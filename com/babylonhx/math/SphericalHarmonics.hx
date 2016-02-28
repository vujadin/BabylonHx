package com.babylonhx.math;

/**
 * ...
 * @author Krtolica Vujadin
 */
class SphericalHarmonics {
	
	public var L00:Vector3 = Vector3.Zero();
	public var L1_1:Vector3 = Vector3.Zero();
	public var L10:Vector3 = Vector3.Zero();
	public var L11:Vector3 = Vector3.Zero();
	public var L2_2:Vector3 = Vector3.Zero();
	public var L2_1:Vector3 = Vector3.Zero();
	public var L20:Vector3 = Vector3.Zero();
	public var L21:Vector3 = Vector3.Zero();
	public var L22:Vector3 = Vector3.Zero();
	

	public function new() {
		
	}
	
	public function addLight(direction:Vector3, color:Color3, deltaSolidAngle:Float) {
		var colorVector = new Vector3(color.r, color.g, color.b);
		var c = colorVector.scale(deltaSolidAngle);
		
		this.L00 = this.L00.add(c.scale(0.282095));
		
		this.L1_1 = this.L1_1.add(c.scale(0.488603 * direction.y));
		this.L10 = this.L10.add(c.scale(0.488603 * direction.z));
		this.L11 = this.L11.add(c.scale(0.488603 * direction.x));
		
		this.L2_2 = this.L2_2.add(c.scale(1.092548 * direction.x * direction.y));
		this.L2_1 = this.L2_1.add(c.scale(1.092548 * direction.y * direction.z));
		this.L21 = this.L21.add(c.scale(1.092548 * direction.x * direction.z));
		
		this.L20 = this.L20.add(c.scale(0.315392 * (3.0 * direction.z * direction.z - 1.0)));
		this.L22 = this.L22.add(c.scale(0.546274 * (direction.x * direction.x - direction.y * direction.y)));
	}

	public function scale(scale:Float) {
		this.L00 = this.L00.scale(scale);
		this.L1_1 = this.L1_1.scale(scale);
		this.L10 = this.L10.scale(scale);
		this.L11 = this.L11.scale(scale);
		this.L2_2 = this.L2_2.scale(scale);
		this.L2_1 = this.L2_1.scale(scale);
		this.L20 = this.L20.scale(scale);
		this.L21 = this.L21.scale(scale);
		this.L22 = this.L22.scale(scale);
	}
	
}
