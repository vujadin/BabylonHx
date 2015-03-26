package com.babylonhx.tools;

#if js
import js.html.Element;
import js.html.XMLHttpRequest;
#end

import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.mesh.AbstractMesh;
import haxe.Json;
import haxe.Timer;

import com.babylonhx.utils.Image;


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
	
	// moved here as build gives an error that haxe.Timer has no delay method...
	public static function delay( f : Void -> Void, time_ms : Int ) {
		#if snow
		var t = new snow.utils.Timer(time_ms);
		#elseif lime
		var t = new haxe.Timer(time_ms);
		#elseif kha
		
		#end
		t.run = function() {
			t.stop();
			f();
		};
		return t;
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
			
		if(Reflect.hasField(obj, "get")) {
		//if (Std.is(obj, Map)) {
			var ret:Array<Dynamic> = [];
			for (key in cast(obj, Map<Dynamic, Dynamic>).keys()) {
				ret.push(obj.get(key));
			}
			return ret;
		}
		
		return Std.is(obj, Array) ? obj : [obj];
	}
	
	#if snow
	public static function LoadFile(path:String, ?callbackFn:Dynamic->Void, type:String = "") {		
		#if js
		var callBackFunction = callbackFn != null ?
			function(result:Dynamic) {
				callbackFn(result.bytes);
			} : function(_) { };
			
		var httpRequest = new XMLHttpRequest();
		httpRequest.onreadystatechange = function(_) {
			if (httpRequest.readyState == 4) {
				if (httpRequest.status == 200) {
					if (callBackFunction != null) {
						callBackFunction(httpRequest.responseText);
					}
				}
			}
		};
		httpRequest.open('GET', path);
		httpRequest.send();
		#else
		if (type == "") {
			if (SnowApp._snow.assets.exists(path)) {
				if (StringTools.endsWith(path, "bbin")) {
					var callBackFunction = callbackFn != null ?
						function(result:Dynamic) {
							callbackFn(result.bytes);
						} : function(_) { };
					SnowApp._snow.assets.bytes(path, { onload: callBackFunction } );	
				} 
				else {
					var callBackFunction = callbackFn != null ?
						function(result:Dynamic) {
							callbackFn(result.text);
						} : function(_) { };
					SnowApp._snow.assets.text(path, { onload: callBackFunction } );
				}
			} else {
				trace("File '" + path + "' doesn't exist!");
			}
		} else {
			if(SnowApp._snow.assets.exists(path)) {
				switch(type) {
					case "text":
						var callBackFunction = callbackFn != null ?
							function(result:Dynamic) {
								callbackFn(result.text);
							} : function(_) { };
						SnowApp._snow.assets.text(path, { onload: callBackFunction } );
						
					case "bin":
						var callBackFunction = callbackFn != null ?
							function(result:Dynamic) {
								callbackFn(result.bytes);
							} : function(_) { };
						SnowApp._snow.assets.bytes(path, { onload: callBackFunction });
						
					case "img":
						var callBackFunction = callbackFn != null ?
							function(result:Dynamic) {
								callbackFn(result.image);
							} : function(_) { };
						SnowApp._snow.assets.image(path, { onload: callBackFunction });
				}
			} else {
				trace("File '" + path + "' doesn't exist!");
			}
		}
		#end
    }
	#elseif lime
	public static function LoadFile(path:String, ?callbackFn:Dynamic->Void, type:String = "") {			
		if (type == "") {
			if (lime.Assets.exists(path)) {
				if (StringTools.endsWith(path, "bbin")) {
					var callBackFunction = callbackFn != null ?
						function(result:Dynamic) {
							callbackFn(result);
						} : function(_) { };
					var data = lime.Assets.getBytes(path);// , { onload: callBackFunction } );	
					callBackFunction(data);
				} 
				else {
					var callBackFunction = callbackFn != null ?
						function(result:Dynamic) {
							callbackFn(result);
						} : function(_) { };
					var data = lime.Assets.getText(path);// , { onload: callBackFunction } );
					callBackFunction(data);
				}
			} else {
				trace("File '" + path + "' doesn't exist!");
			}
		} else {
			if(lime.Assets.exists(path)) {
				switch(type) {
					case "text":
					var callBackFunction = callbackFn != null ?
						function(result:Dynamic) {
							callbackFn(result);
						} : function(_) { };
					var data = lime.Assets.getText(path);// , { onload: callBackFunction } );
					callBackFunction(data);
						
					case "bin":
						var callBackFunction = callbackFn != null ?
							function(result:Dynamic) {
								callbackFn(result);
							} : function(_) { };
						var data = lime.Assets.getBytes(path);// , { onload: callBackFunction } );	
						callBackFunction(data);
						
					case "img":
						var img = lime.Assets.getImage(path);// , { onload: onload } );
						var image = new Image(img.data, img.width, img.height);
						if (callbackFn != null) {
							callbackFn(image);
						}
				}
			} else {
				trace("File '" + path + "' doesn't exist!");
			}
		}
    }
	#elseif kha
	
	#end
	
	#if snow
	public static function LoadImage(url:String, onload:Image->Void, ?onerror:Void->Void, ?db:Dynamic) { 
		if (SnowApp._snow.assets.exists(url)) {
			var callbackFn = function(img:snow.assets.AssetImage) {
				var i = new Image(img.image.data, img.image.width, img.image.height);
				onload(i);
			};
			#if !js			
			var img = SnowApp._snow.assets.image(url, { onload: callbackFn });
			//onload(img);
			#else
			SnowApp._snow.assets.image(url, { onload: callbackFn });
			#end
		} else {
			trace("Image '" + url + "' doesn't exist!");
		}
    } 
	#elseif lime
	public static function LoadImage(url:String, onload:Image->Void, ?onerror:Void->Void, ?db:Dynamic) { 
		if (lime.Assets.exists(url)) {
			var img = lime.Assets.getImage(url);// , { onload: onload } );
			var image = new Image(img.data, img.width, img.height);
			onload(image);			
		} else {
			trace("Image '" + url + "' doesn't exist!");
		}
    }
	#elseif kha
	
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
		if (value == 0) {
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
            return source.clone();// Reflect.callMethod(source, "clone", []);
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
		return Std.int ((Timer.stamp() - __startTime) * 1000);
		#end		
	}
	
	public static inline function uuid():String {
		var specialChars = ['8', '9', 'A', 'B'];
		
		var createRandomIdentifier = function(length:Int, radix:Int = 61):String {
			var characters = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'];
			var id:Array<String>   = new Array<String>();
			radix                  = (radix > 61) ? 61 : radix;
			
			while (length-- > 0) {
				id.push(characters[randomInt(0, radix)]);
			}
			
			return id.join('');
		}
		
		return createRandomIdentifier(8, 15) + '-' + createRandomIdentifier(4, 15) + '-4' + createRandomIdentifier(3, 15) + '-' + randomInt(0, 3) + createRandomIdentifier(3, 15) + '-' + createRandomIdentifier(12, 15);
	}
	
	public static inline function randomInt(from:Int, to:Int):Int {
		return from + Math.floor(((to - from + 1) * Math.random()));
	}
	
}
