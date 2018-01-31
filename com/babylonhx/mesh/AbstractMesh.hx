package com.babylonhx.mesh;

import com.babylonhx.engine.Engine;
import com.babylonhx.actions.ActionManager;
import com.babylonhx.bones.Bone;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.cameras.Camera;
import com.babylonhx.collisions.Collider;
import com.babylonhx.collisions.IntersectionInfo;
import com.babylonhx.collisions.PickingInfo;
import com.babylonhx.culling.Ray;
import com.babylonhx.culling.ICullable;
import com.babylonhx.culling.BoundingInfo;
import com.babylonhx.culling.BoundingSphere;
import com.babylonhx.culling.octrees.Octree;
import com.babylonhx.lights.Light;
import com.babylonhx.materials.Material;
import com.babylonhx.materials.MaterialDefines;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Plane;
import com.babylonhx.math.Axis;
import com.babylonhx.math.Quaternion;
import com.babylonhx.math.Space;
import com.babylonhx.math.Tools;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Frustum;
import com.babylonhx.Node.NodeCache;
import com.babylonhx.physics.PhysicsEngine;
import com.babylonhx.physics.PhysicsBodyCreationOptions;
import com.babylonhx.rendering.EdgesRenderer;
import com.babylonhx.math.Tmp;
import com.babylonhx.tools.Observable;
import com.babylonhx.tools.Observer;
import com.babylonhx.tools.EventState;
import com.babylonhx.math.Tools.BabylonMinMax;
import com.babylonhx.math.Tools as MathTools;

import lime.graphics.opengl.GLQuery;
import lime.utils.UInt32Array;
import lime.utils.Float32Array;
import lime.utils.UInt16Array;

typedef DepthSortedFacet = {
	ind: Int,
	sqDistance: Float
}

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.AbstractMesh') class AbstractMesh extends TransformNode implements IDisposable implements ICullable implements IGetSetVerticesData implements IHasBoundingInfo {
	
	public static inline var OCCLUSION_TYPE_NONE:Int = 0;
	public static inline var OCCLUSION_TYPE_OPTIMISTIC:Int = 1;
	public static inline var OCCLUSION_TYPE_STRICT:Int = 2;
	public static inline var OCCLUSION_ALGORITHM_TYPE_ACCURATE:Int = 0;
	public static inline var OCCLUSION_ALGORITHM_TYPE_CONSERVATIVE:Int = 1;
	
	
	// facetData private properties
	private var _facetPositions:Array<Vector3>;         // facet local positions
	private var _facetNormals:Array<Vector3>;           // facet local normals
	private var _facetPartitioning:Array<Array<Int>>;   // partitioning array of facet index arrays
	private var _facetNb:Int = 0;                   	// facet number
	private var _partitioningSubdivisions:Int = 10;     // number of subdivisions per axis in the partioning space  
	private var _partitioningBBoxRatio:Float = 1.01;    // the partioning array space is by default 1% bigger than the bounding box
	private var _facetDataEnabled:Bool = false;         // is the facet data feature enabled on this mesh ?
	private var _facetParameters:Dynamic = {};          // keep a reference to the object parameters to avoid memory re-allocation
	private var _bbSize:Vector3 = Vector3.Zero();      	// bbox size approximated for facet data
	private var _subDiv:Dynamic = {                     // actual number of subdivisions per axis for ComputeNormals()
		max: 1,
		X: 1,
		Y: 1,
		Z: 1
	};
	private var _facetDepthSort:Bool = false;                           			// is the facet depth sort to be computed
    private var _facetDepthSortEnabled:Bool = false;                    			// is the facet depth sort initialized
    private var _depthSortedIndices:UInt32Array;                         			// copy of the indices array to store them once sorted
    private var _depthSortedFacets:Array<DepthSortedFacet>;    						// array of depth sorted facets
    private var _facetDepthSortFunction:DepthSortedFacet->DepthSortedFacet->Int;  	// facet depth sort function
    private var _facetDepthSortFrom:Vector3;                            			// location where to depth sort from
    private var _facetDepthSortOrigin:Vector3;                          			// same as facetDepthSortFrom but expressed in the mesh local space
    private var _invertedMatrix:Matrix;                                 			// Mesh inverted World Matrix
	
	/**
	 * Read-only : the number of facets in the mesh
	 */
	public var facetNb(get, never):Int;
	inline private function get_facetNb():Int {
		return this._facetNb;
	}
	/**
	 * The number (integer) of subdivisions per axis in the partioning space
	 */
	public var partitioningSubdivisions(get, set):Int;
	inline private function get_partitioningSubdivisions():Int {
		return this._partitioningSubdivisions;
	}
	inline private function set_partitioningSubdivisions(nb:Int):Int {
		return this._partitioningSubdivisions = nb;
	} 
	/**
	 * The ratio (float) to apply to the bouding box size to set to the partioning space.  
	 * Ex : 1.01 (default) the partioning space is 1% bigger than the bounding box.
	 */
	public var partitioningBBoxRatio(get, set):Float;
	inline private function get_partitioningBBoxRatio():Float {
		return this._partitioningBBoxRatio;
	}
	inline private function set_partitioningBBoxRatio(ratio:Float):Float {
		return this._partitioningBBoxRatio = ratio;
	}
	/**
	 * Boolean : must the facet be depth sorted on next call to `updateFacetData()` ?  
	 * Works only for updatable meshes.  
	 * Doesn't work with multi-materials.  
	 */
	public var mustDepthSortFacets(get, set):Bool;
	private function get_mustDepthSortFacets():Bool {
		return this._facetDepthSort;
	}
	private function set_mustDepthSortFacets(sort:Bool):Bool {
		return this._facetDepthSort = sort;
	}
	/**
	 * The location (Vector3) where the facet depth sort must be computed from.  
	 * By default, the active camera position.  
	 * Used only when facet depth sort is enabled.  
	 */
	public var facetDepthSortFrom(get, set):Vector3;
	private function get_facetDepthSortFrom():Vector3 {
		return this._facetDepthSortFrom;
	}
	private function set_facetDepthSortFrom(location:Vector3):Vector3 {
		return this._facetDepthSortFrom = location;
	}
	/**
	 * Read-only boolean : is the feature facetData enabled ?
	 */
	public var isFacetDataEnabled(get, never):Bool;
	inline private function get_isFacetDataEnabled():Bool {
		return this._facetDataEnabled;
	}
	
	override public function _updateNonUniformScalingState(value:Bool):Bool {
		if (!super._updateNonUniformScalingState(value)) {
			return false;
		}
		this._markSubMeshesAsMiscDirty();
		return true;
	}

	// Events
	
	
	// BHX: moved from Mesh - (START)
	/**
	 * An event triggered before rendering the mesh
	 * @type {BABYLON.Observable}
	 */
	public var onBeforeRenderObservable:Observable<AbstractMesh> = new Observable<AbstractMesh>();

	/**
	* An event triggered after rendering the mesh
	* @type {BABYLON.Observable}
	*/
	public var onAfterRenderObservable:Observable<AbstractMesh> = new Observable<AbstractMesh>();

	/**
	* An event triggered before drawing the mesh
	* @type {BABYLON.Observable}
	*/
	public var onBeforeDrawObservable:Observable<AbstractMesh> = new Observable<AbstractMesh>();

	private var _onBeforeDrawObserver:Observer<AbstractMesh>;
	public var onBeforeDraw(never, set):AbstractMesh->Null<EventState<AbstractMesh>>->Void;
	private function set_onBeforeDraw(callback:AbstractMesh->Null<EventState<AbstractMesh>>->Void):AbstractMesh->Null<EventState<AbstractMesh>>->Void {
		if (this._onBeforeDrawObserver != null) {
			this.onBeforeDrawObservable.remove(this._onBeforeDrawObserver);
		}
		
		this._onBeforeDrawObserver = this.onBeforeDrawObservable.add(callback);
		
		return callback;
	}
	// BHX: moved from mesh - (END)

	/**
	* An event triggered when this mesh collides with another one
	* @type {BABYLON.Observable}
	*/
	public var onCollideObservable:Observable<AbstractMesh> = new Observable<AbstractMesh>();
	private var _onCollideObserver:Observer<AbstractMesh>;
	public var onCollide(never, set):AbstractMesh->Null<EventState<AbstractMesh>>->Void;
	private function set_onCollide(callback:AbstractMesh->Null<EventState<AbstractMesh>>->Void):AbstractMesh->Null<EventState<AbstractMesh>>->Void {
		if (this._onCollideObserver != null) {
			this.onCollideObservable.remove(this._onCollideObserver);
		}
		this._onCollideObserver = this.onCollideObservable.add(callback);
		
		return callback;
	}

	/**
	* An event triggered when the collision's position changes
	* @type {BABYLON.Observable}
	*/
	public var onCollisionPositionChangeObservable:Observable<Vector3> = new Observable<Vector3>();
	private var _onCollisionPositionChangeObserver:Observer<Vector3>;
	public var onCollisionPositionChange(never, set):Vector3->Null<EventState<Vector3>>->Void;
	private function set_onCollisionPositionChange(callback:Vector3->Null<EventState<Vector3>>->Void):Vector3->Null<EventState<Vector3>>->Void {
		if (this._onCollisionPositionChangeObserver != null) {
			this.onCollisionPositionChangeObservable.remove(this._onCollisionPositionChangeObserver);
		}
		this._onCollisionPositionChangeObserver = this.onCollisionPositionChangeObservable.add(callback);
		
		return callback;
	}
	
	/**
    * An event triggered when material is changed
    * @type {BABYLON.Observable}
    */
    public var onMaterialChangedObservable:Observable<AbstractMesh> = new Observable<AbstractMesh>();

	// Properties
	public var definedFacingForward:Bool = true; // orientation for POV movement & rotation

	/**
	 * This property determines the type of occlusion query algorithm to run in WebGl, you can use:
	 * AbstractMesh.OCCLUSION_ALGORITHM_TYPE_ACCURATE which is mapped to GL_ANY_SAMPLES_PASSED.
	 * or
	 * AbstractMesh.OCCLUSION_ALGORITHM_TYPE_CONSERVATIVE (Default Value) which is mapped to GL_ANY_SAMPLES_PASSED_CONSERVATIVE which is a false positive  algorithm that is faster than GL_ANY_SAMPLES_PASSED but less accurate.
 	 * for more info check WebGl documentations
	 */
	public var occlusionQueryAlgorithmType:Int = AbstractMesh.OCCLUSION_ALGORITHM_TYPE_CONSERVATIVE;
	/**
	 * This property is responsible for starting the occlusion query within the Mesh or not, this property is also used     to determine what should happen when the occlusionRetryCount is reached. It has supports 3 values:
	 * OCCLUSION_TYPE_NONE (Default Value): this option means no occlusion query whith the Mesh.
	 * OCCLUSION_TYPE_OPTIMISTIC: this option is means use occlusion query and if occlusionRetryCount is reached and the query is broken show the mesh.
	 * OCCLUSION_TYPE_STRICT: this option is means use occlusion query and if occlusionRetryCount is reached and the query is broken restore the last state of the mesh occlusion if the mesh was visible then show the mesh if was hidden then hide don't show.
	 */
	public var occlusionType:Int = AbstractMesh.OCCLUSION_TYPE_NONE;
	/**
	 * This number indicates the number of allowed retries before stop the occlusion query, this is useful if the        occlusion query is taking long time before to the query result is retireved, the query result indicates if the object is visible within the scene or not and based on that Babylon.Js engine decideds to show or hide the object.
	 * The default value is -1 which means don't break the query and wait till the result.
	 */
	public var occlusionRetryCount:Int = -1;
	private var _occlusionInternalRetryCounter:Int = 0;

	private var _isOccluded:Bool = false;
	/**
	 * Property isOccluded : Gets or sets whether the mesh is occluded or not, it is used also to set the intial state of the mesh to be occluded or not.
	 */
	public var isOccluded(get, set):Bool;
	private inline function get_isOccluded():Bool {
		return this._isOccluded;
	}
	private inline function set_isOccluded(val:Bool):Bool {
		return this._isOccluded = val;
	}
	
	/**
	 * Flag to check the progress status of the query
	 */
	private var _isOcclusionQueryInProgress:Bool = false;
	public var isOcclusionQueryInProgress(get, never):Bool;
	public inline function get_isOcclusionQueryInProgress():Bool {
		return _isOcclusionQueryInProgress;
	}

	private var _occlusionQuery:GLQuery;
	
	private var _visibility:Float = 1.0;
	public var visibility(get, set):Float;
	/**
	 * Gets or sets mesh visibility between 0 and 1 (defult is 1)
	 */
	function get_visibility():Float {
		return this._visibility;
	}
	/**
	 * Gets or sets mesh visibility between 0 and 1 (defult is 1)
	 */        
	inline function set_visibility(value:Float):Float {
		if (this._visibility == value) {
			return value;
		}
		
		this._visibility = value;
		this._markSubMeshesAsMiscDirty();
		return value;
	}
	public var alphaIndex:Float = Math.POSITIVE_INFINITY;
	public var isVisible:Bool = true;
	public var isPickable:Bool = true;
	public var showBoundingBox:Bool = false;
	public var showSubMeshesBoundingBox:Bool = false;
	public var isBlocker:Bool = false;
	public var enablePointerMoveEvents:Bool = false;
	
	// BHX
	private var _renderingGroupId:Int = 0;
	public var renderingGroupId(get, set):Int;
	private function get_renderingGroupId():Int {
		return this._renderingGroupId;
	}
	private function set_renderingGroupId(value:Int):Int {
		return this._renderingGroupId = value;
	}
	
	private var _material:Material;
	public var material(get, set):Material;
	private function get_material():Material {
		return this._material;
	}
	private function set_material(value:Material):Material {
		if (this._material == value) {
			return value;
		}
		
		this._material = value;
		
		if (this.onMaterialChangedObservable.hasObservers()) {
            this.onMaterialChangedObservable.notifyObservers(this);
        }
		
		if (this.subMeshes == null) {
			return value;
		}
		
		for (subMesh in this.subMeshes) {
			subMesh.setEffect(null);
		}
		
		return value;
	}

	private var _receiveShadows:Bool = false;
	public var receiveShadows(get, set):Bool;
	private function get_receiveShadows():Bool {
		return this._receiveShadows;
	}
	private function set_receiveShadows(value:Bool):Bool {
		if (this._receiveShadows == value) {
			return value;
		}
		
		this._receiveShadows = value;
		this._markSubMeshesAsLightDirty();
		
		return value;
	}

	public var renderOutline:Bool = false;
	public var outlineColor:Color3 = Color3.Red();
	public var outlineWidth:Float = 0.02;
	public var renderOverlay:Bool = false;
	public var overlayColor:Color3 = Color3.Red();
	public var overlayAlpha:Float = 0.5;
	private var _hasVertexAlpha:Bool = false;
	public var hasVertexAlpha(get, set):Bool;
	private function get_hasVertexAlpha():Bool {
		return this._hasVertexAlpha;
	}
	private function set_hasVertexAlpha(value:Bool):Bool {
		if (this._hasVertexAlpha == value) {
			return value;
		}
		
		this._hasVertexAlpha = value;
		this._markSubMeshesAsAttributesDirty();
		this._markSubMeshesAsMiscDirty();
		
		return value;
	}        

	private var _useVertexColors:Bool = true;
	public var useVertexColors(get, set):Bool;
	private function get_useVertexColors():Bool {
		return this._useVertexColors;
	}
	private function set_useVertexColors(value:Bool):Bool {
		if (this._useVertexColors == value) {
			return value;
		}
		
		this._useVertexColors = value;
		this._markSubMeshesAsAttributesDirty();
		
		return value;
	}         

	private var _computeBonesUsingShaders:Bool = true;
	public var computeBonesUsingShaders(get, set):Bool;
	inline private function get_computeBonesUsingShaders():Bool {
		return this._computeBonesUsingShaders;
	}
	private function set_computeBonesUsingShaders(value:Bool):Bool {
		if (this._computeBonesUsingShaders == value) {
			return value;
		}
		
		this._computeBonesUsingShaders = value;
		this._markSubMeshesAsAttributesDirty();
		
		return value;
	}                

	private var _numBoneInfluencers:Int = 4;
	public var numBoneInfluencers(get, set):Int;
	private function get_numBoneInfluencers():Int {
		return this._numBoneInfluencers;
	}
	private function set_numBoneInfluencers(value:Int):Int {
		if (this._numBoneInfluencers == value) {
			return value;
		}
		
		this._numBoneInfluencers = value;
		this._markSubMeshesAsAttributesDirty();
		
		return value;
	}           

	private var _applyFog:Bool = true;
	public var applyFog(get, set):Bool;
	private function get_applyFog():Bool {
		return this._applyFog;
	}
	private function set_applyFog(value:Bool):Bool {
		if (this._applyFog == value) {
			return value;
		}
		
		this._applyFog = value;
		this._markSubMeshesAsMiscDirty();
		
		return value;
	}  

	public var useOctreeForRenderingSelection:Bool = true;
	public var useOctreeForPicking:Bool = true;
	public var useOctreeForCollisions:Bool = true;

	private var _layerMask:Int = 0x0FFFFFFF;
	public var layerMask(get, set):Int;
	inline private function get_layerMask():Int {
		return _layerMask;
	}
	private function set_layerMask(value:Int):Int {
		if (value == this._layerMask) {
			return value;
		}
		
		this._layerMask = value;
		this._resyncLightSources();
		return value;
	}
	
	/**
	 * True if the mesh must be rendered in any case.  
	 */
	public var alwaysSelectAsActiveMesh:Bool = false;

	/**
	 * This scene's action manager
	 * @type {BABYLON.ActionManager}
	*/
	public var actionManager:ActionManager = null;

	// Physics
	//public var physicsImpostor:PhysicsImpostor;

	// Collisions
	private var _checkCollisions:Bool = false;
	private var _collisionMask:Int = -1;
	private var _collisionGroup:Int = -1;
	public var ellipsoid:Vector3 = new Vector3(0.5, 1, 0.5);
	public var ellipsoidOffset:Vector3 = new Vector3(0, 0, 0);
	private var _collider:Collider;
	private var _oldPositionForCollisions:Vector3 = new Vector3(0, 0, 0);
	private var _diffPositionForCollisions:Vector3 = new Vector3(0, 0, 0);
	
	public var collisionMask(get, set):Int;
	inline private function get_collisionMask():Int {
		return this._collisionMask;
	}	
	inline private function set_collisionMask(mask:Int):Int {
		this._collisionMask = !Math.isNaN(mask) ? mask : -1;
		return mask;
	}
	
	public var collisionGroup(get, set):Int;
	inline private function get_collisionGroup():Int {
		return this._collisionGroup;
	}	
	inline private function set_collisionGroup(mask:Int):Int {
		this._collisionGroup = !Math.isNaN(mask) ? mask : -1;
		return mask;
	}
	
	// Attach to bone
	private var _meshToBoneReferal:AbstractMesh;

	// Edges
	public var edgesWidth:Float = 1;
	public var edgesColor:Color4 = new Color4(1, 0, 0, 1);
	public var _edgesRenderer:EdgesRenderer;

	// Cache
	private var _collisionsTransformMatrix:Matrix = Matrix.Zero();
	private var _collisionsScalingMatrix:Matrix = Matrix.Zero();
	public var _masterMesh:AbstractMesh;

	public var _boundingInfo:BoundingInfo;
	public var _isDisposed:Bool = false;
	public var _renderId:Int = 0;

	public var subMeshes:Array<SubMesh>;
	public var _submeshesOctree:Octree<SubMesh>;
	public var _intersectionsInProgress:Array<AbstractMesh> = [];

	public var _unIndexed:Bool = false;

	public var _lightSources:Array<Light> = [];

	public var _positions(get, never):Array<Vector3>;
	private function get__positions():Array<Vector3> {
		return null;
	}

	// Loading properties
	public var _waitingActions:Dynamic;
	public var _waitingFreezeWorldMatrix:Bool;

	// Skeleton
	private var _skeleton:Skeleton;
	public var _bonesTransformMatrices:Float32Array;

	public var skeleton(get, set):Skeleton;
	private function set_skeleton(value:Skeleton):Skeleton {
		if (this._skeleton != null && this._skeleton.needInitialSkinMatrix) {
			this._skeleton._unregisterMeshWithPoseMatrix(this);
		}
		
		if (value != null && value.needInitialSkinMatrix) {
			value._registerMeshWithPoseMatrix(this);
		}
		
		this._skeleton = value;
		
		if (this._skeleton == null) {
			this._bonesTransformMatrices = null;
		}
		
		this._markSubMeshesAsAttributesDirty();
		return value;
	}
	private function get_skeleton():Skeleton {	// VK: do not inline
		return this._skeleton;
	}
	
	// VK TEMP for memory game:
	public var extraData:Dynamic;
	

	// Constructor
	public function new(name:String, scene:Scene) {
		super(name, scene);
		
		this.getScene().addMesh(this);
		
		this._resyncLightSources();
	}
	
	/**
     * Boolean : true if the mesh has been disposed.  
     */
    public function isDisposed():Bool {
        return this._isDisposed;
    }

	/**
	 * Returns the string "AbstractMesh"
	 */
	override public function getClassName():String {
		return "AbstractMesh";
	}

	/**
	 * @param {boolean} fullDetails - support for multiple levels of logging within scene loading
	 */
	public function toString(fullDetails:Bool = false):String {
		var ret = "Name: " + this.name + ", isInstance: " + (Std.is(this, InstancedMesh) ? "YES" : "NO");
		ret += ", # of submeshes: " + (this.subMeshes != null ? this.subMeshes.length : 0);
		if (this._skeleton != null) {
			ret += ", skeleton: " + this._skeleton.name;
		}
		if (fullDetails) {
			//ret += ", billboard mode: " + (["NONE", "X", "Y", null, "Z", null, null, "ALL"])[this.billboardMode];
			ret += ", freeze wrld mat: " + (this._isWorldMatrixFrozen || this._waitingFreezeWorldMatrix ? "YES" : "NO");
		}
		return ret;
	}
	
	public function _rebuild() {
		if (this._occlusionQuery != null) {
            this._occlusionQuery = null;
        }
		
		if (this._edgesRenderer != null) {
            this._edgesRenderer._rebuild();
        }
		
		if (this.subMeshes == null) {
			return;
		}
		
		for (subMesh in this.subMeshes) {
			subMesh._rebuild();
		}
	}

	public function _resyncLightSources() {
		this._lightSources.splice(0, this._lightSources.length - 1);
		
		for (light in this.getScene().lights) {
			if (!light.isEnabled()) {
				continue;
			}
			
			if (light.canAffectMesh(this)) {
				this._lightSources.push(light);
			}
		}
		
		this._markSubMeshesAsLightDirty();
	}

	public function _resyncLighSource(light:Light) {
		var isIn = light.isEnabled() && light.canAffectMesh(this);
		
		var index = this._lightSources.indexOf(light);
		
		if (index == -1) {
			if (!isIn) {
				return;
			}
			this._lightSources.push(light);
		} 
		else {
			if (isIn) {
				return;
			}
			this._lightSources.splice(index, 1);            
		}
		
		this._markSubMeshesAsLightDirty();
	}

	public function _removeLightSource(light:Light) {
		var index = this._lightSources.indexOf(light);
		
		if (index == -1) {
			return;
		}
		this._lightSources.splice(index, 1);       
	}

	private function _markSubMeshesAsDirty(func:MaterialDefines->Void) {
		if (this.subMeshes == null) {
			return;
		}
		
		for (subMesh in this.subMeshes) {
			if (subMesh._materialDefines != null) {
				func(subMesh._materialDefines);
			}
		}
	}

	public function _markSubMeshesAsLightDirty() {
		this._markSubMeshesAsDirty(function(defines:MaterialDefines) { return defines.markAsLightDirty(); } );
	}

	public function _markSubMeshesAsAttributesDirty() {
		this._markSubMeshesAsDirty(function(defines:MaterialDefines) { return defines.markAsAttributesDirty(); } );
	}

	public function _markSubMeshesAsMiscDirty() {
		if (this.subMeshes == null) {
			return;
		}
		
		for (subMesh in this.subMeshes) {
			var material = subMesh.getMaterial();
			if (material != null) {
				material.markAsDirty(Material.MiscDirtyFlag);
			}
		}
	}
	
	// VK: this already exists in TransformNode !!!
	/**
	* Scaling property : a Vector3 depicting the mesh scaling along each local axis X, Y, Z.  
	* Default : (1.0, 1.0, 1.0)
	*/
	//public var scaling(get, set):Vector3;
	/*override function get_scaling():Vector3 {
		return this._scaling;
	}*/
	/**
	 * Scaling property : a Vector3 depicting the mesh scaling along each local axis X, Y, Z.  
	 * Default : (1.0, 1.0, 1.0)
	 */
	override function set_scaling(newScaling:Vector3):Vector3 {
		this._scaling = newScaling;
		/*if (this.physicsImpostor) {
			this.physicsImpostor.forceUpdate();
		}*/
		return newScaling;
	}

	// Methods
	/**
	 * Disables the mesh edger rendering mode.  
	 * Returns the AbstractMesh.  
	 */
	public function disableEdgesRendering():AbstractMesh {
		if (this._edgesRenderer != null) {
			this._edgesRenderer.dispose();
			this._edgesRenderer = null;
		}
		return this;
	}
	/**
	 * Enables the edge rendering mode on the mesh.  
	 * This mode makes the mesh edges visible.  
	 * Returns the AbstractMesh.  
	 */
	public function enableEdgesRendering(epsilon:Float = 0.95, checkVerticesInsteadOfIndices:Bool = false):AbstractMesh {
		this.disableEdgesRendering();
		this._edgesRenderer = new EdgesRenderer(this, Tools.Epsilon, checkVerticesInsteadOfIndices);
		return this;
	}

	/**
	 * Returns true if the mesh is blocked. Used by the class Mesh.
	 * Returns the boolean `false` by default.  
	 */
	public var isBlocked(get, never):Bool;
	private function get_isBlocked():Bool {
		return false;
	}

	/**
	 * Returns the mesh itself by default, used by the class Mesh.  
	 * Returned type : AbstractMesh
	 */
	public function getLOD(camera:Camera, ?boundingSphere:BoundingSphere):AbstractMesh {
		return this;
	}

	/**
	 * Returns 0 by default, used by the class Mesh.  
	 * Returns an integer.  
	 */
	public function getTotalVertices():Int {
		return 0;
	}

	/**
	 * Returns null by default, used by the class Mesh. 
	 * Returned type : integer array 
	 */
	public function getIndices(copyWhenShared:Bool = false):UInt32Array {
		return null;
	}

	/**
	 * Returns the array of the requested vertex data kind. Used by the class Mesh. Returns null here. 
	 * Returned type : float array or Float32Array 
	 */
	public function getVerticesData(kind:String, copyWhenShared:Bool = false, forceCopy:Bool = false):Float32Array {
		return null;
	}
	/**
	 * Sets the vertex data of the mesh geometry for the requested `kind`.
	 * If the mesh has no geometry, a new Geometry object is set to the mesh and then passed this vertex data.  
	 * The `data` are either a numeric array either a Float32Array. 
	 * The parameter `updatable` is passed as is to the underlying Geometry object constructor (if initianilly none) or updater. 
	 * The parameter `stride` is an optional positive integer, it is usually automatically deducted from the `kind` (3 for positions or normals, 2 for UV, etc).  
	 * Note that a new underlying VertexBuffer object is created each call. 
	 * If the `kind` is the `PositionKind`, the mesh BoundingInfo is renewed, so the bounding box and sphere, and the mesh World Matrix is recomputed. 
	 * Returns the Mesh.  
	 */
	public function setVerticesData(kind:String, data:Float32Array, updatable:Bool = false, ?stride:Int) { }

	/**
	 * Updates the existing vertex data of the mesh geometry for the requested `kind`.
	 * If the mesh has no geometry, it is simply returned as it is.  
	 * The `data` are either a numeric array either a Float32Array. 
	 * No new underlying VertexBuffer object is created. 
	 * If the `kind` is the `PositionKind` and if `updateExtends` is true, the mesh BoundingInfo is renewed, so the bounding box and sphere, and the mesh World Matrix is recomputed.  
	 * If the parameter `makeItUnique` is true, a new global geometry is created from this positions and is set to the mesh.
	 * Returns the Mesh.  
	 */
	public function updateVerticesData(kind:String, data:Float32Array, updateExtends:Bool = false, makeItUnique:Bool = false) { }

	/**
	 * Sets the mesh indices.  
	 * Expects an array populated with a typed array (Int32Array, Uint32Array, Uint16Array).
	 * If the mesh has no geometry, a new Geometry object is created and set to the mesh. 
	 * This method creates a new index buffer each call.  
	 * Returns the Mesh.  
	 */
	public function setIndices(indices:UInt32Array, totalVertices:Int = -1, updatable:Bool = false) { }

	/** Returns false by default, used by the class Mesh.  
	 *  Returns a boolean
	*/
	public function isVerticesDataPresent(kind:String):Bool {
		return false;
	}

	/**
	 * Returns the mesh BoundingInfo object or creates a new one and returns it if undefined.
	 * Returns a BoundingInfo
	 */
	public function getBoundingInfo():BoundingInfo {
		if (this._masterMesh != null) {
			return this._masterMesh.getBoundingInfo();
		}
		
		if (this._boundingInfo == null) {
			// this._boundingInfo is being created here
			this._updateBoundingInfo();
		}
		// cannot be null.
		return this._boundingInfo;
	}
	
	/**
	 * Uniformly scales the mesh to fit inside of a unit cube (1 X 1 X 1 units).
	 * @param includeDescendants Take the hierarchy's bounding box instead of the mesh's bounding box.
	 */
	public function normalizeToUnitCube(includeDescendants:Bool = true):AbstractMesh {
		var boundingVectors = this.getHierarchyBoundingVectors(includeDescendants);
		var sizeVec = boundingVectors.maximum.subtract(boundingVectors.minimum);
		var maxDimension = Math.max(sizeVec.x, Math.max(sizeVec.y, sizeVec.z));
		
		if (maxDimension == 0) {
			return this;
		}
		
		var scale = 1 / maxDimension;
		
		this.scaling.scaleInPlace(scale);
		
		return this;
	}

	/**
	 * Sets a mesh new object BoundingInfo.
	 * Returns the AbstractMesh.  
	 */
	public function setBoundingInfo(boundingInfo:BoundingInfo):AbstractMesh {
		this._boundingInfo = boundingInfo;
		return this;
	}

	public var useBones(get, never):Bool;
	private function get_useBones():Bool {
		return this.skeleton != null && this.getScene().skeletonsEnabled && this.isVerticesDataPresent(VertexBuffer.MatricesIndicesKind) && this.isVerticesDataPresent(VertexBuffer.MatricesWeightsKind);
	}

	public function _preActivate() { }

	public function _preActivateForIntermediateRendering(renderId:Int) { }

	public function _activate(renderId:Int) {
		this._renderId = renderId;
	}

	/**
	 * Returns the last update of the World matrix
	 * Returns a Matrix.  
	 */
	override public function getWorldMatrix():Matrix {
		if (this._masterMesh != null) {
			return this._masterMesh.getWorldMatrix();
		}
		
		return super.getWorldMatrix();
	}
	
	/**
     * Returns the latest update of the World matrix determinant.
     */
    override public function _getWorldMatrixDeterminant():Float {
        if (this._masterMesh != null) {
            return this._masterMesh._getWorldMatrixDeterminant();
        }
		
        return super._getWorldMatrixDeterminant();
    }
	
	// ================================== Point of View Movement =================================
	/**
	 * Perform relative position change from the point of view of behind the front of the mesh.
	 * This is performed taking into account the meshes current rotation, so you do not have to care.
	 * Supports definition of mesh facing forward or backward.
	 * @param {number} amountRight
	 * @param {number} amountUp
	 * @param {number} amountForward
	 * 
	 * Returns the AbstractMesh.
	 */
	inline public function movePOV(amountRight:Float, amountUp:Float, amountForward:Float):AbstractMesh {
		this.position.addInPlace(this.calcMovePOV(amountRight, amountUp, amountForward));
		return this;
	}

	/**
	 * Calculate relative position change from the point of view of behind the front of the mesh.
	 * This is performed taking into account the meshes current rotation, so you do not have to care.
	 * Supports definition of mesh facing forward or backward.
	 * @param {number} amountRight
	 * @param {number} amountUp
	 * @param {number} amountForward  
	 * 
	 * Returns a new Vector3.  
	 */
	public function calcMovePOV(amountRight:Float, amountUp:Float, amountForward:Float):Vector3 {
		var rotMatrix:Matrix = new Matrix();
		var rotQuaternion:Quaternion = (this.rotationQuaternion != null) ? this.rotationQuaternion : Quaternion.RotationYawPitchRoll(this.rotation.y, this.rotation.x, this.rotation.z);
		rotQuaternion.toRotationMatrix(rotMatrix);
		
		var translationDelta = Vector3.Zero();
		var defForwardMult = this.definedFacingForward ? -1 : 1;
		Vector3.TransformCoordinatesFromFloatsToRef(amountRight * defForwardMult, amountUp, amountForward * defForwardMult, rotMatrix, translationDelta);
		return translationDelta;
	}
	// ================================== Point of View Rotation =================================
	/**
	 * Perform relative rotation change from the point of view of behind the front of the mesh.
	 * Supports definition of mesh facing forward or backward.
	 * @param {number} flipBack
	 * @param {number} twirlClockwise
	 * @param {number} tiltRight
	 * 
	 * Returns the AbstractMesh.  
	 */
	inline public function rotatePOV(flipBack:Float, twirlClockwise:Float, tiltRight:Float):AbstractMesh {
		this.rotation.addInPlace(this.calcRotatePOV(flipBack, twirlClockwise, tiltRight));
		return this;
	}

	/**
	 * Calculate relative rotation change from the point of view of behind the front of the mesh.
	 * Supports definition of mesh facing forward or backward.
	 * @param {number} flipBack
	 * @param {number} twirlClockwise
	 * @param {number} tiltRight
	 * 
	 * Returns a new Vector3.
	 */
	inline public function calcRotatePOV(flipBack:Float, twirlClockwise:Float, tiltRight:Float):Vector3 {
		var defForwardMult = this.definedFacingForward ? 1 : -1;
		return new Vector3(flipBack * defForwardMult, twirlClockwise, tiltRight * defForwardMult);
	}
	
	/**
	 * Return the minimum and maximum world vectors of the entire hierarchy under current mesh
	 * @param includeDescendants Include bounding info from descendants as well (true by default).
	 */
	public function getHierarchyBoundingVectors(includeDescendants:Bool = true):BabylonMinMax {
		this.computeWorldMatrix(true);
		
		var min:Vector3 = null;
		var max:Vector3 = null;
		var boundingInfo = this.getBoundingInfo();
		
		if (this.subMeshes == null) {
			min = new Vector3(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
			max = new Vector3(Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY);
		} 
		else {
			min = boundingInfo.boundingBox.minimumWorld;
			max = boundingInfo.boundingBox.maximumWorld;
		}
		
		if (includeDescendants) {
			var descendants = this.getDescendants(false);
			
			for (descendant in descendants) {
				var childMesh:AbstractMesh = cast descendant;
				
				childMesh.computeWorldMatrix(true);
				
				//make sure we have the needed params to get mix and max
                if (childMesh.getBoundingInfo == null || childMesh.getTotalVertices() == 0) {
                    continue;
                }
				
				var childBoundingInfo = childMesh.getBoundingInfo();
				
				var boundingBox = childBoundingInfo.boundingBox;
				
				var minBox = boundingBox.minimumWorld;
				var maxBox = boundingBox.maximumWorld;
				
				MathTools.CheckExtends(minBox, min, max);
				MathTools.CheckExtends(maxBox, min, max);
			}
		}
		
		return {
			minimum: min,
			maximum: max
		}
	}

	/**
	 * Updates the mesh BoundingInfo object and all its children BoundingInfo objects also.  
	 * Returns the AbstractMesh.  
	 */
	public function _updateBoundingInfo():AbstractMesh {
		if (this._boundingInfo == null) {
			this._boundingInfo = new BoundingInfo(this.absolutePosition, this.absolutePosition);
		}
		this._boundingInfo.update(this.worldMatrixFromCache);
		this._updateSubMeshesBoundingInfo(this.worldMatrixFromCache);
		return this;
	}

	/**
	 * Update a mesh's children BoundingInfo objects only.  
	 * Returns the AbstractMesh.  
	 */
	public function _updateSubMeshesBoundingInfo(matrix:Matrix):AbstractMesh {
		if (this.subMeshes == null) {
			return this;
		}
		for (subIndex in 0...this.subMeshes.length) {
			var subMesh = this.subMeshes[subIndex];
			if (!subMesh.IsGlobal) {
				subMesh.updateBoundingInfo(matrix);
			}
		}
		return this;
	}
	
	override private function _afterComputeWorldMatrix() {
		// Bounding info
		this._updateBoundingInfo();
	}

	/**
	 * Returns `true` if the mesh is within the frustum defined by the passed array of planes.  
	 * A mesh is in the frustum if its bounding box intersects the frustum.  
	 * Boolean returned.  
	 */
	public function isInFrustum(frustumPlanes:Array<Plane>):Bool {
		return this._boundingInfo != null && this._boundingInfo.isInFrustum(frustumPlanes);
	}

	/**
	 * Returns `true` if the mesh is completely in the frustum defined be the passed array of planes.  
	 * A mesh is completely in the frustum if its bounding box it completely inside the frustum.  
	 * Boolean returned.  
	 */
	public function isCompletelyInFrustum(frustumPlanes:Array<Plane>):Bool {
		return this._boundingInfo != null && this._boundingInfo.isCompletelyInFrustum(frustumPlanes);
	}

	/** 
	 * True if the mesh intersects another mesh or a SolidParticle object.  
	 * Unless the parameter `precise` is set to `true` the intersection is computed according to Axis Aligned Bounding Boxes (AABB), else according to OBB (Oriented BBoxes)
	 * includeDescendants can be set to true to test if the mesh defined in parameters intersects with the current mesh or any child meshes
	 * Returns a boolean.  
	 */
	public function intersectsMesh(mesh:IHasBoundingInfo, precise:Bool = false, includeDescendants:Bool = false):Bool {
		if (this._boundingInfo != null || mesh._boundingInfo == null) {
			return false;
		}
		
		if (this._boundingInfo.intersects(mesh._boundingInfo, precise)) {
            return true;
        }
		
        if (includeDescendants) {
            for (child in this.getChildMeshes()) {
                if (child.intersectsMesh(mesh, precise, true)) {
                    return true;
                }
            }
        }
		
        return false;
	}

	/**
	 * Returns true if the passed point (Vector3) is inside the mesh bounding box.  
	 * Returns a boolean.  
	 */
	public function intersectsPoint(point:Vector3):Bool {
		if (this._boundingInfo == null) {
			return false;
		}
		
		return this._boundingInfo.intersectsPoint(point);
	}

	/*public function getPhysicsImpostor():PhysicsImpostor {
		return this.physicsImpostor;
	}*/

	public function getPositionInCameraSpace(?camera:Camera):Vector3 {
		if (camera == null) {
			camera = this.getScene().activeCamera;
		}
		
		return Vector3.TransformCoordinates(this.absolutePosition, camera.getViewMatrix());
	}

	/**
	 * Returns the distance from the mesh to the active camera.  
	 * Returns a float.  
	 */
	public function getDistanceToCamera(?camera:Camera):Float {
		if (camera == null) {
			camera = this.getScene().activeCamera;
		}
		return this.absolutePosition.subtract(camera.position).length();
	}

	/*public function applyImpulse(force:Vector3, contactPoint:Vector3):AbstractMesh {
		if (this.physicsImpostor == null) {
			return;
		}
		this.physicsImpostor.applyImpulse(force, contactPoint);
		return this;
	}

	public setPhysicsLinkWith(otherMesh:Mesh, pivot1:Vector3, pivot2:Vector3, ?options:Dynamic):AbstractMesh {
		if (this.physicsImpostor == null || otherMesh.physicsImpostor == null) {
			return;
		}
		this.physicsImpostor.createJoint(otherMesh.physicsImpostor, PhysicsJoint.HingeJoint, {
			mainPivot: pivot1,
			connectedPivot: pivot2,
			nativeParams: options
		});
		return this;
	}*/

	// Collisions

	/**
	 * Property checkCollisions : Boolean, whether the camera should check the collisions against the mesh.  
	 * Default `false`.
	 */
	public var checkCollisions(get, set):Bool;
	private function get_checkCollisions():Bool {
		return this._checkCollisions;
	}
	inline private function set_checkCollisions(collisionEnabled:Bool):Bool {
		this._checkCollisions = collisionEnabled;
		if (this.getScene().workerCollisions) {
			this.getScene().collisionCoordinator.onMeshUpdated(this);
		}
		return collisionEnabled;
	}
	
	/**
	 * Gets Collider object used to compute collisions (not physics)
	 */
	public var collider(get, never):Collider;
	inline function get_collider():Collider {
		return this._collider;
	}

	public function moveWithCollisions(direction:Vector3):AbstractMesh {
		var globalPosition = this.getAbsolutePosition();
		
		globalPosition.subtractFromFloatsToRef(0, this.ellipsoid.y, 0, this._oldPositionForCollisions);
		this._oldPositionForCollisions.addInPlace(this.ellipsoidOffset);
		
		if (this._collider == null) {
			this._collider = new Collider();
		}
		
		this._collider.radius = this.ellipsoid;
		
		this.getScene().collisionCoordinator.getNewPosition(this._oldPositionForCollisions, direction, this._collider, 3, this, this._onCollisionPositionChange, this.uniqueId);
		return this;
	}

	private function _onCollisionPositionChange(collisionId:Int, newPosition:Vector3, collidedMesh:AbstractMesh = null) {
		//TODO move this to the collision coordinator!
		if (this.getScene().workerCollisions) {
			newPosition.multiplyInPlace(this._collider.radius);
		}
		
		newPosition.subtractToRef(this._oldPositionForCollisions, this._diffPositionForCollisions);
		
		if (this._diffPositionForCollisions.length() > Engine.CollisionsEpsilon) {
			this.position.addInPlace(this._diffPositionForCollisions);
		}
		
		if (collidedMesh != null) {
			this.onCollideObservable.notifyObservers(collidedMesh);
		}
		
		this.onCollisionPositionChangeObservable.notifyObservers(this.position);
	}

	// Submeshes octree

	/**
	* This function will create an octree to help to select the right submeshes for rendering, picking and collision computations.  
	* Please note that you must have a decent number of submeshes to get performance improvements when using an octree.  
	* Returns an Octree of submeshes.  
	*/
	public function createOrUpdateSubmeshesOctree(maxCapacity:Int = 64, maxDepth:Int = 2):Octree<SubMesh> {
		if (this._submeshesOctree == null) {
			this._submeshesOctree = new Octree<SubMesh>(Octree.CreationFuncForSubMeshes, maxCapacity, maxDepth);
		}
		
		this.computeWorldMatrix(true);
		
		// Update octree
		var bbox = this.getBoundingInfo().boundingBox;
		this._submeshesOctree.update(bbox.minimumWorld, bbox.maximumWorld, this.subMeshes);
		
		return this._submeshesOctree;
	}

	// Collisions
	public function _collideForSubMesh(subMesh:SubMesh, transformMatrix:Matrix, collider:Collider):AbstractMesh {
		this._generatePointsArray();
		
		if (this._positions == null) {
			return this;
		}
		
		// Transformation
		if (subMesh._lastColliderWorldVertices == null || !subMesh._lastColliderTransformMatrix.equals(transformMatrix)) {
			subMesh._lastColliderTransformMatrix = transformMatrix.clone();
			subMesh._lastColliderWorldVertices = [];
			subMesh._trianglePlanes = [];
			var start = subMesh.verticesStart;
			var end = (subMesh.verticesStart + subMesh.verticesCount);
			for (i in start...end) {
				subMesh._lastColliderWorldVertices.push(Vector3.TransformCoordinates(this._positions[i], transformMatrix));
			}
		}
		// Collide
		collider._collide(subMesh._trianglePlanes, subMesh._lastColliderWorldVertices, this.getIndices(), subMesh.indexStart, subMesh.indexStart + subMesh.indexCount, subMesh.verticesStart, subMesh.getMaterial() != null);
		if (collider.collisionFound) {
			collider.collidedMesh = this;
		}
		return this;
	}

	public function _processCollisionsForSubMeshes(collider:Collider, transformMatrix:Matrix):AbstractMesh {
		var subMeshes:Array<SubMesh>;
		var len:Int;

		// Octrees
		if (this._submeshesOctree != null && this.useOctreeForCollisions) {
			var radius = collider.velocityWorldLength + Math.max(Math.max(collider.radius.x, collider.radius.y), collider.radius.z);
			var intersections = this._submeshesOctree.intersects(collider.basePointWorld, radius);
			
			len = intersections.length;
			subMeshes = intersections.data;
		} 
		else {
			subMeshes = this.subMeshes;
			len = subMeshes.length;
		}
		
		for (index in 0...len) {
			var subMesh = subMeshes[index];
			
			// Bounding test
			if (len > 1 && !subMesh._checkCollision(collider)) {
				continue;
			}
			
			this._collideForSubMesh(subMesh, transformMatrix, collider);
		}
		return this;
	}

	public function _checkCollision(collider:Collider):AbstractMesh {
		// Bounding box test
		if (this._boundingInfo == null || !this._boundingInfo._checkCollision(collider)) {
			return this;
		}
		
		// Transformation matrix
		Matrix.ScalingToRef(1.0 / collider.radius.x, 1.0 / collider.radius.y, 1.0 / collider.radius.z, this._collisionsScalingMatrix);
		this.worldMatrixFromCache.multiplyToRef(this._collisionsScalingMatrix, this._collisionsTransformMatrix);
		this._processCollisionsForSubMeshes(collider, this._collisionsTransformMatrix);
		return this;
	}

	// Picking
	public function _generatePointsArray():Bool {
		return false;
	}

	/**
	 * Checks if the passed Ray intersects with the mesh.  
	 * Returns an object PickingInfo.
	 */
	public function intersects(ray:Ray, fastCheck:Bool = false):PickingInfo {
		var pickingInfo = new PickingInfo();
		
		if (this.subMeshes == null || this._boundingInfo == null || !ray.intersectsSphere(this._boundingInfo.boundingSphere) || !ray.intersectsBox(this._boundingInfo.boundingBox)) {
			return pickingInfo;
		}
		
		if (!this._generatePointsArray()) {
			return pickingInfo;
		}
		
		var intersectInfo:IntersectionInfo = null;
		
		// Octrees
		var subMeshes:Array<SubMesh>;
		var len:Int;
		
		if (this._submeshesOctree != null && this.useOctreeForPicking) {
			var worldRay = Ray.Transform(ray, this.getWorldMatrix());
			var intersections = this._submeshesOctree.intersectsRay(worldRay);
			
			len = intersections.length;
			subMeshes = intersections.data;
		} 
		else {
			subMeshes = this.subMeshes;
			len = subMeshes.length;
		}
		
		for (index in 0...len) {
			var subMesh = subMeshes[index];
			
			// Bounding test
			if (len > 1 && !subMesh.canIntersects(ray)) {
				continue;
			}
			
			var currentIntersectInfo = subMesh.intersects(ray, this._positions, this.getIndices(), fastCheck);
			
			if (currentIntersectInfo != null) {
				if (fastCheck || intersectInfo == null || currentIntersectInfo.distance < intersectInfo.distance) {
					intersectInfo = currentIntersectInfo;
					intersectInfo.subMeshId = index;
					
					if (fastCheck) {
						break;
					}
				}
			}
		}
		
		if (intersectInfo != null) {
			// Get picked point
			var world = this.getWorldMatrix();
			var worldOrigin = Vector3.TransformCoordinates(ray.origin, world);
			var direction = ray.direction.clone();
			direction = direction.scale(intersectInfo.distance);
			var worldDirection = Vector3.TransformNormal(direction, world);
			
			var pickedPoint = worldOrigin.add(worldDirection);
			
			// Return result
			pickingInfo.hit = true;
			pickingInfo.distance = Vector3.Distance(worldOrigin, pickedPoint);
			pickingInfo.pickedPoint = pickedPoint;
			pickingInfo.pickedMesh = this;
			pickingInfo.bu = intersectInfo.bu;
			pickingInfo.bv = intersectInfo.bv;
			pickingInfo.faceId = intersectInfo.faceId;
			pickingInfo.subMeshId = intersectInfo.subMeshId;
			return pickingInfo;
		}
		
		return pickingInfo;
	}

	/**
	 * Clones the mesh, used by the class Mesh.  
	 * Just returns `null` for an AbstractMesh.  
	 */
	override public function clone(name:String, newParent:Node = null, doNotCloneChildren:Bool = false):AbstractMesh {
		return null;
	}

	/**
	 * Disposes all the mesh submeshes.  
	 * Returns the AbstractMesh.  
	 */
	public function releaseSubMeshes():AbstractMesh {
		if (this.subMeshes != null) {
			while (this.subMeshes.length > 0) {
				this.subMeshes[0].dispose();
				this.subMeshes.shift();
			}
		} 
		else {
			this.subMeshes = new Array<SubMesh>();
		}
		return this;
	}

	/**
	 * Disposes the AbstractMesh.  
	 * Some internal references are kept for further use.  
	 * By default, all the mesh children are also disposed unless the parameter `doNotRecurse` is set to `true`.  
	 * Returns nothing.  
	 */
	override public function dispose(doNotRecurse:Bool = false) {
		// Action manager
		if (this.actionManager != null) {
			this.actionManager.dispose();
			this.actionManager = null;
		}
		
		// Skeleton
		this.skeleton = null;
		
		// Animations
		this.getScene().stopAnimation(this);
		
		// Physics
		//if (this.physicsImpostor != null) {
			//this.physicsImpostor.dispose(/*!doNotRecurse*/);
		//}

		// Intersections in progress
		for (index in 0...this._intersectionsInProgress.length) {
			var other = this._intersectionsInProgress[index];
			
			var pos = other._intersectionsInProgress.indexOf(this);
			other._intersectionsInProgress.splice(pos, 1);
		}
		
		this._intersectionsInProgress = [];
		
		// Lights
		var lights = this.getScene().lights;
		
		for (light in lights) {
			var meshIndex = light.includedOnlyMeshes.indexOf(this);
			
			if (meshIndex != -1) {
				light.includedOnlyMeshes.splice(meshIndex, 1);
			}
			
			meshIndex = light.excludedMeshes.indexOf(this);
			
			if (meshIndex != -1) {
				light.excludedMeshes.splice(meshIndex, 1);
			}
			
			// Shadow generators
			var generator = light.getShadowGenerator();
			if (generator != null) {
				meshIndex = generator.getShadowMap().renderList.indexOf(this);
				
				if (meshIndex != -1) {
					generator.getShadowMap().renderList.splice(meshIndex, 1);
				}
			}
		}
		
		// Edges
		if (this._edgesRenderer != null) {
			this._edgesRenderer.dispose();
			this._edgesRenderer = null;
		}
		
		// SubMeshes
		if (this.getClassName() != "InstancedMesh"){
			this.releaseSubMeshes();
		}
		
		// Octree
		var sceneOctree = this.getScene().selectionOctree;
		if (sceneOctree != null) {
			var index = sceneOctree.dynamicContent.indexOf(this);
			
			if (index != -1) {
				sceneOctree.dynamicContent.splice(index, 1);
			}
		}
		
		// Query
        var engine = this.getScene().getEngine();
        if (this._occlusionQuery != null) {
			this._isOcclusionQueryInProgress = false;
            engine.deleteQuery(this._occlusionQuery);
            this._occlusionQuery = null;
        }
		
		// Engine
		engine.wipeCaches();
		
		// Remove from scene
		this.getScene().removeMesh(this);
		
		if (!doNotRecurse) {
			// Particles
			var index:Int = 0;
			while (index < this.getScene().particleSystems.length) {
				if (this.getScene().particleSystems[index].emitter == this) {
					this.getScene().particleSystems[index].dispose();
					index--;
				}
				index++;
			}
			
			// Children
			var objects = this.getDescendants(true);
			for (index in 0...objects.length) {
				objects[index].dispose();
			}
		} 
		else {
			var childMeshes = this.getChildMeshes(true);
			for (index in 0...childMeshes.length) {
				var child = childMeshes[index];
				child.parent = null;
				child.computeWorldMatrix(true);
			}
		}
		
		// facet data
		if (this._facetDataEnabled) {
			this.disableFacetData();
		}
		
		this.onAfterWorldMatrixUpdateObservable.clear();
		this.onCollideObservable.clear();
		this.onCollisionPositionChangeObservable.clear();
		
		this._isDisposed = true;
		
		super.dispose();
	}

	/**
	 * Adds the passed mesh as a child to the current mesh.  
	 * Returns the AbstractMesh.  
	 */
	public function addChild(mesh:AbstractMesh):AbstractMesh {
		mesh.setParent(this);
		return this;
	}

	/**
	 * Removes the passed mesh from the current mesh children list.  
	 * Returns the AbstractMesh.  
	 */
	public function removeChild(mesh:AbstractMesh):AbstractMesh {
		mesh.setParent(null);
		return this;
	}

    // Facet data
	/** 
	 *  Initialize the facet data arrays : facetNormals, facetPositions and facetPartitioning.   
	 * Returns the AbstractMesh.  
	 */
	private function _initFacetData():AbstractMesh {
		if (this._facetNormals == null) {
			this._facetNormals = new Array<Vector3>();
		}
		if (this._facetPositions == null) {
			this._facetPositions = new Array<Vector3>();
		}
		if (this._facetPartitioning == null) {
			this._facetPartitioning = new Array<Array<Int>>();
		}
		this._facetNb = Std.int(this.getIndices().length / 3);
		// VK: default values already set !!!
		//this._partitioningSubdivisions = (this._partitioningSubdivisions != null) ? this._partitioningSubdivisions : 10;   // default nb of partitioning subdivisions = 10
		//this._partitioningBBoxRatio = (this._partitioningBBoxRatio) ? this._partitioningBBoxRatio : 1.01;          // default ratio 1.01 = the partitioning is 1% bigger than the bounding box
		for (f in 0...this._facetNb) {
			this._facetNormals[f] = Vector3.Zero();
			this._facetPositions[f] = Vector3.Zero();
		}
		this._facetDataEnabled = true;           
		return this;
	}

	/**
	 * Updates the mesh facetData arrays and the internal partitioning when the mesh is morphed or updated.  
	 * This method can be called within the render loop.  
	 * You don't need to call this method by yourself in the render loop when you update/morph a mesh with the methods CreateXXX() as they automatically manage this computation.   
	 * Returns the AbstractMesh.  
	 */
	public function updateFacetData():AbstractMesh {
		if (!this._facetDataEnabled) {
			this._initFacetData();
		}
		var positions = this.getVerticesData(VertexBuffer.PositionKind);
		var indices = this.getIndices();
		var normals = this.getVerticesData(VertexBuffer.NormalKind);
		var bInfo = this.getBoundingInfo();
		
		if (bInfo == null) {
			return this;
		}
		
		if (this._facetDepthSort && !this._facetDepthSortEnabled) {
			// init arrays, matrix and sort function on first call
			this._facetDepthSortEnabled = true;
			this._depthSortedIndices = new UInt32Array(indices);               
			this._facetDepthSortFunction = function(f1:DepthSortedFacet, f2:DepthSortedFacet):Int {
				return Std.int(f2.sqDistance - f1.sqDistance);
			};
			if (this._facetDepthSortFrom == null) {
				var camera = this.getScene().activeCamera;
				this._facetDepthSortFrom = camera != null ? camera.position : Vector3.Zero();
			}
			this._depthSortedFacets = [];
			for (f in 0...this._facetNb) {
				var depthSortedFacet = { ind: Std.int(f * 3), sqDistance: 0.0 };
				this._depthSortedFacets.push(depthSortedFacet);
			}
			this._invertedMatrix = Matrix.Identity();
			this._facetDepthSortOrigin = Vector3.Zero();
		}
		
		this._bbSize.x = (bInfo.maximum.x - bInfo.minimum.x > MathTools.Epsilon) ? bInfo.maximum.x - bInfo.minimum.x : MathTools.Epsilon;
		this._bbSize.y = (bInfo.maximum.y - bInfo.minimum.y > MathTools.Epsilon) ? bInfo.maximum.y - bInfo.minimum.y : MathTools.Epsilon;
		this._bbSize.z = (bInfo.maximum.z - bInfo.minimum.z > MathTools.Epsilon) ? bInfo.maximum.z - bInfo.minimum.z : MathTools.Epsilon;
		var bbSizeMax = (this._bbSize.x > this._bbSize.y) ? this._bbSize.x : this._bbSize.y;
		bbSizeMax = (bbSizeMax > this._bbSize.z) ? bbSizeMax : this._bbSize.z;
		this._subDiv.max = this._partitioningSubdivisions;
		this._subDiv.X = Math.floor(this._subDiv.max * this._bbSize.x / bbSizeMax);   // adjust the number of subdivisions per axis
		this._subDiv.Y = Math.floor(this._subDiv.max * this._bbSize.y / bbSizeMax);   // according to each bbox size per axis
		this._subDiv.Z = Math.floor(this._subDiv.max * this._bbSize.z / bbSizeMax);
		this._subDiv.X = this._subDiv.X < 1 ? 1 : this._subDiv.X;                     // at least one subdivision
		this._subDiv.Y = this._subDiv.Y < 1 ? 1 : this._subDiv.Y;
		this._subDiv.Z = this._subDiv.Z < 1 ? 1 : this._subDiv.Z;
		// set the parameters for ComputeNormals()
		this._facetParameters.facetNormals = this.getFacetLocalNormals();
		this._facetParameters.facetPositions = this.getFacetLocalPositions();
		this._facetParameters.facetPartitioning = this.getFacetLocalPartitioning();
		this._facetParameters.bInfo = bInfo;
		this._facetParameters.bbSize = this._bbSize;
		this._facetParameters.subDiv = this._subDiv;
		this._facetParameters.ratio = this.partitioningBBoxRatio;
		this._facetParameters.depthSort = this._facetDepthSort;
		if (this._facetDepthSort && this._facetDepthSortEnabled) {
			this.computeWorldMatrix(true);
			this._worldMatrix.invertToRef(this._invertedMatrix);
			Vector3.TransformCoordinatesToRef(this._facetDepthSortFrom, this._invertedMatrix, this._facetDepthSortOrigin);   
			this._facetParameters.distanceTo = this._facetDepthSortOrigin;
		}
		this._facetParameters.depthSortedFacets = this._depthSortedFacets;
		VertexData.ComputeNormals(positions, indices, normals, this._facetParameters);
		
		if (this._facetDepthSort && this._facetDepthSortEnabled) {
			this._depthSortedFacets.sort(this._facetDepthSortFunction);
			var l = Std.int(this._depthSortedIndices.length / 3);
			for (f in 0...l) {
				var sind = this._depthSortedFacets[f].ind;
				this._depthSortedIndices[f * 3] = indices[sind];
				this._depthSortedIndices[f * 3 + 1] = indices[sind + 1];
				this._depthSortedIndices[f * 3 + 2] = indices[sind + 2];
			}
			this.updateIndices(this._depthSortedIndices);
		}
		
		return this;
	}
	/**
	 * Returns the facetLocalNormals array.  
	 * The normals are expressed in the mesh local space.  
	 */
	public function getFacetLocalNormals():Array<Vector3> {
		if (this._facetNormals == null) {
			this.updateFacetData();
		}
		return this._facetNormals;
	}
	/**
	 * Returns the facetLocalPositions array.  
	 * The facet positions are expressed in the mesh local space.  
	 */
	public function getFacetLocalPositions():Array<Vector3> {
		if (this._facetPositions == null) {
			this.updateFacetData();
		}
		return this._facetPositions;           
	}
	/**
	 * Returns the facetLocalPartioning array.
	 */
	public function getFacetLocalPartitioning():Array<Array<Int>> {
		if (this._facetPartitioning == null) {
			this.updateFacetData();
		}
		return this._facetPartitioning;
	}
	/**
	 * Returns the i-th facet position in the world system.  
	 * This method allocates a new Vector3 per call.  
	 */
	public function getFacetPosition(i:Int):Vector3 {
		var pos = Vector3.Zero();
		this.getFacetPositionToRef(i, pos);
		return pos;
	}
	/**
	 * Sets the reference Vector3 with the i-th facet position in the world system.  
	 * Returns the AbstractMesh.  
	 */
	public function getFacetPositionToRef(i:Int, ref:Vector3):AbstractMesh {
		var localPos = (this.getFacetLocalPositions())[i];
		var world = this.getWorldMatrix();
		Vector3.TransformCoordinatesToRef(localPos, world, ref);
		return this;
	}
	/**
	 * Returns the i-th facet normal in the world system.  
	 * This method allocates a new Vector3 per call.  
	 */
	public function getFacetNormal(i:Int):Vector3 {
		var norm = Vector3.Zero();
		this.getFacetNormalToRef(i, norm);
		return norm;
	}
	/**
	 * Sets the reference Vector3 with the i-th facet normal in the world system.  
	 * Returns the AbstractMesh.  
	 */
	public function getFacetNormalToRef(i:Int, ref:Vector3) {
		var localNorm = (this.getFacetLocalNormals())[i];
		Vector3.TransformNormalToRef(localNorm, this.getWorldMatrix(), ref);
		return this;
	}
	/** 
	 * Returns the facets (in an array) in the same partitioning block than the one the passed coordinates are located (expressed in the mesh local system).
	 */
	public function getFacetsAtLocalCoordinates(x:Float, y:Float, z:Float):Array<Int> {
		var bInfo = this.getBoundingInfo();
		
		if (bInfo == null) {
			return null;
		}
		
		var ox = Math.floor((x - bInfo.minimum.x * this._partitioningBBoxRatio) * this._subDiv.X * this._partitioningBBoxRatio / this._bbSize.x);
		var oy = Math.floor((y - bInfo.minimum.y * this._partitioningBBoxRatio) * this._subDiv.Y * this._partitioningBBoxRatio / this._bbSize.y);
		var oz = Math.floor((z - bInfo.minimum.z * this._partitioningBBoxRatio) * this._subDiv.Z * this._partitioningBBoxRatio / this._bbSize.z);
		if (ox < 0 || ox > this._subDiv.max || oy < 0 || oy > this._subDiv.max || oz < 0 || oz > this._subDiv.max) {
			return null;
		}
		return this._facetPartitioning[Std.int(ox + this._subDiv.max * oy + this._subDiv.max * this._subDiv.max * oz)];
	}
	/** 
	 * Returns the closest mesh facet index at (x,y,z) World coordinates, null if not found.  
	 * If the parameter projected (vector3) is passed, it is set as the (x,y,z) World projection on the facet.  
	 * If checkFace is true (default false), only the facet "facing" to (x,y,z) or only the ones "turning their backs", according to the parameter "facing" are returned.
	 * If facing and checkFace are true, only the facet "facing" to (x, y, z) are returned : positive dot (x, y, z) * facet position.
	 * If facing si false and checkFace is true, only the facet "turning their backs" to (x, y, z) are returned : negative dot (x, y, z) * facet position. 
	 */
	public function getClosestFacetAtCoordinates(x:Float, y:Float, z:Float, ?projected:Vector3, checkFace:Bool = false, facing:Bool = true):Float {
		var world = this.getWorldMatrix();
		var invMat = Tmp.matrix[5];
		world.invertToRef(invMat);
		var invVect = Tmp.vector3[8];
		Vector3.TransformCoordinatesFromFloatsToRef(x, y, z, invMat, invVect);  // transform (x,y,z) to coordinates in the mesh local space
		var closest = this.getClosestFacetAtLocalCoordinates(invVect.x, invVect.y, invVect.z, projected, checkFace, facing);
		if (projected != null) {
			// tranform the local computed projected vector to world coordinates
			Vector3.TransformCoordinatesFromFloatsToRef(projected.x, projected.y, projected.z, world, projected);
		}
		return closest;
	}
	/** 
	 * Returns the closest mesh facet index at (x,y,z) local coordinates, null if not found.   
	 * If the parameter projected (vector3) is passed, it is set as the (x,y,z) local projection on the facet.  
	 * If checkFace is true (default false), only the facet "facing" to (x,y,z) or only the ones "turning their backs", according to the parameter "facing" are returned.
	 * If facing and checkFace are true, only the facet "facing" to (x, y, z) are returned : positive dot (x, y, z) * facet position.
	 * If facing si false and checkFace is true, only the facet "turning their backs"  to (x, y, z) are returned : negative dot (x, y, z) * facet position.
	 */
	public function getClosestFacetAtLocalCoordinates(x:Float, y:Float, z:Float, ?projected:Vector3, checkFace:Bool = false, facing:Bool = true):Null<Float> {
		var closest:Null<Float> = null;
		var tmpx:Float = 0.0;         
		var tmpy:Float = 0.0;
		var tmpz:Float = 0.0;
		var d:Float = 0.0;            // tmp dot facet normal * facet position
		var t0:Float = 0.0;
		var projx:Float = 0.0;
		var projy:Float = 0.0;
		var projz:Float = 0.0;
		// Get all the facets in the same partitioning block than (x, y, z)
		var facetPositions = this.getFacetLocalPositions();
		var facetNormals = this.getFacetLocalNormals();
		var facetsInBlock = this.getFacetsAtLocalCoordinates(x, y, z);
		if (facetsInBlock == null) {
			return null;
		}
		// Get the closest facet to (x, y, z)
		var shortest = Math.POSITIVE_INFINITY;      // init distance vars
		var tmpDistance = shortest;
		var fib:Int;                                // current facet in the block
		var norm:Vector3;                           // current facet normal
		var p0:Vector3;                             // current facet barycenter position
		// loop on all the facets in the current partitioning block
		for (idx in 0...facetsInBlock.length) {
			fib = facetsInBlock[idx];           
			norm = facetNormals[fib];
			p0 = facetPositions[fib];
			
			d = (x - p0.x) * norm.x + (y - p0.y) * norm.y + (z - p0.z) * norm.z;
			if (!checkFace || (checkFace && facing && d >= 0.0) || (checkFace && !facing && d <= 0.0)) {
				// compute (x,y,z) projection on the facet = (projx, projy, projz)
				d = norm.x * p0.x + norm.y * p0.y + norm.z * p0.z; 
				t0 = -(norm.x * x + norm.y * y + norm.z * z - d) / (norm.x * norm.x + norm.y * norm.y + norm.z * norm.z);
				projx = x + norm.x * t0;
				projy = y + norm.y * t0;
				projz = z + norm.z * t0;
				
				tmpx = projx - x;
				tmpy = projy - y;
				tmpz = projz - z;
				tmpDistance = tmpx * tmpx + tmpy * tmpy + tmpz * tmpz;             // compute length between (x, y, z) and its projection on the facet
				if (tmpDistance < shortest) {                                      // just keep the closest facet to (x, y, z)
					shortest = tmpDistance;
					closest = fib; 
					if (projected != null) {
						projected.x = projx;
						projected.y = projy;
						projected.z = projz;
					}
				}
			}
		}
		return closest;
	}
	
	/**
	 * Returns the object "parameter" set with all the expected parameters for facetData computation by ComputeNormals()  
	 */
	public function getFacetDataParameters():Dynamic {
		return this._facetParameters;
	}
	
	/** 
	 * Disables the feature FacetData and frees the related memory.  
	 * Returns the AbstractMesh.  
	 */
	public function disableFacetData():AbstractMesh {
		if (this._facetDataEnabled) {
			this._facetDataEnabled = false;
			this._facetPositions = null;
			this._facetNormals = null;
			this._facetPartitioning = null;
			this._facetParameters = null;
		}
		return this;
	}
	/**
	 * Updates the AbstractMesh indices array. Actually, used by the Mesh object.
	 * Returns the mesh.
	 */
	public function updateIndices(indices:UInt32Array, offset:Int = 0):AbstractMesh {
		return this;
	}

	/**
	 * Creates new normals data for the mesh.
	 * @param updatable.
	 */
	public function createNormals(updatable:Bool) {
		var positions = this.getVerticesData(VertexBuffer.PositionKind);
		var indices = this.getIndices();
		var normals:Float32Array = null;
		
		if (this.isVerticesDataPresent(VertexBuffer.NormalKind)) {
			normals = this.getVerticesData(VertexBuffer.NormalKind);
		} 
		else {
			normals = new Float32Array();
		}
		
		VertexData.ComputeNormals(positions, indices, normals, { useRightHandedSystem: this.getScene().useRightHandedSystem });
		this.setVerticesData(VertexBuffer.NormalKind, normals, updatable);
	}
	
	/**
	 * Align the mesh with a normal.
	 * Returns the mesh.  
	 */
	public function alignWithNormal(normal:Vector3, ?upDirection:Vector3):AbstractMesh {       
		if (upDirection == null) {
			upDirection = Axis.Y;
		}
		
		var axisX = Tmp.vector3[0];
		var axisZ = Tmp.vector3[1];
		Vector3.CrossToRef(upDirection, normal, axisZ);
		Vector3.CrossToRef(normal, axisZ, axisX);
		
		if (this.rotationQuaternion != null) {
			Quaternion.RotationQuaternionFromAxisToRef(axisX, normal, axisZ, this.rotationQuaternion);
		}
		else {
			Vector3.RotationFromAxisToRef(axisX, normal, axisZ, this.rotation);
		}
		
		return this;
	}
	
	private function checkOcclusionQuery() {
		var engine = this.getEngine();
		
		if (engine.webGLVersion < 2 || this.occlusionType == AbstractMesh.OCCLUSION_TYPE_NONE) {
			this._isOccluded = false;
			return;
		}
		
		if (this._isOcclusionQueryInProgress) {			
			var isOcclusionQueryAvailable = engine.isQueryResultAvailable(this._occlusionQuery);
			if (isOcclusionQueryAvailable) {
				var occlusionQueryResult = engine.getQueryResult(this._occlusionQuery);
				
				this._isOcclusionQueryInProgress = false;
				this._occlusionInternalRetryCounter = 0;
				this._isOccluded = occlusionQueryResult == 1 ? false : true;
			}
			else {
				this._occlusionInternalRetryCounter++;
				
				if (this.occlusionRetryCount != -1 && this._occlusionInternalRetryCounter > this.occlusionRetryCount) {
					this._isOcclusionQueryInProgress = false;
					this._occlusionInternalRetryCounter = 0;
					
					// if optimistic set isOccluded to false regardless of the status of isOccluded. (Render in the current render loop)
					// if strict continue the last state of the object.
					this._isOccluded = this.occlusionType == AbstractMesh.OCCLUSION_TYPE_OPTIMISTIC ? false : this._isOccluded;
				}
				else {
					return;
				}
			}
		}
		
		var scene = this.getScene();
		var occlusionBoundingBoxRenderer = scene.getBoundingBoxRenderer();
		
		if (this._occlusionQuery == null) {
			this._occlusionQuery = engine.createQuery();
		}
		
		engine.beginQuery(this.occlusionQueryAlgorithmType, this._occlusionQuery);
		occlusionBoundingBoxRenderer.renderOcclusionBoundingBox(this);
		engine.endQuery(this.occlusionQueryAlgorithmType);
		this._isOcclusionQueryInProgress = true;
	}
	
}
