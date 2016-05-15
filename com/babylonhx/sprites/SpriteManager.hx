package com.babylonhx.sprites;

import com.babylonhx.materials.Effect;
import com.babylonhx.mesh.WebGLBuffer;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.tools.Tools;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;
import com.babylonhx.collisions.PickingInfo;
import com.babylonhx.culling.Ray;
import com.babylonhx.cameras.Camera;
import com.babylonhx.tools.Observable;
import com.babylonhx.tools.Observer;
import com.babylonhx.tools.EventState;

import com.babylonhx.utils.typedarray.Float32Array;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.SpriteManager') class SpriteManager {
	
	public var name:String;
	public var sprites:Array<Sprite> = [];
	public var renderingGroupId:Int = 0;
	public var layerMask:Int = 0x0FFFFFFF;
	public var fogEnabled:Bool = true;
	public var isPickable = false;
	public var cellSize:Float;
	
	/**
	* An event triggered when the manager is disposed.
	* @type {BABYLON.Observable}
	*/
	public var onDisposeObservable = new Observable<SpriteManager>();

	private var _onDisposeObserver:Observer<SpriteManager>;
	public var onDispose(never, set):SpriteManager->Null<EventState>->Void;
	private function set_onDispose(callback:SpriteManager->Null<EventState>->Void):SpriteManager->Null<EventState>->Void {
		if (this._onDisposeObserver != null) {
			this.onDisposeObservable.remove(this._onDisposeObserver);
		}
		this._onDisposeObserver = this.onDisposeObservable.add(callback);
		
		return callback;
	}

	private var _capacity:Int;
	private var _spriteTexture:Texture;
	private var _epsilon:Float;

	private var _scene:Scene;

	private var _vertexDeclaration:Array<Int> = [4, 4, 4, 4];
	private var _vertexStrideSize:Int = 16 * 4; // 16 floats per sprite (x, y, z, angle, size, offsetX, offsetY, invertU, invertV, cellIndexX, cellIndexY, color)
	private var _vertexBuffer:WebGLBuffer;
	private var _indexBuffer:WebGLBuffer;
	private var _vertices:Float32Array;
	private var _effectBase:Effect;
	private var _effectFog:Effect;
	
	public var texture(get, set):Texture;
	

	public function new(name:String, imgUrl:String, capacity:Int, cellSize:Float, scene:Scene, ?epsilon:Float, ?samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE) {
		this.name = name;
		this.cellSize = cellSize;
		
		this._capacity = capacity;
		this._spriteTexture = new Texture(imgUrl, scene, true, false, samplingMode);
		this._spriteTexture.wrapU = Texture.CLAMP_ADDRESSMODE;
		this._spriteTexture.wrapV = Texture.CLAMP_ADDRESSMODE;
		this._epsilon = epsilon == null ? 0.01 : epsilon;
		
		// temp fix for correct 'pixelated' appearance
        if(samplingMode == Texture.NEAREST_SAMPLINGMODE) {
            this._spriteTexture.anisotropicFilteringLevel = 1;
        }
		
		this._scene = scene;
		this._scene.spriteManagers.push(this);
		
		// VBO
		this._vertexBuffer = scene.getEngine().createDynamicVertexBuffer(capacity * this._vertexStrideSize * 4);
		
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
		
		this._indexBuffer = scene.getEngine().createIndexBuffer(indices);
		this._vertices = new Float32Array(capacity * this._vertexStrideSize);
		
		// Effects
		this._effectBase = this._scene.getEngine().createEffect("sprites",
			["position", "options", "cellInfo", "color"],
			["view", "projection", "textureInfos", "alphaTest"],
			["diffuseSampler"], "");
			
		this._effectFog = this._scene.getEngine().createEffect("sprites",
			["position", "options", "cellInfo", "color"],
			["view", "projection", "textureInfos", "alphaTest", "vFogInfos", "vFogColor"],
			["diffuseSampler"], "#define FOG");
	}
	
	private function get_texture():Texture {
		return this._spriteTexture;
	}
	private function set_texture(value:Texture):Texture {
		return this._spriteTexture = value;
	}

	private function _appendSpriteVertex(index:Int, sprite:Sprite, offsetX:Float, offsetY:Float, rowSize:Int) {
		var arrayOffset = index * 16;
		
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
			
		this._vertices[arrayOffset] = sprite.position.x;
		this._vertices[arrayOffset + 1] = sprite.position.y;
		this._vertices[arrayOffset + 2] = sprite.position.z;
		this._vertices[arrayOffset + 3] = sprite.angle;
		this._vertices[arrayOffset + 4] = sprite.width;
		this._vertices[arrayOffset + 5] = sprite.height;
		this._vertices[arrayOffset + 6] = offsetX;
		this._vertices[arrayOffset + 7] = offsetY;
		this._vertices[arrayOffset + 8] = sprite.invertU ? 1 : 0;
		this._vertices[arrayOffset + 9] = sprite.invertV ? 1 : 0;
		var offset = Std.int(sprite.cellIndex / rowSize);
		this._vertices[arrayOffset + 10] = sprite.cellIndex - offset * rowSize;
		this._vertices[arrayOffset + 11] = offset;
		// Color
		this._vertices[arrayOffset + 12] = sprite.color.r;
		this._vertices[arrayOffset + 13] = sprite.color.g;
		this._vertices[arrayOffset + 14] = sprite.color.b;
		this._vertices[arrayOffset + 15] = sprite.color.a;
	}
	
	public function intersects(ray:Ray, camera:Camera, ?predicate:Sprite->Bool, fastCheck:Bool = false):PickingInfo {
		var count:Int = Std.int(Math.min(this._capacity, this.sprites.length));
		var min:Vector3 = Vector3.Zero();
		var max:Vector3 = Vector3.Zero();
		var distance = Math.POSITIVE_INFINITY;
		var currentSprite:Sprite = null;
		var cameraSpacePosition:Vector3 = Vector3.Zero();
		var cameraView:Matrix = camera.getViewMatrix();
		
		for (index in 0...count) {
			var sprite = this.sprites[index];
			if (sprite == null) {
				continue;
			}
			
			if (predicate != null) {
				if (!predicate(sprite)) {
					continue;
				}
			} 
			else if (!sprite.isPickable) {
				continue;
			}
			
			Vector3.TransformCoordinatesToRef(sprite.position, cameraView, cameraSpacePosition);
			
			min.copyFromFloats(cameraSpacePosition.x - sprite.width / 2, cameraSpacePosition.y - sprite.height / 2, cameraSpacePosition.z);
			max.copyFromFloats(cameraSpacePosition.x + sprite.width / 2, cameraSpacePosition.y + sprite.height / 2, cameraSpacePosition.z);
			
			if (ray.intersectsBoxMinMax(min, max)) {
				var currentDistance = Vector3.Distance(cameraSpacePosition, ray.origin);
				
				if (distance > currentDistance) {
					distance = currentDistance;
					currentSprite = sprite;
					
					if (fastCheck) {
						break;
					}
				}
			}
		}
		
		if (currentSprite != null) {
			var result = new PickingInfo();
			
			result.hit = true;
			result.pickedSprite = currentSprite;
			result.distance = distance;
			
			return result;
		}
		
		return null;
	} 

	public function render() {
		// Check
		if (!this._effectBase.isReady() || !this._effectFog.isReady() || this._spriteTexture == null || !this._spriteTexture.isReady()) {
			return;
		}
			
		var engine = this._scene.getEngine();
		var baseSize = this._spriteTexture.getBaseSize();
		
		// Sprites
		var deltaTime = engine.getDeltaTime();
		var max:Int = cast Math.min(this._capacity, this.sprites.length);
		var rowSize:Int = cast baseSize.width / this.cellSize;
		
		var offset:Int = 0;
		for (index in 0...max) {
			var sprite = this.sprites[index];
			if (sprite == null) {
				continue;
			}
			
			sprite._animate(deltaTime);
			
			this._appendSpriteVertex(offset++, sprite, 0, 0, rowSize);
			this._appendSpriteVertex(offset++, sprite, 1, 0, rowSize);
			this._appendSpriteVertex(offset++, sprite, 1, 1, rowSize);
			this._appendSpriteVertex(offset++, sprite, 0, 1, rowSize);
		}
		engine.updateDynamicVertexBuffer(this._vertexBuffer, this._vertices);
		
		// Render
		var effect = this._effectBase;
		
		if (this._scene.fogEnabled && this._scene.fogMode != Scene.FOGMODE_NONE && this.fogEnabled) {
			effect = this._effectFog;
		}
		
		engine.enableEffect(effect);
		
		var viewMatrix = this._scene.getViewMatrix();
		effect.setTexture("diffuseSampler", this._spriteTexture);
		effect.setMatrix("view", viewMatrix);
		effect.setMatrix("projection", this._scene.getProjectionMatrix());
		
		effect.setFloat2("textureInfos", this.cellSize / baseSize.width, this.cellSize / baseSize.height);
		
		// Fog
		if (this._scene.fogEnabled && this._scene.fogMode != Scene.FOGMODE_NONE && this.fogEnabled) {
			effect.setFloat4("vFogInfos", this._scene.fogMode, this._scene.fogStart, this._scene.fogEnd, this._scene.fogDensity);
			effect.setColor3("vFogColor", this._scene.fogColor);
		}
		
		// VBOs
		engine.bindBuffers(this._vertexBuffer, this._indexBuffer, this._vertexDeclaration, this._vertexStrideSize, effect);
		
		// Draw order
		engine.setDepthFunctionToLessOrEqual();
		effect.setBool("alphaTest", true);
		engine.setColorWrite(false);
		engine.draw(true, 0, max * 6);
		engine.setColorWrite(true);
		effect.setBool("alphaTest", false);
		
		engine.setAlphaMode(Engine.ALPHA_COMBINE);
		engine.draw(true, 0, max * 6);
		engine.setAlphaMode(Engine.ALPHA_DISABLE);
	}

	public function dispose() {
		if (this._vertexBuffer != null) {
			this._scene.getEngine()._releaseBuffer(this._vertexBuffer);
			this._vertexBuffer = null;
		}
		
		if (this._indexBuffer != null) {
			this._scene.getEngine()._releaseBuffer(this._indexBuffer);
			this._indexBuffer = null;
		}
		
		if (this._spriteTexture != null) {
			this._spriteTexture.dispose();
			this._spriteTexture = null;
		}
		
		// Remove from scene
		this._scene.spriteManagers.remove(this);
		
		this.onDisposeObservable.notifyObservers(this);
        this.onDisposeObservable.clear();
	}
	
}
