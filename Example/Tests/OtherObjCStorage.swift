//
//  OtherObjCStorage.swift
//  UserKVStorage_Example
//
//  Created by 吴哲 on 2023/8/29.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UserKVStorage

final class OtherObjCStorage: DefaultStorage {
    override class var storage: UserKVStorage {
        enum Once {
            static let other = UserKVStorage(name: "other")
        }
        return Once.other
    }
}
