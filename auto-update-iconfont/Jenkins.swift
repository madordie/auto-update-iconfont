//
//  Jenkins.swift
//  auto-update-iconfont
//
//  Created by 孙继刚 on 2018/12/28.
//  Copyright © 2018 madordie. All rights reserved.
//

import SwiftShell

/// Jenkins配置 https://wiki.jenkins.io/display/JENKINS/Remote+access+API
struct Jenkins {
    let user = "UI"
    let token = "33ae6ce6091442ff89d5c369a4944eb0"
    let projectURL: (String) -> String = { "https://ci-sz.fangdd.net/job/\($0)/build" }
    let developer = "[继刚](钉钉:sunjigang)"
    static let `default` = Jenkins()
}

enum JenkinsError: Error {
    case emptyParameter(String, String)
}
extension JenkinsError: CustomStringConvertible {
    var description: String {
        switch self {
        case .emptyParameter(let name, let code):
            return name + "上传参数生成失败"
                + "\n\t↳ \(code)"
        }
    }
}
extension Jenkins {
    /// 将参数传递到Jenkins
    ///
    /// - Parameters:
    ///   - code: 复制的代码
    ///   - project: 所属项目
    /// - Returns: 是否处理成功
    func post(code: String, project: Project) throws -> Bool {
        let cmd = [
            "curl",
            "-k",
            "-X POST \(projectURL(project.path))",
        ]
            .joined(separator: " ")
        let parameter = try project.cmd(code).joined(separator: " ")
        guard parameter.count > 0 else { throw JenkinsError.emptyParameter(project.name, code) }
        let sh = cmd + " " + parameter
        let output = run(bash: sh)
        return output.succeeded
    }
}

let support: [Project] =
    [
        Jenkins.TTFProject
            .init(fontId: "635235",
                  name: "[Android]多多卖房",
                  path: "iconfont/job/b-android"),
        Jenkins.TTFProject
            .init(fontId: "635235",
                  name: "[iOS]多多卖房",
                  path: "iconfont/job/b-ios"),
        Jenkins.TTFProject
            .init(fontId: "358738",
                  name: "[Android]房多多",
                  path: "iconfont/job/c-android"),
        Jenkins.TTFProject
            .init(fontId: "358738",
                  name: "[iOS]房多多",
                  path: "iconfont/job/c-ios"),
    ]
