//
//  ViewController.swift
//  Example
//
//  Created by supertext on 5/27/21.
//

import UIKit
import  Airmey


class NetowrkController: UIViewController {
    let stackView = UIStackView()
    var oberver:NSKeyValueObservation?
    var progress:Progress? = nil{
        didSet{
            oberver?.invalidate()
            oberver = progress?.observe(\.fractionCompleted, options: .new, changeHandler: { p, c in
                print(p.fractionCompleted)
            })
        }
    }
    init() {
        super.init(nibName: nil, bundle: nil)
        self.tabBarItem = UITabBarItem(title: "Network", image: .round(.blue, radius: 10), selectedImage: .round(.red, radius: 10))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "Network Tester"
        self.view.addSubview(self.stackView)
        self.stackView.axis = .vertical
        self.stackView.alignment = .leading
        self.stackView.distribution = .equalCentering
        self.stackView.spacing = 20
        self.stackView.am.center.equal(to: (100,0))
        self.addTest("Test Login") {
            pop.action(CCLoginType.allCases) { type, idx in
                self.doLogin(type as! CCLoginType)
            }
        }
        self.addTest("上传头像") {[weak self] in
            self?.doUpload()
        }
        self.addTest("下载图片") {
            pop.wait("downloading...")
            let req = net.download("https://media.clipclaps.com/img/20210611/7cde0100308424f6.jpg"){
                pop.idle()
                debugPrint($0)
            }
            self.progress = req?.progress
            
        }
        self.addTest("测试GET") {
            net.request("app/checkPhoneRegistration",options: .get(.api)){
                debugPrint($0)
            }
        }
        self.addTest("测试异常解析") {
            let bool:Bool? = nil
            net.request("feeds/home-pull",params: ["test":["hello":"world"],"testkey":JSON(true),"bool":bool],options: .post(.ugc)){
                debugPrint($0)
            }
        }
        self.addTest("测试webimage") {
            root?.push(WebImageController())
        }
    }
    func doUpload(){
        guard let image = UIImage(named: "test_avatar") else {
            return
        }
        pop.wait("uploading...")
        net.request(.headerToken()){
            guard let token = $0.value?.string else{
                return
            }
            let req = net.upload(UploadAvatar(image,token: token)){
                pop.idle()
                debugPrint($0)
            }
            self.progress = req?.progress
        }
        
    }
    func doLogin(_ type:CCLoginType)  {
        pop.wait("login...")
        let token = "EAADvOD7Q7dQBAHrw4EKbpT1prranKTHz2Sl1TxAmNTRhHXdugZCh0JNRhrbeMbufxP0ONysuUMOxLOdZADO6LYOEnoaQf1EhZBJBWwS6pGjRPk2yCE3tSiOK4rJvfVSm6QZA8M4h7n5hlJgikUZCmZCBiUbq1rvmPBeHUZABU6qDu7m6VfhdLYhEIyUY3ferQ3Ts46bHl7afHcfLAyfZBphWPiFdDR7DC9l0miYFGmszXAZDZD"
        net.request(.login(token,type: type.rawValue)){
            pop.idle()
            debugPrint($0)
            switch $0.result{
            case .success(let info):
                let token = info["token"].stringValue
                pop.remind("login succeed \(token)")
            case .failure(let err):
                pop.remind("loing error:\(err)")
            }
        }
    }
    func addTest(_ text:String,action:(()->Void)?) {
        let imageLabel = AMImageLabel(.left)
        imageLabel.image = .round(.red, radius: 5)
        imageLabel.text = text
        imageLabel.font = .systemFont(ofSize: 17)
        imageLabel.textColor = .black
        self.stackView.addArrangedSubview(imageLabel)
        imageLabel.onclick = {_ in
            action?()
        }
    }
}

