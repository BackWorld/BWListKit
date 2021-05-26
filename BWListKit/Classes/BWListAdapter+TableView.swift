//
//  data+tableView.swift
//  BWListViewKit
//
//  Created by zhuxuhong on 2020/9/29.
//  Copyright © 2020 zxh. All rights reserved.
//

import UIKit

extension BWListAdapter: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return data?.sections?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = data?.sections else {
            return 0
        }
        
        return sections[section].items?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sections = data!.sections!
        
        var headerView: UIView? = nil
        
        guard let header = sections[section].header else {
            return headerView
        }
        if let view = header.view {
            headerView = view
        }
        else if let reuseId = header.reuseId {
            headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseId)
        }
        
        if let proxy = headerView as? BWListItemView {
            proxy.bwListItemViewConfigure(header.data, indexPath: IndexPath(row: -1, section: section))
        }
        return headerView
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let sections = data!.sections!
        
        var footerView: UIView? = nil
        
        guard let footer = sections[section].footer else {
            return footerView
        }
        if let view = footer.view {
            footerView = view
        }
        else if let reuseId = footer.reuseId {
            footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseId)
        }
        
        if let proxy = footerView as? BWListItemView {
            proxy.bwListItemViewConfigure(footer.data, indexPath: IndexPath(row: -1, section: section))
        }
        return footerView
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sections = data!.sections!
        let item = sections[indexPath.section].items![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseId) ?? tableView.dequeueReusableCell(withIdentifier: item.reuseId, for: indexPath)
        cell.layer.zPosition = CGFloat(indexPath.row)
        if let proxy = cell as? BWListItemView {
            proxy.bwListItemViewConfigure(item.data, indexPath: indexPath)
        }
        item.cellConfigure?(cell, item.data, indexPath)
        return cell
    }
}


extension BWListAdapter: UITableViewDelegate{
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let sections = data!.sections!
        let item = sections[indexPath.section].items![indexPath.item]
        guard let action = item.action else {
            return
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseId) ?? tableView.dequeueReusableCell(withIdentifier: item.reuseId, for: indexPath)
        
        var data = BWListItemAction.Data()
        data.indexPath = indexPath
        data.data = item.data
        data.tableView = tableView
        data.tableViewCell = cell
        
        action.didSelectItem?(data)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sections = data!.sections!
        let item = sections[indexPath.section].items![indexPath.row]
        
        return item.height
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sections = data!.sections!
        
        guard let section = sections[section].header else {
            return 0.00001
        }
        return section.height
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let sections = data!.sections!
        
        guard let section = sections[section].footer else {
            return 0.00001
        }
        return section.height
    }
}
