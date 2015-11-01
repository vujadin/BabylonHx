package com.babylonhx.particles;

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
	

	public function new(id:Int, shape:Array<Vector3>, shapeUV:Array<Float>, posFunction:SolidParticle->Int->Int->Void, vtxFunction:SolidParticle->Vector3->Int->Void) {
		this.shapeID = id;
		this._shape = shape;
		this._shapeUV = shapeUV;
		this._positionFunction = posFunction;
		this._vertexFunction = vtxFunction;
	}
	
}
