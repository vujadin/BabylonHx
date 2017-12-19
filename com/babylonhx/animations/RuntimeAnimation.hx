package com.babylonhx.animations;

import com.babylonhx.bones.Bone;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Quaternion;
import com.babylonhx.math.Size;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Scalar;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.Node;

//import haxe.ds.Map;

/**
 * ...
 * @author Krtolica Vujadin
 */
class RuntimeAnimation {

	public var currentFrame:Int;
	private var _animation:Animation;
	private var _target:Dynamic;

	private var _originalBlendValue:Dynamic;
	private var _offsetsCache:Map<String, Dynamic> = new Map();
	private var _highLimitsCache:Map<String, Dynamic> = new Map();
	private var _stopped:Bool = false;
	private var _blendingFactor:Float = 0;
	
	public function new(target:Dynamic, animation:Animation) {
		this._animation = animation;
		this._target = target;
		
		animation._runtimeAnimations.push(this);
	}

	public var animation(get, never):Animation;
	inline private function get_animation():Animation {
		return this._animation;
	}

	public function reset() {
		this._offsetsCache = new Map();
		this._highLimitsCache = new Map();
		this.currentFrame = 0;
		this._blendingFactor = 0;
		this._originalBlendValue = null;
	}

	inline public function isStopped():Bool {
		return this._stopped;
	}        

	public function dispose() {
		var index = this._animation.runtimeAnimations.indexOf(this);
		
		if (index > -1) {
			this._animation.runtimeAnimations.splice(index, 1);
		}
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
		
		var keys = this._animation.getKeys();
		
		// Try to get a hash to find the right key
		var startKeyIndex = Std.int(Math.max(0, Math.min(keys.length - 1, Math.floor(keys.length * (currentFrame - keys[0].frame) / (keys[keys.length - 1].frame - keys[0].frame)) - 1)));
		
		if (keys[startKeyIndex].frame >= currentFrame) {
			while (startKeyIndex - 1 >= 0 && keys[startKeyIndex].frame >= currentFrame) {
				startKeyIndex--;
			}
		}
		
		for (key in startKeyIndex...keys.length) {
			var endKey = keys[key + 1];
			
			if (endKey != null && endKey.frame >= currentFrame) {
				var startKey = keys[key];
				var startValue:Dynamic = this._getKeyValue(startKey.value);
				var endValue:Dynamic = this._getKeyValue(endKey.value);
				
				var useTangent:Bool = startKey.outTangent != null && endKey.inTangent != null;
				var frameDelta:Float = endKey.frame - startKey.frame;
				
				// gradient : percent of currentFrame between the frame inf and the frame sup
				var gradient:Float = (currentFrame - keys[key].frame) / frameDelta;
				
				// check for easingFunction and correction of gradient
				var easingFunction = this._animation.getEasingFunction();
                if (easingFunction != null) {
                    gradient = easingFunction.ease(gradient);
                }
				
				switch (this._animation.dataType) {
					// Float
					case Animation.ANIMATIONTYPE_FLOAT:
						var floatValue = useTangent ? this._animation.floatInterpolateFunctionWithTangents(startValue, startKey.outTangent * frameDelta, endValue, endKey.inTangent * frameDelta, gradient) : this._animation.floatInterpolateFunction(startValue, endValue, gradient);
						switch (loopMode) {
							case Animation.ANIMATIONLOOPMODE_CYCLE, Animation.ANIMATIONLOOPMODE_CONSTANT:
								return floatValue;
							case Animation.ANIMATIONLOOPMODE_RELATIVE:
								return offsetValue * repeatCount + floatValue;
						}
						
					// Quaternion
					case Animation.ANIMATIONTYPE_QUATERNION:
						var quatValue = useTangent ? this._animation.quaternionInterpolateFunctionWithTangents(startValue, startKey.outTangent.scale(frameDelta), endValue, endKey.inTangent.scale(frameDelta), gradient) : this._animation.quaternionInterpolateFunction(startValue, endValue, gradient);
						switch (loopMode) {
							case Animation.ANIMATIONLOOPMODE_CYCLE, Animation.ANIMATIONLOOPMODE_CONSTANT:
								return quatValue;								
							case Animation.ANIMATIONLOOPMODE_RELATIVE:
								return quatValue.add(offsetValue.scale(repeatCount));								
						}
						
						return quatValue;
						
					// Vector3
					case Animation.ANIMATIONTYPE_VECTOR3:
						var vec3Value = useTangent ? this._animation.vector3InterpolateFunctionWithTangents(startValue, startKey.outTangent.scale(frameDelta), endValue, endKey.inTangent.scale(frameDelta), gradient) : this._animation.vector3InterpolateFunction(startValue, endValue, gradient);
						switch (loopMode) {
							case Animation.ANIMATIONLOOPMODE_CYCLE, Animation.ANIMATIONLOOPMODE_CONSTANT:
								return vec3Value;
							case Animation.ANIMATIONLOOPMODE_RELATIVE:
								return vec3Value.add(offsetValue.scale(repeatCount));
						}
						
					// Vector2
					case Animation.ANIMATIONTYPE_VECTOR2:
						var vec2Value = useTangent ? this._animation.vector2InterpolateFunctionWithTangents(startValue, startKey.outTangent.scale(frameDelta), endValue, endKey.inTangent.scale(frameDelta), gradient) : this._animation.vector2InterpolateFunction(startValue, endValue, gradient);
						switch (loopMode) {
							case Animation.ANIMATIONLOOPMODE_CYCLE, Animation.ANIMATIONLOOPMODE_CONSTANT:
								return vec2Value;
							case Animation.ANIMATIONLOOPMODE_RELATIVE:
								return vec2Value.add(offsetValue.scale(repeatCount));
						}
						
					// Size	
					case Animation.ANIMATIONTYPE_SIZE:
                        switch (loopMode) {
                            case Animation.ANIMATIONLOOPMODE_CYCLE, Animation.ANIMATIONLOOPMODE_CONSTANT:
                                return this._animation.sizeInterpolateFunction(startValue, endValue, gradient);
								
                            case Animation.ANIMATIONLOOPMODE_RELATIVE:
                                return this._animation.sizeInterpolateFunction(startValue, endValue, gradient).add(offsetValue.scale(repeatCount));
                        }
						
					// Color3
					case Animation.ANIMATIONTYPE_COLOR3:
						switch (loopMode) {
							case Animation.ANIMATIONLOOPMODE_CYCLE, Animation.ANIMATIONLOOPMODE_CONSTANT:
								return this._animation.color3InterpolateFunction(cast startValue, cast endValue, gradient);
							case Animation.ANIMATIONLOOPMODE_RELATIVE:
								return this._animation.color3InterpolateFunction(cast startValue, cast endValue, gradient).add(offsetValue.scale(repeatCount));
						}
						
					// Matrix
					case Animation.ANIMATIONTYPE_MATRIX:
						switch (loopMode) {
							case Animation.ANIMATIONLOOPMODE_CYCLE, Animation.ANIMATIONLOOPMODE_CONSTANT:
								if (Animation.AllowMatricesInterpolation) {
									var ret = this._animation.matrixInterpolateFunction(startValue, endValue, gradient);
									return ret;
								}
								return startValue; // VK: BHX specific (DO NOT REMOVE)- in BJS it will drop to next case and will return startValue
								
							case Animation.ANIMATIONLOOPMODE_RELATIVE:
								return startValue;
						}
					default:
						//
				}
			}
		}
		
		return this._getKeyValue(keys[keys.length - 1].value);
	}

	public function setValue(currentValue:Dynamic, blend:Bool = false) {
		// Set value
		var path:Dynamic;
		var destination:Dynamic;
		
		var targetPropertyPath = this._animation.targetPropertyPath;
		
		if (targetPropertyPath.length > 1) {
			var property = Reflect.getProperty(this._target, targetPropertyPath[0]);
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
			
			for (index in 1...targetPropertyPath.length - 1) {
				property = Reflect.getProperty(property, targetPropertyPath[index]);
			}
			
			path = targetPropertyPath[targetPropertyPath.length - 1];
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
			
			path = targetPropertyPath[0];
			destination = this._target;
		}
		
		// Blending
		if (this._animation.enableBlending && this._blendingFactor <= 1.0) {
			if (this._originalBlendValue == null) {
				if (destination[path].clone != null) {
					this._originalBlendValue = Reflect.getProperty(destination, path).clone();
				} 
				else {
					this._originalBlendValue = Reflect.getProperty(destination, path);
				}
			}
			
			if (Std.is(this._originalBlendValue, Float) || Std.is(this._originalBlendValue, Int)) {		// Direct value
				Reflect.setProperty(destination, path, this._originalBlendValue * (1.0 - this._blendingFactor) + this._blendingFactor * currentValue);
			}
			else if (this._originalBlendValue.m != null) { // Matrix
				//Reflect.setProperty(destination, path, Matrix.Lerp(this._originalBlendValue, currentValue, this._blendingFactor));
				cast (destination, Bone)._matrix = Matrix.Lerp(this._originalBlendValue, currentValue, this._blendingFactor);
			} 
			else { 	// Complex value
				if (this._originalBlendValue.Lerp != null) { // Lerp supported
					Reflect.setProperty(destination, path, this._originalBlendValue.construtor.prototype.Lerp(currentValue, this._originalBlendValue, this._blendingFactor));
				} 
				else { // Blending not supported
					Reflect.setProperty(destination, path, currentValue);
				}
			}
			this._blendingFactor += this._animation.blendingSpeed;
		} 
		else {
			if (path == "_matrix") {
				cast (destination, Bone)._matrix = currentValue;
			}
			else {
				Reflect.setProperty(destination, path, currentValue);
			}
		}
		
		if (this._target.markAsDirty) {
			this._target.markAsDirty(this._animation.targetProperty);
		}
	}

	public function goToFrame(frame:Int) {
		var keys = this._animation.getKeys();
		
		if (frame < keys[0].frame) {
			frame = keys[0].frame;
		} 
		else if (frame > keys[keys.length - 1].frame) {
			frame = keys[keys.length - 1].frame;
		}
		
		var currentValue = this._interpolate(frame, 0, this._animation.loopMode);
		
		this.setValue(currentValue);
	}
	
	public function _prepareForSpeedRatioChange(newSpeedRatio:Float) {
		var newRatio = this._previousDelay * (this._animation.framePerSecond * newSpeedRatio) / 1000.0;
		
		this._ratioOffset = this._previousRatio - newRatio;
	}

	private var _ratioOffset:Float = 0;
	private var _previousDelay:Float;
	private var _previousRatio:Float;

	public function animate(delay:Float, from:Int, to:Int, loop:Bool, speedRatio:Float, blend:Bool = false):Bool {
		var targetPropertyPath:Array<String> = this._animation.targetPropertyPath;
		if (targetPropertyPath == null || targetPropertyPath.length < 1) {
			this._stopped = true;
			return false;
		}
		var returnValue = true;
		var keys = this._animation.getKeys();
		
		// Adding a start key at frame 0 if missing
		if (keys[0].frame != 0) {
			var newKey = { frame: 0, value: keys[0].value };
			keys.insert(0, newKey);
		}
		
		// Check limits
		if (from < keys[0].frame || from > keys[keys.length - 1].frame) {
			from = keys[0].frame;
		}
		if (to < keys[0].frame || to > keys[keys.length - 1].frame) {
			to = keys[keys.length - 1].frame;
		}
		
		//to and from cannot be the same key
		if (from == to) {
			if (from > keys[0].frame) {
				from--;
			} 
			else if (to < keys[keys.length - 1].frame) {
				to++;
			}
		}
		
		// Compute ratio
		var range:Int = to - from;
		var offsetValue:Dynamic = null;
		// ratio represents the frame delta between from and to
		var ratio:Float = (delay * (this._animation.framePerSecond * speedRatio) / 1000.0) + this._ratioOffset;
		var highLimitValue = 0;
		
		this._previousDelay = delay;
		this._previousRatio = ratio;

		if (((to > from && ratio > range) || (from > to && ratio < range)) && !loop) { // If we are out of range and not looping get back to caller
			returnValue = false;
			highLimitValue = this._getKeyValue(keys[keys.length - 1].value);
		} 
		else {
			// Get max value if required
			if (this._animation.loopMode != Animation.ANIMATIONLOOPMODE_CYCLE) {
				var keyOffset = Std.string(to) + Std.string(from);
				if (this._offsetsCache[keyOffset] == null) {
					var fromValue = this._interpolate(from, 0, Animation.ANIMATIONLOOPMODE_CYCLE);
					var toValue = this._interpolate(to, 0, Animation.ANIMATIONLOOPMODE_CYCLE);
					switch (this._animation.dataType) {
						// Float
						case Animation.ANIMATIONTYPE_FLOAT:
							this._offsetsCache[keyOffset] = toValue - fromValue;
							
						// Quaternion
						case Animation.ANIMATIONTYPE_QUATERNION:
							this._offsetsCache[keyOffset] = cast (toValue, Quaternion).subtract(cast fromValue);
							
						// Vector3
						case Animation.ANIMATIONTYPE_VECTOR3:
							this._offsetsCache[keyOffset] = cast (toValue, Vector3).subtract(cast fromValue);
							
						// Vector2
						case Animation.ANIMATIONTYPE_VECTOR2:
							this._offsetsCache[keyOffset] = cast (toValue, Vector2).subtract(cast fromValue);
							
						// Size
						case Animation.ANIMATIONTYPE_SIZE:
							this._offsetsCache[keyOffset] = cast (toValue, Size).subtract(cast fromValue);
							
						// Color3
						case Animation.ANIMATIONTYPE_COLOR3:
							this._offsetsCache[keyOffset] = cast (toValue, Color3).subtract(cast fromValue);
							
						default:
					}
					
					this._highLimitsCache[keyOffset] = toValue;
				}
				
				highLimitValue = this._highLimitsCache[keyOffset];
				offsetValue = this._offsetsCache[keyOffset];
			}
		}
		
		if (offsetValue == null) {
			switch (this._animation.dataType) {
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
					
				// Size
				case Animation.ANIMATIONTYPE_SIZE:
					offsetValue = Size.Zero();
					
				// Color3
				case Animation.ANIMATIONTYPE_COLOR3:
					offsetValue = Color3.Black();
			}
		}
		
		// Compute value
		var repeatCount:Int = Std.int(ratio / range) >> 0;
		var currentFrame:Int = Std.int(returnValue ? from + ratio % range : to);
		var currentValue:Dynamic = this._interpolate(currentFrame, repeatCount, this._animation.loopMode, offsetValue, highLimitValue);
		
		// Set value
		this.setValue(currentValue);
		// Check events
		var events:Array<AnimationEvent> = this._animation.getEvents();
		var index:Int = 0;
		while (index < events.length) {
			// Make sure current frame has passed event frame and that event frame is within the current range
			// Also, handle both forward and reverse animations
			if (
				(range > 0 && currentFrame >= events[index].frame && events[index].frame >= from) ||
				(range < 0 && currentFrame <= events[index].frame && events[index].frame <= from)
			) {
				var event:AnimationEvent = events[index];
				if (!event.isDone) {
					// If event should be done only once, remove it.
					if (event.onlyOnce) {
						events.splice(index, 1);
						index--;
					}
					event.isDone = true;
					event.action();
				} // Don't do anything if the event has already be done.
			} 
			else if (events[index].isDone && !events[index].onlyOnce) {
				// reset event, the animation is looping
				events[index].isDone = false;
			}
			++index;
		}
		if (!returnValue) {
			this._stopped = true;
		}
		
		return returnValue;
	}
	
}
