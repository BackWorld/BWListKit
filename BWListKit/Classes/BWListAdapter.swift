//
//  BWListDataAdapter.swift
//  BWListViewKit
//
//  Created by zhuxuhong on 2020/9/29.
//  Copyright © 2020 zxh. All rights reserved.
//

import UIKit

open class BWListAdapter: NSObject {
    public weak var tableView: UITableView?
    public weak var collectionView: UICollectionView?
    public weak var scrollDelegate: BWListScrollDelegate?
    
    public var data: BWListData? = nil {
        didSet{
            _registerTableView()
            _registerCollectionView()
            
            tableView?.reloadData()
            collectionView?.reloadData()
        }
    }
    
    public convenience init(tableView: UITableView? = nil,
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
    
    open func reloadData(){
        tableView?.reloadData()
        collectionView?.reloadData()
    }
}

extension BWListAdapter{
    fileprivate func _registerTableView() {
        guard let tableView = tableView,
              let registers = data?.registers else {
            return
        }
        registers.forEach { item in
            let reuseId = item.reuseId ?? ""
            switch item.style {
                case .cell:
                    if let xib = item.xib {
                        tableView.register(.init(nibName: xib, bundle: nil), forCellReuseIdentifier: reuseId)
                    }
                    if let `class` = item.class {
                        tableView.register(`class`, forCellReuseIdentifier: reuseId)
                    }
                case .header, .footer:
                    if let xib = item.xib {
                        tableView.register(.init(nibName: xib, bundle: nil), forHeaderFooterViewReuseIdentifier: reuseId)
                    }
                    if let `class` = item.class {
                        tableView.register(`class`, forHeaderFooterViewReuseIdentifier: reuseId)
                    }
                default: break
            }
        }
    }
    
    fileprivate func _registerCollectionView(){
        guard let collectionView = collectionView,
              let registers = data?.registers  else {
            return
        }
        registers.forEach { item in
            let reuseId = item.reuseId ?? (item.class != nil ? "\(item.class!.self)" : "")
            if reuseId.isEmpty {
                fatalError("reuseId不能为空!!!")
            }
            
            let registerHeaderFooter: (String)->Void = {kind in
                if let xib = item.xib {
                    collectionView.register(.init(nibName: xib, bundle: nil), forSupplementaryViewOfKind: kind, withReuseIdentifier: reuseId)
                }
                if let `class` = item.class {
                    collectionView.register(`class`, forSupplementaryViewOfKind: kind, withReuseIdentifier: reuseId)
                }
            }
            
            switch item.style {
                case .cell:
                    if let xib = item.xib {
                        collectionView.register(.init(nibName: xib, bundle: nil), forCellWithReuseIdentifier: reuseId)
                    }
                    if let `class` = item.class {
                        collectionView.register(`class`, forCellWithReuseIdentifier: reuseId)
                    }
                case .header:
                    registerHeaderFooter(UICollectionView.elementKindSectionHeader)
                case .footer:
                    registerHeaderFooter(UICollectionView.elementKindSectionFooter)
                default: break
            }
        }
    }
}

public protocol BWListItemView: UIView {
    static var RID: String! {get}
    func bwListItemViewConfigure(_ data: Any?, indexPath: IndexPath)
    var bwListCellIndexPath: IndexPath? {get}
    var bwListTableView: UITableView? {get}
    var bwListCollectionView: UICollectionView? {get}
    var bwListItemDidSelect: BWListItemAction.ItemDidSelectHandler? {get}
}

public protocol BWListItemSizeable {
    static func bwListItemCalculatedWidth(byHeight height: CGFloat, data: Any?) -> CGFloat
    static func bwListItemCalculatedHeight(byWidth width: CGFloat, data: Any?) -> CGFloat
    static func bwListItemCalculatedSize(withMaxSize size: CGSize, data: Any?) -> CGSize
}

extension BWListItemSizeable {
    public static func bwListItemCalculatedWidth(byHeight height: CGFloat, data: Any?) -> CGFloat{
        return 0
    }
    public static func bwListItemCalculatedHeight(byWidth width: CGFloat, data: Any?) -> CGFloat{
        return 0
    }
    public static func bwListItemCalculatedSize(withMaxSize: CGSize, data: Any?) -> CGSize {
        return .zero
    }
}

extension BWListItemView {
    public static var RID: String! {
        return "\(Self.self)"
    }
    
    private func findSuperView(_ kind: AnyClass) -> UIView? {
        var found = superview
        while found != nil && !(found!.isKind(of: kind)) {
            found = found?.superview
        }
        return found
    }
    
    //MARK: TODO
    public var bwListItemDidSelect: BWListItemAction.ItemDidSelectHandler? {
        return nil
    }
    
    public var bwListTableView: UITableView? {
        return findSuperView(UITableView.self) as? UITableView
    }
    
    public var bwListCollectionView: UICollectionView? {
        return findSuperView(UICollectionView.self) as? UICollectionView
    }
    
    public var bwListCellIndexPath: IndexPath? {
        if let view = self as? UITableViewCell {
            return bwListTableView?.indexPath(for: view)
        }
        else if let view = self as? UICollectionViewCell {
            return bwListCollectionView?.indexPath(for: view)
        }
        return nil
    }
}

public protocol BWListScrollDelegate: NSObjectProtocol {
    func bwListScrollViewDidScroll(_ scrollView: UIScrollView)
    func bwListScrollViewDidEndDecelerating(_ scrollView: UIScrollView)
}

extension BWListScrollDelegate {
    public func bwListScrollViewDidScroll(_ scrollView: UIScrollView){}
    public func bwListScrollViewDidEndDecelerating(_ scrollView: UIScrollView){}
}

//MARK: TODO
protocol BWListView {
    func reload(_ indexPath: IndexPath?, animated: Bool)
}
