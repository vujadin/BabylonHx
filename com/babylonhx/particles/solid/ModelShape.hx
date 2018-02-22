package com.babylonhx.particles.solid;

import com.babylonhx.math.Vector3;

/**
 * ...
 * @author Krtolica Vujadin
 */
/**
 * Represents the shape of the model used by one particle of a solid particle system.
 * SPS internal tool, don't use it manually.
 * @see SolidParticleSystem
 */
class ModelShape {
	
	/**
	 * The shape id.
	 */
	public var shapeID:Int;
	/**
	 * flat array of model positions (internal use)
	 */
	public var _shape:Array<Vector3>;
	/**
	 * flat array of model UVs (internal use)
	 */
	public var _shapeUV:Array<Float>;	
	/**
	 * length of the shape in the model indices array (internal use)
	 */
	public var _indicesLength:Int = 0;
	/**
	 * Custom position function (internal use)
	 */
	public var _positionFunction:SolidParticle-> Int->Int->Void;
	/**
	 * Custom vertex function (internal use)
	 */
	public var _vertexFunction:SolidParticle->Vector3->Int->Void;
	

	/**
	 * Creates a ModelShape object. This is an internal simplified reference to a mesh used as for a model to replicate particles from by the SPS.
	 * SPS internal tool, don't use it manually.
	 * @ignore
	 */
	public function new(id:Int, shape:Array<Vector3>, indicesLength:Int, shapeUV:Array<Float>, posFunction:SolidParticle->Int->Int->Void, vtxFunction:SolidParticle->Vector3->Int->Void) {
		this.shapeID = id;
		this._shape = shape;
		this._indicesLength = indicesLength;
		this._shapeUV = shapeUV;
		this._positionFunction = posFunction;
		this._vertexFunction = vtxFunction;
	}
	
}
