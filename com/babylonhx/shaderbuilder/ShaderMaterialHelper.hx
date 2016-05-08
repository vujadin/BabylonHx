package com.babylonhx.shaderbuilder;

import com.babylonhx.Scene;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector4;
import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.ShaderMaterial in ShaderMat;
import com.babylonhx.materials.ShadersStore;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.postprocess.PostProcess;

/**
 * ...
 * @author Krtolica Vujadin
 */
class ShaderMaterialHelper {

	static public function ShaderMaterial(name:String, scene:Scene, shader:Dynamic/*ShaderStruct*/, helpers:Dynamic/*ShaderHelper*/):ShaderMat {
		//trace(shader.Pixel);
        return MakeShaderMaterialForEngine(name, scene, shader, helpers);
	}
	
	static public function MakeShaderMaterialForEngine(name:String, scene:Scene, shader:Dynamic/*ShaderStruct*/, helpers:Dynamic/*ShaderHelper*/):ShaderMat { 
		trace(name);
		ShadersStore.Shaders.set(name + ".vertex", shader.Vertex);
		ShadersStore.Shaders.set(name + ".fragment", shader.Pixel);
		
		return new ShaderMat(name, scene, name, cast helpers); 
	}
	
	static public function DefineTexture(url:String, scene:Scene):Texture {
		var tx = new Texture(url, scene); 
		
		return tx;
	}
	
	static public function DefineCubeTexture(url:String, scene:Scene):CubeTexture {
		var tx = new CubeTexture(url, scene); 
		tx.coordinatesMode = Texture.PLANAR_MODE; 
		
		return tx;
	}
	
	static public function SetUniforms(meshes:Array<Mesh>, cameraPos:Vector3, cameraTarget:Vector3, mouse:Vector2, screen:Vector2, time:Float) {
		for (ms in meshes) { 			
			if (ms.material != null && Std.is(ms.material, ShaderMat) && (untyped ms.material.shaderSetting != null)) { 
				if (untyped ms.material.shaderSetting.Camera != null) {               
					untyped ms.material.setVector3(ShaderMaterialHelperStatics.Camera, cameraPos); 
				}
				
				if (untyped ms.material.shaderSetting.Center != null) {
					untyped ms.material.setVector3(ShaderMaterialHelperStatics.Center, new Vector3(0, 0, 0)); 
				}
				
				if (untyped ms.material.shaderSetting.Mouse != null) {
					untyped ms.material.setVector2(ShaderMaterialHelperStatics.Mouse, mouse); 
				}
				
				if (untyped ms.material.shaderSetting.Screen != null) {
					untyped ms.material.setVector2(ShaderMaterialHelperStatics.Screen, screen); 
				}
				
				if (untyped ms.material.shaderSetting.GlobalTime != null) {                
					untyped ms.material.setVector4(ShaderMaterialHelperStatics.GlobalTime, new Vector4(0, 0, 0, 0)); 
				}
				
				if (untyped ms.material.shaderSetting.Look != null) {
					untyped ms.material.setVector3(ShaderMaterialHelperStatics.Look, cameraTarget); 
				}
				
				if (untyped ms.material.shaderSetting.Time) {					
					untyped ms.material.setFloat(ShaderMaterialHelperStatics.Time, time);				
				}
			}
		}
	}
	
	static public function PostProcessTextures(pps:PostProcess, name:String, txt:BaseTexture) { 
		pps._effect.setTexture(name, txt);
	}
	
	static public function DefineRenderTarget(name:String, scale:Float, scene:Scene):Dynamic {
		return { };
	}
	
	static public function ShaderPostProcess(name:String, samplers:Array<String>, camera:Camera, scale:Float, shader:Dynamic, helpers:Dynamic, ?option:Dynamic /*IPostProcess*/):PostProcess {
		if (option == null) {
			option = { };
		}
		
		if (option.samplingMode == null) {
			option.samplingMode = Texture.BILINEAR_SAMPLINGMODE;
		}
		
		ShadersStore.Shaders[name + ".fragment"] = shader.Pixel;
		
		var pps = new PostProcess(name, name, helpers.uniforms, samplers, scale, camera, option.samplingMode);
		pps.onApply = function (effect:Effect) {
			//effect.setFloat("time", time); 
			effect.setVector2("screen", new Vector2(pps.width, pps.height)); 
			effect.setVector3("camera", camera.position); 
			
			if (option != null && option.onApply != null) {
				option.onApply(effect); 
			}
		};
		
		return pps;
	}
	
}
