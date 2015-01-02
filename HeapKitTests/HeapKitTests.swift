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
	
	func testDijkstra() {
		let _graph = _loadGraph()
		let paths = _graph.findShortestPaths(fromIndex: 1)
		
		let indices = [7, 37, 59, 82, 99, 115, 133, 165, 188, 197]
		let correctValues = [2599, 2610, 2947, 2052, 2367, 2399, 2029, 2442, 2505, 3068]
		let values = indices.map { index in paths[index]! }
		
		XCTAssertEqual(values, correctValues, "Incorrect distances")
	}
}
