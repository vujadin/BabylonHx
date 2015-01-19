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

typedef BabylonMinMax = {
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
	
	public static function LoadFile(url:String, callbackFn:String->Void, ?progressCallBack:Dynamic, ?db:Dynamic) {
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
			var file:String = Assets.getText(url);
			callbackFn(file);
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

	// Misc.
	/*public static function GetPointerPrefix():String {
		var eventPrefix = "pointer";

		// Check if hand.js is referenced or if the browser natively supports pointer events
		if (!navigator.pointerEnabled) {
			eventPrefix = "mouse";
		}

		return eventPrefix;
	}

	public static QueueNewFrame(func) {
		if (window.requestAnimationFrame)
			window.requestAnimationFrame(func);
		else if (window.msRequestAnimationFrame)
			window.msRequestAnimationFrame(func);
		else if (window.webkitRequestAnimationFrame)
			window.webkitRequestAnimationFrame(func);
		else if (window.mozRequestAnimationFrame)
			window.mozRequestAnimationFrame(func);
		else if (window.oRequestAnimationFrame)
			window.oRequestAnimationFrame(func);
		else {
			window.setTimeout(func, 16);
		}
	}

	public static RequestFullscreen(element) {
		if (element.requestFullscreen)
			element.requestFullscreen();
		else if (element.msRequestFullscreen)
			element.msRequestFullscreen();
		else if (element.webkitRequestFullscreen)
			element.webkitRequestFullscreen();
		else if (element.mozRequestFullScreen)
			element.mozRequestFullScreen();
	}

	public static ExitFullscreen() {
		if (document.exitFullscreen) {
			document.exitFullscreen();
		}
		else if (document.mozCancelFullScreen) {
			document.mozCancelFullScreen();
		}
		else if (document.webkitCancelFullScreen) {
			document.webkitCancelFullScreen();
		}
		else if (document.msCancelFullScreen) {
			document.msCancelFullScreen();
		}
	}

	// External files
	public static CleanUrl(url:string):string {
		url = url.replace(/#/mg, "%23");
		return url;
	}

	public static LoadImage(url:string, onload, onerror, database):HTMLImageElement {
		url = Tools.CleanUrl(url);

		var img = new Image();

		if (url.substr(0, 5) != "data:")
			img.crossOrigin = 'anonymous';

		img.onload = () => {
			onload(img);
		};

		img.onerror = err => {
			onerror(img, err);
		};

		var noIndexedDB = () => {
			img.src = url;
		};

		var loadFromIndexedDB = () => {
			database.loadImageFromDB(url, img);
		};


		//ANY database to do!
		if (database && database.enableTexturesOffline && BABYLON.Database.isUASupportingBlobStorage) {
			database.openAsync(loadFromIndexedDB, noIndexedDB);
		}
		else {
			if (url.indexOf("file:") === -1) {
				noIndexedDB();
			}
			else {
				try {
					var textureName = url.substring(5);
					var blobURL;
					try {
						blobURL = URL.createObjectURL(BABYLON.FilesInput.FilesTextures[textureName], { oneTimeOnly:true });
					}
					catch (ex) {
						// Chrome doesn't support oneTimeOnly parameter
						blobURL = URL.createObjectURL(BABYLON.FilesInput.FilesTextures[textureName]);
					}
					img.src = blobURL;
				}
				catch (e) {
					Tools.Log("Error while trying to load texture:" + textureName);
					img.src = null;
				}
			}
		}

		return img;
	}

	//ANY
	public static LoadFile(url:string, callback:(data:any) => Void, progressCallBack?:() => Void, database?, useArrayBuffer?:Bool, onError?:() => Void) {
		url = Tools.CleanUrl(url);

		var noIndexedDB = () => {
			var request = new XMLHttpRequest();
			var loadUrl = Tools.BaseUrl + url;
			request.open('GET', loadUrl, true);

			if (useArrayBuffer) {
				request.responseType = "arraybuffer";
			}

			request.onprogress = progressCallBack;

			request.onreadystatechange = () => {
				if (request.readyState == 4) {
					if (request.status == 200 || BABYLON.Tools.ValidateXHRData(request, !useArrayBuffer ? 1 :6)) {
						callback(!useArrayBuffer ? request.responseText :request.response);
					} else { // Failed
						if (onError) {
							onError();
						} else {

							throw new Error("Error status:" + request.status + " - Unable to load " + loadUrl);
						}
					}
				}
			};

			request.send(null);
		};

		var loadFromIndexedDB = () => {
			database.loadFileFromDB(url, callback, progressCallBack, noIndexedDB, useArrayBuffer);
		};

		if (url.indexOf("file:") !== -1) {
			var fileName = url.substring(5);
			BABYLON.Tools.ReadFile(BABYLON.FilesInput.FilesToLoad[fileName], callback, progressCallBack, true);
		}
		else {
			// Caching all files
			if (database && database.enableSceneOffline) {
				database.openAsync(loadFromIndexedDB, noIndexedDB);
			}
			else {
				noIndexedDB();
			}
		}
	}

	public static ReadFileAsDataURL(fileToLoad, callback, progressCallback) {
		var reader = new FileReader();
		reader.onload = e => {
			callback(e.target.result);
		};
		reader.onprogress = progressCallback;
		reader.readAsDataURL(fileToLoad);
	}

	public static ReadFile(fileToLoad, callback, progressCallBack, useArrayBuffer?:Bool) {
		var reader = new FileReader();
		reader.onload = e => {
			callback(e.target.result);
		};
		reader.onprogress = progressCallBack;
		if (!useArrayBuffer) {
			// Asynchronous read
			reader.readAsText(fileToLoad);
		}
		else {
			reader.readAsArrayBuffer(fileToLoad);
		}
	}*/

	// Misc. 
	public static function Clamp(value:Float, min:Float = 0, max:Float = 1):Float {
		return Math.min(max, Math.max(min, value));
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

	public static function WithinEpsilon(a:Float, b:Float):Bool {
		var num = a - b;
		return -1.401298E-45 <= num && num <= 1.401298E-45;
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

	/*public static RegisterTopRootEvents(events:{ name:string; handler:EventListener }[]) {
		for (var index = 0; index < events.length; index++) {
			var event = events[index];
			window.addEventListener(event.name, event.handler, false);

			try {
				if (window.parent) {
					window.parent.addEventListener(event.name, event.handler, false);
				}
			} catch (e) {
				// Silently fails...
			}
		}
	}

	public static UnregisterTopRootEvents(events:{ name:string; handler:EventListener }[]) {
		for (var index = 0; index < events.length; index++) {
			var event = events[index];
			window.removeEventListener(event.name, event.handler);

			try {
				if (window.parent) {
					window.parent.removeEventListener(event.name, event.handler);
				}
			} catch (e) {
				// Silently fails...
			}
		}
	}*/

	/*public static CreateScreenshot(engine:Engine, camera:Camera, size:any) {
		var width:number;
		var height:number;

		var scene = camera.getScene();
		var previousCamera:BABYLON.Camera = null;

		if (scene.activeCamera !== camera) {
			previousCamera = scene.activeCamera;
			scene.activeCamera = camera;
		}

		//If a precision value is specified
		if (size.precision) {
			width = Math.round(engine.getRenderWidth() * size.precision);
			height = Math.round(width / engine.getAspectRatio(camera));
			size = { width:width, height:height };
		}
		else if (size.width && size.height) {
			width = size.width;
			height = size.height;
		}
		//If passing only width, computing height to keep display canvas ratio.
		else if (size.width && !size.height) {
			width = size.width;
			height = Math.round(width / engine.getAspectRatio(camera));
			size = { width:width, height:height };
		}
		//If passing only height, computing width to keep display canvas ratio.
		else if (size.height && !size.width) {
			height = size.height;
			width = Math.round(height * engine.getAspectRatio(camera));
			size = { width:width, height:height };
		}
		//Assuming here that "size" parameter is a number
		else if (!isNaN(size)) {
			height = size;
			width = size;
		}
		else {
			Tools.Error("Invalid 'size' parameter !");
			return;
		}

		//At this point size can be a number, or an object (according to engine.prototype.createRenderTargetTexture method)
		var texture = new RenderTargetTexture("screenShot", size, engine.scenes[0], false, false);
		texture.renderList = engine.scenes[0].meshes;

		texture.onAfterRender = () => {
			// Read the contents of the framebuffer
			var numberOfChannelsByLine = width * 4;
			var halfHeight = height / 2;

			//Reading datas from WebGL
			var data = engine.readPixels(0, 0, width, height);


			//To flip image on Y axis.
			for (var i = 0; i < halfHeight; i++) {
				for (var j = 0; j < numberOfChannelsByLine; j++) {
					var currentCell = j + i * numberOfChannelsByLine;
					var targetLine = height - i - 1;
					var targetCell = j + targetLine * numberOfChannelsByLine;

					var temp = data[currentCell];
					data[currentCell] = data[targetCell];
					data[targetCell] = temp;
				}
			}

			// Create a 2D canvas to store the result
			if (!screenshotCanvas) {
				screenshotCanvas = document.createElement('canvas');
			}
			screenshotCanvas.width = width;
			screenshotCanvas.height = height;
			var context = screenshotCanvas.getContext('2d');

			// Copy the pixels to a 2D canvas
			var imageData = context.createImageData(width, height);
			imageData.data.set(data);
			context.putImageData(imageData, 0, 0);

			var base64Image = screenshotCanvas.toDataURL();

			//Creating a link if the browser have the download attribute on the a tag, to automatically start download generated image.
			if (("download" in document.createElement("a"))) {
				var a = window.document.createElement("a");
				a.href = base64Image;
				var date = new Date();
				var stringDate = date.getFullYear() + "/" + date.getMonth() + "/" + date.getDate() + "-" + date.getHours() + ":" + date.getMinutes();
				a.setAttribute("download", "screenshot-" + stringDate + ".png");

				window.document.body.appendChild(a);

				a.addEventListener("click", () => {
					a.parentElement.removeChild(a);
				});
				a.click();

				//Or opening a new tab with the image if it is not possible to automatically start download.
			} else {
				var newWindow = window.open("");
				var img = newWindow.document.createElement("img");
				img.src = base64Image;
				newWindow.document.body.appendChild(img);
			}

		};

		texture.render(true);
		texture.dispose();

		if (previousCamera) {
			scene.activeCamera = previousCamera;
		}
	}

	// XHR response validator for local file scenario
	public static ValidateXHRData(xhr:XMLHttpRequest, dataType = 7):Bool {
		// 1 for text (.babylon, manifest and shaders), 2 for TGA, 4 for DDS, 7 for all

		try {
			if (dataType & 1) {
				if (xhr.responseText && xhr.responseText.length > 0) {
					return true;
				} else if (dataType === 1) {
					return false;
				}
			}

			if (dataType & 2) {
				// Check header width and height since there is no "TGA" magic number
				var tgaHeader = BABYLON.Internals.TGATools.GetTGAHeader(xhr.response);

				if (tgaHeader.width && tgaHeader.height && tgaHeader.width > 0 && tgaHeader.height > 0) {
					return true;
				} else if (dataType === 2) {
					return false;
				}
			}

			if (dataType & 4) {
				// Check for the "DDS" magic number
				var ddsHeader = new Uint8Array(xhr.response, 0, 3);

				if (ddsHeader[0] == 68 && ddsHeader[1] == 68 && ddsHeader[2] == 83) {
					return true;
				} else {
					return false;
				}
			}

		} catch (e) {
			// Global protection
		}

		return false;
	}*/

	// Logs
	/*public static var NoneLogLevel:Int = 0;
	public static var MessageLogLevel:Int = 1;
	public static var WarningLogLevel:Int = 2;
	public static var ErrorLogLevel:Int = 4;

	public static AllLogLevel:Int = Tools._MessageLogLevel | Tools._WarningLogLevel | Tools._ErrorLogLevel;

	private static _FormatMessage(message:string):string {
		var padStr = i => (i < 10) ? "0" + i :"" + i;

		var date = new Date();
		return "BJS - [" + padStr(date.getHours()) + ":" + padStr(date.getMinutes()) + ":" + padStr(date.getSeconds()) + "]:" + message;
	}

	public static Log:(message:string) => Void = Tools._LogEnabled;

	private static _LogDisabled(message:string) {
		// nothing to do
	}
	private static _LogEnabled(message:string) {
		console.log(Tools._FormatMessage(message));
	}

	public static Warn:(message:string) => Void = Tools._WarnEnabled;

	private static _WarnDisabled(message:string) {
		// nothing to do
	}
	private static _WarnEnabled(message:string) {
		console.warn(Tools._FormatMessage(message));
	}

	public static Error:(message:string) => Void = Tools._ErrorEnabled;

	private static _ErrorDisabled(message:string) {
		// nothing to do
	}
	private static _ErrorEnabled(message:string) {
		console.error(Tools._FormatMessage(message));
	}

	public static set LogLevels(level:number) {
		if ((level & Tools.MessageLogLevel) === Tools.MessageLogLevel) {
			Tools.Log = Tools._LogEnabled;
		}
		else {
			Tools.Log = Tools._LogDisabled;
		}

		if ((level & Tools.WarningLogLevel) === Tools.WarningLogLevel) {
			Tools.Warn = Tools._WarnEnabled;
		}
		else {
			Tools.Warn = Tools._WarnDisabled;
		}

		if ((level & Tools.ErrorLogLevel) === Tools.ErrorLogLevel) {
			Tools.Error = Tools._ErrorEnabled;
		}
		else {
			Tools.Error = Tools._ErrorDisabled;
		}
	}

	// Performances
	private static _PerformanceNoneLogLevel = 0;
	private static _PerformanceUserMarkLogLevel = 1;
	private static _PerformanceConsoleLogLevel = 2;

	private static _performance:Performance = window.performance;

	static get PerformanceNoneLogLevel():number {
		return Tools._PerformanceNoneLogLevel;
	}

	static get PerformanceUserMarkLogLevel():number {
		return Tools._PerformanceUserMarkLogLevel;
	}

	static get PerformanceConsoleLogLevel():number {
		return Tools._PerformanceConsoleLogLevel;
	}

	public static set PerformanceLogLevel(level:number) {
		if ((level & Tools.PerformanceUserMarkLogLevel) === Tools.PerformanceUserMarkLogLevel) {
			Tools.StartPerformanceCounter = Tools._StartUserMark;
			Tools.EndPerformanceCounter = Tools._EndUserMark;
			return;
		}

		if ((level & Tools.PerformanceConsoleLogLevel) === Tools.PerformanceConsoleLogLevel) {
			Tools.StartPerformanceCounter = Tools._StartPerformanceConsole;
			Tools.EndPerformanceCounter = Tools._EndPerformanceConsole;
			return;
		}

		Tools.StartPerformanceCounter = Tools._StartPerformanceCounterDisabled;
		Tools.EndPerformanceCounter = Tools._EndPerformanceCounterDisabled;
	}

	static _StartPerformanceCounterDisabled(counterName:string, condition?:Bool) {
	}

	static _EndPerformanceCounterDisabled(counterName:string, condition?:Bool) {
	}

	static _StartUserMark(counterName:string, condition = true) {
		if (!condition || !Tools._performance.mark) {
			return;
		}
		Tools._performance.mark(counterName + "-Begin");
	}

	static _EndUserMark(counterName:string, condition = true) {
		if (!condition || !Tools._performance.mark) {
			return;
		}
		Tools._performance.mark(counterName + "-End");
		Tools._performance.measure(counterName, counterName + "-Begin", counterName + "-End");
	}

	static _StartPerformanceConsole(counterName:string, condition = true) {
		if (!condition) {
			return;
		}

		Tools._StartUserMark(counterName, condition);

		if (console.time) {
			console.time(counterName);
		}
	}

	static _EndPerformanceConsole(counterName:string, condition = true) {
		if (!condition) {
			return;
		}

		Tools._EndUserMark(counterName, condition);

		if (console.time) {
			console.timeEnd(counterName);
		}
	}

	public static StartPerformanceCounter:(counterName:string, condition?:Bool) => Void = Tools._StartPerformanceCounterDisabled;
	public static EndPerformanceCounter:(counterName:string, condition?:Bool) => Void = Tools._EndPerformanceCounterDisabled;*/

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
