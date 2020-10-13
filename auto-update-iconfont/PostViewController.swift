//
//  PostViewController.swift
//  auto-update-iconfont
//
//  Created by 孙继刚 on 2018/12/26.
//  Copyright © 2018 madordie. All rights reserved.
//

import AppKit
import Cocoa
import SwiftShell

enum IBError: Error {
    case instantiate(NSStoryboard.SceneIdentifier)
}
extension IBError: CustomStringConvertible {
    var description: String {
        switch self {
        case .instantiate(let id):
            return "崩溃了。。。"
                + "\n\t↳ \(id)无法初始化"
        }
    }
}

extension NSStoryboard.SceneIdentifier {
    static let postViewController = "ib-post-view-controller"
}

class PostViewController: NSViewController {

    @IBOutlet var log: NSTextView!

    var callback: (() -> Void)?

    var code = ""
    var projects = [Project]()

    override func viewDidLoad() {
        super.viewDidLoad()
        log.isEditable = false
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        DispatchQueue.global().async {
            do {
                let result = try self.projects
                    .map({ (try Jenkins.default.post(code: self.code, project: $0), $0.name) })
                let ojbk = result.filter({ $0.0 })
                var log: String
                let errorAtMe = { "\n\n\t先看一下上面的日志，如果无法不能理解或无法解决\n\t请 **携带此日志** 联系：\(Jenkins.default.developer)协助帮助。" }
                if ojbk.count == result.count {
                    log = "所有的均成功触发完成 🎉🎉🎉"
                } else if ojbk.count == 0 {
                    log = result.filter({ !$0.0 }).map({ $0.1 }).joined(separator: "、")
                        + "，全部触发失败！！"
                        + errorAtMe()
                } else {
                    log = "只有\(ojbk.map({ $0.1 }).joined(separator: "、"))成功触发，"
                        + "\(result.filter({ !$0.0 }).map({ $0.1 }).joined(separator: "、"))触发失败!!"
                        + errorAtMe()
                }
                self.log(log)
            } catch { self.log("\(error)") }
        }
    }

    func log(_ error: Any) {
        let commit: () -> Void = {
            self.log.string = self.log.string.appending("\n\(error)")
            self.log.scrollRangeToVisible(NSRange(location: self.log.string.count, length: 1))
        }
        if Thread.isMainThread { commit() }
        else { DispatchQueue.main.async(execute: commit) }
    }

    @IBAction func cancel(_ sender: Any) {
        dismiss(sender)
        callback?()
    }
    @IBAction func done(_ sender: Any) {
        callback?()
        exit(0)
    }
}
