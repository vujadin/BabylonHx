package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.PointLight;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;
import com.babylonhx.tools.ColorTools;
import com.babylonhx.tools.Tools;
import com.babylonhx.collisions.PickingInfo;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.ShaderMaterial;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.ShadersStore;

/**
 * ...
 * @author Krtolica Vujadin
 */
class ShaderMaterialTest {

	public function new(scene:Scene) {
		//render cam
		var camera = new ArcRotateCamera("ArcRotateCamera", 1, 0.8, 5, new Vector3(0, 0, 0), scene);
		camera.attachControl();
		camera.lowerRadiusLimit = 1;
		camera.wheelPrecision = 20;
		scene.activeCamera = camera;
		
		//Create a light
		//var light = new PointLight("Omni", new Vector3( -60, 60, 80), scene);
		
		var box = Mesh.CreateBox("box", 1.0, scene);
		box.position.y = 1;
		box.position.x = -1.5;
		box.position.z = -1.5;
		
		var box2 = Mesh.CreateBox("box2", 1.0, scene);
		box2.position.y = 1;
		box2.position.x = 0;
		box2.position.z = -1.5;
		
		var box3 = Mesh.CreateBox("box3", 1.0, scene);
		box3.position.y = 1;
		box3.position.x = 1.5;
		box3.position.z = -1.5;
		
		var box4 = Mesh.CreateBox("box4", 1.0, scene);
		box4.position.y = 1;
		box4.position.x = -1.5;
		box4.position.z = 0;
		
		var box5 = Mesh.CreateBox("box5", 1.0, scene);
		box5.position.y = 1;
		box5.position.x = 0;
		box5.position.z = 0;
		
		var box6 = Mesh.CreateBox("box6", 1.0, scene);
		box6.position.y = 1;
		box6.position.x = 1.5;
		box6.position.z = 0;
		
		var box7 = Mesh.CreateBox("box7", 1.0, scene);
		box7.position.y = 1;
		box7.position.x = -1.5;
		box7.position.z = 1.5;
		
		var box8 = Mesh.CreateBox("box8", 1.0, scene);
		box8.position.y = 1;
		box8.position.x = 0;
		box8.position.z = 1.5;
		
		var box9 = Mesh.CreateBox("box9", 1.0, scene);
		box9.position.y = 1;
		box9.position.x = 1.5;
		box9.position.z = 1.5;
		
		/*var ground = Mesh.CreateGround("ground1", 6, 6, 2, scene);
		ground.enableEdgesRendering(.99);
		ground.edgesWidth = 2.0;
		ground.material = new StandardMaterial("gmat", scene);
		untyped ground.material.diffuseTexture = new Texture("assets/img/dummy.jpg", scene);
		ground.material.backFaceCulling = false;*/
		
		
		/////////////////////MATERIAL
		ShadersStore.Shaders.set("customVertexShader", 'precision highp float;  attribute vec3 position; attribute vec3 normal; attribute vec2 uv;  uniform mat4 worldViewProjection; uniform float time;  varying vec3 vPosition; varying vec3 vNormal; varying vec2 vUV;  void main(void) {     vec3 v = position;     gl_Position = worldViewProjection * vec4(v, 1.0);     vPosition = position;     vNormal = normal;     vUV = uv; }');
		
		ShadersStore.Shaders.set("customPixelShader", '' +
		'#extension GL_OES_standard_derivatives : enable\n' +
		'precision highp float;\n' +
		
		'varying vec3 vPosition;\n' +
		'varying vec3 vNormal;\n' +
		'varying vec2 vUV;\n' +
		
		'uniform mat4 worldViewProjection;\n' +
		'uniform float time;\n' +
		'float rand(vec2 n) {\n' +
		'	return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);\n' + 
		'}\n' +  
		
		'float noise(vec2 n) {\n' +
		'	const vec2 d = vec2(0.0, 1.0);\n' +
		'	vec2 b = floor(n), f = smoothstep(vec2(0.0), vec2(1.0), fract(n));\n' +
		'	return mix(mix(rand(b), rand(b + d.yx), f.x), mix(rand(b + d.xy), rand(b + d.yy), f.x), f.y);\n' +
		'}\n' +  
		
		'float fbm(vec2 n) {\n' +
		'	float total = 0.0, amplitude = 1.0;\n' +
		'	for (int i = 0; i < 7; i++) {\n' +        
		'		total += noise(n) * amplitude;\n' +         
		'		n += n;\n' +         
		'		amplitude *= 0.5;\n' +
		'	}\n' +     
		'	return total;\n' + 
		'}  void main(void) {          vec2 t = vUV * vec2(2.0,1.0) - time*3.0;     vec2 t2 = (vec2(1,-1) + vUV) * vec2(2.0,1.0) - time*3.0;           float ycenter = fbm(t)*0.5;     float ycenter2= fbm(t2)*0.5;       float diff = abs(vUV.y - ycenter);     float c1 = 1.0 - mix(0.0,1.0,diff*20.0);         float diff2 = abs(vUV.y - ycenter2);     float c2 = 1.0 - mix(0.0,1.0,diff2*20.0);         float c = max(c1,c2);     vec3 cout=vec3(c*0.2,0.6*c2,c); if(cout.x<.2 &&  cout.y<.2 && cout.z <.2) { 		if(mod(vUV.x*50.,2.0)<1.7&&mod(vUV.y*50.,2.0)<1.7) { 			discard; 		} else { 			cout=vec3(0.7,0.7,0.7); 		} 	} 	 gl_FragColor = vec4( cout, 1. ); }');
		
		ShadersStore.Shaders["custom2PixelShader"] = 'precision highp float;   varying vec3 vPosition; varying vec3 vNormal; varying vec2 vUV;  uniform mat4 worldViewProjection; uniform float time;  void main(void) { vec2 mv=vec2(.5,.5); float r=.3+mod(time*.1,.4);	vec3 color = vec3(smoothstep(r, r+.01, distance(mv, vUV))); 	if(color.x<.1&&color.y<.1) 	discard;     gl_FragColor = vec4( color, 1. ); 	  }';
		
		ShadersStore.Shaders["custom3PixelShader"] = 'precision highp float; varying vec3 vPosition; varying vec3 vNormal; varying vec2 vUV;  uniform mat4 worldViewProjection;  uniform float time;  float PI=3.141592; float STROKE=0.3; void main(void) { 	vec2 uv=vUV.xy*5.;     float freq1 =  0.5 * sin(time*4. + uv.x*.125 + uv.y * .2) + 0.5;     float circle = smoothstep(freq1-STROKE, freq1, cos(uv.x * 2.0 *PI) *  cos(uv.y * 2.0 *PI))- smoothstep(freq1,freq1+STROKE, cos(uv.x * 2.0 *PI) *  cos(uv.y * 2.0 *PI));   	gl_FragColor =  vec4( circle*0.2, circle*0.3, circle, 1. ); }';
		
		ShadersStore.Shaders["custom4PixelShader"] = 'precision highp float; varying vec3 vPosition; varying vec3 vNormal; varying vec2 vUV; uniform mat4 worldViewProjection; uniform float time; mat3 xrot(float t) {     return mat3(1.0, 0.0, 0.0,                 0.0, cos(t), -sin(t),                 0.0, sin(t), cos(t)); } mat3 yrot(float t) {     return mat3(cos(t), 0.0, -sin(t),                 0.0, 1.0, 0.0,                 sin(t), 0.0, cos(t)); } mat3 zrot(float t) {     return mat3(cos(t), -sin(t), 0.0,                 sin(t), cos(t), 0.0,                 0.0, 0.0, 1.0); } void main(void) { 	float PI=3.141592; 	float STROKE=0.3; 	vec2 uv=vUV.xy*1.;     vec3 eye = normalize(vec3(uv,1.0-dot(uv,uv)*0.5));     float tt=0.0;     float d = 0.0;     vec3 col;     for(int i = 0; i < 16; ++i){         vec3 pos = eye*tt;         pos = pos * xrot(-PI/4.0) * yrot(-PI/4.0);         float theta = time;         pos = pos * xrot(theta) * yrot(theta) * zrot(theta);         pos.z += time;         pos.y += 0.25 + time;        	pos.x += 0.5 + time;         vec3 coord = floor(pos);        	pos = (pos - coord) - 0.5;         d = length(pos)-0.2;         float idx = dot(coord,vec3(1.0));         idx = floor(fract(idx/3.0)*3.0);         if(idx==0.0){             col = vec3(1.0, 0.0, 0.0);         }else if(idx==1.0){             col = vec3(0.0, 1.0, 0.0);         }else if(idx==2.0){             col = vec3(0.0, 0.0, 1.0);         }         float k;         k = length(pos.xy)-0.05;         if(k<d){         	d=k;             col=vec3(1.0,1.0,1.0);         }         k = length(pos.xz)-0.05;         if(k<d){         	d=k;             col=vec3(1.0,1.0,1.0);         }         k = length(pos.yz)-0.05;         if(k<d){         	d=k;             col=vec3(1.0,1.0,1.0);         }         tt+=d;     }     float fog = 1.0 / (1.0 + tt*tt*0.5 + d*100.0); 	gl_FragColor =  vec4( fog*col, 1. );  }';
		
		ShadersStore.Shaders["custom5PixelShader"] = 'precision highp float;   varying vec3 vPosition; varying vec3 vNormal; varying vec2 vUV;  uniform mat4 worldViewProjection; uniform float time;   float r(float n) {  	return fract(abs(sin(n*55.753)*367.34));    } float r(vec2 n) {     return r(dot(n,vec2(2.46,-1.21))); } vec3 color(float type) {  	float t = floor(type*3.0);     vec3 c1 = vec3( 0.738, 0.067, 0.185);     vec3 c2 = vec3( 1.0);     vec3 c3 = vec3( 0.15);     return mix(c1,mix(c2,c3,t-1.0),clamp(t,0.0,1.0)); }  void main(void) {      	float PI=3.141592; 	float STROKE=0.3; 	vec2 uv=vUV.xy*300.;     float a = (radians(60.0));     float zoom = 192.0;  	vec2 cc = (uv.xy+vec2(time*zoom,0.0))*vec2(sin(a),1.0); 	    cc = ((cc+vec2(cc.y,0.0)*cos(a))/zoom)+vec2(floor((cc.x-cc.y*cos(a))/zoom*4.0)/4.0,0.0);     float type = (r(floor(cc*4.0))*0.2+r(floor(cc*2.0))*0.3+r(floor(cc))*0.5);     vec3 n = color(type); 	float l = fract((fract(cc.y*4.0)+fract(cc.x*4.0)+fract((cc.x-cc.y)*4.0)*0.5)/2.5)*0.3+0.7; 	  	gl_FragColor =  vec4( n * l, 1. );  }';
		
		ShadersStore.Shaders["custom6PixelShader"] = 'precision highp float;   varying vec3 vPosition; varying vec3 vNormal; varying vec2 vUV;  uniform mat4 worldViewProjection; uniform float time;   void main(void) {      	float PI=3.141592; 	vec2 uv=vUV.xy*300.; 	float STROKE=0.3; 	float mag  = 10.; 	float pulse = 0.; 	 float gs = 500. / 20.; 	 float ar = 1.;      vec2  s =uv.xy/mag+pulse;     vec2  p =uv.xy/500.*s-s/2.;     float v =.0+sin((p.x+.8*time))+sin((p.y+.8*time)/2.)+sin((p.x+p.y+.9*time)/2.);     p += s/2.*vec2(sin(time/.9),cos(time/.6));     v += sin(sqrt(p.x*p.x+p.y*p.y+1.)+time);     float R =sin(.2*PI*v),G =cos(.75*PI*v),B =sin(.9*PI*v);     R = ceil(R*255. /  8.) *  8. / 256.;     G = ceil(G*255. / 16.) * 16. / 256.;     B = ceil(B*255. /  8.) *  8. / 256.;      if(mod(R,16.) < 1.) R =G*.5+.5;     vec3 col =vec3(R,G,B);       col *= 0.4 * 1./length( sin( 1.*.1 * gs*p.x ) );     col *= 0.8 * 1./length( sin( ar*.1 * gs*p.y ) );           col *= .33 * length( sin( 5. * p.y * gs ) );      col = clamp(col,vec3(.0),vec3(1.));   	 	gl_FragColor =  vec4( col, 1. );  }';
		
		ShadersStore.Shaders["custom7PixelShader"] = 'precision highp float;   varying vec3 vPosition; varying vec3 vNormal; varying vec2 vUV;  uniform mat4 worldViewProjection; uniform float time;  float dist (vec2 uv, vec2 p0) {     vec2 off = abs(uv - p0) * 3.0;     float p = sin(time) * 2.0 + 4.0;     float r = pow(pow(off.x, p) + pow(off.y, p), 1.0 / p);     vec2 ox = uv - p;     float t = atan(ox.y, ox.x);     return 1.0 - abs(1.0 - pow(mod(r * 8.0 / (3.5 + sin(t * 4.0 + time)), 1.0), 2.0)); }  void main(void) {      	float PI=3.141592; 	vec2 uv=vUV;     float d1 = dist(uv, vec2(0.3, 0.3));     float d2 = dist(uv, vec2(0.7, 0.3));     float d3 = dist(uv, vec2(0.3, 0.7));     float d4 = dist(uv, vec2(0.7, 0.7));     float d = d1 - d2 - d3 + d4; 	 	gl_FragColor =  vec4( d,d,d, 1. );  }';
		
		ShadersStore.Shaders["custom8PixelShader"] = 'precision highp float;   varying vec3 vPosition; varying vec3 vNormal; varying vec2 vUV;  uniform mat4 worldViewProjection; uniform float time;    void main(void) {      	float PI=3.141592; 	vec2 uv=vUV.xy*95.; 	float cc=0.05;     vec2 middle = floor(uv*cc+.5)/cc;      vec3 color = vec3(0.0,0.7,0.0);              float dis = distance(uv,middle)*cc*2.;             if(dis<.65&&dis>.55){             color *= dot(vec2(0.707),normalize(uv-middle))*.5+1.;         }          vec2 delta = abs(uv-middle)*cc*2.;         float sdis = max(delta.x,delta.y);         if(sdis>.9){             color *= .8;         } 	 	gl_FragColor =  vec4( color, 1. );  }';
		
		ShadersStore.Shaders["custom9PixelShader"] = 'precision highp float;   varying vec3 vPosition; varying vec3 vNormal; varying vec2 vUV;  uniform mat4 worldViewProjection; uniform float time;   mat2 rotate2d(float angle){     return mat2(cos(angle),-sin(angle),                 sin(angle),cos(angle)); }  float variation(vec2 v1, vec2 v2, float strength, float speed) { 	return sin(         dot(normalize(v1), normalize(v2)) * strength + time * speed     ) / 100.0; }  vec3 paintCircle (vec2 uv, vec2 center, float rad, float width) {     vec2 diff = center-uv;     float len = length(diff);     len += variation(diff, vec2(0.0, 1.0), 5.0, 2.0);     len -= variation(diff, vec2(1.0, 0.0), 5.0, 2.0);     float circle = smoothstep(rad-width, rad, len) - smoothstep(rad, rad+width, len);     return vec3(circle); }  void main(void) { 	float PI=3.141592; 	vec2 uv=vUV.xy*1.01;     vec3 color;     float radius = 0.35;     vec2 center = vec2(0.5);     color = paintCircle(uv, center, radius, 0.1);     vec2 v = rotate2d(time) * uv;     color *= vec3(v.x, v.y, 0.7-v.y*v.x);     color += paintCircle(uv, center, radius, 0.01); gl_FragColor =  vec4( color, color.x * color.y );  }';
		
		//-----------------------
		var shaderMaterial = new ShaderMaterial("shader", scene, {
				vertex: "custom",
				fragment: "custom",
			}, {
				attributes: ["position", "normal", "uv"],
				uniforms: ["time", "worldViewProjection"]
			}
		);
		box.material = shaderMaterial;
		//----------------------------------------
		var shaderMaterial2 = new ShaderMaterial("shader2", scene, {
				vertex: "custom",
				fragment: "custom2",
			}, {
				attributes: ["position", "normal", "uv"],
				uniforms: ["time", "worldViewProjection"]
			}
		);
		box2.material = shaderMaterial2;
		box2.material.backFaceCulling = false;
		//----------------------------------------
		var shaderMaterial3 = new ShaderMaterial("shader3", scene, {
				vertex: "custom",
				fragment: "custom3",
			}, {
				attributes: ["position", "normal", "uv"],
				uniforms: ["time", "worldViewProjection"]
			}
		);
		box3.material = shaderMaterial3;
		//----------------------------------------
		var shaderMaterial4 = new ShaderMaterial("shader4", scene, {
				vertex: "custom",
				fragment: "custom4",
			}, {
				attributes: ["position", "normal", "uv"],
				uniforms: ["time", "worldViewProjection"]
			}
		);
		box4.material = shaderMaterial4;
		//----------------------------------------
		var shaderMaterial5 = new ShaderMaterial("shader5", scene, {
				vertex: "custom",
				fragment: "custom5",
			}, {
				attributes: ["position", "normal", "uv"],
				uniforms: ["time", "worldViewProjection"]
			}
		);
		box5.material = shaderMaterial5;
		//----------------------------------------
		var shaderMaterial6 = new ShaderMaterial("shader6", scene, {
				vertex: "custom",
				fragment: "custom6",
			}, {
				attributes: ["position", "normal", "uv"],
				uniforms: ["time", "worldViewProjection"]
			}
		);
		box6.material = shaderMaterial6;
		//----------------------------------------
		var shaderMaterial7 = new ShaderMaterial("shader7", scene, {
				vertex: "custom",
				fragment: "custom7",
			}, {
				attributes: ["position", "normal", "uv"],
				uniforms: ["time", "worldViewProjection"]
			}
		);
		box7.material = shaderMaterial7;
		//----------------------------------------
		var shaderMaterial8 = new ShaderMaterial("shader8", scene, {
				vertex: "custom",
				fragment: "custom8",
			}, {
				attributes: ["position", "normal", "uv"],
				uniforms: ["time", "worldViewProjection"]
			}
		);
		box8.material = shaderMaterial8;
		//----------------------------------------
		var shaderMaterial9 = new ShaderMaterial("shader9", scene, {
				vertex: "custom",
				fragment: "custom9",
			}, {
				attributes: ["position", "normal", "uv"],
				uniforms: ["time", "worldViewProjection"]
			}
		);
		box9.material = shaderMaterial9;
		box9.material.backFaceCulling = false;
		//----------------------------------------
		
		var time = 0.0;
		scene.registerBeforeRender(function(_, _) {
			shaderMaterial.setFloat("time", time);
			shaderMaterial2.setFloat("time", time);
			shaderMaterial3.setFloat("time", time);
			shaderMaterial4.setFloat("time", time);
			shaderMaterial5.setFloat("time", time);
			shaderMaterial6.setFloat("time", time);
			shaderMaterial7.setFloat("time", time);
			shaderMaterial9.setFloat("time", time);
			time = time + .01;
		});
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}