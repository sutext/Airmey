//
//  CoreDataController.swift
//  Example
//
//  Created by supertext on 12/7/21.
//

import UIKit
import Airmey
import CoreData

let orm = Storage()

class Storage: AMStorage {
    fileprivate init() {
        guard let url = Bundle.main.url(forResource: "Model", withExtension: "momd") else {
            fatalError("momd file not found")
        }
        try! super.init(momd: url)
    }
}

@objc(UserObject)
class UserObject:NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserObject> {
        return NSFetchRequest<UserObject>(entityName: "UserObject")
    }
    @NSManaged public var age: Int64
    @NSManaged public var avatar: String?
    @NSManaged public var id: Int64
    @NSManaged public var name: String?

}

extension UserObject : AMManagedObject{
    public static func id(for model: JSON) throws -> Int64 {
        guard let id = model["id"].int64 else {
            throw AMError.invalidId
        }
        return id
    }
    public func awake(from model: JSON) {
        self.name = model.name.string
        self.avatar = model.avatar.string
        self.age = model.age.int64Value
    }
    func toJSON()->JSON{
        return ["id":id,"name":name,"age":age,"avatar":avatar]
    }
}
class CoreDataController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
        self.tabBarItem = UITabBarItem(title: "CoreData", image: .round(.yellow, radius: 10), selectedImage: .round(.cyan, radius: 10))
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let stackView = UIStackView()
    let scrollView = UIScrollView()
    let textLabel = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(self.scrollView)
        self.scrollView.backgroundColor = .white
        self.scrollView.contentInsetAdjustmentBehavior = .never
        navbar.title = "Popup Tester"
        self.scrollView.contentInset = UIEdgeInsets(top: .navbarHeight, left: 0, bottom: .tabbarHeight, right: 0)
        self.scrollView.am.edge.equal(to: 0)
        let images = (1...45).compactMap {
            UIImage(named: String(format: "loading%02i", $0), in: .main, compatibleWith: nil)
        }
        self.scrollView.using(refresh: AMRefreshHeader(.gif(images)))
        self.scrollView.addSubview(self.stackView)
        self.scrollView.delegate = self
        self.stackView.backgroundColor = .white
        self.stackView.axis = .vertical
        self.stackView.alignment = .leading
        self.stackView.distribution = .equalSpacing
        self.stackView.spacing = 20
        self.stackView.amake { am in
            am.center.equal(to: 0)
            am.edge.equal(top: 0, bottom: 0)
        }
        try? self.addTest("Test concurrence") {
            for _ in 0..<10 {
                try orm.insert(UserObject.self, model: self.randomUser())
            }
            DispatchQueue(label: "thread2").async{
                var models:[JSON] = []
                for _ in 0..<100 {
                    models.append(self.randomUser())
                }
                if let users = try? orm.insert(UserObject.self, models: models){
                    orm.updateAndSave {
                        users.forEach({ user in
                            user.age += 1
                        })
                    }
                    DispatchQueue.main.async {
                        self.navbar.title = "thread2 \(users.count)"
                    }
                }
                print("thread2 over")
            }
            DispatchQueue(label: "thread3").asyncAfter(deadline: .now()+0.01){
                var models:[JSON] = []
                for _ in 0..<100 {
                    models.append(self.randomUser())
                }
                let predicate = NSPredicate(format: "id > 1000000")
                if let users = (try? orm.overlay(UserObject.self,models:models,where: predicate)) {
                    orm.updateAndSave {
                        users.forEach { user in
                            if user.id%3 == 1 {
                                user.age += 1
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.navbar.title = "thread3 \(users.count)"
                    }
                }
                print("thread3 over")
            }
            DispatchQueue(label: "thread4").asyncAfter(deadline: .now()+0.01)
            {
                let predicate = NSPredicate(format: "id < 100000")
                let users = orm.query(UserObject.self,where: predicate)
                orm.updateAndSave {
                    users.forEach { user in
                        if user.id%3 == 0 {
                            orm.delete(user)
                        }
                        if user.id%3 == 1 {
                            user.age += 1
                        }
                    }
                }
                print("thread4 over")
                DispatchQueue.main.async {
                    self.navbar.title = "thread4 \(users.count)"
                }
            }
        }
    }
    func addTest(_ text:String,action: (()throws -> Void)?) rethrows {
        let imageLabel = AMImageLabel(.left)
        imageLabel.image = .round(.red, radius: 5)
        imageLabel.text = text
        imageLabel.font = .systemFont(ofSize: 17)
        imageLabel.textColor = .black
        self.stackView.addArrangedSubview(imageLabel)
        imageLabel.onclick = {_ in
            try? action?()
        }
    }
    func randomUser()->JSON{
        var json:JSON = [:]
        let id = Int.random(in: 1...1000000)
        json["id"] = JSON(id)
        json["name"] = "name_\(id)"
        json["avatar"] = "https://avatar.com/id/\(id)"
        json["age"] = JSON(arc4random())
        return json
    }
}
extension CoreDataController: UIScrollViewDelegate{
    
}
