//
//  ArrayPatchSpec.swift
//  SwiftPatch
//
//  Created by draveness on 16/03/2017.
//  Copyright © 2017 draveness. All rights reserved.
//

import Quick
import Nimble
import RbSwift

class ArrayPatchSpec: BaseSpec {
    override func spec() {        
        describe(".combination(num:)") {
            it("creates a new array containing the values returned by the block") {
                expect([1, 2, 3].combination(1).flatMap { $0 }).to(equal([[1], [2], [3]].flatMap { $0 }))
                expect([1, 2, 3].combination(2).flatMap { $0 }).to(equal([[1, 2], [1, 3], [2, 3]].flatMap { $0 }))
                expect([1, 2, 3].combination(3).flatMap { $0 }).to(equal([[1, 2, 3]].flatMap { $0 }))
                expect([1, 2, 3].combination(0).flatMap { $0 }).to(equal([].compactMap { $0 }))
                expect([1, 2, 3].combination(5).flatMap { $0 }).to(equal([[]].flatMap { $0 }))
            }
        }
        
        describe(".repeatedCombination(num:)") {
            it("creates a new array containing the values returned by the block") {
                expect([1, 2, 3].repeatedCombination(1).flatMap { $0 }).to(equal([[1], [2], [3]].flatMap { $0 }))
                expect([1, 2, 3].repeatedCombination(2).flatMap { $0 }).to(equal([[1,1],[1,2],[1,3],[2,2],[2,3],[3,3]].flatMap { $0 }))
                expect([1, 2, 3].repeatedCombination(3).flatMap { $0 }).to(equal([[1,1,1],[1,1,2],[1,1,3],[1,2,2],[1,2,3],[1,3,3],[2,2,2],[2,2,3],[2,3,3],[3,3,3]].flatMap { $0 }))
                expect([1, 2, 3].repeatedCombination(4).flatMap { $0 }).to(equal([[1,1,1,1],[1,1,1,2],[1,1,1,3],[1,1,2,2],[1,1,2,3],[1,1,3,3],[1,2,2,2],[1,2,2,3],[1,2,3,3],[1,3,3,3], [2,2,2,2],[2,2,2,3],[2,2,3,3],[2,3,3,3],[3,3,3,3]].flatMap { $0 }))
                expect([1, 2, 3].repeatedCombination(0).flatMap { $0 }).to(equal([].compactMap { $0 }))
            }
        }
        
        describe(".dig(idxs:)") {
            it("extracts the nested value specified by the sequence of idx objects by calling dig at each step") {
                let arr = [[1, 2, 3], [3, 4, 5]]
                expect(arr.dig(1, 2)).to(equal(5))
                expect(arr.dig(1)).to(equal([3, 4, 5]))

                let result1: Int? = arr.dig(1, 2, 3)
                expect(result1).to(beNil())
                
                let result2: Int? = arr.dig(10, 2, 3)
                expect(result2).to(beNil())
            }
        }
        
        describe(".transpose()") {
            it("returns the transpose of current array") {
                let result: [[Int]] = [[1,2,3], [4,5,6]].tranpose()!
                let bool = result == [[1, 4], [2, 5], [3, 6]]
                expect(bool).to(beTrue())
            }
        }
        
        describe(".zip(arrays:)") {
            it("converts any arguments to arrays, then merges elements of self with corresponding elements from each argument") {
                let a = [4, 5, 6]
                let b = [7, 8, 9]
                
                let bool1 = [1, 2, 3].zip(a, b) == [[1, 4, 7], [2, 5, 8], [3, 6, 9]]
                expect(bool1).to(beTrue())
                
                let bool2 = [1, 2].zip(a, b) == [[1, 4, 7], [2, 5, 8]]
                expect(bool2).to(beTrue())
                
                let bool3 = a.zip([1, 2], [8]) == [[4, 1, 8]]
                expect(bool3).to(beTrue())
            }
        }
        
        describe(".rotate(count:)") {
            it("returns a new array by rotating self so that the element at count is the first element of the new array") {
                let a = [ "a", "b", "c", "d" ]
                expect(a.rotate).to(equal(["b", "c", "d", "a"]))
                expect(a).to(equal(["a", "b", "c", "d"]))
                expect(a.rotate(2)).to(equal(["c", "d", "a", "b"]))
                expect(a.rotate(-3)).to(equal(["b", "c", "d", "a"]))
            }
        }
    }
}
