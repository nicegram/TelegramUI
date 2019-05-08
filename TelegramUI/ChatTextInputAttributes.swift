import Foundation
import Display
import AsyncDisplayKit
import Postbox

private let alphanumericCharacters = CharacterSet.alphanumerics

struct ChatTextInputAttributes {
    static let bold = NSAttributedStringKey(rawValue: "Attribute__Bold")
    static let italic = NSAttributedStringKey(rawValue: "Attribute__Italic")
    static let monospace = NSAttributedStringKey(rawValue: "Attribute__Monospace")
    static let textMention = NSAttributedStringKey(rawValue: "Attribute__TextMention")
    static let url = NSAttributedStringKey(rawValue: "Attribute__Url")
}

func stateAttributedStringForText(_ text: NSAttributedString) -> NSAttributedString {
    let result = NSMutableAttributedString(string: text.string)
    let fullRange = NSRange(location: 0, length: result.length)
    
    text.enumerateAttributes(in: fullRange, options: [], using: { attributes, range, _ in
        for (key, value) in attributes {
            if key == ChatTextInputAttributes.textMention {
                result.addAttribute(key, value: value, range: range)
            } else if key == ChatTextInputAttributes.bold || key == ChatTextInputAttributes.italic || key == ChatTextInputAttributes.monospace {
                result.addAttribute(key, value: value, range: range)
            } else if key == ChatTextInputAttributes.url {
                result.addAttribute(key, value: value, range: range)
            }
        }
    })
    return result
}

private struct FontAttributes: OptionSet {
    var rawValue: Int32 = 0
    
    static let bold = FontAttributes(rawValue: 1 << 0)
    static let italic = FontAttributes(rawValue: 1 << 1)
    static let monospace = FontAttributes(rawValue: 1 << 2)
}

func textAttributedStringForStateText(_ stateText: NSAttributedString, fontSize: CGFloat, textColor: UIColor, accentTextColor: UIColor) -> NSAttributedString {
    let result = NSMutableAttributedString(string: stateText.string)
    let fullRange = NSRange(location: 0, length: result.length)
    
    result.addAttribute(NSAttributedStringKey.font, value: Font.regular(fontSize), range: fullRange)
    result.addAttribute(NSAttributedStringKey.foregroundColor, value: textColor, range: fullRange)
    
    stateText.enumerateAttributes(in: fullRange, options: [], using: { attributes, range, _ in
        var fontAttributes: FontAttributes = []
        
        for (key, value) in attributes {
            if key == ChatTextInputAttributes.textMention {
                result.addAttribute(key, value: value, range: range)
                result.addAttribute(NSAttributedStringKey.foregroundColor, value: accentTextColor, range: range)
            } else if key == ChatTextInputAttributes.bold {
                result.addAttribute(key, value: value, range: range)
                fontAttributes.insert(.bold)
            } else if key == ChatTextInputAttributes.italic {
                result.addAttribute(key, value: value, range: range)
                fontAttributes.insert(.italic)
            } else if key == ChatTextInputAttributes.monospace {
                result.addAttribute(key, value: value, range: range)
                fontAttributes.insert(.monospace)
            } else if key == ChatTextInputAttributes.url {
                result.addAttribute(key, value: value, range: range)
                result.addAttribute(NSAttributedStringKey.foregroundColor, value: accentTextColor, range: range)
            }
        }
        
        if !fontAttributes.isEmpty {
            var font: UIFont?
            if fontAttributes == [.bold, .italic, .monospace] {
                
            } else if fontAttributes == [.bold, .italic] {
                font = Font.semiboldItalic(fontSize)
            } else if fontAttributes == [.bold] {
                font = Font.semibold(fontSize)
            } else if fontAttributes == [.italic] {
                font = Font.italic(fontSize)
            } else if fontAttributes == [.monospace] {
                font = Font.monospace(fontSize)
            }
            
            if let font = font {
                result.addAttribute(NSAttributedStringKey.font, value: font, range: range)
            }
        }
    })
    return result
}

private func textMentionRangesEqual(_ lhs: [(NSRange, ChatTextInputTextMentionAttribute)], _ rhs: [(NSRange, ChatTextInputTextMentionAttribute)]) -> Bool {
    if lhs.count != rhs.count {
        return false
    }
    for i in 0 ..< lhs.count {
        if lhs[i].0 != rhs[i].0 || lhs[i].1.peerId != rhs[i].1.peerId {
            return false
        }
    }
    return true
}

final class ChatTextInputTextMentionAttribute: NSObject {
    let peerId: PeerId
    
    init(peerId: PeerId) {
        self.peerId = peerId
        
        super.init()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let other = object as? ChatTextInputTextMentionAttribute {
            return self.peerId == other.peerId
        } else {
            return false
        }
    }
}


private func urlRangesEqual(_ lhs: [(NSRange, ChatTextInputUrlAttribute)], _ rhs: [(NSRange, ChatTextInputUrlAttribute)]) -> Bool {
    if lhs.count != rhs.count {
        return false
    }
    for i in 0 ..< lhs.count {
        if lhs[i].0 != rhs[i].0 || lhs[i].1.url != rhs[i].1.url {
            return false
        }
    }
    return true
}

final class ChatTextInputUrlAttribute: NSObject {
    let url: String
    
    init(url: String) {
        self.url = url
        
        super.init()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let other = object as? ChatTextInputUrlAttribute {
            return self.url == other.url
        } else {
            return false
        }
    }
}


func refreshChatTextInputAttributes(_ textNode: ASEditableTextNode, theme: PresentationTheme, baseFontSize: CGFloat) {
    guard let initialAttributedText = textNode.attributedText, initialAttributedText.length != 0 else {
        return
    }
    
    let text: NSString = initialAttributedText.string as NSString
    let fullRange = NSRange(location: 0, length: initialAttributedText.length)
    
    let attributedText = NSMutableAttributedString(attributedString: stateAttributedStringForText(initialAttributedText))
    
    var textMentionRanges: [(NSRange, ChatTextInputTextMentionAttribute)] = []
    initialAttributedText.enumerateAttribute(ChatTextInputAttributes.textMention, in: fullRange, options: [], using: { value, range, _ in
        if let value = value as? ChatTextInputTextMentionAttribute {
            textMentionRanges.append((range, value))
        }
    })
    textMentionRanges.sort(by: { $0.0.location < $1.0.location })
    let initialTextMentionRanges = textMentionRanges
    
    for i in 0 ..< textMentionRanges.count {
        let range = textMentionRanges[i].0
        
        var validLower = range.lowerBound
        inner1: for i in range.lowerBound ..< range.upperBound {
            if let c = UnicodeScalar(text.character(at: i)) {
                if alphanumericCharacters.contains(c) || c == " " as UnicodeScalar {
                    validLower = i
                    break inner1
                }
            } else {
                break inner1
            }
        }
        var validUpper = range.upperBound
        inner2: for i in (validLower ..< range.upperBound).reversed() {
            if let c = UnicodeScalar(text.character(at: i)) {
                if alphanumericCharacters.contains(c) || c == " " as UnicodeScalar {
                    validUpper = i + 1
                    break inner2
                }
            } else {
                break inner2
            }
        }
        
        let minLower = (i == 0) ? fullRange.lowerBound : textMentionRanges[i - 1].0.upperBound
        inner3: for i in (minLower ..< validLower).reversed() {
            if let c = UnicodeScalar(text.character(at: i)) {
                if alphanumericCharacters.contains(c) {
                    validLower = i
                } else {
                    break inner3
                }
            } else {
                break inner3
            }
        }
        
        let maxUpper = (i == textMentionRanges.count - 1) ? fullRange.upperBound : textMentionRanges[i + 1].0.lowerBound
        inner3: for i in validUpper ..< maxUpper {
            if let c = UnicodeScalar(text.character(at: i)) {
                if alphanumericCharacters.contains(c) {
                    validUpper = i + 1
                } else {
                    break inner3
                }
            } else {
                break inner3
            }
        }
        
        textMentionRanges[i] = (NSRange(location: validLower, length: validUpper - validLower), textMentionRanges[i].1)
    }
    
    textMentionRanges = textMentionRanges.filter({ $0.0.length > 0 })
    
    while textMentionRanges.count > 1 {
        var hadReductions = false
        outer: for i in 0 ..< textMentionRanges.count - 1 {
            if textMentionRanges[i].1 === textMentionRanges[i + 1].1 {
                var combine = true
                inner: for j in textMentionRanges[i].0.upperBound ..< textMentionRanges[i + 1].0.lowerBound {
                    if let c = UnicodeScalar(text.character(at: j)) {
                        if alphanumericCharacters.contains(c) || c == " " as UnicodeScalar {
                        } else {
                            combine = false
                            break inner
                        }
                    } else {
                        combine = false
                        break inner
                    }
                }
                if combine {
                    hadReductions = true
                    textMentionRanges[i] = (NSRange(location: textMentionRanges[i].0.lowerBound, length: textMentionRanges[i + 1].0.upperBound - textMentionRanges[i].0.lowerBound), textMentionRanges[i].1)
                    textMentionRanges.remove(at: i + 1)
                    break outer
                }
            }
        }
        if !hadReductions {
            break
        }
    }
    
    if textMentionRanges.count > 1 {
        outer: for i in (1 ..< textMentionRanges.count).reversed() {
            for j in 0 ..< i {
                if textMentionRanges[j].1 === textMentionRanges[i].1 {
                    textMentionRanges.remove(at: i)
                    continue outer
                }
            }
        }
    }
    
    if !textMentionRangesEqual(textMentionRanges, initialTextMentionRanges) {
        attributedText.removeAttribute(ChatTextInputAttributes.textMention, range: fullRange)
        for (range, attribute) in textMentionRanges {
            attributedText.addAttribute(ChatTextInputAttributes.textMention, value: ChatTextInputTextMentionAttribute(peerId: attribute.peerId), range: range)
        }
    }
    
    let resultAttributedText = textAttributedStringForStateText(attributedText, fontSize: baseFontSize, textColor: theme.chat.inputPanel.primaryTextColor, accentTextColor: theme.chat.inputPanel.panelControlAccentColor)
    
    if !resultAttributedText.isEqual(to: initialAttributedText) {
        textNode.textView.textStorage.removeAttribute(NSAttributedStringKey.font, range: fullRange)
        textNode.textView.textStorage.removeAttribute(NSAttributedStringKey.foregroundColor, range: fullRange)
        textNode.textView.textStorage.removeAttribute(ChatTextInputAttributes.textMention, range: fullRange)
        
        textNode.textView.textStorage.addAttribute(NSAttributedStringKey.font, value: Font.regular(baseFontSize), range: fullRange)
        textNode.textView.textStorage.addAttribute(NSAttributedStringKey.foregroundColor, value: theme.chat.inputPanel.primaryTextColor, range: fullRange)
        
        attributedText.enumerateAttributes(in: fullRange, options: [], using: { attributes, range, _ in
            var fontAttributes: FontAttributes = []
            
            for (key, value) in attributes {
                if key == ChatTextInputAttributes.textMention {
                    textNode.textView.textStorage.addAttribute(key, value: value, range: range)
                    textNode.textView.textStorage.addAttribute(NSAttributedStringKey.foregroundColor, value: theme.chat.inputPanel.panelControlAccentColor, range: range)
                } else if key == ChatTextInputAttributes.bold {
                    textNode.textView.textStorage.addAttribute(key, value: value, range: range)
                    fontAttributes.insert(.bold)
                } else if key == ChatTextInputAttributes.italic {
                    textNode.textView.textStorage.addAttribute(key, value: value, range: range)
                    fontAttributes.insert(.italic)
                } else if key == ChatTextInputAttributes.monospace {
                    textNode.textView.textStorage.addAttribute(key, value: value, range: range)
                    fontAttributes.insert(.monospace)
                } else if key == ChatTextInputAttributes.url {
                    textNode.textView.textStorage.addAttribute(key, value: value, range: range)
                    textNode.textView.textStorage.addAttribute(NSAttributedStringKey.foregroundColor, value: theme.chat.inputPanel.panelControlAccentColor, range: range)
                }
            }
                
            if !fontAttributes.isEmpty {
                var font: UIFont?
                if fontAttributes == [.bold, .italic, .monospace] {
                    
                } else if fontAttributes == [.bold, .italic] {
                    font = Font.semiboldItalic(baseFontSize)
                } else if fontAttributes == [.bold, .monospace] {
                    
                } else if fontAttributes == [.italic, .monospace] {
                    
                } else if fontAttributes == [.bold] {
                    font = Font.semibold(baseFontSize)
                } else if fontAttributes == [.italic] {
                    font = Font.italic(baseFontSize)
                } else if fontAttributes == [.monospace] {
                    font = Font.monospace(baseFontSize)
                }
                
                if let font = font {
                    textNode.textView.textStorage.addAttribute(NSAttributedStringKey.font, value: font, range: range)
                }
            }
        })
    }
}

func refreshChatTextInputTypingAttributes(_ textNode: ASEditableTextNode, theme: PresentationTheme, baseFontSize: CGFloat) {    
    var filteredAttributes: [String: Any] = [
        NSAttributedStringKey.font.rawValue: Font.regular(baseFontSize),
        NSAttributedStringKey.foregroundColor.rawValue: theme.chat.inputPanel.primaryTextColor
    ]
    if let attributedText = textNode.attributedText, attributedText.length != 0 {
        let attributes = attributedText.attributes(at: max(0, min(textNode.selectedRange.location - 1, attributedText.length - 1)), effectiveRange: nil)
        for (key, value) in attributes {
            if key == ChatTextInputAttributes.bold {
                filteredAttributes[key.rawValue] = value
            } else if key == ChatTextInputAttributes.italic {
                filteredAttributes[key.rawValue] = value
            } else if key == ChatTextInputAttributes.monospace {
                filteredAttributes[key.rawValue] = value
            } else if key == NSAttributedStringKey.font {
                filteredAttributes[key.rawValue] = value
            }
        }
    }
    textNode.textView.typingAttributes = filteredAttributes
}

func chatTextInputAddFormattingAttribute(_ state: ChatTextInputState, attribute: NSAttributedStringKey, value: Any = true) -> ChatTextInputState {
    if !state.selectionRange.isEmpty {
        let result = NSMutableAttributedString(attributedString: state.inputText)
        result.addAttribute(attribute, value: value, range: NSRange(location: state.selectionRange.lowerBound, length: state.selectionRange.count))
        return ChatTextInputState(inputText: result, selectionRange: state.selectionRange)
    } else {
        return state
    }
}

private func trimRangesForChatInputText(_ text: NSAttributedString) -> (Int, Int) {
    var lower = 0
    var upper = 0
    
    let nsString: NSString = text.string as NSString
    
    for i in 0 ..< nsString.length {
        if let c = UnicodeScalar(nsString.character(at: i)) {
            if c == " " as UnicodeScalar || c == "\t" as UnicodeScalar || c == "\n" as UnicodeScalar {
                lower += 1
            } else {
                break
            }
        } else {
            break
        }
    }
    
    if lower != nsString.length {
        for i in (lower ..< nsString.length).reversed() {
            if let c = UnicodeScalar(nsString.character(at: i)) {
                if c == " " as UnicodeScalar || c == "\t" as UnicodeScalar || c == "\n" as UnicodeScalar {
                    upper += 1
                } else {
                    break
                }
            } else {
                break
            }
        }
    }
    
    return (lower, upper)
}

func trimChatInputText(_ text: NSAttributedString) -> NSAttributedString {
    let (lower, upper) = trimRangesForChatInputText(text)
    if lower == 0 && upper == 0 {
        return text
    }
    
    let result = NSMutableAttributedString(attributedString: text)
    if upper != 0 {
        result.replaceCharacters(in: NSRange(location: result.length - upper, length: upper), with: "")
    }
    if lower != 0 {
        result.replaceCharacters(in: NSRange(location: 0, length: lower), with: "")
    }
    return result
}

func breakChatInputText(_ text: NSAttributedString) -> [NSAttributedString] {
    if text.length <= 4000 {
        return [text]
    } else {
        let rawText: NSString = text.string as NSString
        var result: [NSAttributedString] = []
        var offset = 0
        while offset < text.length {
            var range = NSRange(location: offset, length: min(text.length - offset, 4000))
            if range.upperBound < text.length {
                inner: for i in (range.lowerBound ..< range.upperBound).reversed() {
                    let c = rawText.character(at: i)
                    let uc = UnicodeScalar(c)
                    if uc == "\n" as UnicodeScalar || uc == "." as UnicodeScalar {
                        range.length = i + 1 - range.location
                        break inner
                    }
                }
            }
            result.append(trimChatInputText(text.attributedSubstring(from: range)))
            offset = range.upperBound
        }
        return result
    }
}
