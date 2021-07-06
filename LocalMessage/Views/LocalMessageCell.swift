///
///  LocalMessageCell.swift
///  Created by Harutyun.Amiryan on 02.01.21.
///  Copyright © 2021. All rights reserved.
///

import UIKit

protocol LocalMessageCellDelegate: AnyObject {
    func removeMessage(_ cell: UICollectionViewCell)
}

final class LocalMessageCell: UICollectionViewCell {
    @IBOutlet weak var rearView: UIView!
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    weak var delegate: LocalMessageCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        rearView.layer.cornerRadius = 5
        rearView.backgroundColor = UIColor.white
        rearView.layer.shadowColor = UIColor(red: 21/255, green: 21/255, blue: 26/255, alpha: 0.41).cgColor
        rearView.layer.shadowOpacity = 0.6
        rearView.layer.shadowOffset = .zero
        rearView.layer.shadowRadius = 3
    }
    
    @IBAction func removeAction() {
        delegate?.removeMessage(self)
    }
    
    func setInfo(message: LocalMessage) {
        emojiLabel.text = message.emoji
        infoLabel.text = message.info
    }
}
