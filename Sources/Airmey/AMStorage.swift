//
//  AMStorage.swift
//  Airmey
//
//  Created by supertext on 2020/7/6.
//  Copyright © 2020年 airemy. All rights reserved.
//

import CoreData
import Foundation

public protocol AMManagedObject:NSManagedObject{
    associatedtype IDValue:Codable
    associatedtype Model
    static func id(for model:Model)throws->IDValue
    var id:IDValue{get}
    func aweak(from model:Model)
}
public protocol AMFetchPropertyConfigurable:NSManagedObject{
    static func config(for entity:NSEntityDescription)
}
open class AMStorage{
    public let mom:NSManagedObjectModel
    public let moc:NSManagedObjectContext
    public let psc:NSPersistentStoreCoordinator
    private lazy var queue:DispatchQueue = {
        DispatchQueue(label: "com.airmey.sqlite.queue")
    }()
    public init(momd url:URL) throws{
        guard let mom = NSManagedObjectModel(contentsOf: url) else {
            throw AMError.sqlite(.momdNotFound)
        }
        self.mom = mom
        self.moc = NSManagedObjectContext(concurrencyType:.privateQueueConcurrencyType);
        self.psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        let storeURL = URL(fileURLWithPath:"\(AMDirectory.doc)/\(url.lastPathComponent).db");
        let opions = [
            NSMigratePersistentStoresAutomaticallyOption:true,
            NSInferMappingModelAutomaticallyOption:true
        ];
        do {
            try self.psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: opions)
        }catch{
            print("Add psc error:",error)
            try? FileManager.default.removeItem(at: storeURL);
            try self.psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: opions)
        }
        self.moc.persistentStoreCoordinator = self.psc;
    }
}
//MARK: public sync methods
extension AMStorage{
    @discardableResult
    public func insert<Object:AMManagedObject>(_ type:Object.Type,model:Object.Model)throws->Object{
        var obj:Object? = nil
        var err:Error? = nil
        self.moc.performAndWait {
            do {
                obj = try self.create(type, model: model)
                try self.moc.save();
            } catch {
                err = error
            }
        }
        if let err = err {
            throw err
        }
        guard let obj = obj else {
            throw AMError.sqlite(.system(info: "unkown"))
        }
        return obj
    }
    @discardableResult
    public func insert<Object:AMManagedObject>(_ type:Object.Type,models:[Object.Model])throws->[Object]{
        var results:[Object] = [];
        var err:Error? = nil
        self.moc.performAndWait {
            do {
                results = try self.create(type, models:models)
                try self.moc.save();
            } catch{
                err = error
            }
        }
        if let err = err {
            throw err
        }
        return results;
    }
    public func query<Object:AMManagedObject>(one type:Object.Type,for id:Object.IDValue)->Object?{
        return self.query(all: type, where: NSPredicate(format: "id == %@","\(id)")).first
    }
    public func query<Object:NSManagedObject>(all type:Object.Type,where predicate:NSPredicate?=nil,page:Int?=nil,size:Int=10,sorts:[NSSortDescriptor]? = nil)->[Object]{
        let request = type.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = sorts
        if let page = page {
            request.fetchLimit = size
            request.fetchOffset = size * page
        }
        let objs = try? self.moc.fetch(request) as? [Object];
        return objs ?? []
    }
    public func count<Object:NSManagedObject>(for type:Object.Type,where predicate:NSPredicate?=nil)->Int{
        let request = type.fetchRequest()
        request.predicate = predicate
        let count = try? self.moc.count(for: request)
        return count ?? 0
    }
    public func save(){
        self.moc.performAndWait{
            do{
                try self.moc.save();
            }catch{
                print(error.localizedDescription)
            }
        }
    }
}
//MARK: private methods
extension AMStorage{
    private func create<Object:AMManagedObject>(_ type:Object.Type,models:[Object.Model])throws->[Object]{
        return try models.map{try self.create(type, model: $0)}
    }
    private func create<Object:AMManagedObject>(_ type:Object.Type, model:Object.Model)throws->Object{
        guard let oid = try? type.id(for: model) else {
            throw AMError.sqlite(.idIsNil(info: "model:\(model)"))
        }
        var id:Any = oid
        let m = Mirror(reflecting: id)
        if case .optional = m.displayStyle {
            guard let nid = m.children.first?.value else{
                throw AMError.sqlite(.idIsNil(info: "model:\(model)"))
            }
            id = nid
        }
        let request = type.fetchRequest()
        request.predicate = NSPredicate(format:"id == %@","\(id)");
        let object = (try? self.moc.fetch(request))?.first as? Object ?? type.init(context: self.moc)
        object.aweak(from: model)
        object.setValue(id, forKey: "id")
        return object
    }
}
//MARK: async methods
extension AMStorage{
    public func insert<Object:AMManagedObject>(_ type:Object.Type,model:Object.Model,block:((Result<Object,Error>) ->Void)?){
        self.queue.async {
            var result:Result<Object,Error>
            do {
                let obj = try self.insert(type, model: model)
                result = .success(obj)
            } catch  {
                result = .failure(error)
            }
            DispatchQueue.main.async {
                block?(result)
            }
        }
    }
    public func insert<Object:AMManagedObject>(_ type:Object.Type,models:[Object.Model],block:((Result<[Object],Error>)->Void)?){
        self.queue.async {
            var result:Result<[Object],Error>
            do {
                let objs = try self.insert(type, models: models)
                result = .success(objs)
            } catch  {
                result = .failure(error)
            }
            DispatchQueue.main.async {
                block?(result)
            }
        }
    }
    public func query<Object:AMManagedObject>(one type:Object.Type,for id:Object.IDValue,block:((Object?) ->Void)?) {
        self.queue.async {
            let obj = self.query(one: type, for: id)
            DispatchQueue.main.async {
                block?(obj)
            }
        }
    }
    public func query<Object:NSManagedObject>(all type:Object.Type,where predicate:NSPredicate?=nil,page:Int?=nil,sorts:[NSSortDescriptor]? = nil,block:(([Object])->Void)?){
        self.queue.async {
            let objs = self.query(all: type, where: predicate,page:page, sorts: sorts)
            DispatchQueue.main.async {
                block?(objs)
            }
        }
    }
}




