//
//  LanguageManager.swift
//  PikaMood
//
//  Created by Musawwir Ahmad on 2025-11-19.
//

import Foundation

class LanguageManager {
    static func setLanguage(_ language: String) {
        UserDefaults.standard.set([language], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
}

extension LanguageManager {
    static var currentLocale: String {
        let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "ja"
        return lang == "en" ? "en_US" : "ja_JP"
    }
}
