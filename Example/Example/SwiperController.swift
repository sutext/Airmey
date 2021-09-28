//
//  SwiperController.swift
//  Example
//
//  Created by supertext on 6/15/21.
//

import UIKit
import Airmey

class SwiperController: UIViewController {
    let nodes:[ChildController]
    let swiper = AMSwiper()
    let segment:CCSegmentControl
    init() {
        let chanels = ["chanel1","chanel2","chanel3","chanel4","chanel5"]
        self.segment = CCSegmentControl(items: chanels)
        self.nodes = chanels.map(ChildController.init)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(swiper)
        self.view.addSubview(segment)
        segment.am.edge.equal(top: .navbarHeight, left: 0, right: 0)
        segment.set(badge: 1, at: 0)
        swiper.am.edge.equal(to: 0)
        swiper.delegate = self
        swiper.indicator = segment
        swiper.reload()
    }
}

extension SwiperController:AMSwiperDelegate{
    
    func headNode(for swiper: AMSwiper) -> UIViewController? {
        return nodes[0]
    }
    func swiper(_ swiper: AMSwiper, nodeAtIndex index: Int) -> UIViewController {
        return nodes[index]
    }
    func swiper(_ swiper: AMSwiper, indexOfNode node: UIViewController) -> Int {
        let idx = nodes.firstIndex{ node  == $0}
        return idx ?? 0
    }
    func swiper(_ swiper: AMSwiper, nodeAfter node: UIViewController) -> UIViewController? {
        let idx = nodes.firstIndex{ node  == $0}
        guard let idx = idx else {
            return nil
        }
        return nodes[(idx+1)%nodes.count]
    }
    
    func swiper(_ swiper: AMSwiper, nodeBefore node: UIViewController) -> UIViewController? {
        let idx = nodes.firstIndex{ node  == $0}
        guard let idx = idx else {
            return nil
        }
        return nodes[(nodes.count+idx-1)%nodes.count]
    }
}
class ChildController: UIViewController {
    let channel:String
    init(_ channel:String) {
        self.channel = channel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = channel
        let label = AMLabel()
        label.text = channel
        label.textColor = .black
        self.view.addSubview(label)
        label.am.center.equal(to: 0)
    }
}
