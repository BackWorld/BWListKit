# BWListKit

[![CI Status](https://img.shields.io/travis/朱旭宏/BWListKit.svg?style=flat)](https://travis-ci.org/朱旭宏/BWListKit)
[![Version](https://img.shields.io/cocoapods/v/BWListKit.svg?style=flat)](https://cocoapods.org/pods/BWListKit)
[![License](https://img.shields.io/cocoapods/l/BWListKit.svg?style=flat)](https://cocoapods.org/pods/BWListKit)
[![Platform](https://img.shields.io/cocoapods/p/BWListKit.svg?style=flat)](https://cocoapods.org/pods/BWListKit)

![UITableView示例](https://upload-images.jianshu.io/upload_images/1334681-64a0a1c392f38dcf.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/300)

# 简介
> BWListKit 是基于UITableView/UICollectionView封装了各自的delegate、datasource协议方法，提供了基于数据驱动的列表构建方式，采用Adapter适配器大大减少了代码量，提高了开发效率，提高了封装性和统一性。

# 核心类
## BWListAdapter
``` swift
class BWListAdapter: NSObject {
    weak var tableView: UITableView?
    weak var collectionView: UICollectionView?
    weak var scrollDelegate: BWListScrollDelegate?
    
    var data: BWListData? = nil {
        didSet{
            _registerTableView()
            _registerCollectionView()
            
            tableView?.reloadData()
            collectionView?.reloadData()
        }
    }
```
> Adapter类中存储了外部用户的tableView和collectionView，动态进行了cell、header、footer的注册，及数据加载
``` swift
convenience init(tableView: UITableView? = nil,
                     collectionView: UICollectionView? = nil,
                     scrollDelegate: BWListScrollDelegate? = nil) {
        self.init()
        
        if tableView == nil && collectionView == nil {
            fatalError("必须提供一个UITableView或UICollectionView！")
        }
        else if tableView != nil && collectionView != nil{
            fatalError("只能绑定一个UITableView或UICollectionView！")
        }
        
        tableView?.dataSource = self
        tableView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.delegate = self
        
        self.tableView = tableView
        self.collectionView = collectionView
        self.scrollDelegate = scrollDelegate
    }
```
> 外部调用方法极其简单，传入一个`listView`和`scrollDelegate`即可完成初始化

## BWListAdapter+CollectionView/TableView
> 该extension中主要实现了UICollection/TableView的代理方法，进行了cell、header、footer的设置，及点击等action方法的实现和设置
- CollectionView
``` swift
extension BWListAdapter: UICollectionViewDataSource {
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sections = data!.sections!
        let item = sections[indexPath.section].items![indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.reuseId, for: indexPath)
        
        if let proxy = cell as? BWListItemView {
            proxy.bwListItemViewConfigure(item.data, indexPath: indexPath)
        }
                
        return cell
    }
}
```
- TableView
``` swift
extension BWListAdapter: UITableViewDataSource {
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sections = data!.sections!
        let item = sections[indexPath.section].items![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseId) ?? tableView.dequeueReusableCell(withIdentifier: item.reuseId, for: indexPath)
        
        if let proxy = cell as? BWListItemView {
            proxy.bwListItemViewConfigure(item.data, indexPath: indexPath)
        }
                
        return cell
    }
}
```
- ScrollView
> 该extension中实现了列表的滚动代理UIScrollViewDelegate方法
``` swift
extension BWListAdapter: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.bwListScrollViewDidScroll(scrollView)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollDelegate?.bwListScrollViewDidEndDecelerating(scrollView)
    }
}
```

## BWListData
> 该类为BWListView的数据模型类，其中包含了`BWListRegister`、`BWListSection`、`BWListItem`、`BWListSectionLayout`、`BWListHeaderFooter`、`BWListItemAction`
- BWListRegister //xib、class注册模型
- BWListSection //分组模型
- BWListSectionLayout //分组布局模型
- BWListHeaderFooter //分组头部模型
- BWListItem //cell模型
- BWListItemAction //cell的action（如点击等）模型

# 示例
## UITableView
``` swift
@IBOutlet weak var tableView: UITableView!
    private lazy var listAdapter = BWListAdapter(tableView: tableView)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadData()
    }

private func reloadData() {
        let doingCellRID = STRefundDetailDoingCell.RID
        let successCellRID = STRefundDetailSuccessCell.RID
        let refuseCellRID = STRefundDetailRefuseCell.RID
        let closeCellRID = STRefundDetailCloseCell.RID
        let historyCellRID = STRefundDetailHistoryCell.RID
        let goodsDoingCellRID = STRefundDetailGoodsDoingCell.RID
        let goodsExpressCellRID = STRefundDetailGoodsExpressCell.RID
        let goodsDeliverCellRID = STRefundDetailGoodsDeliverCell.RID
        
        typealias Data = RefundDetailCellData
        let autoHeight = UITableView.automaticDimension
        
        listAdapter.data = .init(registers: [
            doingCellRID, successCellRID, refuseCellRID,
            closeCellRID, historyCellRID, goodsDoingCellRID,
            goodsExpressCellRID, goodsDeliverCellRID
        ].map{
            .init(style: .cell, xib: $0)
        }, sections: [
            .init(items: [
                .init(reuseId: doingCellRID, height: 185, data: doingCellData),
                .init(reuseId: goodsDoingCellRID, height: autoHeight, data: doingCellData),
                .init(reuseId: goodsExpressCellRID, height: autoHeight, data: doingCellData),
                .init(reuseId: goodsDeliverCellRID, height: 138),
                .init(reuseId: successCellRID, height: 160, data: Data(time: "2021/03/04 12:34:56", process: 2)),
                .init(reuseId: closeCellRID, height: 84, data: Data(time: "2021/03/04 12:34:56", process: -1)),
                .init(reuseId: refuseCellRID, height: autoHeight, data: Data(time: "2021/03/04 12:34:56", process: 2, refuse: .init(reason: "商品退回后才能退款", desc: "商品退回后才能退款商品退回后才能退款品退回后才能退款", images: [
                    "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=3408752957,1706848666&fm=26&gp=0.jpg",
                    "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201812%2F17%2F20181217014535_rdqtz.thumb.700_0.jpg&refer=http%3A%2F%2Fb-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1617519148&t=329b0af4fd7ef406f02c8d14639100ec",
                    "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fpic8.58cdn.com.cn%2Fzhuanzh%2Fn_v226a083c72cf844babc7bcf719b0cc0e6.jpg%3Fw%3D750%26h%3D0&refer=http%3A%2F%2Fpic8.58cdn.com.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1617519148&t=9b307f38269ef9efe0cb95d746642169"
                ]))),
                .init(reuseId: historyCellRID, height: 56)
            ])
        ])
    }
```
- Cell用法`需实现BWListItemView协议`
``` swift
class STRefundDetailDoingCell: UITableViewCell, BWListItemView {
    
    @IBOutlet var dots: [UIView]!
    @IBOutlet var lines: [UIView]!
    @IBOutlet var labels: [UILabel]!
    // Data为用户自定义数据结构
    override func bwListItemViewConfigure(_ data: Any?, indexPath: IndexPath) {
        guard let data = data as? Data,
              data.process >= 0 else {
            return
        }
        
        for (i,v) in dots.enumerated() {
            let isSelected = i <= data.process
            v.backgroundColor = isSelected ? STColor.themColorRead : STColor.fontColorE
        }
        for (i,v) in lines.enumerated() {
            let isSelected = i <= (data.process-1)
            v.backgroundColor = isSelected ? STColor.themColorRead : STColor.fontColorE
        }
    }
}
```
## Requirements
- Swift 5.0
- Xcode 12.4
- iOS 9.0

## Installation

BWListKit is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'BWListKit'
```

## 简书
https://www.jianshu.com/p/77d4e5402e3a

## License

BWListKit is available under the MIT license. See the LICENSE file for more info.
