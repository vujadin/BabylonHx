package com.babylonhx.rendering;

import com.babylonhx.cameras.Camera;
import com.babylonhx.math.Color4;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.tools.SmartArray;
import com.babylonhx.tools.Tools;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.RenderingManager') class RenderingManager {
	
	public static var MAX_RENDERINGGROUPS:Int = 4;

	private var _scene:Scene;
	private var _renderingGroups:Array<RenderingGroup> = [];
	private var _depthBufferAlreadyCleaned:Bool;
	
	private var _currentIndex:Int;
    private var _currentActiveMeshes:Array<AbstractMesh>;
    private var _currentRenderParticles:Bool;
    private var _currentRenderSprites:Bool;
	
	private var _activeCamera:Camera;
	

	public function new(scene:Scene) {
		this._scene = scene;
	}

	private function _renderParticles(index:Int, activeMeshes:Array<AbstractMesh>) {
		if (this._scene._activeParticleSystems.length == 0) {
			return;
		}
		
		// Particles
		_activeCamera = this._scene.activeCamera;
		//var beforeParticlesDate = Tools.Now();
		for (particleIndex in 0...this._scene._activeParticleSystems.length) {
			var particleSystem:ParticleSystem = cast this._scene._activeParticleSystems.data[particleIndex];
			
			if (particleSystem.renderingGroupId != index) {
				continue;
			}
			
			if ((_activeCamera.layerMask & particleSystem.layerMask) == 0) {
                continue;
            }
			
			this._clearDepthBuffer();
			
			if (particleSystem.emitter.position == null || activeMeshes == null || activeMeshes.indexOf(particleSystem.emitter) != -1) {
				this._scene._activeParticles += particleSystem.render();
			}
		}
		//this._scene._particlesDuration += Tools.Now() - beforeParticlesDate;
	}

	private function _renderSprites(index:Int) {
		if (!this._scene.spritesEnabled || this._scene.spriteManagers.length == 0) {
			return;
		}
		
		// Sprites 
		_activeCamera = this._scene.activeCamera;
		//var beforeSpritessDate = Tools.Now();
		for (id in 0...this._scene.spriteManagers.length) {
			var spriteManager = this._scene.spriteManagers[id];
			
			if (spriteManager.renderingGroupId == index && ((_activeCamera.layerMask & spriteManager.layerMask) != 0)) {
				this._clearDepthBuffer();
				spriteManager.render();
			}
		}
		//this._scene._spritesDuration += Tools.Now() - beforeSpritessDate;
	}

	inline private function _clearDepthBuffer() {
		if (!this._depthBufferAlreadyCleaned) {
			this._scene.getEngine().clear(new Color4(0, 0, 0), false, true);
			this._depthBufferAlreadyCleaned = true;
		}		
	}
	
	private function _renderSpritesAndParticles() {
		if (this._currentRenderSprites) {
			this._renderSprites(this._currentIndex);
		}
		
		if (this._currentRenderParticles) {
			this._renderParticles(this._currentIndex, this._currentActiveMeshes);
		}
	}

	static var _renderingGroup:RenderingGroup;
	static var _needToStepBack:Bool;
	public function render(customRenderFunction:SmartArray<SubMesh>->SmartArray<SubMesh>->SmartArray<SubMesh>->Void, activeMeshes:Array<AbstractMesh>, renderParticles:Bool, renderSprites:Bool) {
		this._currentActiveMeshes = activeMeshes;
        this._currentRenderParticles = renderParticles;
        this._currentRenderSprites = renderSprites;
		
		var index:Int = 0;
		while(index < RenderingManager.MAX_RENDERINGGROUPS) {
			this._depthBufferAlreadyCleaned = false;
			_renderingGroup = this._renderingGroups[index];
			_needToStepBack = false;
			
			this._currentIndex = index;
			
			if (_renderingGroup != null) {
				this._clearDepthBuffer();
				
				if (_renderingGroup.onBeforeTransparentRendering == null) {
                    _renderingGroup.onBeforeTransparentRendering = this._renderSpritesAndParticles;
                }
				
				if (!_renderingGroup.render(customRenderFunction)) {
					this._renderingGroups.splice(index, 1);
					_needToStepBack = true;
					this._renderSpritesAndParticles();
				}
			}
			else {
				this._renderSpritesAndParticles();
			}
			
			if (_needToStepBack) {
				index--;
			}
			
			++index;
		}
	}

	public function reset() {
		for (rg in this._renderingGroups) {
			if(rg != null) {
				rg.prepare();
			}
		}
	}

	public function dispatch(subMesh:SubMesh) {
		var mesh = subMesh.getMesh();
		var renderingGroupId = mesh.renderingGroupId;
		
		if (this._renderingGroups[renderingGroupId] == null) {
			this._renderingGroups[renderingGroupId] = new RenderingGroup(renderingGroupId, this._scene);
		}
		
		this._renderingGroups[renderingGroupId].dispatch(subMesh);
	}

}
