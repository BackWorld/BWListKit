//
//  BWListAdapter+CollectionView.swift
//  BWListViewKit
//
//  Created by zhuxuhong on 2020/9/29.
//  Copyright © 2020 zxh. All rights reserved.
//

import UIKit

extension BWListAdapter: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return data?.sections?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sections = data?.sections else {
            return 0
        }
        
        return sections[section].items?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sections = data!.sections!
        let section = sections[indexPath.section]
        let config = (kind == UICollectionView.elementKindSectionHeader) ? section.header : section.footer
        
        var view = UICollectionReusableView()
        
        guard let headerFooter = config else {
            return view
        }
        
        if let reuseId = headerFooter.reuseId {
            view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseId, for: indexPath)
        }
        
        if let proxy = view as? BWListItemView {
            proxy.bwListItemViewConfigure(headerFooter.data, indexPath: indexPath)
        }
        
        return view
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sections = data!.sections!
        let item = sections[indexPath.section].items![indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.reuseId, for: indexPath)
        cell.layer.zPosition = CGFloat(indexPath.item)
        if let proxy = cell as? BWListItemView {
            proxy.bwListItemViewConfigure(item.data, indexPath: indexPath)
        }
        item.cellConfigure?(cell, item.data, indexPath)
        return cell
    }
}

extension BWListAdapter: UICollectionViewDelegateFlowLayout{
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        let sections = data!.sections!
        guard let layout = sections[section].layout else {
            return 0
        }
        return layout.minimumLineSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let sections = data!.sections!
        guard let layout = sections[section].layout else {
            return 0
        }
        return layout.minimumInteritemSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let sections = data!.sections!
        
        guard let section = sections[section].header else {
            return .zero
        }
        return CGSize(width: section.width, height: section.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let sections = data!.sections!
        
        guard let section = sections[section].footer else {
            return .zero
        }
        return CGSize(width: section.width, height: section.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let sections = data!.sections!
        let item = sections[indexPath.section].items![indexPath.item]
        var w = item.width
        let h = item.height
        
        if h == 0 {
            fatalError("height不能为0!!!")
        }
        /// 宽度为0，设置为父视图宽度
        if w == 0 {
            let insets = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)
            w = UIScreen.main.bounds.width - insets.left - insets.right
        }
        return CGSize(width: w!, height: h!)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let sections = data!.sections!
        guard let layout = sections[section].layout else {
            return .zero
        }
        return layout.insets
    }
}


extension BWListAdapter: UICollectionViewDelegate{
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sections = data!.sections!
        let item = sections[indexPath.section].items![indexPath.item]
        guard let action = item.action else {
            return
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.reuseId, for: indexPath)
        
        var data = BWListItemAction.Data()
        data.indexPath = indexPath
        data.data = item.data
        data.collectionView = collectionView
        data.collectionViewCell = cell
        
        action.didSelectItem?(data)
    }
}
