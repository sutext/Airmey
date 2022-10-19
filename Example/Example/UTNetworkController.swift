//
//  ViewController.swift
//  Example
//
//  Created by supertext on 5/27/21.
//

import UIKit
import  Airmey


class UTNetowrkController: UIViewController {
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
        self.tabBarItem = UITabBarItem(title: "UTNetwork", image: .round(.blue, radius: 10), selectedImage: .round(.red, radius: 10))
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "UTNetwork"
        self.view.addSubview(self.stackView)
        self.stackView.axis = .vertical
        self.stackView.alignment = .leading
        self.stackView.distribution = .equalCentering
        self.stackView.spacing = 20
        self.stackView.am.center.equal(to: (100,0))
        self.addTest("测试登陆") {
            utnet.request("/public/user/login",params:[
                "identityType":"EMAIL",
                "identifier":"supertext@icloud.com",
                "credential":"zwc20062200337",
                
            ]){
                utenv.token = "\($0.value?["accessToken"].string ?? "")1"///登陆之后设置一个错误的token
                utenv.refreshToken = $0.value?["refreshToken"].string ?? ""///设置正确的refreshtoken
            }
        }
        self.addTest("测试token失效刷新") {///测试并发token失效的情况
            utnet.request("/app/user/info",params: ["userId":1000002],options: .init(.post,headers: UTBaseURL.api.headers)){
                let userId = $0.value?["userId"] ?? ""
                print("请求1结果:",userId)
            }
            utnet.request("/app/user/info",params: ["userId":1000002],options: .init(.post,headers: UTBaseURL.api.headers)){
                let userId = $0.value?["userId"] ?? ""
                print("请求2结果:",userId)
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                utnet.request("/app/user/info",params: ["userId":1000002],options: .init(.post,headers: UTBaseURL.api.headers)){
                    let userId = $0.value?["userId"] ?? ""
                    print("请求3结果:",userId)
                }
                utnet.request("/app/user/info",params: ["userId":1000002],options: .init(.post,headers: UTBaseURL.api.headers)){
                    let userId = $0.value?["userId"] ?? ""
                    print("请求4结果:",userId)
                }
            }
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

