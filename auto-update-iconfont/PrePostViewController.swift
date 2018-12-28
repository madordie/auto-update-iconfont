//
//  PrePostViewController.swift
//  auto-update-iconfont
//
//  Created by 孙继刚 on 2018/12/28.
//  Copyright © 2018 madordie. All rights reserved.
//

import Cocoa

class PrePostViewController: NSViewController {

    @IBOutlet weak var tips: NSTextField!
    @IBOutlet weak var next: NSButton!

    @available(OSX 10.13, *)
    lazy var postVC: PostViewController? = {
        return NSStoryboard.main?
            .instantiateController(withIdentifier: .postViewController) as? PostViewController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        next.isHidden = true
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        do {
            try prepare()
        } catch {
            tips.stringValue = "\(error)"
        }
    }

    @IBAction func cancel(_ sender: Any) {
        dismiss(sender)
    }
    @IBAction func next(_ sender: Any) {
        guard let post = postVC else { return }
        presentAsSheet(post)
        post.callback = { [weak self] in self?.dismiss(nil) }
    }
    
    func prepare() throws {
        let code = try Code.newFromPasteboard()
        let project = try code.projectId()
        let supportList = support.filter({ $0.fontId == project })
        guard supportList.count > 0 else { throw ProjectError.empty(project) }
        next.isHidden = false
        tips.stringValue = "您确定要更新以下项目么？\n\t↳"
            + supportList.map({ $0.name }).joined(separator: "、")
        guard let postVC = postVC else { throw IBError.instantiate(.postViewController) }
        postVC.code = code
        postVC.projects = supportList
    }
}
