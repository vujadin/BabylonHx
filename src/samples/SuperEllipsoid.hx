package samples;

import com.babylonhx.Scene;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.VertexData;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Scalar;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.StandardMaterial;

import lime.utils.Float32Array;
import lime.utils.UInt32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
class SuperEllipsoid {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 0.0, Math.PI / 2, 12.0, Vector3.Zero(), scene);
		camera.setPosition(new Vector3( -5.0, 5.0, 5.0));
		camera.attachControl();
		
		// Add a light
		var light = new HemisphericLight("hemi", new Vector3(0.0, 1.0, 0.0), scene);
		light.intensity = 0.95;
		
		// Create super ellipsoid and material
		var mat          = new StandardMaterial("mat", scene);
		mat.diffuseColor = Color3.Purple();
		mat.backFaceCulling = false;
		var mat2          = new StandardMaterial("mat2", scene);
		mat2.diffuseColor = Color3.Red();
		mat2.backFaceCulling = false;
		var mat3          = new StandardMaterial("mat3", scene);
		mat3.diffuseColor = Color3.Green();
		mat3.backFaceCulling = false;
		var mat4          = new StandardMaterial("mat4", scene);
		mat4.diffuseColor = Color3.Blue();
		mat4.backFaceCulling = false;
		var mat5          = new StandardMaterial("mat5", scene);
		mat5.diffuseColor = Color3.Yellow();
		mat5.backFaceCulling = false;
		var superello1 = _createSuperEllipsoid(48, 0.2, 0.2, 1, 1, 1, scene);
		superello1.material = mat2;
		var superello2 = _createSuperEllipsoid(48, 0.2, 0.2, 1, 1, 1, scene);
		superello2.position.x += 2.5;
		superello2.material = mat;
		superello2.material.wireframe = true;
		var superello3 = _createSuperEllipsoid(48, 1.8, 0.2, 1, 1, 1, scene);
		superello3.position.x -= 2.5;
		superello3.material = mat3;
		var superello4 = _createSuperEllipsoid(48, 1.8, 0.2, 1, 1, 1, scene);
		superello4.position.z += 2.5;
		superello4.material = mat4;
		superello4.material.wireframe = true;
		var superello5 = _createSuperEllipsoid(48, 0.2, 2.9, 1, 1, 1, scene);
		superello5.position.z -= 2.5;
		superello5.material = mat5;
		
		trace('ddd');
		
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
	function _sampleSuperEllipsoid(phi:Float, beta:Float, n1:Float, n2:Float, scaleX:Float, scaleY:Float, scaleZ:Float) {
		var vertex:Vector3 = Vector3.Zero();
		var cosPhi  = Math.cos(phi);
		var cosBeta = Math.cos(beta);
		var sinPhi  = Math.sin(phi);
		var sinBeta = Math.sin(beta);
		vertex.x = scaleX * Scalar.Sign(cosPhi) * Math.pow(Math.abs(cosPhi), n1) * Scalar.Sign(cosBeta) * Math.pow(Math.abs(cosBeta), n2);
		vertex.z = scaleY * Scalar.Sign(cosPhi) * Math.pow(Math.abs(cosPhi), n1) * Scalar.Sign(sinBeta) * Math.pow(Math.abs(sinBeta), n2);
		vertex.y = scaleZ * Scalar.Sign(sinPhi) * Math.pow(Math.abs(sinPhi), n1);
		return vertex;
	}

	function _calculateNormal(phi:Float, beta:Float, n1:Float, n2:Float, scaleX:Float, scaleY:Float, scaleZ:Float) {
		var normal:Vector3 = Vector3.Zero();
		var cosPhi  = Math.cos(phi);
		var cosBeta = Math.cos(beta);
		var sinPhi  = Math.sin(phi);
		var sinBeta = Math.sin(beta);
		normal.x = Scalar.Sign(cosPhi) * Math.pow(Math.abs(cosPhi), 2 - n1) * Scalar.Sign(cosBeta) * Math.pow(Math.abs(cosBeta), 2 - n2) / scaleX;
		normal.z = Scalar.Sign(cosPhi) * Math.pow(Math.abs(cosPhi), 2 - n1) * Scalar.Sign(sinBeta) * Math.pow(Math.abs(sinBeta), 2 - n2) / scaleY;
		normal.y = Scalar.Sign(sinPhi) * Math.pow(Math.abs(sinPhi), 2 - n1) / scaleZ;
		normal.normalize();
		return normal;
	}

	function _createSuperEllipsoid(samples:Int, n1:Float, n2:Float, scalex:Float, scaley:Float, scalez:Float, scene:Scene):Mesh {
		var superello = new Mesh("superellipsoid", scene);
		var phi = 0.0;
		var beta = 0.0;
		var dB = Math.PI * 2 / samples;
		var dP = Math.PI * 2 / samples;
		phi = -Math.PI / 2;
		var vertices:Array<Vector3> = [];
		var normals:Array<Vector3> = [];
		for (j in 0...Std.int(samples / 2) + 1) {
			beta = -Math.PI;
			for (i in 0...samples + 1) {
				// Triangle #1
				vertices.push(_sampleSuperEllipsoid(phi, beta, n1, n2, scalex, scaley, scalez));
				normals.push(_calculateNormal(phi, beta, n1, n2, scalex, scaley, scalez));
				vertices.push(_sampleSuperEllipsoid(phi + dP, beta, n1, n2, scalex, scaley, scalez));
				normals.push(_calculateNormal(phi + dP, beta, n1, n2, scalex, scaley, scalez));
				vertices.push(_sampleSuperEllipsoid(phi + dP, beta + dB, n1, n2, scalex, scaley, scalez));
				normals.push(_calculateNormal(phi + dP, beta + dB, n1, n2, scalex, scaley, scalez));
				// Triangle #2
				vertices.push(_sampleSuperEllipsoid(phi, beta, n1, n2, scalex, scaley, scalez));
				normals.push(_calculateNormal(phi, beta, n1, n2, scalex, scaley, scalez));
				vertices.push(_sampleSuperEllipsoid(phi + dP, beta + dB, n1, n2, scalex, scaley, scalez));
				normals.push(_calculateNormal(phi + dP, beta + dB, n1, n2, scalex, scaley, scalez));
				vertices.push(_sampleSuperEllipsoid(phi, beta + dB, n1, n2, scalex, scaley, scalez));
				normals.push(_calculateNormal(phi, beta + dB, n1, n2, scalex, scaley, scalez));
				beta += dB;
			}
			phi += dP;
		}
		
		var indice:Int = 0;
		var pos:Array<Float> = [];
		var norm:Array<Float> = [];
		
		var _indices = new UInt32Array(vertices.length);

		for (i in 0...vertices.length) {
			_indices[i] = indice++;
			pos.push(vertices[i].x);
			pos.push(vertices[i].y);
			pos.push(vertices[i].z);
			norm.push(normals[i].x);
			norm.push(normals[i].y);
			norm.push(normals[i].z);
		}
		
		var vertexData = new VertexData();
		
		var _positions = new Float32Array(pos);	
		var _normals = new Float32Array(norm);
		
		vertexData.indices = _indices;
		vertexData.positions = _positions;
		vertexData.normals = _normals;
		
		vertexData.applyToMesh(superello);
		
		return superello;
	}
	
}
