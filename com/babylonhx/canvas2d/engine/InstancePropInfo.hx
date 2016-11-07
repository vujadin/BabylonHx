package com.babylonhx.canvas2d.engine;

import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector4;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.tools.StringDictionary;
import com.babylonhx.utils.typedarray.Float32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
class InstancePropInfo {
	
	public var attributeName:String;
	public var category:String;
	public var size:Int;
	public var shaderOffset:Int;
	public var instanceOffset:StringDictionary<Int>;
	public var dataType:ShaderDataType;
	//uniformLocation: WebGLUniformLocation;

	public var delimitedCategory:String;
	

	public function new() {
		this.instanceOffset = new StringDictionary<Int>();
	}

	public function setSize(val:Dynamic) {
		if (Std.is(val, Vector2)) {
			this.size = 8;
			this.dataType = ShaderDataType.Vector2;
			return;
		}
		if (Std.is(val, Vector3)) {
			this.size = 12;
			this.dataType = ShaderDataType.Vector3;
			return;
		}
		if (Std.is(val, Vector4)) {
			this.size = 16;
			this.dataType = ShaderDataType.Vector4;
			return;
		}
		if (Std.is(val, Matrix)) {
			throw ("Matrix type is not supported by WebGL Instance Buffer, you have to use four Vector4 properties instead");
		}
		if (Std.is(val, Float)) {
			this.size = 4;
			this.dataType = ShaderDataType.float;
			return;
		}
		if (Std.is(val, Color3)) {
			this.size = 12;
			this.dataType = ShaderDataType.Color3;
			return;
		}
		if (Std.is(val, Color4)) {
			this.size = 16;
			this.dataType = ShaderDataType.Color4;
			return;
		}
		if (Std.is(val, Size)) {
			this.size = 8;
			this.dataType = ShaderDataType.Size;
			return;
		}            
	}

	public function writeData(array:Float32Array, offset:Int, val:Dynamic) {
		switch (this.dataType) {
			case ShaderDataType.Vector2:
				array[offset + 0] = untyped val.x;
				array[offset + 1] = untyped val.y;
				
			case ShaderDataType.Vector3:
				array[offset + 0] = untyped val.x;
				array[offset + 1] = untyped val.y;
				array[offset + 2] = untyped val.z;
				
			case ShaderDataType.Vector4:
				array[offset + 0] = untyped val.x;
				array[offset + 1] = untyped val.y;
				array[offset + 2] = untyped val.z;
				array[offset + 3] = untyped val.w;
				
			case ShaderDataType.Color3:
				array[offset + 0] = untyped val.r;
				array[offset + 1] = untyped val.g;
				array[offset + 2] = untyped val.b;
				
			case ShaderDataType.Color4:
				array[offset + 0] = untyped val.r;
				array[offset + 1] = untyped val.g;
				array[offset + 2] = untyped val.b;
				array[offset + 3] = untyped val.a;
				
			case ShaderDataType.float:
				array[offset] = v;
				
			case ShaderDataType.Matrix:
				var v:Matrix = cast val;
				for (i in 0...16) {
					array[offset + i] = v.m[i];
				}
				
			case ShaderDataType.Size:
				array[offset + 0] = untyped val.width;
				array[offset + 1] = untyped val.height;
				
		}
	}
	
}
