package com.babylonhx.tools;

#if js
import js.html.Element;
#end

import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.mesh.AbstractMesh;
import haxe.Timer;

#if nme
import nme.Assets;
import nme.display.BitmapData;
import nme.events.Event;
import nme.net.URLLoader;
import nme.net.URLRequest;
#elseif openfl
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.events.Event;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
#elseif snow

#elseif kha

#elseif foo3d

#end

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.BabylonMinMax') typedef BabylonMinMax = {
	minimum: Vector3,
	maximum: Vector3
}

@:expose('BABYLON.Tools') class Tools {
	
	public static var BaseUrl:String = "";
		
	@:noCompletion private static var __startTime:Float = Timer.stamp();

	public static function GetExponantOfTwo(value:Int, max:Int):Int {
		var count = 1;
		
		do {
			count *= 2;
		} while (count < value);
		
		if (count > max) {
			count = max;
		}
		
		return count;
	}

	public static function GetFilename(path:String):String {
		var index = path.lastIndexOf("/");
		if (index < 0) {
			return path;
		}
		
		return path.substring(index + 1);
	}

	public static function ToDegrees(angle:Float):Float {
		return angle * 180 / Math.PI;
	}

	public static function ToRadians(angle:Float):Float {
		return angle * Math.PI / 180;
	}

	inline public static function ExtractMinAndMaxIndexed(positions:Array<Float>, indices:Array<Int>, indexStart:Int, indexCount:Int):BabylonMinMax {
		var minimum = new Vector3(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
		var maximum = new Vector3(Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY);
		
		for (index in indexStart...indexStart + indexCount) {
			var current = new Vector3(positions[indices[index] * 3], positions[indices[index] * 3 + 1], positions[indices[index] * 3 + 2]);
			minimum = Vector3.Minimize(current, minimum);
			maximum = Vector3.Maximize(current, maximum);
		}
		
		return {
			minimum: minimum,
			maximum: maximum
		};
	}

	inline public static function ExtractMinAndMax(positions:Array<Float>, start:Int, count:Int):BabylonMinMax {
		var minimum = new Vector3(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
		var maximum = new Vector3(Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY);
		
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

	public static function MakeArray(obj:Dynamic, allowsNullUndefined:Bool = false):Array<Dynamic> {
		if (allowsNullUndefined != true && obj == null)
			return null;
			
		if (Std.is(obj, Map)) {
			var ret:Array<Dynamic> = [];
			for (key in cast(obj, Map<Dynamic, Dynamic>).keys()) {
				ret.push(obj.get(key));
			}
			return ret;
		}

		return Std.is(obj, Array) ? obj : [obj];
	}
	
	public static function LoadFile(url:String, callbackFn:Dynamic->Void, ?progressCallBack:Dynamic, ?db:Dynamic) {
		#if html5		// Assets.getText doesn't work in html5 -> Chrome ????
		var loader:URLLoader = new URLLoader();
		loader.addEventListener(Event.COMPLETE, function(data) {
			callbackFn(loader.data);
		});
		loader.load(new URLRequest(url));
		#else
		
		#if (nme || openfl)
		#if openfl
        //if (Assets.exists(url)) {
		#end
			if (StringTools.endsWith(url, "bbin")) {
				var file = Assets.getBytes(url);
				callbackFn(file);
			} else {
				var file:String = Assets.getText(url);
				callbackFn(file);
			}
		#if openfl
		//} else {
		//	trace("File: " + url + " doesn't exist !");
		//}
		#end
		#elseif snow
			
		#elseif kha
		
		#elseif foo3d
		
		#end
		#end
    }
	
	#if (nme || openfl)
	public static function LoadImage(url:String, onload:BitmapData->Void, ?onerror:Void->Void, ?db:Dynamic) { 
		#if openfl
		//if (Assets.exists(url)) {
		#end
			var img:BitmapData = Assets.getBitmapData(url);
			onload(img);
		#if openfl
		//} else {
		//	trace("Error: Image '" + url + "' doesn't exist !");
		//}
		#end
    }
	#end

	// Misc. 
	public static function Clamp(value:Float, min:Float = 0, max:Float = 1):Float {
		return Math.min(max, Math.max(min, value));
	}  
	
	public static function Clamp2(x:Float, a:Float, b:Float):Float {
		return (x < a) ? a : ((x > b) ? b : x);
	}
	
	// Returns -1 when value is a negative number and
	// +1 when value is a positive number. 
	inline public static function Sign(value:Dynamic):Int {
		//value = Std.parseFloat(value);
		
		if (value == 0/* || Math.isNaN(value)*/) {
			return 0;
		}
			
		return value > 0 ? 1 : -1;
	}

	public static function Format(value:Float, decimals:Int = 2):String {
		value = Math.round(value * Math.pow(10, decimals));
		var str = '' + value;
		var len = str.length;
		if(len <= decimals){
			while(len < decimals){
				str = '0' + str;
				len++;
			}
			return (decimals == 0 ? '' : '0.') + str;
		}
		else{
			return str.substr(0, str.length - decimals) + (decimals == 0 ? '' : '.') + str.substr(str.length - decimals);
		}
	}

	public static function CheckExtends(v:Vector3, min:Vector3, max:Vector3) {
		if (v.x < min.x)
			min.x = v.x;
		if (v.y < min.y)
			min.y = v.y;
		if (v.z < min.z)
			min.z = v.z;

		if (v.x > max.x)
			max.x = v.x;
		if (v.y > max.y)
			max.y = v.y;
		if (v.z > max.z)
			max.z = v.z;
	}

	inline public static function WithinEpsilon(a:Float, b:Float, epsilon:Float = 1.401298E-45):Bool {
		var num = a - b;
		return -epsilon <= num && num <= epsilon;
	}

	public static function DeepCopy(source:Dynamic, destination:Dynamic, ?doNotCopyList:Array<String>, ?mustCopyList:Array<String>) {
		var sourceFields = Type.getInstanceFields(source);
		for (prop in sourceFields) {
			if (prop.charAt(0) == "_" && (mustCopyList == null || mustCopyList.indexOf(prop) == -1)) {
				continue;
			}

			if (doNotCopyList != null && doNotCopyList.indexOf(prop) != -1) {
				continue;
			}
			var sourceValue = Reflect.getProperty(source, prop);

			if (Reflect.isFunction(sourceValue)) {
				continue;
			}
			
			Reflect.setField(destination, prop, dcopy(sourceValue));

			/*if (Reflect.isObject(sourceValue)) {
				if (Std.is(sourceValue, Array)) {
					Reflect.setField(destination, prop, new Array<Dynamic>());

					if (sourceValue.length > 0) {
						var sv = cast(sourceValue, Array<Dynamic>);
						if (Reflect.isObject(sv[0])) {
							for (index in 0...sv.length) {
								var clonedValue = cloneValue(sv[index], destination);

								if (cast(Reflect.getProperty(destination, prop), Array<Dynamic>).indexOf(clonedValue) == -1) { // Test if auto inject was not done
									cast(Reflect.getProperty(destination, prop), Array<Dynamic>).push(clonedValue);
								}
							}
						} else {
							Reflect.setField(destination, prop, sv.slice(0));
						}
					}
				} else {
					Reflect.setField(destination, prop, cloneValue(sourceValue, destination));
				}
			} else {
				Reflect.setField(destination, prop, sourceValue);
			}*/
		}
	}
	
	/*public static function copy<T>(v:T):T { 
		if (!Reflect.isObject(v)) { // simple type 
			return v; 
		}
		else if (Std.is(v, String)) { // string
			return v;
		}
		else if(Std.is( v, Array )) { // array 
			var result = Type.createInstance(Type.getClass(v), []); 
			untyped { 
				for( ii in 0...v.length ) {
					result.push(copy(v[ii]));
				}
			} 
			return result;
		}
		else if(Std.is(v, Map)) { // hashmap
			var result = Type.createInstance(Type.getClass(v), []);
			untyped {
				var keys : Iterator<String> = v.keys();
				for( key in keys ) {
					result.set(key, copy(v.get(key)));
				}
			} 
			return result;
		}
		else if(Std.is( v, IntHash )) { // integer-indexed hashmap
			var result = Type.createInstance(Type.getClass(v), []);
			untyped {
				var keys : Iterator<Int> = v.keys();
				for( key in keys ) {
					result.set(key, copy(v.get(key)));
				}
			} 
			return result;
		}
		else if(Std.is( v, List )) { // list
			//List would be copied just fine without this special case, but I want to avoid going recursive
			var result = Type.createInstance(Type.getClass(v), []);
			untyped {
				var iter:Iterator<Dynamic> = v.iterator();
				for(ii in iter) {
					result.add(ii);
				}
			} 
			return result; 
		}
		else if(Type.getClass(v) == null) { // anonymous object 
			var obj : Dynamic = {}; 
			for( ff in Reflect.fields(v) ) { 
				Reflect.setField(obj, ff, copy(Reflect.field(v, ff))); 
			}
			return obj; 
		} 
		else { // class 
			var obj = Type.createEmptyInstance(Type.getClass(v)); 
			for(ff in Reflect.fields(v)) {
				Reflect.setField(obj, ff, copy(Reflect.field(v, ff))); 
			}
			return obj; 
		} 
		return null; 
	}*/
	
	public static function dcopy<T>(v:T):T {
		if(Std.is(v, Array)) { // array 		 
			var r = Type.createInstance(Type.getClass(v), []); 
			untyped 
			{ 
				for( ii in 0...v.length ) 
				r.push(dcopy(v[ii])); 
			} 
			return r; 
		} 
		else if(Type.getClass(v) == null) { // anonymous object 
			var obj : Dynamic = {}; 
			for(ff in Reflect.fields(v)) {
				Reflect.setField(obj, ff, dcopy(Reflect.field(v, ff))); 
			}
			return obj; 
		} 
		else { // class 
			var obj = Type.createEmptyInstance(Type.getClass(v)); 
			for(ff in Reflect.fields(v)) {
				Reflect.setField(obj, ff, dcopy(Reflect.field(v, ff))); 
			}
			return obj; 
		}
		
		return null;
	}
	
	/** 
		deep copy of anything 
	**/ 
	public static function deepCopy<T>(v:T):T { 
		if (!Reflect.isObject(v)) {  // simple type 		
		  return v; 
		} 
		else if(Std.is(v, Array)) { // array 		 
			var r = Type.createInstance(Type.getClass(v), []); 
			untyped 
			{ 
				for( ii in 0...v.length ) 
				r.push(deepCopy(v[ii])); 
			} 
			return r; 
		} 
		else if(Type.getClass(v) == null) { // anonymous object 
			var obj : Dynamic = {}; 
			for(ff in Reflect.fields(v)) {
				Reflect.setField(obj, ff, deepCopy(Reflect.field(v, ff))); 
			}
			return obj; 
		} 
		else { // class 
			var obj = Type.createEmptyInstance(Type.getClass(v)); 
			for(ff in Reflect.fields(v)) {
				Reflect.setField(obj, ff, deepCopy(Reflect.field(v, ff))); 
			}
			return obj; 
		}
		
		return null; 
	} 
		
	public static function cloneValue(source:Dynamic, destinationObject:Dynamic):Dynamic {
        if (source == null)
            return null;

        if (Std.is(source, Mesh)) {
            return null;
        }

        if (Std.is(source, SubMesh)) {
            return cast(source, SubMesh).clone(cast(destinationObject, AbstractMesh));
        } else if (Reflect.hasField(source, "clone")) {
            return Reflect.callMethod(source, "clone", []);
        }
        return null;
    };

	public static function IsEmpty(obj:Dynamic):Bool {
		if(Std.is(obj, Array)) {
			for (i in cast(obj, Array<Dynamic>)) {
				return false;
			}
		}
		return true;
	}

	public static function Now():Float {
		return getTimer();
	}
	
	private static function getTimer():Int {		
		#if flash
		return flash.Lib.getTimer ();
		#else
		return Std.int ((Timer.stamp () - __startTime) * 1000);
		#end		
	}
	
}
