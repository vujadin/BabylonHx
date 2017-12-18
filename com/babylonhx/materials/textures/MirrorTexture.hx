package com.babylonhx.materials.textures;

import com.babylonhx.engine.Engine;
import com.babylonhx.math.Plane;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.tools.EventState;
import com.babylonhx.tools.Observer;
import com.babylonhx.postprocess.BlurPostProcess;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.MirrorTexture') class MirrorTexture extends RenderTargetTexture {
	
	public var mirrorPlane:Plane = new Plane(0, 1, 0, 1);

	private var _transformMatrix:Matrix = Matrix.Zero();
	private var _mirrorMatrix:Matrix = Matrix.Zero();
	private var _savedViewMatrix:Matrix;
	
	private var _blurX:BlurPostProcess;
	private var _blurY:BlurPostProcess;
	private var _adaptiveBlurKernel:Float = 0;
	private var _blurKernelX:Float = 0;
	private var _blurKernelY:Float = 0;
	private var _blurRatio:Float = 0.6;
	
	public var blurRatio(get, set):Float;
	private function set_blurRatio(value:Float):Float {
		if (this._blurRatio == value) {
			return value;
		}
		
		this._blurRatio = value;
		this._preparePostProcesses();
		return value;
	}
	inline private function get_blurRatio():Float {
		return this._blurRatio;
	}
	
	public var adaptiveBlurKernel(never, set):Float;
	inline private function set_adaptiveBlurKernel(value:Float):Float {
		this._adaptiveBlurKernel = value;
		this._autoComputeBlurKernel();
		return value;
	}

	public var blurKernel(never, set):Float;
	private function set_blurKernel(value:Float):Float {
		this.blurKernelX = value;
		this.blurKernelY = value;
		return value;
	}
	
	public var blurKernelX(get, set):Float;
	private function set_blurKernelX(value:Float):Float {
		if (this._blurKernelX == value) {
			return value;
		}
		
		this._blurKernelX = value;
		this._preparePostProcesses();
		return value;
	}
	inline private function get_blurKernelX():Float {
		return this._blurKernelX;
	}        

	public var blurKernelY(get, set):Float;
	private function set_blurKernelY(value:Float):Float {
		if (this._blurKernelY == value) {
			return value;
		}
		
		this._blurKernelY = value;
		this._preparePostProcesses();
		return value;
	}
	inline private function get_blurKernelY():Float {
		return this._blurKernelY;
	}
	
	private function _autoComputeBlurKernel() {
		var engine = this.getScene().getEngine();
		
		var dw = this.getRenderWidth() / engine.getRenderWidth();
		var dh = this.getRenderHeight() / engine.getRenderHeight();
		this.blurKernelX = this._adaptiveBlurKernel * dw;
		this.blurKernelY = this._adaptiveBlurKernel * dh;
	}
	
	override private function _onRatioRescale() {
		if (this._sizeRatio > 0) {
			this.resize(this._initialSizeParameter);
			if (this._adaptiveBlurKernel != 0) {
				this._preparePostProcesses();
			}
		}
		
		if (this._adaptiveBlurKernel != 0) {
			this._autoComputeBlurKernel();
		}
	}
	

	public function new(name:String, size:Dynamic, scene:Scene, generateMipMaps:Bool = false, type:Int = Engine.TEXTURETYPE_UNSIGNED_INT, samplingMode:Int = Texture.BILINEAR_SAMPLINGMODE, generateDepthBuffer:Bool = true) {
		super(name, size, scene, generateMipMaps, true, type, false, samplingMode, generateDepthBuffer);
		
		this.ignoreCameraViewport = true;
		
		this.onBeforeRenderObservable.add(function(_, _) {
			Matrix.ReflectionToRef(this.mirrorPlane, this._mirrorMatrix);
			this._savedViewMatrix = scene.getViewMatrix();
			
			this._mirrorMatrix.multiplyToRef(this._savedViewMatrix, this._transformMatrix);
			
			scene.setTransformMatrix(this._transformMatrix, scene.getProjectionMatrix());
			
			scene.clipPlane = this.mirrorPlane;
			
			scene.getEngine().cullBackFaces = false;
			
			scene._mirroredCameraPosition = Vector3.TransformCoordinates(scene.activeCamera.globalPosition, this._mirrorMatrix);
		});
		
		this.onAfterRenderObservable.add(function(_, _) {
			scene.setTransformMatrix(this._savedViewMatrix, scene.getProjectionMatrix());
			scene.getEngine().cullBackFaces = true;
			scene._mirroredCameraPosition = null;
			
			scene.clipPlane = null;
		});
	}
	
	private function _preparePostProcesses() {
		this.clearPostProcesses(true);
		
		if (this._blurKernelX != 0 && this._blurKernelY != 0) {
			var engine = this.getScene().getEngine();
			
			var textureType = engine.getCaps().textureFloatRender ? Engine.TEXTURETYPE_FLOAT : Engine.TEXTURETYPE_HALF_FLOAT;
			
			this._blurX = new BlurPostProcess("horizontal blur", new Vector2(1.0, 0), this._blurKernelX, this._blurRatio, null, Texture.BILINEAR_SAMPLINGMODE, engine, false, textureType);
			this._blurX.autoClear = false;
			
			if (this._blurRatio == 1 && this.samples < 2 && this._texture != null) {
				this._blurX.outputTexture = this._texture;
			} 
			else {
				this._blurX.alwaysForcePOT = true;
			}
			
			this._blurY = new BlurPostProcess("vertical blur", new Vector2(0, 1.0), this._blurKernelY, this._blurRatio, null, Texture.BILINEAR_SAMPLINGMODE, engine, false, textureType);
			this._blurY.autoClear = false;
			this._blurY.alwaysForcePOT = this._blurRatio != 1;
			
			this.addPostProcess(this._blurX);
			this.addPostProcess(this._blurY);   
		}
		else { 
			if (this._blurY != null) {
				this.removePostProcess(this._blurY);
				this._blurY.dispose();
				this._blurY = null;
			}
			if (this._blurX != null) {
				this.removePostProcess(this._blurX);
				this._blurX.dispose();
				this._blurX = null;
			}
		}
	}

	override public function clone():MirrorTexture {
		var scene = this.getScene();
		
		if (scene == null) {
			return this;
		}
		
		var textureSize = this.getSize();
		var newTexture = new MirrorTexture(
            this.name,
            textureSize.width,
            scene,
            this._renderTargetOptions.generateMipMaps,
            this._renderTargetOptions.type,
            this._renderTargetOptions.samplingMode,
            this._renderTargetOptions.generateDepthBuffer
        );
		
		// Base texture
		newTexture.hasAlpha = this.hasAlpha;
		newTexture.level = this.level;
		
		// Mirror Texture
		newTexture.mirrorPlane = this.mirrorPlane.clone();
		if (this.renderList != null) {
			newTexture.renderList = this.renderList.slice(0);
		}
		
		return newTexture;
	}
	
	override public function serialize():Dynamic {
		if (this.name == null) {
			return null;
		}
		
		var serializationObject = super.serialize();
		
		serializationObject.mirrorPlane = this.mirrorPlane.asArray();
		
		return serializationObject;
	}
	
}
