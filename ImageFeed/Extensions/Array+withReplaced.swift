//
//  Array+withReplaced.swift
//  ImageFeed
//
//  Created by Дима on 03.07.2024.
//

import Foundation

extension Array {
    func withReplaced(itemAt index: Int, newValue: Element) -> [Element]? {
        guard index >= 0 && index < self.count else { return nil }
        var newArray = self
        newArray[index] = newValue
        return newArray
    }
}
