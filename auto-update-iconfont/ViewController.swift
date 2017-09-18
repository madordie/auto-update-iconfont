//
//  ViewController.swift
//  auto-update-iconfont
//
//  Created by 孙继刚 on 2017/7/19.
//  Copyright © 2017年 madordie. All rights reserved.
//

import Cocoa
import RxSwift

struct Item {
    let name: String
    let file: String
    let jenkins: String

    func post(_ path: String) -> String {
        return "curl -u UI:71d9848dd7bf4dfd8af9c60892d67913 -X POST http://10.12.12.10:8080/job/\(jenkins)/build  --form file0=@\(path) --form json='{\"parameter\": [{\"name\":\"\(file)\", \"file\":\"file0\"},{\"name\":\"from\", \"value\":\"\(NSUserName())\"}]}'"
    }
}

class ViewController: NSViewController {
    fileprivate let bag = DisposeBag()

    @IBOutlet var log: NSTextView!

    let android = Item(name: "Android",
                       file: "iconfont.ttf",
                       jenkins: "FDD-Customer-Android/job/update-iconfont")

    let ios = Item(name: "iOS",
                   file: "iconfont.ttf",
                   jenkins: "fdd-ios-app/job/update-iconFont")

    override func viewDidLoad() {
        super.viewDidLoad()

        log.isEditable = false

        DispatchQueue.main.async {
            self.log.string = "将需要更新至C端的xxx.ttf拖拽进来即可更新。"
        }

        guard let view = view as? DDView else { return }
        Log.default.inout.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (log) in
                guard let _self = self else { return }
                _self.log.string = (_self.log.string ?? "") + "\n\n" + log
                _self.log.scrollRangeToVisible(NSRange(location: _self.log.string?.characters.count ?? 0, length: 1))
            })
            .addDisposableTo(bag)

        view.draggingUrls.asObservable()
            .skip(1)
            .filter({ (urls) -> Bool in
                if urls.count != 1 {
                    Log.p("请只选择一个.ttf文件！")
                    return false
                }
                return true
            })
            .map { $0.first }
            .map({ (url) -> String? in
                guard let url = url else { return nil }
                if url.lastPathComponent.hasSuffix(".ttf") {
                    return url.path
                }
                Log.p("请选择.ttf文件！")
                return nil
            })
            .filter { $0 != nil }
            .map { $0 ?? "" }
            .subscribe(onNext: { [weak self] (url) in
                guard let _self = self else { return }
                let list = [_self.ios, _self.android]

                Log.p("正在处理...")
                for item in list {
                    let info = Command.default.run([item.post(url)])
                    if let status = info.status, status == 0 {
                        Log.p("\(item.name)项目已触发")
                        Log.p(info.output)
                    } else {
                        Log.p("\(item.name)触发失败～ \nERROR:\(info.output)")
                    }
                }
                Log.p("执行序列已触发完毕。")
            })
            .addDisposableTo(bag)
        view.isDragIn.asObservable()
            .map { $0 ? NSColor.gray : NSColor.white }
            .subscribe(onNext: { [weak self] (color) in
                self?.log.backgroundColor = color
            })
            .addDisposableTo(bag)
    }
}

