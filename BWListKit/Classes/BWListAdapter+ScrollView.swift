//
//  BWListAdapter+ScrollView.swift
//  AG
//
//  Created by zhuxuhong on 2020/10/13.
//  Copyright © 2020 AgoCulture. All rights reserved.
//

import UIKit

extension BWListAdapter: UIScrollViewDelegate{
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.bwListScrollViewDidScroll(scrollView)
    }
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollDelegate?.bwListScrollViewDidEndDecelerating(scrollView)
    }
}
