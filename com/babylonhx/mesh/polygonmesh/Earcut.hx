package com.babylonhx.mesh.polygonmesh;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Earcut {
	
	static public function earcut(data:Array<Float>, ?holeIndices:Array<Int>, dim:Int = 2):Array<Int> {
		var hasHoles:Bool = holeIndices != null && holeIndices.length > 0;
		var	outerLen:Int = hasHoles ? Std.int(holeIndices[0] * dim) : data.length;
		var	outerNode:Node = linkedList(data, 0, outerLen, dim, true);
		var	triangles:Array<Int> = [];
		
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
		
		earcutLinked(outerNode, triangles, dim, minX, minY, size);
		
		return triangles;
	}
	
	// create a circular doubly linked list from polygon points in the specified winding order
	static function linkedList(data:Array<Float>, start:Int, end:Int, dim:Int, clockwise:Bool):Node {
		var last:Node = null;
		
		if (clockwise == (signedArea(data, start, end, dim) > 0)) {
			var i:Int = start;
			while (i < end) {
				last = insertNode(i, data[i], data[i + 1], last);
				
				i += dim;
			}
		} 
		else {
			var i:Int = end - dim;
			while (i >= start) {
				last = insertNode(i, data[i], data[i + 1], last);
				i -= dim;
			}
		}
		
		if (last != null && equals(last, last.next)) {
			removeNode(last);
			last = last.next;
		}
		
		return last;
	}

	// eliminate colinear or duplicate points
	static function filterPoints(?start:Node, ?end:Node):Node {
		if (start == null) {
			return start;
		}
		if (end == null) {
			end = start;
		}
		
		var p:Node = start;
		var again:Bool = false;
		do {
			again = false;
			
			if (!p.steiner && (equals(p, p.next) || area(p.prev, p, p.next) == 0)) {
				removeNode(p);
				p = end = p.prev;
				if (p == p.next) {
					return null;
				}
				again = true;
			} 
			else {
				p = p.next;
			}
		} 
		while (again || p != end);
		
		return end;
	}

	// main ear slicing loop which triangulates a polygon (given as a linked list)
	static function earcutLinked(ear:Node, triangles:Array<Int>, dim:Float, ?minX:Float, ?minY:Float, ?size:Float, ?pass:Int) {
		if (ear == null) {
			return;
		}
		
		// interlink polygon nodes in z-order
		if (pass == null && size != null) {
			indexCurve(ear, minX, minY, size);
		}
		
		var stop = ear;
		var	prev:Node = null;
		var next:Node = null;
		
		// iterate through ears, slicing them one by one
		while (ear.prev != ear.next) {
			prev = ear.prev;
			next = ear.next;
			
			if (size != null ? isEarHashed(ear, minX, minY, size) : isEar(ear)) {
				// cut off the triangle
				triangles.push(Std.int(prev.i / dim));
				triangles.push(Std.int(ear.i / dim));
				triangles.push(Std.int(next.i / dim));
				
				removeNode(ear);
				
				// skipping the next vertice leads to less sliver triangles
				ear = next.next;
				stop = next.next;
				
				continue;
			}
			
			ear = next;
			
			// if we looped through the whole remaining polygon and can't find any more ears
			if (ear == stop) {
				// try filtering points and slicing again
				if (pass == null) {
					earcutLinked(filterPoints(ear), triangles, dim, minX, minY, size, 1);				
				} // if this didn't work, try curing all small self-intersections locally
				else if (pass == 1) {
					ear = cureLocalIntersections(ear, triangles, dim);
					earcutLinked(ear, triangles, dim, minX, minY, size, 2);				
				} // as a last resort, try splitting the remaining polygon into two
				else if (pass == 2) {
					splitEarcut(ear, triangles, dim, minX, minY, size);
				}
				
				break;
			}
		}
	}

	// check whether a polygon node forms a valid ear with adjacent nodes
	static function isEar(ear:Node):Bool {
		var a = ear.prev;
		var	b = ear;
		var	c = ear.next;
		
		if (area(a, b, c) >= 0) {
			return false; // reflex, can't be an ear
		}
		
		// now make sure we don't have other points inside the potential ear
		var p = ear.next.next;
		
		while (p != ear.prev) {
			if (pointInTriangle(a.x, a.y, b.x, b.y, c.x, c.y, p.x, p.y) && area(p.prev, p, p.next) >= 0) {
				return false;
			}
			p = p.next;
		}
		
		return true;
	}
	
	static function isEarHashed(ear:Node, minX:Float, minY:Float, size:Float) {
		var a = ear.prev;
		var	b = ear;
		var c = ear.next;
		
		if (area(a, b, c) >= 0) {
			return false; // reflex, can't be an ear
		}
		
		// triangle bbox; min & max are calculated like this for speed
		var minTX = a.x < b.x ? (a.x < c.x ? a.x : c.x) : (b.x < c.x ? b.x : c.x);
		var	minTY = a.y < b.y ? (a.y < c.y ? a.y : c.y) : (b.y < c.y ? b.y : c.y);
		var	maxTX = a.x > b.x ? (a.x > c.x ? a.x : c.x) : (b.x > c.x ? b.x : c.x);
		var	maxTY = a.y > b.y ? (a.y > c.y ? a.y : c.y) : (b.y > c.y ? b.y : c.y);
		
		// z-order range for the current triangle bbox;
		var minZ = zOrder(cast minTX, cast minTY, cast minX, cast minY, cast size);
		var	maxZ = zOrder(cast maxTX, cast maxTY, cast minX, cast minY, cast size);
		
		// first look for points inside the triangle in increasing z-order
		var p = ear.nextZ;
		
		while (p != null && p.z <= maxZ) {
			if (p != ear.prev && p != ear.next && pointInTriangle(a.x, a.y, b.x, b.y, c.x, c.y, p.x, p.y) && area(p.prev, p, p.next) >= 0) {
				return false;
			}
			p = p.nextZ;
		}
		
		// then look for points in decreasing z-order
		p = ear.prevZ;
		
		while (p != null && p.z >= minZ) {
			if (p != ear.prev && p != ear.next && pointInTriangle(a.x, a.y, b.x, b.y, c.x, c.y, p.x, p.y) && area(p.prev, p, p.next) >= 0) {
				return false;
			}
			p = p.prevZ;
		}
		
		return true;
	}

	// go through all polygon nodes and cure small local self-intersections
	static function cureLocalIntersections(start:Node, triangles:Array<Int>, dim:Float) {
		var p = start;
		do {
			var a = p.prev;
			var	b = p.next.next;
			
			if (!equals(a, b) && intersects(a, p, p.next, b) && locallyInside(a, b) && locallyInside(b, a)) {
				triangles.push(Std.int(a.i / dim));
				triangles.push(Std.int(p.i / dim));
				triangles.push(Std.int(b.i / dim));
				
				// remove two nodes involved
				removeNode(p);
				removeNode(p.next);
				
				p = start = b;
			}
			p = p.next;
		} 
		while (p != start);
		
		return p;
	}

	// try splitting polygon into two and triangulate them independently
	static function splitEarcut(start:Node, triangles:Array<Int>, dim:Float, minX:Float, minY:Float, size:Float) {
		// look for a valid diagonal that divides the polygon into two
		var a = start;
		do {
			var b = a.next.next;
			while (b != a.prev) {
				if (a.i != b.i && isValidDiagonal(a, b)) {
					// split the polygon in two by the diagonal
					var c = splitPolygon(a, b);
					
					// filter colinear points around the cuts
					a = filterPoints(a, a.next);
					c = filterPoints(c, c.next);
					
					// run earcut on each half
					earcutLinked(a, triangles, dim, minX, minY, size);
					earcutLinked(c, triangles, dim, minX, minY, size);
					
					return;
				}
				
				b = b.next;
			}
			
			a = a.next;
		} 
		while (a != start);
	}

	// link every hole into the outer loop, producing a single-ring polygon without holes
	static function eliminateHoles(data:Array<Float>, holeIndices:Array<Int>, outerNode:Node, dim:Int):Node {
		var queue:Array<Node> = [];
		var len:Int = holeIndices.length;
		var	start:Int = 0;
		var end:Int = 0;
		var list:Node = null;
		
		for (i in 0...len) {
			start = Std.int(holeIndices[i] * dim);
			end = i < len - 1 ? Std.int(holeIndices[i + 1] * dim) : data.length;
			list = linkedList(data, start, end, dim, false);
			
			if (list == list.next) {
				list.steiner = true;
			}
			queue.push(getLeftmost(list));
		}
		
		queue.sort(compareX);
		
		// process holes from left to right
		for (i in 0...queue.length) {
			eliminateHole(queue[i], outerNode);
			outerNode = filterPoints(outerNode, outerNode.next);
		}
		
		return outerNode;
	}
	
	static inline function compareX(a:Node, b:Node):Int {
		return Std.int(a.x - b.x);
	}

	// find a bridge between vertices that connects hole with an outer ring and and link it
	static inline function eliminateHole(holeNode:Node, outerNode:Node) {
		outerNode = findHoleBridge(holeNode, outerNode);
		if (outerNode != null) {
			var b = splitPolygon(outerNode, holeNode);
			filterPoints(b, b.next);
		}
	}

	// David Eberly's algorithm for finding a bridge between hole and outer polygon
	static function findHoleBridge(hole:Node, outerNode:Node):Node {
		var p = outerNode;
		var hx = hole.x;
        var hy = hole.y;
		var	qx = Math.NEGATIVE_INFINITY;
		var m:Node = null;
		
		// find a segment intersected by a ray from the hole's leftmost point to the left;
		// segment's endpoint with lesser x will be potential connection point
		do {
			if (hy <= p.y && hy >= p.next.y && p.next.y != p.y) {
				var x = p.x + (hy - p.y) * (p.next.x - p.x) / (p.next.y - p.y);
				if (x <= hx && x > qx) {
					qx = x;
					if (x == hx) {
						if (hy == p.y) {
							return p;
						}
						if (hy == p.next.y) {
							return p.next;
						}
					}
					
					m = p.x < p.next.x ? p : p.next;
				}
			}
			
			p = p.next;
		} 
		while (p != outerNode);
		
		if (m == null) {
			return null;
		}
		
		if (hx == qx) {
			return m.prev; // hole touches outer segment; pick lower endpoint
		}
		
		// look for points inside the triangle of hole point, segment intersection and endpoint;
		// if there are no points found, we have a valid connection;
		// otherwise choose the point of the minimum angle with the ray as connection point
		
		var stop:Node = m;
		var mx:Float = m.x;
		var my:Float = m.y;
		var tanMin:Float = Math.POSITIVE_INFINITY;
		var tan:Float = 0;
		
		p = m.next;
		
		while (p != stop) {
			if (hx >= p.x && p.x >= mx && hx != p.x && pointInTriangle(hy < my ? hx : qx, hy, mx, my, hy < my ? qx : hx, hy, p.x, p.y)) {
				tan = Math.abs(hy - p.y) / (hx - p.x); // tangential
				if ((tan < tanMin || (tan == tanMin && p.x > m.x)) && locallyInside(p, hole)) {
					m = p;
					tanMin = tan;
				}
			}
			
			p = p.next;
		}
		
		return m;
	}

	// interlink polygon nodes in z-order
	static function indexCurve(start:Node, minX:Float, minY:Float, size:Float) {
		var p = start;
		
		do {
			if (p.z == -99999999) {
				p.z = zOrder(cast p.x, cast p.y, cast minX, cast minY, cast size);
			}
			
			p.prevZ = p.prev;
			p.nextZ = p.next;
			p = p.next;
		} 
		while (p != start);
		
		p.prevZ.nextZ = null;
		p.prevZ = null;
		
		sortLinked(p);
	}

	// Simon Tatham's linked list merge sort algorithm
	// http://www.chiark.greenend.org.uk/~sgtatham/algorithms/listsort.html
	static function sortLinked(list:Node):Node {
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
		} 
		while (numMerges > 1);
		
		return list;
	}

	// z-order of a point given coords and size of the data bounding box
	static function zOrder(x:Int, y:Int, minX:Int, minY:Int, size:Int):Int {
		// coords are transformed into non-negative 15-bit integer range
		x = Std.int(32767 * (x - minX) / size);
		y = Std.int(32767 * (y - minY) / size);
		
		x = (x | (x << 8)) & 0x00FF00FF;
		x = (x | (x << 4)) & 0x0F0F0F0F;
		x = (x | (x << 2)) & 0x33333333;
		x = (x | (x << 1)) & 0x55555555;
		
		y = (y | (y << 8)) & 0x00FF00FF;
		y = (y | (y << 4)) & 0x0F0F0F0F;
		y = (y | (y << 2)) & 0x33333333;
		y = (y | (y << 1)) & 0x55555555;
		
		return x | (y << 1);
	}

	// find the leftmost node of a polygon ring
	static function getLeftmost(start:Node):Node {
		var p = start;
		var	leftmost = start;
		
		do {
			if (p.x < leftmost.x) {
				leftmost = p;
			}
			
			p = p.next;
		} 
		while (p != start);
		
		return leftmost;
	}
	
	// check if a point lies within a convex triangle
	static inline function pointInTriangle(ax:Float, ay:Float, bx:Float, by:Float, cx:Float, cy:Float, px:Float, py:Float):Bool {
		return (cx - px) * (ay - py) - (ax - px) * (cy - py) >= 0 &&
			   (ax - px) * (by - py) - (bx - px) * (ay - py) >= 0 &&
			   (bx - px) * (cy - py) - (cx - px) * (by - py) >= 0;
	}

	// check if a diagonal between two polygon nodes is valid (lies in polygon interior)
	static inline function isValidDiagonal(a:Node, b:Node):Bool {
		return a.next.i != b.i && a.prev.i != b.i && !intersectsPolygon(a, b) &&
           locallyInside(a, b) && locallyInside(b, a) && middleInside(a, b);
	}

	// signed area of a triangle
	static inline function area(p:Node, q:Node, r:Node):Float {
		return (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y);
	}

	// check if two points are equal
	static inline function equals(p1:Node, p2:Node):Bool {
		return return p1.x == p2.x && p1.y == p2.y;
	}

	// check if two segments intersect
	static function intersects(p1:Node, q1:Node, p2:Node, q2:Node):Bool {
		if ((equals(p1, q1) && equals(p2, q2)) || (equals(p1, q2) && equals(p2, q1))) {
			return true;
		}
		
		return ((area(p1, q1, p2) > 0) != (area(p1, q1, q2) > 0)) && ((area(p2, q2, p1) > 0) != (area(p2, q2, q1) > 0));
	}

	// check if a polygon diagonal intersects any polygon segments
	static function intersectsPolygon(a:Node, b:Node):Bool {
		var p = a;
		do {
			if (p.i != a.i && p.next.i != a.i && p.i != b.i && p.next.i != b.i && intersects(p, p.next, a, b)) {
				return true;
			}
			p = p.next;
		} 
		while (p != a);
		
		return false;
	}

	// check if a polygon diagonal is locally inside the polygon
	static inline function locallyInside(a:Node, b:Node) {
		return area(a.prev, a, a.next) < 0 ?
			area(a, b, a.next) >= 0 && area(a, a.prev, b) >= 0 :
			area(a, b, a.prev) < 0 || area(a, a.next, b) < 0;
	}

	// check if the middle point of a polygon diagonal is inside the polygon
	static function middleInside(a:Node, b:Node):Bool {
		var p:Node = a;
        var inside:Bool = false;
        var px:Float = (a.x + b.x) / 2;
        var py:Float = (a.y + b.y) / 2;
		
		do {
			if (((p.y > py) != (p.next.y > py)) && p.next.y != p.y && (px < (p.next.x - p.x) * (py - p.y) / (p.next.y - p.y) + p.x)) {
				inside = !inside;
			}
			
			p = p.next;
		} 
		while (p != a);
		
		return inside;
	}

	// link two polygon vertices with a bridge; if the vertices belong to the same ring, it splits polygon into two;
	// if one belongs to the outer ring and another to a hole, it merges it into a single ring
	static function splitPolygon(a:Node, b:Node):Node {
		var a2:Node = new Node(a.i, a.x, a.y);
		var	b2:Node = new Node(b.i, b.x, b.y);
		var	an:Node = a.next;
		var	bp:Node = b.prev;
		
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
	static function insertNode(i:Int, x:Float, y:Float, ?last:Node):Node {
		var node = new Node(i, x, y);
		
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
	
	static function removeNode(p:Node) {
		p.next.prev = p.prev;
		p.prev.next = p.next;
		
		if (p.prevZ != null) {
			p.prevZ.nextZ = p.nextZ;
		}
		if (p.nextZ != null) {
			p.nextZ.prevZ = p.prevZ;
		}
	}
	
	static function signedArea(data:Array<Float>, start:Int, end:Int, dim:Int):Float {
		var sum:Float = 0;
		var i:Int = start;
		var j:Int = end - dim;
		while (i < end) {
			sum += (data[j] - data[i]) * (data[i + 1] + data[j + 1]);
			j = i;
			i += dim;
		}
		
		return sum;
	}
	
	// return a percentage difference between the polygon area and its triangulation area;
	// used to verify correctness of triangulation
	static function deviation(data:Array<Float>, holeIndices:Array<Int>, dim:Int, triangles:Array<Int>):Float {
		var hasHoles:Bool = holeIndices != null && holeIndices.length > 0;
		var outerLen:Int = hasHoles ? Std.int(holeIndices[0] * dim) : data.length;
		
		var polygonArea = Math.abs(signedArea(data, 0, outerLen, dim));
		if (hasHoles) {
			var len:Int = holeIndices.length;
			for (i in 0...len) {
				var start = holeIndices[i] * dim;
				var end = i < len - 1 ? holeIndices[i + 1] * dim : data.length;
				polygonArea -= Math.abs(signedArea(data, start, end, dim));
			}
		}
		
		var trianglesArea = 0.0;
		var i:Int = 0;
		while (i < triangles.length) {
			var a:Int = cast triangles[i] * dim;
			var b:Int = cast triangles[i + 1] * dim;
			var c:Int = cast triangles[i + 2] * dim;
			trianglesArea += Math.abs(
				(data[a] - data[c]) * (data[b + 1] - data[a + 1]) -
				(data[a] - data[b]) * (data[c + 1] - data[a + 1]));
				
			i += 3;
		}
		
		return polygonArea == 0 && trianglesArea == 0 ? 0 : Math.abs((trianglesArea - polygonArea) / polygonArea);
	}
	
	// turn a polygon in a multi-dimensional array form (e.g. as in GeoJSON) into a form Earcut accepts
	static public function flatten(data:Array<Array<Array<Float>>>) {
		var dim:Int = data[0][0].length;
		var vertices:Array<Float> = [];
		var holes:Array<Int> = [];
		var result:Dynamic = { };
		result.vertices = vertices;
		result.holes = holes;
		result.dimensions = dim;
		var holeIndex:Int = 0;
		
		for (i in 0...data.length) {
			for (j in 0...data[i].length) {
				for (d in 0...dim) {
					result.vertices.push(data[i][j][d]);
				}
			}
			if (i > 0) {
				holeIndex += data[i - 1].length;
				result.holes.push(holeIndex);
			}
		}
		
		return result;
	}
	
}

class Node {
	
	public var i:Int;
	
	public var x:Float;
	public var y:Float;
	
	public var prev:Node; 
	public var next:Node;
	
	public var z:Int = -99999999;
	
	public var prevZ:Node;
	public var nextZ:Node;
	
	public var steiner:Bool;
	
	
	public function new(i:Int, x:Float, y:Float) {
		// vertice index in coordinates array
		this.i = i;
		
		// vertex coordinates
		this.x = x;
		this.y = y;
		
		// previous and next vertice nodes in a polygon ring
		this.prev = null;
		this.next = null;
		
		// z-order curve value
		this.z = -99999999;
		
		// previous and next nodes in z-order
		this.prevZ = null;
		this.nextZ = null;
		
		// indicates whether this is a steiner point
		this.steiner = false;
	}
	
}
