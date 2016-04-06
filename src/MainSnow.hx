package;

import snow.types.Types;

import com.babylonhx.Engine;
import com.babylonhx.Scene;
import com.babylonhx.tools.Tools;

typedef UserConfig = { }


class MainSnow extends snow.App {
	
	var engine:Engine;
	var scene:Scene;
	var window:WindowConfig;
	
	
	function new() {}
	
	override function config(config:AppConfig):AppConfig {
		config.window.title = 'BabylonHx_Snow';
		this.window = config.window;
		
		Tools.app = app;
		
		return config;
	}

	override function ready() {
		
		engine = new Engine(this.window);
		scene = new Scene(engine);
		
		new samples.BasicScene(scene);
		//new samples.BasicElements(scene);
		//new samples.DashedLinesMesh(scene);
		//new samples.CandleLight(scene);
		//new samples.RotationAndScaling(scene);
		//new samples.Materials(scene);
		//new samples.Lights(scene);
		//new samples.BumpMap(scene);
		//new samples.Animations(scene);
		//new samples.Collisions(scene);
		//new samples.Intersections(scene);
		//new samples.EasingFunctions(scene);
		//new samples.ProceduralTextures(scene);
		//new samples.MeshImport(scene);
		//new samples.LoadScene(scene);
		//new samples.CSGDemo(scene);
		//new samples.Fog(scene);
		//new samples.DisplacementMap(scene);
		//new samples.Environment(scene);
		//new samples.LensFlares(scene);
		//new samples.PhysicsCannon(scene);
		//new samples.Physics(scene);
		//new samples.Physics2(scene);
		//new samples.Physics_Pyramid(scene);
		//new samples.PhysicsSimple(scene);
		//new samples.PhysicsCar(scene);
		//new samples.PhysicsNew(scene);
		//new samples.PolygonMesh1(scene);
		//new samples.PolygonMesh2(scene);
		//new samples.PolygonMesh3(scene);
		//new samples.CustomRenderTarget(scene);
		//new samples.Lines(scene);
		//new samples.Lines2(scene);
		//new samples.Bones(scene);		
		//new samples.Shadows(scene);
		//new samples.Shadows2(scene);
		//new samples.HeightMap(scene);
		//new samples.LoadObjFile(scene);
		//new samples.LoadStlFile(scene);
		//new samples.LoadPlyFile(scene);
		//new samples.LOD(scene);
		//new samples.Instances(scene);
		//new samples.Instances2(scene);
		//new samples.Fresnel(scene);		
		//new samples.VolumetricLights(scene);
		//new samples.CellShading(scene);
		//new samples.Particles(scene);
		//new samples.Particles2(scene);
		//new samples.Particles3(scene);
		//new samples.Extrusion(scene);
		//new samples.Sprites(scene);
		//new samples.PostprocessBloom(scene);
		//new samples.PostprocessRefraction(scene);
		//new samples.PostprocessConvolution(scene);
		//new samples.GodRays(scene);
		//new samples.GodRays2(scene);
		//new samples.DepthOfField(scene);
		//new samples.Actions(scene);
		//new samples.Picking(scene);		
		//new samples.Octree(scene);
		//new samples.SSAO(scene);						
		//new samples.Decals(scene);
		//new samples.InstancedBones(scene);				
		//new samples.AdvancedShadows(scene);
		//new samples.Ribbons(scene);
		//new samples.RibbonTest2(scene);
		//new samples.SoftShadows(scene);		
		//new samples.BabylonHxWebsiteScene(scene);
		//new samples.Water(scene);
		//new samples.SolidParticles1(scene);
		//new samples.SolidParticles2(scene);
		//new samples.SolidParticles3(scene);
		//new samples.SolidParticles4(scene);
		//new samples.SolidParticles5(scene);
		//new samples.PointLightShadow(scene);
		//new samples.Labyrinth(scene);
		//new samples.FireMat(scene);
		//new samples.WaterMat(scene);
		//new samples.LavaMat(scene);
		//new samples.NormalMat(scene);
		//new samples.ForestOfPythagoras(scene);
		//new samples.Particles4(scene);
		//new samples.MaterialsLibTest(scene);	
		//new samples.ReflectionProbeTest(scene);
		//new samples.IcoSphereTest(scene);
		//new samples.PBRMaterialTest1(scene);
		//new samples.PBRMaterialTest2(scene);	
		//new samples.PBRMaterialTest3(scene);
		//new samples.PBRMaterialTest4(scene);
		//new samples.PBRMaterialTest5(scene);
		//new samples.TorusThing(scene);
		//new samples.StarfieldMaterialTest(scene);
		//new samples.FeaturedDemo1(scene);
		//new samples.GlosinessAndRoughness(scene);
		//new samples.FurMat(scene);
		//new samples.HaxedNES(scene);
		//new samples.RefractionMaterial(scene);
		//new samples.SponzaDynamicShadows(scene);
		//new samples.RefractReflect(scene);
		//new samples.Mario(scene);
	}
		
	override function onmousedown(x:Int, y:Int, button:Int, timestamp:Float, window_id:Int) {
		for(f in Engine.mouseDown) {
			f(x, y, button);
		}
	}
	
	override function onmouseup(x:Int, y:Int, button:Int, timestamp:Float, window_id:Int) {
		for(f in Engine.mouseUp) {
			f(x, y, button);
		}
	}
	
	override function onmousemove(x:Int, y:Int, xrel:Int, yrel:Int, timestamp:Float, window_id:Int) {
		for(f in Engine.mouseMove) {
			f(x, y);
		}
	}
	
	override function onmousewheel(x:Float, y:Float, timestamp:Float, window_id:Int) {
		for (f in Engine.mouseWheel) {
			f(y);
		}
	}
	
	/*override function ontouchdown(x:Float, y:Float, touch_id:Int, timestamp:Float) {
		for (f in Engine.touchDown) {
			f(x, y, touch_id, timestamp);
		}
	}
	
	override function ontouchup(x:Float, y:Float, touch_id:Int, timestamp:Float) {
		for (f in Engine.touchUp) {
			f(x, y, touch_id, timestamp);
		}
	}*/
	
	override function ontouchmove(x:Float, y:Float, dx:Float, dy:Float, touch_id:Int, timestamp:Float) {
		for (f in Engine.touchMove) {
			f(x, y, dx, dy, touch_id, timestamp);
		}
	}

	override function onkeyup(keycode:Int, scancode:Int, repeat:Bool, mod:ModState, timestamp:Float, window_id:Int) {
		if (keycode == Key.escape) {
			app.shutdown();
		}
		
		for(f in Engine.keyUp) {
			f(keycode);
		}
	}
	
	override function onkeydown(keycode:Int, scancode:Int, repeat:Bool, mod:ModState, timestamp:Float, window_id:Int) {
		for(f in Engine.keyDown) {
			f(keycode);
		}
	}
	
	override public function onevent(event:SystemEvent) {
        if(event.window != null) {
            if (event.window.type == we_size_changed || event.window.type == we_resized) {
				Engine.width = event.window.x;
				Engine.height = event.window.y;
				resize();
            }
        }
    }

	override function tick(delta:Float) {
		engine._renderLoop();
	}
	
	private function resize() {
		engine.setSize(Std.int(Engine.width / engine.getHardwareScalingLevel()), Std.int(Engine.height / engine.getHardwareScalingLevel()));
	}
	
}
