package com.babylonhx.rendering;

import com.babylonhx.cameras.Camera;
import com.babylonhx.math.Color4;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.sprites.SpriteManager;
import com.babylonhx.particles.IParticleSystem;
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
	
	/**
	 * Used to globally prevent autoclearing scenes.
	 */
	public static var AUTOCLEAR:Bool = true;

	private var _scene:Scene;
	private var _renderingGroups:Array<RenderingGroup> = [];
	private var _depthStencilBufferAlreadyCleaned:Bool;
	
	private var _currentIndex:Int;
	
	private var _autoClearDepthStencil:Array<RenderingManageAutoClearOptions> = [];	
	private var _customOpaqueSortCompareFn:Array<SubMesh->SubMesh->Int> = [];
	private var _customAlphaTestSortCompareFn:Array<SubMesh->SubMesh->Int> = [];
	private var _customTransparentSortCompareFn:Array<SubMesh->SubMesh->Int> = [];
	private var _renderinGroupInfo:RenderingGroupInfo = null;
	

	public function new(scene:Scene) {
		this._scene = scene;
		
		for (i in RenderingManager.MIN_RENDERINGGROUPS...RenderingManager.MAX_RENDERINGGROUPS) {
			this._autoClearDepthStencil[i] = new RenderingManageAutoClearOptions(true, true, true);
		}
	}

	/*inline*/ private function _clearDepthStencilBuffer(depth:Bool = true, stencil:Bool = true) {
		if (this._depthStencilBufferAlreadyCleaned) {
			return;
		}
		
		this._scene.getEngine().clear(null, false, depth, stencil);
		this._depthStencilBufferAlreadyCleaned = true;		
	}

	public function render(customRenderFunction:SmartArray<SubMesh>->SmartArray<SubMesh>->SmartArray<SubMesh>->SmartArray<SubMesh>->Void = null, activeMeshes:Array<AbstractMesh>, renderParticles:Bool, renderSprites:Bool) {
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
		
		// Dispatch sprites
        if (renderSprites) {
            for (index in 0...this._scene.spriteManagers.length) {
                var manager = this._scene.spriteManagers[index];
                this.dispatchSprites(manager);
            }
        }
		
		// Render
		for (index in RenderingManager.MIN_RENDERINGGROUPS...RenderingManager.MAX_RENDERINGGROUPS) {
			this._depthStencilBufferAlreadyCleaned = (index == RenderingManager.MIN_RENDERINGGROUPS);
			var renderingGroup = this._renderingGroups[index];			
			if (renderingGroup == null && observable == null) {
                continue;
			}
			
			this._currentIndex = index;
			
			var renderingGroupMask:Int = 0;
			
			// Fire PRECLEAR stage
			if (observable != null) {
				renderingGroupMask = Std.int(Math.pow(2, index));
				info.renderStage = RenderingGroupInfo.STAGE_PRECLEAR;
				info.renderingGroupId = index;
				observable.notifyObservers(info, renderingGroupMask);
			}
			
			// Clear depth/stencil if needed
			if (RenderingManager.AUTOCLEAR) {
				var autoClear = this._autoClearDepthStencil[index];
				if (autoClear != null && autoClear.autoClear) {
					this._clearDepthStencilBuffer(autoClear.depth, autoClear.stencil);
				}
			}
			
			if (observable != null) {
				// Fire PREOPAQUE stage
				info.renderStage = RenderingGroupInfo.STAGE_PREOPAQUE;
				observable.notifyObservers(info, renderingGroupMask);
				// Fire PRETRANSPARENT stage
				info.renderStage = RenderingGroupInfo.STAGE_PRETRANSPARENT;
				observable.notifyObservers(info, renderingGroupMask);
			}
			
			if (renderingGroup != null) {
				renderingGroup.render(customRenderFunction, renderSprites, renderParticles, activeMeshes);
			}
			
			// Fire POSTTRANSPARENT stage
			if (observable != null) {
				info.renderStage = RenderingGroupInfo.STAGE_POSTTRANSPARENT;
				observable.notifyObservers(info, renderingGroupMask);
			}
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
	
	public function dispose() {
		for (index in RenderingManager.MIN_RENDERINGGROUPS...RenderingManager.MAX_RENDERINGGROUPS) {
			var renderingGroup = this._renderingGroups[index];
			if (renderingGroup != null) {
				renderingGroup.dispose();
			}
		}
		
		this._renderingGroups.splice(0, this._renderingGroups.length);
	}

	private function _prepareRenderingGroup(renderingGroupId:Int) {
		if (this._renderingGroups[renderingGroupId] == null) {
			this._renderingGroups[renderingGroupId] = new RenderingGroup(renderingGroupId, this._scene,
				this._customOpaqueSortCompareFn[renderingGroupId],
                this._customAlphaTestSortCompareFn[renderingGroupId],
                this._customTransparentSortCompareFn[renderingGroupId]
			);
		}
	}
	
	public function dispatchSprites(spriteManager:SpriteManager) {
        var renderingGroupId = spriteManager.renderingGroupId;
		
        this._prepareRenderingGroup(renderingGroupId);
		
        this._renderingGroups[renderingGroupId].dispatchSprites(spriteManager);
    }

    public function dispatchParticles(particleSystem:IParticleSystem) {
        var renderingGroupId = particleSystem.renderingGroupId;
		
        this._prepareRenderingGroup(renderingGroupId);
		
        this._renderingGroups[renderingGroupId].dispatchParticles(particleSystem);
    }

    public function dispatch(subMesh:SubMesh) {
        var mesh = subMesh.getMesh();
        var renderingGroupId = mesh.renderingGroupId;
		
        this._prepareRenderingGroup(renderingGroupId);
		
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
	 * @param depth Automatically clears depth between groups if true and autoClear is true.
	 * @param stencil Automatically clears stencil between groups if true and autoClear is true.
	 */
	inline public function setRenderingAutoClearDepthStencil(renderingGroupId:Int, autoClearDepthStencil:Bool, depth:Bool = true, stencil:Bool = true) { 
		this._autoClearDepthStencil[renderingGroupId].autoClear = autoClearDepthStencil;
        this._autoClearDepthStencil[renderingGroupId].depth = depth;
        this._autoClearDepthStencil[renderingGroupId].stencil = stencil;
	}
	
}
