//
//  DemoCollectionViewVC.swift
//  BWListKit_Example
//
//  Created by zhuxuhong on 2021/3/9.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

import UIKit
import BWListKit

class DemoCollectionViewVC: UIViewController, BWListScrollDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var listAdapter = BWListAdapter(collectionView: collectionView, scrollDelegate: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellRID = DemoCollectionViewCell.RID
        let headerRID = DemoCollectionViewHeader.RID
        
        listAdapter.data = BWListData(registers: [
            .init(style: .cell, class: DemoCollectionViewCell.self),
            .init(style: .header, xib: headerRID),
        ], sections: [
            .init(layout: .init(insets: .init(top: 20, left: 10, bottom: 20, right: 10), minimumInteritemSpacing: 20, minimumLineSpacing: 10),
                  items: (0..<20).map{
                    .init(reuseId: cellRID, width: 50, height: 50+CGFloat($0*10), data: UIColor.red, action: .init(didSelectItem: {
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

class DemoCollectionViewHeader: UICollectionReusableView, BWListItemView {
    func bwListItemViewConfigure(_ data: Any?, indexPath: IndexPath) {
        backgroundColor = data as? UIColor
    }
}

class DemoCollectionViewCell: UICollectionViewCell, BWListItemView, BWListItemSizeable {
    func bwListItemViewConfigure(_ data: Any?, indexPath: IndexPath) {
        contentView.backgroundColor = data as? UIColor
    }
}
