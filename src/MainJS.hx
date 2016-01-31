package;

import js.Browser;
import js.Lib;
import js.html.Event;
import js.html.MouseEvent;
import js.html.TouchEvent;
import js.html.KeyboardEvent;
import js.html.CanvasElement;

import com.babylonhx.Engine;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.Main') class MainJS {
	
	var canvas:CanvasElement;
	var scene:Scene;
	var engine:Engine;
	
	
	static function main() {
		new MainJS();
	}
	
	public function new() {
		untyped Browser.navigator.isCocoonJS = true;
		canvas = Browser.document.createCanvasElement();
		canvas.width = Browser.window.innerWidth;
		canvas.height = Browser.window.innerHeight;
		Browser.document.body.appendChild(canvas);
		
		engine = new Engine(canvas, false);	
		engine.width = canvas.width;
		engine.height = canvas.height;
		scene = new Scene(engine);
				
		Browser.window.addEventListener("resize", resize);
		Browser.window.addEventListener("orientationchange", resize);
		
		canvas.addEventListener("mousedown", onMouseDown);
		canvas.addEventListener("mouseup", onMouseUp);
		canvas.addEventListener("mousemove", onMouseMove);
		canvas.addEventListener("mousewheel", onMouseWheel);
		canvas.addEventListener("keydown", onKeyDown);
		canvas.addEventListener("keyup", onKeyUp);
		
		startDemo();
	}
	
	function startDemo() {
		//new samples.BasicScene(scene);
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
		//new samples.PointLightShadow(scene);
		//new samples.FireMat(scene);
		//new samples.WaterMat(scene);
		//new samples.LavaMat(scene);
		//new samples.NormalMat(scene);
		new samples.PythagorianThrees(scene);
		//new samples.Particles4(scene);
	}
	
	function resize(e) {
		engine.resize();
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
			f(e.clientX, e.clientY, 0);
		}
	}	
	
	function onMouseMove(e:MouseEvent) {
		for(f in Engine.mouseMove) {
			f(e.clientX, e.clientY);
		}
	}	
	
	function onMouseUp(e:MouseEvent) {
		for(f in Engine.mouseUp) {
			f(e.clientX, e.clientY, 0);
		}
	}
	
	function onMouseWheel(e:MouseEvent) {
		for (f in Engine.mouseWheel) {
			f(e.detail);
		}
	}

	

	public function render ():Void {
		try{
			untyped __js__ ("requestAnimationFrame") (render);
			untyped __js__ ('CocoonJS_App_ForCocoonJS_WebViewIFrame.postMessage("update", "*");');
		}catch(e:Dynamic){
			trace(e);
		}
		
	}
	
}
