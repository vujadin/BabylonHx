package com.gamestudiohx.babylonhx.postprocess;

import com.gamestudiohx.babylonhx.cameras.Camera;
import com.gamestudiohx.babylonhx.materials.Effect;
import com.gamestudiohx.babylonhx.materials.textures.Texture;
import com.gamestudiohx.babylonhx.Engine;
import com.gamestudiohx.babylonhx.Scene;
import com.gamestudiohx.babylonhx.tools.SmartArray;


/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class PostProcess {
	
	public var name:String;
	public var _camera:Camera;
	public var _scene:Scene;
	public var _engine:Engine;
	public var _renderRatio:Float;
	public var width:Float;
	public var height:Float;
	public var renderTargetSamplingMode:Int;
	public var _effect:Effect;
	public var _textures:SmartArray;
	public var _currentRenderTextureInd:Int = 0;
	public var _reusable:Bool;
	
	public var samplers:Array<String>;
	
	public var onApply:Effect->Void;
    public var _onDispose:Void->Void;
    public var onSizeChanged:Void->Void;

	public function new(name:String, fragmentUrl:String, parameters:Array<String> = null, samplers:Array<String> = null, ratio:Float, camera:Camera = null, samplingMode:Int = 1, engine:Engine = null, reusable:Bool = false) {
		this.name = name;
		if(camera != null) {
			this._camera = camera;
			this._scene = camera.getScene();
			camera.attachPostProcess(this);
			this._engine = this._scene.getEngine();
		} else {
			this._engine = engine;
		}
        this._renderRatio = ratio;
        this.width = -1;
        this.height = -1;
        this.renderTargetSamplingMode = samplingMode;
		this._reusable = reusable;
		
		this._textures = new SmartArray();
		this._currentRenderTextureInd = 0;

        this.samplers = samplers == null ? [] : samplers;
        this.samplers.push("textureSampler");

        this._effect = this._engine.createEffect({ vertex: "postprocess", fragment: fragmentUrl },
            ["position"],
            parameters == null ? new Array<String>() : parameters,
            this.samplers, "");
	}
	
	public function activate(?camera:Camera) {
		camera = camera != null ? camera : this._camera;
		
		var scene = camera.getScene();
		
        var desiredWidth = this._engine.getRenderWidth() * this._renderRatio;
        var desiredHeight = this._engine.getRenderHeight() * this._renderRatio;
		
        if (this.width != desiredWidth || this.height != desiredHeight) {
            if (this._textures.length > 0) {
                for (i in 0...this._textures.length) {
                    this._engine._releaseTexture(this._textures.data[i]);
                }
                this._textures.reset();
            }
            this.width = desiredWidth;
            this.height = desiredHeight;
            this._textures.push(this._engine.createRenderTargetTexture( { width: this.width, height: this.height }, { generateMipMaps: false, generateDepthBuffer: Lambda.indexOf(camera._postProcesses, this) == 0, samplingMode: this.renderTargetSamplingMode } ));
			
			if (this._reusable) {
                this._textures.push(this._engine.createRenderTargetTexture({ width: this.width, height: this.height }, { generateMipMaps: false, generateDepthBuffer: Lambda.indexOf(camera._postProcesses, this) == camera._postProcessesTakenIndices[0], samplingMode: this.renderTargetSamplingMode }));
            }
			
            if (this.onSizeChanged != null) {
                this.onSizeChanged();
            }
        }
		
        this._engine.bindFramebuffer(this._textures.data[this._currentRenderTextureInd]);
        
        // Clear
        this._engine.clear(this._scene.clearColor, this._scene.autoClear || this._scene.forceWireframe, true);
		
		if (this._reusable) {
            this._currentRenderTextureInd = (this._currentRenderTextureInd + 1) % 2;
        }
    }
	
	public function apply():Effect {
        // Check
        if (!this._effect.isReady())
            return null;

        // States
        this._engine.enableEffect(this._effect);
        this._engine.setState(false);
        this._engine.setAlphaMode(Engine.ALPHA_DISABLE);
        this._engine.setDepthBuffer(false);
        this._engine.setDepthWrite(false);

        // Texture
        this._effect._bindTexture("textureSampler", this._textures.data[this._currentRenderTextureInd]);
        
        // Parameters
        if (this.onApply != null) {
            this.onApply(this._effect);
        }

        return this._effect;
    }
	
	public function dispose(?camera:Camera) {
		camera = camera == null ? this._camera : camera;
		
        if (this._onDispose != null) {
            this._onDispose();
        }
        
		if (this._textures.length > 0) {
            for (i in 0...this._textures.length) {
                this._engine._releaseTexture(this._textures.data[i]);
            }
            this._textures.reset();
        }
		
		camera.detachPostProcess(this);

        var index = Lambda.indexOf(camera._postProcesses, this);
        if (index == camera._postProcessesTakenIndices[0] && camera._postProcessesTakenIndices.length > 0) {
            this._camera._postProcesses[camera._postProcessesTakenIndices[0]].width = -1; // invalidate frameBuffer to hint the postprocess to create a depth buffer
        }
    }
	
}
