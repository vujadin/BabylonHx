package com.babylonhx.particles;

import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;

/**
 * ...
 * @author Krtolica Vujadin
 */
class ConeParticleEmitter implements IParticleEmitterType {
	
	public var radius:Float;
	public var angle:Float;
	

	public function new(radius:Float, angle:Float) {
		this.radius = radius;
    }
 
    public function startDirectionFunction(emitPower:Float, worldMatrix:Matrix, directionToUpdate:Vector3, particle:Particle) {
        if (this.angle == 0) {
            Vector3.TransformNormalFromFloatsToRef(0, emitPower, 0, worldMatrix, directionToUpdate);
        }
        else {
            var phi = ParticleSystem.randomNumber(0, 2 * Math.PI);
            var theta = ParticleSystem.randomNumber(0, this.angle);
            var randX = Math.cos(phi) * Math.sin(theta);
            var randY = Math.cos(theta);
            var randZ = Math.sin(phi) * Math.sin(theta);
            Vector3.TransformNormalFromFloatsToRef(randX * emitPower, randY * emitPower, randZ * emitPower, worldMatrix, directionToUpdate);
        }
    }

    public function startPositionFunction(worldMatrix:Matrix, positionToUpdate:Vector3, particle:Particle) {
        var s = ParticleSystem.randomNumber(0, Math.PI * 2);
        var radius = ParticleSystem.randomNumber(0, this.radius);
        var randX = radius * Math.sin(s);
        var randZ = radius * Math.cos(s);
		
        Vector3.TransformCoordinatesFromFloatsToRef(randX, 0, randZ, worldMatrix, positionToUpdate);
    }
	
}
