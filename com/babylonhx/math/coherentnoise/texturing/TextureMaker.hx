package com.babylonhx.math.coherentnoise.texturing;

import com.babylonhx.materials.textures.Texture;
import com.babylonhx.utils.Image;

import lime.utils.UInt8Array;


/// <summary>
/// Use methods in this class to create Unity textures with noise generators. 
/// All textures are created using 2D noise (i.e, Z coordinate is always 0), and sample source noise in
/// [0,1]x[0,1] area.
/// </summary>
class TextureMaker {

	/// <summary>
	/// Generic texture-building method. Creates a texture using a fuction that transforms float coordiantes (in the range [0,1]x[0,1]) into color
	/// </summary>
	///<param name="width">Texture width.</param>
	///<param name="height">Texture height</param>
	/// <param name="colorFunc">Function mapping coordinates to color</param>
	///<returns></returns>
	public static function Make(width:Int, height:Int, colorFunc:Float->Float->RGBA, name:String):Texture {
		var cols:Array<RGBA> = [];
		for (ii in 0...width) {
			for (jj in 0...height) {
				cols[Std.int(ii + jj * width)] = colorFunc(ii / width, jj / height);
			}
		}
		
		var data = new UInt8Array(width * height * 4);
		var index:Int = 0;
		var SXtimeSY:Int = Std.int(width * height);
		for (x in 0...SXtimeSY) {
			index = 4 * x;
			data[index]     = cols[x].Rb;
			data[index + 1] = cols[x].Gb;
			data[index + 2] = cols[x].Bb;
			data[index + 3] = cols[x].Ab;
		}
		
		#if (js && debug)
		var img = js.Browser.document.createCanvasElement();
		img.width = 256;
		img.height = 256;
		var ctx = img.getContext2d();
		var imgdata = new js.html.ImageData(256, 256);
		imgdata.data.set(cast data);
		ctx.putImageData(imgdata, 0, 0);
		js.Browser.document.body.appendChild(img);
		#end
		
		var ret = new Texture(new Image(data, width, height), name);
		
		return ret;
	}

	///<summary>
	/// Creates a texture using ramp of colors. Noise value (clamped to [-1,1]) is mapped to one-dimensional ramp texture to obtain final color.
	/// As there are no 1-dimensional textures in Unity, Texture2D is used, that is sampled along its top line.
	///</summary>
	///<param name="width">Texture width.</param>
	///<param name="height">Texture height</param>
	///<param name="noise">Noise source</param>
	///<param name="ramp">Ramp texture</param>
	///<returns></returns>
	public static function RampTexture(width:Int, height:Int, noise:Generator, ramp:Texture):Texture {
		var rampCols:Array<RGBA> = [];	// ramp.GetPixels(0, 0, ramp.width, 1);
		for (i in 0...ramp.width) {
			rampCols[i] = ramp.img.at(i, 0);
		}
		
		return Make(width, height, function(x:Float, y:Float) {
			var v = noise.GetValue(x, y, 0) * 0.5 + 0.5;
			
			return rampCols[Std.int(math.Tools.Clamp(v) * (ramp.width - 1))];
		}, ramp.id);
	}
	
	///<summary>
	/// Creates a texture to use as a bump map, taking height noise as input.
	///</summary>
	///<param name="width">Texture width.</param>
	///<param name="height">Texture height</param>
	///<param name="noise">heightmap  source</param>
	///<returns></returns>

	public static function BumpMap(width:Int, height:Int, noise:Generator, name:String):Texture {
		var cols:Array<RGBA> = []; 
		var normal:Vector3 = new Vector3();
		for (ii in 0...width) {
			for (jj in 0...height) {
				var left = noise.GetValue((ii - 0.5) / width, jj / height, 0);
				var right = noise.GetValue((ii + 0.5) / width, jj / height, 0);
				var down = noise.GetValue(ii / width, (jj - 0.5) / height, 0);
				var up = noise.GetValue(ii / width, (jj + 0.5) / height, 0);
				
				normal.set(right - left, up - down, 1).normalize();
				var idx:Int = Std.int(ii + jj * width);
				cols[idx] = Color.White;				
				cols[idx].Rb = Math.floor(normal.x * 255);
				cols[idx].Gb = Math.floor(normal.y * 255);
				cols[idx].Bb = Math.floor(normal.z * 255);
				cols[idx].Ab = 255;
			}
		}
		
		var data = new UInt8Array(width * height * 4);
		var index:Int = 0;
		var SXtimeSY:Int = Std.int(width * height);
		for (x in 0...SXtimeSY) {
			index = 4 * x;
			data[index]     = cols[x].Rb;
			data[index + 1] = cols[x].Gb;
			data[index + 2] = cols[x].Bb;
			data[index + 3] = cols[x].Ab;
		}
		
		#if (js && debug)
		var img = js.Browser.document.createCanvasElement();
		img.width = 256;
		img.height = 256;
		var ctx = img.getContext2d();
		var imgdata = new js.html.ImageData(256, 256);
		imgdata.data.set(cast data);
		ctx.putImageData(imgdata, 0, 0);
		js.Browser.document.body.appendChild(img);
		#end
		
		var ret = new Texture(new Image(data, width, height), name);
		
		return ret;
	}

/*
	///<summary>
	/// Creates a texture with only alpha channel.
	///</summary>
	///<param name="width">Texture width.</param>
	///<param name="height">Texture height</param>
	///<param name="noise">Noise source</param>
	///<returns></returns>
	public static Texture AlphaTexture(int width, int height, Generator noise)
	{
		return Make(width,height,(x,y)=>new Color(0,0,0,noise.GetValue(x,y,0)*0.5f+0.5f), TextureFormat.Alpha8);
	}
	///<summary>
	/// Creates a monochrome texture.
	///</summary>
	///<param name="width">Texture width.</param>
	///<param name="height">Texture height</param>
	///<param name="noise">Noise source</param>
	///<returns></returns>
	public static Texture MonochromeTexture(int width, int height, Generator noise)
	{
		return Make(width, height, (x, y) =>
										{
											var v = noise.GetValue(x, y, 0) * 0.5f + 0.5f;
											return new Color(v, v, v, 1);
										});
	}
*/

}
