# Airmey

- iOS 开发常用工具集。包含网络，网络图片，存储，弹窗，自动布局以及常用的抽象 UI 控件

- [Airmey](#airmey)
  - [Network](#network)
    - [AMNetwork](#amnetwork)
    - [AMRequest](#amrequest)
    - [AMFileUpload](#amfileupload)
    - [AMFormUpload](#amformupload)
    - [AMMonitor](#ammonitor)
    - [Request](#request)
    - [JSON](#json)
  - [Storage](#storage)
    - [AMStorage](#amstorage)
    - [AMMangedObjet](#ammangedobjet)
  - [Popup](#popup)
    - [AMPresenter](#ampresenter)
    - [AMFramePresenter](#amframepresenter)
    - [AMDimmingPresenter](#amdimmingpresenter)
    - [AMFadeinPresenter](#amfadeinpresenter)
    - [AMPopupCenter](#ampopupcenter)
    - [AMPopupController](#ampopupcontroller)
    - [AMAlertable](#amalertable)
    - [AMActionable](#amactionable)
    - [AMWaitable](#amwaitable)
    - [AMRemindable](#amremindable)
  - [Widgets](#widgets)
    - [AMView](#amview)
    - [AMLabel](#amlabel)
    - [AMButton](#ambutton)
    - [AMSwiper](#amswiper)
    - [AMToolBar](#amtoolbar)
    - [AMDigitLabel](#amdigitlabel)
    - [AMImageLabel](#amimagelabel)
    - [AMImageView](#amimageview)
    - [AMEffectView](#ameffectview)
    - [AMRefreshControl](#amrefreshcontrol)
    - [AMLoadmoreControl](#amloadmorecontrol)
    - [AMTableView](#amtableview)
    - [AMTableViewDelegate](#amtableviewdelegate)
    - [AMCollectionView](#amcollectionview)
    - [AMCollectionViewDelegate](#amcollectionviewdelegate)
    - [AMLayoutViewController](#amlayoutviewcontroller)
  - [AMPhone](#amphone)
  - [AMImageCache](#amimagecache)
  - [AMTimer](#amtimer)
  - [AMDateStyle](#amdatestyle)
  - [AMImage](#amimage)

## Network

- 基于 URLSession 实现的集网络数据请求，表单上传，文件下载一体的工具集。
- 详细用法参考 Example

  ### AMNetwork

  - 网络请求全局参数配置控制类。具体项目需要以继承的方式重写默认参数
  - 通常一个网络请求会包含一个 request 和 一个 response。 request 用于描述请求所需的参数。response 用于描述请求返回数据

  ### AMRequest

  - 一般的数据网络请求协议
  - 主要负责完成请求地址，请求参数，请求头配置，以及返回数据如果序列化

  ### AMFileUpload

  - 继承自 AMRequest，新增文件上传 url 的属性配置

  ### AMFormUpload

  - 继承自 AMRequest，新增表单属性

  ### AMMonitor

  - 网络状态监听器，用于持续侦听网络状态。并发出全局广播

  ### Request

  - 网络请求返回的句柄。用于控制该次网络请求的时效，以及监控请求进度等

  ### JSON

  - 提供基于 swift enum 的高效 json 数据模型。包括序列化和反序列化。已经各种快捷存取。

## Storage

- 基于 CoreData 实现的 ORM 框架，包括对数据表增删改查的封装
  ### AMStorage
  - 数据存储控制类，用于管理 CoreData 上下文，线程队列。
  ### AMMangedObjet
  - ORM 框架数据模型 Schema 协议。需要使用 ORM 的 NSManagedObject 对象都必须实现这个协议

## Popup

- 应用弹窗标准化
  ### AMPresenter
  - 主要实现`UIViewControllerTransitioningDelegate`和`UIViewControllerAnimatedTransitioning`
  - 用于实现 UIViewController 的自定义交互
  ### AMFramePresenter
  - 继承自 AMPresenter 快捷实现视图位移动画弹窗效果，例如 ActionSheet
  ### AMDimmingPresenter
  - 继承自 AMPresenter 仅实现变暗的背景是的动画效果，多数用于和业务相关的自定义弹窗
  ### AMFadeinPresenter
  - 继承自 AMPresenter 仅实现整体弹窗视图的淡入和淡出效果
  ### AMPopupCenter
  - 全局弹窗控制类，主要负责打开和关闭各种弹窗
  ```swift
  let pop = PopupCenter()
  class PopupCenter:AMPopupCenter{
      public override class var Alert: AMAlertable.Type{AMAlertController.self}
      public override class var Action: AMActionable.Type{AMActionController.self}
  }
  class PopupController: UIViewController {
      override func viewDidLoad() {
        pop.wait("loading....")
        pop.idle()
        pop.remind("test1")
        pop.action(["apple","facebook"])
        pop.action(["facebook","apple"])
        pop.remind("testing....")
        pop.alert("test alert",confirm: "确定",cancel: "取消")
        pop.present(PopupController())
      }
  }
  ```
  ### AMPopupController
  - 自定义弹窗控制器基类，多数自定义弹窗可以考虑从此类继承
  ### AMAlertable
  - 对话框类弹窗标准协议
  - 提供一个默认样式的实现 AMAlertController 和一个系统样式弹窗的实现 AMPopupCenter.UIAlert
  ### AMActionable
  - Action sheet 类弹窗标准协议
  - 提供一个默认样式实现 AMActionController 和一个系统样式 acctionsheet 实现。
  ### AMWaitable
  - Loading 类阻塞弹窗标准协议
  - 提供默认样式的实现 AMWaitController
  ### AMRemindable
  - 一闪而过提示性弹窗标准协议
  - 提供默认样式的实现 AMRemindController

## Widgets

- 提供常用的 UI 组件的基本实现

  ### AMView

  - 继承自 `UIView`，提供 onclick（单击）和 doubleClick（双击） 点击事件快捷添加

  ```swift
  let view = AMView()
  view.onclick = {_ in }
  view.doubleClick = {_ in }
  ```

  ### AMLabel

  - 继承自 `UILabel`，提供 onclick 点击事件快捷添加
  - 提供 textInsets 属性以扩展 label 边界

  ```swift
  let label = AMLabel()
  label.text = "test"
  label.textInsets = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 0)
  label.onclick = {_ in
    // do some click action
  }
  ```

  ### AMButton

  - 增加快捷点击事件 onclick 点击事件快捷添加
  - 扩展 `UIButton` 布局实现。提供图文上下排列以及重叠排列方式

  ```swift
  let item = AMButtonItem()
  item.title = "test"
  item.image = UIImage(named:"test")
  let button = AMButton(.bottom)
  button.apply(item:item, for: .normal)
  button.onclick = {_ in }
  ```

  ### AMSwiper

  - 继承自`UIVIew`，基于 UIPageViewController 实现常见的 banner 轮播视图，无限循环列表轮播等功能。详细 example 请运行 example 工程

  ### AMToolBar

  - 参考 UIToolBar。该类被设计为一个工具栏抽象类，只提供了设备兼容的视图层级架构，具体的外观需要自类自行实现。所有的 subview 都应该只被添加到 contentView 里面

  ### AMDigitLabel

  - 继承自 `AMLabel` ，增加滚动数字的支持

  ```swift
    let label = AMDigitLabel()
    label.digit = 1000
  ```

  ### AMImageLabel

  - 继承自 `AMView`，增加图片文字快捷组合布局视图

  ```swift
  let label = AMImageLabel()
  label.font = .systemFont(ofSize: 14)
  label.textColor = .black
  label.text = "test"
  label.spacing = 10
  label.image = UIImage(named:"test")
  label.onclick = {_ in }
  ```

  ### AMImageView

  - 继承自 `UIImageView`，提供 onclick（单击）和 doubleClick（双击） 点击事件快捷添加

  ```swift
  let view = AMImageView()
  view.onclick = {_ in }
  view.doubleClick = {_ in }
  ```

  ### AMEffectView

  - 继承自`AMView`，增加对`UIVisualEffectView`的封装，可快速添加模糊效果

  ```swift
  let contentView = AMEffectView(.light)
  contentView.addSubview(label)
  ```

  ### AMRefreshControl

  - 定义下拉或者上拉刷新的协议，具体刷新的 UI 需要自行实现

  ### AMLoadmoreControl

  - 继承自 UIControl 实现了 AMRefreshControl 协议。提供默认的下拉刷新 UI

  ### AMTableView

  - 继承自 UITableView 增加了 refresh control 的支持

  ### AMTableViewDelegate

  - 继承自 UITableViewDelegate 增加 refresh control 的代理方法

  ### AMCollectionView

  -继承自 UICollectionView 增加 refresh control 的支持

  ### AMCollectionViewDelegate

  - 继承自 UICollectionViewDelegate 增加 refresh control 的代理方法

  ### AMLayoutViewController

  - 继承自 UIViewController 实现侧边栏布局。具体用法请参考 Example 工程

## AMPhone

- 设备尺寸常量
- 设备唯一 ID 实现

## AMImageCache

- 基于 URLSession 实现的网络图片加载，缓存框架

## AMTimer

- 基于 NSTimer 封装计次 timer。处理多线程和循环引用内存泄露的问题。简化定时器的使用。

## AMDateStyle

- 线程安全的日期时间格式化工具方法

## AMImage

- 提供 UIImage 的快捷构造方法
- rect 构造单色矩形图片
- round 构造单色圆形图片
- data 构造支持 gif 的图片
- gradual 构造线性渐变的图片
- qrcode 构造二维码图片
- base64 构造 base64 图片
