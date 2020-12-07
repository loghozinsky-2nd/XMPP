//
//  Message.swift
//  XMPP
//
//  Created by Aleksander Loghozinsky on 07.12.2020.
//

import Foundation

typealias UserType = (id: Int, name: String, password: String)

struct Message {
    enum SenderType {
        case you
        case companion
    }
    
    var sender: SenderType
    let text: String
    
    mutating func switchSender() -> Message {
        sender = sender == .you ? SenderType.companion : SenderType.you
        return self
    }
}
