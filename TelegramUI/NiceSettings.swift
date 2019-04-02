//
//  NiceSettings.swift
//  TelegramUI
//
//  Created by Sergey Ak on 3/28/19.
//  Copyright © 2019 Nicegram. All rights reserved.
//

import Foundation
import Postbox
import SwiftSignalKit

public struct NiceSettings: PreferencesEntry, Equatable {
    public var pinnedMessagesNotification: Bool
    public var workmode: Bool
    public var showContactsTab: Bool
    
    public static var defaultSettings: NiceSettings {
        return NiceSettings(pinnedMessagesNotification: true, workmode: false, showContactsTab: true)
    }
    
    init(pinnedMessagesNotification: Bool, workmode: Bool, showContactsTab: Bool) {
        self.pinnedMessagesNotification = pinnedMessagesNotification
        self.workmode = workmode
        self.showContactsTab = showContactsTab
    }
    
    public init(decoder: PostboxDecoder) {
        self.pinnedMessagesNotification = decoder.decodeBoolForKey("nice:pinndeMessagesNotification", orElse: true)
        self.workmode = decoder.decodeBoolForKey("nice:workmode", orElse: false)
        self.showContactsTab = decoder.decodeBoolForKey("nice:showContactsTab", orElse: true)
    }
    
    public func encode(_ encoder: PostboxEncoder) {
        encoder.encodeBool(self.pinnedMessagesNotification, forKey: "nice:pinndeMessagesNotification")
        encoder.encodeBool(self.workmode, forKey: "nice:workmode")
        encoder.encodeBool(self.showContactsTab, forKey: "nice:showContactsTab")
    }
    
    public func isEqual(to: PreferencesEntry) -> Bool {
        if let to = to as? NiceSettings {
            return self == to
        } else {
            return false
        }
    }
    
    public static func ==(lhs: NiceSettings, rhs: NiceSettings) -> Bool {
        return lhs.pinnedMessagesNotification == rhs.pinnedMessagesNotification && lhs.workmode == rhs.workmode && lhs.showContactsTab == rhs.showContactsTab
    }
    
    public func withUpdatedpinnedMessagesNotification(_ pinnedMessagesNotification: Bool) -> NiceSettings {
        return NiceSettings(pinnedMessagesNotification: pinnedMessagesNotification, workmode: self.workmode, showContactsTab: self.showContactsTab)
    }
    
    public func withUpdatedworkmode(_ workmode: Bool) -> NiceSettings {
        return NiceSettings(pinnedMessagesNotification: self.pinnedMessagesNotification, workmode: workmode, showContactsTab: self.showContactsTab)
    }
    
    public func withUpdatedshowContactsTab(_ showContactsTab: Bool) -> NiceSettings {
        return NiceSettings(pinnedMessagesNotification: self.pinnedMessagesNotification, workmode: self.workmode, showContactsTab: showContactsTab)
    }
}

public func updateNiceSettingsInteractively(accountManager: AccountManager, _ f: @escaping (NiceSettings) -> NiceSettings) -> Signal<Void, NoError> {
    return accountManager.transaction { transaction -> Void in
        transaction.updateSharedData(ApplicationSpecificSharedDataKeys.niceSettings, { entry in
            let currentSettings: NiceSettings
            if let entry = entry as? NiceSettings {
                currentSettings = entry
            } else {
                currentSettings = NiceSettings.defaultSettings
            }
            return f(currentSettings)
        })
    }
}
