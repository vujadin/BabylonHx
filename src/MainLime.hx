package;

import lime.app.Application;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.graphics.RenderContext;

import com.babylonhx.Engine;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */

class MainLime extends Application {
	
	var scene:Scene;
	var engine:Engine;
	
	
	public function new() {
		super();		
	}
	
	public override function init (context:RenderContext):Void {
		engine = new Engine(this, false);	
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
	}
	
	override function onMouseDown(x:Float, y:Float, button:Int) {
		for(f in Engine.mouseDown) {
			f(x, y);
		}
	}
	
	override function onMouseUp(x:Float, y:Float, button:Int) {
		for(f in Engine.mouseUp) {
			f();
		}
	}
	
	override function onMouseMove(x:Float, y:Float) {
		for(f in Engine.mouseMove) {
			f(x, y);
		}
	}
	
	override function onMouseWheel(deltaX:Float, deltaY:Float) {
		for (f in Engine.mouseWheel) {
			f(deltaY);
		}
	}
	
	override function onTouchStart(x:Float, y:Float, id:Int) {
		for (f in Engine.touchDown) {
			f(x, y, id);
		}
	}
	
	override function onTouchEnd(x:Float, y:Float, id:Int) {
		for (f in Engine.touchUp) {
			f(x, y, id);
		}
	}
	
	override function onTouchMove(x:Float, y:Float, id:Int) {
		for (f in Engine.touchMove) {
			f(x, y, id);
		}
	}

	override function onKeyUp(keycode:Int, modifier:KeyModifier) {
		for(f in Engine.keyUp) {
			f(keycode);
		}
	}
	
	override function onKeyDown(keycode:Int, modifier:KeyModifier) {
		for(f in Engine.keyDown) {
			f(keycode);
		}
	}
	
	override public function onWindowResize(width:Int, height:Int) {
		engine.width = this.window.width;
		engine.height = this.window.height;
	}
	
	override function update(deltaTime:Int) {
		if(engine != null) 
		engine._renderLoop();		
	}
	
}
