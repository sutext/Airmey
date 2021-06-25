# Airmey

- iOS 开发常用工具集。包含网络，网络图片，存储，弹窗，自动布局以及常用的抽象 UI 控件

- [Airmey](#airmey)
  - [Network](#network)
    - [AMNetwork](#amnetwork)
    - [AMRequest](#amrequest)
    - [AMFileUpload](#amfileupload)
    - [AMFormUpload](#amformupload)
    - [AMMonitor](#ammonitor)
    - [HTTPTask](#httptask)
    - [Retrier](#retrier)
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

```swift
public let net = MYNetwork()

public class MYNetwork: AMNetwork {
    fileprivate init(){
        super.init(baseURL: "https://example.com")
    }
    public override var method: HTTPMethod{
        .post
    }
    public override var retrier: Retrier?{
        return Retrier(limit:1,policy:.immediately,methods:[.post],statusCodes: [404])
    }
    public override var headers: [String : String]{
        let device = UIDevice.current
        let info = Bundle.main.infoDictionary
        var result:[String:String] = [
            "ostype":"ios",
            "sysver":device.systemVersion,
            "apiver":"1",
            "appver":(info?["CFBundleShortVersionString"] as? String) ?? "1.0.0",
            "uuid":AMPhone.uuid,
            "lang":"zh"
        ]
        if env.isLogin ,let token = env.token{
            result["token"] = token
        }
        return result
    }
}
class MyViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "Network Test"
        self.doLogin()
    }
    func doLogin(_ type:String)  {
        pop.wait("login...")
        let token = "xxxx"
        net.request("user/login",["token":token]){
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

}

```

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

### HTTPTask

- 网络请求返回的句柄。用于控制该次网络请求的时效，以及进度观察等

```swift
    let task = net.request("https://example.com/login",["username":"test"])
    task.suspend()//暂停请求
    task.resume()//恢复请求
    task.addObserver(self, forKeyPath: "fractionCompleted", options: [.new], context: nil)//add progress observer
```

### Retrier

- 请求重试器，负责描述重试规则

### JSON

- 提供基于 swift enum 的高效 json 数据模型。包括序列化和反序列化。已经各种快捷存取。

## Storage

- 基于 CoreData 实现的 ORM 框架，包括对数据表增删改查的封装

```swift
extension UserObject:AMManagedObject{
    public static func id(for model: JSON) -> Int64 {
        return model["id"].int64!
    }
    public func aweak(from model: JSON) {
        name = model["username"].string
        avatar = model["headpic"].string
        gender = model["gender"].int16Value
    }
}
public let orm = Storage()
public class Storage: AMStorage {
    fileprivate init() {
        guard let url = Bundle.module.url(forResource: "Example", withExtension: "momd") else {
            fatalError("momd file not found")
        }
        try! super.init(momd: url)
    }
}
func test(){
    var user = try? orm.insert(UserObject.self,["id":1,"username":"xxx","headpic":"xxxx"])
    user.name = "Test"
    orm.save()
    user = orm.query(one:UserObject.self,id:1)
    orm.delete(user)
}
```

### AMStorage

- 数据存储控制类，用于管理 CoreData 上下文，线程队列。

### AMMangedObjet

- ORM 框架数据模型 Schema 协议。需要使用 ORM 的 NSManagedObject 对象都必须实现这个协议

## Popup

- 一套弹窗标准化协议

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

- 基于 UIPageViewController 实现常见的 banner 轮播视图，
- 实现无限循环列表轮播等功能。详细请运行 example 工程

```swift
let swiper = AMSwiper()
self.view.addSubview(swiper)
swiper.dataSource = self
swiper.delegate = self
swiper.reload()
```

### AMToolBar

- 继承自 `UIToolBar`该类被设计为一个工具栏抽象类，提供基本骨架和自动定位。
- 具体的外观需要子类实现，所有的 subview 都应该只被添加到 contentView 里面

```swift
import UIKit
import Airmey

public class CCNavBar: AMToolBar {
    public override class var position: Position{.top}
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public lazy var titleLabel:AMLabel={
        let label = AMLabel()
        self.contentView.addSubview(label)
        label.am.center.equal(to: 0)
        return label
    }()
    public var title:String?{
        get{
            return self.titleLabel.text
        }
        set {
            self.titleLabel.text = newValue
        }
    }
}
```

### AMDigitLabel

- 继承自 `AMLabel` ，实现了滚动数字动画效果的支持

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

- 继承自 `UIControl` 实现了 AMRefreshControl 协议。提供默认的下拉刷新 UI

### AMTableView

- 继承自 `UITableView` 增加了 refresh control 的支持

```swift
public class ViewController: UIViewController {
    let tableView = AMTableView()
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.tableView)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.am.edge.equal(to: 0)
        self.navbar.title = "Videos"
        self.tableView.register(FeedsCell.self)
        self.tableView.using(refreshs: [.top,.bottom])
        self.tableView.contentInset = UIEdgeInsets(top: CCNavBar.contentHeight, left: 0, bottom: 0, right: 0)
        self.reloadData()
    }
    public func reloadData() {
        pop.wait("loading...")
        net.request(CCRequest.Feeds()){resp in
            pop.idle()
            self.tableView.refresh(at: .top)?.endRefreshing()
            guard let objects = resp.value else{
                pop.remind("加载失败")
                return
            }
            self.videos = objects
            self.tableView.reloadData()
        }
    }
    public func loadMore() {
        net.request(CCRequest.Feeds()){resp in
            self.tableView.refresh(at: .bottom)?.endRefreshing()
            guard let objects = resp.value,objects.count>0 else{
                return
            }
            self.videos.append(contentsOf: objects)
            self.tableView.reloadData()
        }
    }
}
extension ViewController:AMTableViewDelegate,UITableViewDataSource{
  func tableView(_ tableView: AMTableView, beginRefresh style: AMRefreshStyle, control: AMRefreshControl) {
        switch style {
        case .top:
            self.reloadData()
        case .bottom:
            self.loadMore()
        }
    }
}
```

### AMTableViewDelegate

- 继承自 `UITableViewDelegate` 增加 refresh control 的代理方法

### AMCollectionView

-继承自 `UICollectionView` 增加 refresh control 的支持

### AMCollectionViewDelegate

- 继承自 `UICollectionViewDelegate` 增加 refresh control 的代理方法

### AMLayoutViewController

- 继承自 `UIViewController` 实现侧边栏布局。具体用法请参考 Example 工程

## AMPhone

- 维护一些和iPhone设备相关的常量

```swift
let uuid = AMPhone.uuid
let isSlim = AMPhone.isSlim//是否是全面屏手机
let isPlus = AMPhone.isPlus//是否是plus宽屏手机
let isSmall = AMPhone.isSmall//是否是5，5s，SE，小屏手机
let width = AMPhone.width//屏幕宽度 枚举类型
let height = AMPhone.height//屏幕高度 枚举类型
let cache = AMPhone.cacheDir//沙盒缓存目录
let doc = AMPhone.docDir//沙盒document 目录
let tmp = AMPHone.temDir//沙盒临时目录
```

## AMImageCache

- 基于 URLSession 实现的网络图片加载，缓存框架类似于 SDWebImage
- 单例类可提供缓存管理，和清空缓存等操作
- `diskUseage` 查询缓存用量
- `clearDisk` 清除所有缓存

```swift
 let imageView = UIImageView()
 imageView.setImage(url:"https://xxxx.com/xx.jpg",placeholder:UIImage(named:"placeholder"))
```

## AMTimer

- 基于 `NSTimer` 封装计次 timer。处理多线程和循环引用内存泄露的问题。简化定时器的使用。

```swift
final public class MyView:UIView{
    private let timer:AMTimer
    let label = UILabel()
    deinit {
        self.timer.stop()
    }
    init(_ frameRate:Double = 30) {
        self.timer = AMTimer(interval: 1.0/frameRate)
        super.init(frame: .zero)
        self.timer.delegate = self
        self.addSubview(label)
        label.am.center.equl(to:0)
    }
    func start(){
        self.timer.start()
    }
}
extension MyView:AMTimerDelegate{
    public func timer(_ timer: AMTimer, repeated times: Int) {
        lable.text = "\(times)"
    }
}
```

## AMDateStyle

- 线程安全的日期时间格式化工具方法
- 表现形式为扩展 String 和 Date 类型提供两个扩展方法

```swift
let string = "2020-09-10 20:20:00"
let date = string.date(for: .full)//"2020-09-10 20:20:00"
let str = date.string(for: .full)//"2020-09-10 20:20:00"
let time:TimeInterval = 1623833102
time.string(for: .full)//2021-06-16 16:45:02
```

## AMImage

- 提供 UIImage 的快捷构造方法
- rect 构造单色矩形图片
- round 构造单色圆形图片
- data 构造支持 gif 的图片
- gradual 构造线性渐变的图片
- qrcode 构造二维码图片
- base64 构造 base64 图片

```swift
var image:UIImage?
image = .data(gifData)
image = .rect(.red,size:CGSize(width:100,height:100))
image = .round(.red,radius:100)
image = .qrcode("https://xxx.com/xxx")
print(image.qrcode!)//https://xxx.com/xxx
image = .base64(base64String)
image = .gradual(CGSize(width:100,height:100),points: .ymin(.red),.ymax(.blue))
```
