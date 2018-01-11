package com.babylonhx.particles;

import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;

/**
 * ...
 * @author Krtolica Vujadin
 */
class SphereDirectedParticleEmitter extends SphereParticleEmitter {
	
	public var direction1:Vector3;
	public var direction2:Vector3;
	

	public function new(radius:Float, direction1:Vector3, direction2:Vector3) {
		super(radius);
	}

	override public function startDirectionFunction(emitPower:Float, worldMatrix:Matrix, directionToUpdate:Vector3, particle:Particle) {
		var randX = ParticleSystem.randomNumber(this.direction1.x, this.direction2.x);
		var randY = ParticleSystem.randomNumber(this.direction1.y, this.direction2.y);
		var randZ = ParticleSystem.randomNumber(this.direction1.z, this.direction2.z);
		Vector3.TransformNormalFromFloatsToRef(randX * emitPower, randY * emitPower, randZ * emitPower, worldMatrix, directionToUpdate);
	}
	
}
