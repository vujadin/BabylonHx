package;

import openfl.display.Bitmap;
import openfl.Assets;
import openfl.display.Stage;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.KeyboardEvent;
import openfl.events.TouchEvent;
import openfl.ui.Multitouch;
import openfl.ui.MultitouchInputMode;
import openfl.display.OpenGLView;
import openfl.Lib;
import openfl.display.FPS;

import com.babylonhx.Engine;
import com.babylonhx.Scene;
import com.babylonhx.math.Vector3;
import com.babylonhx.utils.Keycodes;

import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.cameras.Camera;

import com.babylonhx.bones.Skeleton;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.math.Color3;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.loading.plugins.BabylonFileLoader;

/**
 * ...
 * @author Krtolica Vujadin
 */

class MainOpenFL extends Sprite {
	
	var scene:Scene;
	var engine:Engine;
	
	
	public function new() {
		super();
		
		stage.addChild(this);
		
		engine = new Engine(stage, false);	
		scene = new Scene(engine);
		
		Engine.width = stage.stageWidth;
		Engine.height = stage.stageHeight;
		
		stage.addEventListener(Event.RESIZE, resize);
		stage.addEventListener(Event.ENTER_FRAME, update);
		
		#if desktop
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		#elseif mobile
		Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
		stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchStart);
		stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
		stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
		#end
		
		createDemo();
		
		enableOpenFL2D();
	}
	
	private function enableOpenFL2D():Void {
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
		
		stage.addChild(new openfl.display.FPS(10, 10, 0xffffff));
	}
	
	function resize(e) {
		Engine.width = stage.stageWidth;
		Engine.height = stage.stageHeight;
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
			f(e.localX, e.localY, e.touchPointID);
		}
	}
	
	function onTouchEnd(e:TouchEvent) {		
		for(f in Engine.touchUp) {
			f(e.localX, e.localY, e.touchPointID);
		}
	}	
	
	function onTouchMove(e:TouchEvent) {
		for(f in Engine.touchMove) {
			f(e.localX, e.localY);
		}		
	}
	
	function update(e) {
		engine._renderLoop();
	}
	
}
