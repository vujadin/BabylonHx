package com.babylonhx.animations;

import com.babylonhx.animations.easing.EasingFunction;
import com.babylonhx.animations.easing.IEasingFunction;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Quaternion;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.AbstractMesh;

/**
* ...
* @author Krtolica Vujadin
*/

@:expose('BABYLON.BabylonFrame') typedef BabylonFrame = {
	frame:Int,
	value:Dynamic			// Vector3 or Quaternion or Matrix or Float or Color3 or Vector2
}

@:expose('BABYLON.Animation') class Animation {
	
	public static var ANIMATIONTYPE_FLOAT:Int = 0;
	public static var ANIMATIONTYPE_VECTOR3:Int = 1;
	public static var ANIMATIONTYPE_QUATERNION:Int = 2;
	public static var ANIMATIONTYPE_MATRIX:Int = 3;
	public static var ANIMATIONTYPE_COLOR3:Int = 4;
	public static var ANIMATIONTYPE_VECTOR2:Int = 5;

	public static var ANIMATIONLOOPMODE_RELATIVE:Int = 0;
	public static var ANIMATIONLOOPMODE_CYCLE:Int = 1;
	public static var ANIMATIONLOOPMODE_CONSTANT:Int = 2;
	
	private var _keys:Array<BabylonFrame>;
	private var _offsetsCache:Array<Dynamic> = [];// { };
	private var _highLimitsCache:Array<Dynamic> = []; // { };
	private var _stopped:Bool = false;
	private var _easingFunction:IEasingFunction;
	public var _target:Dynamic;

	public var name:String;
	public var targetProperty:String;
	public var targetPropertyPath:Array<String>;
	public var framePerSecond:Int;
	public var dataType:Int;
	public var loopMode:Int;
	public var currentFrame:Int;
	
	
	public static function CreateAndStartAnimation(name:String, mesh:AbstractMesh, tartgetProperty:String, framePerSecond:Int, totalFrame:Int,
		from:Dynamic, to:Dynamic, ?loopMode:Int):Animatable {
		
		var dataType:Int = -1;
		
		if (Std.is(from, Float)) {
			dataType = Animation.ANIMATIONTYPE_FLOAT;
		} else if (Std.is(from, Quaternion)) {
			dataType = Animation.ANIMATIONTYPE_QUATERNION;
		} else if (Std.is(from, Vector3)) {
			dataType = Animation.ANIMATIONTYPE_VECTOR3;
		} else if (Std.is(from, Vector2)) {
			dataType = Animation.ANIMATIONTYPE_VECTOR2;
		} else if (Std.is(from, Color3)) {
			dataType = Animation.ANIMATIONTYPE_COLOR3;
		}
		
		if (dataType == -1) {
			return null;
		}
		
		var animation = new Animation(name, tartgetProperty, framePerSecond, dataType, loopMode);
		
		var keys:Array<BabylonFrame> = [];
		keys.push({ frame: 0, value: from });
		keys.push({ frame: totalFrame, value: to });
		animation.setKeys(keys);
		
		mesh.animations.push(animation);
		
		return mesh.getScene().beginAnimation(mesh, 0, totalFrame, (animation.loopMode == 1));
	}

	public function new(name:String, targetProperty:String, framePerSecond:Int, dataType:Int, loopMode:Int = -1) {
		this.name = name;
        this.targetProperty = targetProperty;
        this.targetPropertyPath = targetProperty.split(".");
        this.framePerSecond = framePerSecond;
        this.dataType = dataType;
		this.loopMode = loopMode == -1 ? Animation.ANIMATIONLOOPMODE_CYCLE : loopMode;
	}

	// Methods   
	public function isStopped():Bool {
		return this._stopped;
	}

	public function getKeys():Array<BabylonFrame> {
		return this._keys;
	}
	
	public function getEasingFunction() {
        return this._easingFunction;
    }

    public function setEasingFunction(easingFunction:EasingFunction) {
        this._easingFunction = easingFunction;
	}

	public function floatInterpolateFunction(startValue:Float, endValue:Float, gradient:Float):Float {
		return startValue + (endValue - startValue) * gradient;
	}

	public function quaternionInterpolateFunction(startValue:Quaternion, endValue:Quaternion, gradient:Float):Quaternion {
		return Quaternion.Slerp(startValue, endValue, gradient);
	}

	public function vector3InterpolateFunction(startValue:Vector3, endValue:Vector3, gradient:Float):Vector3 {
		return Vector3.Lerp(startValue, endValue, gradient);
	}

	public function vector2InterpolateFunction(startValue:Vector2, endValue:Vector2, gradient:Float):Vector2 {
		return Vector2.Lerp(startValue, endValue, gradient);
	}

	public function color3InterpolateFunction(startValue:Color3, endValue:Color3, gradient:Float):Color3 {
		return Color3.Lerp(startValue, endValue, gradient);
	}
	
	public function matrixInterpolateFunction(startValue:Matrix, endValue:Matrix, gradient:Float):Matrix {
		var startScale = new Vector3(0, 0, 0);
		var startRotation = new Quaternion();
		var startTranslation = new Vector3(0, 0, 0);
		startValue.decompose(startScale, startRotation, startTranslation);
		
		var endScale = new Vector3(0, 0, 0);
		var endRotation = new Quaternion();
		var endTranslation = new Vector3(0, 0, 0);
		endValue.decompose(endScale, endRotation, endTranslation);
		
		var resultScale = this.vector3InterpolateFunction(startScale, endScale, gradient);
		var resultRotation = this.quaternionInterpolateFunction(startRotation, endRotation, gradient);
		var resultTranslation = this.vector3InterpolateFunction(startTranslation, endTranslation, gradient);
		
		var result = Matrix.Compose(resultScale, resultRotation, resultTranslation);
		
		return result;
	}

	public function clone():Animation {
		var clone = new Animation(this.name, this.targetPropertyPath.join("."), this.framePerSecond, this.dataType, this.loopMode);
		clone.setKeys(this._keys);
		
		return clone;
	}

	public function setKeys(values:Array<BabylonFrame>) {
		this._keys = values.slice(0);
		this._offsetsCache = [];// { };
		this._highLimitsCache = [];// { };
	}

	private function _interpolate(currentFrame:Int, repeatCount:Int, loopMode:Int, ?offsetValue:Dynamic, ?highLimitValue:Dynamic):Dynamic {
		if (loopMode == Animation.ANIMATIONLOOPMODE_CONSTANT && repeatCount > 0 && highLimitValue != null) {
			return highLimitValue.clone != null ? highLimitValue.clone() : highLimitValue;
		}
		
		this.currentFrame = currentFrame;
		
		// Try to get a hash to find the right key
		var startKey = Std.int(Math.max(0, Math.min(this._keys.length - 1, Math.floor(this._keys.length * (currentFrame - this._keys[0].frame) / (this._keys[this._keys.length - 1].frame - this._keys[0].frame)) - 1)));
		
		if (this._keys[startKey].frame >= currentFrame) {
			while (startKey - 1 >= 0 && this._keys[startKey].frame >= currentFrame) {
				startKey--;
			}
		}
		
		for (key in startKey...this._keys.length) {
			// for each frame, we need the key just before the frame superior
			if (this._keys[key + 1] != null && this._keys[key + 1].frame >= currentFrame) {
				
				var startValue:Dynamic = this._keys[key].value;
				var endValue:Dynamic = this._keys[key + 1].value;
				
				// gradient : percent of currentFrame between the frame inf and the frame sup
				var gradient:Float = (currentFrame - this._keys[key].frame) / (this._keys[key + 1].frame - this._keys[key].frame);
				
				// check for easingFunction and correction of gradient
                if (this._easingFunction != null) {
                    gradient = this._easingFunction.ease(gradient);
                }
				
				switch (this.dataType) {
					// Float
					case Animation.ANIMATIONTYPE_FLOAT:
						switch (loopMode) {
							case Animation.ANIMATIONLOOPMODE_CYCLE, Animation.ANIMATIONLOOPMODE_CONSTANT:
								return this.floatInterpolateFunction(cast startValue, cast endValue, gradient);
							case Animation.ANIMATIONLOOPMODE_RELATIVE:
								return offsetValue * repeatCount + this.floatInterpolateFunction(startValue, endValue, gradient);
						}
						
					// Quaternion
					case Animation.ANIMATIONTYPE_QUATERNION:
						var quaternion = null;
						switch (loopMode) {
							case Animation.ANIMATIONLOOPMODE_CYCLE, Animation.ANIMATIONLOOPMODE_CONSTANT:
								quaternion = this.quaternionInterpolateFunction(cast startValue, cast endValue, gradient);
								
							case Animation.ANIMATIONLOOPMODE_RELATIVE:
								quaternion = this.quaternionInterpolateFunction(cast startValue, cast endValue, gradient).add(offsetValue.scale(repeatCount));								
						}
						
						return quaternion;
					// Vector3
					case Animation.ANIMATIONTYPE_VECTOR3:
						switch (loopMode) {
							case Animation.ANIMATIONLOOPMODE_CYCLE, Animation.ANIMATIONLOOPMODE_CONSTANT:
								return this.vector3InterpolateFunction(cast startValue, cast endValue, gradient);
							case Animation.ANIMATIONLOOPMODE_RELATIVE:
								return this.vector3InterpolateFunction(cast startValue, cast endValue, gradient).add(offsetValue.scale(repeatCount));
						}
					// Vector2
					case Animation.ANIMATIONTYPE_VECTOR2:
						switch (loopMode) {
							case Animation.ANIMATIONLOOPMODE_CYCLE, Animation.ANIMATIONLOOPMODE_CONSTANT:
								return this.vector2InterpolateFunction(cast startValue, cast endValue, gradient);
							case Animation.ANIMATIONLOOPMODE_RELATIVE:
								return this.vector2InterpolateFunction(cast startValue, cast endValue, gradient).add(offsetValue.scale(repeatCount));
						}
					// Color3
					case Animation.ANIMATIONTYPE_COLOR3:
						switch (loopMode) {
							case Animation.ANIMATIONLOOPMODE_CYCLE, Animation.ANIMATIONLOOPMODE_CONSTANT:
								return this.color3InterpolateFunction(cast startValue, cast endValue, gradient);
							case Animation.ANIMATIONLOOPMODE_RELATIVE:
								return this.color3InterpolateFunction(cast startValue, cast endValue, gradient).add(offsetValue.scale(repeatCount));
						}
					// Matrix
					case Animation.ANIMATIONTYPE_MATRIX:
						switch (loopMode) {
							case Animation.ANIMATIONLOOPMODE_CYCLE, Animation.ANIMATIONLOOPMODE_CONSTANT, Animation.ANIMATIONLOOPMODE_RELATIVE:
								//return this.matrixInterpolateFunction(startValue, endValue, gradient);
								
							//case Animation.ANIMATIONLOOPMODE_RELATIVE:
								return startValue;
						}
					default:
						//
				}
			}
		}
		
		return this._keys[this._keys.length - 1].value;
	}

	public function animate(delay:Float, from:Int, to:Int, loop:Bool, speedRatio:Float):Bool {
		if (this.targetPropertyPath == null || this.targetPropertyPath.length < 1) {
			this._stopped = true;
			return false;
		}
		
		var returnValue = true;
		
		// Adding a start key at frame 0 if missing
		if (this._keys[0].frame != 0) {
			var newKey = {
				frame:0,
				value:this._keys[0].value
			};
			
			this._keys.unshift(newKey);
		}
		
		// Check limits
		if (from < this._keys[0].frame || from > this._keys[this._keys.length - 1].frame) {
			from = this._keys[0].frame;
		}
		if (to < this._keys[0].frame || to > this._keys[this._keys.length - 1].frame) {
			to = this._keys[this._keys.length - 1].frame;
		}
		
		// Compute ratio
		var range = to - from;
		var offsetValue:Dynamic = null;
		// ratio represents the frame delta between from and to
		var ratio = delay * (this.framePerSecond * speedRatio) / 1000.0;
		var highLimitValue:Dynamic = null;
		
		if (ratio > range && !loop) { // If we are out of range and not looping get back to caller
			returnValue = false;
			highLimitValue = this._keys[this._keys.length - 1].value;
		} else {
			// Get max value if required
			highLimitValue = 0;
			if (this.loopMode != Animation.ANIMATIONLOOPMODE_CYCLE) {
				var keyOffset = to + from;
				if (this._offsetsCache.length > keyOffset) {
					var fromValue = this._interpolate(from, 0, Animation.ANIMATIONLOOPMODE_CYCLE);
					var toValue = this._interpolate(to, 0, Animation.ANIMATIONLOOPMODE_CYCLE);
					switch (this.dataType) {
						// Float
						case Animation.ANIMATIONTYPE_FLOAT:
							this._offsetsCache[keyOffset] = toValue - fromValue;
							
						// Quaternion
						case Animation.ANIMATIONTYPE_QUATERNION:
							this._offsetsCache[keyOffset] = cast(toValue, Quaternion).subtract(cast(fromValue, Quaternion));
							
						// Vector3
						case Animation.ANIMATIONTYPE_VECTOR3:
							this._offsetsCache[keyOffset] = cast(toValue, Vector3).subtract(cast(fromValue, Vector3));
							
						// Vector2
						case Animation.ANIMATIONTYPE_VECTOR2:
							this._offsetsCache[keyOffset] = cast(toValue, Vector2).subtract(cast(fromValue, Vector2));
							
						// Color3
						case Animation.ANIMATIONTYPE_COLOR3:
							this._offsetsCache[keyOffset] = cast(toValue, Color3).subtract(cast(fromValue, Color3));
							
						default:
							//
					}
					
					this._highLimitsCache[keyOffset] = toValue;
				}
				
				highLimitValue = this._highLimitsCache[keyOffset];
				offsetValue = this._offsetsCache[keyOffset];
			}
		}
		
		if (offsetValue == null) {
			switch (this.dataType) {
				// Float
				case Animation.ANIMATIONTYPE_FLOAT:
					offsetValue = 0;
					
				// Quaternion
				case Animation.ANIMATIONTYPE_QUATERNION:
					offsetValue = new Quaternion(0, 0, 0, 0);
					
				// Vector3
				case Animation.ANIMATIONTYPE_VECTOR3:
					offsetValue = Vector3.Zero();
					
				// Vector2
				case Animation.ANIMATIONTYPE_VECTOR2:
					offsetValue = Vector2.Zero();
					
				// Color3
				case Animation.ANIMATIONTYPE_COLOR3:
					offsetValue = Color3.Black();
			}
		}
		
		// Compute value
		var repeatCount = Std.int(ratio / range);
		var currentFrame = cast (returnValue ? from + ratio % range : to);
		var currentValue = this._interpolate(currentFrame, repeatCount, this.loopMode, offsetValue, highLimitValue);
		
		// Set value
		if (this.targetPropertyPath.length > 1) {
			var property = Reflect.getProperty(this._target, this.targetPropertyPath[0]);
			
			for (index in 1...this.targetPropertyPath.length - 1) {
				property = Reflect.getProperty(property, this.targetPropertyPath[index]);
			}
			
			Reflect.setProperty(property, this.targetPropertyPath[this.targetPropertyPath.length - 1], currentValue);
		} else {
			Reflect.setProperty(this._target, this.targetPropertyPath[0], currentValue);
		}
		
		if (this._target.markAsDirty != null) {
			this._target.markAsDirty(this.targetProperty);
		}
		
		if (!returnValue) {
			this._stopped = true;
		}
		
		return returnValue;
	}

}
