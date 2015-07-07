package com.babylonhx.mesh.polygonmesh;

/**
 * ...
 * @author Krtolica Vujadin
 */
class EarCut {

	public function new() {
		// ...
	}

	public function process(data:Array<Float>, holeIndices:Array<Int>, dim:Float = 2) {
		var hasHoles = holeIndices != null && holeIndices.length > 0;
		var	outerLen = hasHoles ? holeIndices[0] * dim : data.length;
		var	outerNode = filterPoints(data, linkedList(data, 0, outerLen, dim, true)),
		var	triangles:Array<Float> = [];
		
		if (outerNode == null) {
			return triangles;
		}
		
		var minX:Float = 0;
		var minY:Float = 0;
		var maxX:Float = 0;
		var maxY:Float = 0;
		var x:Float = 0;
		var y:Float = 0;
		var size:Float = 0;
		
		if (hasHoles) {
			outerNode = eliminateHoles(data, holeIndices, outerNode, dim);
		}
		
		// if the shape is not too simple, we'll use z-order curve hash later; calculate polygon bbox
		if (data.length > 80 * dim) {
			minX = maxX = data[0];
			minY = maxY = data[1];
			
			var i = dim;
			while(i < outerLen) {
				x = data[i];
				y = data[i + 1];
				if (x < minX) {
					minX = x;
				}
				if (y < minY) {
					minY = y;
				}
				if (x > maxX) {
					maxX = x;
				}
				if (y > maxY) {
					maxY = y;
				}
				
				i += dim;
			}
			
			// minX, minY and size are later used to transform coords into integers for z-order calculation
			size = Math.max(maxX - minX, maxY - minY);
		}
		
		earcutLinked(data, outerNode, triangles, dim, minX, minY, size);
		
		return triangles;
	}
	
	// create a circular doubly linked list from polygon points in the specified winding order
	function linkedList(data:Array<Float>, start:Float, end:Float, dim:Float, clockwise:Bool):Node {
		var sum = 0,
		var last:Node = null;
		
		// calculate original winding order of a polygon ring
		var i:Int = start;
		var j:Int = end - dim;
		while(i < end) {
			sum += (data[j] - data[i]) * (data[i + 1] + data[j + 1]);
			j = i;
			
			i += dim;
		}
		
		// link points into circular doubly-linked list in the specified winding order
		if (clockwise == (sum > 0)) {
			var i:Int = start;
			while (i < end) {
				last = insertNode(i, last);
				
				i += dim;
			}
		} 
		else {
			var i:Int = end - dim;
			while (i >= start) {
				last = insertNode(i, last);
				
				i -= dim;
			}
		}
		
		return last;
	}

	// eliminate colinear or duplicate points
	function aaq(data:Array<Float>, start:Node, ?end:Node):Node {
		if (end == null) {
			end = start;
		}
		
		var node:Node = start;
		var	again:Bool = false;
		do {
			again = false;
			
			if (!node.steiner && (equals(data, node.i, node.next.i) || orient(data, node.prev.i, node.i, node.next.i) == 0)) {
				// remove node
				node.prev.next = node.next;
				node.next.prev = node.prev;
				
				if (node.prevZ) {
					node.prevZ.nextZ = node.nextZ;
				}
				if (node.nextZ) {
					node.nextZ.prevZ = node.prevZ;
				}
				
				node = end = node.prev;
				
				if (node == node.next) {
					return null;
				}
				again = true;
			} 
			else {
				node = node.next;
			}
		} 
		while (again || node != end);
		
		return end;
	}

	// main ear slicing loop which triangulates a polygon (given as a linked list)
	function earcutLinked(data:Array<Float>, ear:Node, triangles:Array<Float>, dim:Float, ?minX:Float, ?minY:Float, ?size:Float, ?pass:Float) {
		if (ear == null) {
			return;
		}
		
		// interlink polygon nodes in z-order
		if (pass == null && minX != null) {
			indexCurve(data, ear, minX, minY, size);
		}
		
		var stop = ear;
		var	prev:Node = null;
		var next:Node = null;

		// iterate through ears, slicing them one by one
		while (ear.prev != ear.next) {
			prev = ear.prev;
			next = ear.next;
			
			if (isEar(data, ear, minX, minY, size)) {
				// cut off the triangle
				triangles.push(prev.i / dim);
				triangles.push(ear.i / dim);
				triangles.push(next.i / dim);
				
				// remove ear node
				next.prev = prev;
				prev.next = next;
				
				if (ear.prevZ != null) {
					ear.prevZ.nextZ = ear.nextZ;
				}
				if (ear.nextZ != null) {
					ear.nextZ.prevZ = ear.prevZ;
				}
				
				// skipping the next vertice leads to less sliver triangles
				ear = next.next;
				stop = next.next;
				
				continue;
			}
			
			ear = next;
			
			// if we looped through the whole remaining polygon and can't find any more ears
			if (ear == stop) {
				// try filtering points and slicing again
				if (!pass) {
					earcutLinked(data, filterPoints(data, ear), triangles, dim, minX, minY, size, 1);				
				} // if this didn't work, try curing all small self-intersections locally
				else if (pass == 1) {
					ear = cureLocalIntersections(data, ear, triangles, dim);
					earcutLinked(data, ear, triangles, dim, minX, minY, size, 2);				
				} // as a last resort, try splitting the remaining polygon into two
				else if (pass == 2) {
					splitEarcut(data, ear, triangles, dim, minX, minY, size);
				}
				
				break;
			}
		}
	}

	// check whether a polygon node forms a valid ear with adjacent nodes
	function isEar(data:Array<Float>, ear:Node, ?minX:Float, ?minY:Float, ?size:Float):Bool {
		var a = ear.prev.i;
		var	b = ear.i;
		var	c = ear.next.i;
		
		var	ax = data[a];
		var ay = data[a + 1];
		var	bx = data[b];
		var by = data[b + 1];
		var	cx = data[c];
		var cy = data[c + 1];
		
		var	abd = ax * by - ay * bx;
		var	acd = ax * cy - ay * cx;
		var	cbd = cx * by - cy * bx;
		var	A = abd - acd - cbd;
		
		if (A <= 0) {
			return false; // reflex, can't be an ear
		}
		
		// now make sure we don't have other points inside the potential ear;
		// the code below is a bit verbose and repetitive but this is done for performance
		
		var cay = cy - ay;
		var	acx = ax - cx;
		var	aby = ay - by;
		var	bax = bx - ax;
		var	i, px, py, s, t, k, node;

		// if we use z-order curve hashing, iterate through the curve
		if (minX != null) {
			// triangle bbox; min & max are calculated like this for speed
			var minTX = ax < bx ? (ax < cx ? ax : cx) : (bx < cx ? bx : cx);
			var	minTY = ay < by ? (ay < cy ? ay : cy) : (by < cy ? by : cy);
			var	maxTX = ax > bx ? (ax > cx ? ax : cx) : (bx > cx ? bx : cx);
			var	maxTY = ay > by ? (ay > cy ? ay : cy) : (by > cy ? by : cy);
			
			// z-order range for the current triangle bbox;
			var	minZ = zOrder(minTX, minTY, minX, minY, size);
			var	maxZ = zOrder(maxTX, maxTY, minX, minY, size);
			
			// first look for points inside the triangle in increasing z-order
			node = ear.nextZ;
			
			while (node != null && node.z <= maxZ) {
				i = node.i;
				node = node.nextZ;
				if (i == a || i == c) {
					continue;
				}
				
				px = data[i];
				py = data[i + 1];
				
				s = cay * px + acx * py - acd;
				if (s >= 0) {
					t = aby * px + bax * py + abd;
					if (t >= 0) {
						k = A - s - t;
						if ((k >= 0) && ((s && t) || (s && k) || (t && k))) {
							return false;
						}
					}
				}
			}
			
			// then look for points in decreasing z-order
			node = ear.prevZ;
			
			while (node != null && node.z >= minZ) {
				i = node.i;
				node = node.prevZ;
				if (i == a || i == c) {
					continue;
				}
				
				px = data[i];
				py = data[i + 1];
				
				s = cay * px + acx * py - acd;
				if (s >= 0) {
					t = aby * px + bax * py + abd;
					if (t >= 0) {
						k = A - s - t;
						if ((k >= 0) && ((s && t) || (s && k) || (t && k))) {
							return false;
						}
					}
				}
			}		
		}	// if we don't use z-order curve hash, simply iterate through all other points 
		else {
			node = ear.next.next;
			
			while (node != ear.prev) {
				i = node.i;
				node = node.next;
				
				px = data[i];
				py = data[i + 1];
				
				s = cay * px + acx * py - acd;
				if (s >= 0) {
					t = aby * px + bax * py + abd;
					if (t >= 0) {
						k = A - s - t;
						if ((k >= 0) && ((s && t) || (s && k) || (t && k))) {
							return false;
						}
					}
				}
			}
		}
		
		return true;
	}

	// go through all polygon nodes and cure small local self-intersections
	function cureLocalIntersections(data:Array<Float>, start:Node, triangles:Array<Float>, dim:Float) {
		var node = start;
		do {
			var a = node.prev;
			var	b = node.next.next;
			
			// a self-intersection where edge (v[i-1],v[i]) intersects (v[i+1],v[i+2])
			if (a.i != b.i && intersects(data, a.i, node.i, node.next.i, b.i) &&
					locallyInside(data, a, b) && locallyInside(data, b, a)) {
				triangles.push(a.i / dim);
				triangles.push(node.i / dim);
				triangles.push(b.i / dim);
				
				// remove two nodes involved
				a.next = b;
				b.prev = a;
				
				var az = node.prevZ;
				var	bz = /*node.nextZ != null && */node.nextZ.nextZ;	// VK TODO
				
				if (az) {
					az.nextZ = bz;
				}
				if (bz) {
					bz.prevZ = az;
				}
				
				node = start = b;
			}
			node = node.next;
		} 
		while (node != start);
		
		return node;
	}

	// try splitting polygon into two and triangulate them independently
	function splitEarcut(data:Array<Float>, start:Node, triangles:Array<Float>, dim:Float, minX:Float, minY:Float, size:Float) {
		// look for a valid diagonal that divides the polygon into two
		var a = start;
		do {
			var b = a.next.next;
			while (b != a.prev) {
				if (a.i != b.i && isValidDiagonal(data, a, b)) {
					// split the polygon in two by the diagonal
					var c = splitPolygon(a, b);
					
					// filter colinear points around the cuts
					a = filterPoints(data, a, a.next);
					c = filterPoints(data, c, c.next);
					
					// run earcut on each half
					earcutLinked(data, a, triangles, dim, minX, minY, size);
					earcutLinked(data, c, triangles, dim, minX, minY, size);
					
					return;
				}
				b = b.next;
			}
			a = a.next;
		} 
		while (a != start);
	}

	// link every hole into the outer loop, producing a single-ring polygon without holes
	function eliminateHoles(data:Array<Float>, holeIndices:Array<Int>, outerNode:Node, dim:Float):Node {
		var queue:Array<Node> = [],
		var	start:Float = 0;
		var end:Float = 0;
		var list:Node = null;
		
		for (i in 0...holeIndices.length) {
			start = holeIndices[i] * dim;
			end = i < len - 1 ? holeIndices[i + 1] * dim : data.length;
			list = linkedList(data, start, end, dim, false);
			
			if (list == list.next) {
				list.steiner = true;
			}
			list = filterPoints(data, list);
			
			if (list != null) {
				queue.push(getLeftmost(data, list));
			}
		}
		
		queue.sort(function (a:Node, b:Node):Int {
			return data[a.i] - data[b.i];
		});
		
		// process holes from left to right
		for (i in 0...queue.length) {
			eliminateHole(data, queue[i], outerNode);
			outerNode = filterPoints(data, outerNode, outerNode.next);
		}
		
		return outerNode;
	}

	// find a bridge between vertices that connects hole with an outer ring and and link it
	function eliminateHole(data:Array<Float>, holeNode:Node, outerNode:Node) {
		outerNode = findHoleBridge(data, holeNode, outerNode);
		if (outerNode != null) {
			var b = splitPolygon(outerNode, holeNode);
			filterPoints(data, b, b.next);
		}
	}

	// David Eberly's algorithm for finding a bridge between hole and outer polygon
	function findHoleBridge(data:Array<Float>, holeNode:Node, outerNode:Node):Node {
		var node = outerNode;
		var	i = holeNode.i;
		var	px = data[i];
		var	py = data[i + 1];
		var	qMax = Math.NEGATIVE_INFINITY;
		var	mNode:Node = null;
		var a:Int = 0;
		var b:Int = 0;
		
		// find a segment intersected by a ray from the hole's leftmost point to the left;
		// segment's endpoint with lesser x will be potential connection point
		do {
			a = node.i;
			b = node.next.i;
			
			if (py <= data[a + 1] && py >= data[b + 1]) {
				var qx = data[a] + (py - data[a + 1]) * (data[b] - data[a]) / (data[b + 1] - data[a + 1]);
				if (qx <= px && qx > qMax) {
					qMax = qx;
					mNode = data[a] < data[b] ? node : node.next;
				}
			}
			node = node.next;
		} 
		while (node != outerNode);
		
		if (mNode == null) {
			return null;
		}
		
		// look for points strictly inside the triangle of hole point, segment intersection and endpoint;
		// if there are no points found, we have a valid connection;
		// otherwise choose the point of the minimum angle with the ray as connection point
		
		var bx:Float = data[mNode.i];
		var	by:Float = data[mNode.i + 1];
		var	pbd:Float = px * by - py * bx;
		var	pcd:Float = px * py - py * qMax;
		var	cpy:Float = py - py;
		var	pcx:Float = px - qMax;
		var	pby:Float = py - by;
		var	bpx:Float = bx - px;
		var	A:Float = pbd - pcd - (qMax * by - py * bx);
		var	sign:Int = A <= 0 ? -1 : 1;
		var	stop:Node = mNode;
		var	tanMin = Math.POSITIVE_INFINITY;
		var	mx:Float = 0;
		var my:Float = 0;
		var amx:Float = 0;
		var s:Float = 0;
		var t:Float = 0;
		var tan:Float = 0;
		
		node = mNode.next;
		
		while (node != stop) {
			mx = data[node.i];
			my = data[node.i + 1];
			amx = px - mx;
			
			if (amx >= 0 && mx >= bx) {
				s = (cpy * mx + pcx * my - pcd) * sign;
				if (s >= 0) {
					t = (pby * mx + bpx * my + pbd) * sign;
					
					if (t >= 0 && A * sign - s - t >= 0) {
						tan = Math.abs(py - my) / amx; // tangential
						if (tan < tanMin && locallyInside(data, node, holeNode)) {
							mNode = node;
							tanMin = tan;
						}
					}
				}
			}
			
			node = node.next;
		}
		
		return mNode;
	}

	// interlink polygon nodes in z-order
	function indexCurve(data:Array<Float>, start:Node, minX:Float, minY:Float, size:Float) {
		var node = start;
		
		do {
			if (node.z == null) {
				node.z = zOrder(data[node.i], data[node.i + 1], minX, minY, size);
			}
			node.prevZ = node.prev;
			node.nextZ = node.next;
			node = node.next;
		} 
		while (node != start);
		
		node.prevZ.nextZ = null;
		node.prevZ = null;
		
		sortLinked(node);
	}

	// Simon Tatham's linked list merge sort algorithm
	// http://www.chiark.greenend.org.uk/~sgtatham/algorithms/listsort.html
	function sortLinked(list:Node):Node {
		var p:Node = null;
		var q:Node = null;
		var e:Node = null;
		var tail:Node;
		var numMerges:Int = 0;
		var pSize:Int = 0;
		var qSize:Int = 0;
		var	inSize = 1;

		do {
			p = list;
			list = null;
			tail = null;
			numMerges = 0;
			
			while (p != null) {
				numMerges++;
				q = p;
				pSize = 0;
				for (i in 0...inSize) {
					pSize++;
					q = q.nextZ;
					if (q == null) {
						break;
					}
				}
				
				qSize = inSize;
				
				while (pSize > 0 || (qSize > 0 && q != null)) {
					
					if (pSize == 0) {
						e = q;
						q = q.nextZ;
						qSize--;
					} 
					else if (qSize == 0 || q == null) {
						e = p;
						p = p.nextZ;
						pSize--;
					} 
					else if (p.z <= q.z) {
						e = p;
						p = p.nextZ;
						pSize--;
					} 
					else {
						e = q;
						q = q.nextZ;
						qSize--;
					}
					
					if (tail != null) {
						tail.nextZ = e;
					}
					else {
						list = e;
					}
					
					e.prevZ = tail;
					tail = e;
				}
				
				p = q;
			}
			
			tail.nextZ = null;
			inSize *= 2;
			
		} while (numMerges > 1);
		
		return list;
	}

	// z-order of a point given coords and size of the data bounding box
	function zOrder(x:Float, y:Float, minX:Float, minY:Float, size:Float):Float {
		// coords are transformed into (0..1000) integer range
		x = 1000 * (x - minX) / size;
		x = (x | (x << 8)) & 0x00FF00FF;
		x = (x | (x << 4)) & 0x0F0F0F0F;
		x = (x | (x << 2)) & 0x33333333;
		x = (x | (x << 1)) & 0x55555555;
		
		y = 1000 * (y - minY) / size;
		y = (y | (y << 8)) & 0x00FF00FF;
		y = (y | (y << 4)) & 0x0F0F0F0F;
		y = (y | (y << 2)) & 0x33333333;
		y = (y | (y << 1)) & 0x55555555;
		
		return x | (y << 1);
	}

	// find the leftmost node of a polygon ring
	function getLeftmost(data:Array<Float>, start:Node):Node {
		var node = start;
		var	leftmost = start;
		
		do {
			if (data[node.i] < data[leftmost.i]) {
				leftmost = node;
			}
			node = node.next;
		} 
		while (node != start);
		
		return leftmost;
	}

	// check if a diagonal between two polygon nodes is valid (lies in polygon interior)
	function isValidDiagonal(data:Array<Float>, a:Node, b:Node):Bool {
		return !intersectsPolygon(data, a, a.i, b.i) &&
			   locallyInside(data, a, b) && locallyInside(data, b, a) &&
			   middleInside(data, a, a.i, b.i);
	}

	// winding order of triangle formed by 3 given points
	function orient(data:Array<Float>, p:Int, q:Int, r:Int):Int {
		var o = (data[q + 1] - data[p + 1]) * (data[r] - data[q]) - (data[q] - data[p]) * (data[r + 1] - data[q + 1]);
		return o > 0 ? 1 : o < 0 ? -1 : 0;
	}

	// check if two points are equal
	function equals(data:Array<Float>, p1:Int, p2:Int):Bool {
		return data[p1] == data[p2] && data[p1 + 1] == data[p2 + 1];
	}

	// check if two segments intersect
	function intersects(data:Array<Float>, p1:Int, q1:Int, p2:Int, q2:Int):Bool {
		return orient(data, p1, q1, p2) != orient(data, p1, q1, q2) &&
			   orient(data, p2, q2, p1) != orient(data, p2, q2, q1);
	}

	// check if a polygon diagonal intersects any polygon segments
	function intersectsPolygon(data:Array<Float>, start:Node, a:Int, b:Int):Bool {
		var node = start;
		do {
			var p1 = node.i;
			var	p2 = node.next.i;
			
			if (p1 != a && p2 != a && p1 != b && p2 != b && intersects(data, p1, p2, a, b)) {
				return true;
			}
			
			node = node.next;
		} 
		while (node != start);
		
		return false;
	}

	// check if a polygon diagonal is locally inside the polygon
	function locallyInside(data:Array<Float>, a:Node, b:Node) {
		return orient(data, a.prev.i, a.i, a.next.i) == -1 ?
			orient(data, a.i, b.i, a.next.i) != -1 && orient(data, a.i, a.prev.i, b.i) != -1 :
			orient(data, a.i, b.i, a.prev.i) == -1 || orient(data, a.i, a.next.i, b.i) == -1;
	}

	// check if the middle point of a polygon diagonal is inside the polygon
	function middleInside(data:Array<Float>, start:Node, a:Int, b:Int):Bool {
		var node = start;
		var	inside = false;
		var	px = (data[a] + data[b]) / 2;
		var	py = (data[a + 1] + data[b + 1]) / 2;
		
		do {
			var p1 = node.i;
			var	p2 = node.next.i;
			
			if (((data[p1 + 1] > py) != (data[p2 + 1] > py)) &&
				(px < (data[p2] - data[p1]) * (py - data[p1 + 1]) / (data[p2 + 1] - data[p1 + 1]) + data[p1])) {
					inside = !inside;
				}
				
			node = node.next;
		} 
		while (node != start);
		
		return inside;
	}

	// link two polygon vertices with a bridge; if the vertices belong to the same ring, it splits polygon into two;
	// if one belongs to the outer ring and another to a hole, it merges it into a single ring
	function splitPolygon(a:Node, b:Node):Node {
		var a2 = new Node(a.i);
		var	b2 = new Node(b.i);
		var	an = a.next;
		var	bp = b.prev;
		
		a.next = b;
		b.prev = a;
		
		a2.next = an;
		an.prev = a2;
		
		b2.next = a2;
		a2.prev = b2;
		
		bp.next = b2;
		b2.prev = bp;
		
		return b2;
	}

	// create a node and optionally link it with previous one (in a circular doubly linked list)
	function insertNode(i:Int, ?last:Node):Node {
		var node = new Node(i);
		
		if (last == null) {
			node.prev = node;
			node.next = node;
		} 
		else {
			node.next = last.next;
			node.prev = last;
			last.next.prev = node;
			last.next = node;
		}
		
		return node;
	}
	
}

class Node {
	
	public var i:Int;
	
	public var prev:Node; 
	public var next:Node;
	
	public var z:Int;
	
	public var prevZ:Node;
	public var nextZ:Node;
	
	public var steiner:Bool;
	
	
	public function new(i:Int) {
		// vertex coordinates
		this.i = i;
		
		// previous and next vertice nodes in a polygon ring
		this.prev = null;
		this.next = null;
		
		// z-order curve value
		this.z = null;
		
		// previous and next nodes in z-order
		this.prevZ = null;
		this.nextZ = null;
		
		// indicates whether this is a steiner point
		this.steiner = false;
	}
	
}
