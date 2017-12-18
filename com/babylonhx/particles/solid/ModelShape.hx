package com.babylonhx.particles.solid;

import com.babylonhx.math.Vector3;

/**
 * ...
 * @author Krtolica Vujadin
 */
class ModelShape {
	
	public var shapeID:Int;
	public var _shape:Array<Vector3>;			// flat array of model positions
	public var _shapeUV:Array<Float>;			// flat array of model UVs
	public var _indicesLength:Int = 0;          // length of the shape in the model indices array
	public var _positionFunction:SolidParticle->Int->Int->Void;
	public var _vertexFunction:SolidParticle->Vector3->Int->Void;
	

	/**
     * Creates a ModelShape object. This is an internal simplified reference to a mesh used as for a model to replicate particles from by the SPS.
     * SPS internal tool, don't use it manually.  
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
