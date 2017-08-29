package com.babylonhx.particles.solidparticles;

import com.babylonhx.math.Vector3;

/**
 * ...
 * @author Krtolica Vujadin
 */
class ModelShape {
	
	public var shapeID:Int;
	public var _shape:Array<Vector3>;
	public var _shapeUV:Array<Float>;
	public var _positionFunction:SolidParticle->Int->Int->Void;
	public var _vertexFunction:SolidParticle->Vector3->Int->Void;
	

	/**
     * Creates a ModelShape object. This is an internal simplified reference to a mesh used as for a model to replicate particles from by the SPS.
     * SPS internal tool, don't use it manually.  
     */
	public function new(id:Int, shape:Array<Vector3>, shapeUV:Array<Float>, posFunction:SolidParticle->Int->Int->Void, vtxFunction:SolidParticle->Vector3->Int->Void) {
		this.shapeID = id;
		this._shape = shape;
		this._shapeUV = shapeUV;
		this._positionFunction = posFunction;
		this._vertexFunction = vtxFunction;
	}
	
}
