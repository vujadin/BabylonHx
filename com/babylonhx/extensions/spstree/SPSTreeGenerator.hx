package com.babylonhx.extensions.spstree;

import com.babylonhx.math.Axis;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Quaternion;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.MeshBuilder;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.materials.Material;
import com.babylonhx.particles.solid.SolidParticleSystem;
import com.babylonhx.particles.solid.SolidParticle;

/**
 * ...
 * @author Krtolica Vujadin
 */

typedef CoordSys = {
	x:Vector3,
	y:Vector3,
	z:Vector3
}
 
class SPSTreeGenerator {

	//creates an x, y, z coordinate system using the parameter vec3 for the y axis
	static function coordSystem(vec3:Vector3):CoordSys {  //vec3 non-zero Vector3
		var _y = vec3.normalize();
		var _x:Vector3 = null;
		if (Math.abs(vec3.x) == 0 && Math.abs(vec3.y) == 0) {
			_x = new Vector3(vec3.z, 0, 0).normalize();
		}
		else {
			_x = new Vector3(vec3.y, -vec3.x, 0).normalize();
		}
		var _z = Vector3.Cross(_x, _y);
		return { x: _x, y: _y, z: _z };
	}

	//randomize a value v +/- p*100% of v
	static function randPct(v:Float, p:Float):Float {
		if (p == 0) {
			return v;
		}
		
		return (1 + (1 - 2 * Math.random()) * p) * v;
	}

	/*Creates a single branch of the tree starting from branchAt (Vector3) using the coordinate system branchSys.
	**The branch is in the direction of branchSys.y with the cross section of the branch in the branchSys.x and branchSys.z plane.
	**The branch starts with radius branchRadius and tapers to branchRadius*branchTaper over its length branchLength.
	**The parammeter branchSlices gives the number of cross sectional slices that the branch is divided into
	**The number of bows (bends) in the branch is given by bowFreq and the height of the bow by bowHeight
	*/
	static function createBranch(branchAt:Vector3, branchSys:CoordSys, branchLength:Float, branchTaper:Float, branchSlices:Int, bowFreq:Float, bowHeight:Float, branchRadius:Float, scene:Scene):Dynamic {          
		var _cross_section_paths:Array<Array<Vector3>> =  []; //array of paths, each path running along an outer length of the branch
		var _core_point:Vector3 = null;
		var _core_path:Array<Vector3> = []; //array of Vector3 points that give the path of the central core of the branch
		var _path:Vector3;
		var _xsr:Float = 0;
		var _radii:Array<Float> = []; // array of radii for each core point
		var _theta:Float = 0;
		var _a_sides:Int = 12; //number of sides for each cross sectional polygon slice
		for (a in 0..._a_sides) {
			_cross_section_paths[a] = [];
		}	
		
		var _d_slices_length:Float = 0;	
	   
		for (d in 0...branchSlices) {
			_d_slices_length = d / branchSlices;
			_core_point = branchSys.y.scale(_d_slices_length * branchLength); //central point along core path
			//add damped wave along branch to give bows
			_core_point.addInPlace(branchSys.x.scale(bowHeight * Math.exp( -_d_slices_length) * Math.sin(bowFreq * _d_slices_length * Math.PI)));	
			//set core point start at spur position.
			_core_point.addInPlace(branchAt);
			_core_path[d] = _core_point;
			
			//randomize radius by +/- 40% of radius and taper to branchTaper*100% of radius  at top			
			_xsr = branchRadius * (1 + (0.4 * Math.random() - 0.2)) * (1 - (1 - branchTaper) * _d_slices_length);
			_radii.push(_xsr);
			
			//determine the paths for each vertex of the cross sectional polygons
			for (a in 0..._a_sides) {
				_theta = a * Math.PI / 6;	
				//path followed by one point on cross section in branchSys.y direction
				_path = branchSys.x.scale(_xsr * Math.cos(_theta)).add(branchSys.z.scale(_xsr * Math.sin(_theta)));
				//align with core
				_path.addInPlace(_core_path[d]);
				_cross_section_paths[a].push(_path);        			
			}		
		}
		
		//Add cap at end of branch.
		for (a in 0..._a_sides) {
			_cross_section_paths[a].push(_core_path[_core_path.length - 1]);
		}		
		
		//Create ribbon mesh to repreent the branch.
		var _branch:Mesh = MeshBuilder.CreateRibbon("branch", { pathArray: _cross_section_paths, closeArray: true }, scene);
		
		return { branch: _branch, core: _core_path, _radii: _radii };
	} 

	/*
	**Creates a trunk and some branches. This is used as the base of the tree and as the base mesh for an SPS mesh to give additional branches. 
	**When boughs = 1 the trunk is created then branches are created at the top of the trunk, the number of branches being given by forks.
	**When boughs = 2 the trunk and branches are created as for boughs = 1, then further branches are created at the end of each of these branches.
	**The parameter forkRatio gives the fraction of branch length as branches are added to branches.
	**The angle of a new branch to the one it is growing from is given by forkAngle. 
	*/
	static function createTreeBase(trunkHeight:Float, trunkTaper:Float, trunkSlices:Int, boughs:Int, forks:Int, forkAngle:Float, forkRatio:Float, bowFreq:Float, bowHeight:Float, scene:Scene):Dynamic {   
		var _PHI:Float = 2 / (1 + Math.sqrt(5)); //golden ratio for scale	
		
		var _trunk_direction:Vector3 = new Vector3(0, 1, 0);  //trunk starts in y direction
		
		var _branch:Dynamic = null;
		
		var _trunk_sys:CoordSys = coordSystem(_trunk_direction);    
		var _trunk_root_at:Vector3 = new Vector3(0, 0, 0);
		var _tree_branches:Array<Mesh> = []; //Array holding the mesh of each branch
		var _tree_paths:Array<Array<Vector3>> = [];  //Array holding the central core points for each branch created
		var _tree_radii:Array<Array<Float>> = []; //Array holding the branch radius for each brnch created
		var _tree_directions:Array<CoordSys> = []; //Array holding the branch direction for each branch created
		
		var _trunk:Dynamic = createBranch(_trunk_root_at, _trunk_sys, trunkHeight, trunkTaper, trunkSlices, 1, bowHeight, 1, scene); //create trunk
		_tree_branches.push(_trunk.branch);
		var _core_path:Array<Vector3> = _trunk.core;
		_tree_paths.push(_core_path);
		_tree_radii.push(_trunk._radii);
		_tree_directions.push(_trunk_sys);
		
		var _core_top:Int = _core_path.length - 1;
		var _top_point:Vector3 = _core_path[_core_top];
		
		var _fork_turn:Float = 2 * Math.PI / forks; //angle of spread of forks around a branch
		
		var _fork_branch_direction:Vector3 = null;
		var _fork_branchSys:CoordSys = null;
		var _bough_direction:Vector3 = null;
		var _bough_sys:CoordSys = null;
		var _bough_core_path:Array<Vector3> = null;
		var _turn:Float = 0; 
		var _bough_turn:Float = 0;
		var _bough_top:Vector3 = null;
		var _bough:Dynamic = 0;
		
		//create new branch at top of trunk for number of forks
		for (f in 0...forks) {       
			_turn = randPct(f * _fork_turn, 0.25);	//randomise angle of spread for a fork	
			_fork_branch_direction = _trunk_sys.y.scale(Math.cos(randPct(forkAngle, 0.15))).add(_trunk_sys.x.scale(Math.sin(randPct(forkAngle, 0.15)) * Math.sin(_turn))).add(_trunk_sys.z.scale(Math.sin(randPct(forkAngle, 0.15)) * Math.cos(_turn)));
			_fork_branchSys = coordSystem(_fork_branch_direction);      		 
			_branch = createBranch(_top_point, _fork_branchSys, trunkHeight * forkRatio, trunkTaper, trunkSlices, bowFreq, bowHeight * _PHI, trunkTaper, scene);
			_bough_core_path = _branch.core;
			_bough_top = _bough_core_path[_bough_core_path.length - 1];
		  
			//store branch details
			_tree_branches.push(_branch.branch);
			_tree_paths.push(_branch.core);
			_tree_radii.push(_branch._radii);
			_tree_directions.push(_fork_branchSys);
			if (boughs > 1) { // When boughs = 2 create further branches at end of new branch
				for (k in 0...forks) {
					_bough_turn = randPct(k * _fork_turn, 0.25);
					_bough_direction = _fork_branchSys.y.scale(Math.cos(randPct(forkAngle, 0.15))).add(_fork_branchSys.x.scale(Math.sin(randPct(forkAngle, 0.15)) * Math.sin(_bough_turn))).add(_fork_branchSys.z.scale(Math.sin(randPct(forkAngle, 0.15)) * Math.cos(_bough_turn)));
					_bough_sys = coordSystem(_bough_direction);       		 
					_bough = createBranch(_bough_top, _bough_sys, trunkHeight * forkRatio * forkRatio, trunkTaper, trunkSlices, bowFreq, bowHeight * _PHI * _PHI, trunkTaper * trunkTaper, scene);
				 
					//store branch details
					_tree_branches.push(_bough.branch);
					_tree_paths.push(_bough.core);
					_tree_radii.push(_branch._radii);
					_tree_directions.push(_bough_sys);
				}
			}    
		}
		
		var _tree = Mesh.MergeMeshes(_tree_branches); //merge branch meshes into a single mesh
		return { tree: _tree, paths: _tree_paths, radii: _tree_radii, directions: _tree_directions };
	}

	/*Primary function that creates the tree.
	**
	** A base tree is created consisting of a trunk which forks into branches, which then themselves may fork or not.
	** This base tree is used in two different ways. 
	**    1. as the trunk and parent branches for the whole tree.
	**    2. with leaves added as a mini-tree that is added a number of times to the base trunk and parent branches to form the whole tree.
	**
	** @Param trunkHeight - height of trunk of tree.
	** @Param trunkTaper - 0< trunkTaper <1 - fraction of starting radius for the end radius of a branch. 
	** @Param trunkSlices - the number of points on the paths used for the ribbon mesh that forms the branch.
	** @Param trunk material - the material used on all branches.
	** @Param boughs - 1 or 2 only - the number of times the tree will split into forked branches, 1 trunk splits into branches, 2 these branches also spilt into branches.
	** @Param forks - 5 or more really slows the generation. The number of branches a branch can split into.
	** @Param forkAngle - the angle a forked branch makes with its parent branch measured from the direction of the branch.
	** @Param forkRatio - 0 < forkRatio < 1 - the ratio of the length of a branch to its parent's length.
	** @Param branches - the number of mini-trees that are randomally added to the tree..
	** @Param branchAngle - the angle the mini-tree makes with its parent branch from the direction of the branch.
	** @Param bowFreq - the number of bows (bends) in a branch. A trunk is set to have only one bow.
	** @Param bowHeight - the height of a bow from the line of direction of the branch.
	** @Param leavesOnBranch - the number of leaves to be added to one side of a branch.
	** @Param leafWHRatio - 0 <  leafWHRatio  < 1, closer to 0 longer leaf, closer to 1 more circular.
	** @Param leafMaterial -material used for all leaves.
	** @Param scene - BABYLON scene.
	*/
	public static function Generate(trunkHeight:Float, trunkTaper:Float, trunkSlices:Int, trunkMaterial:Material, boughs:Int, forks:Int, forkAngle:Float, forkRatio:Float, branches:Int, branchAngle:Float, bowFreq:Float, bowHeight:Float, leavesOnBranch:Int, leafWHRatio:Float, leafMaterial:Material, scene:Scene):Mesh {        
		if (!(boughs == 1 || boughs == 2)) {
			boughs = 1;
		}
		
		//create base tree  
		var _base:Dynamic = createTreeBase(trunkHeight, trunkTaper, trunkSlices, boughs, forks, forkAngle, forkRatio, bowFreq, bowHeight, scene);    
		_base.tree.material = trunkMaterial;
		
		//create one leaf
		var _branch_length:Float = trunkHeight * Math.pow(forkRatio, boughs);
		var _leaf_gap:Float = _branch_length / (2 * leavesOnBranch);
		var _leaf_width:Float = 1.5 * Math.pow(trunkTaper, boughs - 1);
		var _leaf:Mesh = MeshBuilder.CreateDisc("leaf", { radius: _leaf_width / 2, tessellation: 12, sideOrientation: Mesh.DOUBLESIDE }, scene);
		
		//create solid particle system for leaves 
		var _leaves_SPS:SolidParticleSystem = new SolidParticleSystem("leaveSPS", scene, { updatable: false });
		
		//function to position leaves on base tree
		var _set_leaves = function(particle:SolidParticle, i:Int, s:Int) {
			var _a = Math.floor(s / (2 * leavesOnBranch));
			if (boughs == 1) {
				_a++;
			}
			else {
				_a = 2 + _a % forks + Math.floor(_a / forks) * (forks + 1);
			}
			var _j = s % (2 * leavesOnBranch);
			var _g = (_j * _leaf_gap + 3 * _leaf_gap / 2) / _branch_length;
			
			var _upper:Int = Math.ceil(trunkSlices * _g);    
			if (_upper > _base.paths[_a].length - 1) {
				_upper = Std.int(_base.paths[_a].length - 1);
			}
			var _lower:Int = _upper - 1; 
			var _gl = _lower / (trunkSlices - 1);
			var _gu = _upper / (trunkSlices - 1);     
			var _px = _base.paths[_a][_lower].x  + (_base.paths[_a][_upper].x - _base.paths[_a][_lower].x) * (_g - _gl) / (_gu - _gl);
			var _py = _base.paths[_a][_lower].y  + (_base.paths[_a][_upper].y - _base.paths[_a][_lower].y) * (_g - _gl) / (_gu - _gl);
			var _pz = _base.paths[_a][_lower].z  + (_base.paths[_a][_upper].z - _base.paths[_a][_lower].z) * (_g - _gl) / (_gu - _gl);             
			particle.position = new Vector3(_px, _py + (0.6 * _leaf_width / leafWHRatio + _base.radii[_a][_upper]) * (2 * (s % 2) - 1), _pz); 
			particle.rotation.z = Math.random() * Math.PI / 4;
			particle.rotation.y = Math.random() * Math.PI / 2;
			particle.rotation.z = Math.random() * Math.PI / 4;
			particle.scaling.y = 1 / leafWHRatio;
		};
		
		//add leaf mesh _leaf enough for all the final forked branches
		_leaves_SPS.addShape(_leaf, Std.int(2 * leavesOnBranch * Math.pow(forks, boughs)), { positionFunction: _set_leaves });
		var _leaves:Mesh = _leaves_SPS.buildMesh(); // mesh of leaves
		//_leaves.billboardMode = AbstractMesh.BILLBOARDMODE_ALL;
		_leaf.dispose(); 
		
		//create SPS to use with base tree mesh base.tree
		var _mini_trees_SPS = new SolidParticleSystem("miniSPS", scene, { updatable: false });
		
		//create SPS to use with leaves mesh
		var _mini_leaves_SPS = new SolidParticleSystem("minileavesSPS", scene, { updatable: false });
		
		//The mini base trees and leaves added to both the SPS systems have to be positioned at the same places and angles.
		//An array of random angles are formed to be used by both the mini base trees and the leaves
		//when they are added as forks at the end of the final branches. 
		var _turns:Array<Float> = [];
		var _fork_turn:Float = 2 * Math.PI / forks;
		var _fmax = Std.int(Math.pow(forks, boughs + 1));
		for (f in 0..._fmax) {
			_turns.push(randPct(Math.floor(f / Math.pow(forks, boughs)) * _fork_turn, 0.2));
		}
		
		//the _set_mini_trees function positions mini base trees and leaves at the end of base tree branches, one for each of the forks
		var _set_mini_trees = function(particle:SolidParticle, i:Int, s:Int) {       
			var _a:Int = s % Std.int(Math.pow(forks, boughs));
			if (boughs == 1) {
				_a++;
			}
			else {
				_a = 2 + _a % forks + Math.floor(_a / forks) * (forks + 1);
			}
			var _mini_sys = _base.directions[_a];     
			var mini_top = new Vector3(_base.paths[_a][Std.int(_base.paths[_a].length - 1)].x, _base.paths[_a][Std.int(_base.paths[_a].length - 1)].y, _base.paths[_a][Std.int(_base.paths[_a].length - 1)].z);       
			var turn:Float = _turns[s];             
			var _mini_direction:Vector3 = _mini_sys.y.scale(Math.cos(randPct(forkAngle, 0))).add(_mini_sys.x.scale(Math.sin(randPct(forkAngle, 0)) * Math.sin(turn))).add(_mini_sys.z.scale(Math.sin(randPct(forkAngle, 0)) * Math.cos(turn)));
			var axis  = Vector3.Cross(Axis.Y, _mini_direction);
			var _theta = Math.acos(Vector3.Dot(_mini_direction, Axis.Y) / _mini_direction.length());
			particle.scaling = new Vector3(Math.pow(trunkTaper, boughs + 1), Math.pow(trunkTaper, boughs + 1), Math.pow(trunkTaper, boughs + 1));
			particle.rotationQuaternion = Quaternion.RotationAxis(axis, _theta);
			particle.position = mini_top;           
		}
		
		//The mini base trees and leaves added to both the SPS systems have to be positioned at the same places and angles.
		//An array of random positions and angles are formed to be used by both the mini base trees and the leaves
		//when they are added as random mini leafed trees to the forked tree. 
		//The random positions are chosen by selecting one of the random paths for a branch and a random point along the branch.
		var _bturns:Array<Float> = [];
		var _places:Array<Array<Int>> = [];
		var _bplen:Int = _base.paths.length;
		var _bp0len:Float = _base.paths[0].length;
		for (b in 0...branches) {
			_bturns.push(2 * Math.PI * Math.random() - Math.PI);
			_places.push([Math.floor(Math.random() * _bplen), Math.floor(Math.random() * (_bp0len - 1) + 1)]);
		}
		
		//the _set_branches function positions mini base trees and leaves at random positions along random branches
		var _set_branches = function(particle:SolidParticle, i:Int, s:Int) {              
			var _a:Int = _places[s][0];
			var _b:Int = _places[s][1];        
			var _mini_sys:CoordSys = _base.directions[_a];       
			var _mini_place:Vector3 = new Vector3(_base.paths[_a][_b].x, _base.paths[_a][_b].y, _base.paths[_a][_b].z);
			_mini_place.addInPlace(_mini_sys.z.scale(_base.radii[_a][_b] / 2));   
			var _turn:Float = _bturns[s];             
			var _mini_direction = _mini_sys.y.scale(Math.cos(randPct(branchAngle, 0))).add(_mini_sys.x.scale(Math.sin(randPct(branchAngle, 0)) * Math.sin(_turn))).add(_mini_sys.z.scale(Math.sin(randPct(branchAngle, 0)) * Math.cos(_turn)));
			var _axis:Vector3 = Vector3.Cross(Axis.Y, _mini_direction);
			var _theta:Float = Math.acos(Vector3.Dot(_mini_direction, Axis.Y) / _mini_direction.length());
			particle.scaling = new Vector3(Math.pow(trunkTaper, boughs + 1), Math.pow(trunkTaper, boughs + 1), Math.pow(trunkTaper, boughs + 1));
			particle.rotationQuaternion = Quaternion.RotationAxis(_axis, _theta);      
			particle.position = _mini_place;     
		}
		
		//add base tree mesh enough for all the final forked branches  
		_mini_trees_SPS.addShape(_base.tree, Std.int(Math.pow(forks, boughs + 1)), { positionFunction: _set_mini_trees });
		
		//add base tree mesh given the number of branches in that parameter. 
		_mini_trees_SPS.addShape(_base.tree, branches, { positionFunction: _set_branches });
		var _tree_crown:Mesh = _mini_trees_SPS.buildMesh(); // form mesh with all mini trees
		_tree_crown.material = trunkMaterial;
		
		//add leaves mesh enough for all the final forked branches  
		_mini_leaves_SPS.addShape(_leaves, Std.int(Math.pow(forks, boughs + 1)), { positionFunction: _set_mini_trees });
		
		//add leaves mesh given the number of branches in that parameter. 
		_mini_leaves_SPS.addShape(_leaves, branches, { positionFunction: _set_branches });   
		var _leaves_crown = _mini_leaves_SPS.buildMesh();  //form mesh of all leaves
		_leaves.dispose();
		_leaves_crown.material = leafMaterial;
		
		//Give the three mesh elements of full tree the same parent.
		var _root = Mesh.CreateBox("", 1, scene);
		_root.isVisible = false;
		_base.tree.parent = _root;
		_tree_crown.parent = _root;
		_leaves_crown.parent = _root;
		
		return _root;
	}
	
}
