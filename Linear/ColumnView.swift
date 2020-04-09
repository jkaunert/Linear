//
//  ColumnView.swift
//  Linear
//
//  Created by joshua kaunert on 4/9/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import UIKit

public struct ColumnView<Member> {
    internal var matrix: Matrix<Member>
    
    internal init(matrix: Matrix<Member>) {
        self.matrix = matrix
    }
}

extension ColumnView: ExpressibleByArrayLiteral {
    public init() {
        self.matrix = Matrix()
    }
    
    public init<S: Sequence>(_ columns: S) where S.Iterator.Element == [Member] {
        self.init()
        self.append(contentsOf:columns)
    }
    
    public init(arrayLiteral elements: [Member]...) {
        self.init(elements)
    }
}

extension ColumnView: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return Array(arrayLiteral: self).description
    }
    
    public var debugDescription: String {
        return Array(arrayLiteral: self).debugDescription
    }
}

extension ColumnView: MutableCollection, RangeReplaceableCollection {
    public func index(after i: Int) -> Int {
        return i+1
    }
    
    public mutating func replaceRange<C: Collection>(subRange: Range<Int>, with newElements: C) where C.Iterator.Element == [Member] {
        
        // Verify size
        let expectedCount = matrix.count > 0 ? matrix.rows.count : (newElements.first?.count ?? 0)
        newElements.forEach { column in
            precondition(column.count == expectedCount, "Incompatable vector size.")
        }
        if matrix.count == 0 { matrix.rowBacking = Array(repeating: Array(), count: expectedCount) }
        
        // Replace range
        matrix.rowBacking.indices.forEach { index in
            replaceRange(subRange: subRange, with: newElements.map { column in
                column[index] as! [Member]
            })
        }
    }
    
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return matrix.rowBacking.first?.count ?? 0
    }
    
    public subscript(index: Int) -> [Member] {
        get {
            return matrix.rows.indices.map{ i in matrix[i, index] }
        }
        set {
            precondition(newValue.count == matrix.rows.count, "Incompatible vector size.")
            zip(matrix.rows.indices, newValue).forEach { (i, v) in matrix[i, index] = v }
        }
    }
}
