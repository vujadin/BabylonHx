package com.gamestudiohx.babylonhx.rendering;

import com.gamestudiohx.babylonhx.mesh.SubMesh;
import com.gamestudiohx.babylonhx.particles.ParticleSystem;
import com.gamestudiohx.babylonhx.Scene;
import com.gamestudiohx.babylonhx.mesh.Mesh;
import com.gamestudiohx.babylonhx.sprites.SpriteManager;
import com.gamestudiohx.babylonhx.tools.math.Color4;
import com.gamestudiohx.babylonhx.tools.SmartArray;
import flash.Lib;


/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class RenderingManager {
	
	public static var MAX_RENDERINGGROUPS:Int = 4;
	
	public var _scene:Scene;
	public var _renderingGroups:Array<RenderingGroup>;
	public var _depthBufferAlreadyCleaned:Bool;

	public function new(scene:Scene) {
		this._scene = scene;
        this._renderingGroups = [];
		
		_depthBufferAlreadyCleaned = false;
	}
	
	inline public function _renderParticles(index:Int, activeMeshes:Array<Mesh>) {
        if (this._scene._activeParticleSystems.length != 0) {
            // Particles
			var beforeParticlesDate = Lib.getTimer();
			for (particleIndex in 0...this._scene._activeParticleSystems.length) {
				var particleSystem:ParticleSystem = this._scene._activeParticleSystems.data[particleIndex];

				if (particleSystem.renderingGroupId == index) {
					this._clearDepthBuffer();

					if (!particleSystem.emitter.position || activeMeshes != null || Lambda.indexOf(activeMeshes, particleSystem.emitter) != -1) {
						this._scene._activeParticles += particleSystem.render();
					}
				}				
			}
			this._scene._particlesDuration += Lib.getTimer() - beforeParticlesDate;
        }        
    }
	
	public function _renderSprites(index:Int) {
        if (this._scene.spriteManagers.length == 0) {
            return;
        }

        // Sprites       
        var beforeSpritessDate = Lib.getTimer();
        for (id in 0...this._scene.spriteManagers.length) {
            var spriteManager:SpriteManager = this._scene.spriteManagers[id];

            if (spriteManager.renderingGroupId == index) {
                this._clearDepthBuffer();
                spriteManager.render();
            }
        }
        this._scene._spritesDuration += Lib.getTimer() - beforeSpritessDate;
    }
	
	public function _clearDepthBuffer() {
        if (this._depthBufferAlreadyCleaned) {
            return;
        }

        this._scene.getEngine().clear(new Color4(0, 0, 0), false, true);
        this._depthBufferAlreadyCleaned = true;
    }
	
	inline public function render(customRenderFunction:SmartArray->SmartArray->SmartArray->Dynamic->Bool, activeMeshes:Array<Mesh>, renderParticles:Bool, renderSprites:Bool) {    
        for (index in 0...RenderingManager.MAX_RENDERINGGROUPS) {
            this._depthBufferAlreadyCleaned = index == 0;
            var renderingGroup:RenderingGroup = this._renderingGroups[index];

            if (renderingGroup != null) {
                this._clearDepthBuffer();
                if (!renderingGroup.render(customRenderFunction, function () {
                    if (renderSprites) {
                        this._renderSprites(index);
                }
                })) {
                    this._renderingGroups.splice(index, 1);
                }
            } else if (renderSprites) {
                this._renderSprites(index);
            }

            if (renderParticles) {
                this._renderParticles(index, activeMeshes);
            }
        }
    }
	
	public function reset() {
        for (renderingGroup in this._renderingGroups) {
            renderingGroup.prepare();
        }
    }
	
	inline public function dispatch(subMesh:SubMesh) {
        var mesh:Mesh = subMesh.getMesh();
        var renderingGroupId = mesh.renderingGroupId;

        if (this._renderingGroups.length <= renderingGroupId) {
            this._renderingGroups[renderingGroupId] = new RenderingGroup(renderingGroupId, this._scene);
        }

        this._renderingGroups[renderingGroupId].dispatch(subMesh);
    }
	
}
