//
//  WebImageController.swift
//  Example
//
//  Created by supertext on 6/16/21.
//

import UIKit
import Airmey
class WebImageController: UIViewController {
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    init() {
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(self.stackView)
        scrollView.am.edge.equal(to: 0)
        self.stackView.amake { am in
            am.edge.equal(top: 0, left: 0,bottom: 0, right: 0)
        }
        self.stackView.spacing = 10
        self.stackView.axis = .vertical
        self.stackView.alignment = .center
        self.stackView.distribution = .equalSpacing
        print(AMImageCache.shared.diskUseage)
        let urls = [
            "https://media.clipclaps.com/20210507/1/1/9/6/3/1196332fbe91428582f1b833db462d0b.jpg",
            "https://gcdn.channelthree.tv/20210206/7/0/4/b/3/704b3a55cdee408093f1c9446910dfd2.jpg",
            "https://gcdn.channelthree.tv/20201201/3/d/b/c/b/3dbcb33529fa451d9e2272d18e39aa5f.jpg",
            "https://gcdn.channelthree.tv/20201201/2/1/4/d/a/214dabf4f0c249f8a2c111e01526eb7e.jpg",
            "https://gcdn.channelthree.tv/20201201/7/4/d/4/b/74d4b8f0cca649f589d6ca595512d7f0.jpg",
            "https://gcdn.channelthree.tv/20201201/1/0/9/1/6/1091663def194270ae637691310941c5.jpg",
            "https://gcdn.channelthree.tv/20201201/b/d/e/e/4/bdee415d4294485a851c963240efc0b8.jpg",
            "https://gcdn.channelthree.tv/20201201/3/9/6/8/c/3968c46126c04cc088aeb43ff4dfd7fb.jpg",
            "https://gcdn.channelthree.tv/20201201/3/7/7/1/8/37718a817d9f43dcba26983cd9b7509b.jpg",
            "https://gcdn.channelthree.tv/20201201/6/8/c/c/b/68ccb2b68fa4411b8fe3f01a65cbc685.jpg"
        ]
        urls.forEach { self.addImage(url: $0) }
    }
    func addImage(url:String){
        let imageView = UIImageView()
        imageView.am.size.equal(to: (self.view.frame.width,self.view.frame.width/1.7))
        imageView.setImage(with: url)
        self.stackView.addArrangedSubview(imageView)
    }
}
