package com.babylonhx.materials;

import com.babylonhx.Engine;
import com.babylonhx.materials.textures.BabylonTexture;
import com.babylonhx.tools.Tools;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.postprocess.PostProcess;
import com.babylonhx.materials.textures.BaseTexture;

#if nme
import nme.Assets;
import nme.gl.GL;
import nme.utils.Float32Array;
import nme.gl.GLProgram;
import nme.gl.GLTexture;
import nme.gl.GLUniformLocation;
#elseif openfl
import openfl.Assets;
import openfl.gl.GL;
import openfl.utils.Float32Array;
import openfl.gl.GLProgram;
import openfl.gl.GLTexture;
import openfl.gl.GLUniformLocation;
#elseif snow
import snow.assets.Assets;
import snow.assets.AssetText;
import snow.render.opengl.GL;
import snow.render.opengl.GLProgram;
import snow.render.opengl.GLTexture;
import snow.render.opengl.GLUniformLocation;
import snow.utils.Float32Array;
#elseif kha

#end

/**
 * ...
 * @author Krtolica Vujadin
 */

class Effect {
		
	public var name:Dynamic;
	public var defines:String;
	public var onCompiled:Effect->Void;
	public var onError:Effect->String->Void;

	private var _engine:Engine;
	private var _uniformsNames:Array<String>;
	private var _samplers:Array<String>;
	private var _isReady:Bool = false;
	private var _compilationError:String = "";
	private var _attributesNames:Array<String>;
	private var _attributes:Array<Int>;
	private var _uniforms:Array<GLUniformLocation>;
	public var _key:String;

	private var _program:GLProgram;
	private var _valueCache:Map<String, Array<Float>>;		
	

	public function new(baseName:Dynamic, attributesNames:Array<String>, uniformsNames:Array<String>, samplers:Array<String>, engine:Engine, ?defines:String, ?fallbacks:EffectFallbacks, ?onCompiled:Effect->Void, ?onError:Effect->String->Void) {
		this._engine = engine;
		this.name = baseName;
		this.defines = defines;
		this._uniformsNames = uniformsNames.concat(samplers);
		this._samplers = samplers;
		this._attributesNames = attributesNames;
		
		this.onError = onError;
		this.onCompiled = onCompiled;
		
		var vertex:String = Reflect.field(baseName, "vertex") != null ? baseName.vertex : baseName;
        var fragment:String = Reflect.field(baseName, "fragment") != null ? baseName.fragment : baseName;
		
        var vertexShaderUrl:String = "";
        if (vertex.charAt(0) == ".") {
            vertexShaderUrl = vertex;
        } else {
            vertexShaderUrl = Engine.ShadersRepository + vertex;
        }
        var fragmentShaderUrl:String = "";
        if (fragment.charAt(0) == ".") {
            fragmentShaderUrl = fragment;
        } else {
            fragmentShaderUrl = Engine.ShadersRepository + fragment;
        }
		
        var _vertexCode:String = "";
        if (ShadersStore.Shaders.exists(vertex + ".vertex")) {
            _vertexCode = ShadersStore.Shaders.get(vertex + ".vertex");
        } else {
			#if (nme || openfl)
            _vertexCode = StringTools.trim(Assets.getText(vertexShaderUrl + ".vertex.fx"));
			#elseif snow
			
			#elseif kha
			
			#elseif foo3d
			
			#end
        }
		
        var _fragmentCode:String = "";
        if (ShadersStore.Shaders.exists(fragment + ".fragment")) {
            _fragmentCode = ShadersStore.Shaders.get(fragment + ".fragment");
        } else {
			#if (nme || openfl)
            _fragmentCode = StringTools.trim(Assets.getText(fragmentShaderUrl + ".fragment.fx"));
			#elseif snow
			
			#elseif kha
			
			#elseif foo3d
			
			#end
        }
		
		this._prepareEffect(_vertexCode, _fragmentCode, attributesNames, defines, fallbacks);
		
		// Cache
        this._valueCache = new Map<String, Array<Float>>();
	}

	// Properties
	public function isReady():Bool {
		return this._isReady;
	}

	public function getProgram():GLProgram {
		return this._program;
	}

	public function getAttributesNames():Array<String> {
		return this._attributesNames;
	}

	public function getAttributeLocation(index:Int):Int {
		return this._attributes[index];
	}

	public function getAttributeLocationByName(name:String):Int {
		var index = this._attributesNames.indexOf(name);

		return this._attributes[index];
	}

	public function getAttributesCount():Int {
		return this._attributes.length;
	}

	public function getUniformIndex(uniformName:String):Int {
		return this._uniformsNames.indexOf(uniformName);
	}

	public function getUniform(uniformName:String):GLUniformLocation {
		return this._uniforms[this._uniformsNames.indexOf(uniformName)];
	}

	public function getSamplers():Array<String> {
		return this._samplers;
	}

	public function getCompilationError():String {
		return this._compilationError;
	}

	// Methods
	public function _loadVertexShader(vertex:String, callbackFn:String->Void) {
        // Is in local store ?
        if (ShadersStore.Shaders.exists(vertex + "VertexShader")) {
            callbackFn(ShadersStore.Shaders.get(vertex + "VertexShader"));
            return;
        }
        
        var vertexShaderUrl:String = "";
		
        if (vertex.charAt(0) == ".") {
            vertexShaderUrl = vertex;
        } else {
            vertexShaderUrl = Engine.ShadersRepository + vertex;
        }
		
        // Vertex shader
        #if (nme || openfl)
		var vs = StringTools.trim(Assets.getText("assets/shaders/" + vertex + ".vertex.fx"));
		#elseif snow
			
		#elseif kha
		
		#elseif foo3d
		
		#end
		callbackFn(vs);
    }
	
	public function _loadFragmentShader(fragment:String, callbackFn:String->Void) {
        // Is in local store ?
        if (ShadersStore.Shaders.exists(fragment + "PixelShader")) {
            callbackFn(ShadersStore.Shaders.get(fragment + "PixelShader"));
            return;
        }
        
        var fragmentShaderUrl:String = "";
		
        if (fragment.charAt(0) == ".") {
            fragmentShaderUrl = fragment;
        } else {
            fragmentShaderUrl = Engine.ShadersRepository + fragment;
        }
		
        // Fragment shader
        #if (nme || openfl)
		var vs = StringTools.trim(Assets.getText("assets/shaders/" + fragment + ".fragment.fx"));
		#elseif snow
			
		#elseif kha
		
		#elseif foo3d
		
		#end
		callbackFn(vs);
    }
	
	private function _prepareEffect(vertexSourceCode:String, fragmentSourceCode:String, attributesNames:Array<String>, defines:String, ?fallbacks:EffectFallbacks) {
        try {
            var engine = this._engine;
			
            this._program = engine.createShaderProgram(vertexSourceCode, fragmentSourceCode, defines);
			
            this._uniforms = engine.getUniforms(this._program, this._uniformsNames);
            this._attributes = engine.getAttributes(this._program, attributesNames);
						
			var index:Int = 0;
			while(index < this._samplers.length) {
                var sampler = this.getUniform(this._samplers[index]);
				#if html5
				if (sampler == null) {
				#else
                if (sampler < 0) {
				#end
                    this._samplers.splice(index, 1);
                    index--;
                }
				
				index++;
            }
						
            engine.bindSamplers(this);
			
            this._isReady = true;
			
			if (this.onCompiled != null) {
				this.onCompiled(this);
			}
			
        } catch (e:Dynamic) {
			trace(e);
			#if js
			// Is it a problem with precision?
			if (e.message.indexOf("highp") != -1) {
				vertexSourceCode = StringTools.replace(vertexSourceCode, "precision highp float", "precision mediump float");
				fragmentSourceCode = StringTools.replace(fragmentSourceCode, "precision highp float", "precision mediump float");
				
				this._prepareEffect(vertexSourceCode, fragmentSourceCode, attributesNames, defines, fallbacks);
				
				return;
			}
			#end
            // Let's go through fallbacks then
			if (fallbacks != null && fallbacks.isMoreFallbacks) {
				defines = fallbacks.reduce(defines);
				this._prepareEffect(vertexSourceCode, fragmentSourceCode, attributesNames, defines, fallbacks);
            } else {
                trace("Unable to compile effect: " + this.name);
                trace("Defines: " + defines);
                trace("Error: " + e);
                this._compilationError = cast e;
				
				if (this.onError != null) {
					this.onError(this, this._compilationError);
				}
            }
        }
    }

	public function _bindTexture(channel:String, texture:BabylonTexture) {
		this._engine._bindTexture(this._samplers.indexOf(channel), texture);
	}

	public function setTexture(channel:String, texture:BaseTexture) {
		this._engine.setTexture(this._samplers.indexOf(channel), texture);
	}

	public function setTextureFromPostProcess(channel:String, postProcess:PostProcess) {
		this._engine.setTextureFromPostProcess(this._samplers.indexOf(channel), postProcess);
	}

	//public _cacheMatrix(uniformName, matrix) {
	//    if (!this._valueCache[uniformName]) {
	//        this._valueCache[uniformName] = new Matrix();
	//    }

	//    for (var index = 0; index < 16; index++) {
	//        this._valueCache[uniformName].m[index] = matrix.m[index];
	//    }
	//};

	inline public function _cacheFloat2(uniformName:String, x:Float, y:Float) {
		if (!this._valueCache.exists(uniformName)) {
			this._valueCache[uniformName] = [x, y];
		} else {		
			this._valueCache[uniformName][0] = x;
			this._valueCache[uniformName][1] = y;
		}
	}

	inline public function _cacheFloat3(uniformName:String, x:Float, y:Float, z:Float) {
		if (!this._valueCache.exists(uniformName)) {
			this._valueCache[uniformName] = [x, y, z];
		} else {		
			this._valueCache[uniformName][0] = x;
			this._valueCache[uniformName][1] = y;
			this._valueCache[uniformName][2] = z;
		}
	}

	inline public function _cacheFloat4(uniformName:String, x:Float, y:Float, z:Float, w:Float) {
		if (!this._valueCache.exists(uniformName)) {
			this._valueCache[uniformName] = [x, y, z, w];
		} else {		
			this._valueCache[uniformName][0] = x;
			this._valueCache[uniformName][1] = y;
			this._valueCache[uniformName][2] = z;
			this._valueCache[uniformName][3] = w;
		}
	}

	inline public function setArray(uniformName:String, array:Array<Float>):Effect {
		this._engine.setArray(this.getUniform(uniformName), array);
		
		return this;
	}

	inline public function setMatrices(uniformName:String, matrices: #if html5 Float32Array #else Array<Float> #end ):Effect {
		this._engine.setMatrices(this.getUniform(uniformName), matrices);
		
		return this;
	}

	inline public function setMatrix(uniformName:String, matrix:Matrix):Effect {
		//if (this._valueCache[uniformName] && this._valueCache[uniformName].equals(matrix))
		//    return;
		
		//this._cacheMatrix(uniformName, matrix);
		this._engine.setMatrix(this.getUniform(uniformName), matrix);
		
		return this;
	}

	inline public function setFloat(uniformName:String, value:Float):Effect {
		if (!(this._valueCache.exists(uniformName) && this._valueCache[uniformName][0] == value)) {
			this._valueCache.set(uniformName, [value]);		
			this._engine.setFloat(this.getUniform(uniformName), value);
		}	
		
		return this;
	}

	inline public function setBool(uniformName:String, bool:Bool):Effect {
		if (!(this._valueCache.exists(uniformName) && this._valueCache[uniformName][0] == (bool ? 1.0 : 0.0))) {
			this._valueCache[uniformName] = bool ? [1.0] : [0.0];
			this._engine.setBool(this.getUniform(uniformName), bool);
		}
		
		return this;
	}

	inline public function setVector2(uniformName:String, vector2:Vector2):Effect {
		if (!(this._valueCache.exists(uniformName) && this._valueCache[uniformName][0] == vector2.x && this._valueCache[uniformName][1] == vector2.y)) {
			this._cacheFloat2(uniformName, vector2.x, vector2.y);
			this._engine.setFloat2(this.getUniform(uniformName), vector2.x, vector2.y);
		}
		
		return this;
	}

	inline public function setFloat2(uniformName:String, x:Float, y:Float):Effect {
		if (!(this._valueCache.exists(uniformName) && this._valueCache[uniformName][0] == x && this._valueCache[uniformName][1] == y)) {
			this._cacheFloat2(uniformName, x, y);
			this._engine.setFloat2(this.getUniform(uniformName), x, y);
		}
		
		return this;
	}

	inline public function setVector3(uniformName:String, vector3:Vector3):Effect {
		if (!(this._valueCache.exists(uniformName) && this._valueCache[uniformName][0] == vector3.x && this._valueCache[uniformName][1] == vector3.y && this._valueCache[uniformName][2] == vector3.z)) {
			this._cacheFloat3(uniformName, vector3.x, vector3.y, vector3.z);
			this._engine.setFloat3(this.getUniform(uniformName), vector3.x, vector3.y, vector3.z);
		}		
		
		return this;
	}

	inline public function setFloat3(uniformName:String, x:Float, y:Float, z:Float):Effect {
		if (!(this._valueCache.exists(uniformName) && this._valueCache[uniformName][0] == x && this._valueCache[uniformName][1] == y && this._valueCache[uniformName][2] == z)) {
			this._cacheFloat3(uniformName, x, y, z);
			this._engine.setFloat3(this.getUniform(uniformName), x, y, z);
		}		
		
		return this;
	}

	public function setFloat4(uniformName:String, x:Float, y:Float, z:Float, w:Float):Effect {
		if (!(this._valueCache.exists(uniformName) && this._valueCache[uniformName][0] == x && this._valueCache[uniformName][1] == y && this._valueCache[uniformName][2] == z && this._valueCache[uniformName][3] == w)) {
			this._cacheFloat4(uniformName, x, y, z, w);
			this._engine.setFloat4(this.getUniform(uniformName), x, y, z, w);
		}		
		
		return this;
	}

	inline public function setColor3(uniformName:String, color3:Color3):Effect {
		if (!(this._valueCache.exists(uniformName) && this._valueCache[uniformName][0] == color3.r && this._valueCache[uniformName][1] == color3.g && this._valueCache[uniformName][2] == color3.b)) {
			this._cacheFloat3(uniformName, color3.r, color3.g, color3.b);
			this._engine.setColor3(this.getUniform(uniformName), color3);
		} 
		
		return this;
	}

	inline public function setColor4(uniformName:String, color3:Color3, alpha:Float):Effect {
		if (!(this._valueCache.exists(uniformName) && this._valueCache[uniformName][0] == color3.r && this._valueCache[uniformName][1] == color3.g && this._valueCache[uniformName][2] == color3.b && this._valueCache[uniformName][3] == alpha)) {
			this._cacheFloat4(uniformName, color3.r, color3.g, color3.b, alpha);
			this._engine.setColor4(this.getUniform(uniformName), color3, alpha);
		}	
		
		return this;
	}

}
