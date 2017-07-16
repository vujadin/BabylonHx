package com.babylonhx.tools;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.RGB') typedef RGB = {
	r:Int,
	g:Int,
	b:Int
}

@:expose('BABYLON.HSL') typedef HSL = {
	h:Float,
	s:Float,
	l:Float
}
 
@:expose('BABYLON.ColorTools') class ColorTools {

	public static inline function toRGB(color:Int):RGB {
        return {
            r: ((color >> 16) & 255),
            g: ((color >> 8) & 255),
            b: (color & 255)
        }
    }
	
	public static function hue2rgb(p:Float, q:Float, t:Float):Float {
		if (t < 0) {
			t += 1;
		}
		if (t > 1) {
			t -= 1;
		}
		if (t < 1 / 6) {
			return p + (q - p) * 6 * t;
		}
		if (t < 1 / 2) {
			return q;
		}
		if (t < 2 / 3) {
			return p + (q - p) * (2 / 3 - t) * 6;
		}
		return p;
	}
	
	public static function hslToRgb(h:Float, s:Float, l:Float):RGB {
		var r:Float, g:Float, b:Float;
		
		if(s == 0){
			r = g = b = l; // achromatic
		} else {			
			var q = l < 0.5 ? l * (1 + s) : l + s - l * s;
			var p = 2 * l - q;
			r = hue2rgb(p, q, h + 1 / 3);
			g = hue2rgb(p, q, h);
			b = hue2rgb(p, q, h - 1 / 3);
		}
		
		return { r: Math.round(r * 255), g: Math.round(g * 255), b: Math.round(b * 255) };
	}
	
	public static inline function rgbToHsl(r:Float, g:Float, b:Float):HSL {
		r /= 255;
		g /= 255;
		b /= 255;
		var max = Math.max(r, g);
		max = Math.max(max, b);
		var min = Math.min(r, g);
		min = Math.min(min, b);
		var h = 0.0;
		var s = 0.0;
		var l = (max + min) / 2;
		
		if (max == min) {
			h = s = 0; // achromatic
		} else {
			var d = max - min;
			s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
			
			if(max == r) { 
				h = (g - b) / d;
			}
					
			if(max == g) { 
				h = 2 + ( (b - r) / d);
			}
					
			if(max == b) { 
				h = 4 + ( (r - g) / d);
			}
			
			h *= 60;
			if (h < 0) {
				h += 360;
			}
		}
		 
		return { h: h, s: s, l: l };
	} 
	
	public static inline function toInt(rgb:RGB):Int {
        return (Math.round(rgb.r * 255) << 16) | (Math.round(rgb.g * 255) << 8) | Math.round(rgb.b * 255);
    }
	
}
