package samples;

import com.babylonhx.Scene;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.VertexData;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Scalar;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.StandardMaterial;

import lime.utils.Float32Array;
import lime.utils.UInt32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
class HexIcoSphere {

	public function new(scene:Scene) {
		var camera = new FreeCamera("camera1", Vector3(0, 0, -2.8), scene);		
		camera.setTarget(Vector3.Zero());
		camera.attachControl();
		
		// Create a Sun & Moon
		var sun = new HemisphericLight("sun", Vector3(0, 1.0, 0), scene);
		sun.intensity = 0.96;
		var moon = new HemisphericLight("moon", Vector3(0, -1.0, 0), scene);
		moon.intensity = 0.25;
		
		// Create the icosphere
		var hexIcosphere = _createHexIcosphere(10, 20.0, scene);
		
		scene.registerBeforeRender(function(_, _) {
			hexIcosphere.rotation.y += -0.0005 * scene->getAnimationRatio();
			hexIcosphere.rotation.x += (-0.0005 / 4.0) * scene->getAnimationRatio();
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
	function _createHexIcosphere(degree:Float, scale:Float, scene:Scene):Mesh {
		var material = new StandardMaterial("mat", scene);
		Extensions::XorShift128 random;
		Extensions::IcosahedronMesh icosahedronMesh
		= Extensions::Icosphere::generateIcosahedronMesh(degree, scale, random);

		Uint32Array indices;
		Float32Array colors;
		Float32Array positions;

		// Generate dual polyhedron position and face indices
		for (auto& node : icosahedronMesh.nodes) {
		unsigned int relativeZeroIndex
		  = static_cast<unsigned int>(positions.size() / 3);

		const auto rand = Math::randomList(0.f, 1.f, 2);
		const Color3 color(0.f, rand[0] * 0.5f, rand[1] * 1.f);

		// Get all the centroids of the faces adjacent to this vertex
		for (auto& fi : node.f) {
		  const Vector3& centroid = icosahedronMesh.faces[fi].centroid;
		  stl_util::concat(positions, {centroid.x, centroid.y, centroid.z});
		  stl_util::concat(colors, {color.r, color.g, color.b, 1.f});
		}

		for (unsigned int i = relativeZeroIndex; i < (positions.size() / 3) - 2;
			 ++i) {
		  stl_util::concat(indices, {relativeZeroIndex, i + 1, i + 2});
		}
		}

		auto mesh = Mesh::New("planet", scene);
		mesh->setUseVertexColors(true);

		auto vertexData       = std::make_unique<VertexData>();
		vertexData->indices   = std::move(indices);
		vertexData->positions = std::move(positions);
		vertexData->colors    = std::move(colors);

		Float32Array normals;
		VertexData::ComputeNormals(positions, indices, normals);
		vertexData->normals = std::move(normals);
		vertexData->applyToMesh(mesh, false);

		mesh->setMaterial(material);

		return mesh;
	}
	
}
