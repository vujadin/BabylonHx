package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.collisions.PickingInfo;
import com.babylonhx.lights.PointLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;
import com.babylonhx.tools.Tools;

/**
 * ...
 * @author Krtolica Vujadin
 */
class DragAndDrop {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 0, 0, 10, new Vector3(0, 0, 0), scene);
		camera.setPosition(new Vector3(20, 200, 400));

		camera.lowerBetaLimit = 0.1;
		camera.upperBetaLimit = (Math.PI / 2) * 0.99;
		camera.lowerRadiusLimit = 150;

		scene.clearColor = new Color3(0, 0, 0);

		// Light
		var light = new PointLight("omni", new Vector3(0, 50, 0), scene);

		// Ground
		var ground = Mesh.CreateGround("ground", 1000, 1000, 1, scene, false);
		var groundMaterial = new StandardMaterial("ground", scene);
		groundMaterial.specularColor = Color3.Black();
		ground.material = groundMaterial;

		// Meshes
		var redSphere = Mesh.CreateSphere("red", 32, 20, scene);
		var redMat = new StandardMaterial("ground", scene);
		redMat.diffuseColor = new Color3(0.4, 0.4, 0.4);
		redMat.specularColor = new Color3(0.4, 0.4, 0.4);
		redMat.emissiveColor = Color3.Red();
		redSphere.material = redMat;
		redSphere.position.y = 10;
		redSphere.position.x -= 100;

		var greenBox = Mesh.CreateBox("green", 20, scene);
		var greenMat = new StandardMaterial("ground", scene);
		greenMat.diffuseColor = new Color3(0.4, 0.4, 0.4);
		greenMat.specularColor = new Color3(0.4, 0.4, 0.4);
		greenMat.emissiveColor = Color3.Green();
		greenBox.material = greenMat;
		greenBox.position.z -= 100;
		greenBox.position.y = 10;

		var blueBox = Mesh.CreateBox("blue", 20, scene);
		var blueMat = new StandardMaterial("ground", scene);
		blueMat.diffuseColor = new Color3(0.4, 0.4, 0.4);
		blueMat.specularColor = new Color3(0.4, 0.4, 0.4);
		blueMat.emissiveColor = Color3.Blue();
		blueBox.material = blueMat;
		blueBox.position.x += 100;
		blueBox.position.y = 10;


		var purpleDonut = Mesh.CreateTorus("red", 30, 10, 32, scene);
		var purpleMat = new StandardMaterial("ground", scene);
		purpleMat.diffuseColor = new Color3(0.4, 0.4, 0.4);
		purpleMat.specularColor = new Color3(0.4, 0.4, 0.4);
		purpleMat.emissiveColor = Color3.Purple();
		purpleDonut.material = purpleMat;
		purpleDonut.position.y = 10;
		purpleDonut.position.z += 100;

		// Events
		var startingPoint:Vector3 = Vector3.Zero();
		var currentMesh:Mesh = null;

		var getGroundPosition = function (x:Float, y:Float) {
			// Use a predicate to get position on the ground
			var pickinfo:PickingInfo = scene.pick(x, y, function (mesh) { return mesh == ground; });
			if (pickinfo.hit) {
				return pickinfo.pickedPoint;
			}

			return null;
		};

		var onPointerDown = function (x:Float, y:Float, button:Int) {
			if (button != 0) {
				return;
			}

			// check if we are under a mesh
			var pickInfo = scene.pick(x, y, function (mesh) { return mesh != ground; });
			if (pickInfo.hit) {
				currentMesh = pickInfo.pickedMesh;
				startingPoint = getGroundPosition(x, y);

				if (startingPoint) { // we need to disconnect camera from canvas
					Tools.delay(function () {
						camera.detachControl(this);
					}, 0);
				}
			}
		};

		var onPointerUp = function () {
			if (startingPoint) {
				camera.attachControl(this, true);
				startingPoint = null;
				return;
			}
		};

		var onPointerMove = function (evt) {
			if (!startingPoint) {
				return;
			}

			var current = getGroundPosition(evt);

			if (!current) {
				return;
			}

			var diff = current.subtract(startingPoint);
			currentMesh.position.addInPlace(diff);

			startingPoint = current;

		}

		canvas.addEventListener("pointerdown", onPointerDown, false);
		canvas.addEventListener("pointerup", onPointerUp, false);
		canvas.addEventListener("pointermove", onPointerMove, false);

		scene.onDispose = function () {
			canvas.removeEventListener("pointerdown", onPointerDown);
			canvas.removeEventListener("pointerup", onPointerUp);
			canvas.removeEventListener("pointermove", onPointerMove);
		}
	}
	
}
