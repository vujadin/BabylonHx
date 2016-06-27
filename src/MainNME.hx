package;

import nme.display.Stage;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.events.KeyboardEvent;
import nme.events.TouchEvent;
import nme.display.OpenGLView;
import nme.display.FPS;
import nme.Lib;

import com.babylonhx.Engine;
import com.babylonhx.Scene;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Space;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.math.Vector3;
import com.babylonhx.cameras.Camera;
import com.babylonhx.cameras.FollowCamera;
import com.babylonhx.cameras.ArcFollowCamera;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.PointLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.sprites.Sprite;
import com.babylonhx.sprites.SpriteManager;
import com.babylonhx.animations.Animation;
import com.babylonhx.animations.easing.CircleEase;
import com.babylonhx.animations.easing.EasingFunction;
import com.babylonhx.animations.Animation.BabylonFrame;
import com.babylonhx.loading.plugins.BabylonFileLoader;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.layer.Layer;

/**
 * ...
 * @author Krtolica Vujadin
 */

class MainNME extends nme.display.Sprite {
	
	var scene:Scene;
	var engine:Engine;
	
	
	public function new() {
		super();
		
		Lib.current.stage.addChild(this);
		
		engine = new Engine(this, false);	
		scene = new Scene(engine);
		
		Engine.width = Lib.current.stage.stageWidth;
		Engine.height = Lib.current.stage.stageHeight;
		
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
		
		// currently needed to render bhx scene, doesn't actualy enables 2D rendering...
		enableNME2D();
	}
	
	private function enableNME2D():Void {
		var openflCameraMask:Int = 0xF0E1D2;
		var mainCamera = scene.activeCamera;
		if (scene.activeCameras.indexOf(mainCamera) == -1) {
			scene.activeCameras.push(mainCamera);
		}
		var openflCamera = new FreeCamera("openfl_nme_dummycamera", new Vector3(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY), scene);
		openflCamera.fov = 0;
        openflCamera.layerMask = openflCameraMask; 
		var openflDummyMesh = Mesh.CreatePlane("openfl_nme_dummymesh", 0.1, scene);
		var openflDummyMaterial = new StandardMaterial("openfl_nme_DummyMaterial", scene);
        openflDummyMaterial.backFaceCulling = false;
		openflDummyMesh.material = openflDummyMaterial;
		openflDummyMesh.layerMask = openflCameraMask;
		scene.activeCameras.push(openflCamera);
	}
	
	function createDemo() {
		new samples.BasicScene(scene);
		//new samples.BasicElements(scene);
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
	}
	
	function resize(e){
		Engine.width = Lib.current.stage.stageWidth;
		Engine.height = Lib.current.stage.stageHeight;
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
