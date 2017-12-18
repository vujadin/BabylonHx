package com.babylonhx.materials.textures.procedurals;

import com.babylonhx.engine.Engine;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.textures.RenderTargetCreationOptions;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.mesh.WebGLBuffer;
import com.babylonhx.Scene;

import lime.utils.Float32Array;
import lime.utils.UInt32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.ProceduralTexture') class ProceduralTexture extends Texture {
	
	private var _size:Float;
	public var _generateMipMaps:Bool;
	public var isEnabled:Bool = true;
	private var _doNotChangeAspectRatio:Bool;
	private var _currentRefreshId:Int = -1;
	private var _refreshRate:Int = 1;
	
	public var onGenerated:Void->Void = null;

	private var _vertexBuffers:Map<String, VertexBuffer> = new Map();
	private var _indexBuffer:WebGLBuffer;
	private var _effect:Effect;

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
	private var _engine:Engine;
	

	public function new(name:String, size:Float, fragment:Dynamic, scene:Scene, ?fallbackTexture:Texture, generateMipMaps:Bool = true) {
		super(null, scene, !generateMipMaps);
		
		scene._proceduralTextures.push(this);
		
		this._engine = scene.getEngine();
		
		this.name = name;
		this.isRenderTarget = true;
		this._size = size;
		this._generateMipMaps = generateMipMaps;
		
		this.setFragment(fragment);
		
		this._fallbackTexture = fallbackTexture;
		
		if (isCube) {
			var rto = new RenderTargetCreationOptions();
			rto.generateMipMaps = generateMipMaps;
			this._texture = this._engine.createRenderTargetCubeTexture(size, rto);
			this.setFloat("face", 0);
		}
		else {
			this._texture = this._engine.createRenderTargetTexture(size, generateMipMaps);
		}
		
		// VBO
		var vertices:Array<Float> = [1, 1, -1, 1, -1, -1, 1, -1];
		this._vertexBuffers[VertexBuffer.PositionKind] = new VertexBuffer(this._engine, new Float32Array(vertices), VertexBuffer.PositionKind, false, false, 2);
		
		this._createIndexBuffer();
	}
		
	private function _createIndexBuffer() {
        var engine = this._engine;
		// Indices
		var indices:Array<Int> = [0, 1, 2, 0, 2, 3];		
		this._indexBuffer = engine.createIndexBuffer(new UInt32Array(indices));
	}
	
	override public function _rebuild() {
		var vb = this._vertexBuffers[VertexBuffer.PositionKind];
		
		if (vb != null) {
			vb._rebuild();
		}
		
        this._createIndexBuffer();
		
        if (this.refreshRate == RenderTargetTexture.REFRESHRATE_RENDER_ONCE) {
            this.refreshRate = RenderTargetTexture.REFRESHRATE_RENDER_ONCE;
        }            
    }

	public function reset() {
		if (this._effect == null) {
			return;
		}
		
		this._engine._releaseEffect(this._effect);
	}

	override public function isReady():Bool {
		var engine = this._engine;
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
			"", null, null, function(_, _) {
				this.releaseInternalTexture();
				
				if (this._fallbackTexture != null) {
					this._texture = this._fallbackTexture._texture;
					
					if (this._texture != null) {
						this._texture.incrementReferences();
					}
				}
				
				this._fallbackTextureUsed = true;
			});
			
		return this._effect.isReady();
	}

	inline public function resetRefreshCounter() {
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
		if (!this.isEnabled || !this.isReady() || this._texture == null) {
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
		this._texture = this._engine.createRenderTargetTexture(size, generateMipMaps);
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
		
		if (scene == null) {
			return;
		}
		
		// Render
		this._engine.enableEffect(this._effect);
		this._engine.setState(false);
		
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
		
		if (this._texture == null) {
			return;
		}
		
		if (this.isCube) {
			for (face in 0...6) {
				this._engine.bindFramebuffer(this._texture, face, null, null, true);
				
				// VBOs
				this._engine.bindBuffers(this._vertexBuffers, this._indexBuffer, this._effect);				
				this._effect.setFloat("face", face);
				
				// Clear
				this._engine.clear(scene.clearColor, true, true, true);
				
				// Draw order
				this._engine.drawElementsType(Material.TriangleFillMode, 0, 6);
				
				// Mipmaps
				if (face == 5) {
					this._engine.generateMipMapsForCubemap(this._texture);
				}
			}
		} 
		else {
			this._engine.bindFramebuffer(this._texture, 0, null, null, true);
			
			// VBOs
            this._engine.bindBuffers(this._vertexBuffers, this._indexBuffer, this._effect);
			
			// Clear
			this._engine.clear(scene.clearColor, true, true, true);
			
			// Draw order
			this._engine.drawElementsType(Material.TriangleFillMode, 0, 6);
		}
		
		// Unbind
		this._engine.unBindFramebuffer(this._texture, this.isCube);
		
		if (this.onGenerated != null) {
			this.onGenerated();
		}
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
		var scene = this.getScene();
		
		if (scene == null) {
			return;
		}
		
		var index = scene._proceduralTextures.indexOf(this);
		
		if (index >= 0) {
			scene._proceduralTextures.splice(index, 1);
		}
		
		var vertexBuffer = this._vertexBuffers[VertexBuffer.PositionKind];
		if (vertexBuffer != null) {
			vertexBuffer.dispose();
			this._vertexBuffers[VertexBuffer.PositionKind] = null;
		}
		
		if (this._indexBuffer != null && this._engine._releaseBuffer(this._indexBuffer)) {
			this._indexBuffer = null;
		}
		
		super.dispose();
	}
	
}
