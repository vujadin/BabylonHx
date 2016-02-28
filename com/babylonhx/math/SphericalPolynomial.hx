package com.babylonhx.math;

/**
 * ...
 * @author Krtolica Vujadin
 */
class SphericalPolynomial {
	
	public var x:Vector3 = Vector3.Zero();
	public var y:Vector3 = Vector3.Zero();
	public var z:Vector3 = Vector3.Zero();
	public var xx:Vector3 = Vector3.Zero();
	public var yy:Vector3 = Vector3.Zero();
	public var zz:Vector3 = Vector3.Zero();
	public var xy:Vector3 = Vector3.Zero();
	public var yz:Vector3 = Vector3.Zero();
	public var zx:Vector3 = Vector3.Zero();
	

	public function new() {
		
	}
	
	public function addAmbient(color:Color3) {
		var colorVector = new Vector3(color.r, color.g, color.b);
		this.xx = this.xx.add(colorVector);
		this.yy = this.yy.add(colorVector);
		this.zz = this.zz.add(colorVector);
	}

	public static function getSphericalPolynomialFromHarmonics(harmonics:SphericalHarmonics):SphericalPolynomial {
		var result = new SphericalPolynomial();
		
		result.x = harmonics.L11.scale(1.02333);
		result.y = harmonics.L1_1.scale(1.02333);
		result.z = harmonics.L10.scale(1.02333);
		
		result.xx = harmonics.L00.scale(0.886277).subtract(harmonics.L20.scale(0.247708)).add(harmonics.L22.scale(0.429043));
		result.yy = harmonics.L00.scale(0.886277).subtract(harmonics.L20.scale(0.247708)).subtract(harmonics.L22.scale(0.429043));
		result.zz = harmonics.L00.scale(0.886277).add(harmonics.L20.scale(0.495417));
		
		result.yz = harmonics.L2_1.scale(0.858086);
		result.zx = harmonics.L21.scale(0.858086);
		result.xy = harmonics.L2_2.scale(0.858086);
		
		return result;
	}
	
}
