package com.babylonhx.particles;

import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;

/**
 * @author Krtolica Vujadin
 */

interface IParticleEmitterType {
	
	function startDirectionFunction(emitPower:Float, worldMatrix:Matrix, directionToUpdate:Vector3, particle:Particle):Void;
    function startPositionFunction(worldMatrix:Matrix, positionToUpdate:Vector3, particle:Particle):Void;
  
}
