package com.babylonhx.materials.textures.procedurals;

import com.babylonhx.materials.Effect;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.BabylonBuffer;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.ProceduralTexture') class ProceduralTexture extends Texture {
	
	private var _size:Float;
	public var _generateMipMaps:Bool;
	private var _doNotChangeAspectRatio:Bool;
	private var _currentRefreshId:Int = -1;
	private var _refreshRate:Int = 1;

	private var _vertexBuffer:BabylonBuffer;
	private var _indexBuffer:BabylonBuffer;
	private var _effect:Effect;

	private var _vertexDeclaration:Array<Int> = [2];
	private var _vertexStrideSize:Int = 2 * 4;

	private var _uniforms:Array<String> = [];
	private var _samplers:Array<String> = [];
	private var _fragment:Dynamic;

	public var _textures:Map<String, Texture> = new Map<String, Texture>();
	private var _floats:Map<String, Float> = new Map<String, Float>();
	private var _floatsArrays:Map<String, Array<Float>> = new Map<String, Array<Float>>();
	private var _colors3:Map<String, Color3> = new Map<String, Color3>();
	private var _colors4:Map<String, Color4> = new Map<String, Color4>();
	private var _vectors2:Map<String, Vector2> = new Map<String, Vector2>();
	private var _vectors3:Map<String, Vector3> = new Map<String, Vector3>();
	private var _matrices:Map<String, Matrix> = new Map<String, Matrix>();

	private var _fallbackTexture:Texture;

	private var _fallbackTextureUsed:Bool = false;
	

	public function new(name:String, size:Float, fragment:Dynamic, scene:Scene, ?fallbackTexture:Texture, generateMipMaps:Bool = true) {
		super(null, scene, !generateMipMaps);
		
		scene._proceduralTextures.push(this);
		
		this.name = name;
		this.isRenderTarget = true;
		this._size = size;
		this._generateMipMaps = generateMipMaps;
		
		this.setFragment(fragment);
		
		this._fallbackTexture = fallbackTexture;
		
		this._texture = scene.getEngine().createRenderTargetTexture(size, generateMipMaps);
		
		// VBO
		var vertices:Array<Float> = [];
		vertices.push(1);
		vertices.push(1);
		vertices.push(-1);
		vertices.push(1);
		vertices.push(-1);
		vertices.push(-1);
		vertices.push(1);
		vertices.push(-1);
		
		this._vertexBuffer = scene.getEngine().createVertexBuffer(vertices);
		
		// Indices
		var indices:Array<Int> = [];
		indices.push(0);
		indices.push(1);
		indices.push(2);
		
		indices.push(0);
		indices.push(2);
		indices.push(3);
		
		this._indexBuffer = scene.getEngine().createIndexBuffer(indices);
	}

	public function reset() {
		if (this._effect == null) {
			return;
		}
		var engine = this.getScene().getEngine();
		engine._releaseEffect(this._effect);
	}

	override public function isReady():Bool {
		var engine = this.getScene().getEngine();
		var shaders:Dynamic = null;
		
		if (this._fragment == null) {
			return false;
		}
		
		if (this._fallbackTextureUsed) {
			return true;
		}
		
		if (this._fragment.fragmentElement != null) {
			shaders = { vertex: "procedural", fragmentElement: this._fragment.fragmentElement };
		}
		else {
			shaders = { vertex: "procedural", fragment: this._fragment };
		}
		
		this._effect = engine.createEffect(shaders,
			["position"],
			this._uniforms,
			this._samplers,
			"", null, null, function(effect:Effect, msg:String) {
				this.releaseInternalTexture();
				
				if (this._fallbackTexture != null) {
					this._texture = this._fallbackTexture._texture;
					this._texture.references++;
				}
				
				this._fallbackTextureUsed = true;
			});
			
		return this._effect.isReady();
	}

	public function resetRefreshCounter() {
		this._currentRefreshId = -1;
	}

	public function setFragment(fragment:Dynamic) {
		this._fragment = fragment;
	}

	public var refreshRate(get, set):Int;
	private function get_refreshRate():Int {
		return this._refreshRate;
	}
	// Use 0 to render just once, 1 to render on every frame, 2 to render every two frames and so on...
	private function set_refreshRate(value:Int):Int {
		this._refreshRate = value;
		this.resetRefreshCounter();
		return value;
	}

	public function _shouldRender():Bool {
		if (!this.isReady() || this._texture == null) {
			return false;
		} 
		
		if (this._fallbackTextureUsed) {
			return false;
		}
		
		if (this._currentRefreshId == -1) { // At least render once
			this._currentRefreshId = 1;
			return true;
		}
		
		if (this.refreshRate == this._currentRefreshId) {
			this._currentRefreshId = 1;
			return true;
		}
		
		this._currentRefreshId++;
		return false;
	}

	public function getRenderSize():Float {
		return this._size;
	}

	public function resize(size:Float, generateMipMaps:Bool) {
		if (this._fallbackTextureUsed) {
			return;
		}
		
		this.releaseInternalTexture();
		this._texture = this.getScene().getEngine().createRenderTargetTexture(size, generateMipMaps);
	}

	inline private function _checkUniform(uniformName:String) {
		if (this._uniforms.indexOf(uniformName) == -1) {
			this._uniforms.push(uniformName);
		}
	}

	inline public function setTexture(name:String, texture:Texture):ProceduralTexture {
		if (this._samplers.indexOf(name) == -1) {
			this._samplers.push(name);
		}
		this._textures[name] = texture;
		
		return this;
	}

	inline public function setFloat(name:String, value:Float):ProceduralTexture {
		this._checkUniform(name);
		this._floats[name] = value;
		
		return this;
	}

	inline public function setFloats(name:String, value:Array<Float>):ProceduralTexture {
		this._checkUniform(name);
		this._floatsArrays[name] = value;
		
		return this;
	}

	inline public function setColor3(name:String, value:Color3):ProceduralTexture {
		this._checkUniform(name);
		this._colors3[name] = value;
		
		return this;
	}

	inline public function setColor4(name:String, value:Color4):ProceduralTexture {
		this._checkUniform(name);
		this._colors4[name] = value;
		
		return this;
	}

	inline public function setVector2(name:String, value:Vector2):ProceduralTexture {
		this._checkUniform(name);
		this._vectors2[name] = value;
		
		return this;
	}

	inline public function setVector3(name:String, value:Vector3):ProceduralTexture {
		this._checkUniform(name);
		this._vectors3[name] = value;
		
		return this;
	}

	inline public function setMatrix(name:String, value:Matrix):ProceduralTexture {
		this._checkUniform(name);
		this._matrices[name] = value;
		
		return this;
	}

	public function render(useCameraPostProcess:Bool = false) {
		var scene:Scene = this.getScene();
		var engine:Engine = scene.getEngine();
		
		engine.bindFramebuffer(this._texture);
		
		// Clear
		engine.clear(scene.clearColor, true, true);
		
		// Render
		engine.enableEffect(this._effect);
		engine.setState(false);
		
		// Texture
		for (key in this._textures.keys()) {
			this._effect.setTexture(key, this._textures[key]);
		}
		
		// Float    
		for (key in this._floats.keys()) {
			this._effect.setFloat(key, this._floats[key]);
		}
		
		// Floats   
		for (key in this._floatsArrays.keys()) {
			this._effect.setArray(key, this._floatsArrays[key]);
		}
		
		// Color3        
		for (key in this._colors3.keys()) {
			this._effect.setColor3(key, this._colors3[key]);
		}
		
		// Color4      
		for (key in this._colors4.keys()) {
			var color = this._colors4[key];
			this._effect.setFloat4(key, color.r, color.g, color.b, color.a);
		}
		
		// Vector2        
		for (key in this._vectors2.keys()) {
			this._effect.setVector2(key, this._vectors2[key]);
		}
		
		// Vector3        
		for (key in this._vectors3.keys()) {
			this._effect.setVector3(key, this._vectors3[key]);
		}
		
		// Matrix      
		for (key in this._matrices.keys()) {
			this._effect.setMatrix(key, this._matrices[key]);
		}
		
		// VBOs
		engine.bindBuffers(this._vertexBuffer, this._indexBuffer, this._vertexDeclaration, this._vertexStrideSize, this._effect);
		
		// Draw order
		engine.draw(true, 0, 6);
		
		// Unbind
		engine.unBindFramebuffer(this._texture);
	}

	override public function clone():ProceduralTexture {
		var textureSize = this.getSize();
		var newTexture = new ProceduralTexture(this.name, textureSize.width, this._fragment, this.getScene(), this._fallbackTexture, this._generateMipMaps);
		
		// Base texture
		newTexture.hasAlpha = this.hasAlpha;
		newTexture.level = this.level;
		
		// RenderTarget Texture
		newTexture.coordinatesMode = this.coordinatesMode;
		
		return newTexture;
	}

	override public function dispose() {
		var index = this.getScene()._proceduralTextures.indexOf(this);
		
		if (index >= 0) {
			this.getScene()._proceduralTextures.splice(index, 1);
		}
		super.dispose();
	}
	
}
