package com.babylonhx.particles;

import com.babylonhx.tools.Observable;

/**
 * ...
 * @author Krtolica Vujadin
 */
class GPUParticleSystem implements IParticleSystem {

	// Members
	public var id:String;
	public var name:String;
	public var emitter:Dynamic = null;        
	public var renderingGroupId:Int = 0;        
	public var layerMask:Int = 0x0FFFFFFF;

	private var _scene:Scene;
	
	public var __smartArrayFlags:Array<Int> = [];	// BHX

	/**
	* An event triggered when the system is disposed.
	* @type {BABYLON.Observable}
	*/
	public var onDisposeObservable:Observable<GPUParticleSystem> = new Observable<GPUParticleSystem>();


	public function isStarted():Bool {
		return false;
	}  
	

	public function new(name:String, capacity:Int, ?scene:Scene) {
		this.id = name;
		this._scene = scene != null ? scene : Engine.LastCreatedScene;
		
		scene.particleSystems.push(this);
	}

	public function animate() {

	}

	public function render():Int {
		return 0;
	}

	public function dispose() {
		var index = this._scene.particleSystems.indexOf(this);
		if (index > -1) {
			this._scene.particleSystems.splice(index, 1);
		}
		
		// Callback
		this.onDisposeObservable.notifyObservers(this);
		this.onDisposeObservable.clear();
	}

	//TODO: Clone / Parse / serialize
	public function clone(name:String, ?newEmitter:Dynamic):GPUParticleSystem {
		return null;
	}

	public serialize():Dynamic {
		
	}
	
}
