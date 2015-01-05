package ;

import com.babylonhx.actions.ActionManager;
import com.babylonhx.actions.CombineAction;
import com.babylonhx.actions.DoNothingAction;
import com.babylonhx.actions.IncrementValueAction;
import com.babylonhx.actions.InterpolateValueAction;
import com.babylonhx.actions.SetStateAction;
import com.babylonhx.actions.SetValueAction;
import com.babylonhx.actions.StateCondition;
import com.babylonhx.animations.Animation;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.collisions.Collider;
import com.babylonhx.layer.Layer;
import com.babylonhx.lights.Light;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.loading.plugins.BabylonFileLoader;
import com.babylonhx.materials.FresnelParameters;
import com.babylonhx.materials.Material;
import com.babylonhx.materials.ShaderMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.RenderTargetTexture;
import com.babylonhx.materials.textures.procedurals.standard.WoodProceduralTexture;
import com.babylonhx.materials.textures.procedurals.standard.GrassProceduralTexture;
import com.babylonhx.materials.textures.procedurals.standard.MarbleProceduralTexture;
import com.babylonhx.materials.textures.procedurals.standard.FireProceduralTexture;
import com.babylonhx.materials.textures.procedurals.standard.CloudProceduralTexture;
import com.babylonhx.materials.textures.procedurals.standard.BrickProceduralTexture;
import com.babylonhx.materials.textures.procedurals.standard.RoadProceduralTexture;
import com.babylonhx.math.Matrix;
import com.babylonhx.mesh.VertexData;
import com.babylonhx.postprocess.RefractionPostProcess;
import com.babylonhx.sprites.SpriteManager;
import com.babylonhx.tools.Tools;
import openfl.display.FPS;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.cameras.Camera;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.Engine;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.lights.PointLight;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.materials.ShadersStore;
import com.babylonhx.Scene;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import openfl.system.System;
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
		
		//new MeshImport(scene);
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
		new ProceduralTextures(scene);
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
