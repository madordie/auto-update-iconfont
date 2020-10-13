//
//  ViewController.swift
//  auto-update-iconfont
//
//  Created by 孙继刚 on 2017/7/19.
//  Copyright © 2017年 madordie. All rights reserved.
//

import Cocoa

extension NSColor.Name {
    static let tipsColor = "tips_color"
}

class ViewController: NSViewController {

    @IBOutlet weak var tips: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        tips.attributedStringValue = {
            let attr = NSMutableAttributedString()
            attr.append(NSAttributedString(string: "# 该项目目前仅支持：\n\t↳ "))

            var list = support
                .flatMap({ (project) -> [NSAttributedString] in
                    guard let url = try? Jenkins.projectURL(project) else { return [] }
                    return [NSAttributedString.init(string: project.name, attributes: [.link: url]),
                            NSAttributedString(string: "、")]
                })
            list.removeLast()
            attr.append(list: list)
            attr.append(NSAttributedString(string: "\n\t↳ 如需支持其他项目请联系\(Jenkins.default.developer)"))

            attr.addAttributes([.font: NSFont.systemFont(ofSize: 15),
                                .foregroundColor: NSColor(named: .tipsColor) ?? NSColor.gray],
                               range: NSRange(location: 0, length: attr.string.count))
            return attr
        }()
        tips.allowsEditingTextAttributes = true
        tips.isSelectable = true
    }
}

