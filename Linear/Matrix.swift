//
//  Matrix.swift
//  Linear
//
//  Created by joshua kaunert on 4/9/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import UIKit

public struct Matrix<Member> {
    internal var rowBacking: [[Member]]
}

extension Matrix: ExpressibleByArrayLiteral {
    public init() {
        self.rowBacking = []
    }
    
    public init(_ rows: [[Member]]) {
        self.init(RowView(rows))
    }
    
    public init(arrayLiteral elements: [Member]...) {
        self.init(elements)
    }
    
    public init(_ rows: RowView<Member>) {
        self.rowBacking = rows.matrix.rowBacking
    }
    
    public init(_ columns: ColumnView<Member>) {
        self.rowBacking = columns.matrix.rowBacking
    }
}

extension Matrix: Sequence {
    public subscript(row: Int, column: Int) -> Member {
        get {
            return rowBacking[row][column]
        }
        set {
            rowBacking[row][column] = newValue
        }
    }
    
    public var rows: RowView<Member> {
        get {
            return RowView(matrix: self)
        }
        set {
            self = Matrix(newValue)
        }
    }
    
    public var columns: ColumnView<Member> {
        get {
            return ColumnView(matrix: self)
        }
        set {
            self = Matrix(newValue)
        }
    }
}

extension Matrix: Collection {
    public func index(after i: Int) -> Int {
        return i+1
    }
    
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return rows.count * columns.count
    }
    
    public func positionWithIndex(index: Int) -> (row: Int, column: Int) {
        return (row: index / columns.count, column: index % columns.count)
    }
    
    public subscript(index: Int) -> Member {
        get {
            let position = positionWithIndex(index: index)
            return self[position.row, position.column]
        }
        set {
            let position = positionWithIndex(index: index)
            self[position.row, position.column] = newValue
        }
    }
}

extension Matrix: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return rows.description
    }
    
    public var debugDescription: String {
        return rows.debugDescription
    }
}



extension Matrix {
    public func map<T>(transform: (Member) throws -> T) rethrows -> Matrix<T> {
        return Matrix<T>(RowView(try self.rows.map{ try $0.map(transform) }))
    }
    //FIXME: last one!
    ///https://stackoverflow.com/questions/44991116/swift-generics-cannot-convert-value-of-type-to-expected-argument-type
    public func map<T>(transform: (Member, _ row: Int, _ column: Int) throws -> T) rethrows -> Matrix<T> {
        
        let matrix = try rows.enumerated().map{ (r, columns) in
            try columns.enumerated().map{ (c, value) in
                try transform(value, r, c) as! Matrix<T>
            }
        }
        return Matrix<T>(RowView(matrix: (matrix.first?.first!)!))
    }
    public func zipWith<U, V>(matrix: Matrix<U>, transform: (Member, U) -> V) -> Matrix<V> {
        return Matrix<V>(RowView(zip(self.rows, matrix.rows).map{ zip($0, $1).map(transform) }))
    }
}

extension Matrix {
    public var isSquare: Bool {
        return rows.count == columns.count
    }
    
    public var transpose: Matrix {
        return Matrix(RowView(columns))
    }
}

extension Matrix where Member: ExpressibleByIntegerLiteral {
    public static func diagonal(dimensions: MatrixDimensions, diagonalValue: Member, defaultValue: Member) -> Matrix {
        var matrix = Matrix(dimensions: dimensions, repeatedValue: defaultValue)
        for i in 0..<Swift.min(dimensions.width, dimensions.height) {
            matrix[i, i] = diagonalValue
        }
        return matrix
    }
    
    public static func diagonal(dimensions: MatrixDimensions) -> Matrix {
        return diagonal(dimensions: dimensions, diagonalValue: 1, defaultValue: 0)
    }
    
    public static func identity(size: Int) -> Matrix {
        return diagonal(dimensions: (size, size))
    }
}

public typealias MatrixDimensions = (width: Int, height: Int)

extension Matrix {
    public init(dimensions: MatrixDimensions, repeatedValue: Member) {
        self.rowBacking = Array(repeating:
            Array(repeating: repeatedValue, count: dimensions.width), count: dimensions.height
        )
    }
    
    public var dimensions: MatrixDimensions {
        return (width: columns.count, height: rows.count)
    }
}

public func ==(lhs: MatrixDimensions, rhs: MatrixDimensions) -> Bool {
    return lhs.width == rhs.width && lhs.height == rhs.height
}







