package com.babylonhx.rendering;

import com.babylonhx.tools.SmartArray;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.math.Vector3;
import com.babylonhx.materials.Material;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.RenderingGroup') class RenderingGroup {
	
	public var index:Int;
	
	private var _scene:Scene;
	private var _opaqueSubMeshes:SmartArray<SubMesh> = new SmartArray<SubMesh>();
	private var _transparentSubMeshes:SmartArray<SubMesh> = new SmartArray<SubMesh>();
	private var _alphaTestSubMeshes:SmartArray<SubMesh> = new SmartArray<SubMesh>();
	private var _activeVertices:Int = 0;
	
	private var _opaqueSortCompareFn:SubMesh->SubMesh->Int;
    private var _alphaTestSortCompareFn:SubMesh->SubMesh->Int;
    private var _transparentSortCompareFn:SubMesh->SubMesh->Int;
	
	public var opaqueSortCompareFn(never, set):SubMesh->SubMesh->Int;
	public var alphaTestSortCompareFn(never, set):SubMesh->SubMesh->Int;
	public var transparentSortCompareFn(never, set):SubMesh->SubMesh->Int;
    
    private var _renderOpaque:SmartArray<SubMesh>->Void;
    private var _renderAlphaTest:SmartArray<SubMesh>->Void;
    private var _renderTransparent:SmartArray<SubMesh>->Void;
	
	public var onBeforeTransparentRendering:Void->Void;
	

	/**
	 * Set the opaque sort comparison function.
	 * If null the sub meshes will be render in the order they were created 
	 */
	private function set_opaqueSortCompareFn(value:SubMesh->SubMesh->Int):SubMesh->SubMesh->Int {
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
	private function set_alphaTestSortCompareFn(value:SubMesh->SubMesh->Int):SubMesh->SubMesh->Int {
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
	private function set_transparentSortCompareFn(value:SubMesh->SubMesh->Int):SubMesh->SubMesh->Int {
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
		this.index = index;
		
		this.opaqueSortCompareFn = opaqueSortCompareFn;
		this.alphaTestSortCompareFn = alphaTestSortCompareFn;
		this.transparentSortCompareFn = transparentSortCompareFn;
	}

	/**
     * Render all the sub meshes contained in the group.
     * @param customRenderFunction Used to override the default render behaviour of the group.
     * @returns true if rendered some submeshes.
     */
	public function render(?customRenderFunction:SmartArray<SubMesh>->SmartArray<SubMesh>->SmartArray<SubMesh>->Void):Bool {
		if (customRenderFunction != null) {
			customRenderFunction(this._opaqueSubMeshes, this._alphaTestSubMeshes, this._transparentSubMeshes);
			
			return true;
		}
		
		if (this._opaqueSubMeshes.length == 0 && this._alphaTestSubMeshes.length == 0 && this._transparentSubMeshes.length == 0) {
			if (this.onBeforeTransparentRendering != null) {
                this.onBeforeTransparentRendering();
            }
			
			return false;
		}
		
		var engine = this._scene.getEngine();
		
		// Opaque
		this._renderOpaque(this._opaqueSubMeshes);
		
		// Alpha test
		engine.setAlphaTesting(true);
		this._renderAlphaTest(this._alphaTestSubMeshes);
		engine.setAlphaTesting(false);
		
		if (this.onBeforeTransparentRendering != null) {
			this.onBeforeTransparentRendering();
		}
		
		// Transparent
		this._renderTransparent(this._transparentSubMeshes);
		engine.setAlphaMode(Engine.ALPHA_DISABLE);
		
		return true;
	}
	
	/**
	 * Renders the opaque submeshes in the order from the opaqueSortCompareFn.
	 * @param subMeshes The submeshes to render
	 */
	inline private function renderOpaqueSorted(subMeshes:SmartArray<SubMesh>) {
		RenderingGroup.renderSorted(subMeshes, this._opaqueSortCompareFn, this._scene.activeCamera.globalPosition, false);
	}

	/**
	 * Renders the opaque submeshes in the order from the alphatestSortCompareFn.
	 * @param subMeshes The submeshes to render
	 */
	inline private function renderAlphaTestSorted(subMeshes:SmartArray<SubMesh>) {
		RenderingGroup.renderSorted(subMeshes, this._alphaTestSortCompareFn, this._scene.activeCamera.globalPosition, false);
	}

	/**
	 * Renders the opaque submeshes in the order from the transparentSortCompareFn.
	 * @param subMeshes The submeshes to render
	 */
	inline private function renderTransparentSorted(subMeshes:SmartArray<SubMesh>) {
		RenderingGroup.renderSorted(subMeshes, this._transparentSortCompareFn, this._scene.activeCamera.globalPosition, true);
	}

	/**
	 * Renders the submeshes in a specified order.
	 * @param subMeshes The submeshes to sort before render
	 * @param sortCompareFn The comparison function use to sort
	 * @param cameraPosition The camera position use to preprocess the submeshes to help sorting
	 * @param transparent Specifies to activate blending if true
	 */
	private static function renderSorted(subMeshes:SmartArray<SubMesh>, sortCompareFn:SubMesh->SubMesh->Int, cameraPosition:Vector3, transparent:Bool) {
		var subMesh:SubMesh = null;
		for (subIndex in 0...subMeshes.length) {
			subMesh = subMeshes.data[subIndex];
			subMesh._alphaIndex = subMesh.getMesh().alphaIndex;
			subMesh._distanceToCamera = subMesh.getBoundingInfo().boundingSphere.centerWorld.subtract(cameraPosition).length();
		}
		
		var sortedArray = subMeshes.data.slice(0, subMeshes.length);
		sortedArray.sort(sortCompareFn);
		
		for (subIndex in 0...sortedArray.length) {
			subMesh = sortedArray[subIndex];
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
	}

	static var material:Material;
	static var mesh:AbstractMesh;
	/**
	 * Inserts the submesh in its correct queue depending on its material.
	 * @param subMesh The submesh to dispatch
	 */
	inline public function dispatch(subMesh:SubMesh) {
		material = subMesh.getMaterial();
		mesh = subMesh.getMesh();
		
		if (material.needAlphaBlending() || mesh.visibility < 1.0 || mesh.hasVertexAlpha) { // Transparent
			this._transparentSubMeshes.push(subMesh);
		} 
		else if (material.needAlphaTesting()) { // Alpha test
			this._alphaTestSubMeshes.push(subMesh);
		} 
		else {
			this._opaqueSubMeshes.push(subMesh); // Opaque
		}
	}
	
}
