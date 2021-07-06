///
///  Header.swift
///  Created by Harutyun.Amiryan on 02.01.21.
///  Copyright © 2021. All rights reserved.
///

import UIKit

protocol HeaderDelegate: AnyObject {
    func groupAction()
}

final class Header: UICollectionReusableView {
    weak var delegate: HeaderDelegate?
    
    @IBAction func groupButtonAction() {
        delegate?.groupAction()
    }
}
