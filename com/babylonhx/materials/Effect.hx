package com.babylonhx.materials;

import com.babylonhx.engine.Engine;
import com.babylonhx.materials.textures.InternalTexture;
import com.babylonhx.materials.textures.WebGLTexture;
import com.babylonhx.tools.Tools;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector4;
import com.babylonhx.postprocess.PostProcess;
import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.mesh.WebGLBuffer;
import com.babylonhx.tools.Observable;
import com.babylonhx.tools.Observer;

import com.babylonhx.utils.GL;
import com.babylonhx.utils.GL.GLUniformLocation;
import com.babylonhx.utils.GL.GLProgram;
import com.babylonhx.utils.GL.GLTexture;
import com.babylonhx.utils.typedarray.Float32Array;
import com.babylonhx.utils.typedarray.Int32Array;

using StringTools;


/**
 * ...
 * @author Krtolica Vujadin
 */
/**
 * Effect containing vertex and fragment shader that can be executed on an object.
 */
@:expose('BABYLON.Effect') class Effect {
	/**
	 * Name of the effect.
	 */
	public var name:Dynamic;
	/**
	 * String container all the define statements that should be set on the shader.
	 */
	public var defines:String;
	/**
	 * Callback that will be called when the shader is compiled.
	 */
	public var onCompiled:Effect->Void;
	/**
	 * Callback that will be called if an error occurs during shader compilation.
	 */
	public var onError:Effect->String->Void;
	/**
	 * Callback that will be called when effect is bound.
	 */
	public var onBind:Effect->Void;
	/**
	 * Unique ID of the effect.
	 */
	public var uniqueId:Int = 0;
	/**
	 * Observable that will be called when the shader is compiled.
	 */
	public var onCompileObservable:Observable<Effect> = new Observable<Effect>();
	/**
	 * Observable that will be called if an error occurs during shader compilation.
	 */
	public var onErrorObservable:Observable<Effect> = new Observable<Effect>();
	/**
	 * Observable that will be called when effect is bound.
	 */
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
	/**
	 * Key for the effect.
	 */
	public var _key:String;
	private var _indexParameters:Dynamic;
	private var _fallbacks:EffectFallbacks;
	private var _vertexSourceCode:String;
    private var _fragmentSourceCode:String;
	private var _vertexSourceCodeOverride:String;
    private var _fragmentSourceCodeOverride:String;
	private var _transformFeedbackVaryings:Array<String> = null;
	
	/**
	 * Compiled shader to webGL program.
	 */
	@:allow(com.babylonhx.engine.Engine) 
	private var _program:GLProgram;
	
	private var _valueCache:Map<String, Array<Float>> = new Map();	
	private var _valueCacheMatrix:Map<String, Matrix> = new Map();	// VK: for matrices only
	private static var _baseCache:Map<Int, WebGLBuffer> = new Map();
	
	/**
	 * Resets the cache of effects.
	 */
	static public function ResetCache() {
		Effect._baseCache = new Map();
	}
	

	/**
	 * Instantiates an effect.
	 * An effect can be used to create/manage/execute vertex and fragment shaders.
	 * @param baseName Name of the effect.
	 * @param attributesNamesOrOptions List of attribute names that will be passed to the shader or set of all options to create the effect.
	 * @param uniformsNamesOrEngine List of uniform variable names that will be passed to the shader or the engine that will be used to render effect.
	 * @param samplers List of sampler variables that will be passed to the shader.
	 * @param engine Engine to be used to render the effect
	 * @param defines Define statements to be added to the shader.
	 * @param fallbacks Possible fallbacks for this effect to improve performance when needed.
	 * @param onCompiled Callback that will be called when the shader is compiled.
	 * @param onError Callback that will be called if an error occurs during shader compilation.
	 * @param indexParameters Parameters to be used with Babylons include syntax to iterate over an array (eg. {lights: 10})
	 */
	public function new(baseName:Dynamic, attributesNamesOrOptions:Dynamic, uniformsNamesOrEngine:Dynamic, ?samplers:Array<String>, ?engine:Engine, ?defines:String, ?fallbacks:EffectFallbacks, ?onCompiled:Effect->Void, ?onError:Effect->String->Void, ?indexParameters:Dynamic) {
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
			this._transformFeedbackVaryings = options.transformFeedbackVaryings;
			
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
								//if (baseName != null) {
									// not needed for BHX !...
									//this._vertexSourceCode = "#define SHADER_NAME vertex:" + baseName + "\n" + migratedVertexCode;
									//this._fragmentSourceCode = "#define SHADER_NAME fragment:" + baseName + "\n" + migratedFragmentCode;
								//}
								//else {
									this._vertexSourceCode = migratedVertexCode;
									this._fragmentSourceCode = migratedFragmentCode;
								//}
								this._prepareEffect();
							});
						});
					});
				});
			});
		});  
	}
	
	/**
	 * Unique key for this effect
	 */
	public var key(get, never):String;
	inline private function get_key():String {
		return this._key;
	}

	/**
	 * If the effect has been compiled and prepared.
	 * @returns if the effect is compiled and prepared.
	 */
	inline public function isReady():Bool {
		return this._isReady;
	}
	
	/**
	 * The engine the effect was initialized with.
	 * @returns the engine.
	 */
	inline public function getEngine():Engine {
		return this._engine;
	}

	/**
	 * The compiled webGL program for the effect
	 * @returns the webGL program.
	 */
	inline public function getProgram():GLProgram {
		return this._program;
	}

	/**
	 * The set of names of attribute variables for the shader.
	 * @returns An array of attribute names.
	 */
	inline public function getAttributesNames():Array<String> {
		return this._attributesNames;
	}

	/**
	 * Returns the attribute at the given index.
	 * @param index The index of the attribute.
	 * @returns The location of the attribute.
	 */
	inline public function getAttributeLocation(index:Int):Int {
		return this._attributes[index];
	}

	/**
	 * Returns the attribute based on the name of the variable.
	 * @param name of the attribute to look up.
	 * @returns the attribute location.
	 */
	inline public function getAttributeLocationByName(name:String):Int {
		var index = this._attributesNames.indexOf(name);
		
		return this._attributes[index];
	}

	/**
	 * The number of attributes.
	 * @returns the numnber of attributes.
	 */
	inline public function getAttributesCount():Int {
		return this._attributes.length;
	}

	/**
	 * Gets the index of a uniform variable.
	 * @param uniformName of the uniform to look up.
	 * @returns the index.
	 */
	public function getUniformIndex(uniformName:String):Int {
		return this._uniformsNames.indexOf(uniformName);
	}

	/**
	 * Returns the uniform based on the name of the variable.
	 * @param uniformName of the uniform to look up.
	 * @returns the location of the uniform.
	 */
	public function getUniform(uniformName:String):GLUniformLocation {
		return this._uniforms[this._uniformsNames.indexOf(uniformName)];
	}

	/**
	 * Returns an array of sampler variable names
	 * @returns The array of sampler variable neames.
	 */
	inline public function getSamplers():Array<String> {
		return this._samplers;
	}

	/**
	 * The error from the last compilation.
	 * @returns the error string.
	 */
	inline public function getCompilationError():String {
		return this._compilationError;
	}

	/**
	 * Adds a callback to the onCompiled observable and call the callback imediatly if already ready.
	 * @param func The callback to be used.
	 */
	public function executeWhenCompiled(func:Effect->Void) {
		if (this.isReady()) {
			func(this);
			return;
		}
		
		this.onCompileObservable.add(function(effect:Effect, _) {
			func(effect);
		});
	}
	
	public function _loadVertexShader(vertex:Dynamic, callbackFn:Dynamic->Void) {
		#if (js || purejs)
		// DOM element ?
		if (Std.is(vertex, js.html.Element)) {
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
		if (Std.is(fragment, js.html.Element)) {
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
		// Rebuild shaders source code
		var shaderVersion = (this._engine.webGLVersion > 1) ? "#version 300 es\n" : "";
		var prefix = shaderVersion + (defines != null ? defines + "\n" : "");
		vertexCode = prefix + vertexCode;
		fragmentCode = prefix + fragmentCode;
		
		// Number lines of shaders source code
		var i = 2;
		var regex:EReg = ~/\n/gm;
		var formattedVertexCode = vertexCode;// "\n1\t" + regex. vertexCode.replace(regex, function() { return "\n" + (i++) + "\t"; });
		i = 2;
		var formattedFragmentCode = fragmentCode;// "\n1\t" + fragmentCode.replace(regex, function() { return "\n" + (i++) + "\t"; });
		
		// Dump shaders name and formatted source code
		if (this.name.vertexElement != null) {
			Tools.Error("Vertex shader: " + this.name.vertexElement + formattedVertexCode);
			Tools.Error("Fragment shader: " + this.name.fragmentElement + formattedFragmentCode);
		}
		else if (this.name.vertex != null) {
			Tools.Error("Vertex shader: " + this.name.vertex + formattedVertexCode);
			Tools.Error("Fragment shader: " + this.name.fragment + formattedFragmentCode);
		}
		else {
			Tools.Error("Vertex shader: " + this.name + formattedVertexCode);
			Tools.Error("Fragment shader: " + this.name + formattedFragmentCode);
		}
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
		
		var dbeRegEx = ~/#extension.+GL_EXT_draw_buffers.+require/g;
		var hasDrawBuffersExtension = dbeRegEx.match(preparedSourceCode);
		
		// Remove extensions 
		// #extension GL_OES_standard_derivatives : enable
		// #extension GL_EXT_shader_texture_lod : enable
		// #extension GL_EXT_frag_depth : enable
		// #extension GL_EXT_draw_buffers : require
		var regex:EReg = ~/#extension.+(GL_OES_standard_derivatives|GL_EXT_shader_texture_lod|GL_EXT_frag_depth|GL_EXT_draw_buffers).+(enable|require)/g;
		var result = regex.replace(preparedSourceCode, "");
		
		// Migrate to GLSL v300
		regex = ~/varying(?![\n\r])\s/g;
		result = regex.replace(result, isFragment ? "in " : "out ");
		regex = ~/attribute[ \t]/g;
		result = regex.replace(result, "in ");
		regex = ~/[ \t]attribute/g;
		result = regex.replace(result, " in");
		
		if (isFragment) {
			regex = ~/texture2DLodEXT\s*\(/g;
			result = regex.replace(result, "textureLod(");
			regex = ~/textureCubeLodEXT\s*\(/g;
			result = regex.replace(result, "textureLod(");
			regex = ~/texture2D\s*\(/g;
			result = regex.replace(result, "texture(");
			regex = ~/textureCube\s*\(/g;
			result = regex.replace(result, "texture(");
			regex = ~/gl_FragDepthEXT/g;
			result = regex.replace(result, "gl_FragDepth");
			regex = ~/gl_FragColor/g;
			result = regex.replace(result, "glFragColor");
			regex = ~/gl_FragData/g;
			result = regex.replace(result, "glFragData");
			regex = ~/void\s+?main\s*\(/g;
			result = regex.replace(result, (hasDrawBuffersExtension ? "" : "out vec4 glFragColor;\n") + "void main(");
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
				if (this._engine.supportsUniformBuffers) {
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
				var includeContent:String = IncludesShadersStore.Shaders[includeFile];
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
						var indexSplits:Array<String> = indexString.split("..");
						var minIndex = Std.parseInt(indexSplits[0]);
						var maxIndex = Std.parseInt(indexSplits[1]);
						var sourceIncludeContent:String = includeContent.substr(0);
						includeContent = "";
						
						// VK: !!! Haxe Std.parseInt will return null instead of NaN !!!   http://api.haxe.org/Std.html#parseInt
						if (maxIndex == null || Math.isNaN(maxIndex)) {
							maxIndex = Std.int(Reflect.getProperty(this._indexParameters, indexSplits[1]));
						}
						
						for (i in minIndex...maxIndex) {
							if (!this._engine.supportsUniformBuffers) {
								// Ubo replacement
								var _tmprx:EReg = ~/light\{X\}.(\w*)/g;
								while (_tmprx.match(sourceIncludeContent)) {
									sourceIncludeContent = StringTools.replace(sourceIncludeContent, _tmprx.matched(0), _tmprx.matched(1) + "{X}");
								}
							}
							includeContent += rx.replace(sourceIncludeContent, i + "") + "\n";
						}
					} 
					else {
						if (!this._engine.supportsUniformBuffers) {
							// Ubo replacement
							var _tmprx:EReg = ~/light\{X\}.(\w*)/g;
							while (_tmprx.match(includeContent)) {
								includeContent = StringTools.replace(includeContent, _tmprx.matched(0), _tmprx.matched(1) + "{X}");
							}
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
		//#if (js || mobile)
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
		//#end
		
		return source;
	}
	
	/**
	 * Recompiles the webGL program
	 * @param vertexSourceCode The source code for the vertex shader.
	 * @param fragmentSourceCode The source code for the fragment shader.
	 * @param onCompiled Callback called when completed.
	 * @param onError Callback called on error.
	 */
	public function _rebuildProgram(vertexSourceCode:String, fragmentSourceCode:String, onCompiled:GLProgram->Void, ?onError:String->Void) {
		this._isReady = false;
		
		this._vertexSourceCodeOverride = vertexSourceCode;
		this._fragmentSourceCodeOverride = fragmentSourceCode;
		this.onError = function (_, error:Dynamic) {
			if (onError != null) {
				onError(error);
			}
		};
		this.onCompiled = function(_) {
			var scenes = this.getEngine().scenes;
			for (i in 0...scenes.length) {
				scenes[i].markAllMaterialsAsDirty(Material.TextureDirtyFlag);
			}
			
			if (onCompiled != null) {
				onCompiled(this._program);
			}
		};
		this._fallbacks = null;
		this._prepareEffect();
	}
	
	/**
	 * Gets the uniform locations of the the specified variable names
	 * @param names THe names of the variables to lookup.
	 * @returns Array of locations in the same order as variable names.
	 */
	inline public function getSpecificUniformLocations(names:Array<String>):Array<GLUniformLocation> {
        return this._engine.getUniforms(this._program, names);
    }
	
	/**
	 * Prepares the effect
	 */
	private function _prepareEffect() {
		var attributesNames = this._attributesNames;
		var defines = this.defines;
		var fallbacks = this._fallbacks;
		this._valueCache = new Map();
		
		var previousProgram = this._program;
		
        try {			
            var engine = this._engine;
			
			if (this._vertexSourceCodeOverride != null && this._fragmentSourceCodeOverride != null) {
				this._program = engine.createRawShaderProgram(this._vertexSourceCodeOverride, this._fragmentSourceCodeOverride, this._transformFeedbackVaryings);
			}
			else {
				this._program = engine.createShaderProgram(this._vertexSourceCode, this._fragmentSourceCode, defines, this._transformFeedbackVaryings);
			}
			
			if (engine.supportsUniformBuffers) {
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
			this.onCompileObservable.notifyObservers(this);
            this.onCompileObservable.clear();
			
			// Unbind mesh reference in fallbacks
            if (this._fallbacks != null) {
                this._fallbacks.unBindMesh();
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
			
            /*// Let's go through fallbacks then
			if (fallbacks != null && fallbacks.isMoreFallbacks) {
				Tools.Error(this.name + " - Trying next fallback.");
				trace('Fallback ERROR: ' + e);
				trace(_vertexSourceCode);
				trace(_fragmentSourceCode);
				this.defines = fallbacks.reduce(this.defines, this);
				this._prepareEffect();
            } 
			else {
                trace("Unable to compile effect: " + this.name);
                trace("Defines: " + defines);
				#if js
                trace("Error: " + e);
				trace("Error #: " + GL.getError());
				trace(_fragmentSourceCode);
				#else
				trace("Error #: " + GL.getError());
				trace("Error: " + e);
				#end
                this._compilationError = cast e;
				
				if (this.onError != null) {
					this.onError(this, this._compilationError);
				}
				this.onErrorObservable.notifyObservers(this);
				this.onErrorObservable.clear();
				
				// Unbind mesh reference in fallbacks
				if (this._fallbacks != null) {
					this._fallbacks.unBindMesh();
				}
            }*/
			// Let's go through fallbacks then
			Tools.Error("Unable to compile effect:");
			Tools.Error("Uniforms: " + this._uniformsNames.map(function(uniform:String) {
				return " " + uniform;
			}));
			Tools.Error("Attributes: " + attributesNames.map(function(attribute:String) {
				return " " + attribute;
			}));
			this._dumpShadersSource(this._vertexSourceCode, this._fragmentSourceCode, defines);
			Tools.Error("Error: " + this._compilationError);
			if (previousProgram != null) {
				this._program = previousProgram;
				this._isReady = true;
				if (this.onError != null) {
					this.onError(this, this._compilationError);
				}
				this.onErrorObservable.notifyObservers(this);
			}
			
			if (fallbacks != null && fallbacks.isMoreFallbacks) {
				Tools.Error("Trying next fallback.");
				this.defines = fallbacks.reduce(this.defines, this);
				this._prepareEffect();
			} 
			else { // Sorry we did everything we can
				if (this.onError != null) {
					this.onError(this, this._compilationError);
				}
				this.onErrorObservable.notifyObservers(this);
				this.onErrorObservable.clear();
				
				// Unbind mesh reference in fallbacks
				if (this._fallbacks != null) {
					this._fallbacks.unBindMesh();
				}
			}
        }
    }
	
	/**
	 * Checks if the effect is supported. (Must be called after compilation)
	 */
	private function get_isSupported():Bool {
		return this._compilationError == "";
	}

	/**
	 * Binds a texture to the engine to be used as output of the shader.
	 * @param channel Name of the output variable.
	 * @param texture Texture to bind.
	 */
	inline public function _bindTexture(channel:String, texture:InternalTexture) {
		this._engine._bindTexture(this._samplers.indexOf(channel), texture);
	}

	/**
	 * Sets a texture on the engine to be used in the shader.
	 * @param channel Name of the sampler variable.
	 * @param texture Texture to set.
	 */
	public function setTexture(channel:String, texture:BaseTexture) {
		this._engine.setTexture(this._samplers.indexOf(channel), this.getUniform(channel), texture);
	}
	
	/**
	 * Sets an array of textures on the engine to be used in the shader.
	 * @param channel Name of the variable.
	 * @param textures Textures to set.
	 */
	public function setTextureArray(channel:String, textures:Array<BaseTexture>) {
		if (this._samplers.indexOf(channel + "Ex") == -1) {
			var initialPos = this._samplers.indexOf(channel);
			for (index in 1...textures.length) {
				this._samplers.insert(initialPos + index, channel + "Ex");
			}
		}
		
		this._engine.setTextureArray(this._samplers.indexOf(channel), this.getUniform(channel), textures);
	}

	/**
	 * Sets a texture to be the input of the specified post process. (To use the output, pass in the next post process in the pipeline)
	 * @param channel Name of the sampler variable.
	 * @param postProcess Post process to get the input texture from.
	 */
	inline public function setTextureFromPostProcess(channel:String, postProcess:PostProcess) {
		this._engine.setTextureFromPostProcess(this._samplers.indexOf(channel), postProcess);
	}

	public function _cacheMatrix(uniformName:String, matrix:Matrix):Bool {
		var cache = this._valueCache[uniformName];
		var flag = matrix.updateFlag;
		if (cache != null && cache[0] == flag) {
			return false;
		}
		
		this._valueCache.set(uniformName, [flag]);
		
		return true;
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
	
	/**
	 * Binds a buffer to a uniform.
	 * @param buffer Buffer to bind.
	 * @param name Name of the uniform variable to bind to.
	 */
	public function bindUniformBuffer(buffer:WebGLBuffer, name:String) {
		var bufferName = this._uniformBuffersNames[name];
        if (bufferName != null && Effect._baseCache[bufferName] == buffer) {
			return;
		}
		Effect._baseCache[bufferName] = buffer;
        this._engine.bindUniformBufferBase(buffer, bufferName);
	}

	/**
	 * Binds block to a uniform.
	 * @param blockName Name of the block to bind.
	 * @param index Index to bind.
	 */
	public function bindUniformBlock(blockName:String, index:Int) {
		this._engine.bindUniformBlock(this._program, blockName, index);
	}
	
	/**
	 * Sets an interger value on a uniform variable.
	 * @param uniformName Name of the variable.
	 * @param value Value to be set.
	 * @returns this effect.
	 */
	public function setInt(uniformName:String, value:Int):Effect {
        var cache = this._valueCache[uniformName];
        if (cache != null && cache[0] == value) {
            return this;
		}
		
        this._valueCache.set(uniformName, [value]);
		
        this._engine.setInt(this.getUniform(uniformName), value);
		
        return this;
    }
	
	/**
	 * Sets an int array on a uniform variable.
	 * @param uniformName Name of the variable.
	 * @param array array to be set.
	 * @returns this effect.
	 */
	inline public function setIntArray(uniformName:String, array:Int32Array):Effect {
		this._valueCache[uniformName] = null;
		this._engine.setIntArray(this.getUniform(uniformName), array);
		
		return this;
	}

	/**
	 * Sets an int array 2 on a uniform variable. (Array is specified as single array eg. [1,2,3,4] will result in [[1,2],[3,4]] in the shader)
	 * @param uniformName Name of the variable.
	 * @param array array to be set.
	 * @returns this effect.
	 */
	inline public function setIntArray2(uniformName:String, array:Int32Array):Effect {
		this._valueCache[uniformName] = null;
		this._engine.setIntArray2(this.getUniform(uniformName), array);
		
		return this;
	}

	/**
	 * Sets an int array 3 on a uniform variable. (Array is specified as single array eg. [1,2,3,4,5,6] will result in [[1,2,3],[4,5,6]] in the shader)
	 * @param uniformName Name of the variable.
	 * @param array array to be set.
	 * @returns this effect.
	 */
	inline public function setIntArray3(uniformName:String, array:Int32Array):Effect {
		this._valueCache[uniformName] = null;
		this._engine.setIntArray3(this.getUniform(uniformName), array);
		
		return this;
	}

	/**
	 * Sets an int array 4 on a uniform variable. (Array is specified as single array eg. [1,2,3,4,5,6,7,8] will result in [[1,2,3,4],[5,6,7,8]] in the shader)
	 * @param uniformName Name of the variable.
	 * @param array array to be set.
	 * @returns this effect.
	 */
	inline public function setIntArray4(uniformName:String, array:Int32Array):Effect {
		this._valueCache[uniformName] = null;
		this._engine.setIntArray4(this.getUniform(uniformName), array);
		
		return this;
	}

	/**
	 * Sets an float array on a uniform variable.
	 * @param uniformName Name of the variable.
	 * @param array array to be set.
	 * @returns this effect.
	 */
	inline public function setFloatArray(uniformName:String, array:Float32Array):Effect {
		this._valueCache[uniformName] = null;
		this._engine.setFloatArray(this.getUniform(uniformName), array);
		
		return this;
	}

	/**
	 * Sets an float array 2 on a uniform variable. (Array is specified as single array eg. [1,2,3,4] will result in [[1,2],[3,4]] in the shader)
	 * @param uniformName Name of the variable.
	 * @param array array to be set.
	 * @returns this effect.
	 */
	inline public function setFloatArray2(uniformName:String, array:Float32Array):Effect {
		this._valueCache[uniformName] = null;
		this._engine.setFloatArray2(this.getUniform(uniformName), array);
		
		return this;
	}

	/**
	 * Sets an float array 3 on a uniform variable. (Array is specified as single array eg. [1,2,3,4,5,6] will result in [[1,2,3],[4,5,6]] in the shader)
	 * @param uniformName Name of the variable.
	 * @param array array to be set.
	 * @returns this effect.
	 */
	inline public function setFloatArray3(uniformName:String, array:Float32Array):Effect {
		this._valueCache[uniformName] = null;
		this._engine.setFloatArray3(this.getUniform(uniformName), array);
		
		return this;
	}

	/**
	 * Sets an float array 4 on a uniform variable. (Array is specified as single array eg. [1,2,3,4,5,6,7,8] will result in [[1,2,3,4],[5,6,7,8]] in the shader)
	 * @param uniformName Name of the variable.
	 * @param array array to be set.
	 * @returns this effect.
	 */
	inline public function setFloatArray4(uniformName:String, array:Float32Array):Effect {
		this._valueCache[uniformName] = null;
		this._engine.setFloatArray4(this.getUniform(uniformName), array);
		
		return this;
	}

	/**
	 * Sets an array on a uniform variable.
	 * @param uniformName Name of the variable.
	 * @param array array to be set.
	 * @returns this effect.
	 */
	inline public function setArray(uniformName:String, array:Array<Float>):Effect {
		this._valueCache[uniformName] = null;
		this._engine.setArray(this.getUniform(uniformName), array);
		
		return this;
	}
	
	/**
	 * Sets an array 2 on a uniform variable. (Array is specified as single array eg. [1,2,3,4] will result in [[1,2],[3,4]] in the shader)
	 * @param uniformName Name of the variable.
	 * @param array array to be set.
	 * @returns this effect.
	 */
	inline public function setArray2(uniformName:String, array:Array<Float>):Effect {
		this._valueCache[uniformName] = null;
        this._engine.setArray2(this.getUniform(uniformName), array);
		
        return this;
    }

	/**
	 * Sets an array 3 on a uniform variable. (Array is specified as single array eg. [1,2,3,4,5,6] will result in [[1,2,3],[4,5,6]] in the shader)
	 * @param uniformName Name of the variable.
	 * @param array array to be set.
	 * @returns this effect.
	 */
    inline public function setArray3(uniformName:String, array:Array<Float>):Effect {
		this._valueCache[uniformName] = null;
        this._engine.setArray3(this.getUniform(uniformName), array);
		
        return this;
    }

	/**
	 * Sets an array 4 on a uniform variable. (Array is specified as single array eg. [1,2,3,4,5,6,7,8] will result in [[1,2,3,4],[5,6,7,8]] in the shader)
	 * @param uniformName Name of the variable.
	 * @param array array to be set.
	 * @returns this effect.
	 */
    inline public function setArray4(uniformName:String, array:Array<Float>):Effect {
		this._valueCache[uniformName] = null;
        this._engine.setArray4(this.getUniform(uniformName), array);
		
        return this;
    }

	/**
	 * Sets matrices on a uniform variable.
	 * @param uniformName Name of the variable.
	 * @param matrices matrices to be set.
	 * @returns this effect.
	 */
	inline public function setMatrices(uniformName:String, matrices:Float32Array):Effect {
		if (matrices == null) {
			return null;
		}
		
		this._valueCache[uniformName] = null;
		this._engine.setMatrices(this.getUniform(uniformName), matrices);
		
		return this;
	}

	/**
	 * Sets matrix on a uniform variable.
	 * @param uniformName Name of the variable.
	 * @param matrix matrix to be set.
	 * @returns this effect.
	 */
	inline public function setMatrix(uniformName:String, matrix:Matrix):Effect {
		if (this._cacheMatrix(uniformName, matrix)) {
			this._engine.setMatrix(this.getUniform(uniformName), matrix);
		}
		
		return this;
	}
	
	/**
	 * Sets a 3x3 matrix on a uniform variable. (Speicified as [1,2,3,4,5,6,7,8,9] will result in [1,2,3][4,5,6][7,8,9] matrix)
	 * @param uniformName Name of the variable.
	 * @param matrix matrix to be set.
	 * @returns this effect.
	 */
	inline public function setMatrix3x3(uniformName:String, matrix:Float32Array):Effect {
		this._valueCache[uniformName] = null;
        this._engine.setMatrix3x3(this.getUniform(uniformName), matrix);
		
        return this;
    }

	/**
	 * Sets a 2x2 matrix on a uniform variable. (Speicified as [1,2,3,4] will result in [1,2][3,4] matrix)
	 * @param uniformName Name of the variable.
	 * @param matrix matrix to be set.
	 * @returns this effect.
	 */
    inline public function setMatrix2x2(uniformName:String, matrix:Float32Array):Effect {
		this._valueCache[uniformName] = null;
        this._engine.setMatrix2x2(this.getUniform(uniformName), matrix);
		
        return this;
    }

	/**
	 * Sets a float on a uniform variable.
	 * @param uniformName Name of the variable.
	 * @param value value to be set.
	 * @returns this effect.
	 */
	public function setFloat(uniformName:String, value:Float):Effect {
		var val = this._valueCache[uniformName];
		if (val != null && val[0] == value) {
			return this;
		}	
		
		this._valueCache.set(uniformName, [value]);		
		this._engine.setFloat(this.getUniform(uniformName), value);
		
		return this;
	}

	/**
	 * Sets a boolean on a uniform variable.
	 * @param uniformName Name of the variable.
	 * @param bool value to be set.
	 * @returns this effect.
	 */
	inline public function setBool(uniformName:String, bool:Bool):Effect {
		var val = this._valueCache[uniformName];
		if (val != null && val[0] == (bool ? 1.0 : 0.0)) {
			return this;
		}
		
		this._valueCache[uniformName] = bool ? [1.0] : [0.0];
		this._engine.setBool(this.getUniform(uniformName), bool);
		
		return this;
	}

	/**
	 * Sets a Vector2 on a uniform variable.
	 * @param uniformName Name of the variable.
	 * @param vector2 vector2 to be set.
	 * @returns this effect.
	 */
	inline public function setVector2(uniformName:String, vector2:Vector2):Effect {
		if (this._cacheFloat2(uniformName, vector2.x, vector2.y)) {
			this._engine.setFloat2(this.getUniform(uniformName), vector2.x, vector2.y);
		}
		
		return this;
	}

	/**
	 * Sets a float2 on a uniform variable.
	 * @param uniformName Name of the variable.
	 * @param x First float in float2.
	 * @param y Second float in float2.
	 * @returns this effect.
	 */
	inline public function setFloat2(uniformName:String, x:Float, y:Float):Effect {
		if (this._cacheFloat2(uniformName, x, y)) {
			this._engine.setFloat2(this.getUniform(uniformName), x, y);
		}
		
		return this;
	}

	/**
	 * Sets a Vector3 on a uniform variable.
	 * @param uniformName Name of the variable.
	 * @param vector3 Value to be set.
	 * @returns this effect.
	 */
	inline public function setVector3(uniformName:String, vector3:Vector3):Effect {
		if (this._cacheFloat3(uniformName, vector3.x, vector3.y, vector3.z)) {
			this._engine.setFloat3(this.getUniform(uniformName), vector3.x, vector3.y, vector3.z);
		}
		
		return this;
	}

	/**
	 * Sets a float3 on a uniform variable.
	 * @param uniformName Name of the variable.
	 * @param x First float in float3.
	 * @param y Second float in float3.
	 * @param z Third float in float3.
	 * @returns this effect.
	 */
	inline public function setFloat3(uniformName:String, x:Float, y:Float, z:Float):Effect {
		if (this._cacheFloat3(uniformName, x, y, z)) {
			this._engine.setFloat3(this.getUniform(uniformName), x, y, z);
		}
		
		return this;
	}
	
	/**
	 * Sets a Vector4 on a uniform variable.
	 * @param uniformName Name of the variable.
	 * @param vector4 Value to be set.
	 * @returns this effect.
	 */
	inline public function setVector4(uniformName:String, vector4:Vector4):Effect {
		if (this._cacheFloat4(uniformName, vector4.x, vector4.y, vector4.z, vector4.w)) {
			this._engine.setFloat4(this.getUniform(uniformName), vector4.x, vector4.y, vector4.z, vector4.w);
		}
		
		return this;
	}

	/**
	 * Sets a float4 on a uniform variable.
	 * @param uniformName Name of the variable.
	 * @param x First float in float4.
	 * @param y Second float in float4.
	 * @param z Third float in float4.
	 * @param w Fourth float in float4.
	 * @returns this effect.
	 */
	inline public function setFloat4(uniformName:String, x:Float, y:Float, z:Float, w:Float):Effect {
		if (this._cacheFloat4(uniformName, x, y, z, w)) {
			this._engine.setFloat4(this.getUniform(uniformName), x, y, z, w);
		}
		
		return this;
	}

	/**
	 * Sets a Color3 on a uniform variable.
	 * @param uniformName Name of the variable.
	 * @param color3 Value to be set.
	 * @returns this effect.
	 */
	inline public function setColor3(uniformName:String, color3:Color3):Effect {
		if (this._cacheFloat3(uniformName, color3.r, color3.g, color3.b)) {
			this._engine.setColor3(this.getUniform(uniformName), color3);
		}
		
		return this;
	}

	/**
	 * Sets a Color4 on a uniform variable.
	 * @param uniformName Name of the variable.
	 * @param color3 Value to be set.
	 * @param alpha Alpha value to be set.
	 * @returns this effect.
	 */
	inline public function setColor4(uniformName:String, color3:Color3, alpha:Float):Effect {
		if (this._cacheFloat4(uniformName, color3.r, color3.g, color3.b, alpha)) {
			this._engine.setColor4(this.getUniform(uniformName), color3, alpha);
		}
		
		return this;
	}
	
	/**
	 * Sets a Color4 on a uniform variable
	 * @param uniformName defines the name of the variable
	 * @param color4 defines the value to be set
	 * @returns this effect.
	 */
	inline public function setDirectColor4(uniformName:String, color4:Color4):Effect {
		if (this._cacheFloat4(uniformName, color4.r, color4.g, color4.b, color4.a)) {
			this._engine.setDirectColor4(this.getUniform(uniformName), color4);
		}
		return this;
	}

}
