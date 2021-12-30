//
//  AMStorage.swift
//  Airmey
//
//  Created by supertext on 2020/7/6.
//  Copyright © 2020年 airemy. All rights reserved.
//

import CoreData
import Foundation

/// AMManagedObject ID protocol
/// Do not declare new conformances to this protocol;
/// They will not work as expected
public protocol AMObjectID:Codable,Hashable{}

extension Int:AMObjectID{}
extension Int8:AMObjectID{}
extension Int16:AMObjectID{}
extension Int32:AMObjectID{}
extension Int64:AMObjectID{}
extension UUID:AMObjectID{}
extension String:AMObjectID{}
extension Optional:AMObjectID where Wrapped:AMObjectID{}

extension AMObjectID{
    var objectId:String{
        switch self {
        case let int as Int8:
            return String(int)
        case let int as Int16:
            return String(int)
        case let int as Int32:
            return String(int)
        case let int as Int64:
            return String(int)
        case let int as Int:
            return String(int)
        case let id as UUID:
            return id.uuidString
        case let str as String:
            return str
        default:
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
    /// Batch update or delete some NSManagedObject.
    ///
    ///         let jack = orm.query(one:UserObject.self,id:"1")
    ///         let tom = orm.query(one:UserObject.self,id:"2")
    ///         orm.updateAndSave{
    ///             jack?.name = "Mr Jackson"
    ///             jack?.age = 11
    ///             jack?.avatar = "https://example.com/avatar/1"
    ///             orm.delete(tom)
    ///         }
    ///         lable.text = jack?.name // "Mr Jackson"
    ///
    /// - Important: Any changes of NSManagedObject must  be around by this method ,otherwise some crash may occur!!! We must try our best to add all changes in one batch.
    /// - Important: The closure will be execute in NSManagedObjectContext's queue. So UI operation shouldn't be include in it.
    /// - Important: `query overlay insert` methods shouldn't be include in the closure. otherwise deadlock may occur
    ///
    /// - Parameters:
    ///    - closure: will be execute synchronously in the NSManagedObjectContext's private queue
    ///
    public func updateAndSave(_ closure:()->Void){
        self.moc.performAndWait {
            closure()
            try? self.moc.save()
        }
    }
    ///
    /// Delete a managed object from database.
    /// - Parameters:
    ///     - object: The instance that will be delete
    /// - Warning: This method must be around by updateAndSave { }
    ///
    public func delete(_ object:NSManagedObject?){
        if let object = object {
            self.moc.delete(object)
        }
    }
    ///
    /// Delete a managed object from database.
    /// - Parameters:
    ///     - objects: The instance array that will be delete
    /// - Warning: This method must be around by updateAndSave { }
    ///
    public func delete(_ objects:[NSManagedObject]?){
        if let objects = objects {
            objects.forEach {
                self.moc.delete($0)
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
    public func overlay<Object:AMManagedObject>(
        _ type:Object.Type,
        models:[Object.Model],
        where predicate:NSPredicate?=nil) throws -> [Object] {
        var results:[Object] = [];
        var err:Error? = nil
        self.moc.performAndWait {
            do {
                let olds = self._query(type, where: predicate)
                results = try self.create(type, models:models)
                var rms = [Object]()
                olds.forEach{ old in
                    let idx = results.firstIndex { new in
                        new.id == old.id
                    }
                    if idx == nil{
                        rms.append(old)
                    }
                }
                rms.forEach { obj in
                    self.moc.delete(obj)
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
    ///  Insert or update a managed object from model
    /// - Parameters:
    ///     - type: An `AMManagedObject` subclass type
    ///     - model: The data source model instance
    /// - Throws: some system error from moc.
    /// - Returns: A newly or updated managed object instance
    ///
    @discardableResult
    public func insert<Object:AMManagedObject>(
        _ type:Object.Type,
        model:Object.Model) throws -> Object{
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
    public func insert<Object:AMManagedObject>(
        _ type:Object.Type,
        models:[Object.Model]) throws -> [Object]{
        var results:[Object] = []
        var err:Error? = nil
        self.moc.performAndWait {
            do {
                results = try self.create(type, models:models)
                try self.moc.save()
            } catch{
                err = error
            }
        }
        if let err = err {
            throw err
        }
        return results
    }
    ///
    ///  Query a managed object form id
    /// - Parameters:
    ///     - type: An `AMManagedObject` subclass type
    ///     - id: The object primary id
    /// - Returns: The managed object  if matching the id
    ///
    public func query<Object:AMManagedObject>(
        one type:Object.Type,
        id:Object.IDValue) -> Object?{
        var obj:Object? = nil
        self.moc.performAndWait {
            obj = self._query(one: type, id: id)
        }
        return obj
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
    public func query<Object:NSManagedObject>(
        _ type:Object.Type,
        where predicate:NSPredicate?=nil,
        page:(index:Int,size:Int)?=nil,
        sorts:[NSSortDescriptor]? = nil)->[Object]
    {
        var results:[Object] = []
        self.moc.performAndWait {
            results = self._query(type, where: predicate, page: page, sorts: sorts)
        }
        return results
    }
    ///
    ///  Query the count of objects that matching the predicate
    /// - Parameters:
    ///     - type: An `AMManagedObject` subclass type
    ///     - predicate: The querey predicate
    /// - Returns: The managed objects count that matching the predicate
    ///
    public func count<Object:NSManagedObject>(
        for type:Object.Type,
        where predicate:NSPredicate?=nil) -> Int{
        var count = 0
        self.moc.performAndWait {
            let request = type.fetchRequest()
            request.predicate = predicate
            if let int = try? self.moc.count(for: request) {
                count = int
            }
        }
        return count
    }
}
//MARK: private methods
extension AMStorage{
    public func _query<Object:AMManagedObject>(
        one type:Object.Type,
        id:Object.IDValue) -> Object?{
        guard  id.objectId.count > 0 else {
            return nil
        }
        let predicate = NSPredicate(format:"id == %@",id.objectId)
        return self._query(type, where: predicate).first
    }
    private func _query<Object:NSManagedObject>(
        _ type:Object.Type,
        where predicate:NSPredicate?=nil,
        page:(index:Int,size:Int)?=nil,
        sorts:[NSSortDescriptor]? = nil)->[Object]
    {
        let request = type.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = sorts
        if let page = page {
            request.fetchLimit = page.size
            request.fetchOffset = page.index * page.size
        }
        return  (try? self.moc.fetch(request) as? [Object]) ?? []
    }
    private func create<Object:AMManagedObject>(_ type:Object.Type,models:[Object.Model])throws->[Object]{
        var result:[Object] = []
        for mod in models {
            let obj = try self.create(type, model: mod)
            result.append(obj)
        }
        return result
    }
    private func create<Object:AMManagedObject>(_ type:Object.Type, model:Object.Model)throws->Object{
        guard let id = try? type.id(for: model),
              id.objectId.count>0 else {
            throw AMError.invalidId
        }
        let request = type.fetchRequest()
        request.predicate = NSPredicate(format:"id == %@",id.objectId);
        let obj = (try self.moc.fetch(request).first as? Object) ?? type.init(context: self.moc)
        obj.awake(from: model)
        obj.setValue(id, forKey: "id")
        return obj
    }
}
//MARK: async methods
extension AMStorage{
    public func query<Object:AMManagedObject>(
        one type:Object.Type,
        id:Object.IDValue,
        block:((Object?) ->Void)?) {
        self.moc.perform {
            let obj = self._query(one: type, id: id)
            DispatchQueue.main.async {
                block?(obj)
            }
        }
    }
    public func query<Object:NSManagedObject>(
        _ type:Object.Type,
        where predicate:NSPredicate? = nil,
        page:(index:Int,size:Int)? = nil,
        sorts:[NSSortDescriptor]? = nil,
        block:(([Object])->Void)?){
        self.moc.perform {
            let objs = self._query(type, where: predicate,page:page, sorts: sorts)
            DispatchQueue.main.async {
                block?(objs)
            }
        }
    }
}




