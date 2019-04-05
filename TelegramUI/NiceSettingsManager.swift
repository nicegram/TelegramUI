//
//  NiceSettingsManager.swift
//  TelegramUI
//
//  Created by Sergey Ak on 4/5/19.
//  Copyright © 2019 Nicegram. All rights reserved.
//

import Foundation
import Postbox
import SwiftSignalKit
import TelegramCore

class NiceSettingsManager {
    func getSettings() -> NiceSettings {
        let appGroupName = "group.\(Bundle.main.bundleIdentifier!)"
        let appGroupUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupName)
        
        let rootPath = rootPathForBasePath(appGroupUrl!.path)
        
        let accountManager = AccountManager(basePath: rootPath + "/accounts-metadata")
        
        var niceSettings = NiceSettings.defaultSettings
        let getSettingsSemaphore = DispatchSemaphore(value: 0)
        _ = (accountManager.sharedData(keys: [ApplicationSpecificSharedDataKeys.niceSettings])).start(next: { sharedData in
            if let settings = sharedData.entries[ApplicationSpecificSharedDataKeys.niceSettings] as? NiceSettings {
                niceSettings = settings
            }
            getSettingsSemaphore.signal()
        })
        getSettingsSemaphore.wait()
        
        return niceSettings
    }
}
