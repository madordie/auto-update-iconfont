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
    let projectURL: (String) -> String = { "http://10.12.12.10:8080/job/\($0)/build" }
    let developer = "[继刚](https://madordie@github.io)"
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
                + "\n\t↳\(code)"
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
        let cmd = ["curl",
                   "-X POST \(projectURL(project.path))",
                   "--user \(user):\(token)"]
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
        Jenkins.CSSProject
            .init(fontId: "984807",
                  name: "房商铺",
                  path: "iconfont/job/fangshangpu-website"),
        Jenkins.TTFProject
            .init(fontId: "635235",
                  name: "多多卖房Android",
                  path: "duoduowangshang/job/iconfont-update-android"),
        Jenkins.TTFProject
            .init(fontId: "635235",
                  name: "多多卖房iOS",
                  path: "duoduowangshang/job/iconfont-update-ios"),
    ]
