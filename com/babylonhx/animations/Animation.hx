package com.babylonhx.animations;

import com.babylonhx.animations.easing.EasingFunction;
import com.babylonhx.animations.easing.IEasingFunction;
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

/**
* ...
* @author Krtolica Vujadin
*/

@:expose('BABYLON.BabylonFrame') typedef BabylonFrame = {
	frame:Int,
	value:Dynamic,			// Vector3 or Quaternion or Matrix or Float or Color3 or Vector2
	?outTangent:Dynamic,
	?inTangent:Dynamic
}

@:expose('BABYLON.Animation') class Animation {
	
	public static inline var ANIMATIONTYPE_FLOAT:Int = 0;
	public static inline var ANIMATIONTYPE_VECTOR3:Int = 1;
	public static inline var ANIMATIONTYPE_QUATERNION:Int = 2;
	public static inline var ANIMATIONTYPE_MATRIX:Int = 3;
	public static inline var ANIMATIONTYPE_COLOR3:Int = 4;
	public static inline var ANIMATIONTYPE_VECTOR2:Int = 5;
	public static inline var ANIMATIONTYPE_SIZE:Int = 6;

	public static inline var ANIMATIONLOOPMODE_RELATIVE:Int = 0;
	public static inline var ANIMATIONLOOPMODE_CYCLE:Int = 1;
	public static inline var ANIMATIONLOOPMODE_CONSTANT:Int = 2;
	
	public static var AllowMatricesInterpolation:Bool = false;
	
	private var _keys:Array<BabylonFrame>;
	private var _easingFunction:IEasingFunction;
	
	public var _runtimeAnimations:Array<RuntimeAnimation> = [];
	
	// The set of event that will be linked to this animation
	private var _events:Array<AnimationEvent> = [];

	public var targetPropertyPath:Array<String>;
	
	public var blendingSpeed:Float = 0.01;

	private var _ranges:Map<String, AnimationRange> = new Map();
	
	public var name:String;
	public var targetProperty:String;	
	public var framePerSecond:Int;
	public var dataType:Int;
	public var loopMode:Int;	
	public var enableBlending:Bool;
	
	
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
		else if (Std.is(from, Size)) {
			dataType = Animation.ANIMATIONTYPE_SIZE;
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
	
	/**
	 * Sets up an animation.
	 * @param property the property to animate
	 * @param animationType the animation type to apply
	 * @param easingFunction the easing function used in the animation
	 * @returns The created animation
	 */
	public static function CreateAnimation(property:String, animationType:Int, framePerSecond:Int, easingFunction:EasingFunction):Animation {
		var animation:Animation = new Animation(property + "Animation",
			property,
			framePerSecond,
			animationType,
			Animation.ANIMATIONLOOPMODE_CONSTANT
		);
		
		animation.setEasingFunction(easingFunction);
		
		return animation;
	}
	
	public static function CreateAndStartAnimation(name:String, node:Node, targetProperty:String, framePerSecond:Int, totalFrame:Int, from:Dynamic, to:Dynamic, ?loopMode:Int, ?easingFunction:EasingFunction, ?onAnimationEnd:Void->Void):Animatable {
		var animation = Animation._PrepareAnimation(name, targetProperty, framePerSecond, totalFrame, from, to, loopMode, easingFunction);
		
		if (animation == null) {
			return null;
		}
		
		return node.getScene().beginDirectAnimation(node, [animation], 0, totalFrame, (animation.loopMode == 1), 1.0, onAnimationEnd);
	}
	
	public static function CreateMergeAndStartAnimation(name:String, node:Node, targetProperty:String, framePerSecond:Int, totalFrame:Int, from:Dynamic, to:Dynamic, ?loopMode:Int, ?easingFunction:EasingFunction, ?onAnimationEnd:Void->Void) {
		var animation = Animation._PrepareAnimation(name, targetProperty, framePerSecond, totalFrame, from, to, loopMode, easingFunction);
		
		if (animation == null) {
			return null;
		}
		
		node.animations.push(animation);
		
		return node.getScene().beginAnimation(node, 0, totalFrame, (animation.loopMode == 1), 1.0, onAnimationEnd);
	}
	
	/**
	 * Transition property of the Camera to the target Value.
	 * @param property The property to transition
	 * @param targetValue The target Value of the property
	 * @param host The object where the property to animate belongs
	 * @param scene Scene used to run the animation
	 * @param frameRate Framerate (in frame/s) to use
	 * @param transition The transition type we want to use
	 * @param duration The duration of the animation, in milliseconds
	 * @param onAnimationEnd Call back trigger at the end of the animation.
	 */
	public static function TransitionTo(property:String, targetValue:Dynamic, host:Dynamic, scene:Scene, frameRate:Int, transition:Animation, duration:Float, onAnimationEnd:Void->Void = null):Animatable {
		if (duration <= 0) {
			Reflect.setProperty(host, property, targetValue);
			if (onAnimationEnd != null) {
				onAnimationEnd();
			}
			return null;
		}
		
		var endFrame:Int = Std.int(frameRate * (duration / 1000));
		
		transition.setKeys([{
			frame: 0,
			value: Reflect.getProperty(host, property).clone != null ? Reflect.getProperty(host, property).clone() : Reflect.getProperty(host, property)
		},
		{
			frame: endFrame,
			value: targetValue
		}]);
		
		if (host.animations == null) {
			host.animations = [];
		}
		
		untyped host.animations.push(transition);
		
		var animation:Animatable = scene.beginAnimation(host, 0, endFrame, false);
		animation.onAnimationEnd = onAnimationEnd;
		return animation;
	}
	
	/**
	 * Return the array of runtime animations currently using this animation
	 */
	public var runtimeAnimations(get, never):Array<RuntimeAnimation>;
	inline function get_runtimeAnimations():Array<RuntimeAnimation> {
		return this._runtimeAnimations;
	}

	public var hasRunningRuntimeAnimations(get, never):Bool;
	function get_hasRunningRuntimeAnimations():Bool {
		for (runtimeAnimation in this._runtimeAnimations) {
			if (!runtimeAnimation.isStopped()) {
				return true;
			}
		}
		
		return false;
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
	 * @param {boolean} fullDetails - support for multiple levels of logging within scene loading
	 */
	public function toString(fullDetails:Bool = false):String {
		var ret = "Name: " + this.name + ", property: " + this.targetProperty;
		ret += ", datatype: " + (["Float", "Vector3", "Quaternion", "Matrix", "Color3", "Vector2"])[this.dataType];
		ret += ", nKeys: " + (this._keys != null ? this._keys.length + '' : "none");
		//ret += ", nRanges: " + (this._ranges != null ? this._ranges.keys().length : "none");
		if (fullDetails) {
			ret += ", Ranges: {";
			var first = true;
			for (name in this._ranges.keys()) {
				if (first) {
					ret += ", ";
					first = false; 
				}
				ret += name; 
			}
			ret += "}";
		}
		return ret;
	}
	
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
	
	inline public function getEvents():Array<AnimationEvent> {
		return this._events;
	}
	
	public function createRange(name:String, from:Float, to:Float) {
		// check name not already in use; could happen for bones after serialized
        if (!this._ranges.exists(name)){
            this._ranges[name] = new AnimationRange(name, from, to);
        }
	}

	public function deleteRange(name:String, deleteFrames:Bool = true) {
		var range = this._ranges[name];
		if (range == null) {
			return;
		}
		
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

	public function getRange(name:String):AnimationRange {		
		return this._ranges[name];
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
		return Scalar.Lerp(startValue, endValue, gradient);
	}
	
	inline public function floatInterpolateFunctionWithTangents(startValue:Float, outTangent:Float, endValue:Float, inTangent:Float, gradient:Float):Float {
		return Scalar.Hermite(startValue, outTangent, endValue, inTangent, gradient);
	}

	inline public function quaternionInterpolateFunction(startValue:Quaternion, endValue:Quaternion, gradient:Float):Quaternion {
		return Quaternion.Slerp(startValue, endValue, gradient);
	}
	
	inline public function quaternionInterpolateFunctionWithTangents(startValue:Quaternion, outTangent:Quaternion, endValue:Quaternion, inTangent:Quaternion, gradient:Float):Quaternion {
		return Quaternion.Hermite(startValue, outTangent, endValue, inTangent, gradient).normalize();
	}

	inline public function vector3InterpolateFunction(startValue:Vector3, endValue:Vector3, gradient:Float):Vector3 {
		return Vector3.Lerp(startValue, endValue, gradient);
	}
	
	inline public function vector3InterpolateFunctionWithTangents(startValue:Vector3, outTangent:Vector3, endValue:Vector3, inTangent:Vector3, gradient:Float): Vector3 {
		return Vector3.Hermite(startValue, outTangent, endValue, inTangent, gradient);
	}

	inline public function vector2InterpolateFunction(startValue:Vector2, endValue:Vector2, gradient:Float):Vector2 {
		return Vector2.Lerp(startValue, endValue, gradient);
	}
	
	inline public function vector2InterpolateFunctionWithTangents(startValue:Vector2, outTangent:Vector2, endValue:Vector2, inTangent:Vector2, gradient:Float): Vector2 {
		return Vector2.Hermite(startValue, outTangent, endValue, inTangent, gradient);
	}

	inline public function sizeInterpolateFunction(startValue:Size, endValue:Size, gradient:Float):Size {
        return Size.Lerp(startValue, endValue, gradient);
    }

	inline public function color3InterpolateFunction(startValue:Color3, endValue:Color3, gradient:Float):Color3 {
		return Color3.Lerp(startValue, endValue, gradient);
	}
	
	public function matrixInterpolateFunction(startValue:Matrix, endValue:Matrix, gradient:Float):Matrix {
		return Matrix.Lerp(startValue, endValue, gradient);
	}

	public function clone():Animation {
		var clone = new Animation(this.name, this.targetPropertyPath.join("."), this.framePerSecond, this.dataType, this.loopMode, this.enableBlending);
		
		clone.enableBlending = this.enableBlending;
        clone.blendingSpeed = this.blendingSpeed;
		
		if (this._keys != null) {
			clone.setKeys(this._keys);
		}
		
		if (this._ranges != null) {
			clone._ranges = new Map();
			for (name in this._ranges.keys()) {
				var range = this._ranges[name];
				if (range == null) {
					continue;
				}
				clone._ranges[name] = range.clone();
			}
		}
		
		return clone;
	}

	public function setKeys(values:Array<BabylonFrame>) {
		this._keys = values.slice(0);
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
		
		if (parsedAnimation.enableBlending != null) {
			animation.enableBlending = parsedAnimation.enableBlending;
		}
		
		if (parsedAnimation.blendingSpeed != null) {
			animation.blendingSpeed = parsedAnimation.blendingSpeed;
		}
		
        for (index in 0...parsedAnimation.keys.length) {
            var key = parsedAnimation.keys[index];
			
			var inTangent:Dynamic = null;
			var outTangent:Dynamic = null;
			
            switch (dataType) {
                case Animation.ANIMATIONTYPE_FLOAT:
                    data = key.values[0];
					if (key.values.length >= 1) {
                        inTangent = key.values[1];
                    }
                    if (key.values.length >= 2) {
                        outTangent = key.values[2];
                    }
                    
                case Animation.ANIMATIONTYPE_QUATERNION:
                    data = Quaternion.FromArray(key.values);
					if (key.values.length >= 8) {
                        var _inTangent = Quaternion.FromArray(key.values.slice(4, 8));
                        if (!_inTangent.equals(Quaternion.Zero())) {
                            inTangent = _inTangent;
                        }
                    }
                    if (key.values.length >= 12) {
                        var _outTangent = Quaternion.FromArray(key.values.slice(8, 12));
                        if (!_outTangent.equals(Quaternion.Zero())) {
                            outTangent = _outTangent;
                        }
                    }
                    
                case Animation.ANIMATIONTYPE_MATRIX:
                    data = Matrix.FromArray(key.values);
					
				case Animation.ANIMATIONTYPE_COLOR3:
                    data = Color3.FromArray(key.values);
                    
                case Animation.ANIMATIONTYPE_VECTOR3:
					data = Vector3.FromArray(key.values);
					
                default:
                    data = Vector3.FromArray(key.values);
                    
            }
			
            var keyData:BabylonFrame = {
				frame: key.frame,
				value: data,
				inTangent: null,
				outTangent: null
			};
			
            if (inTangent != null) {
                keyData.inTangent = inTangent;
            }
            if (outTangent != null) {
                keyData.outTangent = outTangent;
            }
            keys.push(keyData);
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
