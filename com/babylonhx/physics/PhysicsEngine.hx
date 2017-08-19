package com.babylonhx.physics;

import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.AbstractMesh;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.PhysicsEngine') class PhysicsEngine {
	
	// Statics
	public static inline var NoImpostor:Int = 0;
	public static inline var SphereImpostor:Int = 1;
	public static inline var BoxImpostor:Int = 2;
	public static inline var PlaneImpostor:Int = 3;
	public static inline var MeshImpostor:Int = 4;
	public static inline var CapsuleImpostor:Int = 5;
	public static inline var ConeImpostor:Int = 6;
	public static inline var CylinderImpostor:Int = 7;
	public static inline var ConvexHullImpostor:Int = 8;
	public static inline var Epsilon:Float = 0.001;
	
	public var gravity:Vector3;

	private var _physicsPlugin:IPhysicsEnginePlugin;
	

	public function new(plugin:IPhysicsEnginePlugin) {
		this._physicsPlugin = plugin;
	}

	public function _initialize(?gravity:Vector3) {
		this._physicsPlugin.initialize();
		this._setGravity(gravity);
	}

	public function _runOneStep(delta:Float):Void {
		if (delta > 0.1) {
			delta = 0.1;
		} 
		else if (delta <= 0) {
			delta = 1.0 / 60.0;
		}
		
		this._physicsPlugin.runOneStep(delta);
	}

	public function _setGravity(?gravity:Vector3):Void {
		this.gravity = gravity != null ? gravity : new Vector3(0, -9.82, 0);
		this._physicsPlugin.setGravity(this.gravity);
	}
	
	/**
	 * Set the time step of the physics engine.
	 * default is 1/60.
	 * To slow it down, enter 1/600 for example.
	 * To speed it up, 1/30
	 * @param {number} newTimeStep the new timestep to apply to this world.
	 */
	public function setTimeStep(newTimeStep:Float = 1 / 60) {
		this._physicsPlugin.setTimeStep(newTimeStep);
	}

	/**
	 * Get the time step of the physics engine.
	 */
	public function getTimeStep():Float {
		return this._physicsPlugin.getTimeStep();
	}

	public function _registerMesh(mesh:AbstractMesh, impostor:Int, options:PhysicsBodyCreationOptions):Dynamic {
		return this._physicsPlugin.registerMesh(mesh, impostor, options);
	}

	public function _registerMeshesAsCompound(parts:Array<PhysicsCompoundBodyPart>, options:PhysicsBodyCreationOptions):Dynamic {
		return this._physicsPlugin.registerMeshesAsCompound(parts, options);
	}

	public function _unregisterMesh(mesh:AbstractMesh):Void {
		this._physicsPlugin.unregisterMesh(mesh);
	}

	public function _applyImpulse(mesh:AbstractMesh, force:Vector3, contactPoint:Vector3):Void {
		this._physicsPlugin.applyImpulse(mesh, force, contactPoint);
	}

	public function _createLink(mesh1:AbstractMesh, mesh2:AbstractMesh, pivot1:Vector3, pivot2:Vector3, ?options:Dynamic):Bool {
		return this._physicsPlugin.createLink(mesh1, mesh2, pivot1, pivot2, options);
	}

	public function _updateBodyPosition(mesh:AbstractMesh):Void {
		this._physicsPlugin.updateBodyPosition(mesh);
	}

	public function dispose():Void {
		this._physicsPlugin.dispose();
	}

	public function isSupported():Bool {
		if (this._physicsPlugin != null) {
			return this._physicsPlugin.isSupported();
		}
		
		return false;
	}
	
}
