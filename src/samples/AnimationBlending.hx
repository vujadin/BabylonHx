package samples;

import com.babylonhx.lights.PointLight;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.animations.Animation;
import com.babylonhx.Scene;
import com.babylonhx.Engine;

/**
 * ...
 * @author Krtolica Vujadin
 */
class AnimationBlending {

	public function new(scene:Scene) {
		var light = new PointLight("Omni", new Vector3(0, 100, 100), scene);
		var camera = new ArcRotateCamera("Camera", 0, 0.8, 100, Vector3.Zero(), scene);
		camera.attachControl();

		//Boxes
		var box1 = Mesh.CreateBox("Box1", 10.0, scene);
		box1.position.x = -20;

		var materialBox = new StandardMaterial("texture1", scene);
		materialBox.diffuseColor = new Color3(0, 1, 0);//Green

		//Applying materials
		box1.material = materialBox;

		// Creation of a basic animation with box 1
		//----------------------------------------

		var animationBox = new Animation("tutoAnimation", "position.z", 30, Animation.ANIMATIONTYPE_FLOAT,
																		Animation.ANIMATIONLOOPMODE_CYCLE);
		// Animation keys
		var keys = [];
		keys.push({
			frame: 0,
			value: 0
		});

		keys.push({
			frame: 20,
			value: 10
		});

		keys.push({
			frame: 100,
			value: -20
		});

		animationBox.setKeys(keys);

		box1.animations.push(animationBox);

		scene.beginAnimation(box1, 0, 100, true);
		
		// Blending animation
		var animation2Box = new Animation("tutoAnimation", "position.z", 30, Animation.ANIMATIONTYPE_FLOAT,
		Animation.ANIMATIONLOOPMODE_CYCLE);
																	
		animation2Box.enableBlending = true;
		animation2Box.blendingSpeed = 0.01;
		// Animation keys
		var keys = [];
		keys.push({
			frame: 0,
			value: 0
		});

		keys.push({
			frame: 20,
			value: 10
		});

		keys.push({
			frame: 100,
			value: -30
		});

		animation2Box.setKeys(keys);
		
		Engine.mouseDown.push(function (btn:Int) {
			scene.stopAnimation(box1);
			scene.beginDirectAnimation(box1, [animation2Box], 0, 100, true);
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
