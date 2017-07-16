package com.babylonhx.lights;

import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.materials.Effect;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.HemisphericLight') class HemisphericLight extends Light {
	
	@serializeAsColor3()
	public var groundColor = new Color3(0.0, 0.0, 0.0);
	
	@serializeAsVector3()
	public var direction:Vector3;

	private var _worldMatrix:Matrix;
	

	/**
	 * Creates a HemisphericLight object in the scene according to the passed direction (Vector3).  
	 * The HemisphericLight simulates the ambient environment light, so the passed direction is 
	 * the light reflection direction, not the incoming direction.  
	 * The HemisphericLight can't cast shadows.  
	 * Documentation : http://doc.babylonjs.com/tutorials/lights  
	 */
	public function new(name:String, direction:Vector3, scene:Scene) {
		super(name, scene);
		
		this.direction = direction;
	}

	override public function _buildUniformLayout() {
		this._uniformBuffer.addUniform("vLightData", 4);
		this._uniformBuffer.addUniform("vLightDiffuse", 4);
		this._uniformBuffer.addUniform("vLightSpecular", 3);
		this._uniformBuffer.addUniform("vLightGround", 3);
		this._uniformBuffer.addUniform("shadowsInfo", 3);
		this._uniformBuffer.addUniform("depthValues", 2);
		this._uniformBuffer.create();
	}

	/**
	 * Returns the string "HemisphericLight".  
	 */
	override public function getClassName():String {
		return "HemisphericLight";
	}          
	/**
	 * Sets the HemisphericLight direction towards the passed target (Vector3).  
	 * Returns the updated direction.  
	 */
	public function setDirectionToTarget(target:Vector3):Vector3 {
		this.direction = Vector3.Normalize(target.subtract(Vector3.Zero()));
		return this.direction;
	}

	override public function getShadowGenerator():ShadowGenerator {
		return null;
	}

	/**
	 * Sets the passed Effect object with the HemisphericLight normalized direction and color and the passed name (string).  
	 * Returns the HemisphericLight.  
	 */
	override public function transferToEffect(effect:Effect, lightIndex:String):Light {
		var normalizeDirection = Vector3.Normalize(this.direction);
		this._uniformBuffer.updateFloat4("vLightData",
			normalizeDirection.x,
			normalizeDirection.y,
			normalizeDirection.z,
			0.0,
			lightIndex);
		this._uniformBuffer.updateColor3("vLightGround", this.groundColor.scale(this.intensity), lightIndex);
		return this;
	}

	override public function _getWorldMatrix():Matrix {
		if (this._worldMatrix == null) {
			this._worldMatrix = Matrix.Identity();
		}
		return this._worldMatrix;
	}
	/**
	 * Returns the integer 3.  
	 */
	override public function getTypeID():Int {
		return Light.LIGHTTYPEID_HEMISPHERICLIGHT;
	}
	
}
