//
//  BWListData.swift
//  BWListViewKit
//
//  Created by zhuxuhong on 2020/9/29.
//  Copyright © 2020 zxh. All rights reserved.
//

import UIKit

open class BWListData {
    public var registers: [BWListRegister]?
    
    public var sections: [BWListSection]?
    
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
        h += header?.height ?? 0
        h += footer?.height ?? 0
        if let spacing = layout?.minimumLineSpacing {
            h += CGFloat(count-1)*spacing
        }
        items?.forEach{
            h += $0.height
        }
        return h
    }
    public static func totalWidthOfItems(_ items: [BWListItem], layout: BWListSectionLayout) -> CGFloat {
        var w: CGFloat = 0
        let count = items.count
        let spacing = layout.minimumInteritemSpacing
        w += CGFloat(count-1)*spacing
        items.forEach{
            w += $0.width
        }
        return w
    }
    public var itemsWidth: CGFloat {
        guard let items = items, let layout = layout else {
            return 0
        }
        return Self.totalWidthOfItems(items, layout: layout)
    }
}

extension BWListSection {
    public func groupedItems(withCollectionViewWidth width: CGFloat) -> [[BWListItem]]
    {
        let section = self
        var groupeItems: [[BWListItem]] = []
        var lineItems: [BWListItem] = []
        
        let insets = section.layout?.insets ?? .zero
        let itemSpacing = section.layout?.minimumInteritemSpacing ?? 0
        let W = width - insets.left - insets.right
        
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
            
            if w >= W {
                if w > W  {
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
            if let insets = section.layout?.insets {
                h += (insets.top + insets.bottom)
            }
            
            if let header = section.header {
                h += header.height
            }
            
            let groups = section.groupedItems(withCollectionViewWidth: width)
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
    
    public var style: Style!
    public var xib: String?
    public var `class`: AnyClass?
    public var reuseId: String!
    
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
    public typealias BWListCellConfigure = (UIView, Any?, IndexPath)->Void
    
    public var reuseId: String!
    public var data: Any?
    /// 实现`BWListItemViewSize`协议可手动计算宽、高
    public var width: CGFloat!
    public var height: CGFloat!
    public var action: BWListItemAction?
    public var cellConfigure: BWListCellConfigure?
    
    ///!!! 注意collection view 的cell的width、height不能为0
    public init(reuseId: String? = nil, width: CGFloat = 0, height: CGFloat = 0, data: Any? = nil, cellConfigure: BWListCellConfigure? = nil, action: BWListItemAction? = nil) {
        self.reuseId = reuseId
        self.width = width
        self.height = height
        self.data = data
        self.action = action
        self.cellConfigure = cellConfigure
    }
}

open class BWListHeaderFooter {
    public var view: UIView?
    public var reuseId: String?
    public var width: CGFloat!
    public var height: CGFloat!
    public var data: Any?
    
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
    public var layout: BWListSectionLayout?
    public var header: BWListHeaderFooter?
    public var footer: BWListHeaderFooter?
    public var items: [BWListItem]?
    
    public init(layout: BWListSectionLayout? = nil, header: BWListHeaderFooter? = nil, footer: BWListHeaderFooter? = nil, items: [BWListItem] = []) {
        self.layout = layout
        self.header = header
        self.footer = footer
        self.items = items
    }
}

public struct BWListSectionLayout {
    public var insets = UIEdgeInsets.zero
    public var minimumInteritemSpacing: CGFloat = 0
    public var minimumLineSpacing: CGFloat = 0
    
    public init(insets: UIEdgeInsets = .zero, minimumInteritemSpacing: CGFloat = 0, minimumLineSpacing: CGFloat = 0) {
        self.insets = insets
        self.minimumInteritemSpacing = minimumInteritemSpacing
        self.minimumLineSpacing = minimumLineSpacing
    }
}

public struct BWListItemAction {
    public typealias ItemDidSelectHandler = (_ data: Data)->Void
    public struct Data {
        public var indexPath: IndexPath!
        public var data: Any?
        public var tableView: UITableView!
        public var tableViewCell: UITableViewCell!
        public var collectionView: UICollectionView!
        public var collectionViewCell: UICollectionViewCell!
    }
    
    var didSelectItem: BWListItemAction.ItemDidSelectHandler?
    
    public init(didSelectItem: BWListItemAction.ItemDidSelectHandler? = nil) {
        self.didSelectItem = didSelectItem
    }
}
