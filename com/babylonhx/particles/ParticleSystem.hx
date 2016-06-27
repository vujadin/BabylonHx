package com.babylonhx.particles;

import com.babylonhx.ISmartArrayCompatible;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.WebGLBuffer;
import com.babylonhx.particles.Particle;
import com.babylonhx.tools.Tools;
import com.babylonhx.animations.IAnimatable;
import com.babylonhx.animations.Animation;
import com.babylonhx.tools.Observable;
import com.babylonhx.tools.Observer;
import com.babylonhx.tools.EventState;

import com.babylonhx.utils.typedarray.Float32Array;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.ParticleSystem') class ParticleSystem implements IDisposable implements ISmartArrayCompatible implements IAnimatable {
	
	// Statics
	public static var BLENDMODE_ONEONE:Int = 0;
	public static var BLENDMODE_STANDARD:Int = 1;

	// Members
	public var animations:Array<Animation> = [];
	public var name:String;
	public var id:String;
	public var renderingGroupId:Int = 0;
	public var emitter:Dynamic = null;
	public var emitRate:Int = 10;
	public var manualEmitCount:Int = -1;
	public var updateSpeed:Float = 0.01;
	public var targetStopDuration:Float = 0;
	public var disposeOnStop:Bool = false;
	
	public var __smartArrayFlags:Array<Int> = [];

	public var minEmitPower:Float = 1;
	public var maxEmitPower:Float = 1;

	public var minLifeTime:Float = 1;
	public var maxLifeTime:Float = 1;

	public var minSize:Float = 1;
	public var maxSize:Float = 1;
	public var minAngularSpeed:Float = 0;
	public var maxAngularSpeed:Float = 0;

	public var particleTexture:Texture;
	
	public var layerMask:Int = 0x0FFFFFFF;

	/**
	* An event triggered when the system is disposed.
	* @type {BABYLON.Observable}
	*/
	public var onDisposeObservable:Observable<ParticleSystem> = new Observable<ParticleSystem>();
	private var _onDisposeObserver:Observer<ParticleSystem>;
	public var onDispose:ParticleSystem->Null<EventState>->Void;
	private function set_onDispose(callback:ParticleSystem->Null<EventState>->Void):ParticleSystem->Null<EventState>->Void {
		if (this._onDisposeObserver != null) {
			this.onDisposeObservable.remove(this._onDisposeObserver);
		}
		this._onDisposeObserver = this.onDisposeObservable.add(callback);
		
		return callback;
	}
		
	public var updateFunction:Array<Particle>->Void;

	public var blendMode:Int = ParticleSystem.BLENDMODE_ONEONE;

	public var forceDepthWrite:Bool = false;

	public var gravity:Vector3 = Vector3.Zero();
	public var direction1:Vector3 = new Vector3(0, 1.0, 0);
	public var direction2:Vector3 = new Vector3(0, 1.0, 0);
	public var minEmitBox:Vector3 = new Vector3(-0.5, -0.5, -0.5);
	public var maxEmitBox:Vector3 = new Vector3(0.5, 0.5, 0.5);
	public var color1:Color4 = new Color4(1.0, 1.0, 1.0, 0.5);
	public var color2:Color4 = new Color4(1.0, 1.0, 1.0, 0.4);
	public var colorDead:Color4 = new Color4(0, 0, 0, 0.0);
	public var textureMask:Color4 = new Color4(1.0, 1.0, 1.0, 1.0);
	public var startDirectionFunction:Float->Matrix->Vector3->Void;
	public var startPositionFunction:Matrix->Vector3->Void;

	private var particles:Array<Particle> = [];
	private var particle:Particle;

	private var _capacity:Int;
	private var _scene:Scene;
	private var _vertexDeclaration:Array<Int> = [3, 4, 4];
	private var _vertexStrideSize:Int = 11 * 4; // 11 floats per particle (x, y, z, r, g, b, a, angle, size, offsetX, offsetY)
	private var _stockParticles:Array<Particle> = [];
	private var _newPartsExcess:Int = 0;
	private var _vertexBuffer:WebGLBuffer;
	private var _indexBuffer:WebGLBuffer;
	#if html5
	public var _vertices:Float32Array;
	#else
    public var _vertices:Array<Float>;
    #end
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
	
	private var _engine:Engine;
	

	public function new(name:String, capacity:Int, scene:Scene, ?customEffect:Effect) {
		this.name = name;
		this.id = name;
		this._capacity = capacity;
		
		this._scene = scene;
		this._engine = scene.getEngine();
		
		this._customEffect = customEffect;
		
		scene.particleSystems.push(this);
		
		// VBO
		this._vertexBuffer = this._engine.createDynamicVertexBuffer(capacity * this._vertexStrideSize * 4);
		
		var indices:Array<Int> = [];
		var index:Int = 0;
		for (count in 0...capacity) {
			indices.push(index);
			indices.push(index + 1);
			indices.push(index + 2);
			indices.push(index);
			indices.push(index + 2);
			indices.push(index + 3);
			index += 4;
		}
		
		this._indexBuffer = this._engine.createIndexBuffer(indices);
		
		#if html5
		this._vertices = new Float32Array(capacity * this._vertexStrideSize);
		#else
        this._vertices = [];
        #end
		
		// Default behaviors
		this.startDirectionFunction = function(emitPower:Float, worldMatrix:Matrix, directionToUpdate:Vector3):Void {
			var randX = randomNumber(this.direction1.x, this.direction2.x);
			var randY = randomNumber(this.direction1.y, this.direction2.y);
			var randZ = randomNumber(this.direction1.z, this.direction2.z);
			
			Vector3.TransformNormalFromFloatsToRef(randX * emitPower, randY * emitPower, randZ * emitPower, worldMatrix, directionToUpdate);
		}
		
		this.startPositionFunction = function(worldMatrix:Matrix, positionToUpdate:Vector3):Void {
			var randX = randomNumber(this.minEmitBox.x, this.maxEmitBox.x);
			var randY = randomNumber(this.minEmitBox.y, this.maxEmitBox.y);
			var randZ = randomNumber(this.minEmitBox.z, this.maxEmitBox.z);
			
			Vector3.TransformCoordinatesFromFloatsToRef(randX, randY, randZ, worldMatrix, positionToUpdate);
		}
		
		this.updateFunction = function(particles:Array<Particle>):Void {
			var index:Int = 0;
			while (index < particles.length) {
				var particle = particles[index];
				particle.age += this._scaledUpdateSpeed;
				
				if (particle.age >= particle.lifeTime) { // Recycle by swapping with last particle
					this.recycleParticle(particle);
					//index--;
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
					
					index++;
				}
			}
		}
		
		this._effect = this._getEffect();
	}
	
	inline public function recycleParticle(particle:Particle) {
		var lastParticle = this.particles.pop();
		
		if (lastParticle != particle) {
			lastParticle.copyTo(particle);
			this._stockParticles.push(lastParticle);
		}
	}

	inline public function getCapacity():Int {
		return this._capacity;
	}

	inline public function isAlive():Bool {
		return this._alive;
	}

	inline public function isStarted():Bool {
		return this._started;
	}

	public function start():Void {
		this._started = true;
		this._stopped = false;
		this._actualFrame = 0;
	}

	public function stop():Void {
		this._stopped = true;
	}

	inline public function _appendParticleVertex(index:Int, particle:Particle, offsetX:Float, offsetY:Float):Void {
		var offset = index * 11;
		this._vertices[offset] = particle.position.x;
		this._vertices[offset + 1] = particle.position.y;
		this._vertices[offset + 2] = particle.position.z;
		this._vertices[offset + 3] = particle.color.r;
		this._vertices[offset + 4] = particle.color.g;
		this._vertices[offset + 5] = particle.color.b;
		this._vertices[offset + 6] = particle.color.a;
		this._vertices[offset + 7] = particle.angle;
		this._vertices[offset + 8] = particle.size;
		this._vertices[offset + 9] = offsetX;
		this._vertices[offset + 10] = offsetY;
	}

	var worldMatrix:Matrix = Matrix.Zero();
	inline private function _update(newParticles:Int) {
		// Update current
		this._alive = this.particles.length > 0;
		
		this.updateFunction(this.particles);
		
		// Add new ones		
		if (this.emitter.position != null) {
			worldMatrix = this.emitter.getWorldMatrix();
		} 
		else {
			worldMatrix = Matrix.Translation(this.emitter.x + randomNumber(-500, 500), this.emitter.y, this.emitter.z + randomNumber(-500, 500));
		}
		
		for (index in 0...newParticles) {
			if (this.particles.length == this._capacity) {
				break;
			}
			
			if (this._stockParticles.length != 0) {
				particle = this._stockParticles.pop();
				particle.age = 0;
			} 
			else {
				particle = new Particle();
			}
			this.particles.push(particle);
			
			var emitPower = randomNumber(this.minEmitPower, this.maxEmitPower);
			this.startDirectionFunction(emitPower, worldMatrix, particle.direction);
			particle.lifeTime = randomNumber(this.minLifeTime, this.maxLifeTime);
			particle.size = randomNumber(this.minSize, this.maxSize);
			particle.angularSpeed = randomNumber(this.minAngularSpeed, this.maxAngularSpeed);
			this.startPositionFunction(worldMatrix, particle.position);
			
			var step = randomNumber(0, 1.0);
			
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
		
		// Effect
		var join = defines.join("\n");
		if (this._cachedDefines != join) {
			this._cachedDefines = join;
			
			this._effect = this._engine.createEffect(
				"particles",
				["position", "color", "options"],
				["invView", "view", "projection", "vClipPlane", "textureMask"],
				["diffuseSampler"], join);
		}
		
		return this._effect;
	}

	public function animate() {
		if (!this._started) {
			return;
		}
		
		// Check
		if (this.emitter == null || !this._effect.isReady() || this.particleTexture == null || !this.particleTexture.isReady()) {
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
		} 
		else {
			newParticles = Math.floor(this.emitRate * this._scaledUpdateSpeed);
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
				if (this.disposeOnStop) {
					this._scene._toBeDisposed.push(this);
				}
			}
		}
		
		// Update VBO
		var offset:Int = 0;
		for (index in 0...this.particles.length) {
			var particle = this.particles[index];
			
			this._appendParticleVertex(offset++, particle, 0, 0);
			this._appendParticleVertex(offset++, particle, 1, 0);
			this._appendParticleVertex(offset++, particle, 1, 1);
			this._appendParticleVertex(offset++, particle, 0, 1);
		}
		
		this._engine.updateDynamicVertexBuffer(this._vertexBuffer, this._vertices);
	}

	public function render():Int {		
		// Check
		if (this.emitter == null || !this._effect.isReady() || this.particleTexture == null || !this.particleTexture.isReady()) {
			return 0;
		}
		
		// Render
		this._engine.enableEffect(this._effect);
		this._engine.setState(false);
		
		var viewMatrix = this._scene.getViewMatrix();
		this._effect.setTexture("diffuseSampler", this.particleTexture);
		this._effect.setMatrix("view", viewMatrix);
		this._effect.setMatrix("projection", this._scene.getProjectionMatrix());
		this._effect.setFloat4("textureMask", this.textureMask.r, this.textureMask.g, this.textureMask.b, this.textureMask.a);
		
		if (this._scene.clipPlane != null) {
			var clipPlane = this._scene.clipPlane;
			var invView = viewMatrix.clone();
			invView.invert();
			this._effect.setMatrix("invView", invView);
			this._effect.setFloat4("vClipPlane", clipPlane.normal.x, clipPlane.normal.y, clipPlane.normal.z, clipPlane.d);
		}
		
		// VBOs
		this._engine.bindBuffers(this._vertexBuffer, this._indexBuffer, this._vertexDeclaration, this._vertexStrideSize, this._effect);
		
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
		
		this._engine.draw(true, 0, this.particles.length * 6);
		this._engine.setAlphaMode(Engine.ALPHA_DISABLE);
		
		return this.particles.length;
	}

	inline public function dispose(doNotRecurse:Bool = false) {
		if (this._vertexBuffer != null) {
			this._engine._releaseBuffer(this._vertexBuffer);
			this._vertexBuffer = null;
		}
		
		if (this._indexBuffer != null) {
			this._engine._releaseBuffer(this._indexBuffer);
			this._indexBuffer = null;
		}
		
		if (this.particleTexture != null) {
			this.particleTexture.dispose();
			this.particleTexture = null;
		}
		
		// Remove from scene
		this._scene.particleSystems.remove(this);
		
		// Callback
		this.onDisposeObservable.notifyObservers(this);
        this.onDisposeObservable.clear();
	}

	// Clone
	public function clone(name:String, ?newEmitter:Dynamic):ParticleSystem {
		var result = new ParticleSystem(name, this._capacity, this._scene);
		
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
	
	var randomColor:Color4 = new Color4();
	inline function doubleColor4():Color4 {
		randomColor.b = Math.random() * 2;
		randomColor.r = Math.random() * 2;
		randomColor.g = Math.random() * 2;
		randomColor.a = Math.random();
		
		return randomColor;
		//return new Color4(Math.random() * 2, Math.random() * 2, Math.random() * 2, 0.2);
	}
	
	inline private function randomNumber(min:Float, max:Float):Float {
        if (min == max) {
            return (min);
        }
		
        var random = Math.random();
		
        return ((random * (max - min)) + min);
    }
	
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
		
		return serializationObject;
	}

	public static function Parse(parsedParticleSystem:Dynamic, scene:Scene, rootUrl:String):ParticleSystem {
		var name = parsedParticleSystem.name;
		
		var particleSystem = new ParticleSystem(name, parsedParticleSystem.capacity, scene);
		
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
		
		if (parsedParticleSystem.preventAutoStart == null || parsedParticleSystem.preventAutoStart == true) {
            particleSystem.start();
        }
		
		return particleSystem;
	}
	
}
