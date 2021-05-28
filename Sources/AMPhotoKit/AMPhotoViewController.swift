//
//  AMPhotoViewController.swift
//  Airmey
//
//  Created by supertext on 2020/6/24.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit

open class AMPhotoViewController: UIViewController {
    public let photoView:AMPhotoView
    public weak internal(set) var listController:AMPhotoListController?{
        didSet{
            if listController != oldValue {
                self.photoView.delegate = listController
            }
        }
    }
    required public init(model:AMPhoto,config:AMPhotoConfig = .default){
        self.photoView = AMPhotoView(model: model, config: config)
        super.init(nibName: nil, bundle: nil)
        self.photoView.delegate = self
        self.extendedLayoutIncludesOpaqueBars = true
        self.photoView.animatingStatusChanged = {[weak self] (sender,animating) in
            self?.view.isUserInteractionEnabled = !animating
            self?.listController?.view.isUserInteractionEnabled = !animating
        }
    }
    open override var navigationController: UINavigationController?{
        if let list = self.listController{
            return list.navigationController
        }
        return super.navigationController
    }
    open override func loadView() {
        super.loadView()
        self.view.addSubview(self.photoView)
    }
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.photoView.showZoomView()
        }
    }
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.photoView.restore(animated: true)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension AMPhotoViewController:AMPhotoViewDelegate{
    
}
