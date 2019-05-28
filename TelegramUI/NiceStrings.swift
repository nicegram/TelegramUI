//
//  NiceStrings.swift
//  TelegramUI
//
//  Created by Sergey Ak on 5/28/19.
//  Copyright © 2019 Nicegram. All rights reserved.
//

import Foundation

let niceLocales: [String : [String : String]] = [
    "en" : NSDictionary(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "NiceLocalizable", ofType: "strings", inDirectory: nil, forLocalization: "en")!)) as! [String : String],
    "ru": NSDictionary(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "NiceLocalizable", ofType: "strings", inDirectory: nil, forLocalization: "ru")!)) as! [String : String]
]

public func l(key: String, locale: String = "en") -> String {
    var lang = locale
    
    if !niceLocales.keys.contains(locale) {
        lang = "en"
    }
    
    return niceLocales[lang]?[key] ?? niceLocales["en"]?[key] ?? key
}
