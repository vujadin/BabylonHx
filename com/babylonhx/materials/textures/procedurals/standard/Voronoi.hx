package com.babylonhx.materials.textures.procedurals.standard;

import com.babylonhx.math.Vector2;

/**
 * ...
 * @author Krtolica Vujadin
 */

/*
 

	Rounded Voronoi Borders
	-----------------------

	Fabrice came up with an interesting formula to produce more evenly distributed Voronoi values. 
	I'm sure there are more interesting ways to use it, but I like the fact that it facilitates 
	the creation of more rounded looking borders. I'm sure there are more sophisticated ways to 
	produce more accurate borders, but Fabrice's version is simple and elegant.

	The process is explained below. The link to the original is below also.

	I didn't want to cloud the example with too much window dressing, so just for fun, I tried 
	to pretty it up by using as little code as possible.

	// 2D version
	2D trabeculum - FabriceNeyret2
	https://www.shadertoy.com/view/4dKSDV

	// 3D version
	hypertexture - trabeculum - FabriceNeyret2
	https://www.shadertoy.com/view/ltj3Dc

	// Straight borders - accurate geometric solution.
	Voronoi - distances - iq
	https://www.shadertoy.com/view/ldl3W8

*/

/*
 
#extension GL_OES_standard_derivatives : enable
 
uniform vec2 texRes;
uniform float time;

// vec2 to vec2 hash.
vec2 hash22(vec2 p) { 

    // Faster, but doesn't disperse things quite as nicely as other combinations. :)
    float n = sin(dot(p, vec2(41, 289)));
    //return fract(vec2(262144, 32768)*n)*.75 + .25; 
    
    // Animated.
    p = fract(vec2(262144, 32768)*n); 
    return sin( p*6.2831853 + time )*.35 + .65; 
    
}

// 2D 3rd-order Voronoi: This is just a rehash of Fabrice Neyret's version, which is in
// turn based on IQ's original. I've simplified it slightly, and tidied up the "if-statements,"
// but the clever bit at the end came from Fabrice.
//
// Using a bit of science and art, Fabrice came up with the following formula to produce a more 
// rounded, evenly distributed, cellular value:

// d1, d2, d3 - First, second and third closest points (nodes).
// val = 1./(1./(d2-d1) + 1./(d3-d1));
//
float Voronoi(in vec2 p){
    
	vec2 g = floor(p), o; p -= g;
	
	vec3 d = vec3(1); // 1.4, etc.
    
    float r = 0.;
    
	for(int y = -1; y <= 1; y++){
		for(int x = -1; x <= 1; x++){
            
			o = vec2(x, y);
            o += hash22(g + o) - p;
            
			r = dot(o, o);
            
            // 1st, 2nd and 3rd nearest squared distances.
            d.z = max(d.x, max(d.y, min(d.z, r))); // 3rd.
            d.y = max(d.x, min(d.y, r)); // 2nd.
            d.x = min(d.x, r); // Closest.
                       
		}
	}
    
	d = sqrt(d); // Squared distance to distance.
    
    // Fabrice's formula.
    return min(2./(1./max(d.y - d.x, .001) + 1./max(d.z - d.x, .001)), 1.);
    
}

vec2 hMap(vec2 uv){
    
    // Plain Voronoi value. We're saving it and returning it to use when coloring.
    // It's a little less tidy, but saves the need for recalculation later.
    float h = Voronoi(uv*6.);
    
    // Adding some bordering and returning the result as the height map value.
    float c = smoothstep(0., fwidth(h)*2., h - .09)*h;
    c += (1.-smoothstep(0., fwidth(h)*3., h - .22))*c*.5; 
    
    // Returning the rounded border Voronoi, and the straight Voronoi values.
    return vec2(c, h);
    
}

void main(){

    // Moving screen coordinates.
	vec2 uv = gl_FragCoord.xy/texRes.y + vec2(-.2, .05)*time;
    
    // Obtain the height map (rounded Voronoi border) value, then another nearby. 
    vec2 c = hMap(uv);
    vec2 c2 = hMap(uv + .004);
    
    // Take a factored difference of the values above to obtain a very, very basic gradient value.
    // Ie. - a measurement of the bumpiness, or bump value.
    float b = max(c2.x - c.x, 0.)*16.;
    
    // Use the height map value to produce some color. It's all made up on the spot, so don't pay it
    // too much attention.
    //
    vec3 col = vec3(1, .05, .25)*c.x; // Red base.
    float sv = Voronoi(uv*16. + c.y)*.66 + (1.-Voronoi(uv*48. + c.y*2.))*.34; // Finer overlay pattern.
    col = col*.85 + vec3(1, .7, .5)*sv*sqrt(sv)*.3; // Mix in a little of the overlay.
    col += (1. - col)*(1.-smoothstep(0., fwidth(c.y)*3., c.y - .22))*c.x; // Highlighting the border.
    col *= col; // Ramping up the contrast, simply because the deeper color seems to look better.
    
    // Taking a pattern sample a little off to the right, ramping it up, then combining a bit of it
    // with the color above. The result is the flecks of yellowy orange that you see. There's no physics
    // behind it, but the offset tricks your eyes into believing something's happening. :)
    sv = col.x*Voronoi(uv*6. + .5);
    col += vec3(.7, 1, .3)*pow(sv, 4.)*8.;
    
    // Apply the bump - or a powered variation of it - to the color for a bit of highlighting.
    col += vec3(.5, .7, 1)*(b*b*.5 + b*b*b*b*.5);
	 
    
    // Basic gamma correction
	gl_FragColor = vec4(sqrt(clamp(col, 0., 1.)), 1);
    
}

*/

@:expose("BABYLON.VoronoiProceduralTexture") class Voronoi extends ProceduralTexture {
	
	public static var fragmentShader:String = "#extension GL_OES_standard_derivatives : enable\n #ifdef GL_ES \n precision highp float; \n #endif \nuniform vec2 texRes;uniform float time;vec2 hash22(vec2 p){float n=sin(dot(p,vec2(41,289)));p=fract(vec2(262144,32768)*n);return sin(p*6.28319+time)*.35+.65;}float Voronoi(in vec2 p){vec2 g=floor(p),o;p-=g;vec3 d=vec3(1);float r=0.;for(int y=-1;y<=1;y++){for(int x=-1;x<=1;x++)o=vec2(x,y),o+=hash22(g+o)-p,r=dot(o,o),d.z=max(d.x,max(d.y,min(d.z,r))),d.y=max(d.x,min(d.y,r)),d.x=min(d.x,r);}d=sqrt(d);return min(2./(1./max(d.y-d.x,.001)+1./max(d.z-d.x,.001)),1.);}vec2 hMap(vec2 uv){float h=Voronoi(uv*6.),c=smoothstep(0.,fwidth(h)*2.,h-.09)*h;c+=(1.-smoothstep(0.,fwidth(h)*3.,h-.22))*c*.5;return vec2(c,h);}void main(){vec2 uv=gl_FragCoord.xy/texRes.y+vec2(-.2,.05)*time,c=hMap(uv),c2=hMap(uv+.004);float b=max(c2.x-c.x,0.)*16.;vec3 col=vec3(1,.05,.25)*c.x;float sv=Voronoi(uv*16.+c.y)*.66+(1.-Voronoi(uv*48.+c.y*2.))*.34;col=col*.85+vec3(1,.7,.5)*sv*sqrt(sv)*.3;col+=(1.-col)*(1.-smoothstep(0.,fwidth(c.y)*3.,c.y-.22))*c.x;col*=col;sv=col.x*Voronoi(uv*6.+.5);col+=vec3(.7,1,.3)*pow(sv,4.)*8.;col+=vec3(.5,.7,1)*(b*b*.5+b*b*b*b*.5);gl_FragColor=vec4(sqrt(clamp(col,0.,1.)),1);}";

	
	private var _time:Float = 0.0;
	private var _resolution:Vector2 = new Vector2(0, 0);
	

	public function new(name:String, size:Float, scene:Scene, ?fallbackTexture:Texture, ?generateMipMaps:Bool) {
		if (!ShadersStore.Shaders.exists("voronoitextureFragmentShader")) {
			ShadersStore.Shaders.set("voronoitextureFragmentShader", fragmentShader);
		}
		
		super(name, size, "voronoitexture", scene, fallbackTexture, generateMipMaps);
		
		this._resolution.copyFromFloats(size, size);
		
		this.updateShaderUniforms();
		this.refreshRate = 1;
	}
	
	public function updateShaderUniforms() {
		this.setFloat("time", this._time);
		this.setVector2("texRes", this._resolution);
	}

	override public function render(useCameraPostProcess:Bool = false) {
		this._time += this.getScene().getAnimationRatio() * 0.005;
		this.updateShaderUniforms();
		
		super.render(useCameraPostProcess);
	}
	
}
