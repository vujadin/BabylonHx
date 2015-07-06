package com.babylonhxext.loaders.obj;

import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PositionNormalTextured {
	
	public static inline var Stride:Int = 32;
	
	var pID:Int;
	var nID:Int;
	var tcID:Int;
	
	public var Position:Vector3;
	public var Normal:Vector3 = Vector3.Zero();
	public var TextureCoordinates:Vector2;
	

	public function new() {
		
	}
	
	public function ToString():String {
		return 'P:{$Position} N:{$Normal} TV:{$TextureCoordinates}';
	}
	
	public function GetPosition():Vector3 {
		return Position;
	}
	
	inline public function DumpPositions(list:Array<Float>) {
		if(Position != null) {
			list.push(Position.x);
			list.push(Position.y);
			list.push(Position.z);
		}
	}
	
	inline public function DumpNormals(list:Array<Float>) {
		Normal.normalize();
		list.push(Normal.x);
		list.push(Normal.y);
		list.push(Normal.z);
	}
	
	inline public function DumpUVs(list:Array<Float>) {
		if(TextureCoordinates != null) {
			list.push(TextureCoordinates.x);
			list.push(TextureCoordinates.y);
		}
	}
	
}