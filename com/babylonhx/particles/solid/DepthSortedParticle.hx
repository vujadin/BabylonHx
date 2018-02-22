package com.babylonhx.particles.solid;

/**
 * ...
 * @author Krtolica Vujadin
 */
/**
 * Represents a Depth Sorted Particle in the solid particle system.
 * @see SolidParticleSystem
 */
class DepthSortedParticle {
	
	/**
	 * Index of the particle in the "indices" array
	 */
	public var ind:Int = 0;
	/**
	 * Length of the particle shape in the "indices" array
	 */
    public var indicesLength:Int = 0;
	/**
	 * Squared distance from the particle to the camera
	 */
    public var sqDistance:Float = 0.0;
	

	public function new() { }
	
}
