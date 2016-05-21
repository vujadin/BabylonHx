package com.babylonhx.particles;

import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector4;
import com.babylonhx.math.Quaternion;


/**
 * ...
 * @author Krtolica Vujadin
 */
class SolidParticle {
	
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
	public var _model:ModelShape;							// model shape reference
	public var shapeId:Int;                 				// model shape id
	public var idxInShape:Int;              				// index of the particle in its shape id
	
	public var extraFields:Map<String, Float>;
	

	public function new(?particleIndex:Int, ?positionIndex:Int, ?model:ModelShape, ?shapeId:Int, ?idxInShape:Int) {
		this.idx = particleIndex;
		this._pos = positionIndex;
		this._model = model;
		this.shapeId = shapeId;
		this.idxInShape = idxInShape;
		
		extraFields = new Map();
	}
	
}
