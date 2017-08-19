package com.babylonhx.mesh.proctree;

/**
 * ...
 * @author Krtolica Vujadin
 */

// ported from https://github.com/supereggbert/proctree.js
class Tree {

	var properties:Properties;
	var root:Branch;

	public var verts:Array<Array<Float>>;
	public var faces:Array<Array<Int>>;
	public var normals:Array<Array<Float>>;
	public var uvs:Array<Array<Float>>;

	public var vertsTwig:Array<Array<Float>>;
	public var normalsTwig:Array<Array<Float>>;
	public var facesTwig:Array<Array<Int>>;
	public var uvsTwig:Array<Array<Float>>;

	public function new(?data:Dynamic) {
		this.properties = new Properties();
		
		if (data != null) {
			for (key in Reflect.fields(data)) {
				if (Reflect.getProperty(this.properties, key) != null) {
					Reflect.setProperty(this.properties, key, Reflect.getProperty(data, key));
				}
			}
		}
		
		this.properties.rseed = this.properties.seed;
		this.root = new Branch([0, this.properties.trunkLength, 0]);
		this.root.length = this.properties.initalBranchLength;
		this.verts = [];
		this.faces = [];
		this.normals = [];
		this.uvs = [];
		this.vertsTwig = [];
		this.normalsTwig = [];
		this.facesTwig = [];
		this.uvsTwig = [];
		this.root.split(this.properties, null, null);
		this.createForks();
		this.createTwigs();
		this.doFaces();
		this.calcNormals();	
	}

	inline function random(a:Float = -1):Float {
		if (a == -1) {
			a = this.properties.rseed++;
		}
		
		return Math.abs(Math.cos(a + a * a));
	}

	function calcNormals() {
		var normals = this.normals;
		var faces = this.faces;
		var verts = this.verts;
		var allNormals:Array<Array<Array<Float>>> = [];
		for (i in 0...verts.length) {
			allNormals[i] = [];
		}
		for (i in 0...faces.length) {
			var face = faces[i];
			var norm = TreeMath.normalize(
				TreeMath.cross(TreeMath.subVec(verts[face[1]], verts[face[2]]), TreeMath.subVec(verts[face[1]], verts[face[0]])));		
			allNormals[face[0]].push(norm);
			allNormals[face[1]].push(norm);
			allNormals[face[2]].push(norm);
		}
		for (i in 0...allNormals.length) {
			var total:Array<Float> =[0, 0, 0];
			var l = allNormals[i].length;
			for (j in 0...l) {
				total = TreeMath.addVec(total, TreeMath.scaleVec(allNormals[i][j], 1 / l));
			}
			normals[i] = total;
		}
	}

	function doFaces(?branch:Branch) {
		if (branch == null) {
			branch = this.root;
		}
		var segments = this.properties.segments;
		var faces = this.faces;
		var verts = this.verts;
		var uvs = this.uvs;
		if (branch.parent == null) {
			for (i in 0...verts.length) {
				uvs[i] = [0, 0];
			}
			var tangent = TreeMath.normalize(TreeMath.cross(
				TreeMath.subVec(branch.child0.head, branch.head), 
				TreeMath.subVec(branch.child1.head,branch.head))
			);
			var normal = TreeMath.normalize(branch.head);
			var angle = Math.acos(TreeMath.dot(tangent, [-1, 0, 0]));
			if (TreeMath.dot(TreeMath.cross([-1, 0, 0], tangent), normal) > 0) {
				angle = 2 * Math.PI - angle;
			}
			var segOffset = Math.round((angle / Math.PI / 2 * segments));
			for (i in 0...segments) {			
				var v1 = branch.ring0[i];
				var v2 = branch.root[(i + segOffset + 1) % segments];
				var v3 = branch.root[(i + segOffset) % segments];
				var v4 = branch.ring0[(i + 1) % segments];
				
				faces.push([v1, v4, v3]);
				faces.push([v4, v2, v3]);
				uvs[(i + segOffset) % segments] = [Math.abs(i / segments - 0.5) * 2, 0];
				var len = TreeMath.length(TreeMath.subVec(
					verts[branch.ring0[i]],
					verts[branch.root[(i + segOffset) % segments]]
				)) * this.properties.vMultiplier;
				uvs[branch.ring0[i]] = [Math.abs(i / segments - 0.5) * 2, len];
				uvs[branch.ring2[i]] = [Math.abs(i / segments - 0.5) * 2, len];
			}
		}
		
		if (branch.child0.ring0 != null) {
			var segOffset0:Int = -1;
			var segOffset1:Int = -1;
			var match0:Float = 0;
			var match1:Float = 0;
			
			var v1 = TreeMath.normalize(TreeMath.subVec(verts[branch.ring1[0]], branch.head));
			var v2 = TreeMath.normalize(TreeMath.subVec(verts[branch.ring2[0]], branch.head));
			
			v1 = TreeMath.scaleInDirection(v1, TreeMath.normalize(TreeMath.subVec(branch.child0.head, branch.head)), 0);
			v2 = TreeMath.scaleInDirection(v2, TreeMath.normalize(TreeMath.subVec(branch.child1.head, branch.head)), 0);
			
			for (i in 0...segments) {
				var d = TreeMath.normalize(TreeMath.subVec(verts[branch.child0.ring0[i]], branch.child0.head));
				var l = TreeMath.dot(d, v1);
				if (segOffset0 == -1 || l > match0) {
					match0 = l;
					segOffset0 = segments - i;
				}
				d = TreeMath.normalize(TreeMath.subVec(verts[branch.child1.ring0[i]], branch.child1.head));
				l = TreeMath.dot(d, v2);
				if (segOffset1 == -1 || l > match1) {
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
				
				var len1 = TreeMath.length(TreeMath.subVec(	
					verts[branch.child0.ring0[i]],
					verts[branch.ring1[(i+segOffset0) % segments]])
				) * UVScale;
				var uv1 = uvs[branch.ring1[(i + segOffset0 - 1) % segments]];
				
				uvs[branch.child0.ring0[i]] = [uv1[0], uv1[1] + len1 * this.properties.vMultiplier];
				uvs[branch.child0.ring2[i]] = [uv1[0], uv1[1] + len1 * this.properties.vMultiplier];
				
				var len2 = TreeMath.length(TreeMath.subVec(
					verts[branch.child1.ring0[i]], 
					verts[branch.ring2[(i + segOffset1) % segments]])
				) * UVScale;
				var uv2 = uvs[branch.ring2[(i + segOffset1 - 1) % segments]];
				
				uvs[branch.child1.ring0[i]] = [uv2[0], uv2[1] + len2 * this.properties.vMultiplier];
				uvs[branch.child1.ring2[i]] = [uv2[0], uv2[1] + len2 * this.properties.vMultiplier];
			}
			
			this.doFaces(branch.child0);
			this.doFaces(branch.child1);
		}
		else {
			for (i in 0...segments) {
				faces.push([branch.child0.end, branch.ring1[(i + 1) % segments], branch.ring1[i]]);
				faces.push([branch.child1.end, branch.ring2[(i + 1) % segments], branch.ring2[i]]);				
				
				var len = TreeMath.length(TreeMath.subVec(verts[branch.child0.end], verts[branch.ring1[i]]));
				uvs[branch.child0.end] = [Math.abs(i / segments - 1 - 0.5) * 2, len * this.properties.vMultiplier];
				len = TreeMath.length(TreeMath.subVec(verts[branch.child1.end], verts[branch.ring2[i]]));
				uvs[branch.child1.end] = [Math.abs(i / segments - 0.5) * 2, len * this.properties.vMultiplier];
			}
		}
	}
	
	public function createTwigs(?branch:Branch) {
		if (branch == null) {
			branch = this.root;
		}
		var vertsTwig = this.vertsTwig;
		var normalsTwig = this.normalsTwig;
		var facesTwig = this.facesTwig;
		var uvsTwig = this.uvsTwig;
		if (branch.child0 == null) {
			var tangent = TreeMath.normalize(TreeMath.cross(TreeMath.subVec(branch.parent.child0.head, branch.parent.head),
				TreeMath.subVec(branch.parent.child1.head, branch.parent.head)));
			var binormal = TreeMath.normalize(TreeMath.subVec(branch.head, branch.parent.head));
			var normal = TreeMath.cross(tangent, binormal);				
			
			var vert1 = vertsTwig.length;
			vertsTwig.push(TreeMath.addVec(TreeMath.addVec(branch.head, TreeMath.scaleVec(tangent, this.properties.twigScale)),
				TreeMath.scaleVec(binormal, this.properties.twigScale * 2 - branch.length)));
			var vert2 = vertsTwig.length;
			vertsTwig.push(TreeMath.addVec(TreeMath.addVec(branch.head, TreeMath.scaleVec(tangent, -this.properties.twigScale)),
				TreeMath.scaleVec(binormal, this.properties.twigScale * 2 - branch.length)));
			var vert3 = vertsTwig.length;
			vertsTwig.push(TreeMath.addVec(TreeMath.addVec(branch.head, TreeMath.scaleVec(tangent, -this.properties.twigScale)),
				TreeMath.scaleVec(binormal, -branch.length)));
			var vert4 = vertsTwig.length;
			vertsTwig.push(TreeMath.addVec(TreeMath.addVec(branch.head, TreeMath.scaleVec(tangent, this.properties.twigScale)),
				TreeMath.scaleVec(binormal, -branch.length)));
				
			var vert8 = vertsTwig.length;
			vertsTwig.push(TreeMath.addVec(TreeMath.addVec(branch.head, TreeMath.scaleVec(tangent, this.properties.twigScale)),
				TreeMath.scaleVec(binormal, this.properties.twigScale * 2 - branch.length)));
			var vert7 = vertsTwig.length;
			vertsTwig.push(TreeMath.addVec(TreeMath.addVec(branch.head, TreeMath.scaleVec(tangent, -this.properties.twigScale)), 
				TreeMath.scaleVec(binormal, this.properties.twigScale * 2 - branch.length)));
			var vert6 = vertsTwig.length;
			vertsTwig.push(TreeMath.addVec(TreeMath.addVec(branch.head, TreeMath.scaleVec(tangent, -this.properties.twigScale)),
				TreeMath.scaleVec(binormal, -branch.length)));
			var vert5 = vertsTwig.length;
			vertsTwig.push(TreeMath.addVec(TreeMath.addVec(branch.head, TreeMath.scaleVec(tangent, this.properties.twigScale)),
				TreeMath.scaleVec(binormal, -branch.length)));
				
			facesTwig.push([vert1, vert2, vert3]);
			facesTwig.push([vert4, vert1, vert3]);
			
			facesTwig.push([vert6, vert7, vert8]);
			facesTwig.push([vert6, vert8, vert5]);
			
			normal = TreeMath.normalize(TreeMath.cross(TreeMath.subVec(vertsTwig[vert1], vertsTwig[vert3]),
				TreeMath.subVec(vertsTwig[vert2], vertsTwig[vert3])));
			var normal2 = TreeMath.normalize(TreeMath.cross(TreeMath.subVec(vertsTwig[vert7], vertsTwig[vert6]),
				TreeMath.subVec(vertsTwig[vert8], vertsTwig[vert6])));
				
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
		}
		else {
			this.createTwigs(branch.child0);
			this.createTwigs(branch.child1);
		}
	}

	function createForks(?branch:Branch, ?radius:Float) {
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
			
		if (branch.parent == null) {
			//create the root of the tree
			branch.root = [];
			var axis:Array<Float> = [0, 1, 0];
			for (i in 0...segments) {
				var vec = TreeMath.vecAxisAngle([-1.0, 0.0, 0.0], axis, -segmentAngle * i);
				branch.root.push(verts.length);
				verts.push(TreeMath.scaleVec(vec, radius / this.properties.radiusFalloffRate));
			}
		}
		
		//cross the branches to get the left
		//add the branches to get the up
		if (branch.child0 != null) {
			var axis:Array<Float> = [];
			if (branch.parent != null) {
				axis = TreeMath.normalize(TreeMath.subVec(branch.head, branch.parent.head));
			}
			else {
				axis = TreeMath.normalize(branch.head);
			}
			
			var axis1 = TreeMath.normalize(TreeMath.subVec(branch.head, branch.child0.head));
			var axis2 = TreeMath.normalize(TreeMath.subVec(branch.head, branch.child1.head));
			var tangent = TreeMath.normalize(TreeMath.cross(axis1, axis2));
			branch.tangent = tangent;
			
			var axis3 = TreeMath.normalize(TreeMath.cross(tangent, 
				TreeMath.normalize(TreeMath.addVec(TreeMath.scaleVec(axis1, -1), 
					TreeMath.scaleVec(axis2, -1)))));
			var dir = [axis2[0], 0, axis2[2]];			
			var centerloc = TreeMath.addVec(branch.head, TreeMath.scaleVec(dir, -this.properties.maxRadius / 2));
			
			var ring0 = branch.ring0 = [];
			var ring1 = branch.ring1 = [];
			var ring2 = branch.ring2 = [];
			
			var scale = this.properties.radiusFalloffRate;
			
			if (branch.child0.type == "trunk" || branch.type == "trunk") {
				scale = 1 / this.properties.taperRate;
			}
			
			//main segment ring
			var linch0 = verts.length;
			ring0.push(linch0);
			ring2.push(linch0);
			verts.push(TreeMath.addVec(centerloc, TreeMath.scaleVec(tangent, radius * scale)));
			
			var start = verts.length - 1;			
			var d1 = TreeMath.vecAxisAngle(tangent, axis2, 1.57);
			var d2 = TreeMath.normalize(TreeMath.cross(tangent, axis));
			var s = 1 / TreeMath.dot(d1, d2);
			for (i in 1...Std.int(segments / 2)) {
				var vec = TreeMath.vecAxisAngle(tangent, axis2, segmentAngle * i);
				ring0.push(start + i);
				ring2.push(start + i);
				vec = TreeMath.scaleInDirection(vec, d2, s);
				verts.push(TreeMath.addVec(centerloc, TreeMath.scaleVec(vec, radius * scale)));
			}
			var linch1 = verts.length;
			ring0.push(linch1);
			ring1.push(linch1);
			verts.push(TreeMath.addVec(centerloc, TreeMath.scaleVec(tangent, -radius * scale)));
			for (i in Std.int(segments / 2 + 1)...segments){
				var vec = TreeMath.vecAxisAngle(tangent, axis1, segmentAngle * i);
				ring0.push(verts.length);
				ring1.push(verts.length);
				verts.push(TreeMath.addVec(centerloc, TreeMath.scaleVec(vec, radius * scale)));
			}
			ring1.push(linch0);
			ring2.push(linch1);
			
			var start = verts.length - 1;
			for (i in 1...Std.int(segments / 2)) {
				var vec = TreeMath.vecAxisAngle(tangent, axis3, segmentAngle * i);
				ring1.push(start + i);
				ring2.push(start + Std.int(segments / 2 - i));
				var v = TreeMath.scaleVec(vec, radius * scale);
				verts.push(TreeMath.addVec(centerloc, v));
			}
			
			//child radius is related to the brans direction and the length of the branch
			var length0 = TreeMath.length(TreeMath.subVec(branch.head, branch.child0.head));
			var length1 = TreeMath.length(TreeMath.subVec(branch.head, branch.child1.head));
			
			var radius0 = 1 * radius * this.properties.radiusFalloffRate;
			var radius1 = 1 * radius * this.properties.radiusFalloffRate;
			if (branch.child0.type == "trunk") {
				radius0 = radius * this.properties.taperRate;
			}
			this.createForks(branch.child0, radius0);
			this.createForks(branch.child1, radius1);
		}
		else {
			//add points for the ends of braches
			branch.end = verts.length;
			//branch.head=addVec(branch.head,scaleVec([this.properties.xBias,this.properties.yBias,this.properties.zBias],branch.length*3));
			verts.push(branch.head);			
		}		
	}

}
