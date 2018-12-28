//
//  Code.swift
//  auto-update-iconfont
//
//  Created by 孙继刚 on 2018/12/27.
//  Copyright © 2018 madordie. All rights reserved.
//

import Cocoa

typealias Code = String

enum FileType: String {
    case ttf = "ttf"
    case css = "css"
    func checkout(url strURL: String, _ log: Log) -> Bool {
        return log.log({ (p) -> Bool in
            do {
                guard let url = URL(string: strURL) else { return p(false, .error, "无法转换为URL:" + strURL) }
                let data = try Data(contentsOf: url, options: [])
                switch self {
                case .css:
                    guard var css = String(data: data, encoding: .utf8) else { return p(false, .error, "无法解析数据：" + strURL) }
                    css = css.components(separatedBy: "\n").joined()
                    guard css.hasPrefix("@font-face {font-family: \"iconfont\";") else { return p(false, .error, "css解析格式出错：" + strURL) }
                    return p(true, .ojbk, strURL + "可正常解析")
                default:
                    guard data.count > 0 else { return p(false, .error, "无数据:" + strURL) }
                    return p(true, .ojbk, strURL + "共\(data.count)字节")
                }
            } catch {
                return p(false, .error, "无法获取文件：" + strURL)
            }
        })
    }
}

extension Code {
    static let regular = "//at.alicdn.com/t/font_\\d+_[\\d\\w]+."

    func url(log: Log, prefix: String = "https:", suffix: FileType = .ttf) -> String? {
        return log.log({ (p) -> String? in
            let code = self
            do {
                let expression = try NSRegularExpression(pattern: Code.regular, options: .caseInsensitive)
                let strings = expression
                    .matches(in: code, options: [], range: NSRange(location: 0, length: code.count))
                    .compactMap({ (result) -> String? in
                        guard let range = Range<String.Index>(result.range, in: code) else { return nil }
                        return String(code[range])
                    })
                // 此处正常就5个数据，要不就GG给你看
                guard strings.count == 5 else { return p(nil, .error, "无法识别:" + code) }
                var onlyOne = Set(strings)
                // 5个数据去掉后缀之后就是一个，如果不对就GG
                guard onlyOne.count == 1 else { return p(nil, .error, "识别出多个资源" + onlyOne.joined(separator: "、")) }
                let hostURL = "\(onlyOne.removeFirst())\(suffix.rawValue)"
                let httpsURL = "https:" + hostURL
                guard suffix.checkout(url: httpsURL, log) else { return p(nil, .error, "校验失败：" + httpsURL) }
                let url = prefix + hostURL
                return p(url, .ojbk, "成功获取并校验URL：" + url)
            } catch {
                return p(nil, .error, error.localizedDescription)
            }
        })
    }
}
