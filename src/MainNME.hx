package;

import nme.display.Stage;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.events.KeyboardEvent;
import nme.events.TouchEvent;
import nme.display.OpenGLView;
import nme.Lib;

import com.babylonhx.Engine;
import com.babylonhx.Scene;
import com.babylonhx.utils.Keycodes;

/**
 * ...
 * @author Krtolica Vujadin
 */

class MainNME extends Sprite {
	
	var scene:Scene;
	var engine:Engine;
	
	public function new() {
		super();
		
		Lib.current.addChild(this);
		
		engine = new Engine(this, false);	
		scene = new Scene(engine);
		
		engine.width = Lib.current.stage.stageWidth;
		engine.height = Lib.current.stage.stageHeight;
		
		Lib.current.stage.addEventListener(Event.RESIZE, resize);
		
		#if desktop
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		#elseif mobile
		Lib.current.stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchStart);
		Lib.current.stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
		Lib.current.stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
		#end
		
		createDemo();
	}
	
	function createDemo() {
		//new samples.BasicScene(scene);
		//new samples.BasicElements(scene);
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
		new samples.Fog(scene);
		//new samples.DisplacementMap(scene);
		//new samples.Environment(scene);
		//new samples.LensFlares(scene);
		//new samples.PhysicsCannon(scene);
		//new samples.Physics(scene);
		//new samples.Physics2(scene);
		//new samples.Physics_Pyramid(scene);
		//new samples.PhysicsSimple(scene);
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
		//new samples.DepthOfField(scene);
		//new samples.Actions(scene);
		//new samples.Picking(scene);		
		//new samples.Octree(scene);
		//new samples.SSAO(scene);						
		//new samples.Decals(scene);
		//new samples.InstancedBones(scene);				
		//new samples.AdvancedShadows(scene);
		//new samples.Ribbons(scene);
		//new samples.SoftShadows(scene);		
		//new samples.BabylonHxWebsiteScene(scene);
	}
	
	function resize(e){
		engine.width = Lib.current.stage.stageWidth;
		engine.height = Lib.current.stage.stageHeight;
	}
	
	function onKeyDown(e:KeyboardEvent) {
		for(f in Engine.keyDown) {
			f(e.charCode);
		}		
	}	
	
	function onKeyUp(e:KeyboardEvent) {
		for(f in Engine.keyUp) {
			f(e.charCode);
		}
	}	
	
	function onMouseDown(e:MouseEvent) {
		for(f in Engine.mouseDown) {
			f(e.localX, e.localY, 0);
		}
	}	
	
	function onMouseMove(e:MouseEvent) {
		for(f in Engine.mouseMove) {
			f(e.localX, e.localY);
		}
	}	
	
	function onMouseUp(e:MouseEvent) {
		for(f in Engine.mouseUp) {
			f(e.localX, e.localY, 0);
		}
	}
	
	function onMouseWheel(e:MouseEvent) {
		for (f in Engine.mouseWheel) {
			f(e.delta);
		}
	}
	
	function onTouchStart(e:TouchEvent) {
		for(f in Engine.touchDown) {
			f(e.localX, e.localY, 0);
		}
	}
	
	function onTouchEnd(e:TouchEvent) {		
		for(f in Engine.touchUp) {
			f(e.localX, e.localY, 0);
		}
	}	
	
	function onTouchMove(e:TouchEvent) {
		for(f in Engine.touchMove) {
			f(e.localX, e.localY);
		}		
	}		
	
}
