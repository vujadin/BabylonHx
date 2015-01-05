package com.babylonhx.physics.plugins;

import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.physics.IPhysicsEnginePlugin;
import com.babylonhx.physics.PhysicsEngine;
import com.babylonhx.physics.PhysicsBodyCreationOptions;


/**
 * ...
 * @author Krtolica Vujadin
 */

class OimoPlugin implements IPhysicsEnginePlugin {
	
	//private var _world:World;
	//private var _registeredMeshes:Array<Dynamic> = [];
	
	
	public function new() {
		
	}
	
	public function initialize(?iterations:Int):Void {
		//this._world = new World();
		//this._world.clear();
	}
	
	public function setGravity(gravity:Vector3):Void {
		//this._world.gravity = gravity;
	}
	
	public function runOneStep(delta:Float):Void {
		
	}
	
	public function registerMesh(mesh:AbstractMesh, impostor:Int, options:PhysicsBodyCreationOptions):Dynamic {
		return null;
	}
	
	public function registerMeshesAsCompound(parts:Array<PhysicsCompoundBodyPart>, options:PhysicsBodyCreationOptions):Dynamic {
		return null;
	}
	
	public function unregisterMesh(mesh:AbstractMesh):Void {
		
	}
	
	public function applyImpulse(mesh:AbstractMesh, force:Vector3, contactPoint:Vector3):Void {
		
	}
	
	public function createLink(mesh1:AbstractMesh, mesh2:AbstractMesh, pivot1:Vector3, pivot2:Vector3, ?options:Dynamic):Bool {
		return false;
	}
	
	public function dispose():Void {
		
	}
	
	public function isSupported():Bool {
		return false;
	}
	
	public function updateBodyPosition(mesh:AbstractMesh):Void {
		
	}
	
}
