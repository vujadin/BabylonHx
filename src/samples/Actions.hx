package samples;

import com.babylonhx.actions.ActionManager;
import com.babylonhx.actions.CombineAction;
import com.babylonhx.actions.DoNothingAction;
import com.babylonhx.actions.IncrementValueAction;
import com.babylonhx.actions.InterpolateValueAction;
import com.babylonhx.actions.SetStateAction;
import com.babylonhx.actions.SetValueAction;
import com.babylonhx.actions.StateCondition;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.PointLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Actions {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 0, 0, 10, new Vector3(0, 0, 0), scene);
		camera.setPosition(new Vector3(20, 200, 400));
		camera.attachControl(this, true);


		camera.lowerBetaLimit = 0.1;
		camera.upperBetaLimit = (Math.PI / 2) * 0.99;
		camera.lowerRadiusLimit = 150;

		scene.clearColor = new Color3(0, 0, 0);

		var light1 = new PointLight("omni", new Vector3(0, 50, 0), scene);
		var light2 = new PointLight("omni", new Vector3(0, 50, 0), scene);
		var light3 = new PointLight("omni", new Vector3(0, 50, 0), scene);

		light1.diffuse = Color3.Red();
		light2.diffuse = Color3.Green();
		light3.diffuse = Color3.Blue();

		// Define states
		light1.state = "on";
		light2.state = "on";
		light3.state = "on";

		// Ground
		var ground = Mesh.CreateGround("ground", 1000, 1000, 1, scene, false);
		var groundMaterial = new StandardMaterial("ground", scene);
		groundMaterial.specularColor = Color3.Black();
		ground.material = groundMaterial;

		// Boxes
		var redBox = Mesh.CreateBox("red", 20, scene);
		var redMat = new StandardMaterial("ground", scene);
		redMat.diffuseColor = new Color3(0.4, 0.4, 0.4);
		redMat.specularColor = new Color3(0.4, 0.4, 0.4);
		redMat.emissiveColor = Color3.Red();
		redBox.material = redMat;
		redBox.position.x -= 100;

		var greenBox = Mesh.CreateBox("green", 20, scene);
		var greenMat = new StandardMaterial("ground", scene);
		greenMat.diffuseColor = new Color3(0.4, 0.4, 0.4);
		greenMat.specularColor = new Color3(0.4, 0.4, 0.4);
		greenMat.emissiveColor = Color3.Green();
		greenBox.material = greenMat;
		greenBox.position.z -= 100;

		var blueBox = Mesh.CreateBox("blue", 20, scene);
		var blueMat = new StandardMaterial("ground", scene);
		blueMat.diffuseColor = new Color3(0.4, 0.4, 0.4);
		blueMat.specularColor = new Color3(0.4, 0.4, 0.4);
		blueMat.emissiveColor = Color3.Blue();
		blueBox.material = blueMat;
		blueBox.position.x += 100;

		// Sphere
		var sphere = Mesh.CreateSphere("sphere", 16, 20, scene);
		var sphereMat = new StandardMaterial("ground", scene);
		sphereMat.diffuseColor = new Color3(0.4, 0.4, 0.4);
		sphereMat.specularColor = new Color3(0.4, 0.4, 0.4);
		sphereMat.emissiveColor = Color3.Purple();
		sphere.material = sphereMat;
		sphere.position.z += 100;

		// Rotating donut
		var donut = Mesh.CreateTorus("donut", 20, 8, 16, scene);

		// On pick interpolations
		var prepareButton = function (mesh:Mesh, color:Color3, light:PointLight) {
			var goToColorAction = new InterpolateValueAction(ActionManager.OnPickTrigger, light, "diffuse", color, 1000, null, true);

			mesh.actionManager = new ActionManager(scene);
			mesh.actionManager.registerAction(
				new InterpolateValueAction(ActionManager.OnPickTrigger, light, "diffuse", Color3.Black(), 1000))
				.then(new CombineAction(ActionManager.NothingTrigger, [ 
					// Then is used to add a child action used alternatively with the root action. 
					goToColorAction,                                                 
					// First click: root action. Second click: child action. 			
					// Third click: going back to root action and so on...   
					new SetValueAction(ActionManager.NothingTrigger, mesh.material, "wireframe", false)
				]));
			mesh.actionManager.registerAction(new SetValueAction(ActionManager.OnPickTrigger, mesh.material, "wireframe", true))
				.then(new DoNothingAction());
			mesh.actionManager.registerAction(new SetStateAction(ActionManager.OnPickTrigger, light, "off"))
				.then(new SetStateAction(ActionManager.OnPickTrigger, light, "on"));
		};

		prepareButton(redBox, Color3.Red(), light1);
		prepareButton(greenBox, Color3.Green(), light2);
		prepareButton(blueBox, Color3.Blue(), light3);

		// Conditions
		sphere.actionManager = new ActionManager(scene);
		var condition1 = new StateCondition(sphere.actionManager, light1, "off");
		var condition2 = new StateCondition(sphere.actionManager, light1, "on");

		sphere.actionManager.registerAction(new InterpolateValueAction(ActionManager.OnLeftPickTrigger, camera, "alpha", 0, 500, condition1));
		sphere.actionManager.registerAction(new InterpolateValueAction(ActionManager.OnLeftPickTrigger, camera, "alpha", Math.PI, 500, condition2));

		// Over/Out
		var makeOverOut = function (mesh:Mesh) {
			mesh.actionManager.registerAction(new SetValueAction(ActionManager.OnPointerOutTrigger, mesh.material, "emissiveColor", cast(mesh.material, StandardMaterial).emissiveColor));
			mesh.actionManager.registerAction(new SetValueAction(ActionManager.OnPointerOverTrigger, mesh.material, "emissiveColor", Color3.White()));
			mesh.actionManager.registerAction(new InterpolateValueAction(ActionManager.OnPointerOutTrigger, mesh, "scaling", new Vector3(1, 1, 1), 150));
			mesh.actionManager.registerAction(new InterpolateValueAction(ActionManager.OnPointerOverTrigger, mesh, "scaling", new Vector3(1.1, 1.1, 1.1), 150));
		};

		makeOverOut(redBox);
		makeOverOut(greenBox);
		makeOverOut(blueBox);
		makeOverOut(sphere);

		// scene's actions
		scene.actionManager = new ActionManager(scene);

		var rotate = function (mesh:Mesh) {
			scene.actionManager.registerAction(new IncrementValueAction(ActionManager.OnEveryFrameTrigger, mesh, "rotation.y", 0.01));
		};

		rotate(redBox);
		rotate(greenBox);
		rotate(blueBox);

		// Intersections
		donut.actionManager = new ActionManager(scene);

		donut.actionManager.registerAction(new SetValueAction(
			{ trigger: ActionManager.OnIntersectionEnterTrigger, parameter: sphere },
			donut, "scaling", new Vector3(1.2, 1.2, 1.2)));

		donut.actionManager.registerAction(new SetValueAction(
			{ trigger: ActionManager.OnIntersectionExitTrigger, parameter: sphere }
			, donut, "scaling", new Vector3(1, 1, 1)));
			
		com.babylonhx.Engine.mouseDown.push(scene._onPointerDown);

		// Animations
		var alpha = 0.0;
		scene.registerBeforeRender(function () {
			donut.position.x = 100 * Math.cos(alpha);
			donut.position.y = 5;
			donut.position.z = 100 * Math.sin(alpha);
			alpha += 0.01;
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
