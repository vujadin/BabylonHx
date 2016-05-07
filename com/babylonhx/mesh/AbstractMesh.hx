package com.babylonhx.mesh;

import com.babylonhx.actions.ActionManager;
import com.babylonhx.bones.Bone;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.cameras.Camera;
import com.babylonhx.collisions.Collider;
import com.babylonhx.collisions.IntersectionInfo;
import com.babylonhx.collisions.PickingInfo;
import com.babylonhx.culling.BoundingInfo;
import com.babylonhx.culling.BoundingSphere;
import com.babylonhx.culling.octrees.Octree;
import com.babylonhx.materials.Material;
import com.babylonhx.materials.MaterialDefines;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Plane;
import com.babylonhx.math.Axis;
import com.babylonhx.math.Quaternion;
import com.babylonhx.culling.Ray;
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
import com.babylonhx.utils.typedarray.Float32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
 
@:expose('BABYLON.AbstractMesh') class AbstractMesh extends Node implements IDisposable {
	
	// Statics
	public static var BILLBOARDMODE_NONE:Int = 0;
	public static var BILLBOARDMODE_X:Int = 1;
	public static var BILLBOARDMODE_Y:Int = 2;
	public static var BILLBOARDMODE_Z:Int = 4;
	public static var BILLBOARDMODE_ALL:Int = 7;


	// Properties
	public var definedFacingForward:Bool = true; // orientation for POV movement & rotation
	public var position:Vector3 = new Vector3(0, 0, 0);
	public var rotation(get, set):Vector3;
	public var rotationQuaternion(get, set):Quaternion;
	public var scaling(get, set):Vector3;
	public var billboardMode:Int = AbstractMesh.BILLBOARDMODE_NONE;
	
	private var _rotation:Vector3 = new Vector3(0, 0, 0);
	private var _scaling:Vector3 = new Vector3(1, 1, 1);
	private var _rotationQuaternion:Quaternion;
	
	private var _visibility:Float = 1.0;
	public var visibility(get, set):Float;
	private function get_visibility():Float {
		return _visibility;
	}
	private function set_visibility(val:Float):Float {
		_visibility = val;
		return val;
	}	
	
	public var alphaIndex:Float = Math.POSITIVE_INFINITY;
	public var infiniteDistance:Bool = false;
	public var isVisible:Bool = true;	
	
	private var _isPickable:Bool = false;
	public var isPickable(get, set):Bool;
	private function get_isPickable():Bool {
		return _isPickable;
	}
	private function set_isPickable(val:Bool):Bool {
		_isPickable = val;
		return val;
	}
	
	public var showBoundingBox:Bool = false;
	public var showSubMeshesBoundingBox:Bool = false;
	public var onDispose:Void->Void = null;	
	public var isBlocker:Bool = false;	
	
	public var renderingGroupId:Int = 0;	
	
	private var _material:Material;
	public var material(get, set):Material;
	private function get_material():Material {
		return _material;
	}
	private function set_material(val:Material):Material {
		_material = val;
		return val;
	}
	
	private var _receiveShadows:Bool = false;
	public var receiveShadows(get, set):Bool;
	private function get_receiveShadows():Bool {
		return _receiveShadows;
	}
	private function set_receiveShadows(val:Bool):Bool {
		_receiveShadows = val;
		return val;
	}
	
	public var actionManager:ActionManager;
	public var renderOutline:Bool = false;
	public var outlineColor:Color3 = Color3.Red();
	public var outlineWidth:Float = 0.02;
	public var renderOverlay:Bool = false;
	public var overlayColor:Color3 = Color3.Red();
	public var overlayAlpha:Float = 0.5;
	public var hasVertexAlpha:Bool = false;
	public var useVertexColors:Bool = true;
	public var applyFog:Bool = true;
	public var computeBonesUsingShaders:Bool = true;
	public var scalingDeterminant:Float = 1;
	public var numBoneInfluencers:Int = 4;

	public var useOctreeForRenderingSelection:Bool = true;
	public var useOctreeForPicking:Bool = true;
	public var useOctreeForCollisions:Bool = true;

	public var layerMask:Int = 0x0FFFFFFF;
	
	// for bGUI
	public var __gui:Bool = false;
	
	public var alwaysSelectAsActiveMesh:Bool = false;

	// Physics
	public var _physicImpostor:Int = PhysicsEngine.NoImpostor;
	public var _physicsMass:Float = 0;
	public var _physicsFriction:Float = 0;
	public var _physicRestitution:Float = 0;
	public var onPhysicsCollide:AbstractMesh->Dynamic->Void; 

	// Collisions
	private var _checkCollisions:Bool = false;
	public var ellipsoid:Vector3 = new Vector3(0.5, 1, 0.5);
	public var ellipsoidOffset:Vector3 = new Vector3(0, 0, 0);
	private var _collider:Collider = new Collider();
	private var _oldPositionForCollisions:Vector3 = new Vector3(0, 0, 0);
	private var _diffPositionForCollisions:Vector3 = new Vector3(0, 0, 0);
	private var _newPositionForCollisions:Vector3 = new Vector3(0, 0, 0);
	public var onCollide:AbstractMesh->Void;
	public var onCollisionPositionChange:Vector3->Void;
	
	// Attach to bone
    private var _meshToBoneReferal:AbstractMesh;
	
	// Edges
	public var edgesWidth:Float = 1;
    public var edgesColor:Color4 = new Color4(1, 0, 0, 1);
	public var _edgesRenderer:EdgesRenderer;

	// Cache
	private var _localScaling:Matrix = Matrix.Zero();
	private var _localRotation:Matrix = Matrix.Zero();
	private var _localTranslation:Matrix = Matrix.Zero();
	private var _localBillboard:Matrix = Matrix.Zero();
	private var _localPivotScaling:Matrix = Matrix.Zero();
	private var _localPivotScalingRotation:Matrix = Matrix.Zero();
	private var _localMeshReferalTransform:Matrix;
	private var _localWorld:Matrix = Matrix.Zero();
	public var _worldMatrix:Matrix = Matrix.Zero();
	private var _rotateYByPI:Matrix = Matrix.RotationY(Math.PI);
	private var _absolutePosition:Vector3 = Vector3.Zero();
	private var _collisionsTransformMatrix:Matrix = Matrix.Zero();
	private var _collisionsScalingMatrix:Matrix = Matrix.Zero();	
	
	public var _savedMaterial:Material;
		
	private var _positions:Array<Vector3>;
	public var positions(get, set):Array<Vector3>;
	private function get_positions():Array<Vector3> {
		return _positions;
	}
	private function set_positions(val:Array<Vector3>):Array<Vector3> {
		_positions = val;
		return val;
	}
	
	public var useBones(get, never):Bool;
	private function get_useBones():Bool {
		return this.skeleton != null && this.getScene().skeletonsEnabled && this.isVerticesDataPresent(VertexBuffer.MatricesIndicesKind) && this.isVerticesDataPresent(VertexBuffer.MatricesWeightsKind);
	}
	
	private var _isDirty:Bool = false;
	public var _masterMesh:AbstractMesh;
	public var _materialDefines:MaterialDefines;

	public var _boundingInfo:BoundingInfo;
	private var _pivotMatrix:Matrix = Matrix.Identity();
	public var _isDisposed:Bool = false;
	public var _renderId:Int = 0;

	public var subMeshes:Array<SubMesh>;
	public var _submeshesOctree:Octree<SubMesh>;
	public var _intersectionsInProgress:Array<AbstractMesh> = [];
	
	private var _onAfterWorldMatrixUpdate:Array<AbstractMesh->Void> = [];
	
	private var _isWorldMatrixFrozen:Bool = false;
	
	public var _unIndexed:Bool = false;
	
	public var _poseMatrix:Matrix;
	
	// Loading properties
	public var _waitingActions:Dynamic;
	public var _waitingFreezeWorldMatrix:Bool;
	
	// Skeleton
	private var _skeleton:Skeleton;
	public var skeleton(get, set):Skeleton;
	public var _bonesTransformMatrices: #if (js || purejs || web || html5) Float32Array #else Array<Float> #end ;
	
	private function get_skeleton():Skeleton {
		return this._skeleton;
	}
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
		
		return value;
	}
	

	public function new(name:String, scene:Scene) {
		super(name, scene);
		scene.addMesh(this);
		
		// TODO: macro ...
		#if purejs
		untyped __js__("Object.defineProperty(this, 'visibility', { get: this.get_visibility, set: this.set_visibility })");
		untyped __js__("Object.defineProperty(this, 'isPickable', { get: this.get_isPickable, set: this.set_isPickable })");
		untyped __js__("Object.defineProperty(this, 'skeleton', { get: this.get_skeleton, set: this.set_skeleton })");
		untyped __js__("Object.defineProperty(this, 'material', { get: this.get_material, set: this.set_material })");
		untyped __js__("Object.defineProperty(this, 'receiveShadows', { get: this.get_receiveShadows, set: this.set_receiveShadows })");
		untyped __js__("Object.defineProperty(this, 'positions', { get: this.get_positions, set: this.set_positions })");
		untyped __js__("Object.defineProperty(this, 'useBones', { get: this.get_useBones, set: this.set_useBones })");
		untyped __js__("Object.defineProperty(this, 'isBlocked', { get: this.get_isBlocked, set: this.set_isBlocked })");
		untyped __js__("Object.defineProperty(this, 'worldMatrixFromCache', { get: this.get_worldMatrixFromCache })");
		untyped __js__("Object.defineProperty(this, 'absolutePosition', { get: this.get_absolutePosition })");
		untyped __js__("Object.defineProperty(this, 'isWorldMatrixFrozen', { get: this.get_isWorldMatrixFrozen })");
		#end
	}
	
	/**
	 * Getting the rotation object. 
	 * If rotation quaternion is set, this vector will (almost always) be the Zero vector!
	 */
	private function get_rotation():Vector3 {
		return this._rotation;
	}
	private function set_rotation(newRotation:Vector3):Vector3 {
		return this._rotation = newRotation;
	}

	private function get_scaling():Vector3 {
		return this._scaling;
	}
	private function set_scaling(newScaling:Vector3):Vector3 {
		this._scaling = newScaling;
		/*if (this.physicsImpostor != null) {
			this.physicsImpostor.forceUpdate();
		}*/
		
		return newScaling;
	}

	private function get_rotationQuaternion():Quaternion {
		return this._rotationQuaternion;
	} 
	private function set_rotationQuaternion(?quaternion:Quaternion):Quaternion {
        this._rotationQuaternion = quaternion;
        //reset the rotation vector. 
		if (quaternion != null && this.rotation.length() > 0) {
			this.rotation.copyFromFloats(0, 0, 0);
		}
		
		return quaternion;
	}

	// Methods
	public function updatePoseMatrix(matrix:Matrix) {
		this._poseMatrix.copyFrom(matrix);
	}

	public function getPoseMatrix():Matrix {
		return this._poseMatrix;
	}
	
	public function disableEdgesRendering() {
        if (this._edgesRenderer != null) {
            this._edgesRenderer.dispose();
            this._edgesRenderer = null;
        }
    }
    public function enableEdgesRendering(epsilon:Float = 0.95, checkVerticesInsteadOfIndices:Bool = false) {
        this.disableEdgesRendering();
		
        this._edgesRenderer = new EdgesRenderer(this, epsilon, checkVerticesInsteadOfIndices);
    }
	
	private var _isBlocked:Bool;
	public var isBlocked(get, never):Bool;
	private function get_isBlocked():Bool {
		return false;
	}

	public function getLOD(camera:Camera, ?boundingSphere:BoundingSphere):AbstractMesh {
		return this;
	}

	public function getTotalVertices():Int {
		return 0;
	}

	public function getIndices(copyWhenShared:Bool = false):Array<Int> {
		return null;
	}

	public function getVerticesData(kind:String, copyWhenShared:Bool = false):Array<Float> {
		return null;
	}

	public function isVerticesDataPresent(kind:String):Bool {
		return false;
	}

	public function getBoundingInfo():BoundingInfo {
		if (this._masterMesh != null) {
			return this._masterMesh.getBoundingInfo();
		}
		
		if (this._boundingInfo == null) {
			this._updateBoundingInfo();
		}
		
		return this._boundingInfo;
	}
	
	public function _preActivate() { }
	
	public function _preActivateForIntermediateRendering(renderId:Int) { }
	
	public function _activate(renderId:Int) {
		this._renderId = renderId;
	}

	override public function getWorldMatrix():Matrix {
		if (this._masterMesh != null) {
			return this._masterMesh.getWorldMatrix();
		}
		
		if (this._currentRenderId != this.getScene().getRenderId()) {
			this.computeWorldMatrix();
		}
		
		return this._worldMatrix;
	}

	public var worldMatrixFromCache(get, never):Matrix;
	private function get_worldMatrixFromCache():Matrix {
		return this._worldMatrix;
	}

	public var absolutePosition(get, never):Vector3;
	private function get_absolutePosition():Vector3 {
		return this._absolutePosition;
	}
	
	inline public function freezeWorldMatrix() {
		this._isWorldMatrixFrozen = false;  // no guarantee world is not already frozen, switch off temporarily
        this.computeWorldMatrix(true);
        this._isWorldMatrixFrozen = true;
    }

    inline public function unfreezeWorldMatrix() {
        this._isWorldMatrixFrozen = false;
		this.computeWorldMatrix(true);
    }
	
	public var isWorldMatrixFrozen(get, never):Bool;
	private function get_isWorldMatrixFrozen():Bool {
        return this._isWorldMatrixFrozen;
    }

	public function rotate(axis:Vector3, amount:Float, space:Space) {
		axis.normalize();
		
		if (this.rotationQuaternion == null) {
			this.rotationQuaternion = Quaternion.RotationYawPitchRoll(this.rotation.y, this.rotation.x, this.rotation.z);
			this.rotation = Vector3.Zero();
		}
		
		var rotationQuaternion = Quaternion.RotationAxis(axis, amount);
		if (space == null || space == Space.LOCAL) {
			this.rotationQuaternion = this.rotationQuaternion.multiply(rotationQuaternion);
		}
		else {
			if (this.parent != null) {
				var invertParentWorldMatrix = this.parent.getWorldMatrix().clone();
				invertParentWorldMatrix.invert();
				
				axis = Vector3.TransformNormal(axis, invertParentWorldMatrix);
			}
			rotationQuaternion = Quaternion.RotationAxis(axis, amount);
			this.rotationQuaternion = rotationQuaternion.multiply(this.rotationQuaternion);
		}
	}

	public function translate(axis:Vector3, distance:Float, ?space:Space) {
		var displacementVector = axis.scale(distance);
		
		if (space == null || space == Space.LOCAL) {
			var tempV3 = this.getPositionExpressedInLocalSpace().add(displacementVector);
			this.setPositionWithLocalVector(tempV3);
		}
		else {
			this.setAbsolutePosition(this.getAbsolutePosition().add(displacementVector));
		}
	}

	inline public function getAbsolutePosition():Vector3 {
		this.computeWorldMatrix();
		return this._absolutePosition;
	}

	public function setAbsolutePosition(?absolutePosition:Dynamic) {
		if (absolutePosition == null) {
			return;
		}
		
		var absolutePositionX:Float = 0;
		var absolutePositionY:Float = 0;
		var absolutePositionZ:Float = 0;
		
		if (Std.is(absolutePosition, Array)) {
            if (absolutePosition.length < 3) {
                return;
            }
            absolutePositionX = absolutePosition[0];
            absolutePositionY = absolutePosition[1];
            absolutePositionZ = absolutePosition[2];
        } 
		else {	// its Vector3
            absolutePositionX = absolutePosition.x;
            absolutePositionY = absolutePosition.y;
            absolutePositionZ = absolutePosition.z;
        }
		
		if (this.parent != null) {
			var invertParentWorldMatrix = this.parent.getWorldMatrix().clone();
			invertParentWorldMatrix.invert();
			
			var worldPosition = new Vector3(absolutePositionX, absolutePositionY, absolutePositionZ);
			
			this.position = Vector3.TransformCoordinates(worldPosition, invertParentWorldMatrix);
		} 
		else {
			this.position.x = absolutePositionX;
			this.position.y = absolutePositionY;
			this.position.z = absolutePositionZ;
		}
	}
	
	// ================================== Point of View Movement =================================
	/**
	 * Perform relative position change from the point of view of behind the front of the mesh.
	 * This is performed taking into account the meshes current rotation, so you do not have to care.
	 * Supports definition of mesh facing forward or backward.
	 * @param {number} amountRight
	 * @param {number} amountUp
	 * @param {number} amountForward
	 */
	inline public function movePOV(amountRight:Float, amountUp:Float, amountForward:Float) {
		this.position.addInPlace(this.calcMovePOV(amountRight, amountUp, amountForward));
	}
	
	/**
	 * Calculate relative position change from the point of view of behind the front of the mesh.
	 * This is performed taking into account the meshes current rotation, so you do not have to care.
	 * Supports definition of mesh facing forward or backward.
	 * @param {number} amountRight
	 * @param {number} amountUp
	 * @param {number} amountForward
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
	 */
	inline public function rotatePOV(flipBack:Float, twirlClockwise:Float, tiltRight:Float) {
		this.rotation.addInPlace(this.calcRotatePOV(flipBack, twirlClockwise, tiltRight));
	}
	
	/**
	 * Calculate relative rotation change from the point of view of behind the front of the mesh.
	 * Supports definition of mesh facing forward or backward.
	 * @param {number} flipBack
	 * @param {number} twirlClockwise
	 * @param {number} tiltRight
	 */
	inline public function calcRotatePOV(flipBack:Float, twirlClockwise:Float, tiltRight:Float):Vector3 {
		var defForwardMult = this.definedFacingForward ? 1 : -1;
		return new Vector3(flipBack * defForwardMult, twirlClockwise, tiltRight * defForwardMult);
	}

	inline public function setPivotMatrix(matrix:Matrix) {
		this._pivotMatrix = matrix;
		this._cache.pivotMatrixUpdated = true;
	}

	inline public function getPivotMatrix():Matrix {
		return this._pivotMatrix;
	}

	override public function _isSynchronized():Bool {
		if (this._isDirty) {
			return false;
		}
		
		if (this.billboardMode != this._cache.billboardMode || this.billboardMode != AbstractMesh.BILLBOARDMODE_NONE) {
			return false;
		}
		
		if (this._cache.pivotMatrixUpdated) {
			return false;
		}
		
		if (this.infiniteDistance) {
			return false;
		}
		
		if (!this._cache.position.equals(this.position)) {
			return false;
		}
		
		if (!this._cache.rotation.equals(this.rotation)) {
			return false;
		}
		
		if (this.rotationQuaternion != null) {
			if (!this._cache.rotationQuaternion.equals(this.rotationQuaternion)) {
				return false;
			}
		} 
		
		if (!this._cache.scaling.equals(this.scaling)) {
			return false;
		}
		
		return true;
	}

	override public function _initCache() {
		super._initCache();
		
		this._cache.localMatrixUpdated = false;
		this._cache.position = Vector3.Zero();
		this._cache.scaling = Vector3.Zero();
		this._cache.rotation = Vector3.Zero();
		this._cache.rotationQuaternion = new Quaternion(0, 0, 0, 0);
		this._cache.billboardMode = -1;
	}

	inline public function markAsDirty(property:String) {
		if (property == "rotation") {
			this.rotationQuaternion = null;
		}
		this._currentRenderId = cast Math.POSITIVE_INFINITY;
		this._isDirty = true;
	}

	inline public function _updateBoundingInfo() {
		this._boundingInfo = this._boundingInfo == null ? new BoundingInfo(this.absolutePosition, this.absolutePosition) : this._boundingInfo;
		
		this._boundingInfo._update(this.worldMatrixFromCache);
		
		this._updateSubMeshesBoundingInfo(this.worldMatrixFromCache);
	}
	
	public function _updateSubMeshesBoundingInfo(matrix:Matrix) {
		if (this.subMeshes == null) {
			return;
		}
		
		for (subMesh in this.subMeshes) {	
			if (!subMesh.IsGlobal) {
				subMesh.updateBoundingInfo(matrix);
			}
		}
	}

	public function computeWorldMatrix(force:Bool = false):Matrix {
		if (this._isWorldMatrixFrozen) {
			return this._worldMatrix;
		}
		
		if (!force && (this._currentRenderId == this.getScene().getRenderId() || this.isSynchronized(true))) {
			this._currentRenderId = this.getScene().getRenderId();
			return this._worldMatrix;
		}
		
		this._cache.position.copyFrom(this.position);
		this._cache.scaling.copyFrom(this.scaling);
		this._cache.pivotMatrixUpdated = false;
		this._cache.billboardMode = this.billboardMode;
		this._currentRenderId = this.getScene().getRenderId();
		this._isDirty = false;
		
		// Scaling
		Matrix.ScalingToRef(this.scaling.x * this.scalingDeterminant, this.scaling.y * this.scalingDeterminant, this.scaling.z * this.scalingDeterminant, Tmp.matrix[1]);
		
		// Rotation
		
		//rotate, if quaternion is set and rotation was used
		if (this.rotationQuaternion != null) {
			var len = this.rotation.length();
			if (len != 0) {
				this.rotationQuaternion.multiplyInPlace(Quaternion.RotationYawPitchRoll(this.rotation.y, this.rotation.x, this.rotation.z));
				this.rotation.copyFromFloats(0, 0, 0);
			}
		}
		
		if (this.rotationQuaternion != null) {
			this.rotationQuaternion.toRotationMatrix(Tmp.matrix[0]);
			this._cache.rotationQuaternion.copyFrom(this.rotationQuaternion);
		} 
		else {
			Matrix.RotationYawPitchRollToRef(this.rotation.y, this.rotation.x, this.rotation.z, Tmp.matrix[0]);
			this._cache.rotation.copyFrom(this.rotation);
		}
		
		// Translation
		if (this.infiniteDistance && this.parent == null) {
			var camera = this.getScene().activeCamera;
			if (camera != null) {
				var cameraWorldMatrix = camera.getWorldMatrix();
				
				var cameraGlobalPosition = new Vector3(cameraWorldMatrix.m[12], cameraWorldMatrix.m[13], cameraWorldMatrix.m[14]);
				
				Matrix.TranslationToRef(this.position.x + cameraGlobalPosition.x, this.position.y + cameraGlobalPosition.y,
					this.position.z + cameraGlobalPosition.z, Tmp.matrix[2]);
			}
		} 
		else {
			Matrix.TranslationToRef(this.position.x, this.position.y, this.position.z, Tmp.matrix[2]);
		}
		
		// Composing transformations
		this._pivotMatrix.multiplyToRef(Tmp.matrix[1], Tmp.matrix[4]);
		Tmp.matrix[4].multiplyToRef(Tmp.matrix[0], Tmp.matrix[5]);
		
		// Billboarding
		if (this.billboardMode != AbstractMesh.BILLBOARDMODE_NONE && this.getScene().activeCamera != null) {
			Tmp.vector3[0].copyFrom(this.position);
			var localPosition = Tmp.vector3[0];
			
			if (this.parent != null && this.parent.getWorldMatrix() != null) {
				this._markSyncedWithParent();
				
				var parentMatrix:Matrix = null;
				if (this._meshToBoneReferal != null) {
					this.parent.getWorldMatrix().multiplyToRef(this._meshToBoneReferal.getWorldMatrix(), Tmp.matrix[6]);
					parentMatrix = Tmp.matrix[6];
				} 
				else {
					parentMatrix = this.parent.getWorldMatrix();
				}
				
				Vector3.TransformNormalToRef(localPosition, parentMatrix, Tmp.vector3[1]);
				localPosition = Tmp.vector3[1];
			}
			
			var zero = this.getScene().activeCamera.globalPosition.clone();
			
			if (this.parent != null && Reflect.hasField(this.parent, "position")) {
				localPosition.addInPlace(untyped this.parent.position);
				Matrix.TranslationToRef(localPosition.x, localPosition.y, localPosition.z, Tmp.matrix[2]);
			}
			
			if ((this.billboardMode & AbstractMesh.BILLBOARDMODE_ALL) != AbstractMesh.BILLBOARDMODE_ALL) {
				if (this.billboardMode & AbstractMesh.BILLBOARDMODE_X != 0) {
					zero.x = localPosition.x + Tools.Epsilon;
				}
				if (this.billboardMode & AbstractMesh.BILLBOARDMODE_Y != 0) {
					zero.y = localPosition.y + 0.001;
				}
				if (this.billboardMode & AbstractMesh.BILLBOARDMODE_Z != 0) {
					zero.z = localPosition.z + 0.001;
				}
			}
			
			Matrix.LookAtLHToRef(localPosition, zero, Vector3.Up(), Tmp.matrix[3]);
			Tmp.matrix[3].m[12] = 0;
			Tmp.matrix[3].m[13] = 0;
			Tmp.matrix[3].m[14] = 0;
			
			Tmp.matrix[3].invert();
			
			Tmp.matrix[5].multiplyToRef(Tmp.matrix[3], this._localWorld);
			this._rotateYByPI.multiplyToRef(this._localWorld, Tmp.matrix[5]);
		}
		
		// Local world
		Tmp.matrix[5].multiplyToRef(Tmp.matrix[2], this._localWorld);
		
		// Parent
		if (this.parent != null && this.billboardMode == AbstractMesh.BILLBOARDMODE_NONE) {
			this._markSyncedWithParent();
			
			if (this._meshToBoneReferal != null) {
				this._localWorld.multiplyToRef(this.parent.getWorldMatrix(), Tmp.matrix[6]);
				Tmp.matrix[6].multiplyToRef(this._meshToBoneReferal.getWorldMatrix(), this._worldMatrix);
			} 
			else {
				this._localWorld.multiplyToRef(this.parent.getWorldMatrix(), this._worldMatrix);
			}
		} 
		else {
			this._worldMatrix.copyFrom(this._localWorld);
		}
		
		// Bounding info
		this._updateBoundingInfo();
		
		// Absolute position
		this._absolutePosition.copyFromFloats(this._worldMatrix.m[12], this._worldMatrix.m[13], this._worldMatrix.m[14]);
		
		// Callbacks
		for (callbackIndex in this._onAfterWorldMatrixUpdate) {
			callbackIndex(this);
        }
		
		if (this._poseMatrix == null) {
			this._poseMatrix = Matrix.Invert(this._worldMatrix);
		}
		
		return this._worldMatrix;
	}
	
	/**
     * If you'd like to be callbacked after the mesh position, rotation or scaling has been updated
     * @param func: callback function to add
     */
    public function registerAfterWorldMatrixUpdate(func:AbstractMesh->Void) {
        this._onAfterWorldMatrixUpdate.push(func);
    }

    public function unregisterAfterWorldMatrixUpdate(func:AbstractMesh->Void) {
        var index = this._onAfterWorldMatrixUpdate.indexOf(func);
		
        if (index > -1) {
            this._onAfterWorldMatrixUpdate.splice(index, 1);
        }
    }

	inline public function setPositionWithLocalVector(vector3:Vector3) {
		this.computeWorldMatrix();		
		this.position = Vector3.TransformNormal(vector3, this._localWorld);
	}

	inline public function getPositionExpressedInLocalSpace():Vector3 {
		this.computeWorldMatrix();
		var invLocalWorldMatrix = this._localWorld.clone();
		invLocalWorldMatrix.invert();
		
		return Vector3.TransformNormal(this.position, invLocalWorldMatrix);
	}

	inline public function locallyTranslate(vector3:Vector3) {
		this.computeWorldMatrix();
		this.position = Vector3.TransformCoordinates(vector3, this._localWorld);
	}

	/// <summary>Orients a mesh towards a target point. Mesh must be drawn facing user.</summary>
	/// <param name="targetPoint" type="Vector3">The position (must be in same space as current mesh) to look at</param>
	/// <param name="yawCor" type="Number">optional yaw (y-axis) correction in radians</param>
	/// <param name="pitchCor" type="Number">optional pitch (x-axis) correction in radians</param>
	/// <param name="rollCor" type="Number">optional roll (z-axis) correction in radians</param>
	/// <returns>Mesh oriented towards targetMesh</returns>
	inline public function lookAt(targetPoint:Vector3, yawCor:Float = 0, pitchCor:Float = 0, rollCor:Float = 0) {		
		var dv = targetPoint.subtract(this.position);
		var yaw = -Math.atan2(dv.z, dv.x) - Math.PI / 2;
		var len = Math.sqrt(dv.x * dv.x + dv.z * dv.z);
		var pitch = Math.atan2(dv.y, len);
		this.rotationQuaternion = Quaternion.RotationYawPitchRoll(yaw + yawCor, pitch + pitchCor, rollCor);
	}
	
	public function attachToBone(bone:Bone, affectedMesh:AbstractMesh) {
		this._meshToBoneReferal = affectedMesh;
		this.parent = bone;
	}

	public function detachFromBone() {
		this._meshToBoneReferal = null;
		this.parent = null;
	}

	public function isInFrustum(frustumPlanes:Array<Plane>):Bool {
		return this._boundingInfo.isInFrustum(frustumPlanes);
	}

	public function isCompletelyInFrustum(?camera:Camera):Bool {
		if (camera == null) {
			camera = this.getScene().activeCamera;
		}
		
		var transformMatrix = camera.getViewMatrix().multiply(camera.getProjectionMatrix(false));
		
		if (!this._boundingInfo.isCompletelyInFrustum(Frustum.GetPlanes(transformMatrix))) {
			return false;
		}
		
		return true;
	}

	public function intersectsMesh(mesh:AbstractMesh, precise:Bool = false):Bool {
		if (this._boundingInfo == null || mesh._boundingInfo == null) {
			return false;
		}
		
		return this._boundingInfo.intersects(mesh._boundingInfo, precise);
	}

	public function intersectsPoint(point:Vector3):Bool {
		if (this._boundingInfo == null) {
			return false;
		}
		
		return this._boundingInfo.intersectsPoint(point);
	}

	// Physics
	public function setPhysicsState(?impostor:Dynamic, ?options:PhysicsBodyCreationOptions):Dynamic {
		var physicsEngine = this.getScene().getPhysicsEngine();
		
		if (physicsEngine == null) {
			return null;
		}
		
		impostor = impostor != null ? impostor : PhysicsEngine.NoImpostor;
		
		if (Reflect.hasField(impostor, "impostor")) {
			// Old API
			options = impostor;
			impostor = impostor.impostor;
		}
		
		if (impostor == PhysicsEngine.NoImpostor) {
			physicsEngine._unregisterMesh(this);
			return null;
		}
		
		if (options == null) {
			options.mass = 0;
			options.friction = 0.2;
			options.restitution = 0.2;
		} 
		else {
			if (options.mass == null) options.mass = 0;
			if (options.friction == null) options.friction = 0.2;
			if (options.restitution == null) options.restitution = 0.2;
		}
		
		this._physicImpostor = impostor;
		this._physicsMass = options.mass;
		this._physicsFriction = options.friction;
		this._physicRestitution = options.restitution;
				
		return physicsEngine._registerMesh(this, impostor, options);
	}

	inline public function getPhysicsImpostor():Int {
		return this._physicImpostor;
	}

	inline public function getPhysicsMass():Float {
		return this._physicsMass;
	}

	inline public function getPhysicsFriction():Float {
		return this._physicsFriction;
	}

	inline public function getPhysicsRestitution():Float {
		return this._physicRestitution;
	}
	
	inline public function getPositionInCameraSpace(?camera:Camera):Vector3 {
		if (camera == null) {
			camera = this.getScene().activeCamera;
		}
		
		return Vector3.TransformCoordinates(this.absolutePosition, camera.getViewMatrix());
	}

	inline public function getDistanceToCamera(?camera:Camera):Float {
		if (camera == null) {
			camera = this.getScene().activeCamera;
		}
		
		return this.absolutePosition.subtract(camera.position).length();
	}

	inline public function applyImpulse(force:Vector3, contactPoint:Vector3) {
		if (this._physicImpostor != PhysicsEngine.NoImpostor) {
			this.getScene().getPhysicsEngine()._applyImpulse(this, force, contactPoint);
		}	
	}

	inline public function setPhysicsLinkWith(otherMesh:Mesh, pivot1:Vector3, pivot2:Vector3, ?options:Dynamic) {
		if (this._physicImpostor != PhysicsEngine.NoImpostor) {
			this.getScene().getPhysicsEngine()._createLink(this, otherMesh, pivot1, pivot2, options);
		}	
	}

	inline public function updatePhysicsBodyPosition() {
		if (this._physicImpostor != PhysicsEngine.NoImpostor) {
			this.getScene().getPhysicsEngine()._updateBodyPosition(this);
		}		
	}


	// Collisions
	public var checkCollisions(get, set):Bool;
	private function get_checkCollisions():Bool {
		return this._checkCollisions;
	}
	private function set_checkCollisions(collisionEnabled:Bool):Bool {
		this._checkCollisions = collisionEnabled;
		if (this.getScene().workerCollisions) {
			this.getScene().collisionCoordinator.onMeshUpdated(this);
		}
		return collisionEnabled;
	}
	
	inline public function moveWithCollisions(velocity:Vector3) {
		var globalPosition:Vector3 = this.getAbsolutePosition();
		
		globalPosition.subtractFromFloatsToRef(0, this.ellipsoid.y, 0, this._oldPositionForCollisions);
		this._oldPositionForCollisions.addInPlace(this.ellipsoidOffset);
		this._collider.radius = this.ellipsoid;
		
		this.getScene().collisionCoordinator.getNewPosition(this._oldPositionForCollisions, velocity, this._collider, 3, this, this._onCollisionPositionChange, this.uniqueId);
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
		
		if (this.onCollide != null && collidedMesh != null) {
			this.onCollide(collidedMesh);
		}
	}

	// Submeshes octree

	/**
	* This function will create an octree to help select the right submeshes for rendering, picking and collisions
	* Please note that you must have a decent number of submeshes to get performance improvements when using octree
	*/
	inline public function createOrUpdateSubmeshesOctree(maxCapacity:Int = 64, maxDepth:Int = 2):Octree<SubMesh> {
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
	inline public function _collideForSubMesh(subMesh:SubMesh, transformMatrix:Matrix, collider:Collider) {
		this._generatePointsArray();
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
		collider._collide(subMesh, subMesh._lastColliderWorldVertices, this.getIndices(), subMesh.indexStart, subMesh.indexStart + subMesh.indexCount, subMesh.verticesStart);
		if (collider.collisionFound) {
			collider.collidedMesh = this;
		}
	}

	inline public function _processCollisionsForSubMeshes(collider:Collider, transformMatrix:Matrix) {
		var subMeshes:Array<SubMesh>;
		var len:Int = 0;
		
		// Octrees
		if (this._submeshesOctree != null && this.useOctreeForCollisions) {
			var radius = collider.velocityWorldLength + Math.max(Math.max(collider.radius.x, collider.radius.y), collider.radius.z);
			var intersections = this._submeshesOctree.intersects(collider.basePointWorld, radius);
			
			len = intersections.length;
			subMeshes = cast intersections.data;
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
	}

	public function _checkCollision(collider:Collider) {
		// Bounding box test
		if (!this._boundingInfo._checkCollision(collider)) {
			return;
		}
			
		// Transformation matrix
		Matrix.ScalingToRef(1.0 / collider.radius.x, 1.0 / collider.radius.y, 1.0 / collider.radius.z, this._collisionsScalingMatrix);
		this.worldMatrixFromCache.multiplyToRef(this._collisionsScalingMatrix, this._collisionsTransformMatrix);
		
		this._processCollisionsForSubMeshes(collider, this._collisionsTransformMatrix);
	}

	// Picking
	public function _generatePointsArray():Bool {
		return false;
	}

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
			subMeshes = cast intersections.data;
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

	public function clone(name:String, newParent:Node = null, doNotCloneChildren:Bool = false):AbstractMesh {
		return null;
	}

	public function releaseSubMeshes() {
		if (this.subMeshes != null) {
			while (this.subMeshes.length > 0) {
				this.subMeshes[0].dispose();
			}
		} 
		else {
			this.subMeshes = new Array<SubMesh>();
		}
	}

	override public function dispose(doNotRecurse:Bool = false) {
		// Animations
        this.getScene().stopAnimation(this);
		
		// Physics
		if (this.getPhysicsImpostor() != PhysicsEngine.NoImpostor) {
			this.setPhysicsState(PhysicsEngine.NoImpostor);
		}
		
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
		}
		
		// Edges
		if (this._edgesRenderer != null) {
			this._edgesRenderer.dispose();
			this._edgesRenderer = null;
		}
		
		// SubMeshes
		this.releaseSubMeshes();
		
		// Remove from scene
		this.getScene().removeMesh(this);
		
		if (!doNotRecurse) {
			var index:Int = 0;
			while(index < this.getScene().particleSystems.length) {
				if (this.getScene().particleSystems[index].emitter == this) {
					this.getScene().particleSystems[index].dispose();
					index--;
				}
				++index;
			}
			
			// Children
			var objects = this.getScene().meshes.slice(0);
			for (index in 0...objects.length) {
				if (objects[index].parent == this) {
					objects[index].dispose();
				}
			}
		} 
		else {
			for (index in 0...this.getScene().meshes.length) {
				var obj = this.getScene().meshes[index];
				if (obj.parent == this) {
					obj.parent = null;
					obj.computeWorldMatrix(true);
				}
			}
		}
		
		this._onAfterWorldMatrixUpdate = [];
		
		this._isDisposed = true;
		
		// Callback
		if (this.onDispose != null) {
			this.onDispose();
		}
		
		super.dispose();
	}
	
}
