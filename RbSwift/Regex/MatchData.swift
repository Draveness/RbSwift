//
//  MatchData.swift
//  RbSwift
//
//  Created by draveness on 19/03/2017.
//  Copyright © 2017 draveness. All rights reserved.
//

import Foundation

/// Including all the necessary infomation when using `Regex`
public struct MatchData {
    /// A match
    public let match: String
    /// A range for the match
    public let range: NSRange
    /// The array of captures
    public let captures: [String]
    /// The array of all captures ranges
    public let ranges: [NSRange]
    
    /// Returns the number of elements in the match array.
    public var size: Int {
        return to_a.size
    }
    
    /// Returns the array of matches.
    public var to_a: [String] {
        return [match] + captures
    }
    
    /// Returns the entire matched string.
    public var to_s: String {
        return match
    }
    
    public init(match: String, range: NSRange, captures: [String], ranges: [NSRange]) {
        self.match = match
        self.range = range
        self.captures = captures
        self.ranges = ranges
    }
}

extension MatchData: Hashable {
    public func hash(into hasher: inout Hasher) {
        let hashValue = match.hashValue ^ range.hashValue ^ captures.joined().hashValue ^ ranges.reduce(0) { $0 ^ $1.hashValue }
        hasher.combine(hashValue)
    }
}

extension MatchData: Equatable {
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: MatchData, rhs: MatchData) -> Bool {
        guard lhs.match == rhs.match else { return false }
        guard lhs.range == rhs.range else { return false }
        guard lhs.captures == rhs.captures else { return false }
        guard lhs.ranges == rhs.ranges else { return false }
        return true
    }
}
