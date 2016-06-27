package com.babylonhx.materials.lib.grid;

import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector4;
import com.babylonhx.math.Matrix;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.tools.Tags;
import com.babylonhx.animations.IAnimatable;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * The grid materials allows you to wrap any shape with a grid.
 * Colors are customizable.
 */

typedef GRIDMD = GridMaterialDefines
 
class GridMaterial extends Material {
	
	static var fragmentShader:String = "#extension GL_OES_standard_derivatives : enable\n#define SQRT2 1.41421356\n#define PI 3.14159\nprecision highp float;\nuniform vec3 mainColor;\nuniform vec3 lineColor;\nuniform vec4 gridControl;\n\nvarying vec3 vPosition;\nvarying vec3 vNormal;\nfloat getVisibility(float position) {\n\nfloat majorGridFrequency=gridControl.y;\nif (floor(position+0.5) == floor(position/majorGridFrequency+0.5)*majorGridFrequency)\n{\nreturn 1.0;\n} \nreturn gridControl.z;\n}\nfloat getAnisotropicAttenuation(float differentialLength) {\nconst float maxNumberOfLines=10.0;\nreturn clamp(1.0/(differentialLength+1.0)-1.0/maxNumberOfLines,0.0,1.0);\n}\nfloat isPointOnLine(float position,float differentialLength) {\nfloat fractionPartOfPosition=position-floor(position+0.5); \nfractionPartOfPosition/=differentialLength; \nfractionPartOfPosition=clamp(fractionPartOfPosition,-1.,1.);\nfloat result=0.5+0.5*cos(fractionPartOfPosition*PI); \nreturn result; \n}\nfloat contributionOnAxis(float position) {\nfloat differentialLength=length(vec2(dFdx(position),dFdy(position)));\ndifferentialLength*=SQRT2; \n\nfloat result=isPointOnLine(position,differentialLength);\n\nfloat visibility=getVisibility(position);\nresult*=visibility;\n\nfloat anisotropicAttenuation=getAnisotropicAttenuation(differentialLength);\nresult*=anisotropicAttenuation;\nreturn result;\n}\nfloat normalImpactOnAxis(float x) {\nfloat normalImpact=clamp(1.0-2.8*abs(x*x*x),0.0,1.0);\nreturn normalImpact;\n}\nvoid main(void) {\n\nfloat gridRatio=gridControl.x;\nvec3 gridPos=vPosition/gridRatio;\n\nfloat x=contributionOnAxis(gridPos.x);\nfloat y=contributionOnAxis(gridPos.y);\nfloat z=contributionOnAxis(gridPos.z); \n\nvec3 normal=normalize(vNormal);\nx*=normalImpactOnAxis(normal.x);\ny*=normalImpactOnAxis(normal.y);\nz*=normalImpactOnAxis(normal.z);\n\nfloat grid=clamp(x+y+z,0.,1.);\n\nvec3 gridColor=mix(mainColor,lineColor,grid);\n#ifdef TRANSPARENT\nfloat opacity=clamp(grid,0.08,gridControl.w);\ngl_FragColor=vec4(gridColor.rgb,opacity);\n#else\n\ngl_FragColor=vec4(gridColor.rgb,1.0);\n#endif\n}";
	
	static var vertexShader:String = "precision highp float;\n\nattribute vec3 position;\nattribute vec3 normal;\n\nuniform mat4 worldViewProjection;\n\nvarying vec3 vPosition;\nvarying vec3 vNormal;\nvoid main(void) {\ngl_Position=worldViewProjection*vec4(position,1.0);\nvPosition=position;\nvNormal=normal;\n}";

	/**
	 * Main color of the grid (e.g. between lines)
	 */
	@serializeAsColor3()
	public var mainColor:Color3 = Color3.White();
	
	/**
	 * Color of the grid lines.
	 */
	@serializeAsColor3()
	public var lineColor:Color3 = Color3.Black();
	
	/**
	 * The scale of the grid compared to unit.
	 */
	@serialize()
	public var gridRatio:Float = 1.0;
	
	/**
	 * The frequency of thicker lines.
	 */
	@serialize()
	public var majorUnitFrequency:Int = 10;
	
	/**
	 * The visibility of minor units in the grid.
	 */
	@serialize()
	public var minorUnitVisibility:Float = 0.33;
	
	/**
	 * The grid opacity outside of the lines.
	 */
	@serialize()
	public var opacity:Float = 1.0;
	
	private var _gridControl:Vector4;
	
	private var _renderId:Int;
	private var _defines = new GridMaterialDefines();
	private var _cachedDefines = new GridMaterialDefines();
	
	/**
	 * constructor
	 * @param name The name given to the material in order to identify it afterwards.
	 * @param scene The scene the material is used in.
	 */
	public function new(name:String, scene:Scene) {
		super(name, scene);
		
		if (!ShadersStore.Shaders.exists("gridmat.fragment")) {
			ShadersStore.Shaders.set("gridmat.fragment", fragmentShader);
			ShadersStore.Shaders.set("gridmat.vertex", vertexShader);
		}
		
		this._gridControl = new Vector4(this.gridRatio, this.majorUnitFrequency, this.minorUnitVisibility, this.opacity);
	}
	
	/**
	 * Returns wehter or not the grid requires alpha blending.
	 */
	override public function needAlphaBlending():Bool {
		return this.opacity < 1.0;
	}
	
	private function _checkCache(scene:Scene, ?mesh:AbstractMesh, useInstances:Bool = false):Bool {
		if (mesh == null) {
			return true;
		}
		
		if (mesh._materialDefines != null && mesh._materialDefines.isEqual(this._defines)) {
			return true;
		}
		
		return false;
	}

	override public function isReady(?mesh:AbstractMesh, useInstances:Bool = false):Bool {
		if (this.checkReadyOnlyOnce) {
			if (this._wasPreviouslyReady) {
				return true;
			}
		}
		
		var scene = this.getScene();
		
		if (!this.checkReadyOnEveryCall) {
			if (this._renderId == scene.getRenderId()) {
				if (this._checkCache(scene, mesh, useInstances)) {
					return true;
				}
			}
		}
		
		var engine = scene.getEngine();
		var needNormals = true;
		
		this._defines.reset();
		
		if (this.opacity < 1.0) {
			this._defines.defines[GRIDMD.TRANSPARENT] = true;
		}
		
		// Get correct effect      
		if (this._effect == null || !this._defines.isEqual(this._cachedDefines)) {
			this._defines.cloneTo(this._cachedDefines);
			scene.resetCachedMaterial();
			
			// Attributes
			var attribs = [VertexBuffer.PositionKind, VertexBuffer.NormalKind];
			
			// Effect
			var shaderName = scene.getEngine().getCaps().standardDerivatives ? "gridmat" : "legacygridmat";
			
			// Defines
			var join = this._defines.toString();
			this._effect = scene.getEngine().createEffect(shaderName,
				attribs,
				["worldViewProjection", "mainColor", "lineColor", "gridControl"],
				[],
				join, 
				null, 
				this.onCompiled, 
				this.onError
			);
		}
		
		if (!this._effect.isReady()) {
			return false;
		}
		
		this._renderId = scene.getRenderId();
		this._wasPreviouslyReady = true;
		
		return true;
	}
	
	override public function bindOnlyWorldMatrix(world:Matrix) {
		var scene = this.getScene();
		
		this._effect.setMatrix("worldViewProjection", world.multiply(scene.getTransformMatrix()));
	}

	override public function bind(world:Matrix, ?mesh:Mesh) {
		var scene = this.getScene();
		
		// Matrices        
		this.bindOnlyWorldMatrix(world);
		
		// Uniforms
		if (scene.getCachedMaterial() != this) {
			this._effect.setColor3("mainColor", this.mainColor);
			this._effect.setColor3("lineColor", this.lineColor);
			
			this._gridControl.x = this.gridRatio;
			this._gridControl.y = Math.round(this.majorUnitFrequency);
			this._gridControl.z = this.minorUnitVisibility;
			this._gridControl.w = this.opacity;
			this._effect.setVector4("gridControl", this._gridControl);
		}
		
		super.bind(world, mesh);
	}
	
	override public function dispose(forceDisposeEffect:Bool = false) {
		super.dispose(forceDisposeEffect);
	}
	
	override public function clone(name:String, cloneChildren:Bool = false):GridMaterial {
		// TODO
		//return SerializationHelper.Clone(() => new GridMaterial(name, this.getScene()), this);
		return null;
	}

	override public function serialize():Dynamic {
		// TODO
		/*var serializationObject = SerializationHelper.Serialize(this); 
		serializationObject.customType = "BABYLON.GridMaterial"; 
		
		return serializationObject;*/
		return null;
	}

	public static function Parse(source:Dynamic, scene:Scene, rootUrl:String):GridMaterial {
		// TODO
		//return SerializationHelper.Parse(() => new GridMaterial(source.name, scene), source, scene, rootUrl);
		return null;
	}
	
}
