//
//  NiceFeaturesController.swift
//  TelegramUI
//
//  Created by Sergey Ak on 3/28/19.
//  Copyright © 2019 Nicegram. All rights reserved.
//

import Foundation
import Display
import SwiftSignalKit
import Postbox
import TelegramCore

private final class NiceFeaturesControllerArguments {
    let togglePinnedMessage: (Bool) -> Void
    let toggleShowContactsTab: (Bool) -> Void

    
    init(togglePinnedMessage:@escaping (Bool) -> Void, toggleShowContactsTab:@escaping (Bool) -> Void) {
        self.togglePinnedMessage = togglePinnedMessage
        self.toggleShowContactsTab = toggleShowContactsTab
    }
}


private enum niceFeaturesControllerSection: Int32 {
    case messageNotifications
    case chatsList
    case tabs
    case chatScreen
}

private enum NiceFeaturesControllerEntityId: Equatable, Hashable {
    case index(Int)
}

private enum NiceFeaturesControllerEntry: ItemListNodeEntry {
    case messageNotificationsHeader(PresentationTheme, String)
    case pinnedMessageNotification(PresentationTheme, String, Bool)
    
    case chatsListHeader(PresentationTheme, String)
    case workmode(PresentationTheme, String, Bool)
    case workmodeNotice(PresentationTheme, String)
    
    case tabsHeader(PresentationTheme, String)
    case showContactsTab(PresentationTheme, String, Bool)
    
    case chatScreenHeader(PresentationTheme, String)
    
    case animatedStickers(PresentationTheme, String, Bool)
    
    var section: ItemListSectionId {
        switch self {
        case .messageNotificationsHeader, .pinnedMessageNotification:
            return niceFeaturesControllerSection.messageNotifications.rawValue
        case .chatsListHeader, .workmode, .workmodeNotice:
            return niceFeaturesControllerSection.chatsList.rawValue
        case .tabsHeader, .showContactsTab:
            return niceFeaturesControllerSection.tabs.rawValue
        case .chatScreenHeader, .animatedStickers:
            return niceFeaturesControllerSection.chatScreen.rawValue
        }
        
    }
    
    var stableId: NiceFeaturesControllerEntityId {
        switch self {
        case .messageNotificationsHeader:
            return .index(0)
        case .pinnedMessageNotification:
            return .index(1)
        case .chatsListHeader:
            return .index(2)
        case .workmode:
            return .index(3)
        case .workmodeNotice:
            return .index(4)
        case .tabsHeader:
            return .index(5)
        case .showContactsTab:
            return .index(6)
        case .chatScreenHeader:
            return .index(7)
        case .animatedStickers:
            return .index(8)
        }
    }
    
    static func ==(lhs: NiceFeaturesControllerEntry, rhs: NiceFeaturesControllerEntry) -> Bool {
        switch lhs {
        case let .messageNotificationsHeader(lhsTheme, lhsText):
            if case let .messageNotificationsHeader(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                return true
            } else {
                return false
            }
            
        case let .pinnedMessageNotification(lhsTheme, lhsText, lhsValue):
            if case let .pinnedMessageNotification(rhsTheme, rhsText, rhsValue) = rhs, lhsTheme === rhsTheme, lhsText == rhsText, lhsValue == rhsValue {
                return true
            } else {
                return false
            }
            
        case let .chatsListHeader(lhsTheme, lhsText):
            if case let .chatsListHeader(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                return true
            } else {
                return false
            }
            
        case let .workmode(lhsTheme, lhsText, lhsValue):
            if case let .workmode(rhsTheme, rhsText, rhsValue) = rhs, lhsTheme === rhsTheme, lhsText == rhsText, lhsValue == rhsValue {
                return true
            } else {
                return false
            }
            
        case let .workmodeNotice(lhsTheme, lhsText):
            if case let .workmodeNotice(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                return true
            } else {
                return false
            }
            
        case let .tabsHeader(lhsTheme, lhsText):
            if case let .tabsHeader(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                return true
            } else {
                return false
            }
            
        case let .showContactsTab(lhsTheme, lhsText, lhsValue):
            if case let .showContactsTab(rhsTheme, rhsText, rhsValue) = rhs, lhsTheme === rhsTheme, lhsText == rhsText, lhsValue == rhsValue {
                return true
            } else {
                return false
            }
            
        case let .chatScreenHeader(lhsTheme, lhsText):
            if case let .chatScreenHeader(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                return true
            } else {
                return false
            }
            
        case let .animatedStickers(lhsTheme, lhsText, lhsValue):
            if case let .animatedStickers(rhsTheme, rhsText, rhsValue) = rhs, lhsTheme === rhsTheme, lhsText == rhsText, lhsValue == rhsValue {
                return true
            } else {
                return false
            }
        }
    }
    
    static func <(lhs: NiceFeaturesControllerEntry, rhs: NiceFeaturesControllerEntry) -> Bool {
        switch lhs {
        case .messageNotificationsHeader:
            switch rhs {
            case .messageNotificationsHeader:
                return false
            default:
                return true
            }
        case .pinnedMessageNotification:
            switch rhs {
            case .messageNotificationsHeader, .pinnedMessageNotification:
                return false
            default:
                return true
            }
        case .chatsListHeader:
            switch rhs {
            case .messageNotificationsHeader, .pinnedMessageNotification, .chatsListHeader:
                return false
            default:
                return true
            }
        case .workmode:
            switch rhs {
            case .messageNotificationsHeader, .pinnedMessageNotification, .chatsListHeader, .workmode:
                return false
            default:
                return true
            }
        case .workmodeNotice:
            switch rhs {
            case .messageNotificationsHeader, .pinnedMessageNotification, .chatsListHeader, .workmode, .workmodeNotice:
                return false
            default:
                return true
            }
        case .tabsHeader:
            switch rhs {
            case .messageNotificationsHeader, .pinnedMessageNotification, .chatsListHeader, .workmode, .workmodeNotice, .tabsHeader:
                return false
            default:
                return true
            }
        case .showContactsTab:
            switch rhs {
            case .messageNotificationsHeader, .pinnedMessageNotification, .chatsListHeader, .workmode, .workmodeNotice, .tabsHeader, .showContactsTab:
                return false
            default:
                return true
            }
        case .chatScreenHeader:
            switch rhs {
            case .messageNotificationsHeader, .pinnedMessageNotification, .chatsListHeader, .workmode, .workmodeNotice, .tabsHeader, .showContactsTab, .chatScreenHeader:
                return false
            default:
                return true
            }
        case animatedStickers:
            return false
        }
    }
    
    func item(_ arguments: NiceFeaturesControllerArguments) -> ListViewItem {
        switch self {
        case let .messageNotificationsHeader(theme, text):
            return ItemListSectionHeaderItem(theme: theme, text: text, sectionId: self.section)
        case let .pinnedMessageNotification(theme, text, value):
            return ItemListSwitchItem(theme: theme, title: text, value: value, enabled: true, sectionId: self.section, style: .blocks, updated: { value in
                arguments.togglePinnedMessage(value)
            })
        case let .chatsListHeader(theme, text):
            return ItemListSectionHeaderItem(theme: theme, text: text, sectionId: self.section)
        case let .workmode(theme, text, value):
            return ItemListSwitchItem(theme: theme, title: text, value: value, enabled: true, sectionId: self.section, style: .blocks, updated: { value in
                // arguments.toggleWorkmode(value)
            })
        case let .workmodeNotice(theme, text):
            return ItemListTextItem(theme: theme, text: .plain(text), sectionId: self.section)
        case let .tabsHeader(theme, text):
            return ItemListSectionHeaderItem(theme: theme, text: text, sectionId: self.section)
        case let .showContactsTab(theme, text, value):
            return ItemListSwitchItem(theme: theme, title: text, value: value, enabled: true, sectionId: self.section, style: .blocks, updated: { value in
                arguments.toggleShowContactsTab(value)
            })
        case let .chatScreenHeader(theme, text):
            return ItemListSectionHeaderItem(theme: theme, text: text, sectionId: self.section)
        case let .animatedStickers(theme, text, value):
            return ItemListSwitchItem(theme: theme, title: text, value: value, enabled: true, sectionId: self.section, style: .blocks, updated: { value in
                GlobalExperimentalSettings.animatedStickers = value
            })
        }
    }
    
}


/*
 public func niceFeaturesController(context: AccountContext) -> ViewController {
 let presentationData = context.sharedContext.currentPresentationData.with { $0 }
 return niceFeaturesController(accountManager: context.sharedContext.accountManager, postbox: context.account.postbox, theme: presentationData.theme, strings: presentationData.strings, updatedPresentationData: context.sharedContext.presentationData |> map { ($0.theme, $0.strings) })
 }
 */

private func niceFeaturesControllerEntries(niceSettings: NiceSettings, presentationData: PresentationData) -> [NiceFeaturesControllerEntry] {
    var entries: [NiceFeaturesControllerEntry] = []
    
    //entries.append(.messageNotificationsHeader(presentationData.theme, "MESSAGE NOTIFICATIONS"))  // presentationData.strings.Nicegram_Settings_Features_MessageNotifications))
    //entries.append(.pinnedMessageNotification(presentationData.theme, "Pinned Messages", niceSettings.pinnedMessagesNotification))  //presentationData.strings.Nicegram_Settings_Features_PinnedMessages
    // entries.append(.chatsListHeader(presentationData.theme, "CHATS LIST"))
    // entries.append(.workmode(presentationData.theme, "Workmode", niceSettings.workmode))
    // entries.append(.workmodeNotice(presentationData.theme, "Switch between \"All\" and \"Non Muted\" chats"))
    
    entries.append(.tabsHeader(presentationData.theme, l(key: "NiceFeatures.Tabs.Header", locale: presentationData.strings.baseLanguageCode)))
    entries.append(.showContactsTab(presentationData.theme, l(key: "NiceFeatures.Tabs.ShowContacts", locale: presentationData.strings.baseLanguageCode), niceSettings.showContactsTab))
    entries.append(.chatScreenHeader(presentationData.theme, l(key: "NiceFeatures.ChatScreen.Header", locale: presentationData.strings.baseLanguageCode)))
    entries.append(.animatedStickers(presentationData.theme, l(key:  "NiceFeatures.ChatScreen.AnimatedStickers", locale: presentationData.strings.baseLanguageCode), GlobalExperimentalSettings.animatedStickers))
    // entries.append(.transparentEmojisBubble(presentationData.theme, "Transparent Emojis Bubble", niceSettings.transparentEmojisBubble))
    // entries.append(.transparentEmojisBubbleNotice(presentationData.theme, "Looks like emojis in iMessage. Removes bubble for emoji-only messages."))
    
    return entries
}


private struct NiceFeaturesSelectionState: Equatable {
    
}

public func niceFeaturesController(context: AccountContext) -> ViewController {
    let statePromise = ValuePromise(NiceFeaturesSelectionState(), ignoreRepeated: true)
    var dismissImpl: (() -> Void)?
    
    let arguments = NiceFeaturesControllerArguments(togglePinnedMessage: { value in
        let _ = updateNiceSettingsInteractively(accountManager: context.sharedContext.accountManager, { settings in
            var settings = settings
            settings.pinnedMessagesNotification = value
            return settings
        }).start()
    }, toggleShowContactsTab: { value in
        let _ = updateNiceSettingsInteractively(accountManager: context.sharedContext.accountManager, { settings in
            var settings = settings
            settings.showContactsTab = value
            return settings
        }).start()
    }
    )
    
    
    let signal = combineLatest(context.sharedContext.presentationData, context.sharedContext.accountManager.sharedData(keys: [ApplicationSpecificSharedDataKeys.niceSettings]), statePromise.get())
        |> map { presentationData, sharedData, state -> (ItemListControllerState, (ItemListNodeState<NiceFeaturesControllerEntry>, NiceFeaturesControllerEntry.ItemGenerationArguments)) in
            
            let niceSettings: NiceSettings
            
            if let value = sharedData.entries[ApplicationSpecificSharedDataKeys.niceSettings] as? NiceSettings {
                niceSettings = value
            } else {
                niceSettings = NiceSettings.defaultSettings
            }
            
            let entries = niceFeaturesControllerEntries(niceSettings: niceSettings, presentationData: presentationData)
            
            var index = 0
            var scrollToItem: ListViewScrollToItem?
            // workaround
            let focusOnItemTag: NotificationsAndSoundsEntryTag? = nil
            if let focusOnItemTag = focusOnItemTag {
                for entry in entries {
                    if entry.tag?.isEqual(to: focusOnItemTag) ?? false {
                        scrollToItem = ListViewScrollToItem(index: index, position: .top(0.0), animated: false, curve: .Default(duration: 0.0), directionHint: .Up)
                    }
                    index += 1
                }
            }
            
            let controllerState = ItemListControllerState(theme: presentationData.theme, title: .text(l(key: "NiceFeatures.Title", locale: presentationData.strings.baseLanguageCode)), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
            let listState = ItemListNodeState(entries: entries, style: .blocks, ensureVisibleItemTag: focusOnItemTag, initialScrollToItem: scrollToItem)
            
            return (controllerState, (listState, arguments))
    }
    
    let controller = ItemListController(context: context, state: signal)
    dismissImpl = { [weak controller] in
        controller?.dismiss()
    }
    return controller
}

/*
 var onlyNonMuted = false
 self.
 _ = (self.context.sharedContext.accountManager.sharedData(keys: [ApplicationSpecificSharedDataKeys.niceSettings])
 |> deliverOnMainQueue).start(next: { sharedData in
 if let settings = sharedData.entries[ApplicationSpecificSharedDataKeys.niceSettings] as? NiceSettings {
 onlyNonMuted = settings.workmode
 } else {
 onlyNonMuted = NiceSettings.defaultSettings.workmode
 }
 })
 */
