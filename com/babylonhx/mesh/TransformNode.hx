package com.babylonhx.mesh;

import com.babylonhx.cameras.Camera;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Quaternion;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Space;
import com.babylonhx.math.Tmp;
import com.babylonhx.bones.Bone;
import com.babylonhx.tools.Observable;
import com.babylonhx.tools.EventState;
import com.babylonhx.tools.Tags;

/**
 * ...
 * @author Krtolica Vujadin
 */
class TransformNode extends Node {

	// Statics
	public static var BILLBOARDMODE_NONE:Int = 0;
	public static var BILLBOARDMODE_X:Int = 1;
	public static var BILLBOARDMODE_Y:Int = 2;
	public static var BILLBOARDMODE_Z:Int = 4;
	public static var BILLBOARDMODE_ALL:Int = 7;
	
	// Properties
	@serializeAsVector3()
	private var _rotation:Vector3 = Vector3.Zero();
	
	@serializeAsQuaternion()
	private var _rotationQuaternion:Quaternion = null;
	
	@serializeAsVector3()
	private var _scaling:Vector3 = Vector3.One();
	private var _isDirty:Bool = false;
	private var _transformToBoneReferal:TransformNode;
	
	@serialize()
	public var billboardMode:Int = TransformNode.BILLBOARDMODE_NONE;
	
	@serialize()
	public var scalingDeterminant:Float = 1;
	
	@serialize()
	public var infiniteDistance:Bool = false;
	
	@serializeAsVector3()
	public var position:Vector3 = Vector3.Zero();
	
	// Cache        
	public var _poseMatrix:Matrix = null;
	private var _localWorld:Matrix = Matrix.Zero();
	public var _worldMatrix:Matrix = Matrix.Zero();
	public var _worldMatrixDeterminant:Float = 0;
	private var _absolutePosition:Vector3 = Vector3.Zero();
	private var _pivotMatrix:Matrix = Matrix.Identity();
	private var _pivotMatrixInverse:Matrix;
	
	private var _postMultiplyPivotMatrix:Bool = false;        
	
	private var _isWorldMatrixFrozen:Bool = false;

	/**
	* An event triggered after the world matrix is updated
	* @type {BABYLON.Observable}
	*/
	public var onAfterWorldMatrixUpdateObservable:Observable<TransformNode> = new Observable<TransformNode>();        
	

	public function new(name:String, scene:Scene = null, isPure:Bool = true) {
		super(name, scene);
		
		if (isPure) {
			this.getScene().addTransformNode(this);
		}
	}        
	
	/**
	 * Rotation property : a Vector3 depicting the rotation value in radians around each local axis X, Y, Z. 
	 * If rotation quaternion is set, this Vector3 will (almost always) be the Zero vector!
	 * Default : (0.0, 0.0, 0.0)
	 */
	public var rotation(get, set):Vector3;
	private inline function get_rotation():Vector3 {
		return this._rotation;
	}
	private inline function set_rotation(newRotation:Vector3):Vector3 {
		return this._rotation = newRotation;
	}

	/**
	 * Scaling property : a Vector3 depicting the mesh scaling along each local axis X, Y, Z.  
	 * Default : (1.0, 1.0, 1.0)
	 */
	public var scaling(get, set):Vector3;
	function get_scaling():Vector3 {
		return this._scaling;
	}
	function set_scaling(newScaling:Vector3):Vector3 {
		return this._scaling = newScaling;
	}

	/**
	 * Rotation Quaternion property : this a Quaternion object depicting the mesh rotation by using a unit quaternion. 
	 * It's null by default.  
	 * If set, only the rotationQuaternion is then used to compute the mesh rotation and its property `.rotation\ is then ignored and set to (0.0, 0.0, 0.0)
	 */
	public var rotationQuaternion(get, set):Quaternion;
	private inline function get_rotationQuaternion():Quaternion {
		return this._rotationQuaternion;
	}
	private inline function set_rotationQuaternion(quaternion:Quaternion):Quaternion {
		this._rotationQuaternion = quaternion;
		//reset the rotation vector. 
		if (quaternion != null && this.rotation.length() > 0) {
			this.rotation.copyFromFloats(0.0, 0.0, 0.0);
		}
		return quaternion;
	}

	/**
	 * Returns the latest update of the World matrix
	 * Returns a Matrix.  
	 */
	override public function getWorldMatrix():Matrix {
		if (this._currentRenderId != this.getScene().getRenderId()) {
			this.computeWorldMatrix();
		}
		return this._worldMatrix;
	}
	
	/**
     * Returns the latest update of the World matrix determinant.
     */
    public function _getWorldMatrixDeterminant():Float {
        if (this._currentRenderId != this.getScene().getRenderId()) {
            this.computeWorldMatrix();
        }
        return this._worldMatrixDeterminant;
    }

	/**
	 * Returns directly the latest state of the mesh World matrix. 
	 * A Matrix is returned.    
	 */
	public var worldMatrixFromCache(get, never):Matrix;
	inline private function get_worldMatrixFromCache():Matrix {
		return this._worldMatrix;
	}

	/**
	 * Copies the paramater passed Matrix into the mesh Pose matrix.  
	 * Returns the AbstractMesh.  
	 */
	inline public function updatePoseMatrix(matrix:Matrix):TransformNode {
		this._poseMatrix.copyFrom(matrix);
		return this;
	}

	/**
	 * Returns the mesh Pose matrix.  
	 * Returned object : Matrix
	 */
	inline public function getPoseMatrix():Matrix {
		return this._poseMatrix;
	}
	
	override public function _isSynchronized():Bool {
		if (this._isDirty) {
			return false;
		}
		
		if (this.billboardMode != this._cache.billboardMode || this.billboardMode != TransformNode.BILLBOARDMODE_NONE) {
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
		}
		
		if (!this._cache.rotation.equals(this.rotation)) {
			return false;
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

	public function markAsDirty(property:String):TransformNode {
		if (property == "rotation") {
			this.rotationQuaternion = null;
		}
		this._currentRenderId = cast Math.POSITIVE_INFINITY;
		this._isDirty = true;
		return this;
	}        

	/**
	 * Returns the current mesh absolute position.
	 * Retuns a Vector3.
	 */
	public var absolutePosition(get, never):Vector3;
	private inline function get_absolutePosition():Vector3 {
		return this._absolutePosition;
	}

	/**
	 * Sets a new pivot matrix to the mesh.  
	 * Returns the AbstractMesh.
	*/
	public function setPivotMatrix(matrix:Matrix, postMultiplyPivotMatrix:Bool = false):TransformNode {
		this._pivotMatrix = matrix.clone();
		this._cache.pivotMatrixUpdated = true;
		this._postMultiplyPivotMatrix = postMultiplyPivotMatrix;
		
		if (this._postMultiplyPivotMatrix) {
			this._pivotMatrixInverse = Matrix.Invert(matrix);
		}
		return this;
	}

	/**
	 * Returns the mesh pivot matrix.
	 * Default : Identity.  
	 * A Matrix is returned.  
	 */
	inline public function getPivotMatrix():Matrix {
		return this._pivotMatrix;
	}

	/**
	 * Prevents the World matrix to be computed any longer.
	 * Returns the AbstractMesh.  
	 */
	public function freezeWorldMatrix():TransformNode {
		this._isWorldMatrixFrozen = false;  // no guarantee world is not already frozen, switch off temporarily
		this.computeWorldMatrix(true);
		this._isWorldMatrixFrozen = true;
		return this;
	}

	/**
	 * Allows back the World matrix computation. 
	 * Returns the AbstractMesh.  
	 */
	public function unfreezeWorldMatrix() {
		this._isWorldMatrixFrozen = false;
		this.computeWorldMatrix(true);
		return this;
	}

	/**
	 * True if the World matrix has been frozen.  
	 * Returns a boolean.  
	 */
	public var isWorldMatrixFrozen(get, never):Bool;
	private inline function get_isWorldMatrixFrozen():Bool {
		return this._isWorldMatrixFrozen;
	}

	/**
	 * Retuns the mesh absolute position in the World.  
	 * Returns a Vector3.
	 */
	inline public function getAbsolutePosition():Vector3 {
		this.computeWorldMatrix();
		return this._absolutePosition;
	}

	/**
	 * Sets the mesh absolute position in the World from a Vector3 or an Array(3).
	 * Returns the AbstractMesh.  
	 */
	public function setAbsolutePosition(absolutePosition:Dynamic):TransformNode {
		if (absolutePosition == null) {
			return this;
		}
		var absolutePositionX:Float = 0;
		var absolutePositionY:Float = 0;
		var absolutePositionZ:Float = 0;
		if (Std.is(absolutePosition, Array)) {
			if (untyped absolutePosition.length < 3) {
				return this;
			}
			absolutePositionX = absolutePosition[0];
			absolutePositionY = absolutePosition[1];
			absolutePositionZ = absolutePosition[2];
		}
		else if (Std.is(absolutePosition, Vector3)) {
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
		return this;
	}   

	/**
	 * Sets the mesh position in its local space.  
	 * Returns the AbstractMesh.  
	 */
	public function setPositionWithLocalVector(vector3:Vector3):TransformNode {
		this.computeWorldMatrix();
		this.position = Vector3.TransformNormal(vector3, this._localWorld);
		return this;
	}

	/**
	 * Returns the mesh position in the local space from the current World matrix values.
	 * Returns a new Vector3.
	 */
	public function getPositionExpressedInLocalSpace():Vector3 {
		this.computeWorldMatrix();
		var invLocalWorldMatrix = this._localWorld.clone();
		invLocalWorldMatrix.invert();
		
		return Vector3.TransformNormal(this.position, invLocalWorldMatrix);
	}

	/**
	 * Translates the mesh along the passed Vector3 in its local space.  
	 * Returns the AbstractMesh. 
	 */
	public function locallyTranslate(vector3:Vector3):TransformNode {
		this.computeWorldMatrix(true);
		this.position = Vector3.TransformCoordinates(vector3, this._localWorld);
		return this;
	}

	private static var _lookAtVectorCache:Vector3 = new Vector3(0, 0, 0);
	/**
     * Orients a mesh towards a target point. Mesh must be drawn facing user.
     * @param targetPoint the position (must be in same space as current mesh) to look at
     * @param yawCor optional yaw (y-axis) correction in radians
     * @param pitchCor optional pitch (x-axis) correction in radians
     * @param rollCor optional roll (z-axis) correction in radians
     * @param space the choosen space of the target
     * @returns the TransformNode. 
     */
	public function lookAt(targetPoint:Vector3, yawCor:Float = 0, pitchCor:Float = 0, rollCor:Float = 0, space:Int = Space.LOCAL):TransformNode {
		var dv = TransformNode._lookAtVectorCache;
		var pos = space == Space.LOCAL ? this.position : this.getAbsolutePosition();
		targetPoint.subtractToRef(pos, dv);
		var yaw = -Math.atan2(dv.z, dv.x) - Math.PI / 2;
		var len = Math.sqrt(dv.x * dv.x + dv.z * dv.z);
		var pitch = Math.atan2(dv.y, len);
		if (this.rotationQuaternion != null) {
            Quaternion.RotationYawPitchRollToRef(yaw + yawCor, pitch + pitchCor, rollCor, this.rotationQuaternion);
        }
        else {
            this.rotation.x = pitch + pitchCor;
            this.rotation.y = yaw + yawCor;
            this.rotation.z = rollCor;
        }
		return this;
	}        

	/**
	 * Returns a new Vector3 what is the localAxis, expressed in the mesh local space, rotated like the mesh.  
	 * This Vector3 is expressed in the World space.  
	 */
	public function getDirection(localAxis:Vector3):Vector3 {
		var result = Vector3.Zero();
		
		this.getDirectionToRef(localAxis, result);
		
		return result;
	}

	/**
	 * Sets the Vector3 "result" as the rotated Vector3 "localAxis" in the same rotation than the mesh.
	 * localAxis is expressed in the mesh local space.
	 * result is computed in the Wordl space from the mesh World matrix.  
	 * Returns the AbstractMesh.  
	 */
	inline public function getDirectionToRef(localAxis:Vector3, result:Vector3):TransformNode {
		Vector3.TransformNormalToRef(localAxis, this.getWorldMatrix(), result);
		return this;
	}

	public function setPivotPoint(point:Vector3, space:Int = Space.LOCAL):TransformNode {
		if (this.getScene().getRenderId() == 0) {
			this.computeWorldMatrix(true);
		}
		
		var wm = this.getWorldMatrix();
		
		if (space == Space.WORLD) {
			var tmat = Tmp.matrix[0];
			wm.invertToRef(tmat);
			point = Vector3.TransformCoordinates(point, tmat);
		}
		
		Vector3.TransformCoordinatesToRef(point, wm, this.position);
		this._pivotMatrix.m[12] = -point.x;
		this._pivotMatrix.m[13] = -point.y;
		this._pivotMatrix.m[14] = -point.z;
		this._cache.pivotMatrixUpdated = true;
		return this;
	}

	/**
	 * Returns a new Vector3 set with the mesh pivot point coordinates in the local space.  
	 */
	public function getPivotPoint():Vector3 {
		var point = Vector3.Zero();
		this.getPivotPointToRef(point);
		return point;
	}

	/**
	 * Sets the passed Vector3 "result" with the coordinates of the mesh pivot point in the local space.   
	 * Returns the AbstractMesh.   
	 */
	public function getPivotPointToRef(result:Vector3):TransformNode {
		result.x = -this._pivotMatrix.m[12];
		result.y = -this._pivotMatrix.m[13];
		result.z = -this._pivotMatrix.m[14];
		return this;
	}

	/**
	 * Returns a new Vector3 set with the mesh pivot point World coordinates.  
	 */
	public function getAbsolutePivotPoint():Vector3 {
		var point = Vector3.Zero();
		this.getAbsolutePivotPointToRef(point);
		return point;
	}

	/**
	 * Sets the Vector3 "result" coordinates with the mesh pivot point World coordinates.  
	 * Returns the AbstractMesh.  
	 */
	public function getAbsolutePivotPointToRef(result:Vector3):TransformNode {
		result.x = this._pivotMatrix.m[12];
		result.y = this._pivotMatrix.m[13];
		result.z = this._pivotMatrix.m[14];
		this.getPivotPointToRef(result);
		Vector3.TransformCoordinatesToRef(result, this.getWorldMatrix(), result);
		return this;
	}        

	/**
	 * Defines the passed mesh as the parent of the current mesh.  
	 * Returns the AbstractMesh.  
	 */
	public function setParent(?node:Node):TransformNode {
		if (node == null) {
			var rotation = Tmp.quaternion[0];
			var position = Tmp.vector3[0];
			var scale = Tmp.vector3[1];
			
			if(this.parent != null/* && this.parent.computeWorldMatrix*/) {
				this.parent.computeWorldMatrix(true);
			}
			this.computeWorldMatrix(true);              
			this.getWorldMatrix().decompose(scale, rotation, position);
			
			if (this.rotationQuaternion != null) {
				this.rotationQuaternion.copyFrom(rotation);
			} 
			else {
				rotation.toEulerAnglesToRef(this.rotation);
			}
			
			this.scaling.x = scale.x;
            this.scaling.y = scale.y;
            this.scaling.z = scale.z;
			
			this.position.x = position.x;
			this.position.y = position.y;
			this.position.z = position.z;
		} 
		else {
			var rotation = Tmp.quaternion[0];
			var position = Tmp.vector3[0];
			var scale = Tmp.vector3[1];
			var m0 = Tmp.matrix[0];
			var m1 = Tmp.matrix[1];
			var invParentMatrix = Tmp.matrix[2];
			
			this.computeWorldMatrix(true);
			node.getWorldMatrix().decompose(scale, rotation, position);
			
			rotation.toRotationMatrix(m0);
			m1.setTranslation(position);   
			m1.multiplyToRef(m0, m0);     
			m0.invertToRef(invParentMatrix);
			
			this.getWorldMatrix().multiplyToRef(invParentMatrix, m0);        
			m0.decompose(scale, rotation, position);
			
			if (this.rotationQuaternion != null) {
				this.rotationQuaternion.copyFrom(rotation);
			} 
			else {
				rotation.toEulerAnglesToRef(this.rotation);
			}
			
			node.getWorldMatrix().invertToRef(invParentMatrix);
			this.getWorldMatrix().multiplyToRef(invParentMatrix, m0);
			m0.decompose(scale, rotation, position);
			
			this.position.x = position.x;
			this.position.y = position.y;
			this.position.z = position.z;
		}
		
		this.parent = node;
		return this;
	}       
	
	private var _nonUniformScaling:Bool = false;
	public var nonUniformScaling(get, never):Bool;
	private inline function get_nonUniformScaling():Bool {
		return this._nonUniformScaling;
	}

	public function _updateNonUniformScalingState(value:Bool):Bool {
		if (this._nonUniformScaling == value) {
			return false;
		}
		
		this._nonUniformScaling = true;
		return true;
	}        

	/**
	 * Attach the current TransformNode to another TransformNode associated with a bone
	 * @param bone Bone affecting the TransformNode
	 * @param affectedTransformNode TransformNode associated with the bone 
	 */
	public function attachToBone(bone:Bone, affectedTransformNode:TransformNode):TransformNode {
		this._transformToBoneReferal = affectedTransformNode;
		this.parent = bone;
		
		if (bone.getWorldMatrix().determinant() < 0) {
			this.scalingDeterminant *= -1;
		}
		return this;
	}

	public function detachFromBone():TransformNode {
		if (this.parent == null) {
			return this;
		}
		
		if (this.parent.getWorldMatrix().determinant() < 0) {
			this.scalingDeterminant *= -1;
		}
		this._transformToBoneReferal = null;
		this.parent = null;
		return this;
	}        

	private static var _rotationAxisCache:Quaternion = new Quaternion();
	/**
	 * Rotates the mesh around the axis vector for the passed angle (amount) expressed in radians, in the given space.  
	 * space (default LOCAL) can be either BABYLON.Space.LOCAL, either BABYLON.Space.WORLD.
	 * Note that the property `rotationQuaternion` is then automatically updated and the property `rotation` is set to (0,0,0) and no longer used.  
	 * The passed axis is also normalized.  
	 * Returns the AbstractMesh.
	 */
	public function rotate(axis:Vector3, amount:Float, ?space:Int):TransformNode {
		axis.normalize();
		if (this.rotationQuaternion == null) {
			this.rotationQuaternion = Quaternion.RotationYawPitchRoll(this.rotation.y, this.rotation.x, this.rotation.z);
			this.rotation = Vector3.Zero();
		}
		var rotationQuaternion:Quaternion = null;
		if (space == null || space == Space.LOCAL) {
			rotationQuaternion = Quaternion.RotationAxisToRef(axis, amount, TransformNode._rotationAxisCache);
			this.rotationQuaternion.multiplyToRef(rotationQuaternion, this.rotationQuaternion);
		}
		else {
			if (this.parent != null) {
				var invertParentWorldMatrix = this.parent.getWorldMatrix().clone();
				invertParentWorldMatrix.invert();
				axis = Vector3.TransformNormal(axis, invertParentWorldMatrix);
			}
			rotationQuaternion = Quaternion.RotationAxisToRef(axis, amount, TransformNode._rotationAxisCache);
			rotationQuaternion.multiplyToRef(this.rotationQuaternion, this.rotationQuaternion);
		}
		return this;
	}

	/**
	 * Rotates the mesh around the axis vector for the passed angle (amount) expressed in radians, in world space.  
	 * Note that the property `rotationQuaternion` is then automatically updated and the property `rotation` is set to (0,0,0) and no longer used.  
	 * The passed axis is also normalized.  
	 * Returns the AbstractMesh.
	 * Method is based on http://www.euclideanspace.com/maths/geometry/affine/aroundPoint/index.htm
	 */
	public function rotateAround(point:Vector3, axis:Vector3, amount:Float):TransformNode {
		axis.normalize();
		if (this.rotationQuaternion == null) {
			this.rotationQuaternion = Quaternion.RotationYawPitchRoll(this.rotation.y, this.rotation.x, this.rotation.z);
			this.rotation.copyFromFloats(0, 0, 0);
		}
		point.subtractToRef(this.position, Tmp.vector3[0]);
		Matrix.TranslationToRef(Tmp.vector3[0].x, Tmp.vector3[0].y, Tmp.vector3[0].z, Tmp.matrix[0]);
		Tmp.matrix[0].invertToRef(Tmp.matrix[2]);
		Matrix.RotationAxisToRef(axis, amount, Tmp.matrix[1]);
		Tmp.matrix[2].multiplyToRef(Tmp.matrix[1], Tmp.matrix[2]);
		Tmp.matrix[2].multiplyToRef(Tmp.matrix[0], Tmp.matrix[2]);
		
		Tmp.matrix[2].decompose(Tmp.vector3[0], Tmp.quaternion[0], Tmp.vector3[1]);
		
		this.position.addInPlace(Tmp.vector3[1]);
		Tmp.quaternion[0].multiplyToRef(this.rotationQuaternion, this.rotationQuaternion);
		
		return this;
	}

	/**
	 * Translates the mesh along the axis vector for the passed distance in the given space.  
	 * space (default LOCAL) can be either BABYLON.Space.LOCAL, either BABYLON.Space.WORLD.
	 * Returns the AbstractMesh.
	 */
	public function translate(axis:Vector3, distance:Float, ?space:Int):TransformNode {
		var displacementVector = axis.scale(distance);
		if (space == null || space == Space.LOCAL) {
			var tempV3 = this.getPositionExpressedInLocalSpace().add(displacementVector);
			this.setPositionWithLocalVector(tempV3);
		}
		else {
			this.setAbsolutePosition(this.getAbsolutePosition().add(displacementVector));
		}
		return this;
	}

	/**
	 * Adds a rotation step to the mesh current rotation.  
	 * x, y, z are Euler angles expressed in radians.  
	 * This methods updates the current mesh rotation, either mesh.rotation, either mesh.rotationQuaternion if it's set.  
	 * This means this rotation is made in the mesh local space only.   
	 * It's useful to set a custom rotation order different from the BJS standard one YXZ.  
	 * Example : this rotates the mesh first around its local X axis, then around its local Z axis, finally around its local Y axis.  
	 * ```javascript
	 * mesh.addRotation(x1, 0, 0).addRotation(0, 0, z2).addRotation(0, 0, y3);
	 * ```
	 * Note that `addRotation()` accumulates the passed rotation values to the current ones and computes the .rotation or .rotationQuaternion updated values.  
	 * Under the hood, only quaternions are used. So it's a little faster is you use .rotationQuaternion because it doesn't need to translate them back to Euler angles.   
	 * Returns the AbstractMesh.  
	 */
	public function addRotation(x:Float, y:Float, z:Float):TransformNode {
		var rotationQuaternion:Quaternion = null;
		if (this.rotationQuaternion != null) {
			rotationQuaternion = this.rotationQuaternion;
		}
		else {
			rotationQuaternion = Tmp.quaternion[1];
			Quaternion.RotationYawPitchRollToRef(this.rotation.y, this.rotation.x, this.rotation.z, rotationQuaternion);
		}
		var accumulation = Tmp.quaternion[0];
		Quaternion.RotationYawPitchRollToRef(y, x, z, accumulation);
		rotationQuaternion.multiplyInPlace(accumulation);
		if (this.rotationQuaternion == null) {
			rotationQuaternion.toEulerAnglesToRef(this.rotation);
		}
		return this;
	}        
	
	/**
	 * Computes the mesh World matrix and returns it.  
	 * If the mesh world matrix is frozen, this computation does nothing more than returning the last frozen values.  
	 * If the parameter `force` is let to `false` (default), the current cached World matrix is returned. 
	 * If the parameter `force`is set to `true`, the actual computation is done.  
	 * Returns the mesh World Matrix.
	 */
	override public function computeWorldMatrix(force:Bool = false):Matrix {
		if (this._isWorldMatrixFrozen) {
			return this._worldMatrix;
		}
		
		if (!force && this.isSynchronized(true)) {
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
		var camera:Camera = this.getScene().activeCamera;
		
		if (this.infiniteDistance && this.parent == null && camera != null) {			
			var cameraWorldMatrix = camera.getWorldMatrix();
			
			var cameraGlobalPosition = new Vector3(cameraWorldMatrix.m[12], cameraWorldMatrix.m[13], cameraWorldMatrix.m[14]);
			
			Matrix.TranslationToRef(this.position.x + cameraGlobalPosition.x, this.position.y + cameraGlobalPosition.y,
				this.position.z + cameraGlobalPosition.z, Tmp.matrix[2]);
		} 
		else {
			Matrix.TranslationToRef(this.position.x, this.position.y, this.position.z, Tmp.matrix[2]);
		}
		
		// Composing transformations
		this._pivotMatrix.multiplyToRef(Tmp.matrix[1], Tmp.matrix[4]);
		Tmp.matrix[4].multiplyToRef(Tmp.matrix[0], Tmp.matrix[5]);
		
		// Billboarding (testing PG:http://www.babylonjs-playground.com/#UJEIL#13)
		if (this.billboardMode != TransformNode.BILLBOARDMODE_NONE && camera != null) {
			if ((this.billboardMode & TransformNode.BILLBOARDMODE_ALL) != TransformNode.BILLBOARDMODE_ALL) {
				// Need to decompose each rotation here
				var currentPosition = Tmp.vector3[3];
				
				if (this.parent != null && this.parent.getWorldMatrix() != null) {
					if (this._transformToBoneReferal != null) {
						this.parent.getWorldMatrix().multiplyToRef(this._transformToBoneReferal.getWorldMatrix(), Tmp.matrix[6]);
						Vector3.TransformCoordinatesToRef(this.position, Tmp.matrix[6], currentPosition);
					} 
					else {
						Vector3.TransformCoordinatesToRef(this.position, this.parent.getWorldMatrix(), currentPosition);
					}
				} 
				else {
					currentPosition.copyFrom(this.position);
				}
				
				currentPosition.subtractInPlace(camera.globalPosition);
				
				var finalEuler = Tmp.vector3[4].copyFromFloats(0, 0, 0);
				if ((this.billboardMode & TransformNode.BILLBOARDMODE_X) == TransformNode.BILLBOARDMODE_X) {
					finalEuler.x = Math.atan2(-currentPosition.y, currentPosition.z);
				}
				
				if ((this.billboardMode & TransformNode.BILLBOARDMODE_Y) == TransformNode.BILLBOARDMODE_Y) {
					finalEuler.y = Math.atan2(currentPosition.x, currentPosition.z);
				}
				
				if ((this.billboardMode & TransformNode.BILLBOARDMODE_Z) == TransformNode.BILLBOARDMODE_Z) {
					finalEuler.z = Math.atan2(currentPosition.y, currentPosition.x);
				}
				
				Matrix.RotationYawPitchRollToRef(finalEuler.y, finalEuler.x, finalEuler.z, Tmp.matrix[0]);
			} 
			else {
				Tmp.matrix[1].copyFrom(camera.getViewMatrix());
				
				Tmp.matrix[1].setTranslationFromFloats(0, 0, 0);
				Tmp.matrix[1].invertToRef(Tmp.matrix[0]);
			}
			
			Tmp.matrix[1].copyFrom(Tmp.matrix[5]);
			Tmp.matrix[1].multiplyToRef(Tmp.matrix[0], Tmp.matrix[5]);
		}
		
		// Local world
		Tmp.matrix[5].multiplyToRef(Tmp.matrix[2], this._localWorld);
		
		// Parent
		if (this.parent != null /*&& this.parent.getWorldMatrix*/) {	// VK TODO: Reflect.hasField(this.parent, "getWorldMatrix") ?????
			if (this.billboardMode != TransformNode.BILLBOARDMODE_NONE) {
				if (this._transformToBoneReferal != null) {
					this.parent.getWorldMatrix().multiplyToRef(this._transformToBoneReferal.getWorldMatrix(), Tmp.matrix[6]);
					Tmp.matrix[5].copyFrom(Tmp.matrix[6]);
				} 
				else {
					Tmp.matrix[5].copyFrom(this.parent.getWorldMatrix());
				}
				
				this._localWorld.getTranslationToRef(Tmp.vector3[5]);
				Vector3.TransformCoordinatesToRef(Tmp.vector3[5], Tmp.matrix[5], Tmp.vector3[5]);
				this._worldMatrix.copyFrom(this._localWorld);
				this._worldMatrix.setTranslation(Tmp.vector3[5]);
			} 
			else {
				if (this._transformToBoneReferal != null) {
					this._localWorld.multiplyToRef(this.parent.getWorldMatrix(), Tmp.matrix[6]);
					Tmp.matrix[6].multiplyToRef(this._transformToBoneReferal.getWorldMatrix(), this._worldMatrix);
				} 
				else {
					this._localWorld.multiplyToRef(this.parent.getWorldMatrix(), this._worldMatrix);
				}
			}
			this._markSyncedWithParent();
		} 
		else {
			this._worldMatrix.copyFrom(this._localWorld);
		}
		
		// Post multiply inverse of pivotMatrix
		if (this._postMultiplyPivotMatrix) {
			this._worldMatrix.multiplyToRef(this._pivotMatrixInverse, this._worldMatrix);
		}
		
		// Normal matrix
		if (this.scaling.isNonUniform) {
			this._updateNonUniformScalingState(true);
		} 
		else if (this.parent != null && Std.is(this.parent, TransformNode) && untyped this.parent._nonUniformScaling) {
			this._updateNonUniformScalingState(untyped this.parent._nonUniformScaling);
		} 
		else {
			this._updateNonUniformScalingState(false);
		}
		
		this._afterComputeWorldMatrix();
		
		// Absolute position
		this._absolutePosition.copyFromFloats(this._worldMatrix.m[12], this._worldMatrix.m[13], this._worldMatrix.m[14]);
		
		// Callbacks
		this.onAfterWorldMatrixUpdateObservable.notifyObservers(this);
		
		if (this._poseMatrix == null) {
			this._poseMatrix = Matrix.Invert(this._worldMatrix);
		}
		
		// Cache the determinant
        this._worldMatrixDeterminant = this._worldMatrix.determinant();
		
		return this._worldMatrix;
	}   

	private function _afterComputeWorldMatrix() {
	}

	/**
	* If you'd like to be called back after the mesh position, rotation or scaling has been updated.  
	* @param func: callback function to add
	*
	* Returns the TransformNode. 
	*/
	public function registerAfterWorldMatrixUpdate(func:TransformNode->Null<EventState>->Void):TransformNode {
		this.onAfterWorldMatrixUpdateObservable.add(func);
		return this;
	}

	/**
	 * Removes a registered callback function.  
	 * Returns the TransformNode.
	 */
	public function unregisterAfterWorldMatrixUpdate(func:TransformNode->Null<EventState>->Void):TransformNode {
		this.onAfterWorldMatrixUpdateObservable.removeCallback(func);
		return this;
	}        

	/**
	 * Clone the current transform node
	 * Returns the new transform node
	 * @param name Name of the new clone
	 * @param newParent New parent for the clone
	 * @param doNotCloneChildren Do not clone children hierarchy
	 */
	public function clone(name:String, newParent:Node = null, doNotCloneChildren:Bool = false):TransformNode {
		/*var result = SerializationHelper.Clone(() => new TransformNode(name, this.getScene()), this);

		result.name = name;
		result.id = name;

		if (newParent) {
			result.parent = newParent;
		}

		if (!doNotCloneChildren) {
			// Children
			let directDescendants = this.getDescendants(true);
			for (let index = 0; index < directDescendants.length; index++) {
				var child = directDescendants[index];

				if ((<any>child).clone) {
					(<any>child).clone(name + "." + child.name, result);
				}
			}
		}*/
		return null;
	}        

	public function serialize(?serializationObject:Dynamic):Dynamic {
		if (serializationObject == null) {
			serializationObject = { };
		}
		
		serializationObject.name = this.name;
		serializationObject.id = this.id;
		serializationObject.type = this.getClassName();
		
		if (Tags.HasTags(this)) {
			serializationObject.tags = Tags.GetTags(this);
		}
		
		serializationObject.position = this.position.asArray();
		
		if (this.rotationQuaternion != null) {
			serializationObject.rotationQuaternion = this.rotationQuaternion.asArray();
		} 
		else if (this.rotation != null) {
			serializationObject.rotation = this.rotation.asArray();
		}
		
		serializationObject.scaling = this.scaling.asArray();
		serializationObject.localMatrix = this.getPivotMatrix().asArray();
		
		serializationObject.isEnabled = this.isEnabled();
		serializationObject.infiniteDistance = this.infiniteDistance;
		
		serializationObject.billboardMode = this.billboardMode;
		
		// Parent
		if (this.parent != null) {
			serializationObject.parentId = this.parent.id;
		}
		
		// Metadata
		if (this.metadata != null) {
			serializationObject.metadata = this.metadata;
		}
		
		return serializationObject;
	}

	// Statics
	/**
	 * Returns a new TransformNode object parsed from the source provided.   
	 * The parameter `parsedMesh` is the source.   
	 * The parameter `rootUrl` is a string, it's the root URL to prefix the `delayLoadingFile` property with
	 */
	public static function Parse(parsedTransformNode:Dynamic, scene:Scene, rootUrl:String):TransformNode {
		var transformNode = new TransformNode(parsedTransformNode.name, scene);
		
		transformNode.id = parsedTransformNode.id;
		
		if (parsedTransformNode.tags != null) {
			Tags.AddTagsTo(transformNode, parsedTransformNode.tags);
		}
		
		transformNode.position = Vector3.FromArray(parsedTransformNode.position);
		
		if (parsedTransformNode.metadata != null) {
			transformNode.metadata = parsedTransformNode.metadata;
		}
		
		if (parsedTransformNode.rotationQuaternion != null) {
			transformNode.rotationQuaternion = Quaternion.FromArray(parsedTransformNode.rotationQuaternion);
		} 
		else if (parsedTransformNode.rotation != null) {
			transformNode.rotation = Vector3.FromArray(parsedTransformNode.rotation);
		}
		
		transformNode.scaling = Vector3.FromArray(parsedTransformNode.scaling);
		
		if (parsedTransformNode.localMatrix != null) {
			transformNode.setPivotMatrix(Matrix.FromArray(parsedTransformNode.localMatrix));
		} 
		else if (parsedTransformNode.pivotMatrix != null) {
			transformNode.setPivotMatrix(Matrix.FromArray(parsedTransformNode.pivotMatrix));
		}
		
		transformNode.setEnabled(parsedTransformNode.isEnabled);
		transformNode.infiniteDistance = parsedTransformNode.infiniteDistance;
		
		transformNode.billboardMode = parsedTransformNode.billboardMode;
		
		// Parent
		if (parsedTransformNode.parentId != null) {
			transformNode._waitingParentId = parsedTransformNode.parentId;
		}
		
		return transformNode;
	}
	
	/**
	 * Disposes the TransformNode.  
	 * By default, all the children are also disposed unless the parameter `doNotRecurse` is set to `true`.  
	 * Returns nothing.  
	 */
	override public function dispose(doNotRecurse:Bool = false) {
		// Animations
		this.getScene().stopAnimation(this);
		
		// Remove from scene
		this.getScene().removeTransformNode(this);
		
		if (!doNotRecurse) {
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
		
		this.onAfterWorldMatrixUpdateObservable.clear();
		
		super.dispose();
	}
	
}
