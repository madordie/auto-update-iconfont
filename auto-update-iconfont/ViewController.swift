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

        tips.stringValue = "该项目仅支持：" + support.map({ $0.name }).joined(separator: "、")
    }
    @IBAction func goIconfont(_ sender: Any) {
        guard let url = URL(string: "https://www.iconfont.cn/manage/index?manage_type=myprojects") else { return }
        NSWorkspace.shared.open(url)
    }
}

