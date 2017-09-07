package com.babylonhx.tools.hdr;

import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color3;
import com.babylonhx.math.SphericalPolynomial;
import com.babylonhx.math.SphericalHarmonics;
import com.babylonhx.tools.hdr.PanoramaToCubeMapTools.CubeMapInfo;

import lime.utils.Float32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
class CubeMapToSphericalPolynomialTools {
	
	private static var FileFaces:Array<FileFaceOrientation> = [
		new FileFaceOrientation("right", new Vector3(1, 0, 0), new Vector3(0, 0, -1), new Vector3(0, -1, 0)), // +X east
		new FileFaceOrientation("left", new Vector3(-1, 0, 0), new Vector3(0, 0, 1), new Vector3(0, -1, 0)), // -X west
		new FileFaceOrientation("up", new Vector3(0, 1, 0), new Vector3(1, 0, 0), new Vector3(0, 0, 1)), // +Y north
		new FileFaceOrientation("down", new Vector3(0, -1, 0), new Vector3(1, 0, 0), new Vector3(0, 0, -1)), // -Y south
		new FileFaceOrientation("front", new Vector3(0, 0, 1), new Vector3(1, 0, 0), new Vector3(0, -1, 0)), // +Z top
		new FileFaceOrientation("back", new Vector3(0, 0, -1), new Vector3(-1, 0, 0), new Vector3(0, -1, 0))// -Z bottom
	];
	
	/**
	 * Converts a texture to the according Spherical Polynomial data. 
	 * This extracts the first 3 orders only as they are the only one used in the lighting.
	 * 
	 * @param texture The texture to extract the information from.
	 * @return The Spherical Polynomial data.
	 */
	public static function ConvertCubeMapTextureToSphericalPolynomial(texture:BaseTexture):SphericalPolynomial {
		if (!texture.isCube) {
			// Only supports cube Textures currently.
			return null;
		}
		
		var size:Int = texture.getSize().width;
		var right:Float32Array = cast texture.readPixels(0);
		var left:Float32Array = cast texture.readPixels(1);
		
		var up:Float32Array = null;
		var down:Float32Array = null;
		if (texture.isRenderTarget) {
			up = cast texture.readPixels(3);
			down = cast texture.readPixels(2);
		}
		else {
			up = cast texture.readPixels(2);
			down = cast texture.readPixels(3);
		}
		
		var front:Float32Array = cast texture.readPixels(4);
		var back:Float32Array = cast texture.readPixels(5);
		
		var gammaSpace = texture.gammaSpace;
		// Always read as RGBA.
		var format = Engine.TEXTUREFORMAT_RGBA;
		var type = Engine.TEXTURETYPE_UNSIGNED_INT;
		if (texture.textureType != Engine.TEXTURETYPE_UNSIGNED_INT) {
			type = Engine.TEXTURETYPE_FLOAT;
		}
		
		var cubeInfo:CubeMapInfo = {
			size: size,
			right: right,
			left: left,
			up: up,
			down: down,
			front: front,
			back: back,
			format: format,
			type: type,
			gammaSpace: gammaSpace
		};
		
		return ConvertCubeMapToSphericalPolynomial(cubeInfo);
	}
	
	public static function ConvertCubeMapToSphericalPolynomial(cubeInfo:CubeMapInfo):SphericalPolynomial {
		var sphericalHarmonics = new SphericalHarmonics();
		var totalSolidAngle = 0.0;
		
		// The (u,v) range is [-1,+1], so the distance between each texel is 2/Size.
		var du = 2.0 / cubeInfo.size;
		var dv = du;
		
		// The (u,v) of the first texel is half a texel from the corner (-1,-1).
		var minUV = du * 0.5 - 1.0;
		
		for (faceIndex in 0...6) {
			var fileFace = FileFaces[faceIndex];
			
			var dataArray:Float32Array = Reflect.field(cubeInfo, fileFace.name);
			var v = minUV;
			
			// TODO: we could perform the summation directly into a SphericalPolynomial (SP), which is more efficient than SphericalHarmonic (SH).
			// This is possible because during the summation we do not need the SH-specific properties, e.g. orthogonality.
			// Because SP is still linear, so summation is fine in that basis.
			
			for (y in 0...cubeInfo.size) {
				var u = minUV;
				
				for (x in 0...cubeInfo.size) {
					// World direction (not normalised)
					var worldDirection =
						fileFace.worldAxisForFileX.scale(u).add(
						fileFace.worldAxisForFileY.scale(v)).add(
						fileFace.worldAxisForNormal);
					worldDirection.normalize();
					
					var deltaSolidAngle = Math.pow(1.0 + u * u + v * v, -3.0 / 2.0);
					
					if (true) {
						var r = dataArray[(y * cubeInfo.size * 3) + (x * 3) + 0];
						var g = dataArray[(y * cubeInfo.size * 3) + (x * 3) + 1];
						var b = dataArray[(y * cubeInfo.size * 3) + (x * 3) + 2];
						
						var color = new Color3(r, g, b);
						
						sphericalHarmonics.addLight(worldDirection, color, deltaSolidAngle);    
					}
					else {
						switch (faceIndex) {
							case 0:
								dataArray[(y * cubeInfo.size * 3) + (x * 3) + 0] = 1;
								dataArray[(y * cubeInfo.size * 3) + (x * 3) + 1] = 0;
								dataArray[(y * cubeInfo.size * 3) + (x * 3) + 2] = 0;
							 
							case 1:
								dataArray[(y * cubeInfo.size * 3) + (x * 3) + 0] = 0;
								dataArray[(y * cubeInfo.size * 3) + (x * 3) + 1] = 1;
								dataArray[(y * cubeInfo.size * 3) + (x * 3) + 2] = 0;
							
							case 2:
								dataArray[(y * cubeInfo.size * 3) + (x * 3) + 0] = 0;
								dataArray[(y * cubeInfo.size * 3) + (x * 3) + 1] = 0;
								dataArray[(y * cubeInfo.size * 3) + (x * 3) + 2] = 1;
							
							case 3:
								dataArray[(y * cubeInfo.size * 3) + (x * 3) + 0] = 1;
								dataArray[(y * cubeInfo.size * 3) + (x * 3) + 1] = 1;
								dataArray[(y * cubeInfo.size * 3) + (x * 3) + 2] = 0;
							
							case 4:
								dataArray[(y * cubeInfo.size * 3) + (x * 3) + 0] = 1;
								dataArray[(y * cubeInfo.size * 3) + (x * 3) + 1] = 0;
								dataArray[(y * cubeInfo.size * 3) + (x * 3) + 2] = 1;
							
							case 5:
								dataArray[(y * cubeInfo.size * 3) + (x * 3) + 0] = 0;
								dataArray[(y * cubeInfo.size * 3) + (x * 3) + 1] = 1;
								dataArray[(y * cubeInfo.size * 3) + (x * 3) + 2] = 1;
						}
						
						var color = new Color3(dataArray[(y * cubeInfo.size * 3) + (x * 3) + 0],
												dataArray[(y * cubeInfo.size * 3) + (x * 3) + 1], 
												  dataArray[(y * cubeInfo.size * 3) + (x * 3) + 2]);
							
						sphericalHarmonics.addLight(worldDirection, color, deltaSolidAngle);
					}
					
					totalSolidAngle += deltaSolidAngle;
					
					u += du;
				}
				
				v += dv;
			}
		}
		
		var correctSolidAngle = 4.0 * Math.PI; // Solid angle for entire sphere is 4*pi
		var correction = correctSolidAngle / totalSolidAngle;
		
		sphericalHarmonics.scale(correction);
		
		// Additionally scale by pi -- audit needed
		sphericalHarmonics.scale(1.0 / Math.PI);
		
		return SphericalPolynomial.getSphericalPolynomialFromHarmonics(sphericalHarmonics);
	}
	
}
