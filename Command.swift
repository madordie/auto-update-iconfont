//
//  Command.swift
//  auto-update-iconfont
//
//  Created by 孙继刚 on 2017/7/19.
//  Copyright © 2017年 madordie. All rights reserved.
//

import Cocoa

class Command: NSObject {

    fileprivate var task: Process?

    static let `default` = Command()

    func run(_ shell: [String]) -> (status: Int32?, output: String) {
        task = Process()
        guard let task = task  else { return (status: nil, output: "系统错误") }
        if task.environment == nil {
            task.environment = ["PATH":"/usr/bin;/usr/local/bin/node;/usr/local/bin/thinkjs;/usr/local/bin/npm"]
        }
        task.launchPath = "/bin/bash"
        task.arguments = ["-l", "-c", shell.joined(separator: ";")]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()

        return (status: task.terminationStatus,
                output: String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "输出无法格式化")
    }
}
