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
        print(NSNumber.init(value: true).stringValue)
        print(NSNumber.init(value: false).stringValue)

        print(NSNumber.CType.bool)
        print(NSNumber.CType.int8)
        print(NSNumber.CType.int16)
        print(NSNumber.CType.int32)
        print(NSNumber.CType.int64)
        print(NSNumber.CType.uint64)
        print(NSNumber.CType.float)
        print(NSNumber.CType.double)
        var json:JSON = JSON(json:"{\"int8\":1.844674407370955e+20}")
        json["bool"] = true
        json["int16"] = JSON(Int16.max)
        json["int32"] = JSON(Int32.max)
        json["int_min"] = JSON(Int64.min)
        json["int_max"] = JSON(Int64.max)
        json["uint_max"] = JSON(UInt64.max)
        json["array"] = [true,Double.pi,Int64.min,Int64.max,UInt64.max]
        print(json)
        if let data = try? JSONEncoder().encode(json){
            if let aj = try? JSONDecoder().decode(JSON.self, from: data){
                print(aj)
            }
        }
    }
}
