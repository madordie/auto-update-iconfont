//
//  Project.swift
//  auto-update-iconfont
//
//  Created by 孙继刚 on 2018/12/26.
//  Copyright © 2018 madordie. All rights reserved.
//

import Cocoa

enum ProjectError: Error {
    case empty(String)
}
extension ProjectError: CustomStringConvertible {
    var description: String {
        switch self {
        case .empty(let id):
            return "没有可以更新的项目。"
                + "\n\t↳请确认您所复制代码的项目(\(id))是否支持，"
                + "\n\t↳如果需要支持请联系\(Jenkins.default.developer)"
        }
    }
}

protocol Project {
    /// iconfont project id
    var fontId: String { get }
    /// 项目名
    var name: String { get }
    /// Jenkins上的路径
    var path: String { get }
    /// curl 参数
    func cmd(_ code: String) throws -> [String]
}

enum DataError: Error {
    case empty(String)
}
extension DataError: CustomStringConvertible{
    var description: String {
        switch self {
        case .empty(let url):
            return "无数据\n\t↳" + url
        }
    }
}

enum CSSError: Error {
    case format(String)
}
extension CSSError: CustomStringConvertible{
    var description: String {
        switch self {
        case .format(let url):
            return "CSS解析失败\n\t↳" + url
        }
    }
}
extension Jenkins {
    /// TTF直接上传的项目
    struct TTFProject: Project {
        let fontId: String
        let name: String
        let ttfName = "iconfont.ttf"
        let path: String
        static var ttfLocalpath: String?
        /// 将code中的ttf保存至本地
        ///
        /// - Parameters:
        ///   - code: 复制的代码
        /// - Returns: 本地路径
        func ttfLocalpath(_ code: Code) throws -> String {
            if let localPath = TTFProject.ttfLocalpath {
                return localPath
            }
            let ttf = try code.url(project: self)
            guard let url = URL(string: ttf) else { throw URLError.create(ttf) }
            let data = try Data(contentsOf: url, options: [])
            let locationPath = try data.save(ttf: url)
            TTFProject.ttfLocalpath = locationPath
            return locationPath
        }
        func cmd(_ code: String) throws -> [String] {
            let ttf = try ttfLocalpath(code)
            return ["--form file0=@\(ttf)",
                    "--form json='{\"parameter\": [{\"name\":\"\(ttfName)\", \"file\":\"file0\"},{\"name\":\"from\", \"value\":\"\(NSUserName())\"}]}'"]
        }
    }
}
extension Jenkins {
    /// 代码直接插入
    struct CodeProject: Project {
        let fontId: String
        let name: String
        let path: String
        func cmd(_ code: String) throws -> [String] {
            guard code.hasPrefix("@font-face {") && code.hasSuffix("}") else { throw CodeError.format }
            let code = code.components(separatedBy: "\n").joined(separator: "\\n")
                .components(separatedBy: "\t").joined(separator: "\\t")
            return ["-d", "from=\"\(NSUserName())\"",
                    "-d", "code=\"\(code)\""]
        }
    }
}

extension Jenkins {
    /// CSS插入
    struct CSSProject: Project {
        let fontId: String
        let name: String
        let path: String
        func cmd(_ code: Code) throws -> [String] {
            let url = try code.url(project: self, prefix: "", suffix: .css)
            return ["--data-urlencode",
                    Jenkins.mk(json: ["from": NSUserName(),
                                      "css": url,
                                      "project_id": fontId])]
        }
    }
}

extension Jenkins {
    static func mk(json: [String: String], prefix: String = "json='", suffix: String = "'") -> String {
        return prefix
            + "{\"parameter\": ["
            + json
                .map({ "{\"name\":\"\($0.key)\", \"value\":\"\($0.value)\"}" })
                .joined(separator: ", ")
            + "]}"
            + suffix
    }
}
