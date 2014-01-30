package com.gamestudiohx.babylonhx.tools;

import com.gamestudiohx.babylonhx.tools.math.Vector3;
import flash.display.BitmapData;
import flash.events.Event;
import flash.Lib;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.utils.Timer;
import openfl.Assets;
import openfl.utils.Float32Array;
#if cpp
import sys.FileSystem;
import sys.io.File;
import sys.io.FileInput;
#end


/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

typedef BabylonMinMax = {
	minimum: Vector3,
	maximum: Vector3
}
 
class Tools {
	
	public static var timer:Timer;

	public static inline function ExtractMinAndMax(positions:Array<Float>, start:Int, count:Int):BabylonMinMax {
        var minimum:Vector3 = new Vector3(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
        var maximum:Vector3 = new Vector3(Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY);

        for (index in start...start + count) {
            var current = new Vector3(positions[index * 3], positions[index * 3 + 1], positions[index * 3 + 2]);

            minimum = Vector3.Minimize(current, minimum);
            maximum = Vector3.Maximize(current, maximum);
        }

        return {
            minimum: minimum,
            maximum: maximum
        };
    }
	
	public static inline function randomNumber(min:Float, max:Float):Float {
		var ret:Float = min;
        if (min == max) {
            ret = min;
        } else {
			var random = Math.random();
			ret = ((random * (max - min)) + min);
		}
		return ret;
    }
	
	public static inline function WithinEpsilon(a:Float, b:Float):Bool {
        var num:Float = a - b;
        return -1.401298E-45 <= num && num <= 1.401298E-45;
    }
	
	public static function LoadFile(url:String, callbackFn:String->Void) {
		#if html5		// Assets.getText doesn't work in html5 -> Chrome ????
		var loader:URLLoader = new URLLoader();
		loader.addEventListener(Event.COMPLETE, function(data) {
			callbackFn(loader.data);
		});
		loader.load(new URLRequest(url));
		#else
        if (Assets.exists(url)) {
			var file:String = Assets.getText(url);
			callbackFn(file);
		} else {
			trace("File: " + url + " doesn't exist !");
		}
		#end
    }
	
	public static function LoadImage(url:String, onload:BitmapData->Void) {  
		if (Assets.exists(url)) {
			var img:BitmapData = Assets.getBitmapData(url);
			onload(img);
		} else {
			trace("Error: Image '" + url + "' doesn't exist !");
		}
    }
	
	public static function DeepCopy(source:Dynamic, destination:Dynamic, doNotCopyList:Array<String> = null, mustCopyList:Array<String> = null) {
        for (prop in Reflect.fields(source)) {

            if (prop.charAt(0) == "_" && (mustCopyList == null || Lambda.indexOf(mustCopyList, prop) == -1)) {
                continue;
            }

            if (doNotCopyList != null && Lambda.indexOf(doNotCopyList, prop) != -1) {
                continue;
            }
			
            var sourceValue = Reflect.field(source, prop);

            if (Reflect.isFunction(sourceValue)) {
                continue;
            }
			
			Reflect.setField(destination, prop, Reflect.copy(sourceValue));			
        }
    }
	
	
	
	// FPS
    public static var fpsRange:Float = 60.0;
    public static var previousFramesDuration:Array<Float> = [];
    public static var fps:Float = 60.0;
    public static var deltaTime:Float = 0.0;

    public static function GetFps():Float {
        return fps;
    }

    public static function GetDeltaTime():Float {
        return deltaTime;
    }

    inline public static function _MeasureFps() {
        previousFramesDuration.push(Lib.getTimer());
        var length = previousFramesDuration.length;

        if (length >= 2) {
            deltaTime = previousFramesDuration[length - 1] - previousFramesDuration[length - 2];
        }

        if (length >= fpsRange) {

            if (length > fpsRange) {
                previousFramesDuration.splice(0, 1);
                length = previousFramesDuration.length;
            }

            var sum:Float = 0;
            for (id in 0...length - 1) {
                sum += previousFramesDuration[id + 1] - previousFramesDuration[id];
            }

            fps = 1000.0 / (sum / (length - 1));
        }
    }
	
}
