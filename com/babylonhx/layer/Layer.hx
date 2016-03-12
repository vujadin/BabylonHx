package com.babylonhx.layer;

import com.babylonhx.materials.Effect;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Vector2;
import com.babylonhx.mesh.WebGLBuffer;
import com.babylonhx.utils.GL;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Layer') class Layer {
	
	public var name:String;
	public var texture:Dynamic; // Texture;
	public var isBackground:Bool;
	public var color:Color4;
	public var scale:Vector2 = new Vector2(1, 1);
    public var offset:Vector2 = new Vector2(0, 0);
	public var onDispose:Void->Void;
	public var onBeforeRender:Void->Void;
	public var onAfterRender:Void->Void;
	public var alphaBlendingMode:Int = Engine.ALPHA_COMBINE;
	public var alphaTest:Bool = false;
	
	public var vertices:Array<Float> = [];
	public var indices:Array<Int> = [];
	
	private var _scene:Scene;
	private var _vertexDeclaration:Array<Int> = [];
	private var _vertexStrideSize:Int = 2 * 4;
	private var _vertexBuffer:WebGLBuffer;
	private var _indexBuffer:WebGLBuffer;
	private var _effect:Effect;
	private var _alphaTestEffect:Effect;
	

	public function new(name:String, imgUrl:String, scene:Scene, isBackground:Bool = true, ?color:Color4) {
		this.name = name;
		this.texture = imgUrl != null ? new Texture(imgUrl, scene, false) : null;
		this.isBackground = isBackground;
		this.color = color == null ? new Color4(1, 1, 1, 1) : color;
		
		this._scene = scene;
		this._scene.layers.push(this);
		
		// VBO
		this.vertices.push(1);
		this.vertices.push(1);
		this.vertices.push(-1);
		this.vertices.push(1);
		this.vertices.push(-1);
		this.vertices.push(-1);
		this.vertices.push(1);
		this.vertices.push( -1);
		this._vertexDeclaration = [2];
        this._vertexBuffer = scene.getEngine().createVertexBuffer(this.vertices);
		
		
		// Indices
		this.indices.push(0);
		this.indices.push(1);
		this.indices.push(2);
		
		this.indices.push(0);
		this.indices.push(2);
		this.indices.push(3);
		
		this._indexBuffer = scene.getEngine().createIndexBuffer(this.indices);
		
		// Effects
		this._effect = this._scene.getEngine().createEffect("layer",
			["position"],
			["textureMatrix", "color", "scale", "offset"],
			["textureSampler"], "");
			
		this._alphaTestEffect = this._scene.getEngine().createEffect("layer",
			["position"],
			["textureMatrix", "color", "scale", "offset"],
			["textureSampler"], "#define ALPHATEST");
	}

	public function render() {
		var currentEffect = this.alphaTest ? this._alphaTestEffect : this._effect;
		
		// Check
		if (!currentEffect.isReady() || this.texture == null || !this.texture.isReady()) {
			return;
		}
		
		var engine = this._scene.getEngine();
		
		if (this.onBeforeRender != null) {
			this.onBeforeRender();
		}
		
		// Render
		engine.enableEffect(currentEffect);
		engine.setState(false);
		
		// Texture
		currentEffect.setTexture("textureSampler", this.texture);
		currentEffect.setMatrix("textureMatrix", this.texture.getTextureMatrix());
		
		// Color
		currentEffect.setFloat4("color", this.color.r, this.color.g, this.color.b, this.color.a);
		
		// Scale / offset
        currentEffect.setVector2("offset", this.offset);
        currentEffect.setVector2("scale", this.scale);
		
		// VBOs
		engine.bindBuffers(this._vertexBuffer, this._indexBuffer, this._vertexDeclaration, this._vertexStrideSize, currentEffect);
		
		// Draw order
		if (this._alphaTestEffect == null) {
			engine.setAlphaMode(this.alphaBlendingMode);
			engine.draw(true, 0, 6);
			engine.setAlphaMode(Engine.ALPHA_DISABLE);
		}
		else {
			engine.draw(true, 0, 6);
		}
		
		if (this.onAfterRender != null) {
			this.onAfterRender();
		}
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
		
		if (this.texture != null) {
			this.texture.dispose();
			this.texture = null;
		}
		
		// Remove from scene
		var index = this._scene.layers.indexOf(this);
		this._scene.layers.splice(index, 1);
		
		// Callback
		if (this.onDispose != null) {
			this.onDispose();
		}
	}
	
}
