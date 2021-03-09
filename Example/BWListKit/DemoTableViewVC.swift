//
//  ViewController.swift
//  BWListKit
//
//  Created by 朱旭宏 on 03/09/2021.
//  Copyright (c) 2021 朱旭宏. All rights reserved.
//

import UIKit
import BWListKit

class DemoTableViewVC: UIViewController, BWListScrollDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    lazy var listAdapter = BWListAdapter(tableView: tableView, scrollDelegate: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellRID = DemoTableViewCell.RID
        let headerRID = DemoTableViewHeader.RID
        
        listAdapter.data = BWListData(registers: [
            .init(style: .cell, class: DemoTableViewCell.self),
            .init(style: .header, class: DemoTableViewHeader.self),
        ], sections: [
            .init(header: .init(reuseId: headerRID, height: 20, data: UIColor.green),
                  items: (0..<20).map{
                    .init(reuseId: cellRID, height: 50+CGFloat($0), data: UIColor.red, action: .init(didSelectItem: {
                        data in
                        print("tapped cell: \(data)")
                    }))
                })
        ])
    }

    func bwListScrollViewDidScroll(_ scrollView: UIScrollView) {
        print("did scroll: \(scrollView)")
    }
}

class DemoTableViewHeader: UITableViewHeaderFooterView, BWListItemView {
    func bwListItemViewConfigure(_ data: Any?, indexPath: IndexPath) {
        contentView.backgroundColor = data as? UIColor
    }
}

class DemoTableViewCell: UITableViewCell, BWListItemView {
    func bwListItemViewConfigure(_ data: Any?, indexPath: IndexPath) {
        contentView.backgroundColor = data as? UIColor
    }
}

