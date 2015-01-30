package ;

import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;

import com.babylonhx.Engine;
import com.babylonhx.Scene;

import samples.CSGDemo;
import samples.DisplacementMap;
import samples.Bones;
import samples.CustomRenderTarget;
import samples.Lines;
import samples.PostprocessRefraction;
import samples.Environment;
import samples.Fog;
import samples.LensFlares;
import samples.LoadScene;
import samples.Physics;
import samples.Animations;
import samples.BasicElements;
import samples.BasicScene;
import samples.Collisions;
import samples.EasingFunctions;
import samples.Intersections;
import samples.Lights;
import samples.Materials;
import samples.MeshImport;
import samples.Particles;
import samples.ProceduralTextures;
import samples.RotationAndScaling;
import samples.PolygonMesh;
import samples.HeightMap;
import samples.Shadows;

/**
 * ...
 * @author Krtolica Vujadin
 */

class Main extends Sprite {
	
	var inited:Bool;
	var scene:Scene;
	var engine:Engine;
	
	function resize(e) {
		if (!inited) init();
		// else (resize or orientation change)
	}
	
	function init() {
		if (inited) return;
		inited = true;
		
		engine = new Engine(this, false);	
		scene = new Scene(engine);
		
		//new BasicScene(scene);
		//new BasicElements(scene);
		//new RotationAndScaling(scene);
		//new Materials(scene);
		//new Lights(scene);
		//new Animations(scene);
		//new Collisions(scene);
		//new Intersections(scene);
		//new Particles(scene);
		//new EasingFunctions(scene);
		//new ProceduralTextures(scene);
		//new MeshImport(scene);
		//new LoadScene(scene);
		//new CSGDemo(scene);
		//new Fog(scene);
		//new DisplacementMap(scene);
		//new Environment(scene);
		//new LensFlares(scene);
		//new Physics(scene);
		//new PolygonMesh(scene);
		//new CustomRenderTarget(scene);
		//new Lines(scene);
		//new Bones(scene);
		//new PostprocessRefraction(scene);
		//new Shadows(scene);
		new HeightMap(scene);
	}

	public function new() {
		super();	
		addEventListener(Event.ADDED_TO_STAGE, added);
	}

	function added(e) {
		removeEventListener(Event.ADDED_TO_STAGE, added);
		stage.addEventListener(Event.RESIZE, resize);
		#if ios
		haxe.Timer.delay(init, 100); // iOS 6
		#else
		init();
		#end
	}
	
	public static function main() {
		// static entry point
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Main());
	}
}
