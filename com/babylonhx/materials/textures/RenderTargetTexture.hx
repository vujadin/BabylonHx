package com.babylonhx.materials.textures;

import com.babylonhx.Engine;
import com.babylonhx.ISmartArrayCompatible;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.rendering.RenderingManager;
import com.babylonhx.cameras.Camera;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.tools.SmartArray;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.RenderTargetTexture') class RenderTargetTexture extends Texture {
	
	public var renderList:Array<AbstractMesh> = [];
	public var renderParticles:Bool = true;
	public var renderSprites:Bool = false;
	public var onBeforeRender:Void->Void;
	public var onAfterRender:Void->Void;
	public var onAfterUnbind:Void->Void;
	public var onClear:Engine->Void;
	public var activeCamera:Camera;
	public var customRenderFunction:Dynamic;//SmartArray<SubMesh>->SmartArray<SubMesh>->SmartArray<SubMesh>->Void->Void;

	private var _size:Dynamic;
	public var _generateMipMaps:Bool;
	private var _renderingManager:RenderingManager;
	public var _waitingRenderList:Array<String>;
	private var _doNotChangeAspectRatio:Bool;
	private var _currentRefreshId:Int = -1;
	private var _refreshRate:Int = 1;

	
	public function new(name:String, size:Dynamic, scene:Scene, ?generateMipMaps:Bool, doNotChangeAspectRatio:Bool = true, type:Int = Engine.TEXTURETYPE_UNSIGNED_INT) {
		super(null, scene, !generateMipMaps);
		
		this.coordinatesMode = Texture.PROJECTION_MODE;
		
		this.name = name;
		this.isRenderTarget = true;
		this._size = size;
		this._generateMipMaps = generateMipMaps;
		this._doNotChangeAspectRatio = doNotChangeAspectRatio;
		
		this._texture = scene.getEngine().createRenderTargetTexture(size, { generateMipMaps: generateMipMaps, type: type });
		
		// Rendering groups
		this._renderingManager = new RenderingManager(scene);
	}

	public function resetRefreshCounter() {
		this._currentRefreshId = -1;
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

	public var canRescale(get, never):Bool;
	private function get_canRescale():Bool {
		return true;
	}

	override public function scale(ratio:Float) {
		var newSize = this._size * ratio;
		this.resize(newSize, this._generateMipMaps);
	}

	public function resize(size:Float, ?generateMipMaps:Bool) {
		this.releaseInternalTexture();
		this._texture = this.getScene().getEngine().createRenderTargetTexture(size, generateMipMaps);
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
		
		// Bind
		if (!useCameraPostProcess || !scene.postProcessManager._prepareFrame(this._texture)) {
			engine.bindFramebuffer(this._texture);
		}
		
		this._renderingManager.reset();
		
		var currentRenderList:Array<AbstractMesh> = this.renderList != null ? this.renderList : cast scene.getActiveMeshes().data;
		
		for (meshIndex in 0...currentRenderList.length) {
			var mesh:Mesh = cast currentRenderList[meshIndex];
			
			if (mesh != null) {
				if (!mesh.isReady()) {
					// Reset _currentRefreshId
					this.resetRefreshCounter();
					continue;
				}
				
				if (mesh.isEnabled() && mesh.isVisible && (mesh.subMeshes != null) && ((mesh.layerMask & scene.activeCamera.layerMask) != 0)) {
					mesh._activate(scene.getRenderId());
					
					for (subIndex in 0...mesh.subMeshes.length) {
						var subMesh = mesh.subMeshes[subIndex];
						scene._activeVertices += subMesh.indexCount;
						this._renderingManager.dispatch(subMesh);
					}
				}
			}
		}
				
		if (this.onBeforeRender != null) {
			this.onBeforeRender();
		}
		
		// Clear
		if (this.onClear != null) {
			this.onClear(engine);
		} else {
			engine.clear(scene.clearColor, true, true);
		}
		
		if (!this._doNotChangeAspectRatio) {
			scene.updateTransformMatrix(true);
		}
		
		// Render
		this._renderingManager.render(this.customRenderFunction, currentRenderList, this.renderParticles, this.renderSprites);
		
		if (useCameraPostProcess) {
			scene.postProcessManager._finalizeFrame(false, this._texture);
		}
		
		if (!this._doNotChangeAspectRatio) {
			scene.updateTransformMatrix(true);
		}
		
		if (this.onAfterRender != null) {
			this.onAfterRender();
		}
		
		// Unbind
		engine.unBindFramebuffer(this._texture);
		
		if (this.onAfterUnbind != null) {
			this.onAfterUnbind();
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
