//
//  PostViewController.swift
//  auto-update-iconfont
//
//  Created by 孙继刚 on 2018/12/26.
//  Copyright © 2018 madordie. All rights reserved.
//

import AppKit
import Cocoa

class PostViewController: NSViewController, Log {

    @IBOutlet var log: NSTextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        log.isEditable = false
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        log { (p) -> Void in
            guard let code = NSPasteboard.general().string(forType: NSPasteboardTypeString) else { return p((), .error,  "剪切板无数据呀。。") }
            let result = support
                .map({ (Jenkins.default.post(code: code, project: $0, log: self), $0.name) })
            let ojbk = result.filter({ $0.0 })
            let log: String
            if ojbk.count == result.count {
                log = "所有的均成功触发完成。🎉🎉🎉"
            } else {
                log = "只有" + ojbk.map({ $0.1 }).joined(separator: "、")
                    + "成功触发，"
                    + result.filter({ !$0.0 }).map({ $0.1 }).joined(separator: "、")
                    + "触发失败，请联系：孙继刚协助帮助。"
            }
            return p((), .ojbk, "所有处理完成，" + log)
        }
    }

    func log<T>(_ exe: ((T, LogType, String) -> T) -> T) -> T {
        func printLog(value: T, _ type: LogType, _ txt: String) -> T {
            log.string = (log.string?.appending("\n") ?? "") + type.rawValue + txt + "\n"
            log.scrollRangeToVisible(NSRange(location: log.string?.count ?? 0, length: 1))
            return value
        }
        return exe(printLog)
    }

    @IBAction func cancel(_ sender: Any) {
        dismiss(sender)
    }
    @IBAction func done(_ sender: Any) {
        exit(0)
    }
}
