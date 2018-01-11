package com.babylonhx.particles;

import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;

/**
 * ...
 * @author Krtolica Vujadin
 */
class BoxParticleEmitter implements IParticleEmitterType {
	
	private var _particleSystem:ParticleSystem;

	public var direction1(get, set):Vector3;
	inline function get_direction1():Vector3 {
		return this._particleSystem.direction1;
	}
	inline function set_direction1(value:Vector3):Vector3 {
		return this._particleSystem.direction1 = value;
	}

	public var direction2(get, set):Vector3;
	inline function get_direction2():Vector3 {
		return this._particleSystem.direction2;
	}
	inline function set_direction2(value:Vector3):Vector3 {
		return this._particleSystem.direction2 = value;
	}

	public var minEmitBox(get, set):Vector3;
	inline function get_minEmitBox():Vector3 {
		return this._particleSystem.minEmitBox;
	}
	inline function set_minEmitBox(value:Vector3):Vector3 {
		return this._particleSystem.minEmitBox = value;
	}

	public var maxEmitBox(get, set):Vector3;
	inline function get_maxEmitBox():Vector3 {
		return this._particleSystem.maxEmitBox;
	}
	inline function set_maxEmitBox(value:Vector3):Vector3 {
		return this._particleSystem.maxEmitBox = value;
	}
	
	// to be updated like the rest of emitters when breaking changes.
	// all property should be come public variables and passed through constructor.
	public function new(particleSystem:ParticleSystem) {
		this._particleSystem = particleSystem;
	}

	public function startDirectionFunction(emitPower:Float, worldMatrix:Matrix, directionToUpdate:Vector3, particle:Particle) {
		var randX = ParticleSystem.randomNumber(this.direction1.x, this.direction2.x);
		var randY = ParticleSystem.randomNumber(this.direction1.y, this.direction2.y);
		var randZ = ParticleSystem.randomNumber(this.direction1.z, this.direction2.z);
		
		Vector3.TransformNormalFromFloatsToRef(randX * emitPower, randY * emitPower, randZ * emitPower, worldMatrix, directionToUpdate);
	}

	public function startPositionFunction(worldMatrix:Matrix, positionToUpdate:Vector3, particle:Particle) {
		var randX = ParticleSystem.randomNumber(this.minEmitBox.x, this.maxEmitBox.x);
		var randY = ParticleSystem.randomNumber(this.minEmitBox.y, this.maxEmitBox.y);
		var randZ = ParticleSystem.randomNumber(this.minEmitBox.z, this.maxEmitBox.z);
		
		Vector3.TransformCoordinatesFromFloatsToRef(randX, randY, randZ, worldMatrix, positionToUpdate);
	}
	
}
