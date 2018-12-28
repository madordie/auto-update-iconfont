//
//  Project.swift
//  auto-update-iconfont
//
//  Created by 孙继刚 on 2018/12/26.
//  Copyright © 2018 madordie. All rights reserved.
//

import Cocoa
import SwiftShell

/// 日志类型
///
/// - info: 普通信息
/// - error: 错误信息
/// - ojbk: 成功信息
enum LogType: String {
    case info = "[i] "
    case error = "[x] "
    case ojbk = "[√] "
}
protocol Log {
    /// 日志记录
    ///
    /// - Parameter exe: 一个闭包 闭包包含一个记录日志的函数`(T, LogType, String) -> T)`
    /// - Returns: 处理之后
    @discardableResult
    func log<T>(_ exe: ((T, LogType, String) -> T) -> T) -> T;
}

/// Jenkins配置 https://wiki.jenkins.io/display/JENKINS/Remote+access+API
struct Jenkins {
    let user = "UI"
    let token = "33ae6ce6091442ff89d5c369a4944eb0"
    let projectURL: (String) -> String = { "http://10.12.12.10:8080/job/\($0)/build" }
    let developer = "[继刚](https://madordie@github.io)"

    static let `default` = Jenkins()
}
protocol Project {
    /// 项目名
    var name: String { get }
    /// Jenkins上的路径
    var path: String { get }
    /// curl 参数
    func cmd(_ code: String, _ log: Log) -> [String]
}

extension Jenkins {
    /// TTF直接上传的项目
    struct TTFProject: Project {
        let name: String
        let ttfName = "iconfont.ttf"
        let path: String
        static var ttfLocalpath: String?
        /// 将code中的ttf保存至本地
        ///
        /// - Parameters:
        ///   - code: 复制的代码
        ///   - log: 日志系统
        /// - Returns: 本地路径
        func ttfLocalpath(_ code: Code, _ log: Log) -> String? {
            return log.log({ (p) -> String? in
                guard TTFProject.ttfLocalpath == nil else { return p(TTFProject.ttfLocalpath, .info, "已获取本地文件:" + path) }
                guard let ttf = code.url(log: log) else { return p(nil, .error,  "无法取出ttf") }
                guard let url = URL(string: ttf) else { return p(nil, .error,  "无法请求ttf") }
                var tmp: Data?
                do {
                    tmp = try Data(contentsOf: url, options: [])
                } catch {
                    return p(nil, .error, error.localizedDescription)
                }
                guard let data = tmp else { return p(nil, .error,  "ttf下载失败") }
                guard let locationPath = data.save(ttf: url, log: log) else { return p(nil, .error,  "ttf 保存失败") }
                do {
                    tmp = try Data(contentsOf: URL(fileURLWithPath: locationPath), options: [])
                } catch {
                    return p(nil, .error, error.localizedDescription)
                }
                guard (tmp?.count ?? 0) == data.count else { return p(nil, .error,  "保存本地的数据与下载数据不同。。") }
                TTFProject.ttfLocalpath = locationPath
                return p(locationPath, .info, "已下载ttf:" + locationPath)
            })
        }
        func cmd(_ code: String, _ log: Log) -> [String] {
            return log.log({ (p) -> [String] in
                guard let ttf = ttfLocalpath(code, log) else {
                    return p([], .error, "无法获取ttf路径")
                }
                return ["--form file0=@\(ttf)",
                        "--form json='{\"parameter\": [{\"name\":\"\(ttfName)\", \"file\":\"file0\"},{\"name\":\"from\", \"value\":\"\(NSUserName())\"}]}'"]
            })
        }
    }
}
extension Jenkins {
    /// 代码直接插入
    struct CodeProject: Project {
        let name: String
        let path: String
        func cmd(_ code: String, _ log: Log) -> [String] {
            return log.log({ (p) -> [String] in
                guard code.hasPrefix("@font-face {") && code.hasSuffix("}") else { return p([], .error,  "无法识别 请确认是否正确复制") }
                let code = code.components(separatedBy: "\n").joined(separator: "\\n")
                    .components(separatedBy: "\t").joined(separator: "\\t")
                return ["-d", "from=\"\(NSUserName())\"",
                        "-d", "code=\"\(code)\""]
            })
        }
    }
}

extension Jenkins {
    /// CSS插入
    struct CSSProject: Project {
        let name: String
        let path: String
        func cmd(_ code: Code, _ log: Log) -> [String] {
            return log.log({ (p) -> [String] in
                guard let url = code.url(log: log, prefix: "", suffix: .css) else { return p([], .error,  "无法识别 请确认是否正确复制") }
                return ["--data-urlencode",
                        "json='{\"parameter\": [{\"name\":\"from\", \"value\":\"\(NSUserName())\"}, {\"name\":\"css\", \"value\":\"\(url)\"}]}'"]
            })
        }
    }
}

extension Jenkins {
    /// 将参数传递到Jenkins
    ///
    /// - Parameters:
    ///   - code: 复制的代码
    ///   - project: 所属项目
    ///   - log: 日志记录
    /// - Returns: 是否处理成功
    func post(code: String, project: Project, log: Log) -> Bool {
        return log.log { (p) -> Bool in
            let cmd = ["curl",
                       "-X POST \(projectURL(project.path))",
                       "--user \(user):\(token)"]
                .joined(separator: " ")
            let parameter = project.cmd(code, log).joined(separator: " ")
            guard parameter.count > 0 else { return p(false, .error, project.name + "上传参数获取失败") }
            let sh = cmd + " " + parameter
            _ = p(true, .info, "开始触发" + project.name + ": " + parameter)
            let output = run(bash: sh)
            guard output.succeeded else {
                return p(false, .error, "触发失败：" + output.stderror)
            }
            return p(true, .ojbk, project.name + " 已成功触发")
        }
    }
}

let support: [Project] =
    [
        Jenkins.CSSProject
            .init(name: "房商铺",
                  path: "iconfont/job/fangshangpu-website"),
//        Jenkins.TTFProject
//            .init(name: "多多卖房Android",
//                  path: "duoduowangshang/job/iconfont-update-android"),
//        Jenkins.TTFProject
//            .init(name: "多多卖房iOS",
//                  path: "duoduowangshang/job/iconfont-update-ios"),
    ]
