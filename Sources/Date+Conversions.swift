//
//  Date+Conversions.swift
//  RbSwift
//
//  Created by draveness on 19/03/2017.
//  Copyright © 2017 draveness. All rights reserved.
//

import Foundation

public extension Date {
    /// Returns a new date with utc format.
    var to_utc: Date {
        return utc
    }

    /// Returns a new date with utc format.
    var utc: Date {
        let dateFormatter = DateFormat.Custom()
        return dateFormatter.date(from: "\(self)")!
    }
}