package com.babylonhx.particles.solid;

/**
 * ...
 * @author Krtolica Vujadin
 */
class DepthSortedParticle {
	
	public var ind:Int = 0;                      // index of the particle in the "indices" array
    public var indicesLength:Int = 0;            // length of the particle shape in the "indices" array
    public var sqDistance:Float = 0.0;           // squared distance from the particle to the camera
 

	public function new() { }
	
}
