package com.babylonhx.materials;

import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.ShaderMaterialOptions') typedef ShaderMaterialOptions = {
	?needAlphaBlending:Bool,
	?needAlphaTesting:Bool,
	?attributes:Array<String>,
	?uniforms:Array<String>,
	?samplers:Array<String>
}

@:expose('BABYLON.ShaderMaterial') class ShaderMaterial extends Material {
	
	private var _shaderPath:String;
	private var _options:ShaderMaterialOptions;
	private var _textures:Map<String, Texture> = new Map<String, Texture>();
	private var _floats:Map<String, Float> = new Map<String, Float>();
	private var _floatsArrays:Map<String, Array<Float>> = new Map<String, Array<Float>>();
	private var _colors3:Map<String, Color3> = new Map<String, Color3>();
	private var _colors4:Map<String, Color4> = new Map<String, Color4>();
	private var _vectors2:Map<String, Vector2> = new Map<String, Vector2>();
	private var _vectors3:Map<String, Vector3> = new Map<String, Vector3>();
	private var _matrices:Map<String, Matrix> = new Map<String, Matrix>();
	private var _cachedWorldViewMatrix = new Matrix();
	private var _renderId:Int;
	

	public function new(name:String, scene:Scene, shaderPath:Dynamic, options:ShaderMaterialOptions) {
		super(name, scene);
		this._shaderPath = shaderPath;

		options.needAlphaBlending = options.needAlphaBlending != null ? options.needAlphaBlending : false;
		options.needAlphaTesting = options.needAlphaTesting != null ? options.needAlphaTesting : false;
		options.attributes = options.attributes != null ? options.attributes : ["position", "normal", "uv"];
		options.uniforms = options.uniforms != null ? options.uniforms : ["worldViewProjection"];
		options.samplers = options.samplers != null ? options.samplers : [];

		this._options = options;
	}

	override public function needAlphaBlending():Bool {
		return this._options.needAlphaBlending;
	}

	override public function needAlphaTesting():Bool {
		return this._options.needAlphaTesting;
	}

	private function _checkUniform(uniformName:String) {
		if (this._options.uniforms.indexOf(uniformName) == -1) {
			this._options.uniforms.push(uniformName);
		}
	}

	public function setTexture(name:String, texture:Texture):ShaderMaterial {
		if (this._options.samplers.indexOf(name) == -1) {
			this._options.samplers.push(name);
		}
		this._textures[name] = texture;

		return this;
	}

	public function setFloat(name:String, value:Float):ShaderMaterial {
		this._checkUniform(name);
		this._floats[name] = value;

		return this;
	}

	public function setFloats(name:String, value:Array<Float>):ShaderMaterial {
		this._checkUniform(name);
		this._floatsArrays[name] = value;

		return this;
	}

	public function setColor3(name:String, value:Color3):ShaderMaterial {
		this._checkUniform(name);
		this._colors3[name] = value;

		return this;
	}

	public function setColor4(name:String, value:Color4):ShaderMaterial {
		this._checkUniform(name);
		this._colors4[name] = value;

		return this;
	}

	public function setVector2(name:String, value:Vector2):ShaderMaterial {
		this._checkUniform(name);
		this._vectors2[name] = value;

		return this;
	}

	public function setVector3(name:String, value:Vector3):ShaderMaterial {
		this._checkUniform(name);
		this._vectors3[name] = value;

		return this;
	}

	public function setMatrix(name:String, value:Matrix):ShaderMaterial {
		this._checkUniform(name);
		this._matrices[name] = value;

		return this;
	}

	override public function isReady(?mesh:AbstractMesh, useInstances:Bool = false/*?useInstances:Bool*/):Bool {
		var scene = this.getScene();
		var engine = scene.getEngine();
		
		if (!this.checkReadyOnEveryCall) {
            if (this._renderId == scene.getRenderId()) {
                return true;
            }
        }
		
        var previousEffect = this._effect;
		this._effect = engine.createEffect(this._shaderPath,
			this._options.attributes,
			this._options.uniforms,
			this._options.samplers,
			"", null, this.onCompiled, this.onError);
			
		if (!this._effect.isReady()) {
			return false;
		}
		
		if (previousEffect != this._effect) {
            scene.resetCachedMaterial();
        }
		
        this._renderId = scene.getRenderId();
		
		return true;
	}

	override public function bindOnlyWorldMatrix(world:Matrix) {
		var scene = this.getScene();

		if (this._options.uniforms.indexOf("world") != -1) {
			this._effect.setMatrix("world", world);
		}

		if (this._options.uniforms.indexOf("worldView") != -1) {
			world.multiplyToRef(scene.getViewMatrix(), this._cachedWorldViewMatrix);
			this._effect.setMatrix("worldView", this._cachedWorldViewMatrix);
		}

		if (this._options.uniforms.indexOf("worldViewProjection") != -1) {
			this._effect.setMatrix("worldViewProjection", world.multiply(scene.getTransformMatrix()));
		}
	}

	override public function bind(world:Matrix, ?mesh:Mesh) {
		// Std values
		this.bindOnlyWorldMatrix(world);

		if (this.getScene().getCachedMaterial() != this) {
			if (this._options.uniforms.indexOf("view") != -1) {
				this._effect.setMatrix("view", this.getScene().getViewMatrix());
			}

			if (this._options.uniforms.indexOf("projection") != -1) {
				this._effect.setMatrix("projection", this.getScene().getProjectionMatrix());
			}

			if (this._options.uniforms.indexOf("viewProjection") != -1) {
				this._effect.setMatrix("viewProjection", this.getScene().getTransformMatrix());
			}

			// Texture
			for (name in this._textures.keys()) {
				this._effect.setTexture(name, this._textures[name]);
			}

			// Float    
			for (name in this._floats.keys()) {
				this._effect.setFloat(name, this._floats[name]);
			}

			// Float s   
			for (name in this._floatsArrays.keys()) {
				this._effect.setArray(name, this._floatsArrays[name]);
			}

			// Color3        
			for (name in this._colors3.keys()) {
				this._effect.setColor3(name, this._colors3[name]);
			}

			// Color4      
			for (name in this._colors4.keys()) {
				var color = this._colors4[name];
				this._effect.setFloat4(name, color.r, color.g, color.b, color.a);
			}

			// Vector2        
			for (name in this._vectors2.keys()) {
				this._effect.setVector2(name, this._vectors2[name]);
			}

			// Vector3        
			for (name in this._vectors3.keys()) {
				this._effect.setVector3(name, this._vectors3[name]);
			}

			// Matrix      
			for (name in this._matrices.keys()) {
				this._effect.setMatrix(name, this._matrices[name]);
			}
		}

		super.bind(world, null);
	}

	override public function dispose(forceDisposeEffect:Bool = false/*?forceDisposeEffect:Bool*/) {
		for (name in this._textures.keys()) {
			this._textures[name].dispose();
		}

		this._textures = null;

		super.dispose(forceDisposeEffect);
	}
	
}
