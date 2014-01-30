package com.gamestudiohx.babylonhx.layer;

import com.gamestudiohx.babylonhx.materials.textures.Texture;
import com.gamestudiohx.babylonhx.materials.Effect;
import com.gamestudiohx.babylonhx.tools.math.Color4;
import com.gamestudiohx.babylonhx.mesh.Mesh;

/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class Layer {
	
	public var name:String;
	public var texture:Texture;
	public var isBackground:Bool;
	public var color:Color4;
	public var _scene:Scene;
	public var vertices:Array<Float>;
	public var indicies:Array<Int>;
	public var _indexBuffer:Dynamic;
	public var _effect:Effect;
	
	private var _vertexDeclaration:Array<Int>;  
	private var _vertexStrideSize:Int;
	private var _vertexBuffer:BabylonGLBuffer;				
	
	private var onDispose:Void->Void;				

	public function new(name:String, imgUrl:String, scene:Scene, isBackground:Bool = true, color:Color4 = null) {
		this.name = name;
        this.texture = imgUrl != "" ? new Texture(imgUrl, scene, true) : null;
        this.isBackground = isBackground;
        this.color = color == null ? new Color4(1, 1, 1, 1) : color;

        this._scene = scene;
        this._scene.layers.push(this);
        
        // VBO
        var vertices:Array<Float> = [1, 1, -1, 1, -1, -1, 1, -1];
        /*vertices.push(1, 1);
        vertices.push(-1, 1);
        vertices.push(-1, -1);
        vertices.push(1, -1);*/
        this._vertexDeclaration = [2];
        this._vertexStrideSize = 2 * 4;
        this._vertexBuffer = scene.getEngine().createVertexBuffer(vertices);

        // Indices
        var indices = [];
        indices.push(0);
        indices.push(1);
        indices.push(2);

        indices.push(0);
        indices.push(2);
        indices.push(3);

        this._indexBuffer = scene.getEngine().createIndexBuffer(indices);
        
        // Effects
        this._effect = this._scene.getEngine().createEffect("layer",
                    ["position"],
                    ["textureMatrix", "color"],
                    ["textureSampler"], "");
	}
		
	// TODO
	//onDispose: () => void;
       
	public function render() {
		// Check
        if (!this._effect.isReady() || this.texture == null || !this.texture.isReady())
            return;

        var engine = this._scene.getEngine();
       
        // Render
        engine.enableEffect(this._effect);
        engine.setState(false);

        // Texture
        this._effect.setTexture("textureSampler", this.texture);
        this._effect.setMatrix("textureMatrix", this.texture._computeTextureMatrix());

        // Color
        this._effect.setFloat4("color", this.color.r, this.color.g, this.color.b, this.color.a);

        // VBOs
        engine.bindBuffers(this._vertexBuffer, this._indexBuffer, this._vertexDeclaration, this._vertexStrideSize, this._effect);

        // Draw order
        engine.setAlphaMode(Engine.ALPHA_COMBINE);
        engine.draw(true, 0, 6);
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

        if (this.texture != null) {
            this.texture.dispose();
            this.texture = null;
        }

        // Remove from scene
        var index = Lambda.indexOf(this._scene.layers, this);
        this._scene.layers.splice(index, 1);
        
        // Callback
        if (this.onDispose != null) {
            this.onDispose();
        }
	}	
		
}
