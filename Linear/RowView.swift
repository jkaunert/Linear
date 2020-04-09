//
//  RowView.swift
//  Linear
//
//  Created by joshua kaunert on 4/9/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import UIKit

public struct RowView<Member> {
    internal var matrix: Matrix<Member>
    
    internal init(matrix: Matrix<Member>) {
        self.matrix = matrix
    }
}

extension RowView: ExpressibleByArrayLiteral {
    public init() {
        self.matrix = Matrix()
    }
    
    public init<S: Sequence>(_ rows: S) where S.Iterator.Element == [Member] {
        self.init()
        append(rows as! [Member])
    }
    
    public init(arrayLiteral elements: [Member]...) {
        self.init(elements)
    }
}

extension RowView: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return Array(arrayLiteral: self).description
    }
    
    public var debugDescription: String {
        return Array(arrayLiteral: self).debugDescription
    }
}

extension RowView: MutableCollection, RangeReplaceableCollection, Sequence, Collection {
    public func index(after i: Int) -> Int {
        return i+1
    }
    
    public mutating func replaceRange<C : Collection>(subRange: Range<Int>, with newElements: C) where C.Iterator.Element == [Member] {
        let expectedCount = matrix.count > 0 ? matrix.columns.count : (newElements.first?.count ?? 0)
        newElements.forEach{ row in
            precondition(row.count == expectedCount, "Incompatable vector size.")
        }
        replaceRange(subRange: subRange, with: newElements)
    }
    
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return matrix.rowBacking.count
    }
    
    public subscript(index: Int) -> [Member] {
        get {
            return matrix.rowBacking[index]
        }
        set {
            precondition(newValue.count == matrix.columns.count, "Incompatible vector size.")
            matrix.rowBacking[index] = newValue
        }
    }
}

