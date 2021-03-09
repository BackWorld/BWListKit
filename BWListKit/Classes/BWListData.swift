//
//  BWListData.swift
//  BWListViewKit
//
//  Created by zhuxuhong on 2020/9/29.
//  Copyright © 2020 zxh. All rights reserved.
//

import UIKit

open class BWListData {
    var registers: [BWListRegister]?
    var sections: [BWListSection]?
    
    public init(registers: [BWListRegister]? = nil, sections: [BWListSection]? = nil) {
        self.registers = registers
        self.sections = sections
    }
}

extension BWListData {
    public var totalHeight: CGFloat {
        var h: CGFloat = 0
        h += sections?.reduce(0, {
            $0 + $1.totalHeight
        }) ?? 0
        return h
    }
}

extension BWListSection {
    public var totalHeight: CGFloat {
        var h: CGFloat = 0
        let count = items?.count ?? 0
        if let insets = layout?.insets {
            h += (insets.top + insets.bottom)
        }
        if let spacing = layout?.minimumLineSpacing {
            h += CGFloat(count-1)*spacing
        }
        items?.forEach{
            h += $0.height
        }
        return h
    }
    public var itemsWidth: CGFloat {
        var w: CGFloat = 0
        let count = items?.count ?? 0
        if let spacing = layout?.minimumInteritemSpacing {
            w += CGFloat(count-1)*spacing
        }
        items?.forEach{
            w += $0.width
        }
        return w
    }
}

extension BWListSection {
    public func groupedItems(withCollectionViewWidth width: CGFloat) -> [[BWListItem]]
    {
        let section = self
        var groupeItems: [[BWListItem]] = []
        var lineItems: [BWListItem] = []
        
        let itemSpacing = section.layout?.minimumInteritemSpacing ?? 0
        
        let items = section.items ?? []
        items.enumerated().forEach
        { (idx, item) in
            var w: CGFloat = 0
            
            lineItems.append(item)
            lineItems.enumerated().forEach { (idx, item) in
                w += item.width
                if idx != lineItems.count-1 {
                    w += itemSpacing
                }
            }
            
            if w >= width {
                if w > width  {
                    groupeItems.append(lineItems.dropLast())
                    lineItems = [item]
                }
                else {
                    groupeItems.append(lineItems)
                    lineItems = []
                }
            }
            /// 补上最后一行
            if idx == items.count-1 && !lineItems.isEmpty {
                groupeItems.append(lineItems)
            }
        }
        return groupeItems
    }
    
}

extension BWListData {
    public var totalItemsCount: Int {
        var count = 0
        sections?.forEach{
            $0.items?.forEach{_ in
                count += 1
            }
        }
        return count
    }
    
    public func calculatedHeight(withCollectionViewWidth width: CGFloat) -> CGFloat
    {
        var h: CGFloat = 0
        
        sections?.forEach
        { section in
            var w = width
            if let insets = section.layout?.insets {
                h += (insets.top + insets.bottom)
                w -= (insets.left + insets.right)
            }
            
            if let header = section.header {
                h += header.height
            }
            
            let groups = section.groupedItems(withCollectionViewWidth: w)
            groups.forEach
            {
                var maxH: CGFloat = 0
                $0.forEach
                { item in
                    if maxH <= item.height {
                        maxH = item.height
                    }
                }
                h += maxH
            }
            let lineSpacing = section.layout?.minimumLineSpacing ?? 0
            h += CGFloat(groups.count-1) * lineSpacing
            
            if let footer = section.footer {
                h += footer.height
            }
        }
        return h
    }
}

public struct BWListRegister {
    public enum Style: String {
        case cell
        case header
        case footer
    }
    
    var style: Style!
    var xib: String?
    var `class`: AnyClass?
    var reuseId: String!
    
    public init(style: Style! = .cell, xib: String? = nil, class: AnyClass? = nil, reuseId: String? = nil) {
        if xib == nil && `class` == nil {
            fatalError("注册的\(style.rawValue)必须提供一个xib或class！")
        }
        self.style = style
        self.xib = xib
        self.class = `class`
        self.reuseId = reuseId ?? (xib ?? "\(`class`!.self)")
    }
}

open class BWListItem {
    var reuseId: String!
    var data: Any?
    /// 实现`BWListItemViewSize`协议可手动计算宽、高
    var width: CGFloat!
    var height: CGFloat!
    var action: BWListItemAction?
    
    ///!!! 注意collection view 的cell的width、height不能为0
    public init(reuseId: String? = nil, width: CGFloat = 0, height: CGFloat = 0, data: Any? = nil, action: BWListItemAction? = nil) {
        self.reuseId = reuseId
        self.width = width
        self.height = height
        self.data = data
        self.action = action
    }
}

open class BWListHeaderFooter {
    var view: UIView?
    var reuseId: String?
    var width: CGFloat!
    var height: CGFloat!
    var data: Any?
    
    /// !!! 注意collectionView的header、footer必须通过注册xib方式实现
    /// 不能指定view
    public init(view: UIView? = nil, reuseId: String? = nil, width: CGFloat = 0, height: CGFloat = 0, data: Any? = nil) {
        self.view = view
        self.reuseId = reuseId
        self.width = width
        self.height = height
        self.data = data
    }
}

open class BWListSection {
    var layout: BWListSectionLayout?
    var header: BWListHeaderFooter?
    var footer: BWListHeaderFooter?
    var items: [BWListItem]?
    
    public init(layout: BWListSectionLayout? = nil, header: BWListHeaderFooter? = nil, footer: BWListHeaderFooter? = nil, items: [BWListItem] = []) {
        self.layout = layout
        self.header = header
        self.footer = footer
        self.items = items
    }
}

public struct BWListSectionLayout {
    var insets = UIEdgeInsets.zero
    var minimumInteritemSpacing: CGFloat = 0
    var minimumLineSpacing: CGFloat = 0
    
    public init(insets: UIEdgeInsets = .zero, minimumInteritemSpacing: CGFloat = 0, minimumLineSpacing: CGFloat = 0) {
        self.insets = insets
        self.minimumInteritemSpacing = minimumInteritemSpacing
        self.minimumLineSpacing = minimumLineSpacing
    }
}

public struct BWListItemAction {
    public typealias ItemDidSelectHandler = (_ data: Data)->Void
    public struct Data {
        var indexPath: IndexPath!
        var data: Any?
        var tableView: UITableView!
        var tableViewCell: UITableViewCell!
        var collectionView: UICollectionView!
        var collectionViewCell: UICollectionViewCell!
    }
    
    var didSelectItem: BWListItemAction.ItemDidSelectHandler?
    
    public init(didSelectItem: BWListItemAction.ItemDidSelectHandler? = nil) {
        self.didSelectItem = didSelectItem
    }
}
