//
//  AMStorage.swift
//  Airmey
//
//  Created by supertext on 2020/7/6.
//  Copyright © 2020年 airemy. All rights reserved.
//

import CoreData
import Foundation

///AMManagedObject ID protocol
public protocol AMObjectID:Codable,Hashable{
    /// The raw stirng value
    var rawValue:String{get}
}
extension Int:AMObjectID{
    public var rawValue: String{description}
}
extension Int8:AMObjectID{
    public var rawValue: String{description}
}
extension Int16:AMObjectID{
    public var rawValue: String{description}
}
extension Int32:AMObjectID{
    public var rawValue: String{description}
}
extension Int64:AMObjectID{
    public var rawValue: String{description}
}
extension UUID:AMObjectID{
    public var rawValue: String{uuidString}
}
extension String:AMObjectID{
    public var rawValue: String{self}
}
extension Optional:AMObjectID where Wrapped:AMObjectID{
    public var rawValue: String{
        switch self {
        case .some(let v):
            return v.rawValue
        case .none:
            return ""
        }
    }
}
/// `AMManagedObject` protocol describe a schema of managed object for orm structure
///
/// - Parameters:
///     - IDValue: The primary key type
///     - Model: The data source data type.
///
public protocol AMManagedObject:NSManagedObject{
    associatedtype IDValue:AMObjectID
    associatedtype Model
    /// The primary id builder from model
    static func id(for model:Model)throws->IDValue
    /// The  primary key of managed object
    var id:IDValue{get}
    /// The model to managed object transfer.  Usualy it's a model initialize method
    func awake(from model:Model)
}

public protocol AMEntityConfigure:NSManagedObject{
    static func config(for entity:NSEntityDescription)
}
/// global stoage configure
/// User can inherit from this class for custom and extensions。
open class AMStorage{
    private let mom:NSManagedObjectModel
    private let moc:NSManagedObjectContext
    private let psc:NSPersistentStoreCoordinator
    private lazy var queue:DispatchQueue = {
        DispatchQueue(label: "com.airmey.sqlite.queue")
    }()
    public init(momd url:URL) throws{
        guard let mom = NSManagedObjectModel(contentsOf: url) else {
            throw AMError.momdNotFound
        }
        self.mom = mom
        self.moc = NSManagedObjectContext(concurrencyType:.privateQueueConcurrencyType);
        self.psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        let storeURL = URL(fileURLWithPath:"\(AMPhone.docDir)/\(url.lastPathComponent).db");
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
        for entity in self.mom.entities{
            guard let type = NSClassFromString(entity.managedObjectClassName) else{
                return
            }
            if let configType = type as? AMEntityConfigure.Type{
                configType.config(for: entity)
            }
        }
    }
}
//MARK: public sync methods
extension AMStorage{
    ///
    /// Delete a managed object from database.
    /// - Parameters:
    ///     - object: The instance that will be delete
    /// - Throws: some system error from moc.
    ///
    public func delete(_ object:NSManagedObject?)throws{
        if let object = object {
            var err:Error? = nil
            self.moc.performAndWait {
                do {
                    self.moc.delete(object)
                    try self.moc.save();
                } catch {
                    err = error
                }
            }
            if let err = err{
                throw err
            }
        }
    }
    ///
    /// Delete a managed object from database.
    /// - Parameters:
    ///     - objects: The instance array that will be delete
    /// - Throws: some system error from moc.
    ///
    public func delete(_ objects:[NSManagedObject]?)throws{
        if let objects = objects {
            var err:Error? = nil
            self.moc.performAndWait {
                do {
                    objects.forEach {
                        self.moc.delete($0)
                    }
                    try self.moc.save();
                } catch {
                    err = error
                }
            }
            if let err = err{
                throw err
            }
        }
    }
    /// overlay all the object of the AMManagedObject Type
    /// Unlike insert , This method will remove all the object which not exsit in the `models`
    ///
    /// - Parameters:
    ///     - type: type of AMManagedObject
    ///     - models: source models that need to been insert
    ///     - where: the qurey condition tha will been overlay
    /// - Throws: Some error from moc or id not exsit
    /// - Returns: The result object list
    ///
    @discardableResult
    public func overlay<Object:AMManagedObject>(_ type:Object.Type,models:[Object.Model],where predicate:NSPredicate?=nil)throws->[Object]{
        var results:[Object] = [];
        var err:Error? = nil
        self.moc.performAndWait {
            do {
                results = try self.create(type, models:models)
                let olds = self.query(type, where: predicate)
                olds.forEach{ old in
                    let idx = results.firstIndex { new in
                        new.id == old.id
                    }
                    if idx == nil{
                        self.moc.delete(old)
                    }
                }
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
    ///
    ///  Insert or update an managed object from model
    /// - Parameters:
    ///     - type: An `AMManagedObject` subclass type
    ///     - model: The data source model instance
    /// - Throws: some system error from moc.
    /// - Returns: A newly or updated managed object instance
    ///
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
        return obj!//never nil
    }
    ///
    ///  Insert or update a group of managed object from models
    /// - Parameters:
    ///     - type: An `AMManagedObject` subclass type
    ///     - models: The data source model instance list
    /// - Throws: some system error from moc.
    /// - Returns: A newly or updated managed object instance list
    ///
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
    ///
    ///  Query a managed object form id
    /// - Parameters:
    ///     - type: An `AMManagedObject` subclass type
    ///     - id: The object primary id
    /// - Returns: The managed object  if matching the id
    ///
    public func query<Object:AMManagedObject>(one type:Object.Type, id:Object.IDValue)->Object?{
        guard id.rawValue.count > 0 else {
            return nil
        }
        let predicate = NSPredicate(format:"id == %@",id.rawValue)
        return self.query(type, where: predicate).first
    }
    ///
    ///  Query all managed objects which match the predicate
    /// - Parameters:
    ///     - type: An `AMManagedObject` subclass type
    ///     - predicate: The querey predicate
    ///     - page: The pageable query parameters
    ///     - sorts: A `NSSortDescriptor` instance. just like order by
    /// - Returns: The managed objects matching the predicate
    ///
    public func query<Object:NSManagedObject>(_ type:Object.Type,where predicate:NSPredicate?=nil,page:(index:Int,size:Int)?=nil,sorts:[NSSortDescriptor]? = nil)->[Object]{
        let request = type.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = sorts
        if let page = page {
            request.fetchLimit = page.size
            request.fetchOffset = page.index * page.size
        }
        let objs = try? self.moc.fetch(request) as? [Object];
        return objs ?? []
    }
    ///
    ///  Query the count of objects that matching the predicate
    /// - Parameters:
    ///     - type: An `AMManagedObject` subclass type
    ///     - predicate: The querey predicate
    /// - Returns: The managed objects count that matching the predicate
    ///
    public func count<Object:NSManagedObject>(for type:Object.Type,where predicate:NSPredicate?=nil)->Int{
        let request = type.fetchRequest()
        request.predicate = predicate
        let count = try? self.moc.count(for: request)
        return count ?? 0
    }
    /// commit all the insert or update operation
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
        guard let id = try? type.id(for: model),
              id.rawValue.count>0 else {
            throw AMError.invalidId
        }
        let request = type.fetchRequest()
        request.predicate = NSPredicate(format:"id == %@",id.rawValue);
        let object = (try? self.moc.fetch(request))?.first as? Object ?? type.init(context: self.moc)
        object.awake(from: model)
        object.setValue(id, forKey: "id")
        return object
    }
}
//MARK: async methods
extension AMStorage{
    public func insert<Object:AMManagedObject>(_ type:Object.Type,model:Object.Model,block:ONResult<Object>?){
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
    public func insert<Object:AMManagedObject>(_ type:Object.Type,models:[Object.Model],block:ONResult<[Object]>?){
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
    public func query<Object:AMManagedObject>(
        one type:Object.Type,
        id:Object.IDValue,
        block:((Object?) ->Void)?) {
        self.queue.async {
            let obj = self.query(one: type, id: id)
            DispatchQueue.main.async {
                block?(obj)
            }
        }
    }
    public func query<Object:NSManagedObject>(
        _ type:Object.Type,
        where predicate:NSPredicate?=nil,
        page:(index:Int,size:Int)?=nil,
        sorts:[NSSortDescriptor]? = nil,
        block:(([Object])->Void)?){
        self.queue.async {
            let objs = self.query(type, where: predicate,page:page, sorts: sorts)
            DispatchQueue.main.async {
                block?(objs)
            }
        }
    }
}




