package com.babylonhx.particles;

import com.babylonhx.engine.Engine;
import com.babylonhx.ISmartArrayCompatible;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.Material;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Scalar;
import com.babylonhx.mesh.WebGLBuffer;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.mesh.Buffer;
import com.babylonhx.particles.Particle;
import com.babylonhx.particles.emittertypes.BoxParticleEmitter;
import com.babylonhx.particles.emittertypes.ConeParticleEmitter;
import com.babylonhx.particles.emittertypes.IParticleEmitterType;
import com.babylonhx.particles.emittertypes.SphereDirectedParticleEmitter;
import com.babylonhx.particles.emittertypes.SphereParticleEmitter;
import com.babylonhx.tools.Tools;
import com.babylonhx.animations.IAnimatable;
import com.babylonhx.animations.Animation;
import com.babylonhx.tools.Observable;
import com.babylonhx.tools.Observer;
import com.babylonhx.tools.EventState;

import com.babylonhx.utils.typedarray.UInt32Array;
import com.babylonhx.utils.typedarray.Float32Array;


/**
 * ...
 * @author Krtolica Vujadin
 */
/**
 * This represents a particle system in Babylon.
 * Particles are often small sprites used to simulate hard-to-reproduce phenomena like fire, smoke, water, or abstract visual effects like magic glitter and faery dust.
 * Particles can take different shapes while emitted like box, sphere, cone or you can write your custom function.
 * @example https://doc.babylonjs.com/babylon101/particles
 */
@:expose('BABYLON.ParticleSystem') class ParticleSystem implements IAnimatable implements IParticleSystem {
	
	/**
	 * Source color is added to the destination color without alpha affecting the result.
	 */
	public static inline var BLENDMODE_ONEONE:Int = 0;
	/**
	 * Blend current color and particle color using particle’s alpha.
	 */
	public static inline var BLENDMODE_STANDARD:Int = 1;
	

	/**
	 * List of animations used by the particle system.
	 */
	public var animations:Array<Animation> = [];
	
	/**
	 * The id of the Particle system.
	 */
	public var id:String;
	
	/**
	 * The name of the Particle system.
	 */
	public var name:String;
	
	/**
	 * ID of the rendering group used by the Particle system to chose when to render.
	 */
	public var renderingGroupId:Int = 0;
	
	/**
	 * The emitter represents the Mesh or position we are attaching the particle system to.
	 */
	public var emitter:Dynamic = null;		// AbstractMesh | Vector3
	
	/**
	 * The density of particles, the rate of particle flow
	 */
	public var emitRate:Int = 10;
	
	/**
	 * If you want to launch only a few particles at once, that can be done, as well.
	 */
	public var manualEmitCount:Int = -1;
	
	/**
	 * The overall motion speed (0.01 is default update speed, faster updates = faster animation)
	 */
	public var updateSpeed:Float = 0.01;
	
	/**
	 * The amount of time the particle system is running (depends of the overall speed above).
	 */
	public var targetStopDuration:Float = 0;
	
	/**
	 * Specifies whether the particle system will be disposed once it reaches the end of the animation.
	 */
	public var disposeOnStop:Bool = false;

	/**
	 * Minimum power of emitting particles.
	 */
	public var minEmitPower:Float = 1;
	/**
	 * Maximum power of emitting particles.
	 */
	public var maxEmitPower:Float = 1;

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
	 * Minimum angular speed of emitting particles (Z-axis rotation for each particle).
	 */
	public var minAngularSpeed:Float = 0;
	/**
	 * Maximum angular speed of emitting particles (Z-axis rotation for each particle).
	 */
	public var maxAngularSpeed:Float = 0;

	/**
	 * The texture used to render each particle. (this can be a spritesheet)
	 */
	public var particleTexture:Texture;
	
	/**
	 * The layer mask we are rendering the particles through.
	 */
	public var layerMask:Int = 0x0FFFFFFF;
	
	/**
	 * This can help using your own shader to render the particle system.
	 * The according effect will be created 
	 */
	public var customShader:Dynamic = null;
	
	/**
	 * By default particle system starts as soon as they are created. This prevents the 
	 * automatic start to happen and let you decide when to start emitting particles.
	 */
	public var preventAutoStart:Bool = false;
	
	/**
	 * This function can be defined to provide custom update for active particles.
	 * This function will be called instead of regular update (age, position, color, etc.).
	 * Do not forget that this function will be called on every frame so try to keep it simple and fast :)
	 */
	public var updateFunction:Array<Particle>->Void;
	
	/**
	 * Callback triggered when the particle animation is ending.
	 */
	public var onAnimationEnd:Void->Void = null;

	/**
	 * Blend mode use to render the particle, it can be either ParticleSystem.BLENDMODE_ONEONE or ParticleSystem.BLENDMODE_STANDARD.
	 */
	public var blendMode:Int = ParticleSystem.BLENDMODE_ONEONE;

	/**
	 * Forces the particle to write their depth information to the depth buffer. This can help preventing other draw calls
	 * to override the particles.
	 */
	public var forceDepthWrite:Bool = false;

	/**
	 * You can use gravity if you want to give an orientation to your particles.
	 */
	public var gravity:Vector3 = Vector3.Zero();
	
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
	 * Random color of each particle after it has been emitted, between color1 and color2 vectors.
	 */
	public var color1:Color4 = new Color4(1.0, 1.0, 1.0, 0.5);
	/**
	 * Random color of each particle after it has been emitted, between color1 and color2 vectors.
	 */
	public var color2:Color4 = new Color4(1.0, 1.0, 1.0, 0.4);
	/**
	 * Color the particle will have at the end of its lifetime.
	 */
	public var colorDead:Color4 = new Color4(0, 0, 0, 0.0);
	
	/**
	 * An optional mask to filter some colors out of the texture, or filter a part of the alpha channel.
	 */
	public var textureMask:Color4 = new Color4(1.0, 1.0, 1.0, 1.0);
	
	/**
	 * The particle emitter type defines the emitter used by the particle system.
	 * It can be for example box, sphere, or cone...
	 */
	public var particleEmitterType:IParticleEmitterType;
	
	/**
	 * This function can be defined to specify initial direction for every new particle.
	 * It by default use the emitterType defined function.
	 */
	public var startDirectionFunction:Float->Matrix->Vector3->Particle-> Void;
	/**
	 * This function can be defined to specify initial position for every new particle.
	 * It by default use the emitterType defined function.
	 */
	public var startPositionFunction:Matrix->Vector3->Particle-> Void;
	
	/**
	 * If using a spritesheet (isAnimationSheetEnabled), defines if the sprite animation should loop between startSpriteCellID and endSpriteCellID or not.
	 */
	public var spriteCellLoop:Bool = true;
	/**
	 * If using a spritesheet (isAnimationSheetEnabled) and spriteCellLoop defines the speed of the sprite loop.
	 */
	public var spriteCellChangeSpeed:Float = 0;
	/**
	 * If using a spritesheet (isAnimationSheetEnabled) and spriteCellLoop defines the first sprite cell to display.
	 */
	public var startSpriteCellID:Int = 0;
	/**
	 * If using a spritesheet (isAnimationSheetEnabled) and spriteCellLoop defines the last sprite cell to display.
	 */
	public var endSpriteCellID:Int = 0;
	/**
	 * If using a spritesheet (isAnimationSheetEnabled), defines the sprite cell width to use.
	 */
	public var spriteCellWidth:Int = 0;
	/**
	 * If using a spritesheet (isAnimationSheetEnabled), defines the sprite cell height to use.
	 */
	public var spriteCellHeight:Int = 0;
	
	/**
	* An event triggered when the system is disposed.
	* @type {BABYLON.Observable}
	*/
	public var onDisposeObservable:Observable<ParticleSystem> = new Observable<ParticleSystem>();
	private var _onDisposeObserver:Observer<ParticleSystem>;
	public var onDispose:ParticleSystem->Null<EventState>->Void;
	private function set_onDispose(callback:ParticleSystem->Null<EventState>->Void) {
		if (this._onDisposeObserver != null) {
			this.onDisposeObservable.remove(this._onDisposeObserver);
		}
		this._onDisposeObserver = this.onDisposeObservable.add(callback);
		
		return callback;
	}
	
	/**
	 * Gets wether an animation sprite sheet is enabled or not on the particle system.
	 */
	private var _isAnimationSheetEnabled:Bool = false;
	public var isAnimationSheetEnabled(get, never):Bool;
	inline private function get_isAnimationSheetEnabled():Bool {
		return this._isAnimationSheetEnabled;
	}

	private var _particles:Array<Particle> = [];
	private var _epsilon:Float;
	private var _capacity:Int;
	private var _scene:Scene;
	private var _stockParticles:Array<Particle> = [];
	private var _newPartsExcess:Int = 0;
	private var _vertexData:Float32Array;
	private var _vertexBuffer:Buffer;
	private var _vertexBuffers:Map<String, VertexBuffer> = new Map();
	private var _indexBuffer:WebGLBuffer;	
	private var _effect:Effect;
	private var _customEffect:Effect;
	private var _cachedDefines:String;
	private var _scaledColorStep:Color4 = new Color4(0, 0, 0, 0);
	private var _colorDiff:Color4 = new Color4(0, 0, 0, 0);
	private var _scaledDirection:Vector3 = Vector3.Zero();
	private var _scaledGravity:Vector3 = Vector3.Zero();
	private var _currentRenderId:Int = -1;
	private var _alive:Bool = true;
	private var _started:Bool = false;
	private var _stopped:Bool = false;
	private var _actualFrame:Int = 0;
	public var _scaledUpdateSpeed:Float;
	private var _vertexBufferSize:Int = 11;
	
	private var _engine:Engine;	
	public var __smartArrayFlags:Array<Int> = [];	// BHX
	
	/**
	 * Gets the current list of active particles
	 */
	public var particles(get, never):Array<Particle>;
	inline function get_particles():Array<Particle> {
		return this._particles;
	}

	/**
	 * Returns the string "ParticleSystem"
	 * @returns a string containing the class name
	 */
	public function getClassName():String {
		return "ParticleSystem";
	} 
	

	/**
	 * Instantiates a particle system.
	 * Particles are often small sprites used to simulate hard-to-reproduce phenomena like fire, smoke, water, or abstract visual effects like magic glitter and faery dust.
	 * @param name The name of the particle system
	 * @param capacity The max number of particles alive at the same time
	 * @param scene The scene the particle system belongs to
	 * @param customEffect a custom effect used to change the way particles are rendered by default
	 * @param isAnimationSheetEnabled Must be true if using a spritesheet to animate the particles texture
	 * @param epsilon Offset used to render the particles
	 */
	public function new(name:String, capacity:Int, ?scene:Scene, ?customEffect:Effect, isAnimationSheetEnabled:Bool = false, epsilon:Float = 0.01) {
		this.id = name;
		this.name = name;
		
		this._capacity = capacity;
		
		this._epsilon = epsilon;
		this._isAnimationSheetEnabled = isAnimationSheetEnabled;
		if (this._isAnimationSheetEnabled) {
			this._vertexBufferSize = 12;
		}
		
		this._scene = scene != null ? scene : Engine.LastCreatedScene;
		this._engine = this._scene.getEngine();
		
		this._customEffect = customEffect;
		
		scene.particleSystems.push(this);
		
		this._createIndexBuffer();
		
		// 11 floats per particle (x, y, z, r, g, b, a, angle, size, offsetX, offsetY) + 1 filler
        this._vertexData = new Float32Array(Std.int(capacity * this._vertexBufferSize * 4)); 
		this._vertexBuffer = new Buffer(this._engine, this._vertexData, true, this._vertexBufferSize);
		
		var positions = this._vertexBuffer.createVertexBuffer(VertexBuffer.PositionKind, 0, 3);
		var colors = this._vertexBuffer.createVertexBuffer(VertexBuffer.ColorKind, 3, 4);
		var options = this._vertexBuffer.createVertexBuffer("options", 7, 4);
		
		if (this._isAnimationSheetEnabled) {
			var cellIndexBuffer = this._vertexBuffer.createVertexBuffer("cellIndex", 11, 1);
			this._vertexBuffers["cellIndex"] = cellIndexBuffer;
		}
		
		this._vertexBuffers[VertexBuffer.PositionKind] = positions;
		this._vertexBuffers[VertexBuffer.ColorKind] = colors;
		this._vertexBuffers["options"] = options;
		
		// Default behaviors
		this.particleEmitterType = new BoxParticleEmitter();
		
		this.updateFunction = function(particles:Array<Particle>) {
			var index:Int = 0;
			while (index < particles.length && index >= 0) {
				var particle = particles[index];
				particle.age += this._scaledUpdateSpeed;
				
				if (particle.age >= particle.lifeTime) { // Recycle by swapping with last particle
					this.recycleParticle(particle);
					index--;
					continue;
				}
				else {
					particle.colorStep.scaleToRef(this._scaledUpdateSpeed, this._scaledColorStep);
					particle.color.addInPlace(this._scaledColorStep);
					
					if (particle.color.a < 0) {
						particle.color.a = 0;
					}
					
					particle.angle += particle.angularSpeed * this._scaledUpdateSpeed;
					
					particle.direction.scaleToRef(this._scaledUpdateSpeed, this._scaledDirection);
					particle.position.addInPlace(this._scaledDirection);
					
					this.gravity.scaleToRef(this._scaledUpdateSpeed, this._scaledGravity);
					particle.direction.addInPlace(this._scaledGravity);
					
					if (this._isAnimationSheetEnabled) {
						particle.updateCellIndex(this._scaledUpdateSpeed);
					}
				}
				
				++index;
			}
		}		
	}
	
	private function _createIndexBuffer() {
		var indices:Array<Int> = [];
		var index:Int = 0;
		for (count in 0...this._capacity) {
			indices.push(index);
			indices.push(index + 1);
			indices.push(index + 2);
			indices.push(index);
			indices.push(index + 2);
			indices.push(index + 3);
			index += 4;
		}
		
		this._indexBuffer = this._engine.createIndexBuffer(new UInt32Array(indices));
	}
	
	/**
	 * "Recycles" one of the particle by copying it back to the "stock" of particles and removing it from the active list.
	 * Its lifetime will start back at 0.
	 * @param particle The particle to recycle
	 */
	inline public function recycleParticle(particle:Particle) {
		var lastParticle = this._particles.pop();
		
		if (lastParticle != particle) {
			lastParticle.copyTo(particle);
			this._stockParticles.push(lastParticle);
		}
	}

	/**
	 * Gets the maximum number of particles active at the same time.
	 * @returns The max number of active particles.
	 */
	inline public function getCapacity():Int {
		return this._capacity;
	}

	/**
	 * Gets Wether there are still active particles in the system.
	 * @returns True if it is alive, otherwise false.
	 */
	inline public function isAlive():Bool {
		return this._alive;
	}

	/**
	 * Gets Wether the system has been started.
	 * @returns True if it has been started, otherwise false.
	 */
	inline public function isStarted():Bool {
		return this._started;
	}

	/**
	 * Starts the particle system and begins to emit.
	 */
	public function start() {
		this._started = true;
		this._stopped = false;
		this._actualFrame = 0;
	}

	/**
	 * Stops the particle system.
	 */
	public function stop():Void {
		this._stopped = true;
	}
	
	/**
	 * Remove all active particles
	 */
	public function reset() {
		this._stockParticles = [];
		this._particles = [];
	}
	
	/**
	 * @ignore (for internal use only)
	 */
	public function _appendParticleVertex(index:Int, particle:Particle, offsetX:Float, offsetY:Float) {
		var offset = index * 11;
		this._vertexData[offset] = particle.position.x;
		this._vertexData[offset + 1] = particle.position.y;
		this._vertexData[offset + 2] = particle.position.z;
		this._vertexData[offset + 3] = particle.color.r;
		this._vertexData[offset + 4] = particle.color.g;
		this._vertexData[offset + 5] = particle.color.b;
		this._vertexData[offset + 6] = particle.color.a;
		this._vertexData[offset + 7] = particle.angle;
		this._vertexData[offset + 8] = particle.size;
		this._vertexData[offset + 9] = offsetX;
		this._vertexData[offset + 10] = offsetY;
	}
	
	/**
	 * @ignore (for internal use only)
	 */
	public function _appendParticleVertexWithAnimation(index:Int, particle:Particle, offsetX:Float, offsetY:Float) {
		if (offsetX == 0) {
			offsetX = this._epsilon;
		}
		else if (offsetX == 1) {
			offsetX = 1 - this._epsilon;
		}
		
		if (offsetY == 0) {
			offsetY = this._epsilon;
		}
		else if (offsetY == 1) {
			offsetY = 1 - this._epsilon;
		}
		
		var offset = index * this._vertexBufferSize;
		this._vertexData[offset] = particle.position.x;
		this._vertexData[offset + 1] = particle.position.y;
		this._vertexData[offset + 2] = particle.position.z;
		this._vertexData[offset + 3] = particle.color.r;
		this._vertexData[offset + 4] = particle.color.g;
		this._vertexData[offset + 5] = particle.color.b;
		this._vertexData[offset + 6] = particle.color.a;
		this._vertexData[offset + 7] = particle.angle;
		this._vertexData[offset + 8] = particle.size;
		this._vertexData[offset + 9] = offsetX;
		this._vertexData[offset + 10] = offsetY;
		this._vertexData[offset + 11] = particle.cellIndex;
	}

	static var worldMatrix:Matrix = Matrix.Zero();
	private function _update(newParticles:Int) {
		// Update current
		this._alive = this._particles.length > 0;
		
		this.updateFunction(this._particles);
		
		// Add new ones		
		if (this.emitter.position != null) {
			worldMatrix = this.emitter.getWorldMatrix();
		} 
		else {
			worldMatrix = Matrix.Translation(this.emitter.x, this.emitter.y, this.emitter.z);
		}
		
		var particle:Particle = null;
		for (index in 0...newParticles) {
			if (this._particles.length == this._capacity) {
				break;
			}
			
			if (this._stockParticles.length != 0) {
				particle = this._stockParticles.pop();
				particle.age = 0;
				particle.cellIndex = this.startSpriteCellID;
			} 
			else {
				particle = new Particle(this);
			}
			
			this._particles.push(particle);
			
			var emitPower = Scalar.RandomRange(this.minEmitPower, this.maxEmitPower);
			
			if (this.startPositionFunction != null) {
                this.startPositionFunction(worldMatrix, particle.position, particle);
            }
            else {
                this.particleEmitterType.startPositionFunction(worldMatrix, particle.position, particle);
            }
			
			if (this.startDirectionFunction != null) {
                this.startDirectionFunction(emitPower, worldMatrix, particle.direction, particle);
            }
            else {
                this.particleEmitterType.startDirectionFunction(emitPower, worldMatrix, particle.direction, particle);
            }
			
			particle.lifeTime = Scalar.RandomRange(this.minLifeTime, this.maxLifeTime);
			
			particle.size = Scalar.RandomRange(this.minSize, this.maxSize);
            particle.angularSpeed = Scalar.RandomRange(this.minAngularSpeed, this.maxAngularSpeed);
			
			var step =Scalar.RandomRange(0, 1.0);
			
			Color4.LerpToRef(this.color1, this.color2, step, particle.color);
			
			this.colorDead.subtractToRef(particle.color, this._colorDiff);
			this._colorDiff.scaleToRef(1.0 / particle.lifeTime, particle.colorStep);
		}
	}

	private function _getEffect():Effect {
		if (this._customEffect != null) {
			return this._customEffect;
		}
		
		var defines:Array<String> = [];
		
		if (this._scene.clipPlane != null) {
			defines.push("#define CLIPPLANE");
		}
		
		if (this._isAnimationSheetEnabled) {
			defines.push("#define ANIMATESHEET");
		}
		
		// Effect
		var join = defines.join("\n");
		if (this._cachedDefines != join) {
			this._cachedDefines = join;
			
			var attributesNamesOrOptions:Array<String> = [];
			var effectCreationOption:Array<String> = [];
			
			if (this._isAnimationSheetEnabled) {
				attributesNamesOrOptions = [VertexBuffer.PositionKind, VertexBuffer.ColorKind, "options", "cellIndex"];
				effectCreationOption = ["invView", "view", "projection", "particlesInfos", "vClipPlane", "textureMask"];
			}
			else {
				attributesNamesOrOptions = [VertexBuffer.PositionKind, VertexBuffer.ColorKind, "options"];
				effectCreationOption = ["invView", "view", "projection", "vClipPlane", "textureMask"];
			}
			
			this._effect = this._scene.getEngine().createEffect(
				"particles",
				attributesNamesOrOptions,
				effectCreationOption,
				["diffuseSampler"], join);
		}
		
		return this._effect;
	}

	/**
	 * Animates the particle system for the current frame by emitting new particles and or animating the living ones.
	 */
	public function animate() {
		if (!this._started) {
			return;
		}
		
		var effect = this._getEffect();
		
		// Check
		if (this.emitter == null || !effect.isReady() || this.particleTexture == null || !this.particleTexture.isReady()) {
			return;
		}
			
		if (this._currentRenderId == this._scene.getRenderId()) {
			return;
		}
		
		this._currentRenderId = this._scene.getRenderId();
		
		this._scaledUpdateSpeed = this.updateSpeed * this._scene.getAnimationRatio();
		
		// determine the number of particles we need to create   
		var newParticles:Int = 0;
		
		if (this.manualEmitCount > -1) {
			newParticles = this.manualEmitCount;
			this._newPartsExcess = 0;
			this.manualEmitCount = 0;
		} 
		else {
			newParticles = Std.int(this.emitRate * this._scaledUpdateSpeed);
			this._newPartsExcess += Std.int(this.emitRate * this._scaledUpdateSpeed) - newParticles;
		}
		
		if (this._newPartsExcess > 1.0) {
			newParticles += this._newPartsExcess;
			this._newPartsExcess -= this._newPartsExcess;
		}
		
		this._alive = false;
		
		if (!this._stopped) {
			this._actualFrame += cast this._scaledUpdateSpeed;
			
			if (this.targetStopDuration != 0 && this._actualFrame >= this.targetStopDuration) {
				this.stop();
			}
		} 
		else {
			newParticles = 0;
		}
		
		this._update(newParticles);
		
		// Stopped?
		if (this._stopped) {
			if (!this._alive) {
				this._started = false;
				if (this.onAnimationEnd != null) {
                    this.onAnimationEnd();
                }
				if (this.disposeOnStop) {
					this._scene._toBeDisposed.push(this);
				}
			}
		}
		
		// Animation sheet
		if (this._isAnimationSheetEnabled) {
			this.appendParticleVertexes = this.appenedParticleVertexesWithSheet;
		}
		else {
			this.appendParticleVertexes = this.appenedParticleVertexesNoSheet;
		}
		
		// Update VBO
		var offset:Int = 0;
		for (index in 0...this._particles.length) {
			var particle = this._particles[index];
			this.appendParticleVertexes(offset, particle);
			offset += 4;
		}
		
		if (this._vertexBuffer != null) {
            this._vertexBuffer.update(this._vertexData);
        }
	}
	
	public var appendParticleVertexes:Int->Particle->Void = null;

	private function appenedParticleVertexesWithSheet(offset:Int, particle:Particle) {
		this._appendParticleVertexWithAnimation(offset++, particle, 0, 0);
		this._appendParticleVertexWithAnimation(offset++, particle, 1, 0);
		this._appendParticleVertexWithAnimation(offset++, particle, 1, 1);
		this._appendParticleVertexWithAnimation(offset++, particle, 0, 1);
	}

	private function appenedParticleVertexesNoSheet(offset:Int, particle:Particle) {
		this._appendParticleVertex(offset++, particle, 0, 0);
		this._appendParticleVertex(offset++, particle, 1, 0);
		this._appendParticleVertex(offset++, particle, 1, 1);
		this._appendParticleVertex(offset++, particle, 0, 1);
	}
	
	/**
	 * Rebuilds the particle system.
	 */
	public function rebuild() {
        this._createIndexBuffer();
		
		if (this._vertexBuffer != null) {
			this._vertexBuffer._rebuild();
		}
    }

	/**
	 * Renders the particle system in its current state.
	 * @returns the current number of particles.
	 */
	public function render():Int {		
		// Check
		if (this.emitter == null || !this._effect.isReady() || this.particleTexture == null || !this.particleTexture.isReady() || this._particles.length == 0) {
			return 0;
		}
		
		// Render
		this._engine.enableEffect(this._effect);
		this._engine.setState(false);
		
		var viewMatrix = this._scene.getViewMatrix();
		this._effect.setTexture("diffuseSampler", this.particleTexture);
		this._effect.setMatrix("view", viewMatrix);
		this._effect.setMatrix("projection", this._scene.getProjectionMatrix());
		
		if (this._isAnimationSheetEnabled) {
			var baseSize = this.particleTexture.getBaseSize();
			this._effect.setFloat3("particlesInfos", this.spriteCellWidth / baseSize.width, this.spriteCellHeight / baseSize.height, baseSize.width / this.spriteCellWidth);
		}
		
		this._effect.setFloat4("textureMask", this.textureMask.r, this.textureMask.g, this.textureMask.b, this.textureMask.a);
		
		if (this._scene.clipPlane != null) {
			var clipPlane = this._scene.clipPlane;
			var invView = viewMatrix.clone();
			invView.invert();
			this._effect.setMatrix("invView", invView);
			this._effect.setFloat4("vClipPlane", clipPlane.normal.x, clipPlane.normal.y, clipPlane.normal.z, clipPlane.d);
		}
		
		// VBOs
		this._engine.bindBuffers(this._vertexBuffers, this._indexBuffer, this._effect);
		
		// Draw order
		if (this.blendMode == ParticleSystem.BLENDMODE_ONEONE) {
			this._engine.setAlphaMode(Engine.ALPHA_ONEONE);
		} 
		else {
			this._engine.setAlphaMode(Engine.ALPHA_COMBINE);
		}
		
		if (this.forceDepthWrite) {
			this._engine.setDepthWrite(true);
		}
		
		this._engine.drawElementsType(Material.TriangleFillMode, 0, this._particles.length * 6);
		this._engine.setAlphaMode(Engine.ALPHA_DISABLE);
		
		return this._particles.length;
	}

	/*
	 * Disposes the particle system and free the associated resources
	 * @param disposeTexture defines if the particule texture must be disposed as well (true by default)
	 */
	public function dispose(disposeTexture:Bool = true) {
		if (this._vertexBuffer != null) {
			this._vertexBuffer.dispose();
			this._vertexBuffer = null;
		}
		
		if (this._indexBuffer != null) {
			this._engine._releaseBuffer(this._indexBuffer);
			this._indexBuffer = null;
		}
		
		if (disposeTexture && this.particleTexture != null) {
			this.particleTexture.dispose();
			this.particleTexture = null;
		}
		
		// Remove from scene
		this._scene.particleSystems.remove(this);
		
		// Callback
		this.onDisposeObservable.notifyObservers(this);
        this.onDisposeObservable.clear();
	}
	
	/**
	 * Creates a Sphere Emitter for the particle system. (emits along the sphere radius)
	 * @param radius The radius of the sphere to emit from
	 * @returns the emitter
	 */
	public function createSphereEmitter(radius:Float = 1):SphereParticleEmitter {
        var particleEmitter = new SphereParticleEmitter(radius);
        this.particleEmitterType = particleEmitter;
        return particleEmitter;
    }

	/**
	 * Creates a Directed Sphere Emitter for the particle system. (emits between direction1 and direction2)
	 * @param radius The radius of the sphere to emit from
	 * @param direction1 Particles are emitted between the direction1 and direction2 from within the sphere
	 * @param direction2 Particles are emitted between the direction1 and direction2 from within the sphere
	 * @returns the emitter
	 */
    public function createDirectedSphereEmitter(radius:Float = 1, ?direction1:Vector3, ?direction2:Vector3):SphereDirectedParticleEmitter {
		if (direction1 == null) {
			direction1 = new Vector3(0, 1.0, 0);
		}
		if (direction2 == null) {
			direction2 = new Vector3(0, 1.0, 0);
		}
        var particleEmitter = new SphereDirectedParticleEmitter(radius, direction1, direction2);
        this.particleEmitterType = particleEmitter;
        return particleEmitter;
    }

	/**
	 * Creates a Cone Emitter for the particle system. (emits from the cone to the particle position)
	 * @param radius The radius of the cone to emit from
	 * @param angle The base angle of the cone
	 * @returns the emitter
	 */
    public function createConeEmitter(radius:Float = 1, angle:Float = 0.7854):ConeParticleEmitter {
        var particleEmitter = new ConeParticleEmitter(radius, angle);
        this.particleEmitterType = particleEmitter;
        return particleEmitter;
    }

    // this method needs to be changed when breaking changes will be allowed to match the sphere and cone methods and properties direction1,2 and minEmitBox,maxEmitBox to be removed from the system.
	/**
	 * Creates a Box Emitter for the particle system. (emits between direction1 and direction2 from withing the box defined by minEmitBox and maxEmitBox)
	 * @param direction1 Particles are emitted between the direction1 and direction2 from within the box
	 * @param direction2 Particles are emitted between the direction1 and direction2 from within the box
	 * @param minEmitBox Particles are emitted from the box between minEmitBox and maxEmitBox
	 * @param maxEmitBox  Particles are emitted from the box between minEmitBox and maxEmitBox
	 * @returns the emitter
	 */
    public function createBoxEmitter(direction1:Vector3, direction2:Vector3, minEmitBox:Vector3, maxEmitBox:Vector3):BoxParticleEmitter {
        var particleEmitter = new BoxParticleEmitter();
        this.direction1 = direction1;
        this.direction2 = direction2;
        this.minEmitBox = minEmitBox;
        this.maxEmitBox = maxEmitBox;
        this.particleEmitterType = particleEmitter;
        return particleEmitter;
    }

	/**
	 * Clones the particle system.
	 * @param name The name of the cloned object
	 * @param newEmitter The new emitter to use
	 * @returns the cloned particle system
	 */
	public function clone(name:String, newEmitter:Dynamic):ParticleSystem {
		var custom:Effect = null;
		var program:Dynamic = null;
		if (this.customShader != null) {
			program = this.customShader;
			var defines:String = (program.shaderOptions.defines.length > 0) ? program.shaderOptions.defines.join("\n") : "";
			custom = this._engine.createEffectForParticles(program.shaderPath.fragmentElement, program.shaderOptions.uniforms, program.shaderOptions.samplers, defines);
		}
		var result = new ParticleSystem(name, this._capacity, this._scene, custom);
		result.customShader = program;
		
		// TODO:
		//Tools.DeepCopy(this, result, ["particles"], ["_vertexDeclaration", "_vertexStrideSize"]);
		
		if (newEmitter == null) {
			newEmitter = this.emitter;
		}
		
		result.emitter = newEmitter;
		if (this.particleTexture != null) {
			result.particleTexture = new Texture(this.particleTexture.url, this._scene);
		}
		
		result.start();
		
		return result;
	}
	
	/**
	 * Serializes the particle system to a JSON object.
	 * @returns the JSON object
	 */
	public function serialize():Dynamic {
		var serializationObject:Dynamic = { };
		
		serializationObject.name = this.name;
		
		// Emitter
		if (this.emitter.position != null) {
			serializationObject.emitterId = this.emitter.id;
		} 
		else {
			serializationObject.emitter = this.emitter.asArray();
		}
		
		serializationObject.capacity = this.getCapacity();
		
		if (this.particleTexture != null) {
			serializationObject.textureName = this.particleTexture.name;
		}
		
		// Animations
		Animation.AppendSerializedAnimations(this, serializationObject);
		
		// Particle system
		serializationObject.minAngularSpeed = this.minAngularSpeed;
        serializationObject.maxAngularSpeed = this.maxAngularSpeed;
        serializationObject.minSize = this.minSize;
        serializationObject.maxSize = this.maxSize;
        serializationObject.minEmitPower = this.minEmitPower;
        serializationObject.maxEmitPower = this.maxEmitPower;
        serializationObject.minLifeTime = this.minLifeTime;
        serializationObject.maxLifeTime = this.maxLifeTime;
        serializationObject.emitRate = this.emitRate;
        serializationObject.minEmitBox = this.minEmitBox.asArray();
        serializationObject.maxEmitBox = this.maxEmitBox.asArray();
        serializationObject.gravity = this.gravity.asArray();
        serializationObject.direction1 = this.direction1.asArray();
        serializationObject.direction2 = this.direction2.asArray();
        serializationObject.color1 = this.color1.asArray();
        serializationObject.color2 = this.color2.asArray();
        serializationObject.colorDead = this.colorDead.asArray();
        serializationObject.updateSpeed = this.updateSpeed;
        serializationObject.targetStopDuration = this.targetStopDuration;
        serializationObject.textureMask = this.textureMask.asArray();
        serializationObject.blendMode = this.blendMode;
        serializationObject.customShader = this.customShader;
        serializationObject.preventAutoStart = this.preventAutoStart;
		
        serializationObject.startSpriteCellID = this.startSpriteCellID;
        serializationObject.endSpriteCellID = this.endSpriteCellID;
        serializationObject.spriteCellLoop = this.spriteCellLoop;
        serializationObject.spriteCellChangeSpeed = this.spriteCellChangeSpeed;
        serializationObject.spriteCellWidth = this.spriteCellWidth;
        serializationObject.spriteCellHeight = this.spriteCellHeight;
		
        serializationObject.isAnimationSheetEnabled = this._isAnimationSheetEnabled;
		
		// Emitter
		if (this.particleEmitterType != null) {
			serializationObject.particleEmitterType = this.particleEmitterType.serialize();
		} 
		
		return serializationObject;
	}

	/**
	 * Parses a JSON object to create a particle system.
	 * @param parsedParticleSystem The JSON object to parse
	 * @param scene The scene to create the particle system in
	 * @param rootUrl The root url to use to load external dependencies like texture
	 * @returns the Parsed particle system
	 */
	public static function Parse(parsedParticleSystem:Dynamic, scene:Scene, rootUrl:String):ParticleSystem {
		var name = parsedParticleSystem.name;
		var custom:Effect = null;
        var program:Dynamic = null;
        if (parsedParticleSystem.customShader != null) {
            program = parsedParticleSystem.customShader;
            var defines:String = (program.shaderOptions.defines.length > 0) ? program.shaderOptions.defines.join("\n") : "";
            custom = scene.getEngine().createEffectForParticles(program.shaderPath.fragmentElement, program.shaderOptions.uniforms, program.shaderOptions.samplers, defines);
        }
		var particleSystem = new ParticleSystem(name, parsedParticleSystem.capacity, scene, custom, parsedParticleSystem.isAnimationSheetEnabled);
		particleSystem.customShader = program;
		
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
		
		if (parsedParticleSystem.autoAnimate == true) {
			scene.beginAnimation(particleSystem, parsedParticleSystem.autoAnimateFrom, parsedParticleSystem.autoAnimateTo, parsedParticleSystem.autoAnimateLoop, parsedParticleSystem.autoAnimateSpeed != null ? parsedParticleSystem.autoAnimateSpeed : 1.0);
		}
		
		// Particle system
		particleSystem.minAngularSpeed = parsedParticleSystem.minAngularSpeed;
		particleSystem.maxAngularSpeed = parsedParticleSystem.maxAngularSpeed;
		particleSystem.minSize = parsedParticleSystem.minSize;
		particleSystem.maxSize = parsedParticleSystem.maxSize;
		particleSystem.minLifeTime = parsedParticleSystem.minLifeTime;
		particleSystem.maxLifeTime = parsedParticleSystem.maxLifeTime;
		particleSystem.minEmitPower = parsedParticleSystem.minEmitPower;
		particleSystem.maxEmitPower = parsedParticleSystem.maxEmitPower;
		particleSystem.emitRate = parsedParticleSystem.emitRate;
		particleSystem.minEmitBox = Vector3.FromArray(parsedParticleSystem.minEmitBox);
		particleSystem.maxEmitBox = Vector3.FromArray(parsedParticleSystem.maxEmitBox);
		particleSystem.gravity = Vector3.FromArray(parsedParticleSystem.gravity);
		particleSystem.direction1 = Vector3.FromArray(parsedParticleSystem.direction1);
		particleSystem.direction2 = Vector3.FromArray(parsedParticleSystem.direction2);
		particleSystem.color1 = Color4.FromArray(parsedParticleSystem.color1);
		particleSystem.color2 = Color4.FromArray(parsedParticleSystem.color2);
		particleSystem.colorDead = Color4.FromArray(parsedParticleSystem.colorDead);
		particleSystem.updateSpeed = parsedParticleSystem.updateSpeed;
		particleSystem.targetStopDuration = parsedParticleSystem.targetStopDuration;
		particleSystem.textureMask = Color4.FromArray(parsedParticleSystem.textureMask);
		particleSystem.blendMode = parsedParticleSystem.blendMode;
		
		particleSystem.startSpriteCellID = parsedParticleSystem.startSpriteCellID;
        particleSystem.endSpriteCellID = parsedParticleSystem.endSpriteCellID;
        particleSystem.spriteCellLoop = parsedParticleSystem.spriteCellLoop;
        particleSystem.spriteCellChangeSpeed = parsedParticleSystem.spriteCellChangeSpeed;
        particleSystem.spriteCellWidth = parsedParticleSystem.spriteCellWidth;
        particleSystem.spriteCellHeight = parsedParticleSystem.spriteCellHeight;
		
		if (parsedParticleSystem.preventAutoStart == true) {
            particleSystem.start();
        }
		
		return particleSystem;
	}
	
}
