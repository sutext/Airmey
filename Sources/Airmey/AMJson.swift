//
//  AMJson.swift
//  Airmey
//
//  Created by supertext on 2020/1/15.
//  Copyright © 2020年 airmey. All rights reserved.
//
import Foundation

public enum AMJson {
    case null
    case bool(Bool)
    case array([AMJson])
    case string(String)
    case number(NSNumber)
    case object([String:AMJson])
}
extension NSNumber{
    private static let boolType = NSNumber(value:true).objCType.pointee
    public var isBool:Bool{
        return self.objCType.pointee == NSNumber.boolType
    }
}
public extension AMJson{
    init(json string:String){
        guard let data = string.data(using: .utf8) else {
            self = .null
            return
        }
        self.init(json:data)
    }
    init(json data:Data){
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        self.init(json)
    }
    init(_ json:Any?=nil){
        guard let json = json else {
            self = .null
            return
        }
        switch json {
        case let value as AMJson:
            self = value
        case let value as String:
            self = .string(value)
        case let value as NSNumber:
            if value.isBool{
                self = .bool(value.boolValue)
            }else{
                self = .number(value)
            }
        case let value as [Any]:
            self = .array(value.map{AMJson($0)})
        case let value as NSArray:
            self = .array(value.map{AMJson($0)})
        case let value as [String: Any]:
            self = .object(value.mapValues{AMJson($0)})
        case let value as NSDictionary:
            var result = [String: AMJson]()
            for (key, val) in value {
                if let key = key as? String{
                    result[key] = AMJson(val)
                }
            }
            self = .object(result)
        default:
            self = .null
        }
    }
    mutating func merge(_ other:AMJson){
        switch (self,other) {
        case (.array(let thisary),.array(let otherary)):
            self = .array(thisary + otherary)
        case (.object(var thisdic),.object(let otherdic)):
            for (key,value) in otherdic{
                if var thisval = thisdic[key]{
                    thisval.merge(value)
                    thisdic[key] = thisval
                }else{
                    thisdic[key] = value
                }
            }
            self = .object(thisdic)
        default:
            self = other
        }
    }
}
extension AMJson:Equatable{
    public static func ==(lhs: AMJson, rhs: AMJson) -> Bool {
        switch (lhs,rhs) {
        case (.null,.null):
            return true
        case let (.bool(lvalue),.bool(rvalue)):
            return lvalue == rvalue
        case let (.number(lvalue),.number(rvalue)):
            return lvalue == rvalue
        case let (.string(lvalue),.string(rvalue)):
            return lvalue == rvalue
        case (.array(let lhsary),.array(let rhsary)):
            return lhsary == rhsary
        case (.object(let lhsdic),.object(let rhsdic)):
            return lhsdic == rhsdic
        default:
            return false
        }
    }
}
extension AMJson:ExpressibleByArrayLiteral{
    public init(arrayLiteral elements: Any...) {
        self.init(elements)
    }
}
extension AMJson:ExpressibleByDictionaryLiteral{
    public init(dictionaryLiteral elements: (String, Any)...) {
        let dic = elements.reduce(into: [:]) { result, item in
            result[item.0] = AMJson(item.1)
        }
        self = .object(dic)
    }
}
extension AMJson:ExpressibleByFloatLiteral{
    public init(floatLiteral value: FloatLiteralType) {
        self = .number(NSNumber(value:value))
    }
}
extension AMJson:ExpressibleByIntegerLiteral{
    public init(integerLiteral value: IntegerLiteralType) {
        self = .number(NSNumber(value:value))
    }
}
extension AMJson:ExpressibleByStringLiteral{
    public init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
}
extension AMJson:ExpressibleByBooleanLiteral{
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .bool(value)
    }
}
extension AMJson: Collection {
    public enum Index: Comparable {
        case array(Int)
        case object(DictionaryIndex<String, AMJson>)
        case null
        static public func == (lhs: Index, rhs: Index) -> Bool {
            switch (lhs, rhs) {
            case (.array(let left), .array(let right)):
                return left == right
            case (.object(let left), .object(let right)):
                return left == right
            case (.null, .null): return true
            default:
                return false
            }
        }
        static public func < (lhs: Index, rhs: Index) -> Bool {
            switch (lhs, rhs) {
            case (.array(let left), .array(let right)):
                return left < right
            case (.object(let left), .object(let right)):
                return left < right
            default:
                return false
            }
        }
    }
    public var startIndex: Index {
        switch self {
        case .array(let ary):
            return .array(ary.startIndex)
        case .object(let dic):
            return .object(dic.startIndex)
        default:
            return .null
        }
    }
    public var endIndex: Index {
        switch self {
        case .array(let ary):
            return .array(ary.endIndex)
        case .object(let dic):
            return .object(dic.endIndex)
        default:
            return .null
        }
    }
    public func index(after i: Index) -> Index {
        switch (self,i) {
        case let (.array(ary),.array(idx)):
            return .array(ary.index(after: idx))
        case let (.object(dic),.object(idx)):
            return .object(dic.index(after: idx))
        default:
            return .null
        }
    }
    public var count: Int{
        switch self {
        case .array(let ary):
            return ary.count
        case .object(let obj):
            return obj.count
        default:
            return 0
        }
    }
    public subscript (position: Index) -> (String, AMJson) {
        switch (self,position) {
        case let (.array(ary),.array(idx)):
            return (String(idx), ary[idx])
        case let (.object(dic),.object(idx)):
            return dic[idx]
        default:
            return ("", .null)
        }
    }
}
public enum AMJsonKey{
    case index(Int)
    case key(String)
}
public protocol AMJsonKeyConvertible{
    var mkey:AMJsonKey{get}
}
extension Int:AMJsonKeyConvertible{
    public var mkey: AMJsonKey{
        return .index(self)
    }
}
extension String:AMJsonKeyConvertible{
    public var mkey: AMJsonKey{
        return .key(self)
    }
}

extension AMJson{
    public subscript(sub:AMJsonKeyConvertible)->AMJson{
        get{
            switch (self,sub.mkey){
            case let (.array(ary),.index(idx)):
                return ary[idx]
            case let (.object(dic),.key(key)):
                return dic[key] ?? .null
            default:
                return .null
            }
        }
        set{
            switch sub.mkey{
            case .index(let idx):
                switch self {
                case .array(var ary):
                    if ary.indices.contains(idx){
                        ary[idx] = newValue
                        self = .array(ary)
                    }
                case .null:
                    self = .array([newValue])
                default:
                    break
                }
            case .key(let key):
                switch self{
                case .object(var dic):
                    dic[key] = newValue
                    self = .object(dic)
                case .null:
                    self = .object([key:newValue])
                default :
                    break
                }
            }
        }
    }
    private subscript(path: [AMJsonKeyConvertible]) -> AMJson {
        get {
            return path.reduce(self){$0[$1]}
        }
        set {
            switch path.count {
            case 0:
                return
            case 1:
                self[path[0]] = newValue
            default:
                var aPath = path
                aPath.remove(at: 0)
                var next = self[path[0]]
                next[aPath] = newValue
                self[path[0]] = next
            }
        }
    }
    public subscript(path: AMJsonKeyConvertible...) -> AMJson {
        get {
            return self[path]
        }
        set {
            self[path] = newValue
        }
    }
}

public extension AMJson{
    @inlinable var int8:Int8?{
        return self.number?.int8Value
    }
    @inlinable var int8Value:Int8{
        return self.int8 ?? 0
    }
    @inlinable var int16:Int16?{
        return self.number?.int16Value
    }
    @inlinable var int16Value:Int16{
        return self.int16 ?? 0
    }
    @inlinable var int32:Int32?{
        return self.number?.int32Value
    }
    @inlinable var int32Value:Int32{
        return self.int32 ?? 0
    }
    @inlinable var int:Int?{
        return self.number?.intValue
    }
    @inlinable var intValue:Int{
        return self.int ?? 0
    }
    @inlinable var int64:Int64?{
        return self.number?.int64Value
    }
    @inlinable var int64Value:Int64{
        return self.int64 ?? 0
    }
    @inlinable var float:Float?{
        return self.number?.floatValue
    }
    @inlinable var floatValue:Float{
        return self.float ?? 0
    }
    @inlinable var double:Double?{
        return self.number?.doubleValue
    }
    @inlinable var doubleValue:Double{
        return self.double ?? 0
    }
    @inlinable var number:NSNumber?{
        switch self {
        case .number(let value):
            return value
        case .bool(let value):
            return NSNumber(value: value)
        case .string(let value):
            let decimal = NSDecimalNumber(string: value)
            if decimal == NSDecimalNumber.notANumber {
                return nil
            }
            return decimal
        default:
            return nil
        }
    }
    @inlinable var numberValue:NSNumber{
        return self.number ?? NSDecimalNumber.zero
    }
    @inlinable var string:String?{
        switch self {
        case .string(let value):
            return value
        case .number(let value):
            return value.stringValue
        case .bool(let value):
            return value.description
        default:
            return nil
        }
    }
    @inlinable var stringValue:String{
        return self.string ?? ""
    }
    @inlinable var bool:Bool?{
        switch self {
        case .bool(let value):
            return value
        case .number(let value):
            return value.boolValue
        case .string(let value):
            return Bool(value)
        default:
            return nil
        }
    }
    @inlinable var boolValue:Bool{
        return self.bool ?? false
    }
    @inlinable var array:[AMJson]?{
        if case .array(let ary) = self {
            return ary
        }
        return nil
    }
    @inlinable var arrayValue:[AMJson]{
        return self.array ?? []
    }
    @inlinable var object:[String:AMJson]?{
        if case .object(let dic) = self {
            return dic
        }
        return nil
    }
    @inlinable var objectValue:[String:AMJson]{
        return self.object ?? [:]
    }
}
extension AMJson{
    public var rawString: String{
        switch self {
        case .null:
            return "null"
        case .bool(let value):
            return value.description
        case .number(let value):
            return value.stringValue
        case .string(let value):
            return "\"\(value.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\""))\""
        case .array(let ary):
            let result = ary.reduce("", { (str, json) -> String in
                return "\(str)\(json.rawString),"
            }).dropLast()
            return "[\(result)]"
        case .object(let dic):
            let result = dic.reduce("", { (str, json) -> String in
                return  "\(str)\"\(json.key)\":\(json.value.rawString),"
            }).dropLast()
            return "{\(result)}"
        }
    }
    public var rawData:Data?{
        return self.rawString.data(using: .utf8)
    }
}
extension AMJson:CustomStringConvertible,CustomDebugStringConvertible{
    public var description: String{
        return self.rawString
    }
    public var debugDescription: String{
        guard let data = self.rawData else {
            return ""
        }
        guard let obj = try? JSONSerialization.jsonObject(with: data, options: []) else {
            return ""
        }
        guard let ndata = try? JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted) else {
            return ""
        }
        return String(data: ndata, encoding: .utf8) ?? ""
    }
}
extension AMJson:Codable{
    private enum CodingKeys:CodingKey {
        case json
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawString = try container.decode(String.self, forKey: .json)
        guard let data = rawString.data(using: .utf8) else {
            self = .null
            return
        }
        self.init(try?  JSONSerialization.jsonObject(with: data, options: []))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.rawString, forKey: .json)
    }
}
