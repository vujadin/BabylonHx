package com.babylonhx.materials;

import com.babylonhx.engine.Engine;
import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.mesh.WebGLBuffer;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector4;
import com.babylonhx.math.Color3;
import com.babylonhx.tools.Tools;

import lime.graphics.opengl.GLUniformLocation;
import lime.utils.Float32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
class UniformBuffer {
	
	private var _engine:Engine;
	private var _buffer:WebGLBuffer;
	private var _data:Array<Float>;
	private var _bufferData:Float32Array;
	private var _dynamic:Bool;
	private var _uniformName:String;
	private var _uniformLocations:Map<String, Int>;
	private var _uniformSizes:Map<String, Int>;
	private var _uniformLocationPointer:Int;
	private var _needSync:Bool;
	private var _cache:Float32Array;
	private var _noUBO:Bool = false;
	private var _currentEffect:Effect;

	// Pool for avoiding memory leaks
	private static var _MAX_UNIFORM_SIZE:Int = 256;
	private static var _tempBuffer:Float32Array = new Float32Array(UniformBuffer._MAX_UNIFORM_SIZE);

	/**
	 * Wrapper for updateUniform.
	 * @method updateMatrix3x3 
	 * @param {string} name Name of the uniform, as used in the uniform block in the shader.
	 * @param {Float32Array} matrix
	 */
	public var updateMatrix3x3:String->Float32Array->Void;

	/**
	 * Wrapper for updateUniform.
	 * @param {string} name Name of the uniform, as used in the uniform block in the shader.
	 * @param {Float32Array} matrix
	 */
	public var updateMatrix2x2:String->Float32Array->Void;

	/**
	 * Wrapper for updateUniform.
	 * @param {string} name Name of the uniform, as used in the uniform block in the shader.
	 * @param {number} x
	 */
	public var updateFloat:String->Float->Void;

	/**
	 * Wrapper for updateUniform.
	 * @param {string} name Name of the uniform, as used in the uniform block in the shader.
	 * @param {number} x
	 * @param {number} y
	 * * @param {string} [suffix] Suffix to add to the uniform name.
	 */
	public var updateFloat2:String->Float->Float->?String->Void;

	/**
	 * Wrapper for updateUniform.
	 * @param {string} name Name of the uniform, as used in the uniform block in the shader.
	 * @param {number} x
	 * @param {number} y
	 * @param {number} z
	 * @param {string} [suffix] Suffix to add to the uniform name.
	 */
	public var updateFloat3:String->Float->Float->Float->?String->Void;

	/**
	 * Wrapper for updateUniform.
	 * @param {string} name Name of the uniform, as used in the uniform block in the shader.
	 * @param {number} x
	 * @param {number} y
	 * @param {number} z
	 * @param {number} w
	 * @param {string} [suffix] Suffix to add to the uniform name.
	 */
	public var updateFloat4:String->Float->Float->Float->Float->?String->Void;

	/**
	 * Wrapper for updateUniform.
	 * @param {string} name Name of the uniform, as used in the uniform block in the shader.
	 * @param {Matrix} A 4x4 matrix.
	 */
	public var updateMatrix:String->Matrix->Void;

	/**
	 * Wrapper for updateUniform.
	 * @param {string} name Name of the uniform, as used in the uniform block in the shader.
	 * @param {Vector3} vector
	 */
	public var updateVector3:String->Vector3->Void;

	/**
	 * Wrapper for updateUniform.
	 * @param {string} name Name of the uniform, as used in the uniform block in the shader.
	 * @param {Vector4} vector
	 */
	public var updateVector4:String->Vector4->Void;

	/**
	 * Wrapper for updateUniform.
	 * @param {string} name Name of the uniform, as used in the uniform block in the shader.
	 * @param {Color3} color
	 * @param {string} [suffix] Suffix to add to the uniform name.
	 */
	public var updateColor3:String->Color3->?String->Void;

	/**
	 * Wrapper for updateUniform.
	 * @param {string} name Name of the uniform, as used in the uniform block in the shader.
	 * @param {Color3} color
	 * @param {number} alpha
	 * @param {string} [suffix] Suffix to add to the uniform name.
	 */
	public var updateColor4:String->Color3->Float->?String->Void;
	

	/**
	 * Uniform buffer objects.
	 * 
	 * Handles blocks of uniform on the GPU.
	 *
	 * If WebGL 2 is not available, this class falls back on traditionnal setUniformXXX calls.
	 *
	 * For more information, please refer to : 
	 * https://www.khronos.org/opengl/wiki/Uniform_Buffer_Object
	 */
	public function new(engine:Engine, ?data:Array<Float>, _dynamic:Bool = false) {
		this._engine = engine;
		this._noUBO = engine.webGLVersion == 1;
		this._dynamic = _dynamic;
		
		this._data = data == null ? [] : data;
		
		this._uniformLocations = new Map();
		this._uniformSizes = new Map();
		this._uniformLocationPointer = 0;
		this._needSync = false;
		
		/*for (i in 0..._tempBuffer.length) {
			_tempBuffer[i] = 0;
		}*/
		
		if (this._noUBO) {
			this.updateMatrix3x3 = this._updateMatrix3x3ForEffect;
			this.updateMatrix2x2 = this._updateMatrix2x2ForEffect;
			this.updateFloat = this._updateFloatForEffect;
			this.updateFloat2 = this._updateFloat2ForEffect;
			this.updateFloat3 = this._updateFloat3ForEffect;
			this.updateFloat4 = this._updateFloat4ForEffect;
			this.updateMatrix = this._updateMatrixForEffect;
			this.updateVector3 = this._updateVector3ForEffect;
			this.updateVector4 = this._updateVector4ForEffect;
			this.updateColor3 = this._updateColor3ForEffect;
			this.updateColor4 = this._updateColor4ForEffect;
		} 
		else {
			this._engine._uniformBuffers.push(this);
			
			this.updateMatrix3x3 = this._updateMatrix3x3ForUniform;
			this.updateMatrix2x2 = this._updateMatrix2x2ForUniform;
			this.updateFloat = this._updateFloatForUniform;
			this.updateFloat2 = this._updateFloat2ForUniform;
			this.updateFloat3 = this._updateFloat3ForUniform;
			this.updateFloat4 = this._updateFloat4ForUniform;
			this.updateMatrix = this._updateMatrixForUniform;
			this.updateVector3 = this._updateVector3ForUniform;
			this.updateVector4 = this._updateVector4ForUniform;
			this.updateColor3 = this._updateColor3ForUniform;
			this.updateColor4 = this._updateColor4ForUniform;
		}
	}

	// Properties
	/**
	 * Indicates if the buffer is using the WebGL2 UBO implementation,
	 * or just falling back on setUniformXXX calls.
	 */
	public var useUbo(get, never):Bool;
	private function get_useUbo():Bool {
		return !this._noUBO;
	}
	
	/**
	 * Indicates if the WebGL underlying uniform buffer is in sync
	 * with the javascript cache data.
	 */
	public var isSync(get, never):Bool;
	private function get_isSync():Bool {
		return !this._needSync;
	}

	/**
	 * Indicates if the WebGL underlying uniform buffer is dynamic.
	 * Also, a dynamic UniformBuffer will disable cache verification and always 
	 * update the underlying WebGL uniform buffer to the GPU.
	 */
	public function isDynamic():Bool {
		return this._dynamic;
	}

	/**
	 * The data cache on JS side.
	 */
	public function getData():Float32Array {
		return this._bufferData;
	}

	/**
	 * The underlying WebGL Uniform buffer.
	 */
	public function getBuffer():WebGLBuffer {
		return this._buffer;
	}

	/**
	 * std140 layout specifies how to align data within an UBO structure.
	 * See https://khronos.org/registry/OpenGL/specs/gl/glspec45.core.pdf#page=159
	 * for specs.
	 */
	private function _fillAlignment(size:Int) {
		// This code has been simplified because we only use floats, vectors of 1, 2, 3, 4 components
		// and 4x4 matrices
		// TODO : change if other types are used
		
		var alignment:Int = size;
		if (size <= 2) {
			alignment = size;
		} 
		else {
			alignment = 4;
		}
		
		if ((this._uniformLocationPointer % alignment) != 0) {
			var oldPointer = this._uniformLocationPointer;
			this._uniformLocationPointer += alignment - (this._uniformLocationPointer % alignment);
			var diff = this._uniformLocationPointer - oldPointer;
			
			for (i in 0...diff) {
				this._data.push(0); 
			}
		}
	}

	/**
	 * Adds an uniform in the buffer.
	 * Warning : the subsequents calls of this function must be in the same order as declared in the shader
	 * for the layout to be correct !
	 * @param {string} name Name of the uniform, as used in the uniform block in the shader.
	 * @param {number|number[]} size Data size, or data directly.
	 */
	public function addUniform(name:String, size:Dynamic) {
		if (this._noUBO) {
			return;
		}
		
		if (this._uniformLocations[name] != null) {
			// Already existing uniform
			return;
		}
		// This function must be called in the order of the shader layout !
		// size can be the size of the uniform, or data directly
		var data:Array<Float> = [];
		if (Std.is(size, Int)) {			
			// Fill with zeros
			for (i in 0...Std.int(size)) {
				data.push(0);
			}
		} 
		else {
			data = size;
		}
		
		this._fillAlignment(data.length);
		this._uniformSizes[name] = data.length;
		this._uniformLocations[name] = this._uniformLocationPointer;
		this._uniformLocationPointer += data.length;
		
		for (i in 0...data.length) {
			this._data.push(data[i]);
		}
		
		this._needSync = true;
	}

	/**
	 * Wrapper for addUniform.
	 * @param {string} name Name of the uniform, as used in the uniform block in the shader.
	 * @param {Matrix} mat A 4x4 matrix.
	 */
	public function addMatrix(name:String, mat:Matrix) {
		this.addUniform(name, mat.toArray());
	}

	/**
	 * Wrapper for addUniform.
	 * @param {string} name Name of the uniform, as used in the uniform block in the shader.
	 * @param {number} x
	 * @param {number} y
	 */
	public function addFloat2(name:String, x:Float, y:Float) {
		this.addUniform(name, [x, y]);
	}

	/**
	 * Wrapper for addUniform.
	 * @param {string} name Name of the uniform, as used in the uniform block in the shader.
	 * @param {number} x
	 * @param {number} y
	 * @param {number} z
	 */
	public function addFloat3(name:String, x:Float, y:Float, z:Float) {
		this.addUniform(name, [x, y, z]);
	}

	/**
	 * Wrapper for addUniform.
	 * @param {string} name Name of the uniform, as used in the uniform block in the shader.
	 * @param {Color3} color
	 */
	public function addColor3(name:String, color:Color3) {
		var temp:Array<Float> = [];
		color.toArray(temp);
		this.addUniform(name, temp);
	}

	/**
	 * Wrapper for addUniform.
	 * @param {string} name Name of the uniform, as used in the uniform block in the shader.
	 * @param {Color3} color
	 * @param {number} alpha
	 */
	public function addColor4(name:String, color:Color3, alpha:Float) {
		var temp:Array<Float> = [];
		color.toArray(temp);
		temp.push(alpha);
		this.addUniform(name, temp);
	}

	/**
	 * Wrapper for addUniform.
	 * @param {string} name Name of the uniform, as used in the uniform block in the shader.
	 * @param {Vector3} vector
	 */
	public function addVector3(name:String, vector:Vector3) {
		var temp:Array<Float> = [];
		vector.toArray(temp);
		this.addUniform(name, temp);
	}

	/**
	 * Wrapper for addUniform.
	 * @param {string} name Name of the uniform, as used in the uniform block in the shader.
	 */
	public function addMatrix3x3(name:String) {
		this.addUniform(name, 12);
	}

	/**
	 * Wrapper for addUniform.
	 * @param {string} name Name of the uniform, as used in the uniform block in the shader.
	 */
	public function addMatrix2x2(name:String) {
		this.addUniform(name, 8);
	}

	/**
	 * Effectively creates the WebGL Uniform Buffer, once layout is completed with `addUniform`.
	 */
	public function create() {
		if (this._noUBO) {
			return;
		}
		if (this._buffer != null) {
			return; // nothing to do
		}
		
		// See spec, alignment must be filled as a vec4
		this._fillAlignment(4);
		this._bufferData = new Float32Array(this._data);
		
		this._rebuild();
		
		this._needSync = true;
	}
	
	public function _rebuild() {
		if (this._noUBO) {
			return;
		}
		
		if (this._dynamic) {
			this._buffer = this._engine.createDynamicUniformBuffer(this._bufferData);
		}
		else {
			this._buffer = this._engine.createUniformBuffer(this._bufferData);
		}
	}

	/**
	 * Updates the WebGL Uniform Buffer on the GPU.
	 * If the `dynamic` flag is set to true, no cache comparison is done.
	 * Otherwise, the buffer will be updated only if the cache differs.
	 */
	public function update() {
		if (this._buffer == null) {
			this.create();
			return;
		}
		
		if (!this._dynamic && !this._needSync) {
			return;
		}
		
		this._engine.updateUniformBuffer(this._buffer, this._bufferData);
		
		this._needSync = false;
	}

	/**
	 * Updates the value of an uniform. The `update` method must be called afterwards to make it effective in the GPU.
	 * @param {string} uniformName Name of the uniform, as used in the uniform block in the shader.
	 * @param {number[]|Float32Array} data Flattened data
	 * @param {number} size Size of the data.
	 */
	public function updateUniform(uniformName:String, data:Float32Array, size:Int) {
		var location = this._uniformLocations[uniformName];
		if (location == null) {
			if (this._buffer != null) {
				// Cannot add an uniform if the buffer is already created
				Tools.Error("Cannot add an uniform after UBO has been created.");
				return;
			}
			this.addUniform(uniformName, size);
			location = this._uniformLocations[uniformName];
		}
		
		if (this._buffer == null) {
			this.create();
		}
		
		if (!this._dynamic) {
			// Cache for static uniform buffers
			var changed = false;
			for (i in 0...size) {
				if (this._bufferData[location + i] != data[i]) {
					changed = true;
					this._bufferData[location + i] = data[i];
				}
			}
			
			this._needSync = this._needSync || changed;
		} 
		else {
			// No cache for dynamic
			for (i in 0...size) {
				this._bufferData[location + i] = data[i];
			}
		}
	}

	// Update methods

	private function _updateMatrix3x3ForUniform(name:String, matrix:Float32Array) {
		// To match std140, matrix must be realigned
		for (i in 0...3) {
			UniformBuffer._tempBuffer[i * 4] = matrix[i * 3];
			UniformBuffer._tempBuffer[i * 4 + 1] = matrix[i * 3 + 1];
			UniformBuffer._tempBuffer[i * 4 + 2] = matrix[i * 3 + 2];
			UniformBuffer._tempBuffer[i * 4 + 3] = 0.0;
		}
		
		this.updateUniform(name, UniformBuffer._tempBuffer, 12);
	}

	private function _updateMatrix3x3ForEffect(name:String, matrix:Float32Array) {
		this._currentEffect.setMatrix3x3(name, matrix);
	}

	private function _updateMatrix2x2ForEffect(name:String, matrix:Float32Array) {
		this._currentEffect.setMatrix2x2(name, matrix);
	}

	private function _updateMatrix2x2ForUniform(name:String, matrix:Float32Array) {
		// To match std140, matrix must be realigned
		for (i in 0...2) {
			UniformBuffer._tempBuffer[i * 4] = matrix[i * 2];
			UniformBuffer._tempBuffer[i * 4 + 1] = matrix[i * 2 + 1];
			UniformBuffer._tempBuffer[i * 4 + 2] = 0.0;
			UniformBuffer._tempBuffer[i * 4 + 3] = 0.0;
		}
		
		this.updateUniform(name, UniformBuffer._tempBuffer, 8);
	}

	private function _updateFloatForEffect(name:String, x:Float) {
		this._currentEffect.setFloat(name, x);
	}

	private function _updateFloatForUniform(name:String, x:Float) {
		UniformBuffer._tempBuffer[0] = x;
		this.updateUniform(name, UniformBuffer._tempBuffer, 1);
	}

	private function _updateFloat2ForEffect(name:String, x:Float, y:Float, suffix:String = '') {
		this._currentEffect.setFloat2(name + suffix, x, y);
	}

	private function _updateFloat2ForUniform(name:String, x:Float, y:Float, suffix:String = '') {
		UniformBuffer._tempBuffer[0] = x;
		UniformBuffer._tempBuffer[1] = y;
		this.updateUniform(name, UniformBuffer._tempBuffer, 2);
	}        

	private function _updateFloat3ForEffect(name:String, x:Float, y:Float, z:Float, suffix:String = "") {
		this._currentEffect.setFloat3(name + suffix, x, y, z);
	}

	private function _updateFloat3ForUniform(name:String, x:Float, y:Float, z:Float, suffix:String = "") {
		UniformBuffer._tempBuffer[0] = x;
		UniformBuffer._tempBuffer[1] = y;
		UniformBuffer._tempBuffer[2] = z;
		this.updateUniform(name, UniformBuffer._tempBuffer, 3);
	}

	private function _updateFloat4ForEffect(name:String, x:Float, y:Float, z:Float, w:Float, suffix:String = "") {
		this._currentEffect.setFloat4(name + suffix, x, y, z, w);
	}

	private function _updateFloat4ForUniform(name:String, x:Float, y:Float, z:Float, w:Float, suffix:String = "") {
		UniformBuffer._tempBuffer[0] = x;
		UniformBuffer._tempBuffer[1] = y;
		UniformBuffer._tempBuffer[2] = z;
		UniformBuffer._tempBuffer[3] = w;
		this.updateUniform(name, UniformBuffer._tempBuffer, 4);
	}

	private function _updateMatrixForEffect(name:String, mat:Matrix) {
		this._currentEffect.setMatrix(name, mat);
	}

	private function _updateMatrixForUniform(name:String, mat:Matrix) {
		this.updateUniform(name, mat.m, 16);
	}

	private function _updateVector3ForEffect(name:String, vector:Vector3) {
		this._currentEffect.setVector3(name, vector);
	}

	private function _updateVector3ForUniform(name:String, vector:Vector3) {
		vector.toFloat32Array(UniformBuffer._tempBuffer);
		this.updateUniform(name, UniformBuffer._tempBuffer, 3);
	}

	private function _updateVector4ForEffect(name:String, vector:Vector4) {
		this._currentEffect.setVector4(name, vector);
	}

	private function _updateVector4ForUniform(name:String, vector:Vector4) {
		vector.toFloat32Array(UniformBuffer._tempBuffer);
		this.updateUniform(name, UniformBuffer._tempBuffer, 4);
	}

	private function _updateColor3ForEffect(name:String, color:Color3, suffix:String = "") {
		this._currentEffect.setColor3(name + suffix, color);
	}

	private function _updateColor3ForUniform(name:String, color:Color3, suffix:String = "") {
		color.toFloat32Array(UniformBuffer._tempBuffer);
		this.updateUniform(name, UniformBuffer._tempBuffer, 3);
	}

	private function _updateColor4ForEffect(name:String, color:Color3, alpha:Float, suffix:String = "") {
		this._currentEffect.setColor4(name + suffix, color, alpha);
	}

	private function _updateColor4ForUniform(name:String, color:Color3, alpha:Float, suffix:String = "") {
		color.toFloat32Array(UniformBuffer._tempBuffer);
		UniformBuffer._tempBuffer[3] = alpha;
		this.updateUniform(name, UniformBuffer._tempBuffer, 4);
	}

	/**
	 * Sets a sampler uniform on the effect.
	 * @param {string} name Name of the sampler.
	 * @param {Texture} texture
	 */
	public function setTexture(name:String, texture:BaseTexture) {
		this._currentEffect.setTexture(name, texture);
	}

	/**
	 * Directly updates the value of the uniform in the cache AND on the GPU.
	 * @param {string} uniformName Name of the uniform, as used in the uniform block in the shader.
	 * @param {number[]|Float32Array} data Flattened data
	 */
	public function updateUniformDirectly(uniformName:String, data:Float32Array) {
		this.updateUniform(uniformName, data, data.length);
		
		this.update();
	}

	/**
	 * Binds this uniform buffer to an effect.
	 * @param {Effect} effect
	 * @param {string} name Name of the uniform block in the shader.
	 */
	public function bindToEffect(effect:Effect, name:String) {
		this._currentEffect = effect;
		
		if (this._noUBO) {
			return;
		}
		
		effect.bindUniformBuffer(this._buffer, name);
	}

	/**
	 * Disposes the uniform buffer.
	 */
	public function dispose() {
		if (this._noUBO) {
			return;
		}
		
		var index = this._engine._uniformBuffers.indexOf(this);
		
		if (index != -1) {
			this._engine._uniformBuffers.splice(index, 1);
		}
		
		if (this._buffer == null) {
			return;
		}
		if (this._engine._releaseBuffer(this._buffer)) {
			this._buffer = null;
		}
	}
	
}
