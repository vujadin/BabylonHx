package com.babylonhx.mesh;

import com.babylonhx.actions.ActionManager;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.cameras.Camera;
import com.babylonhx.collisions.Collider;
import com.babylonhx.collisions.IntersectionInfo;
import com.babylonhx.collisions.PickingInfo;
import com.babylonhx.culling.BoundingInfo;
import com.babylonhx.culling.BoundingSphere;
import com.babylonhx.culling.octrees.Octree;
import com.babylonhx.materials.Material;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Plane;
import com.babylonhx.math.Axis;
import com.babylonhx.math.Quaternion;
import com.babylonhx.math.Ray;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Frustum;
import com.babylonhx.physics.PhysicsEngine;
import com.babylonhx.physics.PhysicsBodyCreationOptions;

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
	public var rotation:Vector3 = new Vector3(0, 0, 0);
	public var rotationQuaternion:Quaternion;
	public var scaling:Vector3 = new Vector3(1, 1, 1);
	public var billboardMode:Int = AbstractMesh.BILLBOARDMODE_NONE;
	
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
	
	private var _isPickable:Bool = true;
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
	
	private var _checkCollisions:Bool = false;
	public var checkCollisions(get, set):Bool;
	private function get_checkCollisions():Bool {
		return _checkCollisions;
	}
	private function set_checkCollisions(val:Bool):Bool {
		_checkCollisions = val;
		return val;
	}	
	
	public var isBlocker:Bool = false;
	
	private var _skeleton:Skeleton;
	public var skeleton(get, set):Skeleton;
	private function get_skeleton():Skeleton {
		return _skeleton;
	}
	private function set_skeleton(val:Skeleton):Skeleton {
		_skeleton = val;
		return val;
	}	
	
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

	public var useOctreeForRenderingSelection:Bool = true;
	public var useOctreeForPicking:Bool = true;
	public var useOctreeForCollisions:Bool = true;

	public var layerMask:Int = 0x0FFFFFFF;

	// Physics
	public var _physicImpostor:Int = PhysicsEngine.NoImpostor;
	public var _physicsMass:Float = 0;
	public var _physicsFriction:Float = 0;
	public var _physicRestitution:Float = 0;

	// Collisions
	public var ellipsoid:Vector3 = new Vector3(0.5, 1, 0.5);
	public var ellipsoidOffset:Vector3 = new Vector3(0, 0, 0);
	private var _collider:Collider = new Collider();
	private var _oldPositionForCollisions:Vector3 = new Vector3(0, 0, 0);
	private var _diffPositionForCollisions:Vector3 = new Vector3(0, 0, 0);
	private var _newPositionForCollisions:Vector3 = new Vector3(0, 0, 0);

	// Cache
	private var _localScaling:Matrix = Matrix.Zero();
	private var _localRotation:Matrix = Matrix.Zero();
	private var _localTranslation:Matrix = Matrix.Zero();
	private var _localBillboard:Matrix = Matrix.Zero();
	private var _localPivotScaling:Matrix = Matrix.Zero();
	private var _localPivotScalingRotation:Matrix = Matrix.Zero();
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

	public var _boundingInfo:BoundingInfo;
	private var _pivotMatrix:Matrix = Matrix.Identity();
	public var _isDisposed:Bool = false;
	public var _renderId:Int = 0;

	public var subMeshes:Array<SubMesh>;
	public var _submeshesOctree:Octree<SubMesh>;
	public var _intersectionsInProgress:Array<AbstractMesh> = [];
	
	private var _onAfterWorldMatrixUpdate:Array<AbstractMesh->Void> = [];
	
	// Loading properties
	public var _waitingActions:Dynamic;
	

	public function new(name:String, scene:Scene) {
		super(name, scene);
		scene.addMesh(this);
	}

	// Methods
	private var _isBlocked:Bool;
	public var isBlocked(get, set):Bool;
	private function get_isBlocked():Bool {
		return false;
	}
	private function set_isBlocked(val:Bool):Bool {
		_isBlocked = val;
		return val;
	}

	public function getLOD(camera:Camera, ?boundingSphere:BoundingSphere):AbstractMesh {
		return this;
	}

	public function getTotalVertices():Int {
		return 0;
	}

	public function getIndices():Array<Int> {
		return null;
	}

	public function getVerticesData(kind:String):Array<Float> {
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

	public function _preActivate() {
		
	}

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

	public var worldMatrixFromCache(get, null):Matrix;
	private function get_worldMatrixFromCache():Matrix {
		return this._worldMatrix;
	}

	public var absolutePosition(get, null):Vector3;
	private function get_absolutePosition():Vector3 {
		return this._absolutePosition;
	}

	public function rotate(axis:Vector3, amount:Float, space:Space) {
		if (this.rotationQuaternion == null) {
			this.rotationQuaternion = Quaternion.RotationYawPitchRoll(this.rotation.y, this.rotation.x, this.rotation.z);
			this.rotation = Vector3.Zero();
		}
		
		if (space == null || space == Space.LOCAL) {
			var rotationQuaternion = Quaternion.RotationAxis(axis, amount);
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

	public function translate(axis:Vector3, distance:Float, space:Space) {
		var displacementVector = axis.scale(distance);
		
		if (space == null || space == Space.LOCAL) {
			var tempV3 = this.getPositionExpressedInLocalSpace().add(displacementVector);
			this.setPositionWithLocalVector(tempV3);
		}
		else {
			this.setAbsolutePosition(this.getAbsolutePosition().add(displacementVector));
		}
	}

	public function getAbsolutePosition():Vector3 {
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
        } else {	// its Vector3
            absolutePositionX = absolutePosition.x;
            absolutePositionY = absolutePosition.y;
            absolutePositionZ = absolutePosition.z;
        }
		
		if (this.parent != null) {
			var invertParentWorldMatrix = this.parent.getWorldMatrix().clone();
			invertParentWorldMatrix.invert();
			
			var worldPosition = new Vector3(absolutePositionX, absolutePositionY, absolutePositionZ);
			
			this.position = Vector3.TransformCoordinates(worldPosition, invertParentWorldMatrix);
		} else {
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
	public function movePOV(amountRight:Float, amountUp:Float, amountForward:Float) {
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
	public function rotatePOV(flipBack:Float, twirlClockwise:Float, tiltRight:Float) {
		this.rotation.addInPlace(this.calcRotatePOV(flipBack, twirlClockwise, tiltRight));
	}
	
	/**
	 * Calculate relative rotation change from the point of view of behind the front of the mesh.
	 * Supports definition of mesh facing forward or backward.
	 * @param {number} flipBack
	 * @param {number} twirlClockwise
	 * @param {number} tiltRight
	 */
	public function calcRotatePOV(flipBack:Float, twirlClockwise:Float, tiltRight:Float):Vector3 {
		var defForwardMult = this.definedFacingForward ? 1 : -1;
		return new Vector3(flipBack * defForwardMult, twirlClockwise, tiltRight * defForwardMult);
	}

	public function setPivotMatrix(matrix:Matrix) {
		this._pivotMatrix = matrix;
		this._cache.pivotMatrixUpdated = true;
	}

	public function getPivotMatrix():Matrix {
		return this._pivotMatrix;
	}

	override public function _isSynchronized():Bool {
		if (this._isDirty) {
			return false;
		}
		
		if (this.billboardMode != AbstractMesh.BILLBOARDMODE_NONE) {
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
			
		if (this.rotationQuaternion != null) {
			if (!this._cache.rotationQuaternion.equals(this.rotationQuaternion)) {
				return false;
			}
		} else {
			if (!this._cache.rotation.equals(this.rotation)) {
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
	}

	public function markAsDirty(property:String) {
		if (property == "rotation") {
			this.rotationQuaternion = null;
		}
		this._currentRenderId = cast Math.POSITIVE_INFINITY;
		this._isDirty = true;
	}

	public function _updateBoundingInfo() {
		this._boundingInfo = this._boundingInfo == null ? new BoundingInfo(this.absolutePosition, this.absolutePosition) : this._boundingInfo;
		
		this._boundingInfo._update(this.worldMatrixFromCache);
		
		this._updateSubMeshesBoundingInfo(this.worldMatrixFromCache);
	}
	
	public function _updateSubMeshesBoundingInfo(matrix:Matrix) {
		if (this.subMeshes == null) {
			return;
		}
		
		for (subIndex in 0...this.subMeshes.length) {
			var subMesh = this.subMeshes[subIndex];
			
			subMesh.updateBoundingInfo(matrix);
		}
	}

	public function computeWorldMatrix(force:Bool = false):Matrix {
		if (!force && (this._currentRenderId == this.getScene().getRenderId() || this.isSynchronized(true))) {
			return this._worldMatrix;
		}
		
		this._cache.position.copyFrom(this.position);
		this._cache.scaling.copyFrom(this.scaling);
		this._cache.pivotMatrixUpdated = false;
		this._currentRenderId = this.getScene().getRenderId();
		this._isDirty = false;
		
		// Scaling
		Matrix.ScalingToRef(this.scaling.x, this.scaling.y, this.scaling.z, this._localScaling);
		
		// Rotation
		if (this.rotationQuaternion != null) {
			this.rotationQuaternion.toRotationMatrix(this._localRotation);
			this._cache.rotationQuaternion.copyFrom(this.rotationQuaternion);
		} else {
			Matrix.RotationYawPitchRollToRef(this.rotation.y, this.rotation.x, this.rotation.z, this._localRotation);
			this._cache.rotation.copyFrom(this.rotation);
		}
		
		// Translation
		if (this.infiniteDistance && this.parent == null) {
			var camera = this.getScene().activeCamera;
			if(camera != null) {
				var cameraWorldMatrix = camera.getWorldMatrix();
				
				var cameraGlobalPosition = new Vector3(cameraWorldMatrix.m[12], cameraWorldMatrix.m[13], cameraWorldMatrix.m[14]);
				
				Matrix.TranslationToRef(this.position.x + cameraGlobalPosition.x, this.position.y + cameraGlobalPosition.y,
												this.position.z + cameraGlobalPosition.z, this._localTranslation);
			}
		} else {
			Matrix.TranslationToRef(this.position.x, this.position.y, this.position.z, this._localTranslation);
		}
		
		// Composing transformations
		this._pivotMatrix.multiplyToRef(this._localScaling, this._localPivotScaling);
		this._localPivotScaling.multiplyToRef(this._localRotation, this._localPivotScalingRotation);
		
		// Billboarding
		if (this.billboardMode != AbstractMesh.BILLBOARDMODE_NONE && this.getScene().activeCamera != null) {
			var localPosition = this.position.clone();
			var zero = this.getScene().activeCamera.position.clone();
			
			if (this.parent != null && Reflect.hasField(this.parent, "position")) {
				localPosition.addInPlace(Reflect.field(this.parent, "position"));
				Matrix.TranslationToRef(localPosition.x, localPosition.y, localPosition.z, this._localTranslation);
			}
			
			if ((this.billboardMode & AbstractMesh.BILLBOARDMODE_ALL) == AbstractMesh.BILLBOARDMODE_ALL) {
				zero = this.getScene().activeCamera.position;
			} else {
				if (this.billboardMode & AbstractMesh.BILLBOARDMODE_X != 0)
					zero.x = localPosition.x + Engine.Epsilon;
				if (this.billboardMode & AbstractMesh.BILLBOARDMODE_Y != 0)
					zero.y = localPosition.y + 0.001;
				if (this.billboardMode & AbstractMesh.BILLBOARDMODE_Z != 0)
					zero.z = localPosition.z + 0.001;
			}
			
			Matrix.LookAtLHToRef(localPosition, zero, Vector3.Up(), this._localBillboard);
			this._localBillboard.m[12] = this._localBillboard.m[13] = this._localBillboard.m[14] = 0;
			
			this._localBillboard.invert();
			
			this._localPivotScalingRotation.multiplyToRef(this._localBillboard, this._localWorld);
			this._rotateYByPI.multiplyToRef(this._localWorld, this._localPivotScalingRotation);
		}
		
		// Local world
		this._localPivotScalingRotation.multiplyToRef(this._localTranslation, this._localWorld);
		
		// Parent
		if (this.parent != null && this.parent.getWorldMatrix() != null && this.billboardMode == AbstractMesh.BILLBOARDMODE_NONE) {
			this._localWorld.multiplyToRef(this.parent.getWorldMatrix(), this._worldMatrix);
		} else {
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

	public function setPositionWithLocalVector(vector3:Vector3) {
		this.computeWorldMatrix();		
		this.position = Vector3.TransformNormal(vector3, this._localWorld);
	}

	public function getPositionExpressedInLocalSpace():Vector3 {
		this.computeWorldMatrix();
		var invLocalWorldMatrix = this._localWorld.clone();
		invLocalWorldMatrix.invert();
		
		return Vector3.TransformNormal(this.position, invLocalWorldMatrix);
	}

	public function locallyTranslate(vector3:Vector3) {
		this.computeWorldMatrix();
		this.position = Vector3.TransformCoordinates(vector3, this._localWorld);
	}

	public function lookAt(targetPoint:Vector3, yawCor:Float = 0, pitchCor:Float = 0, rollCor:Float = 0) {
		/// <summary>Orients a mesh towards a target point. Mesh must be drawn facing user.</summary>
		/// <param name="targetPoint" type="Vector3">The position (must be in same space as current mesh) to look at</param>
		/// <param name="yawCor" type="Number">optional yaw (y-axis) correction in radians</param>
		/// <param name="pitchCor" type="Number">optional pitch (x-axis) correction in radians</param>
		/// <param name="rollCor" type="Number">optional roll (z-axis) correction in radians</param>
		/// <returns>Mesh oriented towards targetMesh</returns>
		
		var dv = targetPoint.subtract(this.position);
		var yaw = -Math.atan2(dv.z, dv.x) - Math.PI / 2;
		var len = Math.sqrt(dv.x * dv.x + dv.z * dv.z);
		var pitch = Math.atan2(dv.y, len);
		this.rotationQuaternion = Quaternion.RotationYawPitchRoll(yaw + yawCor, pitch + pitchCor, rollCor);
	}

	public function isInFrustum(frustumPlanes:Array<Plane>):Bool {
		if (!this._boundingInfo.isInFrustum(frustumPlanes)) {
			return false;
		}
		
		return true;
	}

	public function isCompletelyInFrustum(?camera:Camera):Bool {
		if (camera == null) {
			camera = this.getScene().activeCamera;
		}
		
		var transformMatrix = camera.getViewMatrix().multiply(camera.getProjectionMatrix());
		
		if (!this._boundingInfo.isCompletelyInFrustum(Frustum.GetPlanes(transformMatrix))) {
			return false;
		}
		
		return true;
	}

	public function intersectsMesh(mesh:AbstractMesh, precise:Bool = false/*?precise:Bool*/):Bool {
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
	public function setPhysicsState(impostor:Int = PhysicsEngine.NoImpostor, ?options:PhysicsBodyCreationOptions):Dynamic {
		var physicsEngine = this.getScene().getPhysicsEngine();
		
		if (physicsEngine == null) {
			return null;
		}
						
		if (impostor == PhysicsEngine.NoImpostor) {
			physicsEngine._unregisterMesh(this);
			return null;
		}
		
		options.mass = options.mass == null ? 0 : options.mass;
		options.friction = options.friction == null ? 0.2 : options.friction;
		options.restitution = options.restitution == null ? 0.2 : options.restitution;
		
		this._physicImpostor = impostor;
		this._physicsMass = options.mass;
		this._physicsFriction = options.friction;
		this._physicRestitution = options.restitution;
		
		return physicsEngine._registerMesh(this, impostor, options);
	}

	public function getPhysicsImpostor():Int {
		return this._physicImpostor;
	}

	public function getPhysicsMass():Float {
		return this._physicsMass;
	}

	public function getPhysicsFriction():Float {
		return this._physicsFriction;
	}

	public function getPhysicsRestitution():Float {
		return this._physicRestitution;
	}

	public function applyImpulse(force:Vector3, contactPoint:Vector3) {
		if (this._physicImpostor == 0) {
			return;
		}
		
		this.getScene().getPhysicsEngine()._applyImpulse(this, force, contactPoint);
	}

	public function setPhysicsLinkWith(otherMesh:Mesh, pivot1:Vector3, pivot2:Vector3, ?options:Dynamic) {
		if (this._physicImpostor == 0) {
			return;
		}
		
		this.getScene().getPhysicsEngine()._createLink(this, otherMesh, pivot1, pivot2, options);
	}

	public function updatePhysicsBodyPosition() {
		if (this._physicImpostor == 0) {
			return;
		}
		
		this.getScene().getPhysicsEngine()._updateBodyPosition(this);
	}


	// Collisions
	public function moveWithCollisions(velocity:Vector3) {
		var globalPosition = this.getAbsolutePosition();
		
		globalPosition.subtractFromFloatsToRef(0, this.ellipsoid.y, 0, this._oldPositionForCollisions);
		this._oldPositionForCollisions.addInPlace(this.ellipsoidOffset);
		this._collider.radius = this.ellipsoid;
		
		this.getScene()._getNewPosition(this._oldPositionForCollisions, velocity, this._collider, 3, this._newPositionForCollisions, this);
		this._newPositionForCollisions.subtractToRef(this._oldPositionForCollisions, this._diffPositionForCollisions);
		
		if (this._diffPositionForCollisions.length() > Engine.CollisionsEpsilon) {
			this.position.addInPlace(this._diffPositionForCollisions);
		}
	}

	// Submeshes octree

	/**
	* This function will create an octree to help select the right submeshes for rendering, picking and collisions
	* Please note that you must have a decent number of submeshes to get performance improvements when using octree
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
	public function _collideForSubMesh(subMesh:SubMesh, transformMatrix:Matrix, collider:Collider) {
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
	}

	public function _processCollisionsForSubMeshes(collider:Collider, transformMatrix:Matrix) {
		var subMeshes:Array<SubMesh>;
		var len:Int = 0;
		
		// Octrees
		if (this._submeshesOctree != null && this.useOctreeForCollisions) {
			var radius = collider.velocityWorldLength + Math.max(Math.max(collider.radius.x, collider.radius.y), collider.radius.z);
			var intersections = this._submeshesOctree.intersects(collider.basePointWorld, radius);
			
			len = intersections.length;
			subMeshes = cast intersections.data;
		} else {
			subMeshes = this.subMeshes;
			len = subMeshes.length;
		}
		
		for (index in 0...len) {
			var subMesh = subMeshes[index];
			
			// Bounding test
			if (len > 1 && !subMesh._checkCollision(collider))
				continue;
				
			this._collideForSubMesh(subMesh, transformMatrix, collider);
		}
	}

	public function _checkCollision(collider:Collider) {
		// Bounding box test
		if (!this._boundingInfo._checkCollision(collider))
			return;
			
		// Transformation matrix
		Matrix.ScalingToRef(1.0 / collider.radius.x, 1.0 / collider.radius.y, 1.0 / collider.radius.z, this._collisionsScalingMatrix);
		this.worldMatrixFromCache.multiplyToRef(this._collisionsScalingMatrix, this._collisionsTransformMatrix);
		
		this._processCollisionsForSubMeshes(collider, this._collisionsTransformMatrix);
	}

	// Picking
	public function _generatePointsArray():Bool {
		return false;
	}

	public function intersects(ray:Ray, fastCheck:Bool = false/*?fastCheck:Bool*/):PickingInfo {
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
		} else {
			subMeshes = this.subMeshes;
			len = subMeshes.length;
		}
		
		for (index in 0...len) {
			var subMesh = subMeshes[index];
			
			// Bounding test
			if (len > 1 && !subMesh.canIntersects(ray))
				continue;
				
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
			//direction.normalize();
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
			return pickingInfo;
		}
		
		return pickingInfo;
	}

	public function clone(name:String, newParent:Node = null, doNotCloneChildren:Bool = false/*?doNotCloneChildren:Bool*/):AbstractMesh {
		return null;
	}

	public function releaseSubMeshes() {
		if (this.subMeshes != null) {
			while (this.subMeshes.length > 0) {
				this.subMeshes[0].dispose();
			}
		} else {
			this.subMeshes = new Array<SubMesh>();
		}
	}

	public function dispose(doNotRecurse:Bool = false/*?doNotRecurse:Bool*/) {
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
		
		// SubMeshes
		this.releaseSubMeshes();
		
		// Remove from scene
		this.getScene().removeMesh(this);
		
		if (!doNotRecurse) {
			// Particles
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
		} else {
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
	}
	
}
