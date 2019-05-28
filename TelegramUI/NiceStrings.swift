//
//  NiceStrings.swift
//  TelegramUI
//
//  Created by Sergey Ak on 5/28/19.
//  Copyright © 2019 Nicegram. All rights reserved.
//

import Foundation

private func gd(locale: String) -> [String : String] {
    return NSDictionary(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "NiceLocalizable", ofType: "strings", inDirectory: nil, forLocalization: locale)!)) as! [String : String]
}

let niceLocales: [String : [String : String]] = [
    "en" : gd(locale: "en"),
    "ru": gd(locale: "ru"),
    "ar": gd(locale: "ar"),
    "de": gd(locale: "de"),
    "it": gd(locale: "it"),
    "es": gd(locale: "es"),
    
    // Chinese
    // Simplified
    "zh-hans": gd(locale: "zh-hans"),
    // Traditional
    "zh-hant": gd(locale: "zh-hant")
]

public func l(key: String, locale: String = "en") -> String {
    var lang = locale
    
    let rawSuffix = "-raw"
    if lang.hasSuffix(rawSuffix) {
        lang = String(lang.dropLast(rawSuffix.count))
    }
    
    if !niceLocales.keys.contains(lang) {
        lang = "en"
    }
    return niceLocales[lang]?[key] ?? niceLocales["en"]?[key] ?? key
}
