package com.babylonhx.tools;

#if (js || purejs)
import js.Browser;
import js.html.Element;
import js.html.XMLHttpRequest;
import js.html.XMLHttpRequestResponseType;
#end

import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.mesh.AbstractMesh;
import lime.utils.Int32Array;

import com.babylonhx.utils.Image;
import lime.utils.UInt8Array;

import haxe.io.BytesInput;
import haxe.io.Bytes;
import haxe.crypto.Base64;
import haxe.Json;
import haxe.Timer;

//#if openfl
//typedef Assets = openfl.Assets;
//#elseif lime
typedef Assets = lime.Assets;
//#end


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Tools') class Tools {
	
	public static var BaseUrl:String = "";
	
	@:noCompletion private static var __startTime:Float = Timer.stamp();
	
	#if snow
	@:noCompletion public static var app:snow.Snow;
	#end

	public static function __init__(){
		#if purejs
		untyped Browser.window.requestAnimationFrame = window.requestAnimationFrame
													   || window.mozRequestAnimationFrame
													   || window.webkitRequestAnimationFrame
													   || window.msRequestAnimationFrame
													   || window.oRequestAnimationFrame;
		#end
	}
	
	public static function Log(msg:String) {
		trace(msg);
	}

	public static function Warn(msg:String) {
		trace('Warning! ' + msg);
	}
	
	public static function Error(msg:String) {
		trace('!!! ERROR !!! ' + msg);
	}
	
	public static function SetImmediate(action:Dynamic/*Void->Void*/) {
		delay(action, 1);
	}
	
	#if (js || purejs)
	public static function GetDOMTextContent(element:js.html.Element):String {
		var result = "";
		var child = element.firstChild;
		
		while (child != null) {
			if (child.nodeType == 3) {
				result += child.textContent;
			}
			child = child.nextSibling;
		}
		
		return result;
	}
	#end
	
	public static function GetFilename(path:String):String {
		var index = path.lastIndexOf("/");
		if (index < 0) {
			return path;
		}
		
		return path.substring(index + 1);
	}
	
	// Snow build gives an error that haxe.Timer has no delay method...
	public static function delay(f:Void->Void, time_ms:Int) {
		var t = new haxe.Timer(time_ms);
		t.run = function() {
			t.stop();
			f();
		};
		return t;
	}

	public static function MakeArray(obj:Dynamic, allowsNullUndefined:Bool = false):Array<Dynamic> {
		if (allowsNullUndefined != true && obj == null) {
			return null;
		}
		
		if(!Std.is(obj, Array) && Reflect.getProperty(obj, "keys") != null) {
			var ret:Array<Dynamic> = [];
			var map:Map<Dynamic, Dynamic> = cast obj;
			for (key in map.keys()) {
				ret.push(map[key]);
			}
			return ret;
		}
		
		return Std.is(obj, Array) ? obj : [obj];
	}
	
	// Misc.
	#if (js || purejs)
	public static function GetPointerPrefix():String {
		var eventPrefix = "pointer";
		
		// Check if hand.js is referenced or if the browser natively supports pointer events
		if (untyped !Browser.navigator.pointerEnabled) {
			eventPrefix = "mouse";
		}
		
		return eventPrefix;
	}

	public inline static function QueueNewFrame(func:Dynamic->Void):Void {
		Browser.window.requestAnimationFrame(func);
	}
	
	public static function RegisterTopRootEvents(events:Array<Dynamic>) {
		for (event in events) {
			Browser.window.addEventListener(event.name, event.handler, false);
			
			try {
				if (Browser.window.parent != null) {
					Browser.window.parent.addEventListener(event.name, event.handler, false);
				}
			} catch (e:Dynamic) {
				// Silently fails...
			}
		}
	}

	public static function UnregisterTopRootEvents(events:Array<Dynamic>) {
		for (event in events) {
			Browser.window.removeEventListener(event.name, event.handler);
			
			try {
				if (Browser.window.parent != null) {
					Browser.window.parent.removeEventListener(event.name, event.handler);
				}
			} catch (e:Dynamic) {
				// Silently fails...
			}
		}
	}
	#end
	
	// External files
	public static function CleanUrl(url:String):String {
		var regex = ~/#/mg;
		url = regex.replace(url, "%23");
		return url;
	}
	
	#if (purejs)
	public static function LoadFile(url:String, callbackFn:Dynamic->Void, ?progressCallBack:Dynamic->Void, ?database:Dynamic, useArrayBuffer:Bool = false, ?onError:Void->Void) {
		url = Tools.CleanUrl(url);
		
		var noIndexedDB = function() {
			var request = new XMLHttpRequest();
			var loadUrl = Tools.BaseUrl + url;
			request.open('GET', loadUrl, true);
			
			if (useArrayBuffer) {
				request.responseType = XMLHttpRequestResponseType.ARRAYBUFFER;
			}
			
			request.onprogress = progressCallBack;
			
			request.onreadystatechange = function(e) {
				if (request.readyState == 4) {
					if (request.status == 200/* || Tools.ValidateXHRData(request, !useArrayBuffer ? 1 : 6)*/) {
						callbackFn(!useArrayBuffer ? request.responseText : request.response);
					} 
					else { // Failed
						if (onError != null) {
							onError();
						} 
						else {
							throw("Error status: " + request.status + " - Unable to load " + loadUrl);
						}
					}
				}
			};
			
			request.send(null);
		};
		
		var loadFromIndexedDB = function() {
			database.loadFileFromDB(url, callbackFn, progressCallBack, noIndexedDB, useArrayBuffer);
		};
		
		if (url.indexOf("file:") != -1) {
			var fileName = url.substring(5);
			//Tools.ReadFile(FilesInput.FilesToLoad[fileName], callback, progressCallBack, true);
		}
		else {
			// Caching all files
			if (database != null && database.enableSceneOffline) {
				database.openAsync(loadFromIndexedDB, noIndexedDB);
			}
			else {
				noIndexedDB();
			}
		}
	}
	
	// XHR response validator for local file scenario
	public static function ValidateXHRData(xhr:XMLHttpRequest, dataType:Int = 7):Bool {
		// 1 for text (.babylon, manifest and shaders), 2 for TGA, 4 for DDS, 7 for all
		
		/*try {
			if (dataType & 1) {
				if (xhr.responseText && xhr.responseText.length > 0) {
					return true;
				}
				else if (dataType == 1) {
					return false;
				}
			}
			
			if (dataType & 2) {
				// Check header width and height since there is no "TGA" magic number
				var tgaHeader = Internals.TGATools.GetTGAHeader(xhr.response);
				
				if (tgaHeader.width && tgaHeader.height && tgaHeader.width > 0 && tgaHeader.height > 0) {
					return true;
				} 
				else if (dataType == 2) {
					return false;
				}
			}
			
			if (dataType & 4) {
				// Check for the "DDS" magic number
				var ddsHeader = new UInt8Array(xhr.response, 0, 3);
				
				if (ddsHeader[0] == 68 && ddsHeader[1] == 68 && ddsHeader[2] == 83) {
					return true;
				} 
				else {
					return false;
				}
			}
			
		} catch (e) {
			// Global protection
		}*/
		
		return false;
	}
	#elseif snow
	
	#if luxe
	public static function LoadFile(path:String, ?callbackFn:Dynamic->Void, type:String = "") {	
		if (type == "") {
			//if (Luxe.core.app.assets.listed(path)) {
				if (StringTools.endsWith(path, "bbin")) {
					var callBackFunction = callbackFn != null ?
						function(result:Dynamic) {
							callbackFn(result.bytes);
						} : function(_) { };
					Luxe.core.app.assets.bytes(path).then(
						function(asset:Dynamic) {
							callBackFunction(asset);
						}
					);
				} 
				else {
					var callBackFunction = callbackFn != null ?
						function(result:Dynamic) {
							callbackFn(result.text);
						} : function(_) { };
					Luxe.core.app.assets.text(path).then(
						function(asset:Dynamic) {
							callBackFunction(asset);
						}
					);
				}
			//} 
			//else {
			//	trace("File '" + path + "' doesn't exist!");
			//}
		} 
		else {
			//if(Luxe.core.app.assets.listed(path)) {
				switch(type) {
					case "text":
						var callBackFunction = callbackFn != null ?
							function(result:Dynamic) {
								callbackFn(result.text);
							} : function(_) { };
						Luxe.core.app.assets.text(path).then(
							function(asset:Dynamic) {
								callBackFunction(asset);
							}
						);					
						
					case "bin":
						var callBackFunction = callbackFn != null ?
							function(result:Dynamic) {
								callbackFn(result.bytes);
							} : function(_) { };
						Luxe.core.app.assets.bytes(path).then(
							function(asset:Dynamic) {
								callBackFunction(asset);
							}
						);
						
					case "img":
						var callBackFunction = callbackFn != null ?
							function(img:Dynamic) {
								var i = new Image(img.image.pixels, img.image.width, img.image.height);
								callbackFn(i);
							} : function(_) { };
						Luxe.core.app.assets.image(path).then(
							function(asset:Dynamic) {
								callBackFunction(asset);
							}
						);
				}
			//} 
			//else {
			//	trace("File '" + path + "' doesn't exist!");
			//}
		}
	}
	#else //snow
	public static function LoadFile(path:String, ?callbackFn:Dynamic->Void, type:String = "") {	
		if (type == "hdr") {
			var callBackFunction = callbackFn != null ?
				function(result:Dynamic) {
					callbackFn(result);
				} : function(_) { };
				
			app.assets.bytes(path).then(
				function(result:Dynamic) {
					trace(result.bytes);
					callBackFunction(result.bytes);	
				}
			);
		}
		else if (type == "") {
			//if (SnowApp._snow.assets.listed(path)) {
				if (StringTools.endsWith(path, "bbin")) {
					var callBackFunction = callbackFn != null ?
						function(result:Dynamic) {
							callbackFn(result.bytes);
						} : function(_) { };
					app.assets.text(path).then(
						function(asset:Dynamic) {
							callBackFunction(asset);
						}
					);
				} 
				else {
					var callBackFunction = callbackFn != null ?
						function(result:Dynamic) {
							callbackFn(result.text);
						} : function(_) { };
					app.assets.text(path).then(
						function(asset:Dynamic) {
							callBackFunction(asset);
						}
					);
				}
			//} 
			//else {
			//	trace("File '" + path + "' doesn't exist!");
			//}
		} 
		else {
			//if(SnowApp._snow.assets.listed(path)) {
				switch(type) {
					case "text":
						var callBackFunction = callbackFn != null ?
							function(result:Dynamic) {
								callbackFn(result.text);
							} : function(_) { };
						app.assets.text(path).then(
							function(asset:Dynamic) {
								callBackFunction(asset);
							}
						);					
						
					case "bin":
						var callBackFunction = callbackFn != null ?
							function(result:Dynamic) {
								callbackFn(result.bytes);
							} : function(_) { };
						app.assets.bytes(path).then(
							function(asset:Dynamic) {
								callBackFunction(asset);
							}
						);
						
					case "img":
						var callBackFunction = callbackFn != null ?
							function(img:Dynamic) {
								var i = new Image(img.image.pixels, img.image.width, img.image.height);
								callbackFn(i);
							} : function(_) { };
						app.assets.image(path).then(
							function(asset:Dynamic) {
								callBackFunction(asset);
							}
						);
						
					case "ctm":
						var callBackFunction = callbackFn != null ?
							function(result:Dynamic) {
								callbackFn(result.bytes);
							} : function(_) { };
						app.assets.bytes(path).then(
							function(asset:Dynamic) {
								callBackFunction(asset);
							}
						);
				}
			//} 
			//else {
			//	trace("File '" + path + "' doesn't exist!");
			//}
		}
	}
	#end // if luxe
	
	#elseif (lime || openfl || nme)
	public static function LoadFile(path:String, ?callbackFn:Dynamic->Void, type:String = "") {	
		if (type == "hdr" || type == "dds") {
			var callBackFunction = callbackFn != null ?
				function(result:Dynamic) {
					callbackFn(result);
				} : function(_) { };
				
			// VK: Assets.getBytes returns some crap, must use Assets.loadBytes
			//var data = Assets.getBytes(path);
			//callBackFunction(data);
			
			var future = Assets.loadBytes(path);
			future.onComplete(function(data:Dynamic):Void {
				callBackFunction(data);
			});
		}
		else if (type == "" || type == "text") {
			/*#if ((html5 || js) && (lime || openfl))
			if (Assets.exists(path)) {
							
				var callBackFunction = callbackFn != null ?
					function(result:Dynamic) {
						callbackFn(result);
					} : function(_) { };
					
				var future = Assets.loadText(path);
				future.onComplete(function(data:String):Void {
					callBackFunction(data);
				});					
			} 
			else {
				trace("File '" + path + "' doesn't exist!");
			}
			#else*/
			var callBackFunction = callbackFn != null ?
					function(result:Dynamic) {
						callbackFn(result);
					} : function(_) { };
					
				var data = Assets.getText(path);
				callBackFunction(data);			
			//#end
		} 
		else {
			#if (lime || openfl)
			if (Assets.exists(path)) {
			#end
				switch(type) {						
					case "img":
						//#if openfl
						//var img = Assets.getBitmapData(path);
						//#if openfl_legacy
						//var image = new Image(new UInt8Array(openfl.display.BitmapData.getRGBAPixels(img)), img.width, img.height);
						//#else
						//var image = new Image(img.image.data, img.width, img.height);
						//#end
						//if (callbackFn != null) {
							//callbackFn(image);
						//}
						//#elseif lime
						var img = Assets.getImage(path);
						var image = new Image(img.data, img.width, img.height);
						if (callbackFn != null) {
							callbackFn(image);
						}						
						//#elseif nme
						//var img = Assets.getBitmapData(path);
						//var image = new Image(new UInt8Array(nme.display.BitmapData.getRGBAPixels(img)), img.width, img.height);
						//if (callbackFn != null) {
							//callbackFn(image);
						//}
						//#end
						
					case "ctm":
						#if lime
						var file = Assets.getBytes(path);
						if (callbackFn != null) {
							callbackFn(file);
						}
						#end
				}
			} 
			#if (lime || openfl)
			else {
				trace("File '" + path + "' doesn't exist!");
			}
			#end
		}
	}
	#elseif kha
	
	#end
	
	
	#if (purejs)
	public static function LoadImage(url:String, ?callbackFn:Dynamic->Void, ?onerror:Dynamic->Void, ?db:Dynamic):Dynamic {
		url = Tools.CleanUrl(url);
		
		var img = new js.html.Image();
		
		if (url.substr(0, 5) != "data:") {
			img.crossOrigin = 'anonymous';
		}
		
		img.onload = function(e) {
			var canvas:js.html.CanvasElement = Browser.document.createCanvasElement();
			canvas.width = img.width;
			canvas.height = img.height;
			var ctx:js.html.CanvasRenderingContext2D = canvas.getContext2d();
			ctx.drawImage(img, 0, 0, img.width, img.height, 0, 0, img.width, img.height);
			var imgData = ctx.getImageData(0, 0, img.width, img.height).data;
			
			// ugly hack ...
			var normalArray:Dynamic = null;
			untyped normalArray = Array.prototype.slice.call(imgData);
			
			if (callbackFn != null) {
				callbackFn(new Image(new UInt8Array(normalArray), img.width, img.height));
			}			
		};
		
		/*img.onerror = err => {
			onerror(img, err);
		};*/
		
		/*var noIndexedDB = function() {
			img.src = url;
		};
		
		var loadFromIndexedDB = function() {
			database.loadImageFromDB(url, img);
		};
		
		//ANY database to do!
		if (database && database.enableTexturesOffline && Database.IsUASupportingBlobStorage) {
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
						blobURL = URL.createObjectURL(FilesInput.FilesTextures[textureName], { oneTimeOnly: true });
					}
					catch (ex) {
						// Chrome doesn't support oneTimeOnly parameter
						blobURL = URL.createObjectURL(FilesInput.FilesTextures[textureName]);
					}
					img.src = blobURL;
				}
				catch (e) {
					Tools.Log("Error while trying to load texture: " + textureName);
					img.src = null;
				}
			}
		}*/
		
		img.src = url;
		
		return img;
	}	
	#elseif snow
	
	#if luxe
	public static function LoadImage(url:String, onload:Image->Void, ?onerror:Dynamic->Void, ?db:Dynamic) { 
		//if (Luxe.core.app.assets.listed(url)) {
			var callBackFunction = function(img:Dynamic) {
				var i = new Image(img.image.pixels, img.image.width, img.image.height);
				onload(i);
			};
			
			Luxe.core.app.assets.image(url).then(
				function(asset:Dynamic) {
					callBackFunction(asset);
				}
			);
		//} 
		//else {
		//	trace("Image '" + url + "' doesn't exist!");
		//}
	}
	#else
	public static function LoadImage(url:String, onload:Image->Void, ?onerror:Dynamic->Void, ?db:Dynamic) { 
		var callBackFunction = function(img:Dynamic) {
			var i = new Image(img.image.pixels, img.image.width, img.image.height);
			onload(i);
		};
		
		app.assets.image(url).then(
			function(asset:Dynamic) {
				callBackFunction(asset);
			}
		);
	}
	#end
	
	#elseif (lime || openfl || nme)
	public static function LoadImage(url:String, onload:Image-> Void, ?onerror:Dynamic->Void, ?db:Dynamic) {
		if (url.indexOf('data:image/png;base64') != -1) {
			var img = Assets.getImage("assets/img/envBRDF.png");
			var arr:Array<Int> = [];
			for (i in 0...img.data.length) {
				arr.push(img.data[i]);
			}
			trace(Base64.encode(img.data.toBytes()));
			var image = new Image(img.data, img.width, img.height);
			onload(image);
			return;
		}
		/*#if (openfl && !nme)
		if (Assets.exists(url)) {
			var img = Assets.getBitmapData(url); 
			
			#if openfl_legacy
			onload(new Image(new UInt8Array(openfl.display.BitmapData.getRGBAPixels(img)), img.width, img.height));		
			#else
			if (img.image.format != lime.graphics.PixelFormat.RGBA32) {
				img.image.format = lime.graphics.PixelFormat.RGBA32;
			}
			onload(new Image(img.image.data, img.width, img.height));	
			#end
		} 
		else {
			trace("Image '" + url + "' doesn't exist!");
			onload(Image.createCheckerboard());
		}
		#elseif lime*/
		if (Assets.exists(url)) {
			/*#if (js || html5)
			var future = Assets.loadImage(url);
			future.onComplete(function(img:lime.graphics.Image):Void {
				var image = new Image(img.data, img.width, img.height);
				onload(image);
			});		
			#else*/
			var img = Assets.getImage(url);
			var image = new Image(img.data, img.width, img.height);
			onload(image);
			//#end
		} 
		else {
			trace("Image '" + url + "' doesn't exist!");
			onload(Image.createCheckerboard());
		}		
		/*#elseif nme		
		var img = Assets.getBitmapData(url); 
		onload(new Image(new UInt8Array(nme.display.BitmapData.getRGBAPixels(img)), img.width, img.height));		
		#end*/
	}	
	#end
	
	
	#if (purejs)
	public static function LoadImages(url:String, ?callbackFn:Dynamic->Void, ?onerror:Dynamic->Void, ?db:Dynamic):Dynamic {
		url = Tools.CleanUrl(url);
		
		var img = new js.html.Image();
		
		if (url.substr(0, 5) != "data:") {
			img.crossOrigin = 'anonymous';
		}
		
		img.onload = function(e) {
			var canvas:js.html.CanvasElement = Browser.document.createCanvasElement();
			canvas.width = img.width;
			canvas.height = img.height;
			var ctx:js.html.CanvasRenderingContext2D = canvas.getContext2d();
			ctx.drawImage(img, 0, 0, img.width, img.height, 0, 0, img.width, img.height);
			var imgData = ctx.getImageData(0, 0, img.width, img.height).data;
			
			// ugly hack ...
			var normalArray:Dynamic = null;
			untyped normalArray = Array.prototype.slice.call(imgData);
			
			if (callbackFn != null) {
				callbackFn(new Image(new UInt8Array(normalArray), img.width, img.height));
			}			
		};
		
		/*img.onerror = err => {
			onerror(img, err);
		};*/
		
		/*var noIndexedDB = function() {
			img.src = url;
		};
		
		var loadFromIndexedDB = function() {
			database.loadImageFromDB(url, img);
		};
		
		//ANY database to do!
		if (database && database.enableTexturesOffline && Database.IsUASupportingBlobStorage) {
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
						blobURL = URL.createObjectURL(FilesInput.FilesTextures[textureName], { oneTimeOnly: true });
					}
					catch (ex) {
						// Chrome doesn't support oneTimeOnly parameter
						blobURL = URL.createObjectURL(FilesInput.FilesTextures[textureName]);
					}
					img.src = blobURL;
				}
				catch (e) {
					Tools.Log("Error while trying to load texture: " + textureName);
					img.src = null;
				}
			}
		}*/
		
		img.src = url;
		
		return img;
	}	
	#elseif snow
	
	#if luxe
	public static function LoadImages(url:String, onload:Image->Void, ?onerror:Dynamic->Void, ?db:Dynamic) { 
		//if (Luxe.core.app.assets.listed(url)) {
			var callBackFunction = function(img:Dynamic) {
				var i = new Image(img.image.pixels, img.image.width, img.image.height);
				onload(i);
			};
			
			Luxe.core.app.assets.image(url).then(
				function(asset:Dynamic) {
					callBackFunction(asset);
				}
			);
		//} 
		//else {
		//	trace("Image '" + url + "' doesn't exist!");
		//}
	}
	#else
	public static function LoadImages(url:String, onload:Image->Void, ?onerror:Dynamic->Void, ?db:Dynamic) { 
		var callBackFunction = function(img:Dynamic) {
			var i = new Image(img.image.pixels, img.image.width, img.image.height);
			onload(i);
		};
		
		app.assets.image(url).then(
			function(asset:Dynamic) {
				callBackFunction(asset);
			}
		);
	}
	#end
	
	#elseif (lime || openfl || nme)
	public static function LoadImages(root:String, urls:Array<String>, onload:Map<String, Image>->Void, ?onerror:Dynamic->Void, ?db:Dynamic) { 
		/*#if (openfl && !nme)
		var imgs:Map<String, Image> = new Map();
		for (i in 0...urls.length) {
			var url = root != "" ? root + urls[i] : urls[i];
			if (Assets.exists(url)) {
				var img = Assets.getBitmapData(url); 
				var image = new Image(img.image.data, img.width, img.height);
				imgs.set(urls[i], image);
			} 
			else {
				trace("Image '" + url + "' doesn't exist!");
			}
			
			if (i == urls.length - 1) {
				onload(imgs);
			}
		}
		#elseif lime*/
		var imgs:Map<String, Image> = new Map();
		for (i in 0...urls.length) {
			var url = root != "" ? root + urls[i] : urls[i];
			if (Assets.exists(url)) {
				var img = Assets.getImage(url);
				var image = new Image(img.data, img.width, img.height);
				imgs.set(urls[i], image);
			} 
			else {
				trace("Image '" + url + "' doesn't exist!");
			}
			
			if (i == urls.length - 1) {
				onload(imgs);
			}
		}
		//#end
	}	
	#end
	

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
	
	public static function cloneValue(source:Dynamic, destinationObject:Dynamic):Dynamic {
		if (source == null)
			return null;
			
		if (Std.is(source, Mesh)) {
			return null;
		}
		
		if (Std.is(source, SubMesh)) {
			return cast(source, SubMesh).clone(cast(destinationObject, AbstractMesh));
		}
		else if (Reflect.hasField(source, "clone")) {
			return source.clone();// Reflect.callMethod(source, "clone", []);
		}
		return null;
	}

	public static function IsEmpty(obj:Dynamic):Bool {
		if(Std.is(obj, Array)) {
			for (i in cast(obj, Array<Dynamic>)) {
				return false;
			}
		}
		return true;
	}

	inline public static function Now():Float {
		return getTimer();
	}
	
	inline private static function getTimer():Int {		
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
				id.push(characters[com.babylonhx.math.Tools.RandomInt(0, radix)]);
			}
			
			return id.join('');
		}
		
		return createRandomIdentifier(8, 15) + '-' + createRandomIdentifier(4, 15) + '-4' + createRandomIdentifier(3, 15) + '-' + com.babylonhx.math.Tools.RandomInt(0, 3) + createRandomIdentifier(3, 15) + '-' + createRandomIdentifier(12, 15);
	}	
	
	/**
	 * This method can be used with hashCodeFromStream when your input is an array of values that are either: 
	 * number, string, boolean or custom type implementing the getHashCode():number method.
	 * @param array
	 */
	public static function arrayOrStringFeeder(array:Dynamic):Int->Int {
		return function(index:Int):Int {
			if (index >= array.length) {
				return -9999;
			}
			
			var val:Dynamic = array.charCodeAt != null ? array.charCodeAt(index) : array[index];
			if (val != null && val.getHashCode != null) {
				val = val.getHashCode();
			}
			if (Std.is(val, String)) {
				return Tools.hashCodeFromStream(Tools.arrayOrStringFeeder(val));
			}
			
			return val;
		};
	}

	/**
	 * Compute the hashCode of a stream of number
	 * To compute the HashCode on a string or an Array of data types implementing the getHashCode() method, 
	 * use the arrayOrStringFeeder method.
	 * @param feeder a callback that will be called until it returns null, each valid returned values will 
	 * be used to compute the hash code.
	 * @return the hash code computed
	 */
	public static function hashCodeFromStream(feeder:Int->Int):Int {
		// Based from here: http://stackoverflow.com/a/7616484/802124
		var hash = 0;
		var index = 0;
		var chr = feeder(index++);
		while (chr != -9999) {
			hash = Std.int(((hash << 5) - hash) + chr);
			//hash |= 0;                          // Convert to 32bit integer
			chr = feeder(index++);
		}
		
		return hash;
	}
	
}
