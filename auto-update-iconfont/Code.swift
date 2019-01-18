//
//  Code.swift
//  auto-update-iconfont
//
//  Created by 孙继刚 on 2018/12/27.
//  Copyright © 2018 madordie. All rights reserved.
//

import Cocoa

enum URLError: Error {
    case create(String)
}
extension URLError: CustomStringConvertible {
    var description: String {
        switch self {
        case .create(let url):
            return "无法创建URL\n\t↳ " + url
        }
    }
}

enum CodeError: Error {
    case format
}
extension CodeError: CustomStringConvertible {
    var description: String {
        switch self {
        case .format:
            return "无法格式化您所复制的代码。\n"
                + "\t↳请确认您复制的是`Unicode -> 在线链接`中的代码。\n"
                + "\t↳您可以向\(Jenkins.default.developer)寻求帮助"
        }
    }
}

typealias Code = String

extension Code {
    static var `default` = ""
}

enum FileType: String {
    case ttf = "ttf"
    case css = "css"
    /// 确认URL是否属于该文件类型
    ///
    /// - Parameter strURL: url
    /// - Throws: Error
    func checkout(url strURL: String) throws {
        guard let url = URL(string: strURL) else { throw URLError.create(strURL) }
        let data = try Data(contentsOf: url, options: [])
        switch self {
        case .css:
            guard var css = String(data: data, encoding: .utf8) else { throw CSSError.format(strURL) }
            css = css.components(separatedBy: "\n").joined()
            guard css.hasPrefix("@font-face {font-family: \"iconfont\";") else { throw CSSError.format(css) }
        default:
            guard data.count > 0 else { throw DataError.empty(strURL) }
        }
    }
}

extension Code {
    static let regularURL: (Project) -> String = { "//at.alicdn.com/t/font_\($0.fontId)_[\\d\\w]+." }
    static let regularProjectId = "font-family: 'iconfont';  /\\* project id (\\d+) \\*/"

    /// 从剪切板获取Code
    ///
    /// - Returns: Code
    /// - Throws: CodeError
    static func newFromPasteboard() throws -> Code {
        guard let code = NSPasteboard.general.string(forType: .string) else { throw CodeError.format }
        return code
    }

    /// 获取代码中的iconfont project id
    ///
    /// - Returns: iconfont project id
    /// - Throws: CodeError
    func projectId() throws -> String {
        let code = self
        let expression = try NSRegularExpression(pattern: Code.regularProjectId, options: .caseInsensitive)
        let id = try NSRegularExpression(pattern: "\\d+", options: .caseInsensitive)
        let strings = expression
            .matches(in: code, options: [], range: NSRange(location: 0, length: code.count))
            .flatMap { (result) -> [String] in
                guard let range = Range<String.Index>(result.range, in: code) else { return [] }
                let block = String(code[range])
                return id.matches(in: block, options: [], range: NSRange(location: 0, length: block.count))
                    .compactMap({ (result) -> String? in
                        guard let range = Range<String.Index>(result.range, in: code) else { return nil }
                        return String(block[range])
                    })
            }
        // 此处正常就1个数据，要不就GG给你看
        guard strings.count == 1 else { throw CodeError.format }
        return strings.joined()
    }

    /// 获取URL
    ///
    /// - Parameters:
    ///   - prefix: URL前缀
    ///   - suffix: URL后缀
    /// - Returns: 全部的URL，会根据type做简单的校验
    /// - Throws: 炸了
    func url(project: Project, prefix: String = "https:", suffix: FileType = .ttf) throws -> String {
        let code = self
        let expression = try NSRegularExpression(pattern: Code.regularURL(project), options: .caseInsensitive)
        let strings = expression
            .matches(in: code, options: [], range: NSRange(location: 0, length: code.count))
            .compactMap({ (result) -> String? in
                guard let range = Range<String.Index>(result.range, in: code) else { return nil }
                return String(code[range])
            })
        // 此处正常就6个数据，要不就GG给你看
        guard strings.count == 6 else { throw CodeError.format }
        var onlyOne = Set(strings)
        // 5个数据去掉后缀之后就是一个，如果不对就GG
        guard onlyOne.count == 1 else { throw CodeError.format }
        let hostURL = "\(onlyOne.removeFirst())\(suffix.rawValue)"
        let httpsURL = "https:" + hostURL
        try suffix.checkout(url: httpsURL)
        return prefix + hostURL
    }
}
