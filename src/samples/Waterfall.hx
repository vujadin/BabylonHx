package samples;

import com.babylonhx.Scene;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.shaderbuilder.ShaderBuilder;
import com.babylonhx.shaderbuilder.ShaderMaterialHelper;
import com.babylonhx.tools.EventState;
import com.babylonhxext.loaders.obj.ObjLoader;
import com.babylonhx.shaderbuilder.Shader;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.bones.Skeleton;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Waterfall {
	
	var time:Float = 0;

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("camera1",50,  0,180 , new Vector3( 0.,7., 0. ), scene);
		camera.attachControl(); 

		var light = new HemisphericLight("light1", new Vector3(0, 1, 0), scene); 
		light.intensity = 0.7; 
		
		var which = "plane";  // or ground
		// var which = "ground";  // or plane

		var objLoader = new ObjLoader(scene);
		SceneLoader.ImportMesh("", 'assets/models/', 'waterfall.babylon', scene, function (meshes:Array<AbstractMesh>, newParticles:Array<ParticleSystem>, newSkeletons:Array<Skeleton>) {
			trace(meshes.length);
			meshes[2].material = new ShaderBuilder().Map({ path: 'assets/img/ground.jpg', scaleX: 2.0, scaleY: 2.0 })
				.Effect({ pr: 'length(result.xyz)/3.' })
				.BuildMaterial(scene);
				
			meshes[1].material = new ShaderBuilder().VertexShader('\n float h1 = 10.4;\n float sca = 10.;\n float speed = 0.01;\n vec3 pos0 = pos;\n float n1 = noise( pos +vec3(speed*time) );\n result = vec4(pos0+  nrm*  n1*h1   ,1.); \n  vuv.x = n1*h1 ;\n') 
				.Solid({ r:1, g:1, b:1, a:0 })
				.Transparency() 
				.Range('result = vec4(1.,1.,1.,0.);','result = vec4(1.);', cast { start: -8.0, end: 30.0, direction: '-pos.y' }).BuildMaterial(scene);
				
			meshes[0].material = new ShaderBuilder()
				.VertexShader('\n float h1 = 0.4;\n float sca = 10.;\n float speed = 0.05;\n if(vuv.x > 0.1 && vuv.x <0.23){ speed = -1.*speed;}\n vec3 pos0 = pos;\n vec3 pos1 = pos+vec3(0.,-0.001,0.01);\n vec3 pos2 = pos+vec3(0.1,0.001,0.0);\n float n1 = noise( vec3(pos0.x*(1.-vuv.x+0.5)-time*speed+floor(vuv.x*2.)*time*speed*0.4,-pos0.y*0.02,pos0.z*(vuv.y+0.2)+floor(vuv.x*2.)*time*speed*0.4)  );\n float n2 = noise( vec3(pos1.x*(1.-vuv.x+0.5)-time*speed+floor(vuv.x*2.)*time*speed*0.4,-pos1.y*0.02,pos1.z*(vuv.y+0.2)+floor(vuv.x*2.)*time*speed*0.4)  );\n float n3 = noise( vec3(pos2.x*(1.-vuv.x+0.5)-time*speed+floor(vuv.x*2.)*time*speed*0.4,-pos2.y*0.02,pos2.z*(vuv.y+0.2)+floor(vuv.x*2.)*time*speed*0.4)  );\n result = vec4(pos0+vec3( n1*h1*0.3,  sin(vuv.x*60.-time*0.1)*0.1+ n1*h1,n1*h1*0.3),1.); \n vec4 rs1 = vec4(pos1+vec3( n2*h1*0.3,  sin(vuv.x*60.-time*0.1)*0.1+  n2*h1,n2*h1*0.3),1.); \n vec4 rs2 = vec4(pos2+vec3( n3*h1*0.3,  sin(vuv.x*60.-time*0.1)*0.1+  n3*h1,n3*h1*0.3),1.); \n nrm =nrm*0.8+ normalize(cross(result.xyz-rs1.xyz,result.xyz-rs2.xyz))*0.2;\n result.y += 0.5; result.x += 0.1;\n')
			// .InLine('vec4 a = vec4(vec3(1.),  min(1., pow(0.95/(abs(pos.' + mydim + ')+abs(vuv.x)*0.95), 3.)));') // Def Result like Red Color
				.Solid({ r: 1 })
				.Func(function (me) {
					Shader.Me.Setting.FragmentWorld = true;
					return me; 
				})
				.InLine('vec3 _pos =  vec3(world * vec4(pos,1.));')
				.Map({ path: 'assets/img/oqfZKQy.jpg', uv: 'vec2(_pos.x*0.01 ,_pos.z*0.01-time*0.000)' })
				.Solid({})
				.Reflect({ equirectangular:true, 
				path: 'assets/assets/skybox/TropicalSunnyDay', bias:0.0, revers: true }, 1.0)
				.Transparency()
				.InLine('result = vec4(result.xyz,max(0.2,pow(length(result.xyz)/3.,5.)*5.));')
				.Light({ phonge: 3, parallel: true, specular: 100.0, specularPower: 0.5 , direction: 'vec3(0.,10.,10.)', normal: 'nrm' }).BuildMaterial(scene);			 
		});
	 
		var mouse = new Vector2(0, 0);
		var screen = new Vector2(100, 100);
		scene.registerBeforeRender(function(scene:Scene, es:Null<EventState>) {
			time++; 
			
			// initialize Shader requirment per frame
			ShaderMaterialHelper.SetUniforms(
				cast scene.meshes, 
				camera.position,
				camera.target,
				mouse,
				screen,
				time
			);
		});
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
