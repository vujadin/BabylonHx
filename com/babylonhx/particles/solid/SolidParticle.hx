package com.babylonhx.particles.solid;

import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector4;
import com.babylonhx.math.Quaternion;
import com.babylonhx.culling.BoundingInfo;
import com.babylonhx.culling.BoundingSphere;
import com.babylonhx.mesh.IHasBoundingInfo;


/**
 * ...
 * @author Krtolica Vujadin
 */
/**
 * Represents one particle of a solid particle system.
 * @see SolidParticleSystem
 */
class SolidParticle implements IHasBoundingInfo {
	
	/**
	 * particle global index
	 */
	public var idx:Int = 0;
	/**
	 * The color of the particle
	 */
	public var color:Color4 = new Color4(1.0, 1.0, 1.0, 1.0);
	/**
	 * The world space position of the particle.
	 */
	public var position:Vector3 = Vector3.Zero();
	/**
	 * The world space rotation of the particle. (Not use if rotationQuaternion is set)
	 */
	public var rotation:Vector3 = Vector3.Zero();
	/**
	 * The world space rotation quaternion of the particle.
	 */
	public var rotationQuaternion:Quaternion;
	/**
	 * The scaling of the particle.
	 */
	public var scaling:Vector3 = Vector3.One();
	/**
	 * The uvs of the particle.
	 */
	public var uvs:Vector4 = new Vector4(0.0, 0.0, 1.0, 1.0);
	/**
	 * The current speed of the particle.
	 */
	public var velocity:Vector3 = Vector3.Zero();
	/**
	 * The pivot point in the particle local space.
	 */
	public var pivot:Vector3 = Vector3.Zero();
	/**
	 * Must the particle be translated from its pivot point in its local space ?
	 * In this case, the pivot point is set at the origin of the particle local space and the particle is translated.  
	 * Default : false
	 */
	public var translateFromPivot:Bool = false;
	/**
	 * Is the particle active or not ?
	 */
	public var alive:Bool = true;
	/**
	 * Is the particle visible or not ?
	 */
	public var isVisible:Bool = true;
	/**
	 * Index of this particle in the global "positions" array (Internal use)
	 */
	public var _pos:Int = 0;
	/**
	 * Index of this particle in the global "indices" array (Internal use)
	 */
	public var _ind:Int = 0;
	/**
	 * ModelShape of this particle (Internal use)
	 */
	public var _model:ModelShape;
	/**
	 * ModelShape id of this particle
	 */
	public var shapeId:Int = 0;
	/**
	 * Index of the particle in its shape id (Internal use)
	 */
	public var idxInShape:Int = 0;
	/**
	 * Reference to the shape model BoundingInfo object (Internal use)
	 */
	public var _modelBoundingInfo:BoundingInfo;
	/**
	 * Particle BoundingInfo object (Internal use)
	 */
	public var _boundingInfo:BoundingInfo;
	/**
	 * Reference to the SPS what the particle belongs to (Internal use)
	 */
	public var _sps:SolidParticleSystem;
	/**
	 * Still set as invisible in order to skip useless computations (Internal use)
	 */
	public var _stillInvisible:Bool = false;
	/**
	 * Last computed particle rotation matrix
	 */
	public var _rotationMatrix:Array<Float> = [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0];
	/**
	 * Parent particle Id, if any.
	 * Default null.
	 */
	public var parentId:Null<Int> = null;
	/**
	 * Internal global position in the SPS.
	 */
	public var _globalPosition:Vector3 = Vector3.Zero();
	

	/**
	 * Creates a Solid Particle object.
	 * Don't create particles manually, use instead the Solid Particle System internal tools like _addParticle()
	 * `particleIndex` (integer) is the particle index in the Solid Particle System pool. It's also the particle identifier.  
	 * `positionIndex` (integer) is the starting index of the particle vertices in the SPS "positions" array.
	 * `indiceIndex` (integer) is the starting index of the particle indices in the SPS "indices" array.
	 * `model` (ModelShape) is a reference to the model shape on what the particle is designed.  
	 * `shapeId` (integer) is the model shape identifier in the SPS.
	 * `idxInShape` (integer) is the index of the particle in the current model (ex: the 10th box of addShape(box, 30))
	 * `modelBoundingInfo` is the reference to the model BoundingInfo used for intersection computations.
	 */
	public function new(?particleIndex:Int, ?positionIndex:Int, ?indiceIndex:Int, ?model:ModelShape, ?shapeId:Int, ?idxInShape:Int, ?sps:SolidParticleSystem, ?modelBoundingInfo:BoundingInfo) {
		this.idx = particleIndex;
		this._pos = positionIndex;
		this._ind = indiceIndex;
		this._model = model;
		this.shapeId = shapeId;
		this.idxInShape = idxInShape;
		this._sps = sps;
		if (modelBoundingInfo != null) {
			this._modelBoundingInfo = modelBoundingInfo;
			this._boundingInfo = new BoundingInfo(modelBoundingInfo.minimum, modelBoundingInfo.maximum);
		}
	}
	
	/**
	 * Returns a boolean. True if the particle intersects another particle or another mesh, else false.
	 * The intersection is computed on the particle bounding sphere and Axis Aligned Bounding Box (AABB)
	 * @param target is the object (solid particle or mesh) what the intersection is computed against.
	 * @returns true if it intersects
	 */
	public function intersectsMesh(target:IHasBoundingInfo):Bool {
		if (this._boundingInfo == null || target._boundingInfo == null) {
			return false;
		}
		if (this._sps._bSphereOnly) {
			return BoundingSphere.Intersects(this._boundingInfo.boundingSphere, target._boundingInfo.boundingSphere);
		}
		return this._boundingInfo.intersects(target._boundingInfo, false);
	}
	
}
