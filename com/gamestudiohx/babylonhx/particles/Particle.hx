package com.gamestudiohx.babylonhx.particles;

import com.gamestudiohx.babylonhx.tools.math.Vector3;
import com.gamestudiohx.babylonhx.tools.math.Color4;


/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class Particle {
	
	public var lifeTime:Float = 1.0;
    public var age:Float = 0;
    public var size:Float = 0;
    public var angle:Float = 0;
    public var angularSpeed:Float = 0;
	
	public var position:Vector3;
	public var direction:Vector3;
	public var color:Color4;
	public var colorStep:Color4;

	public function new() {
		this.position = Vector3.Zero();
        this.direction = Vector3.Zero();
        this.color = new Color4(0, 0, 0, 0);
        this.colorStep = new Color4(0, 0, 0, 0);
	}
	
}
