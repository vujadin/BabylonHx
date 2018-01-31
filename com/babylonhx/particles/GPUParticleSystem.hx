package com.babylonhx.particles;

import com.babylonhx.engine.Engine;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.tools.Observable;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.EffectCreationOptions;
import com.babylonhx.mesh.Buffer;

import lime.graphics.opengl.GLVertexArrayObject;
import lime.utils.Float32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
/**
 * This represents a GPU particle system in Babylon.
 * This os the fastest particle system in Babylon as it uses the GPU to update the individual particle data.
 */
class GPUParticleSystem implements IParticleSystem {

	/**
	 * The id of the Particle system.
	 */
	public var id:String;
	
	/**
	 * The friendly name of the Particle system.
	 */
	public var name:String;
	
	/**
	 * The emitter represents the Mesh or position we are attaching the particle system to.
	 */
	public var emitter:Dynamic = null;		// AbstractMesh | Vector3
	
	/**
	 * The rendering group used by the Particle system to chose when to render.
	 */
	public var renderingGroupId:Int = 0;
	
	/**
	 * The layer mask we are rendering the particles through.
	 */
	public var layerMask:Int = 0x0FFFFFFF;  // TODO
	
	private var _capacity:Int;
	private var _renderEffect:Effect;
	private var _updateEffect:Effect;

	private var _updateBuffer: Buffer;
	private var _updateVAO:GLVertexArrayObject;
	private var _updateVertexBuffers:Map<String, VertexBuffer> = new Map();
	private var _renderBuffer:Buffer;
	private var _renderVAO:GLVertexArrayObject;
	private var _renderVertexBuffers:Map<String, VertexBuffer> = new Map();

	private var _sourceVAO:GLVertexArrayObject;
	private var _targetVAO:GLVertexArrayObject;
	private var _sourceBuffer:Buffer;
	private var _targetBuffer:Buffer;

	private var _scene:Scene;
	private var _engine:Engine;

	private var _currentRenderId:Int = -1;    
	private var _started:Bool = true; 
	
	public var __smartArrayFlags:Array<Int> = [];	// BHX

	/**
	* An event triggered when the system is disposed.
	*/
	public var onDisposeObservable:Observable<GPUParticleSystem> = new Observable<GPUParticleSystem>();

	/**
	 * Gets Wether the system has been started.
	 * @returns True if it has been started, otherwise false.
	 */
	public function isStarted():Bool {
		return false;
	}
	
	/**
	 * Starts the particle system and begins to emit.
	 */
	public function start() {
		this._started = true;
	}

	/**
	 * Stops the particle system.
	 */
	public function stop() {
		this._started = false;
	} 
	

	/**
	 * Instantiates a GPU particle system.
	 * Particles are often small sprites used to simulate hard-to-reproduce phenomena like fire, smoke, water, or abstract visual effects like magic glitter and faery dust.
	 * @param name The name of the particle system
	 * @param capacity The max number of particles alive at the same time
	 * @param scene The scene the particle system belongs to
	 */
	public function new(name:String, capacity:Int, ?scene:Scene) {
		this.id = name;
		this.name = name;
		this._scene = scene != null ? scene : Engine.LastCreatedScene;
		this._capacity = capacity;
	    this._engine = this._scene.getEngine();
		
		scene.particleSystems.push(this);
		
		this._renderEffect = new Effect("gpuRenderParticles", ["position", "age", "life", "velocity"], [], [], this._scene.getEngine());
		
		var updateEffectOptions:EffectCreationOptions = {
			attributes: ["position", "age", "life", "velocity"],
			uniformsNames: [],
			uniformBuffersNames: [],
			samplers:[],
			defines: "",
			fallbacks: null,  
			onCompiled: null,
			onError: null,
			indexParameters: null,
			maxSimultaneousLights: 0,                                                      
			transformFeedbackVaryings: ["outPosition", "outAge", "outLife", "outVelocity"]
		};
		
		this._updateEffect = new Effect("gpuUpdateParticles", updateEffectOptions, this._scene.getEngine());  
	}
	
	/**
	 * Animates the particle system for the current frame by emitting new particles and or animating the living ones.
	 */
	public function animate() {
		// Do nothing
	}

	private function _initialize() {
		if (this._renderVAO != null) {
			return;
		}
		
		var data:Array<Float> = [];
		for (particleIndex in 0...this._capacity) {
			// position
			data.push(0.0);
			data.push(0.0);
			data.push(0.0);
			
			var life = 1 + Math.random() * 10; // TODO: var
			data.push(life + 1); // create the particle as a dead one to create a new one at start
			data.push(life);
			
			// velocity
			data.push(0.0);
			data.push(0.0);
			data.push(0.0);
		}
		
		// Update VAO
		this._updateBuffer = new Buffer(this._scene.getEngine(), new Float32Array(data), false, 0);
		this._updateVertexBuffers["position"] = this._updateBuffer.createVertexBuffer("position", 0, 3, 3);
		this._updateVertexBuffers["age"] = this._updateBuffer.createVertexBuffer("age", 3, 1, 1);
		this._updateVertexBuffers["life"] = this._updateBuffer.createVertexBuffer("life", 4, 1, 1);
		this._updateVertexBuffers["velocity"] = this._updateBuffer.createVertexBuffer("velocity", 5, 3, 3);
	   
		this._updateVAO = this._engine.recordVertexArrayObject(this._updateVertexBuffers, null, this._updateEffect);
		this._engine.bindArrayBuffer(null);
		
		// Render VAO
		this._renderBuffer = new Buffer(this._scene.getEngine(), new Float32Array(data), false, 0);
		this._renderVertexBuffers["position"] = this._renderBuffer.createVertexBuffer("position", 0, 3, 3);
		this._renderVertexBuffers["age"] = this._renderBuffer.createVertexBuffer("age", 3, 1, 1);
		this._renderVertexBuffers["life"] = this._renderBuffer.createVertexBuffer("life", 4, 1, 1);
		this._renderVertexBuffers["velocity"] = this._renderBuffer.createVertexBuffer("velocity", 5, 3, 3);
	   
		this._renderVAO = this._engine.recordVertexArrayObject(this._renderVertexBuffers, null, this._renderEffect);  
		this._engine.bindArrayBuffer(null);
		
		// Links
		this._sourceVAO = this._updateVAO;
		this._targetVAO = this._renderVAO;
		
		this._sourceBuffer = this._updateBuffer;
		this._targetBuffer = this._renderBuffer;
	}

	/**
	 * Renders the particle system in its current state.
	 * @returns the current number of particles.
	 */
	public function render():Int {
		if (this.emitter == null| | !this._updateEffect.isReady() || !this._renderEffect.isReady() ) {
			return 0;
		}
		
		// Get everything ready to render
		this._initialize();
		
		if (this._currentRenderId == this._scene.getRenderId()) {
			return 0;
		}
		
		this._currentRenderId = this._scene.getRenderId(); 
		
		// Enable update effect
		this._engine.enableEffect(this._updateEffect);
		this._engine.setState(false);
		
		// Bind source VAO
		this._engine.bindVertexArrayObject(this._sourceVAO, null);
		
		// Update
		this._engine.bindTransformFeedbackBuffer(this._targetBuffer.getBuffer());
		this._engine.setRasterizerState(false);
		this._engine.beginTransformFeedback();
		this._engine.drawArraysType(Material.PointListDrawMode, 0, this._capacity);
		this._engine.endTransformFeedback();
		this._engine.setRasterizerState(true);
		this._engine.bindTransformFeedbackBuffer(null);
		
		// Enable render effect
		this._engine.enableEffect(this._renderEffect);
		
		// Bind source VAO
		this._engine.bindVertexArrayObject(this._targetVAO, null);
		
		// Render
		this._engine.drawArraysType(Material.PointListDrawMode, 0, this._capacity);
		
		// Switch VAOs
		var tmpVAO = this._sourceVAO;
		this._sourceVAO = this._targetVAO;
		this._targetVAO = tmpVAO;
		
		// Switch buffers
		var tmpBuffer = this._sourceBuffer;
		this._sourceBuffer = this._targetBuffer;
		this._targetBuffer = tmpBuffer;
		
		return 0;
	}

	/**
	 * Rebuilds the particle system
	 */
	public function rebuild() {
		
	}

	/**
	 * Disposes the particle system and free the associated resources.
	 */
	public function dispose() {
		var index = this._scene.particleSystems.indexOf(this);
		if (index > -1) {
			this._scene.particleSystems.splice(index, 1);
		}
		
		//TODO: this._dataBuffer.dispose();
		
		// Callback
		this.onDisposeObservable.notifyObservers(this);
		this.onDisposeObservable.clear();
	}

	//TODO: Clone / Parse / serialize
	
	/**
	 * Clones the particle system.
	 * @param name The name of the cloned object
	 * @param newEmitter The new emitter to use
	 * @returns the cloned particle system
	 */
	public function clone(name:String, ?newEmitter:Dynamic):GPUParticleSystem {
		return null;
	}

	/**
	 * Serializes the particle system to a JSON object.
	 * @returns the JSON object
	 */
	public serialize():Dynamic {
		
	}
	
}
