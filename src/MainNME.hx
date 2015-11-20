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
import com.babylonhx.materials.PBRMaterial;
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

import org.collisionhaxe.Actor;
import org.collisionhaxe.Game;
import org.collisionhaxe.BoundingBox;

/**
 * ...
 * @author Krtolica Vujadin
 */

class MainNME extends nme.display.Sprite {
	
	var scene:Scene;
	var engine:Engine;
	var followCam:ArcRotateCamera;
	
	var randomActors:Array<Actor> = [];
	var keys = { left: false, right: false, up: false, space: false };
	var player:Actor;
	var jumpPower:Sprite;
	var actors:Array<Actor> = [];
	var game:Game;
	
	var gravity:Int = 800;
	
	
	public function new() {
		super();
		
		Lib.current.stage.addChild(this);
		
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
		//new samples.Fog(scene);
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
		new samples.PointLightShadow(scene);
	}
	
	function initGame(newMeshes:Array<AbstractMesh>, newParticles:Array<ParticleSystem>, newSkeletons:Array<Skeleton>) {
		scene.beginAnimation(newSkeletons[0], 14, 86, true, 0.8);
		
		//new Layer("background", "assets/img/bkg.jpg", scene, true);
		
		var light = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
		//var light = new DirectionalLight("dir01", new Vector3(0, -1, -0.8), scene);
		//var light0 = new PointLight("Omni0", new Vector3(21.84, 50, -28.26), scene);
		//light0.intensity = 5;
				
		var ac = new org.collisionhaxe.Actor(new org.collisionhaxe.BoundingBox(520, 380, 30, 5), 0, 0, true);
		ac.mesh = Mesh.CreateBox("box", { width: 30, height: 5, depth: 20 }, scene);
		randomActors.push(ac);
		
		var minPoleGap = 80;
		var maxPoleGap = 250;
		
		var lastPoleX = 520;
		for (i in 0...200) {
			var xOffset = getRandomInt(minPoleGap, maxPoleGap);
			var x = lastPoleX - xOffset;
			lastPoleX -= xOffset;
			var y = getRandomInt(250, 380);
			var w = 30;
			var h = 5;
			var actor = new org.collisionhaxe.Actor(new org.collisionhaxe.BoundingBox(x, y, w, h), 0, 0, true);
			actor.mesh = cast(ac.mesh, Mesh).createInstance("inst" + i);
			actor.mesh.position.x = x;
			actor.mesh.position.y = y;
			randomActors.push(actor);
		}		
		
		player = new org.collisionhaxe.Actor(new org.collisionhaxe.BoundingBox(520, 1100, 20, 30), 0, 0, false);
		player.mesh = newMeshes[0];
		//player.mesh = Mesh.CreateBox("player", { width: 20, height: 30, depth: 10 }, scene);
		player.mesh.rotation.y = Math.PI / 2;
		player.mesh.scaling.scaleInPlace(0.2);
		player.mesh.setPositionWithLocalVector(new Vector3(0, 0, -100));
		
		actors = randomActors.concat([player]);
		
		/*var playerMaterial = new StandardMaterial("playermat", scene);
		playerMaterial.diffuseColor = Color3.Green();
		player.mesh.material = playerMaterial;*/
		
		var spriteManager = new SpriteManager("powerbarmanager", "assets/img/disp2.jpg", 8, 8, scene); 
		jumpPower = new Sprite("jumpPower", spriteManager);
		jumpPower.width = 0;
		jumpPower.height = 4;
		
		followCam = new ArcRotateCamera("cam", 1.75, 1.4, 350, player.mesh, scene);
		
		//var followCam = new ArcFollowCamera("Camera", 1.650, 1.1, 350, player.mesh, scene);
		//followCam.position = new Vector3(530.92, 483.27, 1417.86);
		
		// Let's add a Follow Camera.
		// It is set initially very far from the roller-coaster
		// in order to get an "approach"" effect on start 
		/*followCam = new FollowCamera("fcam", new Vector3(20, 800, -800), scene);
		followCam.target = player.mesh;
		followCam.maxCameraSpeed = 1;
		followCam.rotationOffset = 250;
		followCam.radius = 450;
		followCam.cameraAcceleration = 0.02;
		followCam.maxCameraSpeed = 3;
		followCam.heightOffset = 60;*/
		
		/*var camera = new FreeCamera("Camera", new Vector3(530.92, 483.27, 1417.86), scene);
		camera.rotation = new Vector3(0.0, 3.18, 0);
		*/
		followCam.attachControl();
		
		// Skybox
		/*var skybox = Mesh.CreateBox("skyBox", 1000.0, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.diffuseColor = Color3.Yellow();
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/skybox", scene);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		skybox.material = skyboxMaterial;
		skybox.infiniteDistance = true;*/
		
		
		//var a = new Animation("a", "rotation.z", 30, Animation.ANIMATIONTYPE_FLOAT, Animation.ANIMATIONLOOPMODE_CYCLE); 
		//var keys:Array<BabylonFrame> = [];
		//keys.push({ frame: 0, value: 0 });
		//keys.push({ frame: 20, value: 2 * Math.PI });
		//a.setKeys(keys);	   
		//var easingFunction = new CircleEase();
		//easingFunction.setEasingMode(EasingFunction.EASINGMODE_EASEINOUT);
		//a.setEasingFunction(easingFunction); 
		//player.mesh.animations.push(a);	
	   
				
		game = new org.collisionhaxe.Game(actors);
		
		Engine.mouseDown.push(jumpPrepare);
		Engine.mouseUp.push(jump);
		#if mobile
		Engine.touchDown.push(jumpPrepare);
		Engine.touchUp.push(jump);
		#end
		
		trace(" ok ");
		
		scene.getEngine().runRenderLoop(function () {
			game.loop(engine.getDeltaTime() / 1000);
			
			player.velocityY -= gravity * (engine.getDeltaTime() / 1000);
			
			for(actor in game.actors) {
				actor.mesh.position.x = actor.boundingBox.x;
				actor.mesh.position.y = actor.boundingBox.y;
			}
			
			if (keys.left) {
				player.velocityX += 10;
				if (player.velocityX > 200) {
					player.velocityX = 200;
				}
			}
			else if (keys.right || player.isJumping) {
				/*player.velocityX -= 10;
				if (player.velocityX < -200) {
					player.velocityX = -200;
				}*/
				if (!player.isFalling) {
					player.velocityX = -finalXForce;
				}
			}
			else {
				player.velocityX = 0;
			}
			
			player.mesh.position.x = player.boundingBox.x;
			player.mesh.position.y = player.boundingBox.y - 15;
			
			if (player.mesh.position.y < -500) {
				player.isFalling = true;
				player.boundingBox.y = 700;
				player.boundingBox.x = 520;
				player.velocityX = 0;
				followCam.position.set(366, 442, 422);
			}
			
			jumpPower.position.x = player.mesh.position.x + 5 - (jumpPower.width / 2);
			jumpPower.position.y = player.mesh.position.y + 40;
			
			if (isMouseDown) {
				if (jumpPower.width < 30) {
					jumpPower.width += 0.3;
				}
			}
			
			if (followCam != null) {
				cast(followCam, ArcRotateCamera).target = player.mesh.position;// .subtract(offVec);
			}
			
			scene.render();
		});
	}
	
	var isMouseDown:Bool = false;
	function jumpPrepare() {
		if (!player.isJumping) {
			isMouseDown = true;
		}
	}
	
	var finalXForce:Float = 0;
	function jump() {		
		if (!player.isJumping) {
			//scene.beginAnimation(player.mesh, 0, 20, false);
			isMouseDown = false;
			player.isJumping = true;			
			finalXForce = (jumpPower.width / 0.2) * 4.7;
			player.velocityY = 200 + finalXForce;
			jumpPower.width = 0;
		}
	}
	
	function getRandomInt(min:Int, max:Int):Int {
		return Math.floor(Math.random() * (max - min + 1)) + min;
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
