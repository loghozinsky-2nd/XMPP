//
//  SwitchUserViewController.swift
//  XMPP
//
//  Created by Aleksander Loghozinsky on 07.12.2020.
//

import UIKit

protocol SwitchUserDelegate: class {
    func switchUser(to userId: Int)
}

class SwitchUserViewController: UIViewController {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    weak var delegate: SwitchUserDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func configure(_ switchUserDelegate: SwitchUserDelegate, userId: Int) {
        delegate = switchUserDelegate
        segmentControl.selectedSegmentIndex = userId - 1
    }
    
    @IBAction func valueChanged(_ sender: UISegmentedControl) {
        let userId = sender.selectedSegmentIndex + 1
        delegate?.switchUser(to: userId)
    }
    
}
