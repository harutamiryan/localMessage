///
///  LocalMessageManager.swift
///  Created by Harutyun.Amiryan on 02.01.21.
///  Copyright © 2021. All rights reserved.
///

import UIKit

final class LocalMessageHandler: LocalMessageViewControllerDelegate {
    private var localMessageViewController: LocalMessageViewController?
    
    func showMessage(_ message: LocalMessage) {
        if localMessageViewController == nil {
            localMessageViewController = LocalMessageViewController(frame: UIScreen.main.bounds, delegate: self)
            UIApplication.shared.windows.first?.addSubview(localMessageViewController!.view)
        }
        localMessageViewController!.show(message: message)
    }
    
    // MARK: - LocalMessageViewControllerDelegate
    
    func removeMessagePanel() {
        localMessageViewController?.view.removeFromSuperview()
        localMessageViewController = nil
    }
}
