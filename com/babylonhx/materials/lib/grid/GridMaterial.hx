package com.babylonhx.materials.lib.grid;

import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector4;
import com.babylonhx.math.Matrix;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.mesh.BaseSubMesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.tools.Tags;
import com.babylonhx.animations.IAnimatable;
import com.babylonhx.tools.serialization.SerializationHelper;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * The grid materials allows you to wrap any shape with a grid.
 * Colors are customizable.
 */
 
class GridMaterial extends PushMaterial {
	
	static var _fragmentShader:String = "#extension GL_OES_standard_derivatives : enable\n#define SQRT2 1.41421356\n#define PI 3.14159\nprecision highp float;\nuniform vec3 mainColor;\nuniform vec3 lineColor;\nuniform vec4 gridControl;\n\n#ifdef TRANSPARENT\nvarying vec4 vCameraSpacePosition;\n#endif\nvarying vec3 vPosition;\nvarying vec3 vNormal;\n#include<fogFragmentDeclaration>\nfloat getVisibility(float position) {\n\nfloat majorGridFrequency=gridControl.y;\nif (floor(position+0.5) == floor(position/majorGridFrequency+0.5)*majorGridFrequency)\n{\nreturn 1.0;\n} \nreturn gridControl.z;\n}\nfloat getAnisotropicAttenuation(float differentialLength) {\nconst float maxNumberOfLines=10.0;\nreturn clamp(1.0/(differentialLength+1.0)-1.0/maxNumberOfLines,0.0,1.0);\n}\nfloat isPointOnLine(float position,float differentialLength) {\nfloat fractionPartOfPosition=position-floor(position+0.5); \nfractionPartOfPosition/=differentialLength; \nfractionPartOfPosition=clamp(fractionPartOfPosition,-1.,1.);\nfloat result=0.5+0.5*cos(fractionPartOfPosition*PI); \nreturn result; \n}\nfloat contributionOnAxis(float position) {\nfloat differentialLength=length(vec2(dFdx(position),dFdy(position)));\ndifferentialLength*=SQRT2; \n\nfloat result=isPointOnLine(position,differentialLength);\n\nfloat visibility=getVisibility(position);\nresult*=visibility;\n\nfloat anisotropicAttenuation=getAnisotropicAttenuation(differentialLength);\nresult*=anisotropicAttenuation;\nreturn result;\n}\nfloat normalImpactOnAxis(float x) {\nfloat normalImpact=clamp(1.0-3.0*abs(x*x*x),0.0,1.0);\nreturn normalImpact;\n}\nvoid main(void) {\n\nfloat gridRatio=gridControl.x;\nvec3 gridPos=vPosition/gridRatio;\n\nfloat x=contributionOnAxis(gridPos.x);\nfloat y=contributionOnAxis(gridPos.y);\nfloat z=contributionOnAxis(gridPos.z);\n\nvec3 normal=normalize(vNormal);\nx*=normalImpactOnAxis(normal.x);\ny*=normalImpactOnAxis(normal.y);\nz*=normalImpactOnAxis(normal.z);\n\nfloat grid=clamp(x+y+z,0.,1.);\n\nvec3 color=mix(mainColor,lineColor,grid);\n#ifdef FOG\n#include<fogFragment>\n#endif\n#ifdef TRANSPARENT\nfloat distanceToFragment=length(vCameraSpacePosition.xyz);\nfloat cameraPassThrough=clamp(distanceToFragment-0.25,0.0,1.0);\nfloat opacity=clamp(grid,0.08,cameraPassThrough*gridControl.w*grid);\ngl_FragColor=vec4(color.rgb,opacity);\n#ifdef PREMULTIPLYALPHA\ngl_FragColor.rgb*=opacity;\n#endif\n#else\n\ngl_FragColor=vec4(color.rgb,1.0);\n#endif\n}";
	
	static var _vertexShader:String = "precision highp float;\n\nattribute vec3 position;\nattribute vec3 normal;\n\nuniform mat4 projection;\nuniform mat4 world;\nuniform mat4 view;\nuniform mat4 worldView;\n\n#ifdef TRANSPARENT\nvarying vec4 vCameraSpacePosition;\n#endif\nvarying vec3 vPosition;\nvarying vec3 vNormal;\n#include<fogVertexDeclaration>\nvoid main(void) {\n#ifdef FOG\nvec4 worldPos=world*vec4(position,1.0);\n#endif\n#include<fogVertex>\nvec4 cameraSpacePosition=worldView*vec4(position,1.0);\ngl_Position=projection*cameraSpacePosition;\n#ifdef TRANSPARENT\nvCameraSpacePosition=cameraSpacePosition;\n#endif\nvPosition=position;\nvNormal=normal;\n}";

	/**
	 * Main color of the grid (e.g. between lines)
	 */
	@serializeAsColor3()
	public var mainColor:Color3 = Color3.Black();
	
	/**
	 * Color of the grid lines.
	 */
	@serializeAsColor3()
	public var lineColor:Color3 = Color3.Teal();
	
	/**
	 * The scale of the grid compared to unit.
	 */
	@serialize()
	public var gridRatio:Float = 1.0;
	
	/**
     * Allows setting an offset for the grid lines.
     */
    @serializeAsColor3()
    public var gridOffset:Vector3 = Vector3.Zero();
	
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
	
	/**
	 * Determine RBG output is premultiplied by alpha value.
	 */
	@serialize()
	public var preMultiplyAlpha:Bool = false;
	
	private var _gridControl:Vector4;
	
	private var _renderId:Int;
	
	/**
	 * constructor
	 * @param name The name given to the material in order to identify it afterwards.
	 * @param scene The scene the material is used in.
	 */
	public function new(name:String, scene:Scene) {
		super(name, scene);
		
		if (!ShadersStore.Shaders.exists("gridPixelShader")) {
			ShadersStore.Shaders.set("gridPixelShader", _fragmentShader);
			ShadersStore.Shaders.set("gridVertexShader", _vertexShader);
		}
		
		this._gridControl = new Vector4(this.gridRatio, this.majorUnitFrequency, this.minorUnitVisibility, this.opacity);
	}
	
	/**
	 * Returns wehter or not the grid requires alpha blending.
	 */
	override public function needAlphaBlending():Bool {
		return this.opacity < 1.0;
	}
	
	override public function isReadyForSubMesh(mesh:AbstractMesh, subMesh:BaseSubMesh, useInstances:Bool = false):Bool {
		if (this.isFrozen) {
			if (this._wasPreviouslyReady && subMesh.effect != null) {
				return true;
			}
		}
		
		if (subMesh._materialDefines == null) {
			subMesh._materialDefines = new GridMaterialDefines();
		}
		
		var defines:GridMaterialDefines = cast subMesh._materialDefines;
		var scene = this.getScene();
		
		if (!this.checkReadyOnEveryCall && subMesh.effect != null) {
			if (this._renderId == scene.getRenderId()) {
				return true;
			}
		}
		
		var engine = scene.getEngine();
		
		if (defines.TRANSPARENT != (this.opacity < 1.0)) {
			defines.TRANSPARENT = !defines.TRANSPARENT;
			defines.markAsUnprocessed();
		}
		
		if (defines.PREMULTIPLYALPHA != this.preMultiplyAlpha) {
			defines.PREMULTIPLYALPHA = !defines.PREMULTIPLYALPHA;
			defines.markAsUnprocessed();
		}
		
		MaterialHelper.PrepareDefinesForMisc(mesh, scene, false, false, this.fogEnabled, defines);
		
		// Get correct effect      
		if (defines.isDirty) {
			defines.markAsProcessed();
			scene.resetCachedMaterial();
			
			// Attributes
			var attribs = [VertexBuffer.PositionKind, VertexBuffer.NormalKind];
			
			// Defines
			var join:String = defines.toString();
			subMesh.setEffect(scene.getEngine().createEffect("grid",
				attribs,
				["projection", "worldView", "mainColor", "lineColor", "gridControl", "gridOffset", "vFogInfos", "vFogColor", "world", "view"],
				[],
				join,
				null,
				this.onCompiled,
				this.onError), defines);
		}
		
		if (!subMesh.effect.isReady()) {
			return false;
		}
		
		this._renderId = scene.getRenderId();
		this._wasPreviouslyReady = true;
		
		return true;
	}
	
	override public function bindForSubMesh(world:Matrix, mesh:Mesh, subMesh:SubMesh) {
		var scene = this.getScene();
		
		var defines:GridMaterialDefines = cast subMesh._materialDefines;
		if (defines == null) {
			return;
		}
		
		var effect = subMesh.effect;
		this._activeEffect = effect;
		
		// Matrices
		this.bindOnlyWorldMatrix(world);
		this._activeEffect.setMatrix("worldView", world.multiply(scene.getViewMatrix()));
		this._activeEffect.setMatrix("view", scene.getViewMatrix());
		this._activeEffect.setMatrix("projection", scene.getProjectionMatrix());
		
		// Uniforms
		if (this._mustRebind(scene, effect)) {
			this._activeEffect.setColor3("mainColor", this.mainColor);
			this._activeEffect.setColor3("lineColor", this.lineColor);
			
			this._activeEffect.setVector3("gridOffset", this.gridOffset);
			
			this._gridControl.x = this.gridRatio;
			this._gridControl.y = Math.round(this.majorUnitFrequency);
			this._gridControl.z = this.minorUnitVisibility;
			this._gridControl.w = this.opacity;
			this._activeEffect.setVector4("gridControl", this._gridControl);
		}
		// Fog
		MaterialHelper.BindFogParameters(scene, mesh, this._activeEffect);
		
		this._afterBind(mesh, this._activeEffect);
	}
	
	override public function dispose(forceDisposeEffect:Bool = false, forceDisposeTextures:Bool = false) {
		super.dispose(forceDisposeEffect, forceDisposeTextures);
	}
	
	override public function clone(name:String, cloneChildren:Bool = false):GridMaterial {
		return SerializationHelper.Clone(function() { return new GridMaterial(name, this.getScene()); } , this);
	}

	override public function serialize():Dynamic {
		// TODO
		/*var serializationObject = SerializationHelper.Serialize(this); 
		serializationObject.customType = "BABYLON.GridMaterial"; 
		
		return serializationObject;*/
		return null;
	}

	public static function Parse(source:Dynamic, scene:Scene, rootUrl:String):GridMaterial {
		return SerializationHelper.Parse(function() { return new GridMaterial(source.name, scene); } , source, scene, rootUrl);
	}
	
}
