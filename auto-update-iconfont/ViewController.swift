//
//  ViewController.swift
//  auto-update-iconfont
//
//  Created by 孙继刚 on 2017/7/19.
//  Copyright © 2017年 madordie. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var tips: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        tips.stringValue = "该项目目前仅支持："
            + "\n\t↳" + support.map({ $0.name }).joined(separator: "、")
            + "\n\t↳如需支持其他项目请联系\(Jenkins.default.developer)"
    }
    @IBAction func goIconfont(_ sender: Any) {
        guard let url = URL(string: "https://www.iconfont.cn/manage/index?manage_type=myprojects") else { return }
        NSWorkspace.shared.open(url)
    }
}

