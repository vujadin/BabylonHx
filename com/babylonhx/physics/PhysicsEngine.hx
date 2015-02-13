package com.babylonhx.physics;

import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.physics.plugins.OimoPlugin;

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

	private var _currentPlugin:IPhysicsEnginePlugin;
	

	public function new(?plugin:IPhysicsEnginePlugin) {
		this._currentPlugin = plugin != null ? plugin : new OimoPlugin();
	}

	public function _initialize(?gravity:Vector3) {
		this._currentPlugin.initialize();
		this._setGravity(gravity);
	}

	public function _runOneStep(delta:Float):Void {
		if (delta > 0.1) {
			delta = 0.1;
		} else if (delta <= 0) {
			delta = 1.0 / 60.0;
		}

		this._currentPlugin.runOneStep(delta);
	}

	public function _setGravity(?gravity:Vector3):Void {
		this.gravity = gravity != null ? gravity : new Vector3(0, -9.82, 0);
		this._currentPlugin.setGravity(this.gravity);
	}

	public function _registerMesh(mesh:AbstractMesh, impostor:Int, options:PhysicsBodyCreationOptions):Dynamic {
		return this._currentPlugin.registerMesh(mesh, impostor, options);
	}

	public function _registerMeshesAsCompound(parts:Array<PhysicsCompoundBodyPart>, options:PhysicsBodyCreationOptions):Dynamic {
		return this._currentPlugin.registerMeshesAsCompound(parts, options);
	}

	public function _unregisterMesh(mesh:AbstractMesh):Void {
		this._currentPlugin.unregisterMesh(mesh);
	}

	public function _applyImpulse(mesh:AbstractMesh, force:Vector3, contactPoint:Vector3):Void {
		this._currentPlugin.applyImpulse(mesh, force, contactPoint);
	}

	public function _createLink(mesh1:AbstractMesh, mesh2:AbstractMesh, pivot1:Vector3, pivot2:Vector3, ?options:Dynamic):Bool {
		return this._currentPlugin.createLink(mesh1, mesh2, pivot1, pivot2, options);
	}

	public function _updateBodyPosition(mesh:AbstractMesh):Void {
		this._currentPlugin.updateBodyPosition(mesh);
	}

	public function dispose():Void {
		this._currentPlugin.dispose();
	}

	public function isSupported():Bool {
		return this._currentPlugin.isSupported();
	}
	
}
