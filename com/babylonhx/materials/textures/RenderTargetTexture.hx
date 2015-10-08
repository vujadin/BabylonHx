package com.babylonhx.materials.textures;

import com.babylonhx.Engine;
import com.babylonhx.ISmartArrayCompatible;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.rendering.RenderingManager;
import com.babylonhx.cameras.Camera;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.tools.SmartArray;
import com.babylonhx.math.Matrix;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.RenderTargetTexture') class RenderTargetTexture extends Texture {
	
	public static inline var REFRESHRATE_RENDER_ONCE:Int = 0;
    public static inline var REFRESHRATE_RENDER_ONEVERYFRAME:Int = 1;
    public static inline var REFRESHRATE_RENDER_ONEVERYTWOFRAMES:Int = 2;
	
	public var renderList:Array<AbstractMesh> = [];
	public var renderParticles:Bool = true;
	public var renderSprites:Bool = false;
	public var onBeforeRender:Int->Void;
	public var onAfterRender:Int->Void;
	public var onAfterUnbind:Void->Void;
	public var onClear:Engine->Void;
	public var activeCamera:Camera;
	public var customRenderFunction:Dynamic;//SmartArray<SubMesh>->SmartArray<SubMesh>->SmartArray<SubMesh>->Void->Void;
	
	public var refreshRate(get, set):Int;
	public var canRescale(get, never):Bool;

	private var _size:Dynamic;
	public var _generateMipMaps:Bool;
	private var _renderingManager:RenderingManager;
	public var _waitingRenderList:Array<String>;
	private var _doNotChangeAspectRatio:Bool;
	private var _currentRefreshId:Int = -1;
	private var _refreshRate:Int = 1;
	private var _textureMatrix:Matrix;

	
	public function new(name:String, size:Dynamic, scene:Scene, ?generateMipMaps:Bool, doNotChangeAspectRatio:Bool = true, type:Int = Engine.TEXTURETYPE_UNSIGNED_INT, isCube:Bool = false) {
		super(null, scene, !generateMipMaps);
		
		this.coordinatesMode = Texture.PROJECTION_MODE;
		
		this.name = name;
		this.isRenderTarget = true;
		this._size = size;
		this._generateMipMaps = generateMipMaps;
		this._doNotChangeAspectRatio = doNotChangeAspectRatio;
		this.isCube = isCube;
		
		if (isCube) {
			this._texture = scene.getEngine().createRenderTargetCubeTexture(size, { generateMipMaps: generateMipMaps, type: type } );
			this.coordinatesMode = Texture.INVCUBIC_MODE;
            this._textureMatrix = Matrix.Identity();
		}
		else {
			this._texture = scene.getEngine().createRenderTargetTexture(size, { generateMipMaps: generateMipMaps, type: type });
		}
		
		// Rendering groups
		this._renderingManager = new RenderingManager(scene);
	}

	public function resetRefreshCounter() {
		this._currentRefreshId = -1;
	}

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
	
	override public function isReady():Bool {
		if (!this.getScene().renderTargetsEnabled) {
			return false;
		}
		return super.isReady();
	}

	public function getRenderSize():Float {
		return this._size;
	}

	private function get_canRescale():Bool {
		return true;
	}

	override public function scale(ratio:Float) {
		var newSize = Std.int(this._size * ratio);
		this.resize(newSize, this._generateMipMaps);
	}
	
	override public function getReflectionTextureMatrix():Matrix {
        if (this.isCube) {
            return this._textureMatrix;
        }
		
        return super.getReflectionTextureMatrix();
    }

	public function resize(size:Int, ?generateMipMaps:Bool) {
		this.releaseInternalTexture();
		if (this.isCube) {
			this._texture = this.getScene().getEngine().createRenderTargetCubeTexture(size);
		} 
		else {
			this._texture = this.getScene().getEngine().createRenderTargetTexture(size, generateMipMaps);
		}
	}

	public function render(useCameraPostProcess:Bool = false) {
		var scene = this.getScene();
		var engine = scene.getEngine();
		
		if (this._waitingRenderList != null) {
			this.renderList = [];
			for (index in 0...this._waitingRenderList.length) {
				var id = this._waitingRenderList[index];
				this.renderList.push(scene.getMeshByID(id));
			}
			
			this._waitingRenderList = null;
		}
		
		if (this.renderList != null && this.renderList.length == 0) {
			return;
		}
		
		// Prepare renderingManager
		this._renderingManager.reset();
		
		var currentRenderList:Array<AbstractMesh> = cast this.renderList != null ? this.renderList : scene.getActiveMeshes().data;
		
		for (mesh in currentRenderList) {
			if (mesh != null) {
				if (!mesh.isReady()) {
					// Reset _currentRefreshId
					this.resetRefreshCounter();
					continue;
				}
				
				if (mesh.isEnabled() && mesh.isVisible && mesh.subMeshes != null && ((mesh.layerMask & scene.activeCamera.layerMask) != 0)) {
					mesh._activate(scene.getRenderId());
					
					for (subMesh in mesh.subMeshes) {
						scene._activeIndices += subMesh.indexCount;
						this._renderingManager.dispatch(subMesh);
					}
				}
			}
		}
		
		if (this.isCube) {
			for (face in 0...6) {
				this.renderToTarget(face, currentRenderList, useCameraPostProcess);
			}
		} 
		else {
			this.renderToTarget(0, currentRenderList, useCameraPostProcess);
		}
		
		if (this.onAfterUnbind != null) {
			this.onAfterUnbind();
		}
		
		scene.resetCachedMaterial();
	}
	
	public function renderToTarget(faceIndex:Int, currentRenderList:Array<AbstractMesh>, useCameraPostProcess:Bool) {
		var scene = this.getScene();
		var engine = scene.getEngine();
		
		// Bind
		if (!useCameraPostProcess || !scene.postProcessManager._prepareFrame(this._texture)) {
			if (this.isCube) {
				engine.bindFramebuffer(this._texture, faceIndex);
			} 
			else {
				engine.bindFramebuffer(this._texture);
			}
		}
		
		if (this.onBeforeRender != null) {
			this.onBeforeRender(faceIndex);
		}
		
		// Clear
		if (this.onClear != null) {
			this.onClear(engine);
		} 
		else {
			engine.clear(scene.clearColor, true, true);
		}
		
		if (!this._doNotChangeAspectRatio) {
			scene.updateTransformMatrix(true);
		}
		
		// Render
		this._renderingManager.render(this.customRenderFunction, currentRenderList, this.renderParticles, this.renderSprites);
		
		if (useCameraPostProcess) {
			scene.postProcessManager._finalizeFrame(false, this._texture, faceIndex);
		}
		
		if (!this._doNotChangeAspectRatio) {
			scene.updateTransformMatrix(true);
		}
		
		if (this.onAfterRender != null) {
			this.onAfterRender(faceIndex);
		}
		
		// Unbind
		if (!this.isCube || faceIndex == 5) {
			if (this.isCube) {
				if (faceIndex == 5) {
					engine.generateMipMapsForCubemap(this._texture);
				}
			}
			
			engine.unBindFramebuffer(this._texture, true);
		}
	}

	override public function clone():RenderTargetTexture {
		var textureSize = this.getSize();
		var newTexture = new RenderTargetTexture(this.name, textureSize.width, this.getScene(), this._generateMipMaps);
		
		// Base texture
		newTexture.hasAlpha = this.hasAlpha;
		newTexture.level = this.level;
		
		// RenderTarget Texture
		newTexture.coordinatesMode = this.coordinatesMode;
		newTexture.renderList = this.renderList.slice(0);
		
		return newTexture;
	}
	
}
