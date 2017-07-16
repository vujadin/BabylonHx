package com.babylonhx.materials;

import com.babylonhx.Engine;
import com.babylonhx.materials.textures.WebGLTexture;
import com.babylonhx.tools.Tools;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector4;
import com.babylonhx.postprocess.PostProcess;
import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.mesh.WebGLBuffer;
import com.babylonhx.tools.Observable;
import com.babylonhx.tools.Observer;

import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLUniformLocation;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLTexture;
import lime.utils.Float32Array;
import lime.utils.Int32Array;

#if (js || purejs)
import js.html.Element;
#end

using StringTools;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Effect') class Effect {
	
	public var name:Dynamic;
	public var defines:String;
	public var onCompiled:Effect->Void;
	public var onError:Effect->String->Void;
	public var onBind:Effect->Void;
	public var uniqueId:Int = 0;
	public var onCompileObservable:Observable<Effect> = new Observable<Effect>();
	public var onErrorObservable:Observable<Effect> = new Observable<Effect>();
	public var onBindObservable:Observable<Effect> = new Observable<Effect>();
	
	public var isSupported(get, never):Bool;

	private static var _uniqueIdSeed:Int = 0;
	private var _engine:Engine;
	private var _uniformBuffersNames:Map<String, Int> = new Map();
	private var _uniformsNames:Array<String>;
	private var _samplers:Array<String>;
	private var _isReady:Bool = false;
	private var _compilationError:String = "";
	private var _attributesNames:Array<String>;
	private var _attributes:Array<Int>;
	private var _uniforms:Array<GLUniformLocation>;
	public var _key:String;
	private var _indexParameters:Dynamic;
	private var _fallbacks:EffectFallbacks;
	
	@:allow(com.babylonhx.Engine) 
	private var _program:GLProgram;
	
	private var _valueCache:Map<String, Array<Float>> = new Map();	
	private var _valueCacheMatrix:Map<String, Matrix> = new Map();	// VK: for matrices only
	private static var _baseCache:Map<Int, WebGLBuffer> = new Map();
	

	public function new(baseName:Dynamic, attributesNamesOrOptions:Dynamic, uniformsNamesOrEngine:Dynamic, samplers:Array<String>, engine:Engine, ?defines:String, ?fallbacks:EffectFallbacks, ?onCompiled:Effect->Void, ?onError:Effect->String->Void, ?indexParameters:Dynamic) {
		this.name = baseName;
		
		if (attributesNamesOrOptions.attributes != null) {
			var options:EffectCreationOptions = cast attributesNamesOrOptions;
			this._engine = cast uniformsNamesOrEngine;
			
			this._attributesNames = options.attributes;
			this._uniformsNames = options.uniformsNames.concat(options.samplers);
			this._samplers = options.samplers;
			this.defines = options.defines;
			this.onError = options.onError;
			this.onCompiled = options.onCompiled;
			this._fallbacks = options.fallbacks;
			this._indexParameters = options.indexParameters; 
			
			if (options.uniformBuffersNames != null) {
				for (i in 0...options.uniformBuffersNames.length) {
					this._uniformBuffersNames[options.uniformBuffersNames[i]] = i;
				}          
			}    
		}
		else {
			this._engine = engine;
			this.defines = defines;
			this._uniformsNames = uniformsNamesOrEngine.concat(samplers);
			this._samplers = samplers;
			this._attributesNames = attributesNamesOrOptions;
			
			this.onError = onError;
			this.onCompiled = onCompiled;
			
			this._indexParameters = indexParameters;
			this._fallbacks = fallbacks;
		}
		
		this.uniqueId = Effect._uniqueIdSeed++;
		
		#if (js || purejs)
		var vertexSource:Dynamic;
		var fragmentSource:Dynamic;
		#else
		var vertexSource:String = "";
		var fragmentSource:String = "";
		#end
		
		if (baseName.vertexElement != null) {
			#if (js || purejs)
			vertexSource = js.Browser.document.getElementById(baseName.vertexElement);
			
			if (vertexSource == null) {
				vertexSource = baseName.vertexElement;
			}
			#end
		} 
		else {
			vertexSource = baseName.vertex != null ? baseName.vertex : baseName;
		}
		
		if (baseName.fragmentElement != null) {
			#if (js || purejs)
			fragmentSource = js.Browser.document.getElementById(baseName.fragmentElement);
			
			if (fragmentSource == null) {
				fragmentSource = baseName.fragmentElement;
			}
			#end
		} 
		else {
			fragmentSource = baseName.fragment != null ? baseName.fragment : baseName;
		}
		
		this._loadVertexShader(vertexSource, function(vertexCode:String) {
			this._processIncludes(vertexCode, function(vertexCodeWithIncludes:String) {
				this._processShaderConversion(vertexCodeWithIncludes, false, function(migratedVertexCode:String) {
					this._loadFragmentShader(fragmentSource, function(fragmentCode:String) {
						this._processIncludes(fragmentCode, function(fragmentCodeWithIncludes:String) {
							this._processShaderConversion(fragmentCodeWithIncludes, true, function(migratedFragmentCode:String) {
								this._prepareEffect(migratedVertexCode, migratedFragmentCode, this._attributesNames, this.defines, this._fallbacks);
							});
						});
					});
				});
			});
		});  
	}
	
	public var key(get, never):String;
	inline private function get_key():String {
		return this._key;
	}

	// Properties
	inline public function isReady():Bool {
		return this._isReady;
	}
	
	inline public function getEngine():Engine {
		return this._engine;
	}

	inline public function getProgram():GLProgram {
		return this._program;
	}

	inline public function getAttributesNames():Array<String> {
		return this._attributesNames;
	}

	inline public function getAttributeLocation(index:Int):Int {
		return this._attributes[index];
	}

	inline public function getAttributeLocationByName(name:String):Int {
		var index = this._attributesNames.indexOf(name);
		
		return this._attributes[index];
	}

	inline public function getAttributesCount():Int {
		return this._attributes.length;
	}

	inline public function getUniformIndex(uniformName:String):Int {
		return this._uniformsNames.indexOf(uniformName);
	}

	inline public function getUniform(uniformName:String):GLUniformLocation {
		return this._uniforms[this._uniformsNames.indexOf(uniformName)];
	}

	inline public function getSamplers():Array<String> {
		return this._samplers;
	}

	inline public function getCompilationError():String {
		return this._compilationError;
	}
	
	public function getVertexShaderSource():String {
		return this._evaluateDefinesOnString(this._engine.getVertexShaderSource(this._program));
    }

    public function getFragmentShaderSource():String {
		return this._evaluateDefinesOnString(this._engine.getFragmentShaderSource(this._program));
    }

	// Methods
	var observer:Observer<Effect>;
	public function executeWhenCompiled(func:Effect->Void) {
		if (this.isReady()) {
			func(this);
			return;
		}
		
		observer = this.onCompileObservable.add(function(effect:Effect, _) {
			this.onCompileObservable.remove(observer);
			func(effect);
		});
	}
	
	public function _loadVertexShader(vertex:Dynamic, callbackFn:Dynamic->Void) {
		#if (js || purejs)
		// DOM element ?
		if (Std.is(vertex, Element)) {
			var vertexCode = Tools.GetDOMTextContent(vertex);
			callbackFn(vertexCode);
			return;
		}
		
		// Base64 encoded ?
		if (vertex.substr(0, 7) == "base64:") {
			var vertexBinary = js.Browser.window.atob(vertex.substr(7));
			callbackFn(vertexBinary);
			return;
		}
		#end
		
        // Is in local store ?
        if (ShadersStore.Shaders.exists(vertex + "VertexShader")) {
            callbackFn(ShadersStore.Shaders.get(vertex + "VertexShader"));
            return;
        }
		
		var vertexShaderUrl:String = "";
		
		if (vertex[0] == "." || vertex[0] == "/" || vertex.indexOf("http") > -1) {
			vertexShaderUrl = vertex;
		} 
		else {
			vertexShaderUrl = Engine.ShadersRepository + vertex;
		}
        
        // Vertex shader
		Tools.LoadFile(vertexShaderUrl + ".vertex.fx", callbackFn, "text");
    }
	
	public function _loadFragmentShader(fragment:Dynamic, callbackFn:Dynamic->Void) {
		#if (js || purejs)
		// DOM element ?
		if (Std.is(fragment, Element)) {
			var fragmentCode = Tools.GetDOMTextContent(fragment);
			callbackFn(fragmentCode);
			return;
		}
		
		// Base64 encoded ?
		if (fragment.substr(0, 7) == "base64:") {
			var fragmentBinary = js.Browser.window.atob(fragment.substr(7));
			callbackFn(fragmentBinary);
			return;
		}
		#end
		
        // Is in local store ?
        if (ShadersStore.Shaders.exists(fragment + "FragmentShader")) {
            callbackFn(ShadersStore.Shaders.get(fragment + "FragmentShader"));
            return;
        }
		
		if (ShadersStore.Shaders.exists(fragment + "PixelShader")) {
			callbackFn(ShadersStore.Shaders.get(fragment + "PixelShader"));
			return;
		}
		
		var fragmentShaderUrl:String = "";
		
		if (fragment[0] == "." || fragment[0] == "/" || fragment.indexOf("http") > -1) {
			fragmentShaderUrl = fragment;
		} 
		else {
			fragmentShaderUrl = Engine.ShadersRepository + fragment;
		}
        
        // Fragment shader
		Tools.LoadFile(fragmentShaderUrl + ".fragment.fx", callbackFn, "text");
    }
	
	private function _dumpShadersSource(vertexCode:String, fragmentCode:String, defines:String) {
		// VK TODO:
		/*// Rebuild shaders source code
		var shaderVersion = (this._engine.webGLVersion > 1) ? "#version 300 es\n" : "";
		var prefix = shaderVersion + (defines != null ? defines + "\n" : "");
		vertexCode = prefix + vertexCode;
		fragmentCode = prefix + fragmentCode;
		
		// Number lines of shaders source code
		var i = 2;
		var regex:EReg = ~/\n/gm;
		var formattedVertexCode = "\n1\t" + regex. vertexCode.replace(regex, function() { return "\n" + (i++) + "\t"; });
		i = 2;
		var formattedFragmentCode = "\n1\t" + fragmentCode.replace(regex, function() { return "\n" + (i++) + "\t"; });
		
		// Dump shaders name and formatted source code
		if (this.name.vertexElement) {
			Tools.Error("Vertex shader: " + this.name.vertexElement + formattedVertexCode);
			Tools.Error("Fragment shader: " + this.name.fragmentElement + formattedFragmentCode);
		}
		else if (this.name.vertex) {
			Tools.Error("Vertex shader: " + this.name.vertex + formattedVertexCode);
			Tools.Error("Fragment shader: " + this.name.fragment + formattedFragmentCode);
		}
		else {
			Tools.Error("Vertex shader: " + this.name + formattedVertexCode);
			Tools.Error("Fragment shader: " + this.name + formattedFragmentCode);
		}*/
	}

	private function _processShaderConversion(sourceCode:String, isFragment:Bool, callback:Dynamic->Void) {
		var preparedSourceCode = this._processPrecision(sourceCode);
		
		if (this._engine.webGLVersion == 1) {
			callback(preparedSourceCode);
			return;
		}
		
		// Already converted
		if (preparedSourceCode.indexOf("#version 3") != -1) {
			callback(StringTools.replace(preparedSourceCode, "#version 300 es", ""));
			return;
		}
		
		// Remove extensions 
		// #extension GL_OES_standard_derivatives : enable
		// #extension GL_EXT_shader_texture_lod : enable
		// #extension GL_EXT_frag_depth : enable
		var regex:EReg = ~/#extension.+(GL_OES_standard_derivatives|GL_EXT_shader_texture_lod|GL_EXT_frag_depth).+enable/g;
		var result = regex.replace(preparedSourceCode, "");
		
		// Migrate to GLSL v300
		regex = ~/varying(?![\n\r])\s/g;
		result = regex.replace(result, isFragment ? "in " : "out ");
		regex = ~/attribute[ \t]/g;
		result = regex.replace(result, "in ");
		regex = ~/[ \t]attribute/g;
		result = regex.replace(result, " in");
		
		if (isFragment) {
			regex = ~/texture2DLodEXT\(/g;
			result = regex.replace(result, "textureLod(");
			regex = ~/textureCubeLodEXT\(/g;
			result = regex.replace(result, "textureLod(");
			regex = ~/texture2D\(/g;
			result = regex.replace(result, "texture(");
			regex = ~/textureCube\(/g;
			result = regex.replace(result, "texture(");
			regex = ~/gl_FragDepthEXT/g;
			result = regex.replace(result, "gl_FragDepth");
			regex = ~/gl_FragColor/g;
			result = regex.replace(result, "glFragColor");
			regex = ~/void\s+?main\(/g;
			result = regex.replace(result, "out vec4 glFragColor;\nvoid main(");
		}
		
		callback(result);
	}
	
	private function _processIncludes(sourceCode:String, callback:Dynamic->Void) {
		var regex:EReg = ~/#include<(.+)>(\((.*)\))*(\[(.*)\])*/g;
		var match = regex.match(sourceCode);
		
		var returnValue = sourceCode;
		
		while (match) {
			var includeFile:String = regex.matched(1);
			
			// Uniform declaration
			if (includeFile.indexOf("__decl__") != -1) {
				var rgex:EReg = ~/__decl__/;
				includeFile = rgex.replace(includeFile, "");
				if (this._engine.webGLVersion != 1) {
					rgex = ~/Vertex/;
					includeFile = rgex.replace(includeFile, "Ubo");
					rgex = ~/Fragment/;
					includeFile = rgex.replace(includeFile, "Ubo");
				}
				includeFile = includeFile + "Declaration";
			}
			
			if (IncludesShadersStore.Shaders[includeFile] != null) {
				sourceCode = StringTools.replace(sourceCode, regex.matched(0), IncludesShadersStore.Shaders[includeFile]);
				
				// Substitution
				var includeContent = IncludesShadersStore.Shaders[includeFile];
				var match2:String = regex.matched(2);
				if (match2 != null) {
					var splits = regex.matched(3).split(",");
					
					var index = 0;
					while (index < splits.length) {
						var source = new EReg(splits[index], "g");
						var dest = splits[index + 1];
						
						includeContent = source.replace(includeContent, dest);
						
						index += 2;
					}
				}
				
				var match4:String = regex.matched(4);
				if (match4 != null) {
					var rx:EReg = ~/\{X\}/g;
					var indexString:String = regex.matched(5);
					
					if (indexString.indexOf("..") != -1) {
						var indexSplits = indexString.split("..");
						var minIndex = Std.parseInt(indexSplits[0]);
						var maxIndex = Std.parseInt(indexSplits[1]);
						var sourceIncludeContent = includeContent.substr(0);
						includeContent = "";
						
						if (maxIndex == null || Math.isNaN(maxIndex)) {
							maxIndex = Std.int(Reflect.getProperty(this._indexParameters, indexSplits[1]));
						}
						
						for (i in minIndex...maxIndex + 1) {
							// VK TODO:
							/*if (this._engine.webGLVersion == 1) {
								// Ubo replacement
								sourceIncludeContent = sourceIncludeContent.replace(/light\{X\}.(\w*)/g, (str: string, p1: string) => {
									return p1 + "{X}";
								});
							}*/
							includeContent += rx.replace(sourceIncludeContent, i + "") + "\n";
						}
					} 
					else {
						if (this._engine.webGLVersion == 1) {
							// Ubo replacement
							// VK TODO:
							/*includeContent = StringTools.replace(includeContent.replace(, (str: string, p1: string) => {
								return p1 + "{X}";
							});*/
						}
						includeContent = rx.replace(includeContent, indexString);
					}
				}
				
				// Replace
				returnValue = StringTools.replace(returnValue, regex.matched(0), includeContent);
			} 
			else {
				var includeShaderUrl = Engine.ShadersRepository + "ShadersInclude/" + includeFile + ".fx";
				
				Tools.LoadFile(includeShaderUrl, function(fileContent:Dynamic) {
					IncludesShadersStore.Shaders[includeFile] = fileContent;
					this._processIncludes(sourceCode, callback);
				});
				
				return;
			}
			
			match = regex.match(sourceCode);
		}
		
		callback(returnValue);
	}
	
	private function _processPrecision(source:String):String {
		if (source.indexOf("precision highp float") == -1) {
			if (!this._engine.getCaps().highPrecisionShaderSupported) {
				source = "precision mediump float;\n" + source;
			} 
			else {
				source = "precision highp float;\n" + source;
			}
		} 
		else {
			if (!this._engine.getCaps().highPrecisionShaderSupported) { // Moving highp to mediump
				source = StringTools.replace(source, "precision highp float", "precision mediump float");
			}
		}		
		
		#if (!android && !js && !purejs && !web && !html5)	// TODO !mobile ??
		// native bug fix for neko / osx / etc http://community.openfl.org/t/lime-2-8-0-shader-issues/7060/2
		source = StringTools.replace(source, "precision highp float;", "\n");
		source = StringTools.replace(source, "precision highp float;", "\n");
		source = StringTools.replace(source, "precision mediump float;", "\n");
		source = StringTools.replace(source, "precision mediump float;", "\n");
		#end
		
		return source;
	}
	
	private function _prepareEffect(vertexSourceCode:String, fragmentSourceCode:String, attributesNames:Array<String>, defines:String, ?fallbacks:EffectFallbacks) {		
        try {
            var engine = this._engine;
			
            this._program = engine.createShaderProgram(vertexSourceCode, fragmentSourceCode, defines);
			
			if (engine.webGLVersion > 1) {
				for (name in this._uniformBuffersNames.keys()) {
					this.bindUniformBlock(name, this._uniformBuffersNames[name]);
				}
			}
			
            this._uniforms = engine.getUniforms(this._program, this._uniformsNames);
            this._attributes = engine.getAttributes(this._program, attributesNames);
			
			var index:Int = 0;
			while (index < this._samplers.length) {				
                var sampler = this.getUniform(this._samplers[index]);	
				#if (js || purejs || html5 || web || snow || nme || neko)
				if (sampler == null) {
				#else // openfl/lime
				if ( #if legacy sampler != null && #end cast(sampler, Int) < 0) {
				#end
					this._samplers.splice(index, 1);
					index--;
				}
				
				index++;
            }
			
            engine.bindSamplers(this);
			
			this._compilationError = "";
            this._isReady = true;			
			if (this.onCompiled != null) {
				this.onCompiled(this);
			}			
        } 
		catch (e:Dynamic) {
			/*#if (js || purejs)
			// Is it a problem with precision?
			if (e.indexOf("highp") != -1) {
				vertexSourceCode = StringTools.replace(vertexSourceCode, "precision highp float", "precision mediump float");
				fragmentSourceCode = StringTools.replace(fragmentSourceCode, "precision highp float", "precision mediump float");
				
				this._prepareEffect(vertexSourceCode, fragmentSourceCode, attributesNames, defines, fallbacks);
				
				return;
			}
			#end*/
			trace(e);
            // Let's go through fallbacks then
			if (fallbacks != null && fallbacks.isMoreFallbacks) {
				Tools.Error(this.name + " - Trying next fallback.");
				trace(defines);
				defines = fallbacks.reduce(defines);
				trace(defines);
				this._prepareEffect(vertexSourceCode, fragmentSourceCode, attributesNames, defines, fallbacks);
            } 
			else {
                trace("Unable to compile effect: " + this.name);
                trace("Defines: " + defines);
				#if (js || purejs || web || html5)
                trace("Error: " + e);
				#else
				trace("Error #: " + GL.getError());
				trace("Error: " + e);
				#end
                this._compilationError = cast e;
				
				//trace("VERTEX SHADER: \n" + vertexSourceCode);
				//trace("FRAGMENT SHADER: \n" + fragmentSourceCode);
				
				if (this.onError != null) {
					this.onError(this, this._compilationError);
				}
            }
        }
    }
	
	private function get_isSupported():Bool {
		return this._compilationError == "";
	}

	inline public function _bindTexture(channel:String, texture:GLTexture) {
		this._engine._bindTexture(this._samplers.indexOf(channel), texture);
	}

	public function setTexture(channel:String, texture:BaseTexture) {
		this._engine.setTexture(this._samplers.indexOf(channel), this.getUniform(channel), texture);
	}
	
	public function setTextureArray(channel:String, textures:Array<BaseTexture>) {
		if (this._samplers.indexOf(channel + "Ex") == -1) {
			var initialPos = this._samplers.indexOf(channel);
			for (index in 1...textures.length) {
				this._samplers.insert(initialPos + index, channel + "Ex");
			}
		}
		
		this._engine.setTextureArray(this._samplers.indexOf(channel), this.getUniform(channel), textures);
	}

	inline public function setTextureFromPostProcess(channel:String, postProcess:PostProcess) {
		this._engine.setTextureFromPostProcess(this._samplers.indexOf(channel), postProcess);
	}

	public function _cacheMatrix(uniformName:String, matrix:Matrix):Bool {
		var changed:Bool = false;
		var cache:Matrix = this._valueCacheMatrix[uniformName];
		if (cache == null) {
			changed = true;
			cache = new Matrix();
		}
		
		var tm = cache.m;
		var om = matrix.m;
		for (index in 0...16) {
			if (tm[index] != om[index]) { 
				tm[index] = om[index];
				changed = true;
			}
		}
		
		this._valueCacheMatrix[uniformName] = cache;
		
		return changed;
	}

	public function _cacheFloat2(uniformName:String, x:Float, y:Float):Bool {
		var cache:Array<Float> = this._valueCache[uniformName];
		if (cache == null) {
			cache = [x, y];
			this._valueCache[uniformName] = cache;
			
			return true;
		}
		
		var changed = false;
		if (cache[0] != x) {
			cache[0] = x;
			changed = true;
		}
		if (cache[1] != y) {
			cache[1] = y;
			changed = true;
		}
		
		return changed;
	}

	public function _cacheFloat3(uniformName:String, x:Float, y:Float, z:Float):Bool {
		var cache:Array<Float> = this._valueCache[uniformName];
		if (cache == null) {
			cache = [x, y, z];
			this._valueCache[uniformName] = cache;
			
			return true;
		}
		
		var changed = false;
		if (cache[0] != x) {
			cache[0] = x;
			changed = true;
		}
		if (cache[1] != y) {
			cache[1] = y;
			changed = true;
		}
		if (cache[2] != z) {
			cache[2] = z;
			changed = true;
		}
		
		return changed;
	}

	public function _cacheFloat4(uniformName:String, x:Float, y:Float, z:Float, w:Float):Bool {
		var cache:Array<Float> = this._valueCache[uniformName];
		if (cache == null) {
			cache = [x, y, z, w];
			this._valueCache[uniformName] = cache;
			
			return true;
		}
		
		var changed = false;
		if (cache[0] != x) {
			cache[0] = x;
			changed = true;
		}
		if (cache[1] != y) {
			cache[1] = y;
			changed = true;
		}
		if (cache[2] != z) {
			cache[2] = z;
			changed = true;
		}
		if (cache[3] != w) {
			cache[3] = w;
			changed = true;
		}
		
		return changed;
	}
	
	public function bindUniformBuffer(buffer:WebGLBuffer, name:String) {
		if (Effect._baseCache[this._uniformBuffersNames[name]] == buffer) {
			return;
		}
		Effect._baseCache[this._uniformBuffersNames[name]] = buffer;
		this._engine.bindUniformBufferBase(buffer, this._uniformBuffersNames[name]);
	}

	public function bindUniformBlock(blockName:String, index:Int) {
		this._engine.bindUniformBlock(this._program, blockName, index);
	}
	
	inline public function setIntArray(uniformName:String, array:Int32Array):Effect {
		this._valueCache[uniformName] = null;
		this._engine.setIntArray(this.getUniform(uniformName), array);
		
		return this;
	}

	inline public function setIntArray2(uniformName:String, array:Int32Array):Effect {
		this._valueCache[uniformName] = null;
		this._engine.setIntArray2(this.getUniform(uniformName), array);
		
		return this;
	}

	inline public function setIntArray3(uniformName:String, array:Int32Array):Effect {
		this._valueCache[uniformName] = null;
		this._engine.setIntArray3(this.getUniform(uniformName), array);
		
		return this;
	}

	inline public function setIntArray4(uniformName:String, array:Int32Array):Effect {
		this._valueCache[uniformName] = null;
		this._engine.setIntArray4(this.getUniform(uniformName), array);
		
		return this;
	}

	inline public function setFloatArray(uniformName:String, array:Float32Array):Effect {
		this._valueCache[uniformName] = null;
		this._engine.setFloatArray(this.getUniform(uniformName), array);
		
		return this;
	}

	inline public function setFloatArray2(uniformName:String, array:Float32Array):Effect {
		this._valueCache[uniformName] = null;
		this._engine.setFloatArray2(this.getUniform(uniformName), array);
		
		return this;
	}

	inline public function setFloatArray3(uniformName:String, array:Float32Array):Effect {
		this._valueCache[uniformName] = null;
		this._engine.setFloatArray3(this.getUniform(uniformName), array);
		
		return this;
	}

	inline public function setFloatArray4(uniformName:String, array:Float32Array):Effect {
		this._valueCache[uniformName] = null;
		this._engine.setFloatArray4(this.getUniform(uniformName), array);
		
		return this;
	}

	inline public function setArray(uniformName:String, array:Array<Float>):Effect {
		this._valueCache[uniformName] = null;
		this._engine.setArray(this.getUniform(uniformName), array);
		
		return this;
	}
	
	inline public function setArray2(uniformName:String, array:Array<Float>):Effect {
		this._valueCache[uniformName] = null;
        this._engine.setArray2(this.getUniform(uniformName), array);
		
        return this;
    }

    inline public function setArray3(uniformName:String, array:Array<Float>):Effect {
		this._valueCache[uniformName] = null;
        this._engine.setArray3(this.getUniform(uniformName), array);
		
        return this;
    }

    inline public function setArray4(uniformName:String, array:Array<Float>):Effect {
		this._valueCache[uniformName] = null;
        this._engine.setArray4(this.getUniform(uniformName), array);
		
        return this;
    }

	inline public function setMatrices(uniformName:String, matrices: #if (js || purejs) Float32Array #else Array<Float> #end ):Effect {
		this._valueCache[uniformName] = null;
		this._engine.setMatrices(this.getUniform(uniformName), matrices);
		
		return this;
	}

	inline public function setMatrix(uniformName:String, matrix:Matrix):Effect {
		if (this._cacheMatrix(uniformName, matrix)) {
			this._engine.setMatrix(this.getUniform(uniformName), matrix);
		}
		
		return this;
	}
	
	inline public function setMatrix3x3(uniformName:String, matrix:Float32Array):Effect {
		this._valueCache[uniformName] = null;
        this._engine.setMatrix3x3(this.getUniform(uniformName), matrix);
		
        return this;
    }

    inline public function setMatrix2x2(uniformName:String, matrix:Float32Array):Effect {
		this._valueCache[uniformName] = null;
        this._engine.setMatrix2x2(this.getUniform(uniformName), matrix);
		
        return this;
    }

	inline public function setFloat(uniformName:String, value:Float):Effect {
		var val = this._valueCache[uniformName];
		if (val != null && val[0] == value) {
			return this;
		}	
		
		this._valueCache.set(uniformName, [value]);		
		this._engine.setFloat(this.getUniform(uniformName), value);
		
		return this;
	}

	inline public function setBool(uniformName:String, bool:Bool):Effect {
		var val = this._valueCache[uniformName];
		if (val != null && val[0] == (bool ? 1.0 : 0.0)) {
			return this;
		}
		
		this._valueCache[uniformName] = bool ? [1.0] : [0.0];
		this._engine.setBool(this.getUniform(uniformName), bool);
		
		return this;
	}

	inline public function setVector2(uniformName:String, vector2:Vector2):Effect {
		if (this._cacheFloat2(uniformName, vector2.x, vector2.y)) {
			this._engine.setFloat2(this.getUniform(uniformName), vector2.x, vector2.y);
		}
		
		return this;
	}

	inline public function setFloat2(uniformName:String, x:Float, y:Float):Effect {
		if (this._cacheFloat2(uniformName, x, y)) {
			this._engine.setFloat2(this.getUniform(uniformName), x, y);
		}
		
		return this;
	}

	inline public function setVector3(uniformName:String, vector3:Vector3):Effect {
		if (this._cacheFloat3(uniformName, vector3.x, vector3.y, vector3.z)) {
			this._engine.setFloat3(this.getUniform(uniformName), vector3.x, vector3.y, vector3.z);
		}
		
		return this;
	}

	inline public function setFloat3(uniformName:String, x:Float, y:Float, z:Float):Effect {
		if (this._cacheFloat3(uniformName, x, y, z)) {
			this._engine.setFloat3(this.getUniform(uniformName), x, y, z);
		}
		
		return this;
	}
	
	inline public function setVector4(uniformName:String, vector4:Vector4):Effect {
		if (this._cacheFloat4(uniformName, vector4.x, vector4.y, vector4.z, vector4.w)) {
			this._engine.setFloat4(this.getUniform(uniformName), vector4.x, vector4.y, vector4.z, vector4.w);
		}
		
		return this;
	}

	inline public function setFloat4(uniformName:String, x:Float, y:Float, z:Float, w:Float):Effect {
		if (this._cacheFloat4(uniformName, x, y, z, w)) {
			this._engine.setFloat4(this.getUniform(uniformName), x, y, z, w);
		}
		
		return this;
	}

	inline public function setColor3(uniformName:String, color3:Color3):Effect {
		if (this._cacheFloat3(uniformName, color3.r, color3.g, color3.b)) {
			this._engine.setColor3(this.getUniform(uniformName), color3);
		}
		
		return this;
	}

	inline public function setColor4(uniformName:String, color3:Color3, alpha:Float):Effect {
		if (this._cacheFloat4(uniformName, color3.r, color3.g, color3.b, alpha)) {
			this._engine.setColor4(this.getUniform(uniformName), color3, alpha);
		}
		
		return this;
	}
	
	private function _recombineShader(node:Dynamic):String {
		if (node.define != null) {
			if (node.condition != null) {
				var defineIndex = this.defines.indexOf("#define " + node.define);
                if (defineIndex == -1) {
                    return null;
                }
				
                var nextComma = this.defines.indexOf("\n", defineIndex);
                var defineValue = this.defines.substr(defineIndex + 7, nextComma - defineIndex - 7).replace(node.define, "").trim();
                var condition = defineValue + node.condition;
				
				// VK TODO:
                //if (!eval(condition)) {
                    return null;
				//}
			}
			else if (node.ndef != null) {
				if (this.defines.indexOf("#define " + node.define) != -1) {
					return null;
				}
			}
			else if (this.defines.indexOf("#define " + node.define) == -1) {
				return null;
			}
		}
		
		var result:String = "";
		for (index in 0...node.children.length) {
			var line = node.children[index];
			
			if (line.children != null) {
				var combined = this._recombineShader(line);
				if (combined != null) {
					result += combined + "\r\n";
				}
				
				continue;
			}
			
			if (line.length > 0) {
				result += line + "\r\n";
			}
		}
		
		return result;
	}

	private function _evaluateDefinesOnString(shaderString:String):String {
		var root:Dynamic = {
			children: []
		};
		var currentNode:Dynamic = root;
		
		var lines = shaderString.split("\n");
		
		var newNode:Dynamic = { };
		
		for (index in 0...lines.length) {
			var line = StringTools.trim(lines[index]);
			
			// #ifdef
			var pos = line.indexOf("#ifdef ");
			if (pos != -1) {
				var define = line.substr(pos + 7);
				
				var newNode:Dynamic = {
					condition: null,
					ndef: false,
					define: define,
					children: [],
					parent: currentNode
				}
				
				currentNode.children.push(newNode);
				currentNode = newNode;
				continue;
			}
			
			// #ifndef
			var pos = line.indexOf("#ifndef ");
			if (pos != -1) {
				var define = line.substr(pos + 8);
				
				newNode = {
					condition: null,
					define: define,
					ndef: true,
					children: [],
					parent: currentNode
				}
				
				currentNode.children.push(newNode);
				currentNode = newNode;
				continue;
			}
			
			// #if
			var pos = line.indexOf("#if ");
			if (pos != -1) {
				var define = StringTools.trim(line.substr(pos + 4));
				var conditionPos = define.indexOf(" ");
				
				newNode = {
					condition: define.substr(conditionPos + 1),
					define: define.substr(0, conditionPos),
					ndef: false,
					children: [],
					parent: currentNode
				}
				
				currentNode.children.push(newNode);
				currentNode = newNode;
				continue;
			}
			
			// #endif
			pos = line.indexOf("#endif");
			if (pos != -1) {
				currentNode = currentNode.parent;
				continue;
			}
			
			currentNode.children.push(line);
		}
		
		// Recombine
		return this._recombineShader(root);
	}

}
