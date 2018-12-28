//
//  Extensions.swift
//  auto-update-iconfont
//
//  Created by 孙继刚 on 2018/12/27.
//  Copyright © 2018 madordie. All rights reserved.
//

import Cocoa

extension String {
    func removeFile() throws {
        guard FileManager.default.fileExists(atPath: self) else { return }
        try FileManager.default.removeItem(atPath: self)
    }
}
extension Data {
    func save(ttf: URL) throws -> String {
        let name = ttf.lastPathComponent
        let path = NSHomeDirectory() + "/Downloads/"
            + "iconfont-update-" + Date().timeIntervalSince1970.description + "-" + name
        try write(to: URL(fileURLWithPath: path), options: .atomic)
        return path
    }
}
