//
//  Heap.swift
//
//  Copyright (c) 2014 Matt Rajca. All rights reserved.
//

import Foundation

public class Heap<T where T: Comparable, T: Hashable> {
	private var array = [T]()
	private var elementsToPositions = Dictionary<T, Int>()
	
	private func _parentIndex(index: Int) -> Int {
		return (index - 1) / 2
	}
	
	private func _leftChildIndex(index: Int) -> Int {
		return index * 2 + 1
	}
	
	private func _rightChildIndex(index: Int) -> Int {
		return index * 2 + 2
	}
	
	private func _heapifyUp(index: Int) {
		var lastIndex = index
		
		while lastIndex > 0 {
			let parentIndex = _parentIndex(lastIndex)
			
			if array[parentIndex] > array[lastIndex] {
				_swapElementAtIndex(parentIndex, withElementAtIndex: lastIndex)
				lastIndex = parentIndex
			}
			else {
				return
			}
		}
	}
	
	private func _heapifyDown(index: Int) {
		var startIndex = index
		
		while true {
			let leftChildIndex = _leftChildIndex(startIndex)
			let rightChildIndex = _rightChildIndex(startIndex)
			
			let leftChild: T? = leftChildIndex < array.count ? array[leftChildIndex] : nil
			let rightChild: T? = rightChildIndex < array.count ? array[rightChildIndex] : nil
			
			var smallerChildIndex: Int
			
			if leftChild != nil && rightChild == nil {
				smallerChildIndex = leftChildIndex
			}
			else if leftChild != nil && rightChild != nil {
				smallerChildIndex = leftChild < rightChild ? leftChildIndex : rightChildIndex
			}
			else {
				// Both children are nil
				return
			}
			
			if array[startIndex] > array[smallerChildIndex] {
				_swapElementAtIndex(smallerChildIndex, withElementAtIndex: startIndex)
				startIndex = smallerChildIndex
			}
			else {
				return
			}
		}
	}
	
	private func _swapElementAtIndex(a: Int, withElementAtIndex b: Int) {
		let elementA = array[a]
		let elementB = array[b]
		
		array[a] = elementB
		array[b] = elementA
		
		elementsToPositions[elementA] = b
		elementsToPositions[elementB] = a
	}
	
	public func count() -> Int {
		return array.count
	}
	
	public func insert(element: T) {
		array.append(element)
		elementsToPositions[element] = array.count - 1
		
		_heapifyUp(array.count - 1)
	}
	
	public func update(element: T) {
		if let position = elementsToPositions[element] {
			_heapifyUp(position)
		}
	}
	
	public func findMinimum() -> T? {
		return array.first
	}
	
	public func removeMinimum() -> T? {
		if array.count == 0 {
			return nil
		}
		
		let minimum = array.first!
		array[0] = array[array.count - 1]
		array.removeAtIndex(array.count - 1)
		
		elementsToPositions.removeValueForKey(minimum)
		
		if array.count == 0 {
			return minimum
		}
		
		elementsToPositions[array[0]] = 0
		_heapifyDown(0)
		
		return minimum
	}
}

public func heapSort(inout array: [Int]) {
	var heap = Heap<Int>()
	
	for element in array {
		heap.insert(element)
	}
	
	for n in 0..<array.count {
		array[n] = heap.removeMinimum()!
	}
}
