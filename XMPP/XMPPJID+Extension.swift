//
//  XMPPJID+Extension.swift
//  XMPP
//
//  Created by Aleksander Loghozinsky on 07.12.2020.
//

import XMPPFramework

extension XMPPJID {
    class func configure(with userName: String, hostName: String) -> XMPPJID? {
        XMPPJID(string: "\(userName)@\(hostName)")
    }
}
