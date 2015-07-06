package;

/**
 * ...
 * @author Krtolica Vujadin
 */

typedef ProcTreeProperties = {
	clumpMax:Null<Float>,
	clumpMin:Null<Float>,
	lengthFalloffFactor:Null<Float>,
	lengthFalloffPower:Null<Float>,
	branchFactor:Null<Float>,
	radiusFalloffRate:Null<Float>,
	climbRate:Null<Float>,
	trunkKink:Null<Float>,
	maxRadius:Null<Float>,
	treeSteps:Null<Int>,
	taperRate:Null<Float>,
	twistRate:Null<Float>,
	segments:Null<Int>,
	levels:Null<Int>,
	sweepAmount:Null<Float>,
	initalBranchLength:Null<Float>,
	trunkLength:Null<Float>,
	dropAmount:Null<Float>,
	growAmount:Null<Float>,
	vMultiplier:Null<Float>,
	twigScale:Null<Float>,
	seed:Null<Int>,
	rseed:Null<Int>,
	random:Null<Float->Float>
}
 
class ProcTree {
	
	public var properties:ProcTreeProperties = {
		clumpMax: 0.8,
		clumpMin: 0.5,
		lengthFalloffFactor: 0.85,
		lengthFalloffPower: 1,
		branchFactor: 2.0,
		radiusFalloffRate: 0.6,
		climbRate: 1.5,
		trunkKink: 0.00,
		maxRadius: 0.25,
		treeSteps: 2,
		taperRate: 0.95,
		twistRate: 13,
		segments: 6,
		levels: 3,
		sweepAmount: 0,
		initalBranchLength: 0.85,
		trunkLength: 2.5,
		dropAmount: 0.0,
		growAmount: 0.0,
		vMultiplier: 0.2,
		twigScale: 2.0,
		seed: 10,
		rseed: 10,
		random: function(?a:Float):Float {
			if (a == null) {
				a = this.properties.rseed++;
			}
			return Math.abs(Math.cos(a + a * a));
		}
	}
	
	public var root:Branch;
	public var verts:Array<Array<Float>>;
	public var faces:Array<Array<Int>>;
	public var normals:Array<Array<Float>>;
	public var UV:Array<Array<Float>>;
	public var vertsTwig:Array<Array<Float>>;
	public var normalsTwig:Array<Array<Float>>;
	public var facesTwig:Array<Array<Int>>;
	public var uvsTwig:Array<Array<Float>>;
	

	public function new(?data:ProcTreeProperties) {
		if (data != null) {
			var fields = Reflect.fields(data);
			for (f in fields) {
				if(Reflect.field(data, f) != null) {
					Reflect.setField(this.properties, f, Reflect.field(data, f));
				}
			}
		}
		
		this.properties.rseed = this.properties.seed;
		this.root = new Branch([0, this.properties.trunkLength, 0]);
		this.root.length = this.properties.initalBranchLength;
		this.verts = [];
		this.faces = [];
		this.normals = [];
		this.UV = [];
		this.vertsTwig = [];
		this.normalsTwig = [];
		this.facesTwig = [];
		this.uvsTwig = [];
		this.root.split(null, null, this.properties);
		this.createForks();
		this.createTwigs();
		this.doFaces();
		this.calcNormals();
	}
	
	public function calcNormals() {
		var allNormals:Array<Array<Array<Float>>> = [];
		
		for (i in 0...verts.length) {
			allNormals[i] = [];
		}
		
		for (i in 0...faces.length) {
			var face = faces[i];
			var norm = normalize(cross(subVec(verts[face[1]], verts[face[2]]), subVec(verts[face[1]], verts[face[0]])));	
			allNormals[face[0]].push(norm);
			allNormals[face[1]].push(norm);
			allNormals[face[2]].push(norm);
		}
		
		for (i in 0...allNormals.length) {
			var total:Array<Float> = [0, 0, 0];
			var l = allNormals[i].length;
			for (j in 0...l) {
				total = addVec(total, scaleVec(allNormals[i][j], 1 / l));
			}
			normals[i] = total;
		}
	}
	
	public function doFaces(?branch:Branch) {
		if (branch == null) {
			branch = this.root;
		}
		
		var segments = this.properties.segments;
		
		if(branch.parent == null){
			for (i in 0...verts.length) {
				UV[i] = [0, 0];
			}
	
			var tangent = normalize(cross(subVec(branch.child0.head, branch.head), subVec(branch.child1.head, branch.head)));
			var normal = normalize(branch.head);
			var angle = Math.acos(dot(tangent, [ -1, 0, 0]));
			if (dot(cross([ -1, 0, 0], tangent), normal) > 0) {
				angle = 2 * Math.PI - angle;
			}
			
			var segOffset = Math.round((angle / Math.PI / 2 * segments));
			
			try {
			for (i in 0...segments) {
				var v1 = branch.ring0[i];
				var v2 = branch.root[(i + segOffset + 1) % segments];
				var v3 = branch.root[(i + segOffset) % segments];
				var v4 = branch.ring0[(i + 1) % segments];
				
				faces.push([v1, v4, v3]);
				faces.push([v4, v2, v3]);
				UV[(i + segOffset) % segments] = [Math.abs(i / segments - 0.5) * 2, 0];
				var len = length(subVec(verts[branch.ring0[i]], verts[branch.root[(i + segOffset) % segments]])) * this.properties.vMultiplier;
				UV[branch.ring0[i]] = [Math.abs(i / segments - 0.5) * 2, len];
				UV[branch.ring2[i]] = [Math.abs(i / segments - 0.5) * 2, len];
			}
			} catch (err:Dynamic) {
				trace(err);
			}
		}
		
		if(branch.child0.ring0 != null){
			var segOffset0:Int = Std.int(Math.NEGATIVE_INFINITY);
			var segOffset1:Int = Std.int(Math.NEGATIVE_INFINITY);
			var match0:Float = Math.NEGATIVE_INFINITY;
			var match1:Float = Math.NEGATIVE_INFINITY;
			
			var v1 = normalize(subVec(verts[branch.ring1[0]], branch.head));
			var v2 = normalize(subVec(verts[branch.ring2[0]], branch.head));
			
			v1 = scaleInDirection(v1, normalize(subVec(branch.child0.head, branch.head)), 0);
			v2 = scaleInDirection(v2, normalize(subVec(branch.child1.head, branch.head)), 0);
			
			for (i in 0...segments) {
				var d = normalize(subVec(verts[branch.child0.ring0[i]], branch.child0.head));
				var l = dot(d, v1);
				if (segOffset0 == Math.NEGATIVE_INFINITY || l > match0) {
					match0 = l;
					segOffset0 = segments - i;
				}
				d = normalize(subVec(verts[branch.child1.ring0[i]], branch.child1.head));
				l = dot(d, v2);
				if (segOffset1 == Math.NEGATIVE_INFINITY || l > match1) {
					match1 = l;
					segOffset1 = segments - i;
				}
			}
			
			var UVScale = this.properties.maxRadius / branch.radius;			

			
			for (i in 0...segments) {
				var v1 = branch.child0.ring0[i];
				var v2 = branch.ring1[(i + segOffset0 + 1) % segments];
				var v3 = branch.ring1[(i + segOffset0) % segments];
				var v4 = branch.child0.ring0[(i + 1) % segments];
				faces.push([v1, v4, v3]);
				faces.push([v4, v2, v3]);
				v1 = branch.child1.ring0[i];
				v2 = branch.ring2[(i + segOffset1 + 1) % segments];
				v3 = branch.ring2[(i + segOffset1) % segments];
				v4 = branch.child1.ring0[(i + 1) % segments];
				faces.push([v1, v2, v3]);
				faces.push([v1, v4, v2]);
				
				var len1 = length(subVec(verts[branch.child0.ring0[i]], verts[branch.ring1[(i + segOffset0) % segments]])) * UVScale;
				var uv1 = UV[branch.ring1[(i + segOffset0 - 1) % segments]];
				
				UV[branch.child0.ring0[i]] = [uv1[0], uv1[1] + len1 * this.properties.vMultiplier];
				UV[branch.child0.ring2[i]] = [uv1[0], uv1[1] + len1 * this.properties.vMultiplier];
				
				var len2 = length(subVec(verts[branch.child1.ring0[i]], verts[branch.ring2[(i + segOffset1) % segments]])) * UVScale;
				var uv2 = UV[branch.ring2[(i + segOffset1 - 1) % segments]];
				
				UV[branch.child1.ring0[i]] = [uv2[0], uv2[1] + len2 * this.properties.vMultiplier];
				UV[branch.child1.ring2[i]] = [uv2[0], uv2[1] + len2 * this.properties.vMultiplier];
			}

			this.doFaces(branch.child0);
			this.doFaces(branch.child1);
			
		} else {
			for (i in 0...segments) {
				faces.push([branch.child0.end, branch.ring1[(i + 1) % segments], branch.ring1[i]]);
				faces.push([branch.child1.end, branch.ring2[(i + 1) % segments], branch.ring2[i]]);
				
				
				var len = length(subVec(verts[branch.child0.end], verts[branch.ring1[i]]));
				UV[branch.child0.end] = [Math.abs(i / segments - 1 - 0.5) * 2, len * this.properties.vMultiplier];
				var len = length(subVec(verts[branch.child1.end], verts[branch.ring2[i]]));
				UV[branch.child1.end] = [Math.abs(i / segments - 0.5) * 2, len * this.properties.vMultiplier];
			}
		}
	}
	
	public function createTwigs(?branch:Branch) {
		if (branch == null) {
			branch = this.root;
		}
				
		if (branch.child0 == null) {
			
			var tangent = normalize(cross(subVec(branch.parent.child0.head, branch.parent.head), subVec(branch.parent.child1.head, branch.parent.head)));
			var binormal = normalize(subVec(branch.head, branch.parent.head));
			var normal = cross(tangent, binormal);
			
			var vert1 = vertsTwig.length;
			vertsTwig.push(addVec(addVec(branch.head, scaleVec(tangent, this.properties.twigScale)), scaleVec(binormal, this.properties.twigScale * 2 - branch.length)));
			var vert2 = vertsTwig.length;
			vertsTwig.push(addVec(addVec(branch.head, scaleVec(tangent, -this.properties.twigScale)), scaleVec(binormal, this.properties.twigScale * 2 - branch.length)));
			var vert3 = vertsTwig.length;
			vertsTwig.push(addVec(addVec(branch.head, scaleVec(tangent, -this.properties.twigScale)), scaleVec(binormal, -branch.length)));
			var vert4 = vertsTwig.length;
			vertsTwig.push(addVec(addVec(branch.head, scaleVec(tangent, this.properties.twigScale)), scaleVec(binormal, -branch.length)));
			
			var vert8 = vertsTwig.length;
			vertsTwig.push(addVec(addVec(branch.head, scaleVec(tangent, this.properties.twigScale)), scaleVec(binormal, this.properties.twigScale * 2 - branch.length)));
			var vert7 = vertsTwig.length;
			vertsTwig.push(addVec(addVec(branch.head, scaleVec(tangent, -this.properties.twigScale)), scaleVec(binormal, this.properties.twigScale * 2 - branch.length)));
			var vert6 = vertsTwig.length;
			vertsTwig.push(addVec(addVec(branch.head, scaleVec(tangent, -this.properties.twigScale)), scaleVec(binormal, -branch.length)));
			var vert5 = vertsTwig.length;
			vertsTwig.push(addVec(addVec(branch.head, scaleVec(tangent, this.properties.twigScale)), scaleVec(binormal, -branch.length)));
			
			facesTwig.push([vert1, vert2, vert3]);
			facesTwig.push([vert4, vert1, vert3]);
			
			facesTwig.push([vert6, vert7, vert8]);
			facesTwig.push([vert6, vert8, vert5]);
			
			normal = normalize(cross(subVec(vertsTwig[vert1], vertsTwig[vert3]), subVec(vertsTwig[vert2], vertsTwig[vert3])));
			var normal2 = normalize(cross(subVec(vertsTwig[vert7], vertsTwig[vert6]), subVec(vertsTwig[vert8], vertsTwig[vert6])));
			
			normalsTwig.push(normal);
			normalsTwig.push(normal);
			normalsTwig.push(normal);
			normalsTwig.push(normal);
			
			normalsTwig.push(normal2);
			normalsTwig.push(normal2);
			normalsTwig.push(normal2);
			normalsTwig.push(normal2);
			
			uvsTwig.push([0, 1]);
			uvsTwig.push([1, 1]);
			uvsTwig.push([1, 0]);
			uvsTwig.push([0, 0]);
			
			uvsTwig.push([0, 1]);
			uvsTwig.push([1, 1]);
			uvsTwig.push([1, 0]);
			uvsTwig.push([0, 0]);
			
		} else {
			this.createTwigs(branch.child0);
			this.createTwigs(branch.child1);
		}
	}
	
	public function createForks(?branch:Branch, ?radius:Float) {
		if (branch == null) {
			branch = this.root;
		}
		if (radius == null) {
			radius = this.properties.maxRadius;
		}		
		
		branch.radius = radius;
		
		if (radius > branch.length) {
			radius = branch.length;
		}
		
		var verts = this.verts;
		var segments = this.properties.segments;
		
		var segmentAngle = Math.PI * 2 / segments;
			
		if(branch.parent == null) {
			//create the root of the tree
			branch.root = [];
			var axis = [0.0, 1.0, 0.0];
			for (i in 0...segments) {
				var vec = vecAxisAngle([ -1, 0, 0], axis, -segmentAngle * i);
				branch.root.push(verts.length);
				verts.push(scaleVec(vec, radius / this.properties.radiusFalloffRate));
			}
		}
		
		//cross the branches to get the left
		//add the branches to get the up
		if (branch.child0 != null) {
			var axis:Array<Float>;
			if (branch.parent != null) {
				axis = normalize(subVec(branch.head, branch.parent.head));
			} else {
				axis = normalize(branch.head);
			}
			
			var axis1 = normalize(subVec(branch.head, branch.child0.head));
			var axis2 = normalize(subVec(branch.head, branch.child1.head));
			var tangent = normalize(cross(axis1, axis2));
			branch.tangent = tangent;
			
			var axis3 = normalize(cross(tangent, normalize(addVec(scaleVec(axis1, -1), scaleVec(axis2, -1)))));
			var dir = [axis2[0], 0, axis2[2]];
			var centerloc = addVec(branch.head, scaleVec(dir, -this.properties.maxRadius / 2));



			var ring0:Array<Int> = [];
			branch.ring0 = [];
			var ring1:Array<Int> = [];
			branch.ring1 = [];
			var ring2:Array<Int> = [];
			branch.ring2 = [];
			
			var scale = this.properties.radiusFalloffRate;
			
			if (branch.child0.type == "trunk" || branch.type == "trunk") {
				scale = 1 / this.properties.taperRate;
			}
			
			//main segment ring
			var linch0 = verts.length;
			ring0.push(linch0);
			ring2.push(linch0);
			verts.push(addVec(centerloc, scaleVec(tangent, radius * scale)));
			
			var start = verts.length - 1;			
			var d1 = vecAxisAngle(tangent, axis2, 1.57);
			var d2 = normalize(cross(tangent, axis));
			var s = 1 / dot(d1, d2);
			for (i in 1...Std.int(segments / 2)) {
				var vec = vecAxisAngle(tangent, axis2, segmentAngle * i);
				ring0.push(start + i);
				ring2.push(start + i);
				vec = scaleInDirection(vec, d2, s);
				verts.push(addVec(centerloc, scaleVec(vec, radius * scale)));
			}
			
			var linch1 = verts.length;
			ring0.push(linch1);
			ring1.push(linch1);
			verts.push(addVec(centerloc, scaleVec(tangent, -radius * scale)));
			for (i in Std.int(segments / 2 + 1)...segments) {
				var vec = vecAxisAngle(tangent, axis1, segmentAngle * i);
				ring0.push(verts.length);
				ring1.push(verts.length);
				verts.push(addVec(centerloc, scaleVec(vec, radius * scale)));
			}
			
			ring1.push(linch0);
			ring2.push(linch1);
			var start = verts.length - 1;
			for (i in 1...Std.int(segments / 2)) {
				var vec = vecAxisAngle(tangent, axis3, segmentAngle * i);
				ring1.push(start + i);
				ring2.push(Std.int(start + (segments / 2 - i)));
				var v = scaleVec(vec, radius * scale);
				verts.push(addVec(centerloc, v));
			}
			
			//child radius is related to the brans direction and the length of the branch
			var length0 = length(subVec(branch.head, branch.child0.head));
			var length1 = length(subVec(branch.head, branch.child1.head));
			
			var radius0 = 1 * radius * this.properties.radiusFalloffRate;
			var radius1 = 1 * radius * this.properties.radiusFalloffRate;
			if (branch.child0.type == "trunk") {
				radius0 = radius * this.properties.taperRate;
			}
			this.createForks(branch.child0, radius0);
			this.createForks(branch.child1, radius1);
			
		} else {
			//add points for the ends of braches
			branch.end = verts.length;
			//branch.head=addVec(branch.head,scaleVec([this.properties.xBias,this.properties.yBias,this.properties.zBias],branch.length*3));
			verts.push(branch.head);			
		}
	}
	
	public static function flattenArray(input:Array<Array<Float>>):Array<Float> {
        var retArray:Array<Float> = [];
    	for (i in 0...input.length) {
    		for (j in 0...input[i].length) {
    			retArray.push(input[i][j]);
    		}
    	}
    	return retArray;
    }
	
	// Statics
	public static function dot(v1:Array<Float>, v2:Array<Float>):Float {
		return v1[0] * v2[0] + v1[1] * v2[1] + v1[2] * v2[2];
	}
	
	public static function cross(v1:Array<Float>, v2:Array<Float>):Array<Float> {
		return [v1[1] * v2[2] - v1[2] * v2[1], v1[2] * v2[0] - v1[0] * v2[2], v1[0] * v2[1] - v1[1] * v2[0]];
	}
	
	public static function length(v:Array<Float>):Float {
		return Math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
	}
	
	public static function normalize(v:Array<Float>):Array<Float> {
		var l = length(v);
		return scaleVec(v, 1 / l);
	}
	
	public static function scaleVec(v:Array<Float>, s:Float):Array<Float> {
		return [v[0] * s, v[1] * s, v[2] * s];
	}
	
	public static function subVec(v1:Array<Float>, v2:Array<Float>):Array<Float> {
		return [v1[0] - v2[0], v1[1] - v2[1], v1[2] - v2[2]];
	}
	
	public static function addVec(v1:Array<Float>, v2:Array<Float>):Array<Float> {
		return [v1[0] + v2[0], v1[1] + v2[1], v1[2] + v2[2]];
	}

	public static function vecAxisAngle(vec:Array<Float>, axis:Array<Float>, angle:Float):Array<Float> {
		//v cos(T) + (axis x v) * sin(T) + axis*(axis . v)(1-cos(T)
		var cosr = Math.cos(angle);
		var sinr = Math.sin(angle);
		return addVec(addVec(scaleVec(vec, cosr), scaleVec(cross(axis, vec), sinr)), scaleVec(axis, dot(axis, vec) * (1 - cosr)));
	}
	
	public static function scaleInDirection(vector:Array<Float>, direction:Array<Float>, scale:Float):Array<Float> {
		var currentMag = dot(vector, direction);
		
		var change = scaleVec(direction, currentMag * scale-currentMag);
		return addVec(vector, change);
	}
	
}
