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
	
	/**
     * The max id used for rendering groups (not included)
     */
	public static inline var MAX_RENDERINGGROUPS:Int = 4;
	
	/**
     * The min id used for rendering groups (included)
     */
    inline public static var MIN_RENDERINGGROUPS:Int = 0;

	private var _scene:Scene;
	private var _renderingGroups:Array<RenderingGroup> = [];
	private var _depthStencilBufferAlreadyCleaned:Bool;
	
	private var _currentIndex:Int;
    private var _currentActiveMeshes:Array<AbstractMesh>;
    private var _currentRenderParticles:Bool;
    private var _currentRenderSprites:Bool;
	
	private var _autoClearDepthStencil:Array<Bool> = [];
	private var _customOpaqueSortCompareFn:Array<SubMesh->SubMesh->Int> = [];
	private var _customAlphaTestSortCompareFn:Array<SubMesh->SubMesh->Int> = [];
	private var _customTransparentSortCompareFn:Array<SubMesh->SubMesh->Int> = [];
	private var _renderinGroupInfo:RenderingGroupInfo = null;
	
	private var _activeCamera:Camera;
	

	public function new(scene:Scene) {
		this._scene = scene;
		
		for (i in RenderingManager.MIN_RENDERINGGROUPS...RenderingManager.MAX_RENDERINGGROUPS) {
			this._autoClearDepthStencil[i] = true;
		}
	}

	private function _renderParticles(index:Int, activeMeshes:Array<AbstractMesh>) {
		if (this._scene._activeParticleSystems.length == 0) {
			return;
		}
		
		// Particles
		_activeCamera = this._scene.activeCamera;
		//this._scene._particlesDuration.beginMonitoring();
		for (particleIndex in 0...this._scene._activeParticleSystems.length) {
			var particleSystem:ParticleSystem = cast this._scene._activeParticleSystems.data[particleIndex];
			
			if (particleSystem.renderingGroupId != index) {
				continue;
			}
			
			if ((_activeCamera.layerMask & particleSystem.layerMask) == 0) {
                continue;
            }
			
			this._clearDepthStencilBuffer();
			
			if (particleSystem.emitter.position == null || activeMeshes == null || activeMeshes.indexOf(particleSystem.emitter) != -1) {
				this._scene._activeParticles += particleSystem.render();
			}
		}
		//this._scene._particlesDuration.endMonitoring(false);
	}

	private function _renderSprites(index:Int) {
		if (!this._scene.spritesEnabled || this._scene.spriteManagers.length == 0) {
			return;
		}
		
		// Sprites 
		_activeCamera = this._scene.activeCamera;
		//this._scene._spritesDuration.beginMonitoring();
		for (id in 0...this._scene.spriteManagers.length) {
			var spriteManager = this._scene.spriteManagers[id];
			
			if (spriteManager.renderingGroupId == index && ((_activeCamera.layerMask & spriteManager.layerMask) != 0)) {
				this._clearDepthStencilBuffer();
				spriteManager.render();
			}
		}
		//this._scene._spritesDuration.endMonitoring(false);
	}

	inline private function _clearDepthStencilBuffer() {
		if (this._depthStencilBufferAlreadyCleaned) {
			return;
		}
		
		this._scene.getEngine().clear(0, false, true, true);
		this._depthStencilBufferAlreadyCleaned = true;		
	}
	
	private function _renderSpritesAndParticles() {
		if (this._currentRenderSprites) {
			this._renderSprites(this._currentIndex);
		}
		
		if (this._currentRenderParticles) {
			this._renderParticles(this._currentIndex, this._currentActiveMeshes);
		}
	}

	public function render(customRenderFunction:SmartArray<SubMesh>->SmartArray<SubMesh>->SmartArray<SubMesh>->Void = null, activeMeshes:Array<AbstractMesh>, renderParticles:Bool, renderSprites:Bool) {
		// Check if there's at least on observer on the onRenderingGroupObservable and initialize things to fire it
		var observable = this._scene.onRenderingGroupObservable.hasObservers() ? this._scene.onRenderingGroupObservable : null;
		var info:RenderingGroupInfo = null;
		if (observable != null) {
			if (this._renderinGroupInfo == null) {
				this._renderinGroupInfo = new RenderingGroupInfo();
			}
			info = this._renderinGroupInfo;
			info.scene = this._scene;
			info.camera = this._scene.activeCamera;
		}
		
		this._currentActiveMeshes = activeMeshes;
		this._currentRenderParticles = renderParticles;
		this._currentRenderSprites = renderSprites;
		
		var index = RenderingManager.MIN_RENDERINGGROUPS;
		while (index < RenderingManager.MAX_RENDERINGGROUPS) {
			this._depthStencilBufferAlreadyCleaned = index == RenderingManager.MIN_RENDERINGGROUPS;
			var renderingGroup = this._renderingGroups[index];
			var needToStepBack = false;
			
			this._currentIndex = index;
			
			if (renderingGroup != null) {
				var renderingGroupMask:Int = 0;
				
				// Fire PRECLEAR stage
				if (observable != null) {
					renderingGroupMask = cast Math.pow(2, index);
					info.renderStage = RenderingGroupInfo.STAGE_PRECLEAR;
					info.renderingGroupId = index;
					observable.notifyObservers(info, renderingGroupMask);
				}
				
				// Clear depth/stencil if needed
				if (this._autoClearDepthStencil[index]) {
					this._clearDepthStencilBuffer();
				}
				
				// Fire PREOPAQUE stage
				if (observable != null) {
					info.renderStage = RenderingGroupInfo.STAGE_PREOPAQUE;
					observable.notifyObservers(info, renderingGroupMask);
				}
				
				if (renderingGroup.onBeforeTransparentRendering == null) {
					renderingGroup.onBeforeTransparentRendering = this._renderSpritesAndParticles;
				}
				
				// Fire PRETRANSPARENT stage
				if (observable != null) {
					info.renderStage = RenderingGroupInfo.STAGE_PRETRANSPARENT;
					observable.notifyObservers(info, renderingGroupMask);
				}
				
				if (!renderingGroup.render(customRenderFunction)) {
					this._renderingGroups.splice(index, 1);
					needToStepBack = true;
					this._renderSpritesAndParticles();
				}
				
				// Fire POSTTRANSPARENT stage
				if (observable != null) {
					info.renderStage = RenderingGroupInfo.STAGE_POSTTRANSPARENT;
					observable.notifyObservers(info, renderingGroupMask);
				}
			} 
			else {
				this._renderSpritesAndParticles();
				
				if (observable != null) {
					var renderingGroupMask:Int = cast Math.pow(2, index);
					info.renderStage = RenderingGroupInfo.STAGE_PRECLEAR;
					info.renderingGroupId = index;
					observable.notifyObservers(info, renderingGroupMask);
					
					info.renderStage = RenderingGroupInfo.STAGE_POSTTRANSPARENT;
					observable.notifyObservers(info, renderingGroupMask);
				}
			}
			
			if (needToStepBack) {
				index--;
			}
			
			++index;
		}
	}

	public function reset() {
		for (index in RenderingManager.MIN_RENDERINGGROUPS...RenderingManager.MAX_RENDERINGGROUPS) {
			var renderingGroup = this._renderingGroups[index];
			if(renderingGroup != null) {
				renderingGroup.prepare();
			}
		}
	}

	public function dispatch(subMesh:SubMesh) {
		var mesh = subMesh.getMesh();
		var renderingGroupId = mesh.renderingGroupId;
		
		if (this._renderingGroups[renderingGroupId] == null) {
			this._renderingGroups[renderingGroupId] = new RenderingGroup(renderingGroupId, this._scene,
				this._customOpaqueSortCompareFn[renderingGroupId],
                this._customAlphaTestSortCompareFn[renderingGroupId],
                this._customTransparentSortCompareFn[renderingGroupId]
			);
		}
		
		this._renderingGroups[renderingGroupId].dispatch(subMesh);
	}
	
	/**
	 * Overrides the default sort function applied in the renderging group to prepare the meshes.
	 * This allowed control for front to back rendering or reversly depending of the special needs.
	 * 
	 * @param renderingGroupId The rendering group id corresponding to its index
	 * @param opaqueSortCompareFn The opaque queue comparison function use to sort.
	 * @param alphaTestSortCompareFn The alpha test queue comparison function use to sort.
	 * @param transparentSortCompareFn The transparent queue comparison function use to sort.
	 */
	public function setRenderingOrder(renderingGroupId:Int,
		opaqueSortCompareFn:SubMesh->SubMesh->Int = null,
		alphaTestSortCompareFn:SubMesh->SubMesh->Int = null,
		transparentSortCompareFn:SubMesh->SubMesh->Int = null) {
		
		this._customOpaqueSortCompareFn[renderingGroupId] = opaqueSortCompareFn;
		this._customAlphaTestSortCompareFn[renderingGroupId] = alphaTestSortCompareFn;
		this._customTransparentSortCompareFn[renderingGroupId] = transparentSortCompareFn;
		
		if (this._renderingGroups[renderingGroupId] != null) {
			var group = this._renderingGroups[renderingGroupId];
			group.opaqueSortCompareFn = this._customOpaqueSortCompareFn[renderingGroupId];
			group.alphaTestSortCompareFn = this._customAlphaTestSortCompareFn[renderingGroupId];
			group.transparentSortCompareFn = this._customTransparentSortCompareFn[renderingGroupId];
		}
	}

	/**
	 * Specifies whether or not the stencil and depth buffer are cleared between two rendering groups.
	 * 
	 * @param renderingGroupId The rendering group id corresponding to its index
	 * @param autoClearDepthStencil Automatically clears depth and stencil between groups if true.
	 */
	inline public function setRenderingAutoClearDepthStencil(renderingGroupId:Int, autoClearDepthStencil:Bool) {            
		this._autoClearDepthStencil[renderingGroupId] = autoClearDepthStencil;
	}

}
