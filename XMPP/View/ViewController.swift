//
//  ViewController.swift
//  XMPP
//
//  Created by Aleksander Loghozinsky on 06.12.2020.
//

import UIKit
import XMPPFramework

class ViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    private var stream: XMPPStream!
    private var rosterStorage: XMPPRosterCoreDataStorage!
    private var roster: XMPPRoster!
    
    private var userId: Int! {
        didSet {
            textView.text = nil
            userIdLabel.text = String(userId)
            user = (id: userId, name: "test\(userId ?? 1)", password: "test\(userId ?? 1)")
        }
    }
    private var recipientUserId: Int { userId == 1 ? 2 : 1 }
    private var user: UserType! {
        didSet {
            stream.myJID = XMPPJID.configure(with: user.name, hostName: API.Address.stage.rawValue)
        }
    }
    
    private var data = [Message]() {
        didSet {
            tableView.reloadData()
            if data.last?.sender == .you {
                let indexPath = IndexPath(item: data.count - 1, section: 0)
                tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureStream(with: 1)
        setupView()
    }
    
    private func configureStream(with userId: Int) {
        rosterStorage = XMPPRosterCoreDataStorage()
        roster = XMPPRoster(rosterStorage: rosterStorage)
        stream = XMPPStream()
        
        stream.addDelegate(self, delegateQueue: .main)
        
        authenticateStream(with: userId)
    }
    
    private func authenticateStream(with userId: Int) {
        self.userId = userId
        self.roster.activate(stream)
        
        do {
            try stream.connect(withTimeout: 120)
        } catch {
            // should handle an error
        }
    }
    
    private func setupView() {
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
    }
    
    private func sendMessage(with text: String) {
        if text.count > 0 {
            let recipientUserName = "test\(userId ?? 1)"
            let jid = XMPPJID.configure(with: recipientUserName, hostName: API.Address.stage.rawValue)
            let message = XMPPMessage(type: "chat", to: jid)
            
            message.addBody(text)
            stream.send(message)
            
            let model = Message(sender: .you, text: text)
            data.append(model)
        }
    }
    
    private func swapMessages() {
        var result = [Message]()
        
        for message in data {
            var message = message
            result.append(message.switchSender())
        }
        
        data = result
    }
    
}

// MARK: Handlers
extension ViewController {
    @IBAction func onSendButtonTouchUpInside(_ sender: UIButton) {
        sendMessage(with: textView.text)
    }
    
    @IBAction func onUserButtonTap(_ sender: UIButton) {
        if let storyboard = storyboard {
            let vc = storyboard.instantiateViewController(withIdentifier: "SwitchUserViewController") as! SwitchUserViewController
            present(vc, animated: true, completion: {
                vc.configure(self, userId: self.userId)
            })
        }
    }
}

// MARK: XMPPStreamDelegate
extension ViewController: XMPPStreamDelegate {
    func xmppStreamWillConnect(_ sender: XMPPStream) {
        statusLabel.text = "Connecting ..."
        statusLabel.textColor = .systemBlue
        
        sendButton.isEnabled = false
    }
    
    func xmppStreamDidConnect(_ sender: XMPPStream) {
        do {
            try sender.authenticate(withPassword: (user.password))
        } catch {
            print("failed xmppStreamDidConnect")
        }
    }
    
    func xmppStream(_ sender: XMPPStream, willSend message: XMPPMessage) -> XMPPMessage? {
        textView.text = nil
        
        return message
    }
    
    func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
        statusLabel.text = "Online"
        statusLabel.textColor = .systemGreen
        
        sendButton.isEnabled = true
        
        sender.send(XMPPPresence())
    }
    
    func xmppStreamDidDisconnect(_ sender: XMPPStream, withError error: Error?) {
        statusLabel.text = "Disconnected"
        statusLabel.textColor = .systemRed
        
        sendButton.isEnabled = false
    }
    
    func xmppStream(_ sender: XMPPStream, didReceive message: XMPPMessage) {
        if let from = message.fromStr, let text = message.body, !(message.fromStr?.contains(user.name) ?? false) {
            let model = Message(sender: from.contains(user.name) ? .you : .companion, text: text)
            data.append(model)
        }
    }
    
}

// MARK: UITableViewDelegate & UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = data[indexPath.row]
        if model.sender == .you, let cell = tableView.dequeueReusableCell(withIdentifier: "SelfMessageTableViewCell", for: indexPath) as? SelfMessageTableViewCell {
            cell.configure(with: model)
            return cell
        } else if model.sender == .companion, let cell = tableView.dequeueReusableCell(withIdentifier: "CompanionMessageTableViewCell", for: indexPath) as? CompanionMessageTableViewCell {
            cell.configure(with: model)
            return cell
        } else {
            fatalError("Incorrect cell type")
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        textView.resignFirstResponder()
    }
}

// MARK: Custom Delegates
extension ViewController: SwitchUserDelegate {
    func switchUser(to userId: Int) {
        authenticateStream(with: userId)
        swapMessages()
    }
}

