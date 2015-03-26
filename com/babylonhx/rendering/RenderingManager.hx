package com.babylonhx.rendering;

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
	

	public function new(scene:Scene) {
		this._scene = scene;
	}

	private function _renderParticles(index:Int, activeMeshes:Array<AbstractMesh>) {
		if (this._scene._activeParticleSystems.length == 0) {
			return;
		}
		
		// Particles
		var beforeParticlesDate = Tools.Now();
		for (particleIndex in 0...this._scene._activeParticleSystems.length) {
			var particleSystem:ParticleSystem = cast this._scene._activeParticleSystems.data[particleIndex];
			
			if (particleSystem.renderingGroupId != index) {
				continue;
			}
			
			this._clearDepthBuffer();
			
			if (particleSystem.emitter.position == null || activeMeshes == null || activeMeshes.indexOf(particleSystem.emitter) != -1) {
				this._scene._activeParticles += particleSystem.render();
			}
		}
		this._scene._particlesDuration += Tools.Now() - beforeParticlesDate;
	}

	private function _renderSprites(index:Int) {
		if (!this._scene.spritesEnabled || this._scene.spriteManagers.length == 0) {
			return;
		}
		
		// Sprites       
		var beforeSpritessDate = Tools.Now();
		for (id in 0...this._scene.spriteManagers.length) {
			var spriteManager = this._scene.spriteManagers[id];
			
			if (spriteManager.renderingGroupId == index) {
				this._clearDepthBuffer();
				spriteManager.render();
			}
		}
		this._scene._spritesDuration += Tools.Now() - beforeSpritessDate;
	}

	private function _clearDepthBuffer() {
		if (this._depthBufferAlreadyCleaned) {
			return;
		}
		
		this._scene.getEngine().clear(new Color4(0, 0, 0), false, true);
		this._depthBufferAlreadyCleaned = true;
	}

	public function render(customRenderFunction:SmartArray->SmartArray->SmartArray->Void, activeMeshes:Array<AbstractMesh>, renderParticles:Bool, renderSprites:Bool) {
		var index:Int = 0;
		while(index < RenderingManager.MAX_RENDERINGGROUPS) {
		//for (index in 0...RenderingManager.MAX_RENDERINGGROUPS) {
			this._depthBufferAlreadyCleaned = false;
			var renderingGroup = this._renderingGroups[index];
			var needToStepBack = false;
			
			if (renderingGroup != null) {
				this._clearDepthBuffer();
				if (!renderingGroup.render(customRenderFunction)) {
					this._renderingGroups.splice(index, 1);
					needToStepBack = true;
				}
			}
			
			if(renderSprites) {
				this._renderSprites(index);
			}
			
			if (renderParticles) {
				this._renderParticles(index, activeMeshes);
			}
			
			if (needToStepBack) {
				index--;
			}
			
			++index;
		}
	}

	public function reset() {
		for (rg in this._renderingGroups) {
			rg.prepare();
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
