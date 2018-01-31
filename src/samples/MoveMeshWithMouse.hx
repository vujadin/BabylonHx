package samples;

import com.babylonhx.Scene;
import com.babylonhx.cameras.TargetCamera;
import com.babylonhx.math.Angle;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;

/**
 * ...
 * @author Krtolica Vujadin
 */
class MoveMeshWithMouse {

	public function new(scene:Scene) {
		var camera = new TargetCamera("Perspective camera", new Vector3(0, 0, -10), scene);
		camera.fov = Angle.FromDegrees(45).radians();
		camera.minZ = 0.3;
		camera.maxZ = 100;
		camera.plane = Mesh.CreatePlane("Plane", 1000, scene);
		camera.plane.isVisible = false;
		camera.plane.parent = camera;
		camera.screenToWorld = function (x, y, depth, position) {
			this.plane.position.z = depth;
			var name = this.plane.name;
			var info = this.getScene().pick(x, y, function (mesh:Mesh) {
				return (mesh.name == name);
			}, true, this);
			position.copyFrom(info.hit ? info.pickedPoint : position);
		};

		var ambientLight = new HemisphericLight("Global ambient", Vector3.Up(), scene);
		ambientLight.diffuse = Color3.FromInts(51, 51, 51);
		var directionalLight = new DirectionalLight("Directional light", new Vector3(0, -1, Math.tan(Angle.FromDegrees(34.57).radians())), scene);

		var whiteMaterial = new StandardMaterial("White material", scene);
		whiteMaterial.diffuseColor = Color3.FromInts(253, 246, 246);
		var colors = {
			red: Color3.FromInts(247, 12, 12),
			green: Color3.FromInts(7, 152, 73),
			blue: Color3.FromInts(60, 82, 207)
		};

		var box = Mesh.CreateBox("Box", 1, scene);
		box.material = whiteMaterial;

		canvas.oncontextmenu = function (event) {
			event.preventDefault();
		};

		var position = new Vector3();
		canvas.onmousemove = function (event) {
			var depth = 10;
			camera.screenToWorld(event.x, event.y, depth, position);
			box.position.copyFrom(position);
		};

		var Mouse = {
			LEFT: 0,
			MIDDLE: 1,
			RIGHT: 2
		};
		canvas.onmousedown = function (event) {
			if (event.button === Mouse.LEFT) {
				box.material.diffuseColor = colors.red;
			} else if (event.button === Mouse.MIDDLE) {
				box.material.diffuseColor = colors.green;
			} else if (event.button === Mouse.RIGHT) {
				box.material.diffuseColor = colors.blue;
			}
		};
	}
	
}
