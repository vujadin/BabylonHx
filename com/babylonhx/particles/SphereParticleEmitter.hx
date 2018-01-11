package com.babylonhx.particles;

import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;

/**
 * ...
 * @author Krtolica Vujadin
 */
class SphereParticleEmitter implements IParticleEmitterType {
	
	public var radius:Float;
	

	public function new(radius:Float) {
		this.radius = radius;
	}
	
	public function startDirectionFunction(emitPower:Float, worldMatrix:Matrix, directionToUpdate:Vector3, particle:Particle) {
		// measure the direction Vector from the emitter to the particle.
		var direction = particle.position.subtract(worldMatrix.getTranslation());
		Vector3.TransformNormalFromFloatsToRef(direction.x * emitPower, direction.y * emitPower, direction.z * emitPower, worldMatrix, directionToUpdate);
	}

	public function startPositionFunction(worldMatrix:Matrix, positionToUpdate:Vector3, particle:Particle) {
		var phi = ParticleSystem.randomNumber(0, 2 * Math.PI);
		var theta = ParticleSystem.randomNumber(0, Math.PI);
		var randX = this.radius * Math.cos(phi) * Math.sin(theta);
		var randY = this.radius * Math.cos(theta);
		var randZ = this.radius * Math.sin(phi) * Math.sin(theta);
		Vector3.TransformCoordinatesFromFloatsToRef(randX, randY, randZ, worldMatrix, positionToUpdate);
	}
	
}
