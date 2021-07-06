///
///  SampleViewController.swift
///  Created by Harutyun.Amiryan on 02.01.21.
///  Copyright © 2021. All rights reserved.
///

import UIKit

struct LocalMessage {
    var info: String
    var emoji: String
}

final class SampleViewController: UIViewController {
    private var localMessageHandler = LocalMessageHandler()
    private var fruits = ["🍏", "🍐", "🍊", "🍋", "🍒", "🍓", "🍑", "🥑", "🍉", "🥭", "🍍"]
    private var messages = [LocalMessage]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let message1 = LocalMessage(info: "iOS can dynamically generate shadows for any UIView, and these shadows automatically adjust to fit the shape of the item in question", emoji: "🍍")
        let message2 = LocalMessage(info: "iOS can dynamically generate shadows for any UIView, and these shadows automatically adjust to fit the shape of the item in question", emoji: "🍏")
        let message3 = LocalMessage(info: "iOS can dynamically generate shadows for any UIView, and these shadows automatically adjust to fit the shape of the item in question. iOS can dynamically generate shadows for any UIView, and these shadows automatically adjust to fit the shape of the item in question", emoji: "🍊")
        let message4 = LocalMessage(info: "iOS can dynamically generate shadows for any UIView, and these shadows automatically adjust to fit the shape of the item in question", emoji: "🍐")
        let message5 = LocalMessage(info: "iOS can dynamically generate shadows for any UIView, and these shadows automatically adjust to fit the shape of the item in question. iOS can dynamically generate shadows for any UIView, and these shadows automatically adjust to fit the shape of the item in question. iOS can dynamically generate shadows for any UIView, and these shadows automatically adjust to fit the shape of the item in question", emoji: "🍋")
        let message6 = LocalMessage(info: "iOS can dynamically generate shadows for any UIView, and these shadows automatically adjust to fit the shape of the item in question", emoji: "🍒")
        let message7 = LocalMessage(info: "iOS can dynamically generate shadows for any UIView, and these shadows automatically adjust to fit the shape of the item in question", emoji: "🍑")
        let message8 = LocalMessage(info: "iOS can dynamically generate shadows for any UIView, and these shadows automatically adjust to fit the shape of the item in question", emoji: "🥑")
        let message9 = LocalMessage(info: "iOS can dynamically generate shadows for any UIView, and these shadows automatically adjust to fit the shape of the item in question", emoji: "🥭")
        let message10 = LocalMessage(info: "iOS can dynamically generate shadows for any UIView, and these shadows automatically adjust to fit the shape of the item in question", emoji: "🍓")
        messages = [message1, message2, message3, message4, message5, message6, message7, message8, message9, message10]
        
        var a = 0
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if a < 10 {
                self.localMessageHandler.showMessage(self.messages[a])
                a += 1
            }
        }
    }
}
