package;

import snow.types.Types;

import com.babylonhx.Engine;
import com.babylonhx.Scene;


class MainSnow extends snow.App {
	
	var engine:Engine;
	var scene:Scene;
	
	override function config(config:AppConfig):AppConfig {
		config.window.title = 'BabylonHx_Snow';
		return config;
	}

	override function ready() {
				
		engine = new Engine(SnowApp._snow.window);
		scene = new Scene(engine);
		
		new samples.BasicScene(scene);
		//new samples.BasicElements(scene);
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
		//new samples.Physics(scene);
		//new samples.PolygonMesh(scene);
		//new samples.CustomRenderTarget(scene);
		//new samples.Lines(scene);
		//new samples.Bones(scene);
		//new samples.PostprocessRefraction(scene);
		//new samples.Shadows(scene);
		//new samples.HeightMap(scene);
		//new samples.LoadObjFile(scene);
		//new samples.LOD(scene);
		//new samples.Instances(scene);
		//new samples.Fresnel(scene);
		//new samples.PostprocessConvolution(scene);
		//new samples.VolumetricLights(scene);
		//new samples.CellShading(scene);
		//new samples.Particles(scene);
		//new samples.Particles2(scene);
		//new samples.Extrusion(scene);
		//new samples.Sprites(scene);
		//new samples.PostprocessBloom(scene);
		//new samples.Actions(scene);
		//new samples.Picking(scene);
		//new samples.Particles3(scene);
		//new samples.Octree(scene);
		//new samples.SSAO(scene);						// NOT WORKING YET !!
		//new samples.Decals(scene);
		
		app.window.onrender = render;
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
	
	override function onmousewheel(x:Int, y:Int, timestamp:Float, window_id:Int) {
		for (f in Engine.mouseWheel) {
			f(y);
		}
	}
	
	override function ontouchdown(x:Float, y:Float, touch_id:Int, timestamp:Float) {
		for (f in Engine.touchDown) {
			f(x, y, touch_id, timestamp);
		}
	}
	
	override function ontouchup(x:Float, y:Float, touch_id:Int, timestamp:Float) {
		for (f in Engine.touchUp) {
			f(x, y, touch_id, timestamp);
		}
	}
	
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

	function render(window:snow.system.window.Window) {
		engine._renderLoop();
	}
}
