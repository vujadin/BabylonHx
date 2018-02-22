package com.babylonhx.particles;

import com.babylonhx.animations.IAnimatable;
import com.babylonhx.engine.Engine;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.particles.emittertypes.IParticleEmitterType;
import com.babylonhx.tools.Observable;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.EffectCreationOptions;
import com.babylonhx.materials.Material;
import com.babylonhx.materials.textures.RawTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.Buffer;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;
import com.babylonhx.tools.Tools;
import com.babylonhx.animations.Animation;
import com.babylonhx.particles.emittertypes.BoxParticleEmitter;
import com.babylonhx.particles.emittertypes.SphereDirectedParticleEmitter;
import com.babylonhx.particles.emittertypes.SphereParticleEmitter;
import com.babylonhx.particles.emittertypes.ConeParticleEmitter;

import com.babylonhx.utils.GL;
import com.babylonhx.utils.GL.GLVertexArrayObject;
import com.babylonhx.utils.typedarray.Float32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
/**
 * This represents a GPU particle system in Babylon.
 * This os the fastest particle system in Babylon as it uses the GPU to update the individual particle data.
 * @see https://www.babylonjs-playground.com/#PU4WYI#4
 */
class GPUParticleSystem implements IParticleSystem implements IAnimatable {

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
	public var layerMask:Int = 0x0FFFFFFF;
	
	private var _capacity:Int;
	private var _activeCount:Int;
	private var _currentActiveCount:Int;
	private var _renderEffect:Effect;
	private var _updateEffect:Effect;

	private var _buffer0:Buffer;
	private var _buffer1:Buffer;
	private var _spriteBuffer:Buffer;
	private var _updateVAO:Array<GLVertexArrayObject>;
	private var _renderVAO:Array<GLVertexArrayObject>;

	private var _targetIndex:Int = 0;
	private var _sourceBuffer:Buffer;
	private var _targetBuffer:Buffer;

	private var _scene:Scene;
	private var _engine:Engine;

	private var _currentRenderId:Int = -1;    
	private var _started:Bool = false;    
	private var _stopped:Bool = false;    

	private var _timeDelta:Float = 0;

	private var _randomTexture:RawTexture;

	private static inline var _attributesStrideSize:Int = 14;
	private var _updateEffectOptions:EffectCreationOptions;

	private var _randomTextureSize:Int;
	private var _actualFrame:Float = 0;        

	/**
	 * List of animations used by the particle system.
	 */
	public var animations:Array<Animation> = [];        

	/**
	 * Gets a boolean indicating if the GPU particles can be rendered on current browser
	 */
	public static var IsSupported(get, never):Bool;
	static function get_IsSupported():Bool {
		if (Engine.LastCreatedEngine == null) {
			return false;
		}
		return Engine.LastCreatedEngine.webGLVersion > 1;
	} 
	
	public var __smartArrayFlags:Array<Int> = [];	// BHX

	/**
	* An event triggered when the system is disposed.
	*/
	public var onDisposeObservable:Observable<GPUParticleSystem> = new Observable<GPUParticleSystem>();

	/**
	 * The overall motion speed (0.01 is default update speed, faster updates = faster animation)
	 */
	public var updateSpeed:Float = 0.01;        

	/**
	 * The amount of time the particle system is running (depends of the overall update speed).
	 */
	public var targetStopDuration:Float = 0;        

	/**
	 * The texture used to render each particle. (this can be a spritesheet)
	 */
	public var particleTexture:Texture;   
	
	/**
	 * Blend mode use to render the particle, it can be either ParticleSystem.BLENDMODE_ONEONE or ParticleSystem.BLENDMODE_STANDARD.
	 */
	public var blendMode:Int = ParticleSystem.BLENDMODE_ONEONE;   
	
	/**
	 * Minimum life time of emitting particles.
	 */
	public var minLifeTime:Float = 1;
	/**
	 * Maximum life time of emitting particles.
	 */
	public var maxLifeTime:Float = 1;    

	/**
	 * Minimum Size of emitting particles.
	 */
	public var minSize:Float = 1;
	/**
	 * Maximum Size of emitting particles.
	 */
	public var maxSize:Float = 1;        
	
	/**
	 * Random color of each particle after it has been emitted, between color1 and color2 vectors.
	 */
	public var color1:Color4 = new Color4(1.0, 1.0, 1.0, 1.0);
	/**
	 * Random color of each particle after it has been emitted, between color1 and color2 vectors.
	 */
	public var color2:Color4 = new Color4(1.0, 1.0, 1.0, 1.0);  
	
	/**
	 * Color the particle will have at the end of its lifetime.
	 */
	public var colorDead:Color4 = new Color4(0, 0, 0, 0);        
	
	/**
	 * The maximum number of particles to emit per frame until we reach the activeParticleCount value
	 */
	public var emitRate:Int = 100; 
	
	/**
	 * You can use gravity if you want to give an orientation to your particles.
	 */
	public var gravity = Vector3.Zero();    

	/**
	 * Minimum power of emitting particles.
	 */
	public var minEmitPower:Float = 1;
	/**
	 * Maximum power of emitting particles.
	 */
	public var maxEmitPower:Float = 1;        

	/**
	 * The particle emitter type defines the emitter used by the particle system.
	 * It can be for example box, sphere, or cone...
	 */
	public var particleEmitterType:IParticleEmitterType;    

	public var direction1(get, set):Vector3;
	/**
	 * Random direction of each particle after it has been emitted, between direction1 and direction2 vectors.
	 * This only works when particleEmitterTyps is a BoxParticleEmitter
	 */
	function get_direction1():Vector3 {
		if (this.particleEmitterType.getClassName() == "BoxEmitter") {
			return untyped this.particleEmitterType.direction1;
		}		
		return Vector3.Zero();
	}
	function set_direction1(value:Vector3):Vector3 {
		if (this.particleEmitterType.getClassName() == "BoxEmitter") {
			untyped this.particleEmitterType.direction1 = value;
		}
		return value;
	}

	public var direction2(get, set):Vector3;
	/**
	 * Random direction of each particle after it has been emitted, between direction1 and direction2 vectors.
	 * This only works when particleEmitterTyps is a BoxParticleEmitter
	 */
	function get_direction2():Vector3 {
		if (this.particleEmitterType.getClassName() == "BoxEmitter") {
			return untyped this.particleEmitterType.direction2;
		}		
		return Vector3.Zero();
	}
	function set_direction2(value:Vector3):Vector3 {
		if (this.particleEmitterType.getClassName() == "BoxEmitter") {
			untyped this.particleEmitterType.direction2 = value;
		}
		return value;
	}

	public var minEmitBox(get, set):Vector3;
	/**
	 * Minimum box point around our emitter. Our emitter is the center of particles source, but if you want your particles to emit from more than one point, then you can tell it to do so.
	 * This only works when particleEmitterTyps is a BoxParticleEmitter
	 */
	function get_minEmitBox():Vector3 {
		if (this.particleEmitterType.getClassName() == "BoxEmitter") {
			return untyped this.particleEmitterType.minEmitBox;
		}		
		return Vector3.Zero();
	}
	function set_minEmitBox(value:Vector3):Vector3 {
		if (this.particleEmitterType.getClassName() == "BoxEmitter") {
			untyped this.particleEmitterType.minEmitBox = value;
		}
		return Vector3.Zero();
	}

	public var maxEmitBox(get, set):Vector3;
	/**
	 * Maximum box point around our emitter. Our emitter is the center of particles source, but if you want your particles to emit from more than one point, then you can tell it to do so.
	 * This only works when particleEmitterTyps is a BoxParticleEmitter
	 */
	function get_maxEmitBox():Vector3 {
		if (this.particleEmitterType.getClassName() == "BoxEmitter") {
			return untyped this.particleEmitterType.maxEmitBox;
		}
		return Vector3.Zero();
	}
	function set_maxEmitBox(value:Vector3):Vector3 {
		if (this.particleEmitterType.getClassName() == "BoxEmitter") {
			untyped this.particleEmitterType.maxEmitBox = value;
		}
		return Vector3.Zero();
	}       

	/**
	 * Gets the maximum number of particles active at the same time.
	 * @returns The max number of active particles.
	 */
	public function getCapacity():Int {
		return this._capacity;
	}

	/**
	 * Gets or set the number of active particles
	 */
	public var activeParticleCount(get, set):Int;
	function get_activeParticleCount():Int {
		return this._activeCount;
	}
	function set_activeParticleCount(value:Int):Int {
		return this._activeCount = Std.int(Math.min(value, this._capacity));
	}

	/**
	 * Gets Wether the system has been started.
	 * @returns True if it has been started, otherwise false.
	 */
	public function isStarted():Bool {
		return this._started;
	}

	/**
	 * Starts the particle system and begins to emit.
	 */
	public function start() {
		this._started = true;
		this._stopped = false;
	}

	/**
	 * Stops the particle system.
	 */
	public function stop() {
		this._stopped = true;
	}

	/**
	 * Remove all active particles
	 */
	public function reset() {
		this._releaseBuffers();
		this._releaseVAOs();   
		this._currentActiveCount = 0;         
		this._targetIndex = 0;
	}      
	
	/**
	 * Returns the string "GPUParticleSystem"
	 * @returns a string containing the class name 
	 */
	public function getClassName():String {
		return "GPUParticleSystem";
	} 
	

	/**
	 * Instantiates a GPU particle system.
	 * Particles are often small sprites used to simulate hard-to-reproduce phenomena like fire, smoke, water, or abstract visual effects like magic glitter and faery dust.
	 * @param name The name of the particle system
	 * @param capacity The max number of particles alive at the same time
	 * @param scene The scene the particle system belongs to
	 */
	public function new(name:String, options:Dynamic, scene:Scene) {
		this.id = name;
		this.name = name;
		this._scene = scene != null ? scene : Engine.LastCreatedScene;
	    this._engine = this._scene.getEngine();
		
		var fullOptions = {
			capacity: 50000,
			randomTextureSize: this._engine.getCaps().maxTextureSize
		};
		
		Tools.ExtendOptions(options, fullOptions);
		
		this._capacity = fullOptions.capacity;
		this._activeCount = fullOptions.capacity;
		this._currentActiveCount = 0;
		
		scene.particleSystems.push(this);
		
		this._updateEffectOptions = {
			attributes: ["position", "age", "life", "seed", "size", "color", "direction"],
			uniformsNames: ["currentCount", "timeDelta", "generalRandoms", "emitterWM", "lifeTime", "color1", "color2", "sizeRange", "gravity", "emitPower",
							"direction1", "direction2", "minEmitBox", "maxEmitBox", "radius", "directionRandomizer", "height", "angle"],
			uniformBuffersNames: [],
			samplers:["randomSampler"],
			defines: "",
			fallbacks: null,  
			onCompiled: null,
			onError: null,
			indexParameters: null,
			maxSimultaneousLights: 0,                                                      
			transformFeedbackVaryings: ["outPosition", "outAge", "outLife", "outSeed", "outSize", "outColor", "outDirection"]
		};
		
		// Random data
		var maxTextureSize:Int = cast Math.min(this._engine.getCaps().maxTextureSize, fullOptions.randomTextureSize);
		var d:Array<Float> = [];
		for (i in 0...maxTextureSize) {
			d.push(Math.random());
			d.push(Math.random());
			d.push(Math.random());
			d.push(Math.random());
		}
		this._randomTexture = new RawTexture(new Float32Array(d), maxTextureSize, 1, Engine.TEXTUREFORMAT_RGBA32F, this._scene, false, false, Texture.NEAREST_SAMPLINGMODE, Engine.TEXTURETYPE_FLOAT);
		this._randomTexture.wrapU = Texture.WRAP_ADDRESSMODE;
		this._randomTexture.wrapV = Texture.WRAP_ADDRESSMODE;
		
		this._randomTextureSize = maxTextureSize;
		this.particleEmitterType = new BoxParticleEmitter();  
	}
	
	private function _createUpdateVAO(source:Buffer):GLVertexArrayObject {            
		var updateVertexBuffers:Map<String, VertexBuffer> = new Map();
		updateVertexBuffers["position"] = source.createVertexBuffer("position", 0, 3);
		updateVertexBuffers["age"] = source.createVertexBuffer("age", 3, 1);
		updateVertexBuffers["life"] = source.createVertexBuffer("life", 4, 1);
		updateVertexBuffers["seed"] = source.createVertexBuffer("seed", 5, 1);
		updateVertexBuffers["size"] = source.createVertexBuffer("size", 6, 1);
		updateVertexBuffers["color"] = source.createVertexBuffer("color", 7, 4);
		updateVertexBuffers["direction"] = source.createVertexBuffer("direction", 11, 3);
	   
		var vao = this._engine.recordVertexArrayObject(updateVertexBuffers, null, this._updateEffect);
		this._engine.bindArrayBuffer(null);
		
		return vao;
	}

	private function _createRenderVAO(source:Buffer, spriteSource:Buffer):GLVertexArrayObject {            
		var renderVertexBuffers:Map<String, VertexBuffer> = new Map();
		renderVertexBuffers["position"] = source.createVertexBuffer("position", 0, 3, _attributesStrideSize, true);
		renderVertexBuffers["age"] = source.createVertexBuffer("age", 3, 1, _attributesStrideSize, true);
		renderVertexBuffers["life"] = source.createVertexBuffer("life", 4, 1, _attributesStrideSize, true);
		renderVertexBuffers["size"] = source.createVertexBuffer("size", 6, 1, _attributesStrideSize, true);           
		renderVertexBuffers["color"] = source.createVertexBuffer("color", 7, 4, _attributesStrideSize, true);
		
		renderVertexBuffers["offset"] = spriteSource.createVertexBuffer("offset", 0, 2);
		renderVertexBuffers["uv"] = spriteSource.createVertexBuffer("uv", 2, 2);
	  
		var vao = this._engine.recordVertexArrayObject(renderVertexBuffers, null, this._renderEffect);
		this._engine.bindArrayBuffer(null);
		
		return vao;
	}        
	
	private function _initialize(force:Bool = false) {
		if (this._buffer0 != null && !force) {
			return;
		}
		
		var engine = this._scene.getEngine();
		var data:Array<Float> = [];
		for (particleIndex in 0...this._capacity) {
			// position
			data.push(0.0);
			data.push(0.0);
			data.push(0.0);
			
			// Age and life
			data.push(0.0); // create the particle as a dead one to create a new one at start
			data.push(0.0);
			
			// Seed
			data.push(Math.random());
			
			// Size
			data.push(0.0);
			
			// color
			data.push(0.0);
			data.push(0.0);
			data.push(0.0);                     
			data.push(0.0); 
			
			// direction
			data.push(0.0);
			data.push(0.0);
			data.push(0.0);              
		}
		
		// Sprite data
		var spriteData = new Float32Array([
			 0.5,  0.5,  1, 1,  
			-0.5,  0.5,  0, 1,
			-0.5, -0.5,  0, 0,   
			 0.5, -0.5,  1, 0
		]);
		
		// Buffers
		this._buffer0 = new Buffer(engine, new Float32Array(data), false, _attributesStrideSize);
		this._buffer1 = new Buffer(engine, new Float32Array(data), false, _attributesStrideSize);
		this._spriteBuffer = new Buffer(engine, spriteData, false, 4);
		
		// Update VAO
		this._updateVAO = [];
		this._updateVAO.push(this._createUpdateVAO(this._buffer0));
		this._updateVAO.push(this._createUpdateVAO(this._buffer1));
		
		// Render VAO
		this._renderVAO = [];
		this._renderVAO.push(this._createRenderVAO(this._buffer1, this._spriteBuffer));
		this._renderVAO.push(this._createRenderVAO(this._buffer0, this._spriteBuffer));
		
		// Links
		this._sourceBuffer = this._buffer0;
		this._targetBuffer = this._buffer1;
	}

	/** @ignore */
	public function _recreateUpdateEffect() {
		var defines = this.particleEmitterType != null ? this.particleEmitterType.getEffectDefines() : "";
		if (this._updateEffect != null && this._updateEffectOptions.defines == defines) {
			return;
		}
		this._updateEffectOptions.defines = defines;
		this._updateEffect = new Effect("gpuUpdateParticles", this._updateEffectOptions, this._scene.getEngine());   
	}

	/** @ignore */
	public function _recreateRenderEffect() {
		var defines:String = "";
		if (this._scene.clipPlane != null) {
			defines = "\n#define CLIPPLANE";
		}
		
		if (this._renderEffect != null && this._renderEffect.defines == defines) {
			return;
		}
		
		this._renderEffect = new Effect("gpuRenderParticles", 
										["position", "age", "life", "size", "color", "offset", "uv"], 
										["view", "projection", "colorDead", "invView", "vClipPlane"], 
										["textureSampler"], this._scene.getEngine(), defines);
	}        

	/**
	 * Animates the particle system for the current frame by emitting new particles and or animating the living ones.
	 */
	public function animate() {           
		if (!this._stopped) {
			this._timeDelta = this.updateSpeed * this._scene.getAnimationRatio();   
			this._actualFrame += this._timeDelta;
			
			if (this.targetStopDuration > 0 && this._actualFrame >= this.targetStopDuration) {
				this.stop();
			}
		} 
		else {
			this._timeDelta = 0;
		}             
	}        

	/**
	 * Renders the particle system in its current state.
	 * @returns the current number of particles
	 */
	public function render():Int {
		if (!this._started) {
			return 0;
		}
		
		this._recreateUpdateEffect();
		this._recreateRenderEffect();
		
		if (this.emitter == null || !this._updateEffect.isReady() || !this._renderEffect.isReady() ) {
			return 0;
		}
		
		if (this._currentRenderId == this._scene.getRenderId()) {
			return 0;
		}
		
		this._currentRenderId = this._scene.getRenderId();      
		
		// Get everything ready to render
		this._initialize();
		
		this._currentActiveCount = cast Math.min(this._activeCount, this._currentActiveCount + Std.int(this.emitRate * this._timeDelta));
		
		// Enable update effect
		this._engine.enableEffect(this._updateEffect);
		this._engine.setState(false);    
		
		this._updateEffect.setFloat("currentCount", this._currentActiveCount);
		this._updateEffect.setFloat("timeDelta", this._timeDelta);
		this._updateEffect.setFloat3("generalRandoms", Math.random(), Math.random(), Math.random());
		this._updateEffect.setTexture("randomSampler", this._randomTexture);
		this._updateEffect.setFloat2("lifeTime", this.minLifeTime, this.maxLifeTime);
		this._updateEffect.setFloat2("emitPower", this.minEmitPower, this.maxEmitPower);
		this._updateEffect.setDirectColor4("color1", this.color1);
		this._updateEffect.setDirectColor4("color2", this.color2);
		this._updateEffect.setFloat2("sizeRange", this.minSize, this.maxSize);
		this._updateEffect.setVector3("gravity", this.gravity);
		
		if (this.particleEmitterType != null) {
			this.particleEmitterType.applyToShader(this._updateEffect);
		}
		
		var emitterWM:Matrix = null;
		if (this.emitter.position != null) {
			var emitterMesh:AbstractMesh = cast this.emitter;
			emitterWM = emitterMesh.getWorldMatrix();
		} 
		else {
			var emitterPosition:Vector3 = cast this.emitter;
			emitterWM = Matrix.Translation(emitterPosition.x, emitterPosition.y, emitterPosition.z);
		}            
		this._updateEffect.setMatrix("emitterWM", emitterWM);
		
		// Bind source VAO
		this._engine.bindVertexArrayObject(this._updateVAO[this._targetIndex], null);
		
		// Update
		this._engine.bindTransformFeedbackBuffer(this._targetBuffer.getBuffer().buffer);
		this._engine.setRasterizerState(false);
		this._engine.beginTransformFeedback();
		this._engine.drawArraysType(Material.PointListDrawMode, 0, this._currentActiveCount, 0);
		this._engine.endTransformFeedback();
		this._engine.setRasterizerState(true);
		this._engine.bindTransformFeedbackBuffer(null);
		
		// Enable render effect
		this._engine.enableEffect(this._renderEffect);
		var viewMatrix = this._scene.getViewMatrix();
		this._renderEffect.setMatrix("view", viewMatrix);
		this._renderEffect.setMatrix("projection", this._scene.getProjectionMatrix());
		this._renderEffect.setTexture("textureSampler", this.particleTexture);
		this._renderEffect.setDirectColor4("colorDead", this.colorDead);
		
		if (this._scene.clipPlane != null) {
			var clipPlane = this._scene.clipPlane;
			var invView = viewMatrix.clone();
			invView.invert();
			this._renderEffect.setMatrix("invView", invView);
			this._renderEffect.setFloat4("vClipPlane", clipPlane.normal.x, clipPlane.normal.y, clipPlane.normal.z, clipPlane.d);
		}
		
		// Draw order
		if (this.blendMode == ParticleSystem.BLENDMODE_ONEONE) {
			this._engine.setAlphaMode(Engine.ALPHA_ONEONE);
		} 
		else {
			this._engine.setAlphaMode(Engine.ALPHA_COMBINE);
		}
		
		// Bind source VAO
		this._engine.bindVertexArrayObject(this._renderVAO[this._targetIndex], null);
		
		// Render
		this._engine.drawArraysType(Material.TriangleFanDrawMode, 0, 4, this._currentActiveCount);   
		this._engine.setAlphaMode(Engine.ALPHA_DISABLE);
		
		// Switch VAOs
		this._targetIndex++;
		if (this._targetIndex == 2) {
			this._targetIndex = 0;
		}
		
		// Switch buffers
		var tmpBuffer = this._sourceBuffer;
		this._sourceBuffer = this._targetBuffer;
		this._targetBuffer = tmpBuffer;
		
		return this._currentActiveCount;
	}

	/**
	 * Rebuilds the particle system
	 */
	public function rebuild() {
		this._initialize(true);
	}

	private function _releaseBuffers() {
		if (this._buffer0 != null) {
			this._buffer0.dispose();
			this._buffer0 = null;
		}
		if (this._buffer1 != null) {
			this._buffer1.dispose();
			this._buffer1 = null;
		}
		if (this._spriteBuffer != null) {
			this._spriteBuffer.dispose();
			this._spriteBuffer = null;
		}            
	}

	private function _releaseVAOs() {
		for (index in 0...this._updateVAO.length) {
			this._engine.releaseVertexArrayObject(this._updateVAO[index]);
		}
		this._updateVAO = [];
		
		for (index in 0...this._renderVAO.length) {
			this._engine.releaseVertexArrayObject(this._renderVAO[index]);
		}
		this._renderVAO = [];   
	}

	/**
	 * Disposes the particle system and free the associated resources
	 * @param disposeTexture defines if the particule texture must be disposed as well (true by default)
	 */
	public function dispose(disposeTexture:Bool = true) {
		var index = this._scene.particleSystems.indexOf(this);
		if (index > -1) {
			this._scene.particleSystems.splice(index, 1);
		}
		
		this._releaseBuffers();
		this._releaseVAOs();
		
		if (this._randomTexture != null) {
			this._randomTexture.dispose();
			this._randomTexture = null;
		}
		
		if (disposeTexture && this.particleTexture != null) {
			this.particleTexture.dispose();
			this.particleTexture = null;
		}
		
		// Callback
		this.onDisposeObservable.notifyObservers(this);
		this.onDisposeObservable.clear();
	}
	
	/**
	 * Clones the particle system.
	 * @param name The name of the cloned object
	 * @param newEmitter The new emitter to use
	 * @returns the cloned particle system
	 */
	public function clone(name:String, newEmitter:Dynamic):GPUParticleSystem {
		var result = new GPUParticleSystem(name, { capacity: this._capacity, randomTextureSize: this._randomTextureSize }, this._scene);
		
		//Tools.DeepCopy(this, result);
		
		if (newEmitter == null) {
			newEmitter = this.emitter;
		}
		
		result.emitter = newEmitter;
		if (this.particleTexture != null) {
			result.particleTexture = new Texture(this.particleTexture.url, this._scene);
		}
		
		return result;
	}

	/**
	 * Serializes the particle system to a JSON object.
	 * @returns the JSON object
	 */
	public function serialize() {
		var serializationObject:Dynamic = {};
		
		serializationObject.name = this.name;
		serializationObject.id = this.id;
		
		// Emitter
		if (this.emitter.position != null) {
			var emitterMesh:AbstractMesh = cast this.emitter;
			serializationObject.emitterId = emitterMesh.id;
		} 
		else {
			var emitterPosition:Vector3 = cast this.emitter;
			serializationObject.emitter = emitterPosition.asArray();
		}
		
		serializationObject.capacity = this.getCapacity();
		
		if (this.particleTexture != null) {
			serializationObject.textureName = this.particleTexture.name;
		}
		
		// Animations
		Animation.AppendSerializedAnimations(this, serializationObject);
		
		// Particle system
		serializationObject.activeParticleCount = this.activeParticleCount;
		serializationObject.randomTextureSize = this._randomTextureSize;
		serializationObject.minSize = this.minSize;
		serializationObject.maxSize = this.maxSize;
		serializationObject.minEmitPower = this.minEmitPower;
		serializationObject.maxEmitPower = this.maxEmitPower;
		serializationObject.minLifeTime = this.minLifeTime;
		serializationObject.maxLifeTime = this.maxLifeTime;
		serializationObject.emitRate = this.emitRate;
		serializationObject.gravity = this.gravity.asArray();
		serializationObject.color1 = this.color1.asArray();
		serializationObject.color2 = this.color2.asArray();
		serializationObject.colorDead = this.colorDead.asArray();
		serializationObject.updateSpeed = this.updateSpeed;
		serializationObject.targetStopDuration = this.targetStopDuration;
		serializationObject.blendMode = this.blendMode;
		
		// Emitter
		if (this.particleEmitterType != null) {
			serializationObject.particleEmitterType = this.particleEmitterType.serialize();
		}
		
		return serializationObject;            
	}

	/**
	 * Parses a JSON object to create a GPU particle system.
	 * @param parsedParticleSystem The JSON object to parse
	 * @param scene The scene to create the particle system in
	 * @param rootUrl The root url to use to load external dependencies like texture
	 * @returns the parsed GPU particle system
	 */
	public static function Parse(parsedParticleSystem:Dynamic, scene:Scene, rootUrl:String):GPUParticleSystem {
		var name = parsedParticleSystem.name;
		var particleSystem = new GPUParticleSystem(name, { capacity: parsedParticleSystem.capacity, randomTextureSize: parsedParticleSystem.randomTextureSize }, scene);
		
		if (parsedParticleSystem.id != null) {
			particleSystem.id = parsedParticleSystem.id;
		}
		
		// Texture
		if (parsedParticleSystem.textureName != null) {
			particleSystem.particleTexture = new Texture(rootUrl + parsedParticleSystem.textureName, scene);
			particleSystem.particleTexture.name = parsedParticleSystem.textureName;
		}
		
		// Emitter
		if (parsedParticleSystem.emitterId != null) {
			particleSystem.emitter = scene.getLastMeshByID(parsedParticleSystem.emitterId);
		} 
		else {
			particleSystem.emitter = Vector3.FromArray(parsedParticleSystem.emitter);
		}
		
		// Animations
		if (parsedParticleSystem.animations != null) {
			for (animationIndex in 0...parsedParticleSystem.animations.length) {
				var parsedAnimation = parsedParticleSystem.animations[animationIndex];
				particleSystem.animations.push(Animation.Parse(parsedAnimation));
			}
		}
		
		// Particle system
		particleSystem.activeParticleCount = parsedParticleSystem.activeParticleCount;
		particleSystem.minSize = parsedParticleSystem.minSize;
		particleSystem.maxSize = parsedParticleSystem.maxSize;
		particleSystem.minLifeTime = parsedParticleSystem.minLifeTime;
		particleSystem.maxLifeTime = parsedParticleSystem.maxLifeTime;
		particleSystem.minEmitPower = parsedParticleSystem.minEmitPower;
		particleSystem.maxEmitPower = parsedParticleSystem.maxEmitPower;
		particleSystem.emitRate = parsedParticleSystem.emitRate;
		particleSystem.gravity = Vector3.FromArray(parsedParticleSystem.gravity);
		particleSystem.color1 = Color4.FromArray(parsedParticleSystem.color1);
		particleSystem.color2 = Color4.FromArray(parsedParticleSystem.color2);
		particleSystem.colorDead = Color4.FromArray(parsedParticleSystem.colorDead);
		particleSystem.updateSpeed = parsedParticleSystem.updateSpeed;
		particleSystem.targetStopDuration = parsedParticleSystem.targetStopDuration;
		particleSystem.blendMode = parsedParticleSystem.blendMode;
		
		// Emitter
		if (parsedParticleSystem.particleEmitterType != null) {
			var emitterType:IParticleEmitterType = null;
			switch (parsedParticleSystem.particleEmitterType.type) {
				case "SphereEmitter":
					emitterType = new SphereParticleEmitter();
					
				case "SphereDirectedParticleEmitter":
					emitterType = new SphereDirectedParticleEmitter();
					
				case "ConeEmitter":
					emitterType = new ConeParticleEmitter();
					
				case "BoxEmitter":
					emitterType = new BoxParticleEmitter();
					
				default:
					emitterType = new BoxParticleEmitter();
			}
			
			emitterType.parse(parsedParticleSystem.particleEmitterType);
			particleSystem.particleEmitterType = emitterType;
		}
		
		return particleSystem;
	}
	
}
