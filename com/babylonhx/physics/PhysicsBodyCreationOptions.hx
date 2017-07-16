package com.babylonhx.physics;

import com.babylonhx.tools.Tools;

/**
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.PhysicsBodyCreationOptions') class PhysicsBodyCreationOptions {
	
	public var name:String = "";
	public var mass:Null<Float>;
	public var friction:Null<Float>;
	public var restitution:Null<Float>;
	
	
	public function new(?mass:Float, ?friction:Float, ?restitution:Float, ?name:String = "") {
		this.name = name != "" ? name : Tools.uuid();
		this.mass = mass;
		this.friction = friction;
		this.restitution = restitution;
	}
	
}
