//
//  JSON.swift
//  Airmey
//
//  Created by supertext on 2020/1/15.
//  Copyright © 2020年 airmey. All rights reserved.
//
import Foundation

///
/// Common value type JSON data model stucture
/// Add Collection Codable subscript ... implementions
///
public enum JSON {
    case null
    case bool(Bool)
    case array(Array)
    case object(Object)
    case string(String)
    case number(NSNumber)
    public typealias Array = [JSON]
    public typealias Object = [String:JSON]
}

public extension JSON{
    static func parse(_ string:String)throws->JSON{
        return try JSON.parse(Data(string.utf8))
    }
    static func parse(_ data:Data)throws ->JSON{
        let obj = try JSONSerialization.jsonObject(with: data, options: [])
        return JSON(obj)
    }
    init(parse string: String?){
        guard let string = string,let json = try? JSON.parse(string) else {
            self = .null
            return
        }
        self = json
    }
    init(parse data: Data?){
        guard let data = data,let json = try? JSON.parse(data) else {
            self = .null
            return
        }
        self = json
    }
    init(_ json:Any?=nil){
        guard let json = json else {
            self = .null
            return
        }
        if json is NSNull {
            self = .null
            return
        }
        switch json {
        case let value as JSON:
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
            self = .array(value.map(JSON.init))
        case let value as NSArray:
            self = .array(value.map(JSON.init))
        case let value as [String: Any]:
            self = .object(value.mapValues(JSON.init))
        case let value as NSDictionary:
            let result = value.reduce(into:Object()) { map, ele in
                if let key = ele.key as? String{
                    map[key] = JSON(ele.value)
                }
            }
            self = .object(result)
        default:
            self = .null
        }
    }
    mutating func merge(_ other:JSON){
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
extension JSON:Equatable{
    public static func ==(lhs: JSON, rhs: JSON) -> Bool {
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
/// Simple JSON Value
/// Do not declare new conformances to this protocol
/// they will not work as expected.
public protocol JSONValue:Codable{}

extension Int:JSONValue{}
extension Int8:JSONValue{}
extension Int16:JSONValue{}
extension Int32:JSONValue{}
extension Int64:JSONValue{}

extension UInt:JSONValue{}
extension UInt8:JSONValue{}
extension UInt16:JSONValue{}
extension UInt32:JSONValue{}
extension UInt64:JSONValue{}

extension Bool:JSONValue{}
extension Float:JSONValue{}
extension Double:JSONValue{}
extension String:JSONValue{}

extension JSON:JSONValue{}
extension Array:JSONValue where Element:JSONValue{}
extension Optional:JSONValue where Wrapped:JSONValue{}
extension Dictionary:JSONValue where Key==String,Value:JSONValue{}

extension JSON:ExpressibleByStringInterpolation{
    public init(stringLiteral value: String) {
        self = .string(value)
    }
    public init(stringInterpolation: DefaultStringInterpolation) {
        self = .string(stringInterpolation.description)
    }
}
extension JSON:ExpressibleByArrayLiteral{
    public init(arrayLiteral elements: JSONValue...) {
        self = .array(elements.map(JSON.init))
    }
}
extension JSON:ExpressibleByDictionaryLiteral{
    public init(dictionaryLiteral elements: (String, JSONValue)...) {
        let obj = elements.reduce(into: Object()) {
            $0[$1.0] = JSON($1.1)
        }
        self = .object(obj)
    }
}
extension JSON:ExpressibleByFloatLiteral{
    public init(floatLiteral value: FloatLiteralType) {
        self = .number(NSNumber(value:value))
    }
}
extension JSON:ExpressibleByIntegerLiteral{
    public init(integerLiteral value: IntegerLiteralType) {
        self = .number(NSNumber(value:value))
    }
}
extension JSON:ExpressibleByBooleanLiteral{
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .bool(value)
    }
}
extension JSON:ExpressibleByNilLiteral{
    public init(nilLiteral: ()) {
        self = .null
    }
}

/// Do not declare new conformances to this protocol;
/// they will not work as expected.
public protocol JSONIndex:Codable{}
extension String:JSONIndex{}
extension Int:JSONIndex{}

extension JSON{
    public subscript(key:JSONIndex)->JSON{
        get{
            switch (self,key){
            case let (.array(ary),idx as Int):
                return ary.count>idx ? ary[idx] : .null
            case let (.object(dic),str as String):
                return dic[str] ?? .null
            default:
                return .null
            }
        }
        set{
            switch key{
            case let idx as Int:
                guard case .array(var ary) = self else {
                    return
                }
                if ary.count>idx{
                    ary[idx] = newValue
                    self = .array(ary)
                }
            case let str as String:
                switch self{
                case .object(var dic):
                    dic[str] = newValue
                    self = .object(dic)
                case .null:
                    self = .object([str:newValue])
                default :
                    break
                }
            default:
                break
            }
        }
    }
    private subscript(path: [JSONIndex]) -> JSON {
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
    public subscript(path: JSONIndex...) -> JSON {
        get {
            return self[path]
        }
        set {
            self[path] = newValue
        }
    }
}

public extension JSON{
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
    @inlinable var uint64:UInt64?{
        return self.number?.uint64Value
    }
    @inlinable var uint64Value:UInt64{
        return self.uint64 ?? 0
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
    @inlinable var array:Array?{
        if case .array(let ary) = self {
            return ary
        }
        return nil
    }
    @inlinable var arrayValue:Array{
        return self.array ?? []
    }
    @inlinable var object:Object?{
        if case .object(let dic) = self {
            return dic
        }
        return nil
    }
    @inlinable var objectValue:Object{
        return self.object ?? [:]
    }
}
extension JSON{
    /// Convert rawData  to string  with utf8 encoding
    public var rawString: String{
        if let data = rawData,
           let str = String(data: data, encoding: .utf8){
            return str
        }
        return "null"
    }
    /// Use JSONEncoder to encode it self
    public var rawData:Data?{ try? JSONEncoder().encode(self) }
}
extension JSON:CustomStringConvertible,CustomDebugStringConvertible{
    /// custom serialization for json
    private func toString(_ deep:Int? = nil,strip:Bool = true)-> String{
        switch self {
        case .null:
            return "null"
        case .bool(let value):
            return value.description
        case .number(let value):
            return value.stringValue
        case .string(let value):
            return "\"\(value.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\""))\""
        case .array(var ary):
            if strip {
                ary = ary.filter {$0 != .null}
            }
            guard ary.count>0 else {
                return "[]"
            }
            guard let deep = deep else {
                let str = ary.reduce(""){"\($0)\($1.toString(strip:strip)),"}
                return "[\(str.dropLast())]"
            }
            let result = ary.reduce(""){
                "\($0)\($1.toString(deep+1,strip:strip)),\n\("\t".repeat(deep+1))"
            }.dropLast(deep+3)
            return "[\n\("\t".repeat(deep+1))\(result)\n\("\t".repeat(deep))]"
        case .object(var dic):
            if strip {
                dic = dic.filter {$0.value != .null}
            }
            guard dic.count>0 else {
                return "{}"
            }
            guard let deep=deep else {
                let result = dic.reduce("") {
                    "\($0)\"\($1.key)\":\($1.value.toString(strip:strip)),"
                }
                return "{\(result.dropLast())}"
            }
            let result = dic.reduce(""){
                "\($0)\"\($1.key)\":\($1.value.toString(deep+1,strip: strip)),\n\("\t".repeat(deep+1))"
            }.dropLast(deep+3)
            return "{\n\("\t".repeat(deep+1))\(result)\n\("\t".repeat(deep))}"
        }
    }
    public var description: String{
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted,.sortedKeys]
        if let data = try? encoder.encode(self),
           let str = String(data: data, encoding: .utf8) {
            return str
        }
        return "[ERROR] JSON encode failed"
    }
    public var debugDescription: String{
        toString(0,strip: false)
    }
}
// MARK: - JSON: Codable
extension JSON: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
            return
        }
        if let value = try? container.decode(Bool.self) {
            self = .bool(value)
            return
        }
        if let value = try? container.decode(Int64.self) {
            self = .number(NSNumber(value: value))
            return
        }
        if let value = try? container.decode(UInt64.self) {
            self = .number(NSNumber(value: value))
            return
        }
        if let value = try? container.decode(Double.self) {
            self = .number(NSNumber(value: value))
            return
        }
        if let value = try? container.decode(String.self) {
            self = .string(value)
            return
        }
        if let value = try? container.decode(Array.self) {
            self = .array(value)
            return
        }
        if let value = try? container.decode(Object.self) {
            self = .object(value)
            return
        }
        self = .null
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null:
            try container.encodeNil()
        case .bool(let bool):
            try container.encode(bool)
        case .number(let number):
            switch  number.octype{
            case .double,.float:
                try container.encode(number.doubleValue)
            case .uint64:
                try container.encode(number.uint64Value)
            default:
                try container.encode(number.int64Value)
            }
        case .string(let string):
            try container.encode(string)
        case .array(let ary):
            try container.encode(ary.filter{$0 != .null})
        case .object(let dic):
            try container.encode(dic.filter{$0.value != .null})
        }
    }
}
extension NSNumber{
    // get objc type for current number
    public var octype:OCType{ OCType(self) }
    /// is bool or not
    public var isBool:Bool{
        return octype == .bool && (int8Value == 0 || int8Value == 1)//OCType.bool == OCType.int8
    }
    // is double or float
    public var isDouble:Bool{
        switch octype {
        case .float,.double:
            return true
        default:
            return false
        }
    }
    /// enum some objc type of number
    public struct OCType:RawRepresentable,Codable,Equatable,Hashable{
        public var rawValue: CChar
        public init(rawValue: CChar) {
            self.rawValue = rawValue
        }
        public init(_ number:NSNumber) {
            self.init(rawValue: number.objCType.pointee)
        }
        public static let bool     = OCType(.init(value:true))
        public static let int8     = OCType(.init(value:Int8.max))
        public static let int16    = OCType(.init(value:Int16.max))
        public static let int32    = OCType(.init(value:Int32.max))
        public static let int64    = OCType(.init(value:Int64.max))
        public static let uint8    = OCType(.init(value:UInt8.max))
        public static let uint16   = OCType(.init(value:UInt16.max))
        public static let uint32   = OCType(.init(value:UInt32.max))
        public static let uint64   = OCType(.init(value:UInt64.max))
        public static let float    = OCType(.init(value:Float(0)))
        public static let double   = OCType(.init(value:Double(0)))
    }
}
