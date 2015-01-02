//
//  Heap.swift
//
//  Copyright (c) 2014 Matt Rajca. All rights reserved.
//

import Foundation

public class MinHeap<T: Hashable, W: Comparable> : Heap<T, W> {
	override func isWeight(weight: W, betterThanWeight otherWeight: W) -> Bool {
		return weight < otherWeight
	}
}

public class MaxHeap<T: Hashable, W: Comparable> : Heap<T, W> {
	override func isWeight(weight: W, betterThanWeight otherWeight: W) -> Bool {
		return weight > otherWeight
	}
}

public class Heap<T: Hashable, W: Comparable> {
	private var array = [T]()
	private var weights = [W]()
	private var elementsToPositions = Dictionary<T, Int>()
	
	/* For subclasses */
	func isWeight(weight: W, betterThanWeight otherWeight: W) -> Bool {
		fatalError("This method must be overridden") 
	}
	
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
			
			if isWeight(weights[lastIndex], betterThanWeight: weights[parentIndex]) {
				_swapElements(parentIndex, lastIndex)
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
			
			let leftChild: W? = leftChildIndex < weights.count ? weights[leftChildIndex] : nil
			let rightChild: W? = rightChildIndex < weights.count ? weights[rightChildIndex] : nil
			
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
			
			if isWeight(weights[smallerChildIndex], betterThanWeight: weights[startIndex]) {
				_swapElements(smallerChildIndex, startIndex)
				startIndex = smallerChildIndex
			}
			else {
				return
			}
		}
	}
	
	private func _swapElements(a: Int, _ b: Int) {
		let elementA = array[a]
		let elementB = array[b]
		
		let weightA = weights[a]
		let weightB = weights[b]
		
		array[a] = elementB
		array[b] = elementA
		
		weights[a] = weightB
		weights[b] = weightA
		
		elementsToPositions[elementA] = b
		elementsToPositions[elementB] = a
	}
	
	public var isEmpty: Bool {
		return array.count == 0
	}
	
	public func insert(element: T, weight: W) {
		array.append(element)
		weights.append(weight)
		elementsToPositions[element] = array.count - 1
		
		_heapifyUp(array.count - 1)
	}
	
	public func update(element: T, weight: W) {
		if let index = elementsToPositions[element] {
			weights[index] = weight
			_heapifyUp(index)
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
		weights[0] = weights[weights.count - 1]
		array.removeAtIndex(array.count - 1)
		weights.removeAtIndex(weights.count - 1)
		
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
	var heap = MinHeap<Int, Int>()
	
	for element in array {
		heap.insert(element, weight: element)
	}
	
	for n in 0..<array.count {
		array[n] = heap.removeMinimum()!
	}
}
