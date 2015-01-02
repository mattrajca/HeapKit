//
//  Graph.swift
//  HeapKit Tests
//
//  Copyright (c) 2014 Matt Rajca. All rights reserved.
//

import Foundation

struct Connection: Equatable, Hashable {
	let nodeA: Int
	let nodeB: Int
	
	var hashValue: Int {
		return 65536 * nodeA + nodeB
	}
}

func ==(lhs: Connection, rhs: Connection) -> Bool {
	return lhs.nodeA == rhs.nodeA && lhs.nodeB == rhs.nodeB
}

class Graph {
	private let nodes: Dictionary<Int, [Int]>
	private let weights: Dictionary<Connection, Int>
	
	init(nodes: Dictionary<Int, [Int]>, weights: Dictionary<Connection, Int>) {
		self.nodes = nodes
		self.weights = weights
	}
	
	func findShortestPaths(fromIndex sourceIndex: Int) -> Dictionary<Int, Int> {
		var visited = Dictionary<Int, Bool>()
		
		var distances = Dictionary<Int, Int>()
		distances[sourceIndex] = 0
		
		let heap = MinHeap<Int, Int>()
		heap.insert(sourceIndex, weight: 0)
		
		while !heap.isEmpty {
			let index = heap.removeTop()!
			visited[index] = true
			
			if let neighbors = nodes[index] {
				for neighborIndex in neighbors {
					if visited[neighborIndex] == nil {
						let weight = weights[Connection(nodeA: index, nodeB: neighborIndex)]!
						let newDistance = distances[index]! + weight
						
						if let currentDistance = distances[neighborIndex] {
							if newDistance < currentDistance {
								distances[neighborIndex] = newDistance
								heap.update(neighborIndex, weight: newDistance)
							}
						}
						else {
							distances[neighborIndex] = newDistance
							heap.insert(neighborIndex, weight: newDistance)
						}
					}
				}
			}
		}
		
		return distances
	}
}
