package com.babylonhxext.bumper;

import snow.render.opengl.GL.GLTexture;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:enum abstract FallOffEnum(Int) {
	var NO = 0;
    var LINEAR = 1;
    var SQUARE = 2;
}

class SpecularMap {
	
	public var specular_mean:Float = 255;
	public var specular_range:Float = 255;
	public var specular_canvas:GLTexture;
	public var specular_falloff:FallOffEnum = FallOffEnum.LINEAR;
	

	public function new(element:String, v:Float) {
		if (element == "spec_mean") {
			specular_mean = v * 255;			
		}
		else if (element == "spec_range") {
			specular_range = v * 255;
		}
		else if (element == "spec_falloff") {
			if (v == "linear") {
				specular_falloff = FallOffEnum.LINEAR;
			}
			else if (v == "square") {
				specular_falloff = FallOffEnum.SQUARE;
			}
			else if (v == "no") {
				specular_falloff = FallOffEnum.NO;
			}
		}
			
		/*if (auto_update && Date.now() - timer > 150){
			createSpecularTexture();
			timer = Date.now();
		}*/
	}
	
	public function createSpecularTexture() {
		var img_data = Filters.filterImage(Filters.grayscale, height_image);
		var specular_map = Filters.createImageData(img_data.width, img_data.height);
		
		// invert colors if needed
		var v = 0.0;
		var i = 0;
		while(i < img_data.
		for (i 0...img_data.data.length i += 4){
			v = (img_data.data[i] + img_data.data[i+1] + img_data.data[i+2]) * 0.333333; // average
			v = v < 1.0 || v > 255.0 ? 0 : v; // clamp

			var per_dist_to_mean = (specular_range - Math.abs(v - specular_mean)) / specular_range;

			if(specular_falloff == FallOffEnum.NO)
				v = per_dist_to_mean > 0 ? 1 : 0;
			else if(specular_falloff == FallOffEnum.LINEAR)
				v = per_dist_to_mean > 0 ? per_dist_to_mean : 0;
			else if(specular_falloff == FallOffEnum.SQUARE)
				v = per_dist_to_mean > 0 ? Math.sqrt(per_dist_to_mean,2) : 0;

			v = v*255;
			specular_map.data[i]   = v;
			specular_map.data[i+1] = v;
			specular_map.data[i+2] = v;
			//specular_map.data[i+3] = 255;
			specular_map.data[i+3] = img_data.data[i+3];
		}


		// write out texture
		var ctx_specular = specular_canvas.getContext("2d");
		specular_canvas.width = img_data.width;
		specular_canvas.height = img_data.height;
		ctx_specular.clearRect(0, 0, img_data.width, img_data.height);
		ctx_specular.putImageData(specular_map, 0, 0, 0, 0, img_data.width, img_data.height);
		
		setTexturePreview(specular_canvas, "specular_img", img_data.width, img_data.height);
	}
	
}
