package;

import ProcTree.ProcTreeProperties;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Branch {
	
	public var head:Array<Float>;
	public var parent:Branch;
	public var child0:Branch;
	public var child1:Branch;
	public var length:Float = 1;
	public var type:String;
	public var root:Array<Int>;
	public var tangent:Array<Float>;
	public var radius:Float;
	
	public var ring0:Array<Int>;
	public var ring1:Array<Int>;
	public var ring2:Array<Int>;
	
	public var end:Int;
	

	public function new(?head:Array<Float>, ?parent:Branch) {
		this.head = head;
		this.parent = parent;
	}
	
	public function mirrorBranch(vec:Array<Float>, norm:Array<Float>, properties:ProcTreeProperties):Array<Float> {
		var v = ProcTree.cross(norm, ProcTree.cross(vec, norm));
		var s = properties.branchFactor * ProcTree.dot(v, vec);
		return [vec[0] - v[0] * s, vec[1] - v[1] * s, vec[2] - v[2] * s];
	}
	
	public function split(?level:Int, ?steps:Int, ?properties:ProcTreeProperties, ?l1:Int, ?l2:Int) {
		if (l1 == null) l1 = 1;
		if (l2 == null) l2 = 1;
		if (level == null) level = properties.levels;
		if (steps == null) steps = properties.treeSteps;
		
		var rLevel = properties.levels - level;
		
		var po:Array<Float> = null;
		if (this.parent != null){
			po = this.parent.head;
		} else {
			po = [0, 0, 0];
			this.type = "trunk";
		}
		
		var so = this.head;
		var dir = ProcTree.normalize(ProcTree.subVec(so, po));

		var normal = ProcTree.cross(dir, [dir[2], dir[0], dir[1]]);
		var tangent = ProcTree.cross(dir, normal);
		var r = properties.random(rLevel * 10 + l1 * 5 + l2 + properties.seed);
		var r2 = properties.random(rLevel * 10 + l1 * 5 + l2 + 1 + properties.seed);
		var clumpmax = properties.clumpMax;
		var clumpmin = properties.clumpMin;
		
		var adj = ProcTree.addVec(ProcTree.scaleVec(normal, r), ProcTree.scaleVec(tangent, 1 - r));
		if (r > 0.5) adj = ProcTree.scaleVec(adj, -1);
		
		var clump = (clumpmax - clumpmin) * r + clumpmin;
		var newdir = ProcTree.normalize(ProcTree.addVec(ProcTree.scaleVec(adj, 1 - clump), ProcTree.scaleVec(dir, clump)));
			
		
		var newdir2 = this.mirrorBranch(newdir, dir, properties);
		if (r > 0.5) {
			var tmp = newdir;
			newdir = newdir2;
			newdir2 = tmp;
		}
		if (steps > 0) {
			var angle = steps / properties.treeSteps * 2 * Math.PI * properties.twistRate;
			newdir2 = ProcTree.normalize([Math.sin(angle), r, Math.cos(angle)]);
		}
		
		var growAmount = level * level / (properties.levels * properties.levels) * properties.growAmount;
		var dropAmount = rLevel * properties.dropAmount;
		var sweepAmount = rLevel * properties.sweepAmount;
		newdir = ProcTree.normalize(ProcTree.addVec(newdir, [sweepAmount, dropAmount + growAmount, 0]));
		newdir2 = ProcTree.normalize(ProcTree.addVec(newdir2, [sweepAmount, dropAmount + growAmount, 0]));
		
		var head0 = ProcTree.addVec(so, ProcTree.scaleVec(newdir, this.length));
		var head1 = ProcTree.addVec(so, ProcTree.scaleVec(newdir2, this.length));
		this.child0 = new Branch(head0, this);
		this.child1 = new Branch(head1, this);
		this.child0.length = Math.pow(this.length, properties.lengthFalloffPower) * properties.lengthFalloffFactor;
		this.child1.length = Math.pow(this.length, properties.lengthFalloffPower) * properties.lengthFalloffFactor;
		if (level > 0) {
			if (steps > 0) {
				this.child0.head = ProcTree.addVec(this.head, [(r - 0.5) * 2 * properties.trunkKink, properties.climbRate, (r - 0.5) * 2 * properties.trunkKink]);
				this.child0.type = "trunk";
				this.child0.length = this.length * properties.taperRate;
				this.child0.split(level, steps - 1, properties, l1 + 1, l2);
			} else {
				this.child0.split(level - 1, 0, properties, l1 + 1, l2);
			}
			this.child1.split(level - 1, 0, properties, l1, l2 + 1);
		}
	}
		
}
