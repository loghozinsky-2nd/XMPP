//
//  SelfMessageTableViewCell.swift
//  XMPP
//
//  Created by Aleksander Loghozinsky on 07.12.2020.
//

import UIKit

class SelfMessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageLabel: UILabel!
    
    func configure(with model: Message) {
        messageLabel.text = model.text
    }
    
}
