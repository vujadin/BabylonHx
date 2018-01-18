package com.babylonhx.rendering;

import com.babylonhx.cameras.Camera;
import com.babylonhx.engine.Engine;
import com.babylonhx.tools.SmartArray;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.math.Vector3;
import com.babylonhx.materials.Material;
import com.babylonhx.sprites.SpriteManager;
import com.babylonhx.particles.IParticleSystem;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.RenderingGroup') class RenderingGroup {
	
	private var _scene:Scene;
	private var _opaqueSubMeshes:SmartArray<SubMesh> = new SmartArray<SubMesh>(256);
	private var _transparentSubMeshes:SmartArray<SubMesh> = new SmartArray<SubMesh>(256);
	private var _alphaTestSubMeshes:SmartArray<SubMesh> = new SmartArray<SubMesh>(256);
	private var _depthOnlySubMeshes:SmartArray<SubMesh> = new SmartArray<SubMesh>(256);
	private var _particleSystems:SmartArray<IParticleSystem> = new SmartArray<IParticleSystem>(256);
	private var _spriteManagers:SmartArray<SpriteManager> = new SmartArray<SpriteManager>(256);
	
	private var _opaqueSortCompareFn:SubMesh->SubMesh->Int;
    private var _alphaTestSortCompareFn:SubMesh->SubMesh->Int;
    private var _transparentSortCompareFn:SubMesh->SubMesh->Int;
	
	public var opaqueSortCompareFn(never, set):SubMesh->SubMesh->Int;
	public var alphaTestSortCompareFn(never, set):SubMesh->SubMesh->Int;
	public var transparentSortCompareFn(never, set):SubMesh->SubMesh->Int;
    
    private var _renderOpaque:SmartArray<SubMesh>->Void;
    private var _renderAlphaTest:SmartArray<SubMesh>->Void;
    private var _renderTransparent:SmartArray<SubMesh>->Void;
	
	private var _edgesRenderers:SmartArray<EdgesRenderer> = new SmartArray<EdgesRenderer>(16);
	
	public var onBeforeTransparentRendering:Void->Void;
	

	/**
	 * Set the opaque sort comparison function.
	 * If null the sub meshes will be render in the order they were created 
	 */
	private function set_opaqueSortCompareFn(?value:SubMesh->SubMesh->Int):SubMesh->SubMesh->Int {
		this._opaqueSortCompareFn = value;
		if (value != null) {
			this._renderOpaque = this.renderOpaqueSorted;
		}
		else {
			this._renderOpaque = RenderingGroup.renderUnsorted;
		}
		
		return value;
	}

	/**
	 * Set the alpha test sort comparison function.
	 * If null the sub meshes will be render in the order they were created 
	 */
	private function set_alphaTestSortCompareFn(?value:SubMesh->SubMesh->Int):SubMesh->SubMesh->Int {
		this._alphaTestSortCompareFn = value;
		if (value != null) {
			this._renderAlphaTest = this.renderAlphaTestSorted;
		}
		else {
			this._renderAlphaTest = RenderingGroup.renderUnsorted;
		}
		
		return value;
	}

	/**
	 * Set the transparent sort comparison function.
	 * If null the sub meshes will be render in the order they were created 
	 */
	private function set_transparentSortCompareFn(?value:SubMesh->SubMesh->Int):SubMesh->SubMesh->Int {
		if (value != null) {
			this._transparentSortCompareFn = value;
		}
		else {
			this._transparentSortCompareFn = RenderingGroup.defaultTransparentSortCompare;
		}
		this._renderTransparent = this.renderTransparentSorted;
		
		return value;
	}

	/**
	 * Creates a new rendering group.
	 * @param index The rendering group index
	 * @param opaqueSortCompareFn The opaque sort comparison function. If null no order is applied
	 * @param alphaTestSortCompareFn The alpha test sort comparison function. If null no order is applied
	 * @param transparentSortCompareFn The transparent sort comparison function. If null back to front + alpha index sort is applied
	 */
	public function new(index:Int, scene:Scene,
		opaqueSortCompareFn:SubMesh->SubMesh->Int = null,
		alphaTestSortCompareFn:SubMesh->SubMesh->Int = null,
		transparentSortCompareFn:SubMesh->SubMesh->Int = null) {
		this._scene = scene;
		
		this.opaqueSortCompareFn = opaqueSortCompareFn;
		this.alphaTestSortCompareFn = alphaTestSortCompareFn;
		this.transparentSortCompareFn = transparentSortCompareFn;
	}

	/**
     * Render all the sub meshes contained in the group.
     * @param customRenderFunction Used to override the default render behaviour of the group.
     */
	public function render(?customRenderFunction:SmartArray<SubMesh>->SmartArray<SubMesh>->SmartArray<SubMesh>->SmartArray<SubMesh>->Void, renderSprites:Bool, renderParticles:Bool, activeMeshes:Array<AbstractMesh>) {
		if (customRenderFunction != null) {
			customRenderFunction(this._opaqueSubMeshes, this._alphaTestSubMeshes, this._transparentSubMeshes, this._depthOnlySubMeshes);
			return;
		}
		
		var engine = this._scene.getEngine();
		
		// Depth only
        if (this._depthOnlySubMeshes.length != 0) {
            engine.setColorWrite(false);
            this._renderAlphaTest(this._depthOnlySubMeshes);
            engine.setColorWrite(true);
        } 
		
		// Opaque
		if (this._opaqueSubMeshes.length != 0) {
			this._renderOpaque(this._opaqueSubMeshes);
		}
		
		// Alpha test
		if (this._alphaTestSubMeshes.length != 0) {
			this._renderAlphaTest(this._alphaTestSubMeshes);
		}
		
		var stencilState = engine.getStencilBuffer();
		engine.setStencilBuffer(false);
		
		// Sprites
		if (renderSprites) {
			this._renderSprites();
		}
		
		// Particles
		if (renderParticles) {
			this._renderParticles(activeMeshes);
		}
		
		if (this.onBeforeTransparentRendering != null) {
			this.onBeforeTransparentRendering();
		}
		
		// Transparent
		if (this._transparentSubMeshes.length > 0) {
			this._renderTransparent(this._transparentSubMeshes);
			engine.setAlphaMode(Engine.ALPHA_DISABLE);
		}
		
		// Set back stencil to false in case it changes before the edge renderer.
        engine.setStencilBuffer(false);
		
		// Edges
		for (edgesRendererIndex in 0...this._edgesRenderers.length) {
			this._edgesRenderers.data[edgesRendererIndex].render();
		}
		
		// Restore Stencil state.
        engine.setStencilBuffer(stencilState);
	}
	
	/**
	 * Renders the opaque submeshes in the order from the opaqueSortCompareFn.
	 * @param subMeshes The submeshes to render
	 */
	inline private function renderOpaqueSorted(subMeshes:SmartArray<SubMesh>) {
		RenderingGroup.renderSorted(subMeshes, this._opaqueSortCompareFn, this._scene.activeCamera, false);
	}

	/**
	 * Renders the opaque submeshes in the order from the alphatestSortCompareFn.
	 * @param subMeshes The submeshes to render
	 */
	inline private function renderAlphaTestSorted(subMeshes:SmartArray<SubMesh>) {
		RenderingGroup.renderSorted(subMeshes, this._alphaTestSortCompareFn, this._scene.activeCamera, false);
	}

	/**
	 * Renders the opaque submeshes in the order from the transparentSortCompareFn.
	 * @param subMeshes The submeshes to render
	 */
	inline private function renderTransparentSorted(subMeshes:SmartArray<SubMesh>) {
		RenderingGroup.renderSorted(subMeshes, this._transparentSortCompareFn, this._scene.activeCamera, true);
	}

	/**
	 * Renders the submeshes in a specified order.
	 * @param subMeshes The submeshes to sort before render
	 * @param sortCompareFn The comparison function use to sort
	 * @param cameraPosition The camera position use to preprocess the submeshes to help sorting
	 * @param transparent Specifies to activate blending if true
	 */
	private static function renderSorted(subMeshes:SmartArray<SubMesh>, sortCompareFn:SubMesh->SubMesh->Int, camera:Camera, transparent:Bool) {
		var subMesh:SubMesh = null;
		var cameraPosition = camera != null ? camera.globalPosition : Vector3.Zero();
		for (subIndex in 0...subMeshes.length) {
			subMesh = subMeshes.data[subIndex];
			subMesh._alphaIndex = subMesh.getMesh().alphaIndex;
			subMesh._distanceToCamera = subMesh.getBoundingInfo().boundingSphere.centerWorld.subtract(cameraPosition).length();
		}
		
		var sortedArray = subMeshes.data.slice(0, subMeshes.length);
		
		if (sortCompareFn != null) {
			sortedArray.sort(sortCompareFn);
		}
		
		for (subIndex in 0...sortedArray.length) {
			subMesh = sortedArray[subIndex];
			
			if (transparent) {
                var material = subMesh.getMaterial();
				
                if (material != null && material.needDepthPrePass) {
                    var engine = material.getScene().getEngine();
                    engine.setColorWrite(false);
                    engine.setAlphaMode(Engine.ALPHA_DISABLE);
                    subMesh.render(false);
                    engine.setColorWrite(true);
                }
            }
			
			subMesh.render(transparent);
		}
	}

	/**
	 * Renders the submeshes in the order they were dispatched (no sort applied).
	 * @param subMeshes The submeshes to render
	 */
	inline private static function renderUnsorted(subMeshes:SmartArray<SubMesh>) {
		for (subIndex in 0...subMeshes.length) {
			var submesh = subMeshes.data[subIndex];
			submesh.render(false);
		}
	}

	/**
	 * Build in function which can be applied to ensure meshes of a special queue (opaque, alpha test, transparent)
	 * are rendered back to front if in the same alpha index.
	 * 
	 * @param a The first submesh
	 * @param b The second submesh
	 * @returns The result of the comparison
	 */
	public static function defaultTransparentSortCompare(a:SubMesh, b:SubMesh):Int {
		// Alpha index first
		if (a._alphaIndex > b._alphaIndex) {
			return 1;
		}
		if (a._alphaIndex < b._alphaIndex) {
			return -1;
		}
		
		// Then distance to camera
		return RenderingGroup.backToFrontSortCompare(a, b);
	}

	/**
	 * Build in function which can be applied to ensure meshes of a special queue (opaque, alpha test, transparent)
	 * are rendered back to front.
	 * 
	 * @param a The first submesh
	 * @param b The second submesh
	 * @returns The result of the comparison
	 */
	public static function backToFrontSortCompare(a:SubMesh, b:SubMesh):Int {
		// Then distance to camera
		if (a._distanceToCamera < b._distanceToCamera) {
			return 1;
		}
		if (a._distanceToCamera > b._distanceToCamera) {
			return -1;
		}
		
		return 0;
	}

	/**
	 * Build in function which can be applied to ensure meshes of a special queue (opaque, alpha test, transparent)
	 * are rendered front to back (prevent overdraw).
	 * 
	 * @param a The first submesh
	 * @param b The second submesh
	 * @returns The result of the comparison
	 */
	public static function frontToBackSortCompare(a:SubMesh, b:SubMesh):Int {
		// Then distance to camera
		if (a._distanceToCamera < b._distanceToCamera) {
			return -1;
		}
		if (a._distanceToCamera > b._distanceToCamera) {
			return 1;
		}
		
		return 0;
	}

	/**
	 * Resets the different lists of submeshes to prepare a new frame.
	 */	
	inline public function prepare() {
		this._opaqueSubMeshes.reset();
		this._transparentSubMeshes.reset();
		this._alphaTestSubMeshes.reset();
		this._depthOnlySubMeshes.reset();
		this._particleSystems.reset();
        this._spriteManagers.reset();
		this._edgesRenderers.reset();
	}
	
	public function dispose() {
		this._opaqueSubMeshes.dispose();
		this._transparentSubMeshes.dispose();
		this._alphaTestSubMeshes.dispose();
		this._depthOnlySubMeshes.dispose();
		this._particleSystems.dispose();
		this._spriteManagers.dispose();                      
		this._edgesRenderers.dispose();
	}

	/**
     * Inserts the submesh in its correct queue depending on its material.
     * @param subMesh The submesh to dispatch
     * @param [mesh] Optional reference to the submeshes's mesh. Provide if you have an exiting reference to improve performance.
     * @param [material] Optional reference to the submeshes's material. Provide if you have an exiting reference to improve performance.
     */
	inline public function dispatch(subMesh:SubMesh, ?mesh:AbstractMesh, ?material:Material) {
		// Get mesh and materials if not provided
		if (mesh == null) {
			mesh = subMesh.getMesh();
		}
		if (material == null) {
			material = subMesh.getMaterial();
		}
		
		if (material == null) {
			return;
		}
		
		if (material.needAlphaBlendingForMesh(mesh)) { // Transparent
			this._transparentSubMeshes.push(subMesh);
		} 
		else if (material.needAlphaTesting()) { // Alpha test
			if (material.needDepthPrePass) {
				this._depthOnlySubMeshes.push(subMesh);
			}
			
			this._alphaTestSubMeshes.push(subMesh);
		} 
		else {
			if (material.needDepthPrePass) {
				this._depthOnlySubMeshes.push(subMesh);
			}
			
			this._opaqueSubMeshes.push(subMesh); // Opaque
		}
		
		if (mesh._edgesRenderer != null) {
			this._edgesRenderers.push(mesh._edgesRenderer);
		}
	}
	
	inline public function dispatchSprites(spriteManager:SpriteManager) {
		this._spriteManagers.push(spriteManager);
	}

	inline public function dispatchParticles(particleSystem:IParticleSystem) {
		this._particleSystems.push(particleSystem);
	}

	private function _renderParticles(activeMeshes:Array<AbstractMesh>) {
		if (this._particleSystems.length == 0) {
			return;
		}
		
		// Particles
		var activeCamera = this._scene.activeCamera;
		this._scene.onBeforeParticlesRenderingObservable.notifyObservers(this._scene);
		for (particleIndex in 0...this._scene._activeParticleSystems.length) {
			var particleSystem = this._scene._activeParticleSystems.data[particleIndex];
			
			if (activeCamera != null && (activeCamera.layerMask & particleSystem.layerMask) == 0) {
				continue;
			}
			
			var emitter:Dynamic = particleSystem.emitter;
			if (emitter.position == null || activeMeshes == null || (Std.is(emitter, AbstractMesh) && activeMeshes.indexOf(particleSystem.emitter) != -1)) {
				//this._scene._activeParticles.addCount(particleSystem.render(), false);
				particleSystem.render();
			}
		}
		
		this._scene.onAfterParticlesRenderingObservable.notifyObservers(this._scene);
	}

	private function _renderSprites() {
		if (!this._scene.spritesEnabled || this._spriteManagers.length == 0) {
			return;
		}
		
		// Sprites       
		var activeCamera = this._scene.activeCamera;
		this._scene.onBeforeSpritesRenderingObservable.notifyObservers(this._scene);
		for (id in 0...this._spriteManagers.length) {
			var spriteManager = this._scene.spriteManagers[id];
			
			if (activeCamera != null && ((activeCamera.layerMask & spriteManager.layerMask) != 0)) {
				spriteManager.render();
			}
		}
		
		this._scene.onAfterSpritesRenderingObservable.notifyObservers(this._scene);
	}
	
}
