//
//  Log.swift
//  MakeSketchplugin
//
//  Created by 孙继刚 on 2017/7/13.
//  Copyright © 2017年 madordie. All rights reserved.
//

import Cocoa
import RxSwift

class Log {

    static var `default` = Log()

    let `inout` = Variable("")
}

extension Log {
    class func p(_ string: String) {
        guard string.characters.count > 0 else { return }
        Log.default.inout.value = string
    }
}
