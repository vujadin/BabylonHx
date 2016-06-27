package com.babylonhx.lights;

import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.materials.Effect;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.tools.Tags;
import com.babylonhx.animations.Animation;
import com.babylonhx.tools.serialization.SerializationHelper;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Light') class Light extends Node {
	
	@serializeAsColor3()
	public var diffuse:Color3 = new Color3(1.0, 1.0, 1.0);
	
	@serializeAsColor3()
	public var specular:Color3 = new Color3(1.0, 1.0, 1.0);
	
	@serialize()
	public var intensity:Float = 1.0;
	
	@serialize()
	public var range:Float = Math.POSITIVE_INFINITY;
	
	@serialize()
	public var includeOnlyWithLayerMask:Int = 0;
	
	public var includedOnlyMeshes:Array<AbstractMesh> = [];
	public var excludedMeshes:Array<AbstractMesh> = [];
	
	@serialize()
	public var excludeWithLayerMask:Int = 0;
	
	// PBR Properties.
	@serialize()
	public var radius:Float = 0.00001;

	public var _shadowGenerator:ShadowGenerator;
	private var _parentedWorldMatrix:Matrix;
	public var _excludedMeshesIds:Array<String> = [];
	public var _includedOnlyMeshesIds:Array<String> = [];
	
	private var _type:String;
	public var type(get, never):String;
	
	public var __serializableMembers:Dynamic;
	

	public function new(name:String, scene:Scene) {
		super(name, scene);
		
		this._type = "LIGHT";
		
		scene.addLight(this);
	}
	
	private function get_type():String {
		return this._type;
	}

	public function getShadowGenerator():ShadowGenerator {
		return this._shadowGenerator;
	}
	
	public function getAbsolutePosition():Vector3 {
		return Vector3.Zero();
	}

	public function transferToEffect(effect:Effect, ?uniformName0:String, ?uniformName1:String) {
		// to be overriden
	}

	public function _getWorldMatrix():Matrix {
		return Matrix.Identity();
	}
	
	public function getTypeID():Int {
		return 0;
	}

	inline public function canAffectMesh(mesh:AbstractMesh):Bool {
		if (mesh == null) {
			return true;
		}
		
		if (this.includedOnlyMeshes.length > 0 && this.includedOnlyMeshes.indexOf(mesh) == -1) {
			return false;
		}
		
		if (this.excludedMeshes.length > 0 && this.excludedMeshes.indexOf(mesh) != -1) {
			return false;
		}
		
		if (this.includeOnlyWithLayerMask != 0 && (this.includeOnlyWithLayerMask & mesh.layerMask) == 0){
            return false;
        }
		
		if (this.excludeWithLayerMask != 0 && (this.excludeWithLayerMask & mesh.layerMask) != 0) {
            return false;
        }
		
		return true;
	}

	override public function getWorldMatrix():Matrix {
		this._currentRenderId = this.getScene().getRenderId();
		
		var worldMatrix = this._getWorldMatrix();
		
		if (this.parent != null && this.parent.getWorldMatrix() != null) {
			if (this._parentedWorldMatrix == null) {
				this._parentedWorldMatrix = Matrix.Identity();
			}
			
			worldMatrix.multiplyToRef(this.parent.getWorldMatrix(), this._parentedWorldMatrix);
			
			this._markSyncedWithParent();
			
			return this._parentedWorldMatrix;
		}
		
		return worldMatrix;
	}

	override public function dispose(doNotRecurse:Bool = false) {
		if (this._shadowGenerator != null) {
			this._shadowGenerator.dispose();
			this._shadowGenerator = null;
		}
		
		// Animations
        this.getScene().stopAnimation(this);
		
		// Remove from scene
		this.getScene().removeLight(this);
		
		super.dispose();
	}
	
	public function clone(name:String):Light {
		return SerializationHelper.Clone(Light.GetConstructorFromName(this.getTypeID(), name, this.getScene()), this);
	}
	
	public function serialize():Dynamic {
		var serializationObject = SerializationHelper.Serialize(Light, this);
		
		// Type
		serializationObject.type = this.getTypeID();
		
		// Parent
		if (this.parent != null) {
			serializationObject.parentId = this.parent.id;
		}
		
		// Inclusion / exclusions
		if (this.excludedMeshes.length > 0) {
			serializationObject.excludedMeshesIds = [];
			for (mesh in this.excludedMeshes) {
				serializationObject.excludedMeshesIds.push(mesh.id);
			}
		}

		if (this.includedOnlyMeshes.length > 0) {
			serializationObject.includedOnlyMeshesIds = [];
			for (mesh in this.includedOnlyMeshes) {
				serializationObject.includedOnlyMeshesIds.push(mesh.id);
			}
		}
		
		// Animations  
		//Animation.AppendSerializedAnimations(this, serializationObject);
		//serializationObject.ranges = this.serializeAnimationRanges(); 
		
		return serializationObject;
	}
	
	static function GetConstructorFromName(type:Int, name:String, scene:Scene):Void->Light {
		switch (type) {
			case 0:
				return function():PointLight { return new PointLight(name, Vector3.Zero(), scene); }
				
			case 1:
				return function():DirectionalLight { return new DirectionalLight(name, Vector3.Zero(), scene); }
				
			case 2:
				return function():SpotLight { return new SpotLight(name, Vector3.Zero(), Vector3.Zero(), 0, 0, scene); }
				
			case 3:
				return function():HemisphericLight { return new HemisphericLight(name, Vector3.Zero(), scene); }
		}
		
		return null;
	}

	public static function Parse(parsedLight:Dynamic, scene:Scene):Light {
		var light = SerializationHelper.Parse(Light.GetConstructorFromName(parsedLight.type, parsedLight.name, scene), parsedLight, scene);
		
		// Inclusion / exclusions
		if (parsedLight.excludedMeshesIds != null) {
			light._excludedMeshesIds = parsedLight.excludedMeshesIds;
		}
		
		if (parsedLight.includedOnlyMeshesIds != null) {
			light._includedOnlyMeshesIds = parsedLight.includedOnlyMeshesIds;
		}
		
		// Parent
		if (parsedLight.parentId != null) {
			light._waitingParentId = parsedLight.parentId;
		}
		
		// Animations
		if (parsedLight.animations != null) {
			for (animationIndex in 0...parsedLight.animations.length) {
				var parsedAnimation = parsedLight.animations[animationIndex];
				
				light.animations.push(Animation.Parse(parsedAnimation));
			}
			Node.ParseAnimationRanges(light, parsedLight, scene);
		}
		
		if (parsedLight.autoAnimate != null && parsedLight.autoAnimate == true) {
			var aSpeed:Dynamic = parsedLight.autoAnimateSpeed;
			scene.beginAnimation(light, parsedLight.autoAnimateFrom, parsedLight.autoAnimateTo, parsedLight.autoAnimateLoop, aSpeed != null ? aSpeed : 1.0);
		}

		return light;
	}
	
}
