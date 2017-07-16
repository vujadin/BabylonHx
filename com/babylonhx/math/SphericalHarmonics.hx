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
	
	public function convertIncidentRadianceToIrradiance() {
		// Convert from incident radiance (Li) to irradiance (E) by applying convolution with the cosine-weighted hemisphere.
		//
		//      E_lm = A_l * L_lm
		// 
		// In spherical harmonics this convolution amounts to scaling factors for each frequency band.
		// This corresponds to equation 5 in "An Efficient Representation for Irradiance Environment Maps", where
		// the scaling factors are given in equation 9.
		
		// Constant (Band 0)
		this.L00 = this.L00.scale(3.141593);
		
		// Linear (Band 1)
		this.L1_1 = this.L1_1.scale(2.094395);
		this.L10 = this.L10.scale(2.094395);
		this.L11 = this.L11.scale(2.094395);
		
		// Quadratic (Band 2)
		this.L2_2 = this.L2_2.scale(0.785398);
		this.L2_1 = this.L2_1.scale(0.785398);
		this.L20 = this.L20.scale(0.785398);
		this.L21 = this.L21.scale(0.785398);
		this.L22 = this.L22.scale(0.785398);
	}

	public function convertIrradianceToLambertianRadiance() {
		// Convert from irradiance to outgoing radiance for Lambertian BDRF, suitable for efficient shader evaluation.
		//      L = (1/pi) * E * rho
		// 
		// This is done by an additional scale by 1/pi, so is a fairly trivial operation but important conceptually.
		
		this.scale(1.0 / Math.PI);
		
		// The resultant SH now represents outgoing radiance, so includes the Lambert 1/pi normalisation factor but without albedo (rho) applied
		// (The pixel shader must apply albedo after texture fetches, etc).
	}

	public static function getsphericalHarmonicsFromPolynomial(polynomial:SphericalPolynomial):SphericalHarmonics {
		var result = new SphericalHarmonics();
		
		result.L00 = polynomial.xx.scale(0.376127).add(polynomial.yy.scale(0.376127)).add(polynomial.zz.scale(0.376126));
		result.L1_1 = polynomial.y.scale(0.977204);
		result.L10 = polynomial.z.scale(0.977204);
		result.L11 = polynomial.x.scale(0.977204);
		result.L2_2 = polynomial.xy.scale(1.16538);
		result.L2_1 = polynomial.yz.scale(1.16538);
		result.L20 = polynomial.zz.scale(1.34567).subtract(polynomial.xx.scale(0.672834)).subtract(polynomial.yy.scale(0.672834));
		result.L21 = polynomial.zx.scale(1.16538);
		result.L22 = polynomial.xx.scale(1.16538).subtract(polynomial.yy.scale(1.16538));
		
		result.scale(Math.PI);
		
		return result;
	}
	
}
