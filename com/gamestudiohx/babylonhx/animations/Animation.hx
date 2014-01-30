package com.gamestudiohx.babylonhx.animations;

import com.gamestudiohx.babylonhx.animations.Animation.BabylonFrame;
import com.gamestudiohx.babylonhx.tools.math.Quaternion;
import com.gamestudiohx.babylonhx.tools.math.Vector3;

/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

typedef BabylonFrame = {
	frame: Int,
	value: Dynamic			// Vector3 or Quaternion or Matrix or Float
}
 
class Animation {
	
	public static var ANIMATIONTYPE_FLOAT:Int = 0;
	public static var ANIMATIONTYPE_VECTOR3:Int = 1;
	public static var ANIMATIONTYPE_QUATERNION:Int = 2;
	public static var ANIMATIONTYPE_MATRIX:Int = 3;

	public static var ANIMATIONLOOPMODE_RELATIVE:Int = 0;
	public static var ANIMATIONLOOPMODE_CYCLE:Int = 1;
	public static var ANIMATIONLOOPMODE_CONSTANT:Int = 2;
	
	
	public var name:String;
	public var targetProperty:String;
	public var targetPropertyPath:Array<String>;
	public var framePerSecond:Int;
	public var dataType:Int;
	public var loopMode:Int;
	public var currentFrame:Float;
	public var _keys:Array<BabylonFrame>;		
	public var _offsetsCache:Array<Dynamic>; // Array<Int>;   // TODO - Array of Float, Quat, Vector3 ...
	public var _highLimitsCache:Array<Dynamic>; // Array<Int>;  // TODO - same as above - CHECK
		

	public function new(name:String, targetProperty:String, framePerSecond:Int, dataType:Int, loopMode:Int = -1) {
		this.name = name;
        this.targetProperty = targetProperty;
        this.targetPropertyPath = targetProperty.split(".");
        this.framePerSecond = framePerSecond;
        this.dataType = dataType;
        this.loopMode = loopMode == -1 ? Animation.ANIMATIONLOOPMODE_CYCLE : loopMode;

        this._keys = [];
        
        // Cache
        this._offsetsCache = [];
        this._highLimitsCache = [];
	}
	
	inline public function floatInterpolateFunction(startValue:Float, endValue:Float, gradient:Float):Float {
        return startValue + (endValue - startValue) * gradient;
    }
	
	inline public function quaternionInterpolateFunction(startValue:Quaternion, endValue:Quaternion, gradient:Float):Quaternion {
        return Quaternion.Slerp(startValue, endValue, gradient);
    }
	
	inline public function vector3InterpolateFunction(startValue:Vector3, endValue:Vector3, gradient:Float):Vector3 {
        return Vector3.Lerp(startValue, endValue, gradient);
    }
	
	public function clone():Animation {
        var clone = new Animation(this.name, this.targetPropertyPath.join("."), this.framePerSecond, this.dataType, this.loopMode);

        clone.setKeys(this._keys);

        return clone;
    }
	
	public function setKeys(values:Array<BabylonFrame>) {
        this._keys = values.slice(0);
        this._offsetsCache = [];
        this._highLimitsCache = [];
    }
	
	// it returns Float or Quaternion or Vector3 ??
	public function _interpolate(currentFrame:Float, repeatCount:Int, loopMode:Int, offsetValue:Dynamic = null, highLimitValue:Dynamic = null):Dynamic {
        if (loopMode == Animation.ANIMATIONLOOPMODE_CONSTANT && repeatCount > 0) {
            return Reflect.field(highLimitValue, "clone") != null ? highLimitValue.clone() : highLimitValue;
        }

        this.currentFrame = currentFrame;
        
        for (key in 0...this._keys.length-1) {
            if (this._keys[key + 1].frame >= currentFrame) {
                var startValue = this._keys[key].value;
                var endValue = this._keys[key + 1].value;
                var gradient:Float = (currentFrame - this._keys[key].frame) / (this._keys[key + 1].frame - this._keys[key].frame);

                switch (this.dataType) {
                    // Float
                    case Animation.ANIMATIONTYPE_FLOAT:
                        switch (loopMode) {
                            case Animation.ANIMATIONLOOPMODE_CYCLE, Animation.ANIMATIONLOOPMODE_CONSTANT:
                                return this.floatInterpolateFunction(cast startValue, cast endValue, gradient);                                
                            case Animation.ANIMATIONLOOPMODE_RELATIVE:
                                return offsetValue * repeatCount + this.floatInterpolateFunction(cast startValue, cast endValue, gradient);
                        }
                    // Quaternion
                    case Animation.ANIMATIONTYPE_QUATERNION:
                        var quaternion:Quaternion = null;
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
                    // Matrix
                    case Animation.ANIMATIONTYPE_MATRIX:
                        switch (loopMode) {
                            case Animation.ANIMATIONLOOPMODE_CYCLE, Animation.ANIMATIONLOOPMODE_CONSTANT, Animation.ANIMATIONLOOPMODE_RELATIVE:
                                return startValue;
                        }
                    default:
                        //
                }
            }
        }
		
        return this._keys[this._keys.length - 1].value;
    }
	
	public function animate(target:Dynamic, delay:Float, from:Float, to:Float, loop:Bool, speedRatio:Float):Bool {
		var returnValue:Bool = true;
        if (this.targetPropertyPath == null || this.targetPropertyPath.length < 1) {
            returnValue = false;
        } else {        
			// Adding a start key at frame 0 if missing
			if (this._keys.length == 0 || this._keys[0].frame != 0) {
				var newKey = {
					frame: 0,
					value: this._keys[0].value
				};

				//this._keys.splice(0, 0, newKey);
				this._keys.push(newKey);
			}

			// Check limits
			if (from < this._keys[0].frame || from > this._keys[this._keys.length - 1].frame) {
				from = this._keys[0].frame;
			}
			if (to < this._keys[0].frame || to > this._keys[this._keys.length - 1].frame) {
				to = this._keys[this._keys.length - 1].frame;
			}

			// Compute ratio
			var range:Float = to - from;
			var ratio:Float = delay * (this.framePerSecond * speedRatio) / 1000.0;
			var offsetValue = 0;
			var highLimitValue = 0;

			if (ratio > range && !loop) { // If we are out of range and not looping get back to caller
				//offsetValue = 0;
				returnValue = false;
			} else {
				// Get max value if required
				var offsetValue = 0;            
				if (this.loopMode != Animation.ANIMATIONLOOPMODE_CYCLE) {
					var keyOffset = Std.int(to + from);
					if (keyOffset < this._offsetsCache.length) {
						var fromValue = this._interpolate(from, 0, Animation.ANIMATIONLOOPMODE_CYCLE);
						var toValue = this._interpolate(to, 0, Animation.ANIMATIONLOOPMODE_CYCLE);
						switch (this.dataType) {
							// Float
							case Animation.ANIMATIONTYPE_FLOAT:
								this._offsetsCache[keyOffset] = toValue - fromValue;
								
							// Quaternion
							case Animation.ANIMATIONTYPE_QUATERNION:
								this._offsetsCache[keyOffset] = cast(toValue, Vector3).subtract(cast(fromValue, Vector3));
								
							// Vector3
							case Animation.ANIMATIONTYPE_VECTOR3:
								this._offsetsCache[keyOffset] = cast(toValue, Vector3).subtract(cast(fromValue, Vector3));
							default:
						   
						}

						this._highLimitsCache[keyOffset] = toValue;
					}

					highLimitValue = this._highLimitsCache[keyOffset];
					offsetValue = this._offsetsCache[keyOffset];
				}
			}

			// Compute value
			var repeatCount:Int = Std.int(ratio / range);  		
			var currentFrame = returnValue ? from + ratio % range : to;
			var currentValue = this._interpolate(currentFrame, repeatCount, this.loopMode, offsetValue, highLimitValue);

			// Set value
			if (this.targetPropertyPath.length > 1) {
				var property = Reflect.getProperty(target, this.targetPropertyPath[0]);

				for (index in 1...this.targetPropertyPath.length - 1) {
					property = Reflect.getProperty(property, this.targetPropertyPath[index]);
				}

				Reflect.setProperty(property, this.targetPropertyPath[this.targetPropertyPath.length - 1], currentValue);
			} else {
				Reflect.setProperty(target, this.targetPropertyPath[0], currentValue);
			}
			
			if (Reflect.field(target, "markAsDirty") != null) {
				target.markAsDirty(this.targetProperty);
			}
		}

        return returnValue;
    }
	
}
