package com.babylonhx.shaderbuilder;

import com.babylonhx.Scene;
import com.babylonhx.cameras.Camera;
import com.babylonhx.math.Vector3;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.ShaderMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.postprocess.PostProcess;

/**
 * ...
 * @author Krtolica Vujadin
 */
class ShaderBuilder {

	public var Parent:ShaderBuilder;
	public var Setting:ShaderSetting;
	public var CustomIndexer:Int;
	public var Fragment:Array<String>;
	public var Vertex:Array<String>; 
	
	public var FragmentBeforeMain:String = "";
	public var VertexBeforeMain:String = "";
	public var Varings:Array<String>;
	public var Attributes:Array<String>;
	public var Uniforms:Array<String>;
	public var FragmentUniforms:String = "";
	public var VertexUniforms:String = "";
	public var Extentions:Array<String>;
	public var References:String = "";
	public var Helpers:Array<String>;
	public var Body:String = "";
	public var VertexBody:String = "";
	public var AfterVertex:String = "";
	public var RenderTargetForColorId:String = "";
	public var PPSSamplers:Array<String>;
	public var RenderTargetForDepth:String;

	public var PostEffect1Effects:Array<String>;
	public var PostEffect2Effects:Array<String>;	
	
	static var ColorIdRenderTarget:Dynamic;
	

	static public function InitializePostEffects(scene:Scene, scale:Float) {
		ShaderBuilder.ColorIdRenderTarget = ShaderMaterialHelper.DefineRenderTarget("ColorId", scale, scene);
	}

	public function PrepareBeforeMaterialBuild() {
		this.Setting = Shader.Me.Setting;
		
		this.Attributes.push(ShaderMaterialHelperStatics.AttrPosition);
		this.Attributes.push(ShaderMaterialHelperStatics.AttrNormal);
		if (this.Setting.Uv) {
			this.Attributes.push(ShaderMaterialHelperStatics.AttrUv);
		}
		if (this.Setting.Uv2) {
			this.Attributes.push(ShaderMaterialHelperStatics.AttrUv2);
		}
		
		this.Uniforms.push(ShaderMaterialHelperStatics.uniformView);
		this.Uniforms.push(ShaderMaterialHelperStatics.uniformWorld);
		this.Uniforms.push(ShaderMaterialHelperStatics.uniformWorldView);
		this.Uniforms.push(ShaderMaterialHelperStatics.uniformViewProjection);
		this.Uniforms.push(ShaderMaterialHelperStatics.uniformWorldViewProjection);
		
		// start Build Vertex Frame 
		this.Vertex.push("precision " + this.Setting.PrecisionMode + " float;");
		this.Vertex.push("attribute " + ShaderMaterialHelperStatics.AttrTypeForPosition + " " + ShaderMaterialHelperStatics.AttrPosition + ";");
		this.Vertex.push("attribute " + ShaderMaterialHelperStatics.AttrTypeForNormal + " " + ShaderMaterialHelperStatics.AttrNormal + ";");
		
		if (this.Setting.Uv) {
			this.Vertex.push("attribute " + ShaderMaterialHelperStatics.AttrTypeForUv + " " + ShaderMaterialHelperStatics.AttrUv + ";");
			
			this.Vertex.push("varying vec2 " + ShaderMaterialHelperStatics.Uv + ";");
		}
		if (this.Setting.Uv2) {
			this.Vertex.push("attribute " + ShaderMaterialHelperStatics.AttrTypeForUv2 + " " + ShaderMaterialHelperStatics.AttrUv2 + ";");
			
			this.Vertex.push("varying vec2 " + ShaderMaterialHelperStatics.Uv2 + ";");
		}
		
		this.Vertex.push("varying vec3 " + ShaderMaterialHelperStatics.Position + ";");
		this.Vertex.push("varying vec3 " + ShaderMaterialHelperStatics.Normal + ";");
		
		this.Vertex.push("uniform   " + ShaderMaterialHelperStatics.uniformStandardType + ' ' + ShaderMaterialHelperStatics.uniformWorldViewProjection + ";");
		if (this.Setting.VertexView) {
			this.Vertex.push("uniform   " + ShaderMaterialHelperStatics.uniformStandardType + ' ' + ShaderMaterialHelperStatics.uniformView + ";");
		}
		
		if (this.Setting.VertexWorld) {
			this.Vertex.push("uniform   " + ShaderMaterialHelperStatics.uniformStandardType + ' ' + ShaderMaterialHelperStatics.uniformWorld + ";");
		}
		
		if (this.Setting.VertexViewProjection) {
			this.Vertex.push("uniform   " + ShaderMaterialHelperStatics.uniformStandardType + ' ' + ShaderMaterialHelperStatics.uniformViewProjection + ";");
		}
		
		if (this.Setting.Flags) {
			this.Uniforms.push(ShaderMaterialHelperStatics.uniformFlags);
			
			this.Vertex.push("uniform  float " + ShaderMaterialHelperStatics.uniformFlags + ";");
		}
		
		if (this.Setting.VertexWorldView) {
			this.Vertex.push("uniform   " + ShaderMaterialHelperStatics.uniformStandardType + ' ' + ShaderMaterialHelperStatics.uniformWorldView + ";");
		}
		
		if (this.VertexUniforms != null) {
			this.Vertex.push(this.VertexUniforms);
		}
		
		/*#extension GL_OES_standard_derivatives : enable*/
		this.Fragment.push("precision " + this.Setting.PrecisionMode + " float;\n#extension GL_OES_standard_derivatives : enable\n\n\n");
		
		if (this.Setting.Uv) {
			this.Fragment.push("varying vec2 " + ShaderMaterialHelperStatics.Uv + ";");
		}
		if (this.Setting.Uv2) {
			this.Fragment.push("varying vec2 " + ShaderMaterialHelperStatics.Uv2 + ";");
		}
		
		if (this.Setting.FragmentView) {
			this.Fragment.push("uniform   " + ShaderMaterialHelperStatics.uniformStandardType + ' ' + ShaderMaterialHelperStatics.uniformView + ";");
		}
		
		if (this.Setting.FragmentWorld) {
			this.Fragment.push("uniform   " + ShaderMaterialHelperStatics.uniformStandardType + ' ' + ShaderMaterialHelperStatics.uniformWorld + ";");
		}
		
		if (this.Setting.FragmentViewProjection) {
			this.Fragment.push("uniform   " + ShaderMaterialHelperStatics.uniformStandardType + ' ' + ShaderMaterialHelperStatics.uniformViewProjection + ";");
		}
		
		if (this.Setting.FragmentWorldView) {
			this.Fragment.push("uniform   " + ShaderMaterialHelperStatics.uniformStandardType + ' ' + ShaderMaterialHelperStatics.uniformWorldView + ";");
		}
		
		if (this.Setting.Flags) {
			this.Fragment.push("uniform  float " + ShaderMaterialHelperStatics.uniformFlags + ";");
		}
		
		if (this.FragmentUniforms != null) {
			this.Fragment.push(this.FragmentUniforms);
		}
		this.Fragment.push("varying vec3 " + ShaderMaterialHelperStatics.Position + ";");
		this.Fragment.push("varying vec3 " + ShaderMaterialHelperStatics.Normal + ";");
		
		if (this.Setting.WorldPosition) {
			this.Vertex.push("varying vec3 " + ShaderMaterialHelperStatics.WorldPosition + ";");
			this.Vertex.push("varying vec3 " + ShaderMaterialHelperStatics.WorldNormal + ";");
			
			this.Fragment.push("varying vec3 " + ShaderMaterialHelperStatics.WorldPosition + ";");
			this.Fragment.push("varying vec3 " + ShaderMaterialHelperStatics.WorldNormal + ";");
		}
		
		if (this.Setting.Texture2Ds != null) {
			for (s in 0...this.Setting.Texture2Ds.length) {
				if (this.Setting.Texture2Ds[s] != null && this.Setting.Texture2Ds[s].inVertex) {
					this.Vertex.push("uniform  sampler2D " + ShaderMaterialHelperStatics.Texture2D + s + ";");
				}
				if (this.Setting.Texture2Ds[s] != null && this.Setting.Texture2Ds[s].inFragment) {
					this.Fragment.push("uniform  sampler2D  " + ShaderMaterialHelperStatics.Texture2D + s + ";");
				}
			}
		}
		
		if (this.Setting.CameraShot) {
			this.Fragment.push("uniform  sampler2D  textureSampler;");
		}
		
		if (this.Setting.TextureCubes != null) {
			for (s in 0...this.Setting.TextureCubes.length) {
				if (this.Setting.TextureCubes[s] != null && this.Setting.TextureCubes[s].inVertex) {
					this.Vertex.push("uniform  samplerCube  " + ShaderMaterialHelperStatics.TextureCube + s + ";");
				}
				if (this.Setting.TextureCubes[s] != null && this.Setting.TextureCubes[s].inFragment) {
					this.Fragment.push("uniform  samplerCube   " + ShaderMaterialHelperStatics.TextureCube + s + ";");
				}
			}
		}
		
		if (this.Setting.Center) {
			this.Vertex.push("uniform  vec3 " + ShaderMaterialHelperStatics.Center + ";");
			this.Fragment.push("uniform  vec3 " + ShaderMaterialHelperStatics.Center + ";");
		}
		if (this.Setting.Mouse) {
			this.Vertex.push("uniform  vec2 " + ShaderMaterialHelperStatics.Mouse + ";");
			this.Fragment.push("uniform  vec2 " + ShaderMaterialHelperStatics.Mouse + ";");
		}
		if (this.Setting.Screen) {
			this.Vertex.push("uniform  vec2 " + ShaderMaterialHelperStatics.Screen + ";");
			this.Fragment.push("uniform  vec2 " + ShaderMaterialHelperStatics.Screen + ";");
		}
		if (this.Setting.Camera) {
			this.Vertex.push("uniform  vec3 " + ShaderMaterialHelperStatics.Camera + ";");
			this.Fragment.push("uniform  vec3 " + ShaderMaterialHelperStatics.Camera + ";");
		}
		if (this.Setting.Look) {
			this.Vertex.push("uniform  vec3 " + ShaderMaterialHelperStatics.Look + ";");
			this.Fragment.push("uniform  vec3 " + ShaderMaterialHelperStatics.Look + ";");
		}
		if (this.Setting.Time) {
			this.Vertex.push("uniform  float " + ShaderMaterialHelperStatics.Time + ";");
			this.Fragment.push("uniform  float " + ShaderMaterialHelperStatics.Time + ";");
		}
		if (this.Setting.GlobalTime) {
			this.Vertex.push("uniform  vec4 " + ShaderMaterialHelperStatics.GlobalTime + ";");
			this.Fragment.push("uniform  vec4 " + ShaderMaterialHelperStatics.GlobalTime + ";");
		}
		if (this.Setting.ReflectMatrix) {
			this.Vertex.push("uniform  mat4 " + ShaderMaterialHelperStatics.ReflectMatrix + ";");
			this.Fragment.push("uniform  mat4 " + ShaderMaterialHelperStatics.ReflectMatrix + ";");
		}
		if (this.Setting.Helpers) {
			var sresult = Shader.Join([
				"vec3 random3(vec3 c) {   float j = 4096.0*sin(dot(c,vec3(17.0, 59.4, 15.0)));   vec3 r;   r.z = fract(512.0*j); j *= .125;  r.x = fract(512.0*j); j *= .125; r.y = fract(512.0*j);  return r-0.5;  } ",
				"float rand(vec2 co){   return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453); } ",
				"const float F3 =  0.3333333;const float G3 =  0.1666667;",
				"float simplex3d(vec3 p) {   vec3 s = floor(p + dot(p, vec3(F3)));   vec3 x = p - s + dot(s, vec3(G3));  vec3 e = step(vec3(0.0), x - x.yzx);  vec3 i1 = e*(1.0 - e.zxy);  vec3 i2 = 1.0 - e.zxy*(1.0 - e);   vec3 x1 = x - i1 + G3;   vec3 x2 = x - i2 + 2.0*G3;   vec3 x3 = x - 1.0 + 3.0*G3;   vec4 w, d;    w.x = dot(x, x);   w.y = dot(x1, x1);  w.z = dot(x2, x2);  w.w = dot(x3, x3);   w = max(0.6 - w, 0.0);   d.x = dot(random3(s), x);   d.y = dot(random3(s + i1), x1);   d.z = dot(random3(s + i2), x2);  d.w = dot(random3(s + 1.0), x3);  w *= w;   w *= w;  d *= w;   return dot(d, vec4(52.0));     }  ",
				"float noise(vec3 m) {  return   0.5333333*simplex3d(m)   +0.2666667*simplex3d(2.0*m) +0.1333333*simplex3d(4.0*m) +0.0666667*simplex3d(8.0*m);   } ",
				"float dim(vec3 p1 , vec3 p2){   return sqrt((p2.x-p1.x)*(p2.x-p1.x)+(p2.y-p1.y)*(p2.y-p1.y)+(p2.z-p1.z)*(p2.z-p1.z)); }",
				"vec2  rotate_xy(vec2 pr1,vec2  pr2,float alpha) {vec2 pp2 = vec2( pr2.x - pr1.x,   pr2.y - pr1.y );return  vec2( pr1.x + pp2.x * cos(alpha*3.14159265/180.) - pp2.y * sin(alpha*3.14159265/180.),pr1.y + pp2.x * sin(alpha*3.14159265/180.) + pp2.y * cos(alpha*3.14159265/180.));} \n vec3  r_y(vec3 n, float a,vec3 c) {vec3 c1 = vec3( c.x,  c.y,   c.z );c1.x = c1.x;c1.y = c1.z;vec2 p = rotate_xy(vec2(c1.x,c1.y), vec2( n.x,  n.z ), a);n.x = p.x;n.z = p.y;return n; } \n vec3  r_x(vec3 n, float a,vec3 c) {vec3 c1 = vec3( c.x,  c.y,   c.z );c1.x = c1.y;c1.y = c1.z;vec2 p = rotate_xy(vec2(c1.x,c1.y), vec2( n.y,  n.z ), a);n.y = p.x;n.z = p.y;return n; } \n vec3  r_z(vec3 n, float a,vec3 c) {  vec3 c1 = vec3( c.x,  c.y,   c.z );vec2 p = rotate_xy(vec2(c1.x,c1.y), vec2( n.x,  n.y ), a);n.x = p.x;n.y = p.y;return n; }"
				//"vec3 sundir(float da,float db,vec3 ps){ float h = floor(floor(" + ShaderMaterialHelperStatics.GlobalTime + ".y/100.)/100.);float m =     floor(" + ShaderMaterialHelperStatics.GlobalTime + ".y/100.) - h*100.;float s =      " + ShaderMaterialHelperStatics.GlobalTime + ".y  - h*10000. -m*100.;float si = s *100./60.;float mi = m*100./60.;float hi = h+mi/100.+si/10000.;float dm = 180./(db-da); vec3  gp = vec3(ps.x,ps.y,ps.z);gp = r_z(gp,  dm* hi -da*dm -90. ,vec3(0.));gp = r_x(gp,40. ,vec3(0.)); gp.x = gp.x*-1.; gp.z = gp.z*-1.; return gp; }",
			]);
			
			this.Vertex.push(sresult);
			this.Fragment.push(sresult);
		}
		
		this.Vertex.push("void main(void) { \n" + ShaderMaterialHelperStatics.Position + " = " + ShaderMaterialHelperStatics.AttrPosition + "; \n" + ShaderMaterialHelperStatics.Normal + " = " + ShaderMaterialHelperStatics.AttrNormal + "; \nvec4 result = vec4(" + ShaderMaterialHelperStatics.Position + ",1.);  \n  vuv = uv;\n #[Source]\ngl_Position = worldViewProjection * result;\n#[AfterFinishVertex] \n}");
		
		// start Build Fragment Frame 
		if (this.Setting.NormalMap != null) {
			this.Fragment.push("vec3 normalMap() { vec4 result = vec4(0.); " + this.Setting.NormalMap + "; \nresult = vec4( normalize( "+ this.Setting.Normal + " -(normalize(result.xyz)*2.0-vec3(1.))*(max(-0.5,min(0.5," + Shader.Print(this.Setting.NormalOpacity) + ")) )),1.0); return result.xyz;}");
		}
		
		if (this.Setting.SpecularMap != null) {
			this.Fragment.push("float specularMap() { vec4 result = vec4(0.);float float_result = 0.; " + this.Setting.SpecularMap + " return float_result ;}");
		}
		
		this.Fragment.push(this.FragmentBeforeMain);
		
		this.Fragment.push(" \nvoid main(void) { \n int discardState = 0;\n vec4 result = vec4(0.);\n #[Source] \n if(discardState == 0)gl_FragColor = result; \n}");
	}

	public function PrepareBeforePostProcessBuild() {
		this.Setting = Shader.Me.Setting;
		
		this.Attributes.push(ShaderMaterialHelperStatics.AttrPosition);
		
		// start Build Vertex Frame 
		
		/*#extension GL_OES_standard_derivatives : enable*/
		this.Fragment.push("precision " + this.Setting.PrecisionMode + " float;\n\n");
		
		if (this.Setting.Uv) {
			this.Fragment.push("varying vec2 vUV;");
		}
		
		if (this.Setting.Flags) {
			this.Fragment.push("uniform  float " + ShaderMaterialHelperStatics.uniformFlags + ";");
		}
		
		if (this.Setting.Texture2Ds != null) {
			for (s in 0...this.Setting.Texture2Ds.length) {
				if (this.Setting.Texture2Ds[s].inFragment) {
					this.Fragment.push("uniform  sampler2D  " + ShaderMaterialHelperStatics.Texture2D + s + ";");
				}
			}
		}
		
		if (this.PPSSamplers != null) {
			for (s in 0...this.PPSSamplers.length) {
				if (this.PPSSamplers[s] != null && this.PPSSamplers[s] != "") {
					this.Fragment.push("uniform  sampler2D  " + this.PPSSamplers[s] + ";");
				}
			}
		}
		
		if (this.Setting.CameraShot) {
			this.Fragment.push("uniform  sampler2D  textureSampler;");
		}
		
		if (this.Setting.Mouse) {
			this.Fragment.push("uniform  vec2 " + ShaderMaterialHelperStatics.Mouse + ";");
		}
		if (this.Setting.Screen) {
			this.Fragment.push("uniform  vec2 " + ShaderMaterialHelperStatics.Screen + ";");
		}
		if (this.Setting.Camera) {
			this.Fragment.push("uniform  vec3 " + ShaderMaterialHelperStatics.Camera + ";");
		}
		if (this.Setting.Look) {
			this.Fragment.push("uniform  vec3 " + ShaderMaterialHelperStatics.Look + ";");
		}
		if (this.Setting.Time) {
			this.Fragment.push("uniform  float " + ShaderMaterialHelperStatics.Time + ";");
		}
		if (this.Setting.GlobalTime) {
			this.Fragment.push("uniform  vec4 " + ShaderMaterialHelperStatics.GlobalTime + ";");
		}
		
		if (this.Setting.Helpers) {
			var sresult = Shader.Join([
				"vec3 random3(vec3 c) {   float j = 4096.0*sin(dot(c,vec3(17.0, 59.4, 15.0)));   vec3 r;   r.z = fract(512.0*j); j *= .125;  r.x = fract(512.0*j); j *= .125; r.y = fract(512.0*j);  return r-0.5;  } ",
				"float rand(vec2 co){   return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453); } ",
				"const float F3 =  0.3333333;const float G3 =  0.1666667;",
				"float simplex3d(vec3 p) {   vec3 s = floor(p + dot(p, vec3(F3)));   vec3 x = p - s + dot(s, vec3(G3));  vec3 e = step(vec3(0.0), x - x.yzx);  vec3 i1 = e*(1.0 - e.zxy);  vec3 i2 = 1.0 - e.zxy*(1.0 - e);   vec3 x1 = x - i1 + G3;   vec3 x2 = x - i2 + 2.0*G3;   vec3 x3 = x - 1.0 + 3.0*G3;   vec4 w, d;    w.x = dot(x, x);   w.y = dot(x1, x1);  w.z = dot(x2, x2);  w.w = dot(x3, x3);   w = max(0.6 - w, 0.0);   d.x = dot(random3(s), x);   d.y = dot(random3(s + i1), x1);   d.z = dot(random3(s + i2), x2);  d.w = dot(random3(s + 1.0), x3);  w *= w;   w *= w;  d *= w;   return dot(d, vec4(52.0));     }  ",
				"float noise(vec3 m) {  return   0.5333333*simplex3d(m)   +0.2666667*simplex3d(2.0*m) +0.1333333*simplex3d(4.0*m) +0.0666667*simplex3d(8.0*m);   } ",
				"vec2  rotate_xy(vec2 pr1,vec2  pr2,float alpha) {vec2 pp2 = vec2( pr2.x - pr1.x,   pr2.y - pr1.y );return  vec2( pr1.x + pp2.x * cos(alpha*3.14159265/180.) - pp2.y * sin(alpha*3.14159265/180.),pr1.y + pp2.x * sin(alpha*3.14159265/180.) + pp2.y * cos(alpha*3.14159265/180.));} \n vec3  r_y(vec3 n, float a,vec3 c) {vec3 c1 = vec3( c.x,  c.y,   c.z );c1.x = c1.x;c1.y = c1.z;vec2 p = rotate_xy(vec2(c1.x,c1.y), vec2( n.x,  n.z ), a);n.x = p.x;n.z = p.y;return n; } \n vec3  r_x(vec3 n, float a,vec3 c) {vec3 c1 = vec3( c.x,  c.y,   c.z );c1.x = c1.y;c1.y = c1.z;vec2 p = rotate_xy(vec2(c1.x,c1.y), vec2( n.y,  n.z ), a);n.y = p.x;n.z = p.y;return n; } \n vec3  r_z(vec3 n, float a,vec3 c) {  vec3 c1 = vec3( c.x,  c.y,   c.z );vec2 p = rotate_xy(vec2(c1.x,c1.y), vec2( n.x,  n.y ), a);n.x = p.x;n.y = p.y;return n; }",
				"float getIdColor(vec4 a){    float b = 255.;float c = 255. / b;float x = floor(a.x*256. / c);float y = floor(a.y *256./ c);float z = floor(a.z*256. / c);return z * b * b + y * b + x;}"
				//"vec3 sundir(float da,float db,vec3 ps){ float h = floor(floor(" + ShaderMaterialHelperStatics.GlobalTime + ".y/100.)/100.);float m =     floor(" + ShaderMaterialHelperStatics.GlobalTime + ".y/100.) - h*100.;float s =      " + ShaderMaterialHelperStatics.GlobalTime + ".y  - h*10000. -m*100.;float si = s *100./60.;float mi = m*100./60.;float hi = h+mi/100.+si/10000.;float dm = 180./(db-da); vec3  gp = vec3(ps.x,ps.y,ps.z);gp = r_z(gp,  dm* hi -da*dm -90. ,vec3(0.));gp = r_x(gp,40. ,vec3(0.)); gp.x = gp.x*-1.; gp.z = gp.z*-1.; return gp; }",
			]);
			
			this.Fragment.push(sresult);
		}
		
		if (this.Setting.NormalMap != null && this.Setting.NormalMap != "") {
			this.Fragment.push("vec3 normalMap() { vec4 result = vec4(0.);   return result.xyz;}");
		}
		
		// start Build Fragment Frame  
		
		this.Fragment.push(this.FragmentBeforeMain);
		
		this.Fragment.push(" \nvoid main(void) { \n int discardState = 0;\n vec2 vuv = vUV;\n vec3 center = vec3(0.);\n vec4 result = vec4(0.);\n #[Source] \n if(discardState == 0)gl_FragColor = result; \n}");
	}

	public function PrepareMaterial(material:ShaderMaterial, scene:Scene):ShaderMaterial {
		material.shaderSetting = this.Setting;
		
		if (!this.Setting.Transparency) {
			material._options.needAlphaBlending = false;
		}
		else {
			material._options.needAlphaBlending = true;
		}
		if (!this.Setting.Back) {
			this.Setting.Back = false;
		}
		
		material._options.needAlphaTesting = true;
		
		material.setVector3("camera", new Vector3(18.0, 18.0, 18.0));
		
		material.backFaceCulling = !this.Setting.Back;
		material.wireframe = this.Setting.Wire;
		
		material.setFlags = function (flags:Array<String>) {
			if (material.shaderSetting.Flags) {
				var s = 0.0;
				for (i in 0...20) {
					if (flags.length > i && flags[i] == '1') {
						s += Math.pow(2.0, i);
					}
				}
				material.flagNumber = s;
				material.setFloat(ShaderMaterialHelperStatics.uniformFlags, s);
			}
		};
		
		material.flagNumber = 0.0;
		
		material.flagUp = function (flag:Float) {
			if (material.shaderSetting.Flags) {
				if (Math.floor((material.flagNumber / Math.pow(2.0, flag) % 2.0)) != 1.0) {
					material.flagNumber += Math.pow(2.0, flag);
				}
				
				material.setFloat(ShaderMaterialHelperStatics.uniformFlags, material.flagNumber);
			}
		};
		
		material.flagDown = function (flag:Float) {
			if (material.shaderSetting.Flags) {
				if (Math.floor((material.flagNumber / Math.pow(2.0, flag) % 2.0)) == 1.0) {
					material.flagNumber -= Math.pow(2.0, flag);
				}
				
				material.setFloat(ShaderMaterialHelperStatics.uniformFlags, material.flagNumber);
			}
		};
		
		material.onCompiled = function (effect:Effect) { };
		
		if (this.Setting.Texture2Ds != null) {
			for (s in 0...this.Setting.Texture2Ds.length) {
				// setTexture2D
				var texture:Texture = ShaderMaterialHelper.DefineTexture(this.Setting.Texture2Ds[s].key, scene);
				material.setTexture(ShaderMaterialHelperStatics.Texture2D + s, texture);
			}
		}
		
		if (this.Setting.TextureCubes != null) {
			for (s in 0...this.Setting.TextureCubes.length) {
				// setTexture2D
				var texture:CubeTexture = ShaderMaterialHelper.DefineCubeTexture(this.Setting.TextureCubes[s].key, scene);
				material.setTexture(ShaderMaterialHelperStatics.TextureCube + s, cast texture);
				material.setMatrix(ShaderMaterialHelperStatics.ReflectMatrix, texture.getReflectionTextureMatrix());
			}
		}
		
		Shader.Me = null;
		
		return material;
	}

	public function Build():String {
		Shader.Me.Parent.Setting = Shader.Me.Setting;
		Shader.Me = Shader.Me.Parent;
		
		return this.Body;
	}

	public function BuildVertex():String {
		Shader.Me.Parent.Setting = Shader.Me.Setting;
		Shader.Me = Shader.Me.Parent;
		
		return this.VertexBody;
	}

	public function SetUniform(name:String, type:String):ShaderBuilder {
		if (Shader.Me.VertexUniforms == null) {
			Shader.Me.VertexUniforms = "";
		}
		if (Shader.Me.FragmentUniforms == null) {
			Shader.Me.FragmentUniforms = "";
		}
		
		this.VertexUniforms += 'uniform ' + type + ' ' + name + ';\n';
		this.FragmentUniforms += 'uniform ' + type + ' ' + name + ';\n';
		
		return this;
	}

	public function BuildMaterial(scene:Scene):ShaderMaterial {
		this.PrepareBeforeMaterialBuild();
		
		Shader.ShaderIdentity++;
		
		var shaderMaterial = ShaderMaterialHelper.ShaderMaterial("ShaderBuilder_" + Shader.ShaderIdentity, scene, {
			Pixel: StringTools.replace(Shader.Join(this.Fragment), "#[Source]", this.Body),
			Vertex: StringTools.replace(StringTools.replace(Shader.Join(this.Vertex), "#[Source]", Shader.Def(this.VertexBody, "")), "#[AfterFinishVertex]", Shader.Def(this.AfterVertex, ""))
		}, 
		{
			uniforms: this.Uniforms,
			attributes: this.Attributes
		});
		
		Shader.Indexer = 1;
		
		return this.PrepareMaterial(shaderMaterial, scene);
	}

	public function BuildPostProcess(camera:Camera, scene:Scene, scale:Float, option:IPostProcess):PostProcess {
		this.Setting.Screen = true;
		this.Setting.Mouse = true;
		this.Setting.Time = true;
		this.Setting.CameraShot = true;
		
		this.PrepareBeforePostProcessBuild();
		
		Shader.ShaderIdentity++;
		var samplers:Array<String> = [];
		for (s in 0...this.Setting.Texture2Ds.length) {
			samplers.push(ShaderMaterialHelperStatics.Texture2D + s);
		}
		
		if (this.PPSSamplers != null) {
			for (s in 0...this.PPSSamplers.length) {
				if (this.PPSSamplers[s] != null) {
					samplers.push(this.PPSSamplers[s]);
				}
			}
		}
		
		var shaderPps = ShaderMaterialHelper.ShaderPostProcess(
			"ShaderBuilder_" + Shader.ShaderIdentity
			, samplers, camera, scale,
			{
				Pixel: StringTools.replace(Shader.Join(this.Fragment), "#[Source]", this.Body),
				Vertex: StringTools.replace(StringTools.replace(Shader.Join(this.Vertex), "#[Source]", Shader.Def(this.VertexBody, "")), "#[AfterFinishVertex]", Shader.Def(this.AfterVertex, ""))
			}, 
			{
				uniforms: this.Uniforms,
				attributes: this.Attributes
			}, 
			option
		);
		
		if (this.Setting.Texture2Ds != null) {
			for (s in 0...this.Setting.Texture2Ds.length) {
				// setTexture2D
				var texture = ShaderMaterialHelper.DefineTexture(this.Setting.Texture2Ds[s].key, scene);
				ShaderMaterialHelper.PostProcessTextures(shaderPps, ShaderMaterialHelperStatics.Texture2D + s, texture);
			}
		}
		
		return shaderPps;
	}

	public function Event(index:Int, mat:String):ShaderBuilder {
		Shader.Me.Setting.Flags = true;
		
		Shader.Indexer++;
		
		this.Body = Shader.Def(this.Body, "");
		this.Body += "  if ( floor(mod( " + ShaderMaterialHelperStatics.uniformFlags + "/pow(2.," + Shader.Print(index) + "),2.)) == 1.) { " + mat + " } ";
		
		return this;
	}

	public function EventVertex(index:Int, mat:String):ShaderBuilder {
		Shader.Me.Setting.Flags = true;
		Shader.Me.Setting.Vertex = true;
		Shader.Indexer++;
		
		this.VertexBody = Shader.Def(this.VertexBody, "");
		this.VertexBody += " if( floor(mod( " + ShaderMaterialHelperStatics.uniformFlags + "/pow(2.," + Shader.Print(index) + "),2.)) == 1. ){ " + mat + "}";
		
		return this;
	}

	public function Transparency():ShaderBuilder {
		Shader.Me.Setting.Transparency = true;
		
		return this;
	}

	public function PostEffect1(id:Int, effect:String):ShaderBuilder {
		if (Shader.Me.PostEffect1Effects == null) {
			Shader.Me.PostEffect1Effects = [];
		}
		Shader.Me.PostEffect1Effects[id] = effect;
		
		return this;
	}

	public function PostEffect2(id:Int, effect:String):ShaderBuilder {
		if (Shader.Me.PostEffect2Effects == null) {
			Shader.Me.PostEffect2Effects = [];
		}
		Shader.Me.PostEffect2Effects[id] = effect;
		
		return this;
	}

	public function ImportSamplers(txts:Array<String>):ShaderBuilder {
		if (Shader.Me.PPSSamplers == null) {
			Shader.Me.PPSSamplers = [];
		}
		for (s in 0...txts.length) {
			Shader.Me.PPSSamplers.push(txts[s]);
		}
		
		return this;
	}

	public function Wired():ShaderBuilder {
		Shader.Me.Setting.Wire = true;
		
		return this;
	}

	public function VertexShader(mat:String):ShaderBuilder {
		this.VertexBody = Shader.Def(this.VertexBody, "");
		this.VertexBody += mat;
		
		return this;
	}

	public function Solid(color:Dynamic/*IColor*/) {
		color = Shader.Def(color, { r: 0.0, g: 0.0, b: 0.0, a: 1.0 });
		color.a = Shader.Def(color.a, 1.0);
		color.r = Shader.Def(color.r, 0.0);
		color.g = Shader.Def(color.g, 0.0);
		color.b = Shader.Def(color.b, 0.0);
		
		this.Body = Shader.Def(this.Body, "");
		this.Body += " result = vec4(" + Shader.Print(color.r) + "," + Shader.Print(color.g) + "," + Shader.Print(color.b) + "," + Shader.Print(color.a) + ");";
		
		return this;
	}

	public function GetMapIndex(key:String):Int {
		if (Shader.Me.Setting.Texture2Ds != null) {
			for (it in 0...Shader.Me.Setting.Texture2Ds.length) {
				if (Shader.Me.Setting.Texture2Ds[it] != null && Shader.Me.Setting.Texture2Ds[it].key == key) {
					return it;
				}
			}
		}
		else {
			Shader.Me.Setting.Texture2Ds = [];
		}
		
		return -1;
	}

	public function GetCubeMapIndex(key:String):Int {
		if (Shader.Me.Setting.TextureCubes != null) {
			for (it in 0...Shader.Me.Setting.TextureCubes.length) {
				if (this.Setting.TextureCubes[it].key == key) {
					return it;
				}
			}
		}
		else {
			Shader.Me.Setting.TextureCubes = [];
		}
		
		return -1;
	}

	public function Func(fun:ShaderBuilder->Dynamic):Dynamic {
		return fun(Shader.Me);
	}

	public function Nut(value:String, option:INut):ShaderBuilder {
		Shader.Indexer++;
		option = Shader.Def(option, {});
		option.frame = Shader.Def(option.frame, 'sin(time*0.4)');
		
		var sresult:String = Shader.Join([
			"float nut#[Ind]= " + Shader.Print(value) + ";",
			"float nut_ts#[Ind] = " + Shader.Print(option.frame) + ";",
			this.Func(function (me) {
				var f:Array<String> = [];
				for (i in 0...option.bones.length) {
					f.push('vec3 nut_p#[Ind]_' + i + ' = ' + option.bones[i].center + ';');
				}
				
				return Shader.Join(f);
			}),
			this.Func(function (me) {
				var f:Array<String> = [];
				for (i in 0...option.bones.length) {
					f.push('if(nut#[Ind] ' + option.bones[i].bet + '){ ');
					
					for (j in 0...option.array.length) {
						if (option.bones[i].rotation.x != 0) {
							f.push(option.array[j] + ' = r_x(' + option.array[j] +
								',nut_ts#[Ind]*' + Shader.Print(option.bones[i].rotation.x)
								+ ',nut_p#[Ind]_' + i + ');');
							for (v in i + 1...option.bones.length) {
								f.push('nut_p#[Ind]_' + v + ' = r_x(nut_p#[Ind]_' + v +
									',nut_ts#[Ind]*' + Shader.Print(option.bones[i].rotation.x)
									+ ',nut_p#[Ind]_' + i + ');');
							}
						}
						
						if (option.bones[i].rotation.y != 0) {
							f.push(option.array[j] + ' = r_y(' + option.array[j] + ',nut_ts#[Ind]*' + Shader.Print(option.bones[i].rotation.y) + ',nut_p#[Ind]_' + i + ');');
							for (v in i + 1...option.bones.length) {
								f.push('nut_p#[Ind]_' + v + ' = r_y(nut_p#[Ind]_' + v + ',nut_ts#[Ind]*' + Shader.Print(option.bones[i].rotation.y) + ',nut_p#[Ind]_' + i + ');');
							}
						}
						
						if (option.bones[i].rotation.z != 0) {
							f.push(option.array[j] + ' = r_z(' + option.array[j] + ',nut_ts#[Ind]*' + Shader.Print(option.bones[i].rotation.z) + ',nut_p#[Ind]_' + i + ');');
							for (v in i + 1...option.bones.length) {
								f.push('nut_p#[Ind]_' + v + ' = r_z(nut_p#[Ind]_' + v + ',nut_ts#[Ind]*' + Shader.Print(option.bones[i].rotation.z) + ',nut_p#[Ind]_' + i + ');');
							}
						}
					}
					
					f.push('}');
				}
				
				return Shader.Join(f);
			})
		]);
		
		this.VertexBody = Shader.Def(this.VertexBody, "");
		sresult = Shader.Replace(sresult, '#[Ind]', Std.string(Shader.Indexer)) + " result = vec4(pos,1.);";
		this.VertexBody += sresult;
		
		return this;
	}

	public function Map(option:Dynamic):ShaderBuilder {
		Shader.Indexer++;
		trace(option);
		option = Shader.Def(option, { path: 'assets/img/color.png' });
		trace(option);
		var s = 0;
		var refInd = '';
		if (option.index == null) {
			s = Shader.Me.GetMapIndex(option.path);
			
			if (s == -1) {
				Shader.Me.Setting.Texture2Ds.push(cast { key: option.path, inVertex: option.useInVertex, inFragment: true });
			} 
			else {
				Shader.Me.Setting.Texture2Ds[s].inVertex = option.useInVertex;
			}
			
			s = Shader.Me.GetMapIndex(option.path);
			refInd = ShaderMaterialHelperStatics.Texture2D + s;
		}
		else if (option.index == "current") { // path denied
			refInd = "textureSampler"; // used Only for postProcess
		}
		else {
			var sn = Shader.Replace(Std.string(option.index), '-', '0');
			var reg = new EReg('^\\d+$', '');
			if (reg.match(sn) && Std.string(option.index).indexOf('.') == -1) {
				refInd = ShaderMaterialHelperStatics.Texture2D + option.index;
			}
			else {
				refInd = option.index;
			}
		}
		
		Shader.Me.Setting.Center = true;
		Shader.Me.Setting.Helpers = true;
		Shader.Me.Setting.Uv = true;
		
		option.normal = Shader.Def(option.normal, Normals.NMap);
		option.alpha = Shader.Def(option.alpha, false);
		option.bias = Shader.Def(option.bias, "0.");
		option.normalLevel = Shader.Def(option.normalLevel, 1.0);
		option.path = Shader.Def(option.path, "qa.jpg");
		option.rotation = Shader.Def(option.rotation, { x: 0, y: 0, z: 0 });
		option.scaleX = Shader.Def(option.scaleX, 1.0);
		option.scaleY = Shader.Def(option.scaleY, 1.0);
		option.useInVertex = Shader.Def(option.useInVertex, false);
		option.x = Shader.Def(option.x, 0.0);
		option.y = Shader.Def(option.y, 0.0);
		option.uv = Shader.Def(option.uv, ShaderMaterialHelperStatics.Uv);
		option.animation = Shader.Def(option.animation, false);
		option.tiled = Shader.Def(option.tiled, false);
		option.columnIndex = Shader.Def(option.columnIndex, 1);
		option.rowIndex = Shader.Def(option.rowIndex, 1);
		option.animationSpeed = Shader.Def(option.animationSpeed, 2000);
		option.animationFrameEnd = Shader.Def(option.animationFrameEnd, 100) + option.indexCount;
		option.animationFrameStart = Shader.Def(option.animationFrameStart, 0) + option.indexCount;
		option.indexCount = Shader.Def(option.indexCount, 1);
		
		var frameLength = Math.min(option.animationFrameEnd - option.animationFrameStart, option.indexCount * option.indexCount);
		
		var uv = Shader.Def(option.uv, ShaderMaterialHelperStatics.Uv);
		
		if (option.uv == "planar") {
			uv = ShaderMaterialHelperStatics.Position;
		}
		else {
			uv = 'vec3(' + option.uv + '.x,' + option.uv + '.y,0.)';
		}
		
		option.scaleX /= option.indexCount;
		option.scaleY /= option.indexCount;
		
		var rotate = ["vec3 centeri#[Ind] = " + ShaderMaterialHelperStatics.Center + ";",
			"vec3 ppo#[Ind] = r_z( " + uv + "," + Shader.Print(option.rotation.x) + ",centeri#[Ind]);  ",
			" ppo#[Ind] = r_y( ppo#[Ind]," + Shader.Print(option.rotation.y) + ",centeri#[Ind]);  ",
			" ppo#[Ind] = r_x( ppo#[Ind]," + Shader.Print(option.rotation.x) + ",centeri#[Ind]); ",
			"vec3 nrm#[Ind] = r_z( " + option.normal + "," + Shader.Print(option.rotation.x) + ",centeri#[Ind]);  ",
			" nrm#[Ind] = r_y( nrm#[Ind]," + Shader.Print(option.rotation.y) + ",centeri#[Ind]);  ",
			" nrm#[Ind] = r_x( nrm#[Ind]," + Shader.Print(option.rotation.z) + ",centeri#[Ind]);  "].join("\n");
			
		var sresult = Shader.Join([rotate,
			" vec4 color#[Ind] = texture2D(" +
			refInd + " ,ppo#[Ind].xy*vec2(" +
			Shader.Print(option.scaleX) + "," + Shader.Print(option.scaleY) + ")+vec2(" +
			Shader.Print(option.x) + "," + Shader.Print(option.y) + ")" + (option.bias == null || Shader.Print(option.bias) == '0.' ? "" : "," + Shader.Print(option.bias)) + ");",
			" if(nrm#[Ind].z < " + Shader.Print(option.normalLevel) + "){ ",
			(option.alpha ? " result =  color#[Ind];" : "result = vec4(color#[Ind].rgb , 1.); "),
			"}"]);
			
		if (option.indexCount > 1 || option.tiled) {
			option.columnIndex = option.indexCount - option.columnIndex + 1;
			sresult = [
				" vec3 uvt#[Ind] = vec3(" + uv + ".x*" + Shader.Print(option.scaleX) + "+" + Shader.Print(option.x) + "," + uv + ".y*" + Shader.Print(option.scaleY) + "+" + Shader.Print(option.y) + ",0.0);     ",
				"             ",
				" float xst#[Ind] = 1./(" + Shader.Print(option.indexCount) + "*2.);                                                    ",
				" float yst#[Ind] =1./(" + Shader.Print(option.indexCount) + "*2.);                                                     ",
				" float xs#[Ind] = 1./" + Shader.Print(option.indexCount) + ";                                                     ",
				" float ys#[Ind] = 1./" + Shader.Print(option.indexCount) + ";                                                     ",
				" float yid#[Ind] = " + Shader.Print(option.columnIndex - 1.0) + " ;                                                      ",
				" float xid#[Ind] =  " + Shader.Print(option.rowIndex - 1.0) + ";                                                      ",
				option.animation ? " float ind_a#[Ind] = floor(mod(time*0.001*" + Shader.Print(option.animationSpeed) + ",   " + Shader.Print(frameLength) + " )+" + Shader.Print(option.animationFrameStart) + ");" +
					" yid#[Ind] = " + Shader.Print(option.indexCount) + "- floor(ind_a#[Ind] /  " + Shader.Print(option.indexCount) + ");" +
					" xid#[Ind] =  floor(mod(ind_a#[Ind] ,  " + Shader.Print(option.indexCount) + ")); "
					: "",
				" float xi#[Ind] = mod(uvt#[Ind].x ,xs#[Ind])+xs#[Ind]*xid#[Ind]  ;                                   ",
				" float yi#[Ind] = mod(uvt#[Ind].y ,ys#[Ind])+ys#[Ind]*yid#[Ind]  ;                                   ",

				"                                                                       ",
				" float xi2#[Ind] = mod(uvt#[Ind].x -xs#[Ind]*0.5 ,xs#[Ind])+xs#[Ind]*xid#[Ind]      ;                     ",
				" float yi2#[Ind] = mod(uvt#[Ind].y -ys#[Ind]*0.5,ys#[Ind])+ys#[Ind]*yid#[Ind]   ;                         ",
				"                                                                       ",
				"                                                                       ",
				" vec4 f#[Ind] = texture2D(" + refInd + ",vec2(xi#[Ind],yi#[Ind])) ;                             ",
				" result =   f#[Ind] ;                                               ",
				(option.tiled ? [" vec4 f2#[Ind] = texture2D(" + refInd + ",vec2(xi2#[Ind]+xid#[Ind] ,yi#[Ind])) ;                      ",
					" vec4 f3#[Ind] = texture2D(" + refInd + ",vec2(xi#[Ind],yi2#[Ind]+yid#[Ind])) ;                       ",
					" vec4 f4#[Ind] = texture2D(" + refInd + ",vec2(xi2#[Ind]+xid#[Ind],yi2#[Ind]+yid#[Ind])) ;                  ",
					"                                                                       ",
					"                                                                       ",
					" float ir#[Ind]  = 0.,ir2#[Ind] = 0.;                                              ",
					"                                                                       ",
					"     if( yi2#[Ind]  >= yid#[Ind] *ys#[Ind] ){                                            ",
					"         ir2#[Ind]  = min(2.,max(0.,( yi2#[Ind]-yid#[Ind] *ys#[Ind])*2.0/ys#[Ind] ))   ;             ",
					"         if(ir2#[Ind] > 1.0) ir2#[Ind] =1.0-(ir2#[Ind]-1.0);                             ",
					"         ir2#[Ind] = min(1.0,max(0.0,pow(ir2#[Ind]," + Shader.Print(15.) + " )*" + Shader.Print(3.) + ")); ",
					"         result =  result *(1.0-ir2#[Ind]) +f3#[Ind]*ir2#[Ind]  ;           ",

					"     }                                                                 ",

					" if( xi2#[Ind]  >= xid#[Ind] *xs#[Ind]   ){                                               ",
					"         ir2#[Ind]  = min(2.,max(0.,( xi2#[Ind]-xid#[Ind] *xs#[Ind])*2.0/xs#[Ind] ))   ;             ",
					"         if(ir2#[Ind] > 1.0) ir2#[Ind] =1.0-(ir2#[Ind]-1.0);                             ",
					"         ir2#[Ind] = min(1.0,max(0.0,pow(ir2#[Ind]," + Shader.Print(15.) + " )*" + Shader.Print(3.) + ")); ",

					"         result = result *(1.0-ir2#[Ind]) +f2#[Ind]*ir2#[Ind]  ;           ",

					"     }  ",
					" if( xi2#[Ind]  >= xid#[Ind] *xs#[Ind]  && xi2#[Ind]  >= xid#[Ind] *xs#[Ind]  ){                                               ",
					"         ir2#[Ind]  = min(2.,max(0.,( xi2#[Ind]-xid#[Ind] *xs#[Ind])*2.0/xs#[Ind] ))   ;             ",
					"  float       ir3#[Ind]  = min(2.,max(0.,( yi2#[Ind]-yid#[Ind] *ys#[Ind])*2.0/ys#[Ind] ))   ;             ",
					"         if(ir2#[Ind] > 1.0) ir2#[Ind] =1.0-(ir2#[Ind]-1.0);                             ",
					"         if(ir3#[Ind] > 1.0) ir3#[Ind] =1.0-(ir3#[Ind]-1.0);                             ",
					"         ir2#[Ind] = min(1.0,max(0.0,pow(ir2#[Ind]," + Shader.Print(15.) + " )*" + Shader.Print(3.) + ")); ",
					"         ir3#[Ind] = min(1.0,max(0.0,pow(ir3#[Ind]," + Shader.Print(15.) + " )*" + Shader.Print(3.) + ")); ",
					"         ir2#[Ind] = min(1.0,max(0.0, ir2#[Ind]* ir3#[Ind] )); ",
					" if(nrm#[Ind].z < " + Shader.Print(option.normalLevel) + "){ ",
					(option.alpha ? "    result =  result *(1.0-ir2#[Ind]) +f4#[Ind]* ir2#[Ind]   ;" : "    result = vec4(result.xyz*(1.0-ir2#[Ind]) +f4#[Ind].xyz* ir2#[Ind]   ,1.0); "),
					"}",
					"     }  "
				].join("\n") : "")].join("\n");
		}
		
		sresult = Shader.Replace(sresult, "#[Ind]", "_" + Shader.Indexer + "_");
		
		this.Body = Shader.Def(this.Body, "");
		this.Body += sresult;
		
		return this;
	}

	public function Multi(mats:Array<Dynamic>, combine:Bool):ShaderBuilder {
		combine = Shader.Def(combine, true);
		Shader.Indexer++;
		var pre = "";
		var ps = ["", "", "", ""];
		var psh = "0.0";
		for (i in 0...mats.length) {
			if (mats[i].result == null) {
				mats[i] = { result: mats[i], opacity: 1.0 };
			}
			
			pre += " vec4 result#[Ind]" + i + ";result#[Ind]" + i + " = vec4(0.,0.,0.,0.); float rp#[Ind]" + i + " = " + Shader.Print(mats[i].opacity) + "; \n";
			pre += mats[i].result + "\n";
			pre += " result#[Ind]" + i + " = result; \n";
			
			ps[0] += (i == 0 ? "" : " + ") + "result#[Ind]" + i + ".x*rp#[Ind]" + i;
			ps[1] += (i == 0 ? "" : " + ") + "result#[Ind]" + i + ".y*rp#[Ind]" + i;
			ps[2] += (i == 0 ? "" : " + ") + "result#[Ind]" + i + ".z*rp#[Ind]" + i;
			ps[3] += (i == 0 ? "" : " + ") + "result#[Ind]" + i + ".w*rp#[Ind]" + i;
			
			psh += "+" + Shader.Print(mats[i].opacity);
		}
		
		if (combine) {
			ps[0] = "(" + ps[0] + ")/(" + Shader.Print(psh) + ")";
			ps[1] = "(" + ps[1] + ")/(" + Shader.Print(psh) + ")";
			ps[2] = "(" + ps[2] + ")/(" + Shader.Print(psh) + ")";
			ps[3] = "(" + ps[3] + ")/(" + Shader.Print(psh) + ")";
		}
		
		pre += "result = vec4(" + ps[0] + "," + ps[1] + "," + ps[2] + "," + ps[3] + ");";
		
		this.Body = Shader.Def(this.Body, "");
		this.Body += Shader.Replace(pre, "#[Ind]", "_" + Shader.Indexer + "_");
		
		return this;
	}

	public function Back(mat:String = ""):ShaderBuilder {
		Shader.Me.Setting.Back = true;
		mat = Shader.Def(mat, '');
		this.Body = Shader.Def(this.Body, "");
		this.Body += 'if(' + ShaderMaterialHelperStatics.face_back + '){' + mat + ';}';
		
		return this;
	}

	public function InLine(mat:String):ShaderBuilder {
		mat = Shader.Def(mat, '');
		this.Body = Shader.Def(this.Body, "");
		this.Body += mat;
		
		return this;
	}

	public function Front(mat:String):ShaderBuilder {
		mat = Shader.Def(mat, '');
		this.Body = Shader.Def(this.Body, "");
		this.Body += 'if(' + ShaderMaterialHelperStatics.face_front + '){' + mat + ';}';
		
		return this;
	}

	public function Range(mat1:String, mat2:String, option:Dynamic/*IRange*/):ShaderBuilder {
		Shader.Indexer++;
		var k = Shader.Indexer;
		
		option.start = Shader.Def(option.start, 0.0);
		option.end = Shader.Def(option.end, 1.0);
		option.direction = Shader.Def(option.direction, ShaderMaterialHelperStatics.Position + '.y');
		
		var sresult = [
			"float s_r_dim#[Ind] = " + option.direction + ";",
			"if(s_r_dim#[Ind] > " + Shader.Print(option.end) + "){",
			mat2,
			"}",
			"else { ",
			mat1,
			"   vec4 mat1#[Ind]; mat1#[Ind]  = result;",
			"   if(s_r_dim#[Ind] > " + Shader.Print(option.start) + "){ ",
			mat2,
			"       vec4 mati2#[Ind];mati2#[Ind] = result;",
			"       float s_r_cp#[Ind]  = (s_r_dim#[Ind] - (" + Shader.Print(option.start) + "))/(" + Shader.Print(option.end) + "-(" + Shader.Print(option.start) + "));",
			"       float s_r_c#[Ind]  = 1.0 - s_r_cp#[Ind];",
			"       result = vec4(mat1#[Ind].x*s_r_c#[Ind]+mati2#[Ind].x*s_r_cp#[Ind],mat1#[Ind].y*s_r_c#[Ind]+mati2#[Ind].y*s_r_cp#[Ind],mat1#[Ind].z*s_r_c#[Ind]+mati2#[Ind].z*s_r_cp#[Ind],mat1#[Ind].w*s_r_c#[Ind]+mati2#[Ind].w*s_r_cp#[Ind]);",
			"   }",
			"   else { result = mat1#[Ind]; }",
			"}"
		].join('\n');
		sresult = Shader.Replace(sresult, '#[Ind]', "_" + Shader.Indexer + "_");
		
		this.Body = Shader.Def(this.Body, "");
		this.Body += sresult;
		
		return this;
	}

	public function Reference(index:String, ?mat:Dynamic):ShaderBuilder {
		if (Shader.Me.References == null) {
			Shader.Me.References = "";
		}
		
		var sresult = "vec4 resHelp#[Ind] = result;";
		
		if (Shader.Me.References.indexOf("," + index + ",") == -1) {
			Shader.Me.References += "," + index + ",";
			sresult += " vec4 result_" + index + " = vec4(0.);\n";
		}
		if (mat == null) {
			sresult += "  result_" + index + " = result;";
		}
		else {
			sresult += mat + "\nresult_" + index + " = result;";
		}
		
		sresult += "result = resHelp#[Ind] ;";
		sresult = Shader.Replace(sresult, '#[Ind]', "_" + Shader.Indexer + "_");
		
		this.Body = Shader.Def(this.Body, "");
		this.Body += sresult;
		
		return this;
	}

	public function ReplaceColor(index:Int, color:Int, mat:String, option:Dynamic/*IReplaceColor*/):ShaderBuilder {
		Shader.Indexer++;
		option = Shader.Def(option, {});
		var d:Float = cast Shader.Def(option.rangeStep, -0.280);
		var d2:Float = cast Shader.Def(option.rangePower, 0.0);
		var d3:Float = cast Shader.Def(option.colorIndex, 0.0);
		var d4:Float = cast Shader.Def(option.colorStep, 1.0);
		var ilg:Bool = cast Shader.Def(option.indexToEnd, false);
		
		var lg = " > 0.5 + " + Shader.Print(d) + " ";
		var lw = " < 0.5 - " + Shader.Print(d) + " ";
		var rr = "((result_" + index + ".x*" + Shader.Print(d4) + "-" + Shader.Print(d3) + ")>1.0 ? 0. : max(0.,(result_" + index + ".x*" + Shader.Print(d4) + "-" + Shader.Print(d3) + ")))";
		var rg = "((result_" + index + ".y*" + Shader.Print(d4) + "-" + Shader.Print(d3) + ")>1.0 ? 0. : max(0.,(result_" + index + ".y*" + Shader.Print(d4) + "-" + Shader.Print(d3) + ")))";
		var rb = "((result_" + index + ".z*" + Shader.Print(d4) + "-" + Shader.Print(d3) + ")>1.0 ? 0. : max(0.,(result_" + index + ".z*" + Shader.Print(d4) + "-" + Shader.Print(d3) + ")))";
		if (ilg) {
			rr = "min(1.0, max(0.,(result_" + index + ".x*" + Shader.Print(d4) + "-" + Shader.Print(d3) + ")))";
			rg = "min(1.0, max(0.,(result_" + index + ".y*" + Shader.Print(d4) + "-" + Shader.Print(d3) + ")))";
			rb = "min(1.0, max(0.,(result_" + index + ".z*" + Shader.Print(d4) + "-" + Shader.Print(d3) + ")))";
		}
		var a = " && ";
		var p = " + ";
		
		var r = "";
		var cond = "";
		
		switch (color) {
			case Helper.White: 
				cond = rr + lg + a + rg + lg + a + rb + lg; 
				r = "(" + rr + p + rg + p + rb + ")/3.0"; 
				
			case Helper.Cyan: 
				cond = rr + lw + a + rg + lg + a + rb + lg; 
				r = "(" + rg + p + rb + ")/2.0 - (" + rr + ")/1.0"; 
				
			case Helper.Pink: 
				cond = rr + lg + a + rg + lw + a + rb + lg; 
				r = "(" + rr + p + rb + ")/2.0 - (" + rg + ")/1.0"; 
				
			case Helper.Yellow: 
				cond = rr + lg + a + rg + lg + a + rb + lw; 
				r = "(" + rr + p + rg + ")/2.0 - (" + rb + ")/1.0"; 
				
			case Helper.Blue: 
				cond = rr + lw + a + rg + lw + a + rb + lg; 
				r = "(" + rb + ")/1.0 - (" + rr + p + rg + ")/2.0"; 
				
			case Helper.Red: 
				cond = rr + lg + a + rg + lw + a + rb + lw; 
				r = "(" + rr + ")/1.0 - (" + rg + p + rb + ")/2.0"; 
				
			case Helper.Green: 
				cond = rr + lw + a + rg + lg + a + rb + lw; 
				r = "(" + rg + ")/1.0 - (" + rr + p + rb + ")/2.0"; 
				
			case Helper.Black: 
				cond = rr + lw + a + rg + lw + a + rb + lw; 
				r = "1.0-(" + rr + p + rg + p + rb + ")/3.0"; 
		}
		
		var sresult = " if( " + cond + " ) { vec4 oldrs#[Ind] = vec4(result);float al#[Ind] = max(0.0,min(1.0," + r + "+(" + Shader.Print(d2) + "))); float  l#[Ind] =  1.0-al#[Ind];  " + mat + " result = result*al#[Ind] +  oldrs#[Ind] * l#[Ind];    }";
		
		sresult = Shader.Replace(sresult, '#[Ind]', "_" + Shader.Indexer + "_");
		
		this.Body = Shader.Def(this.Body, "");
		this.Body += sresult;
		
		return this;
	}

	public function Blue(index:Int, mat:String, option:Dynamic/*IReplaceColor*/):ShaderBuilder {
		return this.ReplaceColor(index, Helper.Blue, mat, option);
	}
	public function Cyan(index:Int, mat:String, option:Dynamic/*IReplaceColor*/):ShaderBuilder {
		return this.ReplaceColor(index, Helper.Cyan, mat, option);
	}
	public function Red(index:Int, mat:String, option:Dynamic/*IReplaceColor*/):ShaderBuilder {
		return this.ReplaceColor(index, Helper.Red, mat, option);
	}
	public function Yellow(index:Int, mat:String, option:Dynamic/*IReplaceColor*/):ShaderBuilder {
		return this.ReplaceColor(index, Helper.Yellow, mat, option);
	}
	public function Green(index:Int, mat:String, option:Dynamic/*IReplaceColor*/):ShaderBuilder {
		return this.ReplaceColor(index, Helper.Green, mat, option);
	}
	public function Pink(index:Int, mat:String, option:Dynamic/*IReplaceColor*/):ShaderBuilder {
		return this.ReplaceColor(index, Helper.Pink, mat, option);
	}
	public function White(index:Int, mat:String, option:Dynamic/*IReplaceColor*/):ShaderBuilder {
		return this.ReplaceColor(index, Helper.White, mat, option);
	}
	public function Black(index:Int, mat:String, option:Dynamic/*IReplaceColor*/) {
		return this.ReplaceColor(index, Helper.Black, mat, option);
	}

	public function ReflectCube(option:IReflectMap):ShaderBuilder {
		Shader.Indexer++;
		option = Shader.Def(option, { path: 'assets/images/cube/a' });
		var s = Shader.Me.GetCubeMapIndex(option.path);
		
		if (s == -1) {
			Shader.Me.Setting.TextureCubes.push(cast { key: option.path, inVertex: option.useInVertex, inFragment: true });
		} 
		else {
			Shader.Me.Setting.TextureCubes[s].inVertex = true;
		}
		
		s = Shader.Me.GetCubeMapIndex(option.path);
		
		option.normal = Shader.Def(option.normal, Normals.NMap);
		option.alpha = Shader.Def(option.alpha, false);
		option.bias = Shader.Def(option.bias, "0.");
		option.normalLevel = Shader.Def(option.normalLevel, 1.0);
		option.rotation = Shader.Def(option.rotation, { x: 0, y: 0, z: 0 });
		option.scaleX = Shader.Def(option.scaleX, 1.0);
		option.scaleY = Shader.Def(option.scaleY, 1.0);
		option.useInVertex = Shader.Def(option.useInVertex, false);
		option.x = Shader.Def(option.x, 0.0);
		option.y = Shader.Def(option.y, 0.0);
		option.uv = Shader.Def(option.uv, ShaderMaterialHelperStatics.Uv);
		option.reflectMap = Shader.Def(option.reflectMap, "1.");
		Shader.Me.Setting.Center = true;
		Shader.Me.Setting.Camera = true;
		Shader.Me.Setting.ReflectMatrix = true;
		
		var sresult = "";
		
		if (option.equirectangular) {
			option.path = Shader.Def(option.path, 'assets/images/cube/roofl1.jpg');
			var s = Shader.Me.GetMapIndex(option.path);
			
			if (s == -1) {
				Shader.Me.Setting.Texture2Ds.push(cast { key: option.path, inVertex: option.useInVertex, inFragment: true });
			} 
			else {
				Shader.Me.Setting.Texture2Ds[s].inVertex = true;
			}
			
			s = Shader.Me.GetMapIndex(option.path);
			Shader.Me.Setting.VertexWorld = true;
			Shader.Me.Setting.FragmentWorld = true;
			
			sresult = ' vec3 nWorld#[Ind] = normalize( mat3( world[0].xyz, world[1].xyz, world[2].xyz ) *  ' + option.normal + '); ' +
				' vec3 vReflect#[Ind] = normalize( reflect( normalize(  ' + ShaderMaterialHelperStatics.Camera + '- vec3(world * vec4(' + ShaderMaterialHelperStatics.Position + ', 1.0))),  nWorld#[Ind] ) ); ' +
				'float yaw#[Ind] = .5 - atan( vReflect#[Ind].z, -1.* vReflect#[Ind].x ) / ( 2.0 * 3.14159265358979323846264);  ' +
				' float pitch#[Ind] = .5 - atan( vReflect#[Ind].y, length( vReflect#[Ind].xz ) ) / ( 3.14159265358979323846264);  ' +
				' vec3 color#[Ind] = texture2D( ' + ShaderMaterialHelperStatics.Texture2D + s + ', vec2( yaw#[Ind], pitch#[Ind])' + (option.bias == null || Shader.Print(option.bias) == '0.' ? "" : "," + Shader.Print(option.bias)) + ' ).rgb; result = vec4(color#[Ind] ,1.);';
		}
		else {
			option.path = Shader.Def(option.path, "assets/images/cube/a");
			
			sresult = [
				"vec3 viewDir#[Ind] =  " + ShaderMaterialHelperStatics.Position + " - " + ShaderMaterialHelperStatics.Camera + " ;",
				"  viewDir#[Ind] =r_x(viewDir#[Ind] ," + Shader.Print(option.rotation.x) + ",  " + ShaderMaterialHelperStatics.Center + ");",
				"  viewDir#[Ind] =r_y(viewDir#[Ind] ," + Shader.Print(option.rotation.y) + "," + ShaderMaterialHelperStatics.Center + ");",
				"  viewDir#[Ind] =r_z(viewDir#[Ind] ," + Shader.Print(option.rotation.z) + "," + ShaderMaterialHelperStatics.Center + ");",

				"vec3 coords#[Ind] = " + (option.refract ? "refract" : "reflect") + "(viewDir#[Ind]" + (option.revers ? "*vec3(1.0)" : "*vec3(-1.0)") + ", " + option.normal + " " + (option.refract ? ",(" + Shader.Print(option.refractMap) + ")" : "") + " )+" + ShaderMaterialHelperStatics.Position + "; ",
				"vec3 vReflectionUVW#[Ind] = vec3( " + ShaderMaterialHelperStatics.ReflectMatrix + " *  vec4(coords#[Ind], 0)); ",
				"vec3 rc#[Ind]= textureCube(" +
				ShaderMaterialHelperStatics.TextureCube + s + ", vReflectionUVW#[Ind] " + (option.bias == null || Shader.Print(option.bias) == '0.' ? "" : "," + Shader.Print(option.bias)) + ").rgb;",

				"result =result  + vec4(rc#[Ind].x ,rc#[Ind].y,rc#[Ind].z, " + (!option.alpha ? "1." : "(rc#[Ind].x+rc#[Ind].y+rc#[Ind].z)/3.0 ") + ")*(min(1.,max(0.," + Shader.Print(option.reflectMap) + ")));  "
			].join('\n');
		}
		
		sresult = Shader.Replace(sresult, '#[Ind]', "_" + Shader.Indexer + "_");
		
		this.Body = Shader.Def(this.Body, "");
		this.Body += sresult;
		
		return this;
	}

	public function NormalMap(val:String, mat:String):ShaderBuilder {
		Shader.Me.Setting.NormalOpacity = val;
		Shader.Me.Setting.NormalMap = mat;
		
		return this;
	}

	public function SpecularMap(mat:String):ShaderBuilder {
		Shader.Me.Setting.SpecularMap = mat;
		
		return this;
	}

	public function Instance():ShaderBuilder {
		var setting = Shader.Me.Setting;
		var instance = new ShaderBuilder();
		instance.Parent = Shader.Me;
		instance.Setting = setting;
		
		return instance;
	}

	public function Reflect(option:Dynamic/*IReflectMap*/, opacity:Float):ShaderBuilder {
		opacity = Shader.Def(opacity, 1.0);
		
		return this.Multi(["result = result;", { result: this.Instance().ReflectCube(option).Build(), opacity: opacity }], true);
	}

	public function Light(option:Dynamic/*ILight*/):ShaderBuilder {
		option = Shader.Def(option, {});
		option.color = Shader.Def(option.color, { r: 1.0, g: 1.0, b: 1.0, a: 1.0 });
		option.darkColorMode = Shader.Def(option.darkColorMode, false);
		option.direction = Shader.Def(option.direction, "vec3(sin(time*0.02)*28.,sin(time*0.02)*8.+10.,cos(time*0.02)*28.)");
		
		option.normal = Shader.Def(option.normal, Normals.NMap);
		option.rotation = Shader.Def(option.rotation, { x: 0.0, y: 0.0, z: 0.0 });
		option.specular = Shader.Def(option.specular, Speculars.SMap);
		option.specularLevel = Shader.Def(option.specularLevel, 1.0);
		option.specularPower = Shader.Def(option.specularPower, 1.0);
		option.phonge = Shader.Def(option.phonge, 0.0);
		option.phongePower = Shader.Def(option.phongePower, 1.0);
		option.phongeLevel = Shader.Def(option.phongeLevel, 1.0);
		
		option.supplement = Shader.Def(option.supplement, false);
		
		option.reducer = Shader.Def(option.reducer, '1.');
		
		var c_c:Dynamic = option.color;
		if (option.darkColorMode) {
			c_c.a = 1.0 - c_c.a;
			
			c_c.r = 1.0 - c_c.r;
			c_c.g = 1.0 - c_c.g;
			c_c.b = 1.0 - c_c.b;
			c_c.a = c_c.a - 1.0;
		}
		
		Shader.Indexer++;
		
		Shader.Me.Setting.Camera = true;
		Shader.Me.Setting.FragmentWorld = true;
		Shader.Me.Setting.VertexWorld = true;
		Shader.Me.Setting.Helpers = true;
		Shader.Me.Setting.Center = true;
		
		var sresult = Shader.Join([
			"  vec3 dir#[Ind] = normalize(  vec3(world * vec4(" + ShaderMaterialHelperStatics.Position + ",1.)) - " + ShaderMaterialHelperStatics.Camera + ");",

			"  dir#[Ind] =r_x(dir#[Ind] ," + Shader.Print(option.rotation.x) + ",vec3(" + ShaderMaterialHelperStatics.Center + "));",
			"  dir#[Ind] =r_y(dir#[Ind] ," + Shader.Print(option.rotation.y) + ",vec3(" + ShaderMaterialHelperStatics.Center + "));",
			"  dir#[Ind] =r_z(dir#[Ind] ," + Shader.Print(option.rotation.z) + ",vec3(" + ShaderMaterialHelperStatics.Center + "));",

			"  vec4 p1#[Ind] = vec4(" + option.direction + ",.0);                                ",
			"  vec4 c1#[Ind] = vec4(" + Shader.Print(c_c.r) + "," + Shader.Print(c_c.g) + "," + Shader.Print(c_c.b) + ",0.0); ",

			"  vec3 vnrm#[Ind] = normalize(vec3(world * vec4(" + option.normal + ", 0.0)));          ",
			"  vec3 l#[Ind]= normalize(p1#[Ind].xyz " +
			(!option.parallel ? "- vec3(world * vec4(" + ShaderMaterialHelperStatics.Position + ",1.))  " : "")
			+ ");   ",
			"  vec3 vw#[Ind]= normalize(camera -  vec3(world * vec4(" + ShaderMaterialHelperStatics.Position + ",1.)));  ",
			"  vec3 aw#[Ind]= normalize(vw#[Ind]+ l#[Ind]);  ",
			"  float sc#[Ind]= max(0.,min(1., dot(vnrm#[Ind], aw#[Ind])));   ",
			"  sc#[Ind]= pow(sc#[Ind]*min(1.,max(0.," + Shader.Print(option.specular) + ")), (" + Shader.Print(option.specularPower * 1000.0) + "))/" + Shader.Print(option.specularLevel) + " ;  ",

			" float  ph#[Ind]= pow(" + Shader.Print(option.phonge) + "*2., (" + Shader.Print(option.phongePower) + "*0.3333))/(" + Shader.Print(option.phongeLevel) + "*3.) ;  ",
			"  float ndl#[Ind] = max(0., dot(vnrm#[Ind], l#[Ind]));                            ",
			"  float ls#[Ind] = " + (option.supplement ? "1.0 -" : "") + "max(0.,min(1.,ndl#[Ind]*ph#[Ind]*(" + Shader.Print(option.reducer) + "))) ;         ",
			"  result  += vec4( c1#[Ind].xyz*( ls#[Ind])*" + Shader.Print(c_c.a) + " ,  ls#[Ind]); ",
			"  float ls2#[Ind] = " + (option.supplement ? "0.*" : "1.*") + "max(0.,min(1., sc#[Ind]*(" + Shader.Print(option.reducer) + "))) ;         ",
			"  result  += vec4( c1#[Ind].xyz*( ls2#[Ind])*" + Shader.Print(c_c.a) + " ,  ls2#[Ind]); "
		]);
		
		sresult = Shader.Replace(sresult, '#[Ind]', "_" + Shader.Indexer + "_");
		
		this.Body = Shader.Def(this.Body, "");
		this.Body += sresult;
		
		return this;
	}

	public function Effect(option:Dynamic/*IEffect*/):ShaderBuilder {
		var op = Shader.Def(option, {});
		Shader.Indexer++;
		var sresult = [
			'vec4 res#[Ind] = vec4(0.);',

			'res#[Ind].x = ' + (op.px != null ? Shader.Replace(Shader.Replace(Shader.Replace(Shader.Replace(op.px, 'px', 'result.x'), 'py', 'result.y'), 'pz', 'result.z'), 'pw', 'result.w') + ';' : ' result.x;'),
			'res#[Ind].y = ' + (op.py != null ? Shader.Replace(Shader.Replace(Shader.Replace(Shader.Replace(op.py, 'px', 'result.x'), 'py', 'result.y'), 'pz', 'result.z'), 'pw', 'result.w') + ';' : ' result.y;'),
			'res#[Ind].z = ' + (op.pz != null ? Shader.Replace(Shader.Replace(Shader.Replace(Shader.Replace(op.pz, 'px', 'result.x'), 'py', 'result.y'), 'pz', 'result.z'), 'pw', 'result.w') + ';' : ' result.z;'),
			'res#[Ind].w = ' + (op.pw != null ? Shader.Replace(Shader.Replace(Shader.Replace(Shader.Replace(op.pw, 'px', 'result.x'), 'py', 'result.y'), 'pz', 'result.z'), 'pw', 'result.w') + ';' : ' result.w;'),
			'res#[Ind]  = ' + (op.pr != null ? ' vec4(' + Shader.Replace(Shader.Replace(Shader.Replace(Shader.Replace(Shader.Replace(op.pr, 'pr', 'res#[Ind].x'), 'px', 'result.x'), 'py', 'result.y'), 'pz', 'result.z'), 'pw', 'result.w') + ','

				+ Shader.Replace(Shader.Replace(Shader.Replace(Shader.Replace(Shader.Replace(op.pr, 'pr', 'res#[Ind].y'), 'px', 'result.x'), 'py', 'result.y'), 'pz', 'result.z'), 'pw', 'result.w') + ',' +
				Shader.Replace(Shader.Replace(Shader.Replace(Shader.Replace(Shader.Replace(op.pr, 'pr', 'res#[Ind].z'), 'px', 'result.x'), 'py', 'result.y'), 'pz', 'result.z'), 'pw', 'result.w')
				+ ',' +
				Shader.Replace(Shader.Replace(Shader.Replace(Shader.Replace(Shader.Replace(op.pr, 'pr', 'res#[Ind].w'), 'px', 'result.x'), 'py', 'result.y'), 'pz', 'result.z'), 'pw', 'result.w')
				+ ');' : ' res#[Ind]*1.0;'),

			'result = res#[Ind] ;'
		].join('\n');
		sresult = Shader.Replace(sresult, '#[Ind]', "_" + Shader.Indexer + "_");
		
		this.Body = Shader.Def(this.Body, "");
		this.Body += sresult;
		
		return this;
	}

	public function IdColor(id:Float, w:Float):ShaderBuilder {
		var kg = { r: 0.0, g: 0.0, b: 0.0 };
		kg = Shader.torgb(id * 1.0, 255);
		
		this.Body = Shader.Def(this.Body, "");
		this.Body += 'result = vec4(' + Shader.Print(kg.r) + ',' + Shader.Print(kg.g) + ',' + Shader.Print(Math.max(kg.b, 0.0)) + ',' + Shader.Print(w) + ');';
		
		return this;
	}

	public function Discard():ShaderBuilder {
		this.Body = Shader.Def(this.Body, "");
		this.Body += 'discard;';
		
		return this;
	}

	public function new() {
		this.Setting = new ShaderSetting();
		this.Extentions = [];
		this.Attributes = [];
		this.Fragment = [];
		this.Helpers = [];
		this.Uniforms = [];
		this.Varings = [];
		this.Vertex = [];
		
		this.Setting.Uv = true;
		this.Setting.Time = true;
		this.Setting.Camera = true;
		this.Setting.Helpers = true;
		
		this.Setting.NormalMap = "result = vec4(0.5);";
		this.Setting.SpecularMap = "float_result = 1.0;";
		this.Setting.NormalOpacity = "0.5";
		this.Setting.Normal = ShaderMaterialHelperStatics.Normal;
		
		/*if (Shader.Indexer == null) {
			Shader.Indexer = 1;
		}*/
		
		this.CustomIndexer = 1;
		Shader.Me = this;
	}
	
}
