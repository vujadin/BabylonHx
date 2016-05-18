package com.babylonhx.materials;

import com.babylonhx.math.Color3;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.FresnelParameters') class FresnelParameters {
	
	public var isEnabled:Bool = true;
	public var leftColor:Color3 = Color3.White();
	public var rightColor:Color3 = Color3.Black();
	public var bias:Float = 0;
	public var power:Float = 1;
	
	
	public function new() {
		
	}
	
	public function clone():FresnelParameters {
		var newFresnelParameters = new FresnelParameters();
		
		newFresnelParameters.isEnabled = this.isEnabled;
		newFresnelParameters.leftColor = this.leftColor;
		newFresnelParameters.rightColor = this.rightColor;
		newFresnelParameters.bias = this.bias;
		newFresnelParameters.power = this.power;
		
		return newFresnelParameters;
	}
	
	public function serialize():Dynamic {
		var serializationObject:Dynamic = { };
		
		serializationObject.isEnabled = this.isEnabled;
		serializationObject.leftColor = this.leftColor;
		serializationObject.rightColor = this.rightColor;
		serializationObject.bias = this.bias;
		serializationObject.power = this.power;
		
		return serializationObject;
	}
	
	public static function Parse(parsedFresnelParameters:Dynamic):FresnelParameters {
		var fresnelParameters = new FresnelParameters();
		
		fresnelParameters.isEnabled = parsedFresnelParameters.isEnabled;
		fresnelParameters.leftColor = Color3.FromArray(parsedFresnelParameters.leftColor);
		fresnelParameters.rightColor = Color3.FromArray(parsedFresnelParameters.rightColor);
		fresnelParameters.bias = parsedFresnelParameters.bias;
		fresnelParameters.power = parsedFresnelParameters.power != null ? parsedFresnelParameters.power : 1.0;
		
		return fresnelParameters;
	}
	
}
