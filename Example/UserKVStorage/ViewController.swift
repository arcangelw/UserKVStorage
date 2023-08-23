//
//  ViewController.swift
//  UserKVStorage
//
//  Created by arcangel-w on 08/23/2023.
//  Copyright (c) 2023 arcangel-w. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let uInt64 = UInt64.max
        let uInt64Number = NSNumber(value: uInt64)
        let uInt64Type = CFNumberGetType(uInt64Number)

        let int64 = Int64.max
        let int64Number = NSNumber(value: int64)
        let int64Type = CFNumberGetType(int64Number)
        let int64CType = int64Number.objCType.pointee

        let int = Int.max
        let intNumber = NSNumber(value: int)
        let intType = CFNumberGetType(intNumber)
        let intCType = intNumber.objCType.pointee
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
