package com.babylonhx.math;

/**
 * ...
 * @author Krtolica Vujadin
 */

// port of https://gist.github.com/KdotJPG/f4db4491b341b8987f4a

/*
 * OpenSimplex Noise in Java.
 * by Kurt Spencer
 * 
 * Tileable 3D version, preliminary release.
 * Could probably use further optimization.
 *
 * w6, h6, and d6 are each 1/6 of the repeating period.
 * for x, y, z respectively. If w6 = 2, h6 = 2, d6 = 2,
 * then the noise repeats in blocks of (0,0,0)->(12,12,12)
 */
class OpenSimplexNoiseTileable3D {

	private static inline var STRETCH_CONSTANT_3D:Float = -1.0 / 6;              //(1/Math.sqrt(3+1)-1)/3;
	private static inline var SQUISH_CONSTANT_3D:Float = 1.0 / 3;                //(Math.sqrt(3+1)-1)/3;
	
	private static inline var NORM_CONSTANT_3D = 103;
	
	private static inline var DEFAULT_SEED:Int = 0;
	
	private var perm:Array<Int>;
	private var permGradIndex3D:Array<Int>;
	
	private var w6:Int;
	private var h6:Int;
	private var d6:Int;
	private var sOffset:Int;
	
	public function new(w6:Int, h6:Int, d6:Int) {
		this.init(DEFAULT_SEED, w6, h6, d6);
	}
	
	/*public OpenSimplexNoiseTileable3D(perm:Array<Int>, w6:Int, h6:Int, d6:Int) {
		this.perm = perm;
		permGradIndex3D = [];
		this.w6 = w6;
		this.h6 = h6;
		this.d6 = d6;
		sOffset = Std.int(Math.max(w6, Math.max(h6, d6)) * 6);
		
		for (i in 0...256) {
			//Since 3D has 24 gradients, simple bitmask won't work, so precompute modulo array.
			permGradIndex3D[i] = Std.int((perm[i] % (gradients3D.length / 3)) * 3);
		}
	}*/
	
	//Initializes the class using a permutation array generated from a 64-bit seed.
	//Generates a proper permutation (i.e. doesn't merely perform N successive pair swaps on a base array)
	//Uses a simple 64-bit LCG.
	private function init(seed:Float, w6:Int, h6:Int, d6:Int) {
		perm = [];
		permGradIndex3D = [];
		var source:Array<Int> = [];
		for (i in 0...256) {
			source[i] = i;
		}
		seed = seed * 6364136223846793005 + 1442695040888963407;
		seed = seed * 6364136223846793005 + 1442695040888963407;
		seed = seed * 6364136223846793005 + 1442695040888963407;
		
		var i:Int = 255;
		while (i >= 0) {
			seed = seed * 6364136223846793005 + 1442695040888963407;
			var r = Std.int((seed + 31) % (i + 1));
			if (r < 0) {
				r += (i + 1);
			}
			perm[i] = source[r];
			permGradIndex3D[i] = Std.int((perm[i] % (gradients3D.length / 3)) * 3);
			source[r] = source[i];
			
			--i;
		}
		this.w6 = w6;
		this.h6 = h6;
		this.d6 = d6;
		sOffset = Std.int(Math.max(w6, Math.max(h6, d6)) * 6);
	}
	
	//3D OpenSimplex Noise.
	public function eval(x:Float, y:Float, z:Float):Float {	
		//Place input coordinates on simplectic honeycomb.
		var stretchOffset:Float = (x + y + z) * STRETCH_CONSTANT_3D;
		var xs:Float = x + stretchOffset;
		var ys:Float = y + stretchOffset;
		var zs:Float = z + stretchOffset;
		
		//Floor to get simplectic honeycomb coordinates of rhombohedron (stretched cube) super-cell origin.
		var xsb = fastFloor(xs);
		var ysb = fastFloor(ys);
		var zsb = fastFloor(zs);
		
		//Skew out to get actual coordinates of rhombohedron origin. We'll need these later.
		var squishOffset:Float = (xsb + ysb + zsb) * SQUISH_CONSTANT_3D;
		var xb:Float = xsb + squishOffset;
		var yb:Float = ysb + squishOffset;
		var zb:Float = zsb + squishOffset;
		
		//Compute simplectic honeycomb coordinates relative to rhombohedral origin.
		var xins:Float = xs - xsb;
		var yins:Float = ys - ysb;
		var zins:Float = zs - zsb;
		
		//Sum those together to get a value that determines which region we're in.
		var inSum:Float = xins + yins + zins;
		
		//Positions relative to origin point.
		var dx0:Float = x - xb;
		var dy0:Float = y - yb;
		var dz0:Float = z - zb;
		
		//From here on out, these can't be negative.
		xsb += sOffset;
		ysb += sOffset;
		zsb += sOffset;
		
		//We'll be defining these inside the next block and using them afterwards.
		var dx_ext0:Float = 0;
		var dy_ext0:Float = 0;
		var dz_ext0:Float = 0;
		var dx_ext1:Float = 0;
		var dy_ext1:Float = 0;
		var dz_ext1:Float = 0;
		var xsv_ext0:Int = 0;
		var ysv_ext0:Int = 0;
		var zsv_ext0:Int = 0;
		var xsv_ext1:Int = 0;
		var ysv_ext1:Int = 0;
		var zsv_ext1:Int = 0;
		
		var value:Float = 0;
		if (inSum <= 1) { //We're inside the tetrahedron (3-Simplex) at (0,0,0)			
			//Determine which two of (0,0,1), (0,1,0), (1,0,0) are closest.
			var aPoint:Int = 0x01;
			var aScore:Float = xins;
			var bPoint:Int = 0x02;
			var bScore:Float = yins;
			if (aScore >= bScore && zins > bScore) {
				bScore = zins;
				bPoint = 0x04;
			} 
			else if (aScore < bScore && zins > aScore) {
				aScore = zins;
				aPoint = 0x04;
			}
			
			//Now we determine the two lattice points not part of the tetrahedron that may contribute.
			//This depends on the closest two tetrahedral vertices, including (0,0,0)
			var wins = 1 - inSum;
			if (wins > aScore || wins > bScore) { //(0,0,0) is one of the closest two tetrahedral vertices.
				var c = (bScore > aScore ? bPoint : aPoint); //Our other closest vertex is the closest out of a and b.
				
				if ((c & 0x01) == 0) {
					xsv_ext0 = xsb - 1;
					xsv_ext1 = xsb;
					dx_ext0 = dx0 + 1;
					dx_ext1 = dx0;
				} 
				else {
					xsv_ext0 = xsv_ext1 = xsb + 1;
					dx_ext0 = dx_ext1 = dx0 - 1;
				}
				
				if ((c & 0x02) == 0) {
					ysv_ext0 = ysv_ext1 = ysb;
					dy_ext0 = dy_ext1 = dy0;
					if ((c & 0x01) == 0) {
						ysv_ext1 -= 1;
						dy_ext1 += 1;
					} 
					else {
						ysv_ext0 -= 1;
						dy_ext0 += 1;
					}
				} else {
					ysv_ext0 = ysv_ext1 = ysb + 1;
					dy_ext0 = dy_ext1 = dy0 - 1;
				}
				
				if ((c & 0x04) == 0) {
					zsv_ext0 = zsb;
					zsv_ext1 = zsb - 1;
					dz_ext0 = dz0;
					dz_ext1 = dz0 + 1;
				} 
				else {
					zsv_ext0 = zsv_ext1 = zsb + 1;
					dz_ext0 = dz_ext1 = dz0 - 1;
				}
			} 
			else { //(0,0,0) is not one of the closest two tetrahedral vertices.
				var c = (aPoint | bPoint); //Our two extra vertices are determined by the closest two.
				
				if ((c & 0x01) == 0) {
					xsv_ext0 = xsb;
					xsv_ext1 = xsb - 1;
					dx_ext0 = dx0 - 2 * SQUISH_CONSTANT_3D;
					dx_ext1 = dx0 + 1 - SQUISH_CONSTANT_3D;
				} 
				else {
					xsv_ext0 = xsv_ext1 = xsb + 1;
					dx_ext0 = dx0 - 1 - 2 * SQUISH_CONSTANT_3D;
					dx_ext1 = dx0 - 1 - SQUISH_CONSTANT_3D;
				}
				
				if ((c & 0x02) == 0) {
					ysv_ext0 = ysb;
					ysv_ext1 = ysb - 1;
					dy_ext0 = dy0 - 2 * SQUISH_CONSTANT_3D;
					dy_ext1 = dy0 + 1 - SQUISH_CONSTANT_3D;
				} 
				else {
					ysv_ext0 = ysv_ext1 = ysb + 1;
					dy_ext0 = dy0 - 1 - 2 * SQUISH_CONSTANT_3D;
					dy_ext1 = dy0 - 1 - SQUISH_CONSTANT_3D;
				}
				
				if ((c & 0x04) == 0) {
					zsv_ext0 = zsb;
					zsv_ext1 = zsb - 1;
					dz_ext0 = dz0 - 2 * SQUISH_CONSTANT_3D;
					dz_ext1 = dz0 + 1 - SQUISH_CONSTANT_3D;
				} 
				else {
					zsv_ext0 = zsv_ext1 = zsb + 1;
					dz_ext0 = dz0 - 1 - 2 * SQUISH_CONSTANT_3D;
					dz_ext1 = dz0 - 1 - SQUISH_CONSTANT_3D;
				}
			}
			
			//Contribution (0,0,0)
			var attn0 = 2 - dx0 * dx0 - dy0 * dy0 - dz0 * dz0;
			if (attn0 > 0) {
				attn0 *= attn0;
				value += attn0 * attn0 * extrapolate(xsb + 0, ysb + 0, zsb + 0, dx0, dy0, dz0);
			}
			
			//Contribution (1,0,0)
			var dx1 = dx0 - 1 - SQUISH_CONSTANT_3D;
			var dy1 = dy0 - 0 - SQUISH_CONSTANT_3D;
			var dz1 = dz0 - 0 - SQUISH_CONSTANT_3D;
			var attn1 = 2 - dx1 * dx1 - dy1 * dy1 - dz1 * dz1;
			if (attn1 > 0) {
				attn1 *= attn1;
				value += attn1 * attn1 * extrapolate(xsb + 1, ysb + 0, zsb + 0, dx1, dy1, dz1);
			}
			
			//Contribution (0,1,0)
			var dx2 = dx0 - 0 - SQUISH_CONSTANT_3D;
			var dy2 = dy0 - 1 - SQUISH_CONSTANT_3D;
			var dz2 = dz1;
			var attn2 = 2 - dx2 * dx2 - dy2 * dy2 - dz2 * dz2;
			if (attn2 > 0) {
				attn2 *= attn2;
				value += attn2 * attn2 * extrapolate(xsb + 0, ysb + 1, zsb + 0, dx2, dy2, dz2);
			}
			
			//Contribution (0,0,1)
			var dx3 = dx2;
			var dy3 = dy1;
			var dz3 = dz0 - 1 - SQUISH_CONSTANT_3D;
			var attn3 = 2 - dx3 * dx3 - dy3 * dy3 - dz3 * dz3;
			if (attn3 > 0) {
				attn3 *= attn3;
				value += attn3 * attn3 * extrapolate(xsb + 0, ysb + 0, zsb + 1, dx3, dy3, dz3);
			}
		} 
		else if (inSum >= 2) { //We're inside the tetrahedron (3-Simplex) at (1,1,1)		
			//Determine which two tetrahedral vertices are the closest, out of (1,1,0), (1,0,1), (0,1,1) but not (1,1,1).
			var aPoint:Int = 0x06;
			var aScore:Float = xins;
			var bPoint:Int = 0x05;
			var bScore:Float = yins;
			if (aScore <= bScore && zins < bScore) {
				bScore = zins;
				bPoint = 0x03;
			} 
			else if (aScore > bScore && zins < aScore) {
				aScore = zins;
				aPoint = 0x03;
			}
			
			//Now we determine the two lattice points not part of the tetrahedron that may contribute.
			//This depends on the closest two tetrahedral vertices, including (1,1,1)
			var wins = 3 - inSum;
			if (wins < aScore || wins < bScore) { //(1,1,1) is one of the closest two tetrahedral vertices.
				var c = (bScore < aScore ? bPoint : aPoint); //Our other closest vertex is the closest out of a and b.
				
				if ((c & 0x01) != 0) {
					xsv_ext0 = xsb + 2;
					xsv_ext1 = xsb + 1;
					dx_ext0 = dx0 - 2 - 3 * SQUISH_CONSTANT_3D;
					dx_ext1 = dx0 - 1 - 3 * SQUISH_CONSTANT_3D;
				} 
				else {
					xsv_ext0 = xsv_ext1 = xsb;
					dx_ext0 = dx_ext1 = dx0 - 3 * SQUISH_CONSTANT_3D;
				}
				
				if ((c & 0x02) != 0) {
					ysv_ext0 = ysv_ext1 = ysb + 1;
					dy_ext0 = dy_ext1 = dy0 - 1 - 3 * SQUISH_CONSTANT_3D;
					if ((c & 0x01) != 0) {
						ysv_ext1 += 1;
						dy_ext1 -= 1;
					} 
					else {
						ysv_ext0 += 1;
						dy_ext0 -= 1;
					}
				} 
				else {
					ysv_ext0 = ysv_ext1 = ysb;
					dy_ext0 = dy_ext1 = dy0 - 3 * SQUISH_CONSTANT_3D;
				}
				
				if ((c & 0x04) != 0) {
					zsv_ext0 = zsb + 1;
					zsv_ext1 = zsb + 2;
					dz_ext0 = dz0 - 1 - 3 * SQUISH_CONSTANT_3D;
					dz_ext1 = dz0 - 2 - 3 * SQUISH_CONSTANT_3D;
				} 
				else {
					zsv_ext0 = zsv_ext1 = zsb;
					dz_ext0 = dz_ext1 = dz0 - 3 * SQUISH_CONSTANT_3D;
				}
			} 
			else { //(1,1,1) is not one of the closest two tetrahedral vertices.
				var c = (aPoint & bPoint); //Our two extra vertices are determined by the closest two.
				
				if ((c & 0x01) != 0) {
					xsv_ext0 = xsb + 1;
					xsv_ext1 = xsb + 2;
					dx_ext0 = dx0 - 1 - SQUISH_CONSTANT_3D;
					dx_ext1 = dx0 - 2 - 2 * SQUISH_CONSTANT_3D;
				} 
				else {
					xsv_ext0 = xsv_ext1 = xsb;
					dx_ext0 = dx0 - SQUISH_CONSTANT_3D;
					dx_ext1 = dx0 - 2 * SQUISH_CONSTANT_3D;
				}
				
				if ((c & 0x02) != 0) {
					ysv_ext0 = ysb + 1;
					ysv_ext1 = ysb + 2;
					dy_ext0 = dy0 - 1 - SQUISH_CONSTANT_3D;
					dy_ext1 = dy0 - 2 - 2 * SQUISH_CONSTANT_3D;
				} 
				else {
					ysv_ext0 = ysv_ext1 = ysb;
					dy_ext0 = dy0 - SQUISH_CONSTANT_3D;
					dy_ext1 = dy0 - 2 * SQUISH_CONSTANT_3D;
				}
				
				if ((c & 0x04) != 0) {
					zsv_ext0 = zsb + 1;
					zsv_ext1 = zsb + 2;
					dz_ext0 = dz0 - 1 - SQUISH_CONSTANT_3D;
					dz_ext1 = dz0 - 2 - 2 * SQUISH_CONSTANT_3D;
				} 
				else {
					zsv_ext0 = zsv_ext1 = zsb;
					dz_ext0 = dz0 - SQUISH_CONSTANT_3D;
					dz_ext1 = dz0 - 2 * SQUISH_CONSTANT_3D;
				}
			}
			
			//Contribution (1,1,0)
			var dx3 = dx0 - 1 - 2 * SQUISH_CONSTANT_3D;
			var dy3 = dy0 - 1 - 2 * SQUISH_CONSTANT_3D;
			var dz3 = dz0 - 0 - 2 * SQUISH_CONSTANT_3D;
			var attn3 = 2 - dx3 * dx3 - dy3 * dy3 - dz3 * dz3;
			if (attn3 > 0) {
				attn3 *= attn3;
				value += attn3 * attn3 * extrapolate(xsb + 1, ysb + 1, zsb + 0, dx3, dy3, dz3);
			}
			
			//Contribution (1,0,1)
			var dx2 = dx3;
			var dy2 = dy0 - 0 - 2 * SQUISH_CONSTANT_3D;
			var dz2 = dz0 - 1 - 2 * SQUISH_CONSTANT_3D;
			var attn2 = 2 - dx2 * dx2 - dy2 * dy2 - dz2 * dz2;
			if (attn2 > 0) {
				attn2 *= attn2;
				value += attn2 * attn2 * extrapolate(xsb + 1, ysb + 0, zsb + 1, dx2, dy2, dz2);
			}
			
			//Contribution (0,1,1)
			var dx1 = dx0 - 0 - 2 * SQUISH_CONSTANT_3D;
			var dy1 = dy3;
			var dz1 = dz2;
			var attn1 = 2 - dx1 * dx1 - dy1 * dy1 - dz1 * dz1;
			if (attn1 > 0) {
				attn1 *= attn1;
				value += attn1 * attn1 * extrapolate(xsb + 0, ysb + 1, zsb + 1, dx1, dy1, dz1);
			}
			
			//Contribution (1,1,1)
			dx0 = dx0 - 1 - 3 * SQUISH_CONSTANT_3D;
			dy0 = dy0 - 1 - 3 * SQUISH_CONSTANT_3D;
			dz0 = dz0 - 1 - 3 * SQUISH_CONSTANT_3D;
			var attn0 = 2 - dx0 * dx0 - dy0 * dy0 - dz0 * dz0;
			if (attn0 > 0) {
				attn0 *= attn0;
				value += attn0 * attn0 * extrapolate(xsb + 1, ysb + 1, zsb + 1, dx0, dy0, dz0);
			}
		} 
		else { //We're inside the octahedron (Rectified 3-Simplex) in between.
			var aScore:Float = 0;
			var aPoint:Int = 0;
			var aIsFurtherSide:Bool = false;
			var bScore:Float = 0;
			var bPoint:Int = 0;
			var bIsFurtherSide:Bool = false;
			
			//Decide between point (0,0,1) and (1,1,0) as closest
			var p1 = xins + yins;
			if (p1 > 1) {
				aScore = p1 - 1;
				aPoint = 0x03;
				aIsFurtherSide = true;
			} 
			else {
				aScore = 1 - p1;
				aPoint = 0x04;
				aIsFurtherSide = false;
			}
			
			//Decide between point (0,1,0) and (1,0,1) as closest
			var p2 = xins + zins;
			if (p2 > 1) {
				bScore = p2 - 1;
				bPoint = 0x05;
				bIsFurtherSide = true;
			} 
			else {
				bScore = 1 - p2;
				bPoint = 0x02;
				bIsFurtherSide = false;
			}
			
			//The closest out of the two (1,0,0) and (0,1,1) will replace the furthest out of the two decided above, if closer.
			var p3 = yins + zins;
			if (p3 > 1) {
				var score = p3 - 1;
				if (aScore <= bScore && aScore < score) {
					aScore = score;
					aPoint = 0x06;
					aIsFurtherSide = true;
				} 
				else if (aScore > bScore && bScore < score) {
					bScore = score;
					bPoint = 0x06;
					bIsFurtherSide = true;
				}
			} 
			else {
				var score = 1 - p3;
				if (aScore <= bScore && aScore < score) {
					aScore = score;
					aPoint = 0x01;
					aIsFurtherSide = false;
				} 
				else if (aScore > bScore && bScore < score) {
					bScore = score;
					bPoint = 0x01;
					bIsFurtherSide = false;
				}
			}
			
			//Where each of the two closest points are determines how the extra two vertices are calculated.
			if (aIsFurtherSide == bIsFurtherSide) {
				if (aIsFurtherSide) { //Both closest points on (1,1,1) side
					//One of the two extra points is (1,1,1)
					dx_ext0 = dx0 - 1 - 3 * SQUISH_CONSTANT_3D;
					dy_ext0 = dy0 - 1 - 3 * SQUISH_CONSTANT_3D;
					dz_ext0 = dz0 - 1 - 3 * SQUISH_CONSTANT_3D;
					xsv_ext0 = xsb + 1;
					ysv_ext0 = ysb + 1;
					zsv_ext0 = zsb + 1;
					
					//Other extra point is based on the shared axis.
					var c = (aPoint & bPoint);
					if ((c & 0x01) != 0) {
						dx_ext1 = dx0 - 2 - 2 * SQUISH_CONSTANT_3D;
						dy_ext1 = dy0 - 2 * SQUISH_CONSTANT_3D;
						dz_ext1 = dz0 - 2 * SQUISH_CONSTANT_3D;
						xsv_ext1 = xsb + 2;
						ysv_ext1 = ysb;
						zsv_ext1 = zsb;
					} 
					else if ((c & 0x02) != 0) {
						dx_ext1 = dx0 - 2 * SQUISH_CONSTANT_3D;
						dy_ext1 = dy0 - 2 - 2 * SQUISH_CONSTANT_3D;
						dz_ext1 = dz0 - 2 * SQUISH_CONSTANT_3D;
						xsv_ext1 = xsb;
						ysv_ext1 = ysb + 2;
						zsv_ext1 = zsb;
					} 
					else {
						dx_ext1 = dx0 - 2 * SQUISH_CONSTANT_3D;
						dy_ext1 = dy0 - 2 * SQUISH_CONSTANT_3D;
						dz_ext1 = dz0 - 2 - 2 * SQUISH_CONSTANT_3D;
						xsv_ext1 = xsb;
						ysv_ext1 = ysb;
						zsv_ext1 = zsb + 2;
					}
				} 
				else {//Both closest points on (0,0,0) side
					//One of the two extra points is (0,0,0)
					dx_ext0 = dx0;
					dy_ext0 = dy0;
					dz_ext0 = dz0;
					xsv_ext0 = xsb;
					ysv_ext0 = ysb;
					zsv_ext0 = zsb;
					
					//Other extra point is based on the omitted axis.
					var c = (aPoint | bPoint);
					if ((c & 0x01) == 0) {
						dx_ext1 = dx0 + 1 - SQUISH_CONSTANT_3D;
						dy_ext1 = dy0 - 1 - SQUISH_CONSTANT_3D;
						dz_ext1 = dz0 - 1 - SQUISH_CONSTANT_3D;
						xsv_ext1 = xsb - 1;
						ysv_ext1 = ysb + 1;
						zsv_ext1 = zsb + 1;
					} 
					else if ((c & 0x02) == 0) {
						dx_ext1 = dx0 - 1 - SQUISH_CONSTANT_3D;
						dy_ext1 = dy0 + 1 - SQUISH_CONSTANT_3D;
						dz_ext1 = dz0 - 1 - SQUISH_CONSTANT_3D;
						xsv_ext1 = xsb + 1;
						ysv_ext1 = ysb - 1;
						zsv_ext1 = zsb + 1;
					} 
					else {
						dx_ext1 = dx0 - 1 - SQUISH_CONSTANT_3D;
						dy_ext1 = dy0 - 1 - SQUISH_CONSTANT_3D;
						dz_ext1 = dz0 + 1 - SQUISH_CONSTANT_3D;
						xsv_ext1 = xsb + 1;
						ysv_ext1 = ysb + 1;
						zsv_ext1 = zsb - 1;
					}
				}
			} 
			else { //One point on (0,0,0) side, one point on (1,1,1) side
				var c1:Int = 0;
				var c2:Int = 0;
				if (aIsFurtherSide) {
					c1 = aPoint;
					c2 = bPoint;
				} 
				else {
					c1 = bPoint;
					c2 = aPoint;
				}
				
				//One contribution is a permutation of (1,1,-1)
				if ((c1 & 0x01) == 0) {
					dx_ext0 = dx0 + 1 - SQUISH_CONSTANT_3D;
					dy_ext0 = dy0 - 1 - SQUISH_CONSTANT_3D;
					dz_ext0 = dz0 - 1 - SQUISH_CONSTANT_3D;
					xsv_ext0 = xsb - 1;
					ysv_ext0 = ysb + 1;
					zsv_ext0 = zsb + 1;
				} 
				else if ((c1 & 0x02) == 0) {
					dx_ext0 = dx0 - 1 - SQUISH_CONSTANT_3D;
					dy_ext0 = dy0 + 1 - SQUISH_CONSTANT_3D;
					dz_ext0 = dz0 - 1 - SQUISH_CONSTANT_3D;
					xsv_ext0 = xsb + 1;
					ysv_ext0 = ysb - 1;
					zsv_ext0 = zsb + 1;
				} 
				else {
					dx_ext0 = dx0 - 1 - SQUISH_CONSTANT_3D;
					dy_ext0 = dy0 - 1 - SQUISH_CONSTANT_3D;
					dz_ext0 = dz0 + 1 - SQUISH_CONSTANT_3D;
					xsv_ext0 = xsb + 1;
					ysv_ext0 = ysb + 1;
					zsv_ext0 = zsb - 1;
				}
				
				//One contribution is a permutation of (0,0,2)
				dx_ext1 = dx0 - 2 * SQUISH_CONSTANT_3D;
				dy_ext1 = dy0 - 2 * SQUISH_CONSTANT_3D;
				dz_ext1 = dz0 - 2 * SQUISH_CONSTANT_3D;
				xsv_ext1 = xsb;
				ysv_ext1 = ysb;
				zsv_ext1 = zsb;
				if ((c2 & 0x01) != 0) {
					dx_ext1 -= 2;
					xsv_ext1 += 2;
				} 
				else if ((c2 & 0x02) != 0) {
					dy_ext1 -= 2;
					ysv_ext1 += 2;
				} 
				else {
					dz_ext1 -= 2;
					zsv_ext1 += 2;
				}
			}
			
			//Contribution (1,0,0)
			var dx1 = dx0 - 1 - SQUISH_CONSTANT_3D;
			var dy1 = dy0 - 0 - SQUISH_CONSTANT_3D;
			var dz1 = dz0 - 0 - SQUISH_CONSTANT_3D;
			var attn1 = 2 - dx1 * dx1 - dy1 * dy1 - dz1 * dz1;
			if (attn1 > 0) {
				attn1 *= attn1;
				value += attn1 * attn1 * extrapolate(xsb + 1, ysb + 0, zsb + 0, dx1, dy1, dz1);
			}
			
			//Contribution (0,1,0)
			var dx2 = dx0 - 0 - SQUISH_CONSTANT_3D;
			var dy2 = dy0 - 1 - SQUISH_CONSTANT_3D;
			var dz2 = dz1;
			var attn2 = 2 - dx2 * dx2 - dy2 * dy2 - dz2 * dz2;
			if (attn2 > 0) {
				attn2 *= attn2;
				value += attn2 * attn2 * extrapolate(xsb + 0, ysb + 1, zsb + 0, dx2, dy2, dz2);
			}
			
			//Contribution (0,0,1)
			var dx3 = dx2;
			var dy3 = dy1;
			var dz3 = dz0 - 1 - SQUISH_CONSTANT_3D;
			var attn3 = 2 - dx3 * dx3 - dy3 * dy3 - dz3 * dz3;
			if (attn3 > 0) {
				attn3 *= attn3;
				value += attn3 * attn3 * extrapolate(xsb + 0, ysb + 0, zsb + 1, dx3, dy3, dz3);
			}
			
			//Contribution (1,1,0)
			var dx4 = dx0 - 1 - 2 * SQUISH_CONSTANT_3D;
			var dy4 = dy0 - 1 - 2 * SQUISH_CONSTANT_3D;
			var dz4 = dz0 - 0 - 2 * SQUISH_CONSTANT_3D;
			var attn4 = 2 - dx4 * dx4 - dy4 * dy4 - dz4 * dz4;
			if (attn4 > 0) {
				attn4 *= attn4;
				value += attn4 * attn4 * extrapolate(xsb + 1, ysb + 1, zsb + 0, dx4, dy4, dz4);
			}
			
			//Contribution (1,0,1)
			var dx5 = dx4;
			var dy5 = dy0 - 0 - 2 * SQUISH_CONSTANT_3D;
			var dz5 = dz0 - 1 - 2 * SQUISH_CONSTANT_3D;
			var attn5 = 2 - dx5 * dx5 - dy5 * dy5 - dz5 * dz5;
			if (attn5 > 0) {
				attn5 *= attn5;
				value += attn5 * attn5 * extrapolate(xsb + 1, ysb + 0, zsb + 1, dx5, dy5, dz5);
			}
			
			//Contribution (0,1,1)
			var dx6 = dx0 - 0 - 2 * SQUISH_CONSTANT_3D;
			var dy6 = dy4;
			var dz6 = dz5;
			var attn6 = 2 - dx6 * dx6 - dy6 * dy6 - dz6 * dz6;
			if (attn6 > 0) {
				attn6 *= attn6;
				value += attn6 * attn6 * extrapolate(xsb + 0, ysb + 1, zsb + 1, dx6, dy6, dz6);
			}
		}
		 
		//First extra vertex
		var attn_ext0 = 2 - dx_ext0 * dx_ext0 - dy_ext0 * dy_ext0 - dz_ext0 * dz_ext0;
		if (attn_ext0 > 0) {
			attn_ext0 *= attn_ext0;
			value += attn_ext0 * attn_ext0 * extrapolate(xsv_ext0, ysv_ext0, zsv_ext0, dx_ext0, dy_ext0, dz_ext0);
		}
		
		//Second extra vertex
		var attn_ext1 = 2 - dx_ext1 * dx_ext1 - dy_ext1 * dy_ext1 - dz_ext1 * dz_ext1;
		if (attn_ext1 > 0) {
			attn_ext1 *= attn_ext1;
			value += attn_ext1 * attn_ext1 * extrapolate(xsv_ext1, ysv_ext1, zsv_ext1, dx_ext1, dy_ext1, dz_ext1);
		}
		
		return value / NORM_CONSTANT_3D;
	}
	
	private function extrapolate(xsb:Int, ysb:Int, zsb:Int, dx:Float, dy:Float, dz:Float):Float {
		var bSum = xsb + ysb + zsb;
		var xc = Std.int((3 * xsb + bSum) / 18 / w6);
		var yc = Std.int((3 * ysb + bSum) / 18 / h6);
		var zc = Std.int((3 * zsb + bSum) / 18 / d6);
		
		var xsbm = Std.int((-5 * w6 * xc) + (h6 * yc) + (d6 * zc) + xsb);
		var ysbm = Std.int((w6 * xc) + (-5 * h6 * yc) + (d6 * zc) + ysb);
		var zsbm = Std.int((w6 * xc) + (h6 * yc) + (-5 * d6 * zc) + zsb);
		
		var index = permGradIndex3D[(perm[(perm[xsbm & 0xFF] + ysbm) & 0xFF] + zsbm) & 0xFF];
		return gradients3D[index] * dx
			+ gradients3D[index + 1] * dy
			+ gradients3D[index + 2] * dz;
	}
	
	private static inline function fastFloor(x:Float):Int {
		var xi:Int = Std.int(x);
		return x < xi ? xi - 1 : xi;
	}
	
	//Gradients for 3D. They approximate the directions to the
	//vertices of a rhombicuboctahedron from the center, skewed so
	//that the triangular and square facets can be inscribed inside
	//circles of the same radius.
	private static var gradients3D:Array<Int> = [
		-11,  4,  4,     -4,  11,  4,    -4,  4,  11,
		 11,  4,  4,      4,  11,  4,     4,  4,  11,
		-11, -4,  4,     -4, -11,  4,    -4, -4,  11,
		 11, -4,  4,      4, -11,  4,     4, -4,  11,
		-11,  4, -4,     -4,  11, -4,    -4,  4, -11,
		 11,  4, -4,      4,  11, -4,     4,  4, -11,
		-11, -4, -4,     -4, -11, -4,    -4, -4, -11,
		 11, -4, -4,      4, -11, -4,     4, -4, -11,
	];
	
}
