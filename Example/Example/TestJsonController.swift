//
//  TestJsonController.swift
//  Example
//
//  Created by supertext on 6/5/21.
//

import UIKit
import Airmey

class TestJsonController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
        self.tabBarItem = UITabBarItem(title: "Json", image: .round(.blue, radius: 10), selectedImage: .round(.red, radius: 10))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {        
        super.viewDidLoad()
        print(JSON(parse: try? JSONEncoder().encode(true)))
        print(NSNumber.init(value: true).stringValue)
        print(NSNumber.init(value: false).stringValue)
        print(JSON(1))
        print(JSON(true))
        print(NSNumber.OCType.bool)
        print(NSNumber.OCType.int8)
        print(NSNumber.OCType.int16)
        print(NSNumber.OCType.int32)
        print(NSNumber.OCType.int64)
        print(NSNumber.OCType.uint64)
        print(NSNumber.OCType.float)
        print(NSNumber.OCType.double)
        let bool:Bool? = true
        let int:Int? = nil
        var json:JSON = (try? JSON.parse("{\"int8\":1.844674407370955e+20}")) ?? .null
        json["int16"] = JSON(Int16.max)
        json["int32"] = JSON(Int32.max)
        json["int_min"] = JSON(Int64.min)
        json["int_max"] = JSON(Int64.max)
        json["uint_max"] = JSON(UInt64.max)
        json["ary"] = [true,Double.pi,Int64.min,Int64.max,UInt64.max,int,[bool],[int]]
        json["dic"] = ["name":"jackson","age":18,"obj":json,"int":int]
        json["empty"] = [:]
        json["null"] = .null
        

        let params:Parameters = ["json":json,"key":"text","bool":bool,"int":int]
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted,.sortedKeys]
        if let data = try? encoder.encode(JSON(params)) {
            print(String(data:data,encoding: .utf8) ?? "")
        }
        var dic = [Int:Int]()
        dic[1] = 2
        dic[2] = 1
        for ele in dic {
            print(ele)
        }
        dic[1] = nil
        for ele in dic {
            print(ele)
        }
    }
}
