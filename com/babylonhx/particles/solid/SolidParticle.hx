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
class SolidParticle implements IHasBoundingInfo {
	
	public var idx:Int;                     				// particle global index
	public var color:Color4 = new Color4(1, 1, 1, 1);  		// color
	public var position:Vector3 = Vector3.Zero();       	// position
	public var rotation:Vector3 = Vector3.Zero();       	// rotation
	public var rotationQuaternion:Quaternion;    			// quaternion, will overwrite rotation
	public var scaling:Vector3 = new Vector3(1, 1, 1);  	// scaling
	public var uvs:Vector4 = new Vector4(0, 0, 1, 1);   	// uvs
	public var velocity:Vector3 = Vector3.Zero();       	// velocity
	public var alive:Bool = true;                    		// alive
	public var isVisible:Bool = true;                		// visibility
	public var _pos:Int;                    				// index of this particle in the global "positions" array
	public var _ind:Int = 0;                        		// index of this particle in the global "indices" array
	public var _model:ModelShape;							// model shape reference
	public var shapeId:Int;                 				// model shape id
	public var idxInShape:Int;              				// index of the particle in its shape id
	public var _modelBoundingInfo:BoundingInfo;        		// reference to the shape model BoundingInfo object
    public var _boundingInfo:BoundingInfo;             		// particle BoundingInfo
	public var _sps:SolidParticleSystem;               		// reference to the SPS what the particle belongs to
	public var _stillInvisible:Bool = false;         		// still set as invisible in order to skip useless computations
	

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
		if (indiceIndex != null) {
			this._ind = indiceIndex;
		}
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
	 * `target` is the object (solid particle or mesh) what the intersection is computed against.
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
