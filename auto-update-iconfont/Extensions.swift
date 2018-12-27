//
//  Extensions.swift
//  auto-update-iconfont
//
//  Created by 孙继刚 on 2018/12/27.
//  Copyright © 2018 madordie. All rights reserved.
//

import Cocoa

extension String {
    func getTTFs() -> [String]? {
        let prefix = "url('//"
        let suffix = ".ttf')format('truetype'),"
        return components(separatedBy: " ").joined()
            .components(separatedBy: "\n")
            .compactMap { (line) -> String? in
                guard let preRange = line.range(of: prefix) else { return nil }
                guard let sufRange = line.range(of: suffix) else { return nil }
                return line.substring(with: Range<String.Index>
                    .init(uncheckedBounds: (preRange.upperBound, sufRange.lowerBound)))
                    .appending(".ttf")
            }
    }
    func removeFile(_ log: Log) -> Bool {
        return log.log { (p) -> Bool in
            guard FileManager.default.fileExists(atPath: self) else { return p(true, .error, "该处无文件：" + self) }
            do {
                try FileManager.default.removeItem(atPath: self)
            } catch (let err) {
                return p(false, .error, "临时文件清理失败" + err.localizedDescription)
            }
            return p(true, .ojbk, "临时文件" + self + "已删除")
        }
    }
}
extension Data {
    func save(ttf: URL, log: Log) -> String? {
        return log.log { (p) -> String? in
            let name = ttf.lastPathComponent
            guard name.count > 1 else { return p(nil, .error, "文件名提取失败") }
            let path = NSHomeDirectory() + "/Downloads/iconfont-update-" + Date().timeIntervalSince1970.description + "-" + name
            do {
                try self.write(to: URL(fileURLWithPath: path), options: .atomic)
            } catch {
                return p(nil, .error, error.localizedDescription)
            }
            return p(path, .ojbk, "ttf文件已保存至：" + name)
        }
    }
}
