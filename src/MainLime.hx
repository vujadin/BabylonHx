package;

#if cpp
//import hxtelemetry.HxTelemetry;
#end

import lime.app.Application;
import lime.Assets;
import lime.audio.AudioSource;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.graphics.RenderContext;
import lime.graphics.Renderer;
import lime.ui.Touch;
import lime.ui.Window;
import mario.def.SoundManager;

import com.babylonhx.Engine;
import com.babylonhx.Scene;


/**
 * ...
 * @author Krtolica Vujadin
 */

class MainLime extends Application {
	
	var scene:Scene;
	var engine:Engine;
	
	#if cpp
	//var hxt = new HxTelemetry();
	#end
	
	
	public function new() {
		super();
	}
	
	override public function onPreloadComplete():Void {
		engine = new Engine(window, true);	
		scene = new Scene(engine);
		
		//new samples.BasicScene(scene);
		new samples.BasicElements(scene);
		//new samples.DashedLinesMesh(scene);
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
		//new samples.AnimationBlending(scene);
		//new samples.GridMaterialTest(scene);
		//new samples.SkeletonViewerTest(scene);
		//new samples.Mario(scene);
		//new samples.LogarithmicDepth(scene);
		
		Engine.width = this.window.width;
		Engine.height = this.window.height;
	}
	
	override function onMouseDown(window:Window, x:Float, y:Float, button:Int) {
		for(f in Engine.mouseDown) {
			f(x, y, button);
		}
	}
	
	#if !neko
	override function onMouseUp(window:Window, x:Float, y:Float, button:Int) {
		for(f in Engine.mouseUp) {
			f();
		}
	}
	#end
	
	override function onMouseMove(window:Window, x:Float, y:Float) {
		for(f in Engine.mouseMove) {
			f(x, y);
		}
	}
	
	override function onMouseWheel(window:Window, deltaX:Float, deltaY:Float) {
		for (f in Engine.mouseWheel) {
			f(deltaY);
		}
	}
	
	override function onTouchStart(touch:Touch) {
		for (f in Engine.touchDown) {
			f(touch.x, touch.y, touch.id);
		}
	}
	
	override function onTouchEnd(touch:Touch) {
		for (f in Engine.touchUp) {
			f(touch.x, touch.y, touch.id);
		}
	}
	
	override function onTouchMove(touch:Touch) {
		for (f in Engine.touchMove) {
			f(touch.x, touch.y, touch.id);
		}
	}

	override function onKeyUp(window:Window, keycode:Int, modifier:KeyModifier) {
		for(f in Engine.keyUp) {
			f(keycode);
		}
	}
	
	override function onKeyDown(window:Window, keycode:Int, modifier:KeyModifier) {
		for(f in Engine.keyDown) {
			f(keycode);
		}
	}
	
	override public function onWindowResize(window:Window, width:Int, height:Int) {
		Engine.width = this.window.width;
		Engine.height = this.window.height;
		engine.resize();
	}
	
	override function update(deltaTime:Int) {
		#if cpp
		//hxt.advance_frame();
		#end
	}
	
	override public function render(renderer:Renderer) {
		engine._renderLoop();
	}
	
}
