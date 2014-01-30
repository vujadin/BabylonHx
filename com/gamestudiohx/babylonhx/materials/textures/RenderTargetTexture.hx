package com.gamestudiohx.babylonhx.materials.textures;

import com.gamestudiohx.babylonhx.mesh.SubMesh;
import com.gamestudiohx.babylonhx.rendering.RenderingManager;
import com.gamestudiohx.babylonhx.Scene;
import com.gamestudiohx.babylonhx.mesh.Mesh;
import com.gamestudiohx.babylonhx.tools.SmartArray;

/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class RenderTargetTexture extends Texture {
	
	public var _generateMipMaps:Bool;
	public var _renderingManager:RenderingManager;
	public var renderList:Array<Mesh>;
	
	public var renderParticles:Bool;
    public var renderSprites:Bool;
    public var isRenderTarget:Bool;
	
	public var customRenderFunction:Dynamic;

    // Methods  
    public var onBeforeRender:Void->Void;
    public var onAfterRender:Void->Void;
	
	public var _waitingRenderList:Array<String>;

	public function new(name:String, size:Float, scene:Scene, generateMipMaps:Bool) {			
        this._generateMipMaps = generateMipMaps;

        this._texture = scene.getEngine().createRenderTargetTexture(size, generateMipMaps);
		
		super(name, scene, generateMipMaps);

        // Render list
        this.renderList = [];

        // Rendering groups
        this._renderingManager = new RenderingManager(scene);
	}
	
	public function resize(size:Float, generateMipMaps:Bool) {
        this.releaseInternalTexture();
        this._texture = this._scene.getEngine().createRenderTargetTexture(size, generateMipMaps);
    }
	
	public function render() {
        if (this.onBeforeRender != null) {
            this.onBeforeRender();
        }

        var scene = this._scene;
        var engine = scene.getEngine();

        if (this._waitingRenderList != null) {
            this.renderList = [];
            for (index in 0...this._waitingRenderList.length) {
                var id = this._waitingRenderList[index];
                this.renderList.push(this._scene.getMeshByID(id));
            }

            this._waitingRenderList = null;
        }

        if (this.renderList == null || this.renderList.length == 0) {
            if (this.onAfterRender != null) {
                this.onAfterRender();
            }            
        } else {
			// Bind
			engine.bindFramebuffer(this._texture);

			// Clear
			engine.clear(scene.clearColor, true, true);

			this._renderingManager.reset();

			for (meshIndex in 0...this.renderList.length) {
				var mesh:Mesh = this.renderList[meshIndex];

				if (mesh != null && mesh.isEnabled() && mesh.isVisible) {
					for (subIndex in 0...mesh.subMeshes.length) {
						var subMesh:SubMesh = mesh.subMeshes[subIndex];
						scene._activeVertices += subMesh.verticesCount;
						this._renderingManager.dispatch(subMesh);
					}
				}
			}

			// Render
			this._renderingManager.render(this.customRenderFunction, this.renderList, this.renderParticles, this.renderSprites);

			// Unbind
			engine.unBindFramebuffer(this._texture);

			if (this.onAfterRender != null) {
				this.onAfterRender();
			}
		}
    }
	
	override public function clone():Texture {
        var textureSize = this.getSize();
        var newTexture:RenderTargetTexture = new RenderTargetTexture(this.name, textureSize.width, this._scene, this._generateMipMaps);

        // Base texture
        newTexture.hasAlpha = this.hasAlpha;
        newTexture.level = this.level;

        // RenderTarget Texture
        newTexture.coordinatesMode = this.coordinatesMode;
        newTexture.renderList = this.renderList.copy();

        return newTexture;
    }
	
}
