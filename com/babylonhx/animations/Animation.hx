package com.babylonhx.animations;

import com.babylonhx.animations.easing.EasingFunction;
import com.babylonhx.animations.easing.IEasingFunction;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Quaternion;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.Node;

/**
* ...
* @author Krtolica Vujadin
*/

@:expose('BABYLON.BabylonFrame') typedef BabylonFrame = {
	frame:Int,
	value:Dynamic			// Vector3 or Quaternion or Matrix or Float or Color3 or Vector2
}

@:expose('BABYLON.Animation') class Animation {
	
	public static inline var ANIMATIONTYPE_FLOAT:Int = 0;
	public static inline var ANIMATIONTYPE_VECTOR3:Int = 1;
	public static inline var ANIMATIONTYPE_QUATERNION:Int = 2;
	public static inline var ANIMATIONTYPE_MATRIX:Int = 3;
	public static inline var ANIMATIONTYPE_COLOR3:Int = 4;
	public static inline var ANIMATIONTYPE_VECTOR2:Int = 5;

	public static inline var ANIMATIONLOOPMODE_RELATIVE:Int = 0;
	public static inline var ANIMATIONLOOPMODE_CYCLE:Int = 1;
	public static inline var ANIMATIONLOOPMODE_CONSTANT:Int = 2;
	
	private var _keys:Array<BabylonFrame>;
	private var _offsetsCache:Array<Dynamic> = [];// { };
	private var _highLimitsCache:Array<Dynamic> = []; // { };
	private var _stopped:Bool = false;
	public var _target:Dynamic;
	private var _blendingFactor:Float = 0;
	private var _easingFunction:IEasingFunction;
	
	// The set of event that will be linked to this animation
	private var _events:Array<AnimationEvent> = [];

	public var name:String;
	public var targetProperty:String;
	public var targetPropertyPath:Array<String>;
	public var framePerSecond:Int;
	public var dataType:Int;
	public var loopMode:Int;
	public var currentFrame:Int;
	
	public var allowMatricesInterpolation:Bool = false;
	
	public var blendingSpeed:Float = 0.01;
	private var _originalBlendValue:Dynamic;
	
	public var enableBlending:Bool;

	private var _ranges:Map<String, AnimationRange> = new Map();
	
	
	private static function _PrepareAnimation(name:String, targetProperty:String, framePerSecond:Int, totalFrame:Int, from:Dynamic, to:Dynamic, ?loopMode:Int, ?easingFunction:EasingFunction):Animation {
		var dataType:Int = -1;
		
		if (Std.is(from, Float)) {
			dataType = Animation.ANIMATIONTYPE_FLOAT;
		} 
		else if (Std.is(from, Quaternion)) {
			dataType = Animation.ANIMATIONTYPE_QUATERNION;
		} 
		else if (Std.is(from, Vector3)) {
			dataType = Animation.ANIMATIONTYPE_VECTOR3;
		} 
		else if (Std.is(from, Vector2)) {
			dataType = Animation.ANIMATIONTYPE_VECTOR2;
		} 
		else if (Std.is(from, Color3)) {
			dataType = Animation.ANIMATIONTYPE_COLOR3;
		}
		
		if (dataType == -1) {
			return null;
		}
		
		var animation = new Animation(name, targetProperty, framePerSecond, dataType, loopMode);
		
		var keys:Array<BabylonFrame> = [];
		keys.push({ frame: 0, value: from });
		keys.push({ frame: totalFrame, value: to });
		animation.setKeys(keys);
		
		if (easingFunction != null) {
            animation.setEasingFunction(easingFunction);
        }
		
		return animation;
	}
	
	public static function CreateAndStartAnimation(name:String, node:Node, targetProperty:String, framePerSecond:Int, totalFrame:Int, from:Dynamic, to:Dynamic, ?loopMode:Int, ?easingFunction:EasingFunction, ?onAnimationEnd:Void->Void):Animatable {
		var animation = Animation._PrepareAnimation(name, targetProperty, framePerSecond, totalFrame, from, to, loopMode, easingFunction);
		
		return node.getScene().beginDirectAnimation(node, [animation], 0, totalFrame, (animation.loopMode == 1), 1.0, onAnimationEnd);
	}
	
	public static function CreateMergeAndStartAnimation(name:String, node:Node, targetProperty:String, framePerSecond:Int, totalFrame:Int, from:Dynamic, to:Dynamic, ?loopMode:Int, ?easingFunction:EasingFunction, ?onAnimationEnd:Void->Void) {
		var animation = Animation._PrepareAnimation(name, targetProperty, framePerSecond, totalFrame, from, to, loopMode, easingFunction);
		
		node.animations.push(animation);
		
		return node.getScene().beginAnimation(node, 0, totalFrame, (animation.loopMode == 1), 1.0, onAnimationEnd);
	}

	public function new(name:String, targetProperty:String, framePerSecond:Int, dataType:Int, loopMode:Int = -1, enableBlending:Bool = false) {
		this.name = name;
        this.targetProperty = targetProperty;
        this.targetPropertyPath = targetProperty.split(".");
        this.framePerSecond = framePerSecond;
        this.dataType = dataType;
		this.loopMode = loopMode == -1 ? Animation.ANIMATIONLOOPMODE_CYCLE : loopMode;
		this.enableBlending = enableBlending;
	}

	// Methods 
	
	/**
	 * Add an event to this animation.
	 */
	public function addEvent(event:AnimationEvent) {
		this._events.push(event);
	}

	/**
	 * Remove all events found at the given frame
	 * @param frame
	 */
	public function removeEvents(frame:Int) {
		var index:Int = 0;
		while (index < this._events.length) {
			if (this._events[index].frame == frame) {
				this._events.splice(index, 1);
				index--;
			}
			
			++index;
		}
	}
	
	public function createRange(name:String, from:Float, to:Float) {
		// check name not already in use; could happen for bones after serialized
        if (!this._ranges.exists(name)){
            this._ranges[name] = new AnimationRange(name, from, to);
        }
	}

	public function deleteRange(name:String, deleteFrames:Bool = true) {
		if (this._ranges[name] != null){
			if (deleteFrames) {
				var from = this._ranges[name].from;
				var to = this._ranges[name].to;
				
				// this loop MUST go high to low for multiple splices to work
				var key = this._keys.length - 1;
				while (key >= 0) {
					if (this._keys[key].frame >= from  && this._keys[key].frame <= to) {
					   this._keys.splice(key, 1); 
					}
					key--;
				}
			}
			this._ranges.remove(name);
		}
	}

	public function getRange(name:String):AnimationRange {		
		return this._ranges[name];
	}
	
	public function reset() {
		this._offsetsCache = [];
		this._highLimitsCache = [];
		this.currentFrame = 0;
		this._blendingFactor = 0;
		this._originalBlendValue = null;
	}
	
	inline public function isStopped():Bool {
		return this._stopped;
	}

	inline public function getKeys():Array<BabylonFrame> {
		return this._keys;
	}
	
	inline public function getHighestFrame():Int {
		var ret = 0; 
		
		for (key in 0...this._keys.length) {
			if (ret < this._keys[key].frame) {
				ret = this._keys[key].frame; 
			}
		}
		
		return ret;
	}
	
	inline public function getEasingFunction() {
        return this._easingFunction;
    }

    inline public function setEasingFunction(easingFunction:EasingFunction) {
        this._easingFunction = easingFunction;
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

	inline public function vector2InterpolateFunction(startValue:Vector2, endValue:Vector2, gradient:Float):Vector2 {
		return Vector2.Lerp(startValue, endValue, gradient);
	}

	inline public function color3InterpolateFunction(startValue:Color3, endValue:Color3, gradient:Float):Color3 {
		return Color3.Lerp(startValue, endValue, gradient);
	}
	
	public function matrixInterpolateFunction(startValue:Matrix, endValue:Matrix, gradient:Float):Matrix {
		return Matrix.Lerp(startValue, endValue, gradient);
	}

	public function clone():Animation {
		var clone = new Animation(this.name, this.targetPropertyPath.join("."), this.framePerSecond, this.dataType, this.loopMode, this.enableBlending);
		
		if (this._keys != null) {
			clone.setKeys(this._keys);
		}
		
		if (this._ranges != null) {
			clone._ranges = new Map();
			for (name in this._ranges.keys()) {
				clone._ranges[name] = this._ranges[name].clone();
			}
		}
		
		return clone;
	}

	public function setKeys(values:Array<BabylonFrame>) {
		this._keys = values.slice(0);
		this._offsetsCache = [];
		this._highLimitsCache = [];
	}
	
	private function _getKeyValue(value:Dynamic):Dynamic {
		if (Reflect.isFunction(value)) {
			return value();
		}
		
		return value;
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
							case Animation.ANIMATIONLOOPMODE_CYCLE, Animation.ANIMATIONLOOPMODE_CONSTANT:
								return this.matrixInterpolateFunction(startValue, endValue, gradient);
								
							case Animation.ANIMATIONLOOPMODE_RELATIVE:
								return startValue;
								
							default:
								//
						}
					default:
						//
				}
			}
		}
		
		return this._getKeyValue(this._keys[this._keys.length - 1].value);
	}
	
	inline public function setValue(currentValue:Dynamic, blend:Bool = false) {
		// Set value
		var path:Dynamic;
		var destination:Dynamic;
		
		if (this.targetPropertyPath.length > 1) {
			var property = Reflect.getProperty(this._target, this.targetPropertyPath[0]);
			/*switch(this.targetPropertyPath[0]) {
				case "scaling":
					property = untyped this._target.scaling;
					
				case "position":
					property = untyped this._target.position;
					
				case "rotation":
					property = untyped this._target.rotation;
					
				default: 
					property = Reflect.getProperty(this._target, this.targetPropertyPath[0]);
			}*/			
			
			for (index in 1...this.targetPropertyPath.length - 1) {
				property = Reflect.getProperty(property, this.targetPropertyPath[index]);
			}
			
			path = this.targetPropertyPath[this.targetPropertyPath.length - 1];
			destination = property;
			
			/*switch(this.targetPropertyPath[this.targetPropertyPath.length - 1]) {					
				case "x":
					untyped property.x = currentValue;
					
				case "y":
					untyped property.y = currentValue;
					
				case "z":
					untyped property.z = currentValue;
					
				default:
					Reflect.setProperty(property, this.targetPropertyPath[this.targetPropertyPath.length - 1], currentValue);
			}*/	
		} 
		else {
			/*switch(this.targetPropertyPath[0]) {
				case "_matrix":
					untyped this._target._matrix = currentValue;
					
				case "rotation":
					untyped this._target.rotation = currentValue;
					
				case "position":
					untyped this._target.position = currentValue;
					
				case "scaling":
					untyped this._target.scaling = currentValue;
				 
				default:
					Reflect.setProperty(this._target, this.targetPropertyPath[0], currentValue);
			}*/
			
			path = this.targetPropertyPath[0];
			destination = this._target;
		}
		
		// Blending
		if (this.enableBlending && this._blendingFactor <= 1.0) {
			if (this._originalBlendValue == null) {				
				if (path == "_matrix") {
					this._originalBlendValue = destination._matrix.clone();
				} 
				else {
					this._originalBlendValue = Reflect.getProperty(destination, path);
				}
			}
			
			if (path == "_matrix") { 				
				untyped destination._matrix = Matrix.Lerp(this._originalBlendValue, currentValue, this._blendingFactor);
			} 
			else { // Direct value
				Reflect.setField(destination, path, this._originalBlendValue * (1.0 - this._blendingFactor) + this._blendingFactor * currentValue);
			}
			
			this._blendingFactor += this.blendingSpeed;
		} 
		else {
			Reflect.setField(destination, path, currentValue);
		}
		
		if (this._target.markAsDirty != null) {
			this._target.markAsDirty(this.targetProperty);
		}
	}

	public function goToFrame(frame:Int) {
		if (frame < this._keys[0].frame) {
			frame = this._keys[0].frame;
		} 
		else if (frame > this._keys[this._keys.length - 1].frame) {
			frame = this._keys[this._keys.length - 1].frame;
		}
		
		var currentValue = this._interpolate(frame, 0, this.loopMode);
		
		this.setValue(currentValue);
	}

	public function animate(delay:Float, from:Int, to:Int, loop:Bool, speedRatio:Float, blend:Bool = false):Bool {
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
			highLimitValue = this._getKeyValue(this._keys[this._keys.length - 1].value);
		} 
		else {
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
		this.setValue(currentValue);
		
		// Check events
		var index:Int = 0;
		while (index < this._events.length) {
			if (currentFrame >= this._events[index].frame) {
				var event = this._events[index];
				if (!event.isDone) {
					// If event should be done only once, remove it.
					if (event.onlyOnce) {
						this._events.splice(index, 1);
						index--;
					}
					event.isDone = true;
					event.action();
				} // Don't do anything if the event has already be done.
			} 
			else if (this._events[index].isDone && !this._events[index].onlyOnce) {
				// reset event, the animation is looping
				this._events[index].isDone = false;
			}
			
			++index;
		}
		
		if (!returnValue) {
			this._stopped = true;
		}
		
		return returnValue;
	}
	
	public function serialize():Dynamic {
		var serializationObject:Dynamic = { };
		
		serializationObject.name = this.name;
		serializationObject.property = this.targetProperty;
		serializationObject.framePerSecond = this.framePerSecond;
		serializationObject.dataType = this.dataType;
		serializationObject.loopBehavior = this.loopMode;
		
		var dataType = this.dataType;
		serializationObject.keys = [];
		var keys = this.getKeys();
		for (index in 0...keys.length) {
			var animationKey = keys[index];
			
			var key:Dynamic = { };
			key.frame = animationKey.frame;
			
			switch (dataType) {
				case Animation.ANIMATIONTYPE_FLOAT:
					key.values = [animationKey.value];
					
				case Animation.ANIMATIONTYPE_QUATERNION, Animation.ANIMATIONTYPE_MATRIX, Animation.ANIMATIONTYPE_VECTOR3, Animation.ANIMATIONTYPE_COLOR3:
					key.values = animationKey.value.asArray();
				
			}
			
			serializationObject.keys.push(key);
		}
		
		serializationObject.ranges = [];
        for (name in this._ranges.keys()) {
            var range:Dynamic = { };
            range.name = name;
            range.from = this._ranges[name].from;
            range.to   = this._ranges[name].to;
            serializationObject.ranges.push(range);
        }
		
		return serializationObject;
	}
	
	public static function Parse(parsedAnimation:Dynamic):Animation {
        var animation = new Animation(parsedAnimation.name, parsedAnimation.property, parsedAnimation.framePerSecond, parsedAnimation.dataType, parsedAnimation.loopBehavior);
		
        var dataType = parsedAnimation.dataType;
        var keys:Array<BabylonFrame> = [];
		var data:Dynamic = null;
        for (index in 0...parsedAnimation.keys.length) {
            var key = parsedAnimation.keys[index];
			
            switch (dataType) {
                case Animation.ANIMATIONTYPE_FLOAT:
                    data = key.values[0];
                    
                case Animation.ANIMATIONTYPE_QUATERNION:
                    data = Quaternion.FromArray(key.values);
                    
                case Animation.ANIMATIONTYPE_MATRIX:
                    data = Matrix.FromArray(key.values);
					
				case Animation.ANIMATIONTYPE_COLOR3:
                    data = Color3.FromArray(key.values);
                    
                case Animation.ANIMATIONTYPE_VECTOR3:
					data = Vector3.FromArray(key.values);
					
                default:
                    data = Vector3.FromArray(key.values);
                    
            }
			
            keys.push({
                frame: key.frame,
                value: data
            });
        }
		
        animation.setKeys(keys);
		
		if (parsedAnimation.ranges != null) {
            for (index in 0...parsedAnimation.ranges.length) {
                data = parsedAnimation.ranges[index];
                animation.createRange(data.name, data.from, data.to);
            }
        }
		
        return animation;
    }
	
	public static function AppendSerializedAnimations(source:IAnimatable, destination:Dynamic) {
		if (source.animations != null) {
			destination.animations = [];
			for (animationIndex in 0...source.animations.length) {
				var animation = source.animations[animationIndex];
				
				destination.animations.push(animation.serialize());
			}
		}
	}

}
