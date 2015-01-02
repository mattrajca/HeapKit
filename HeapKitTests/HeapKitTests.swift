//
//  HeapKitTests.swift
//  HeapKit Tests
//
//  Copyright (c) 2014 Matt Rajca. All rights reserved.
//

import XCTest

class HeapKitTests: XCTestCase {
	private func _loadGraph() -> Graph {
		let bundle = NSBundle(forClass: HeapKitTests.self)
		let graphURL = bundle.URLForResource("dijkstraData", withExtension: "txt")
		XCTAssertNotNil(graphURL, "Cannot find the graph data file")
		
		let graphString_ = NSString(contentsOfURL: graphURL!, encoding: NSASCIIStringEncoding, error: nil)
		XCTAssertNotNil(graphString_, "Cannot load the graph data file")
		
		var nodes = Dictionary<Int, [Int]>()
		var weights = Dictionary<Connection, Int>()
		
		if let graphString = graphString_ as? String {
			graphString.enumerateLines { (line, stop) in
				let columns = line.componentsSeparatedByString("\t")
				let index = columns.first!.toInt()!
				var adjacentIndices = [Int]()
				
				for n in 1..<columns.count {
					let column = columns[n]
					
					if column.lengthOfBytesUsingEncoding(NSASCIIStringEncoding) == 0 {
						continue
					}
					
					let indexWeightTuple = column.componentsSeparatedByString(",")
					XCTAssertEqual(indexWeightTuple.count, 2, "Should have a pair")
					
					let otherIndex = indexWeightTuple.first!.toInt()!
					let weight = indexWeightTuple.last!.toInt()!
					
					adjacentIndices.append(otherIndex)
					
					// Make the connection
					weights[Connection(nodeA: index, nodeB: otherIndex)] = weight
				}
				
				nodes[index] = adjacentIndices
			}
		}
		
		return Graph(nodes: nodes, weights: weights)
	}
	
	private func _loadNumberStream() -> [Int] {
		let bundle = NSBundle(forClass: HeapKitTests.self)
		let URL = bundle.URLForResource("Median", withExtension: "txt")
		XCTAssertNotNil(URL, "Cannot find the Median data file")
		
		let string_ = NSString(contentsOfURL: URL!, encoding: NSASCIIStringEncoding, error: nil)
		XCTAssertNotNil(string_, "Cannot load the Median data file")
		
		var numbers = [Int]()
		
		if let string = string_ as? String {
			string.enumerateLines { (line, stop) in
				numbers.append(line.toInt()!)
			}
		}
		
		return numbers
	}
	
	func testDijkstra() {
		let graph = _loadGraph()
		let paths = graph.findShortestPaths(fromIndex: 1)
		
		let indices = [7, 37, 59, 82, 99, 115, 133, 165, 188, 197]
		let correctValues = [2599, 2610, 2947, 2052, 2367, 2399, 2029, 2442, 2505, 3068]
		let values = indices.map { index in paths[index]! }
		
		XCTAssertEqual(values, correctValues, "Incorrect distances")
	}
	
	func testMedianMaintenance() {
		let lowHeap = MaxHeap<Int, Int>()
		let highHeap = MinHeap<Int, Int>()
		let numberStream = _loadNumberStream()
		var medians = [Int]()
		
		for number in numberStream {
			if lowHeap.isEmpty && highHeap.isEmpty {
				lowHeap.insert(number, weight: number)
			}
			else if !lowHeap.isEmpty && !highHeap.isEmpty {
				if number < lowHeap.findTop()! {
					lowHeap.insert(number, weight: number)
				}
				else if number > highHeap.findTop()! {
					highHeap.insert(number, weight: number)
				}
				else {
					lowHeap.insert(number, weight: number)
				}
			}
			else if !lowHeap.isEmpty {
				if number < lowHeap.findTop()! {
					lowHeap.insert(number, weight: number)
				}
				else {
					highHeap.insert(number, weight: number)
				}
			}
			else {
				fatalError("We should never get here")
			}
			
			let imbalance = lowHeap.count - highHeap.count
			if imbalance > 1 {
				let value = lowHeap.removeTop()!
				highHeap.insert(value, weight: value)
			}
			else if imbalance <= -1 {
				let value = highHeap.removeTop()!
				lowHeap.insert(value, weight: value)
			}
			
			medians.append(lowHeap.findTop()!)
		}
		
		let medianSum = medians.reduce(0, combine: { (u, t) in u + t })
		
		XCTAssertEqual(medianSum % 10000, 1213, "Incorrect sum")
	}
}
