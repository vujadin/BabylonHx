package com.babylonhx.physics;

import com.babylonhx.Scene;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.math.Vector3;
import com.babylonhx.materials.Material;

import jiglib.math.Matrix3D;
import jiglib.math.Vector3D;
import jiglib.physics.RigidBody;
import jiglib.plugin.AbstractPhysics;
import jiglib.geometry.JBox;
import jiglib.geometry.JSphere;
import jiglib.geometry.JPlane;
import jiglib.geometry.JTriangleMesh;
import jiglib.geometry.JTerrain;


/**
 * ...
 * @author Krtolica Vujadin
 */
class BabylonPhysics extends AbstractPhysics {
	
	private var scene:Scene;

	
	public function new(scene:Scene, speed:Float = 1) {
		this.scene = scene;
		super(speed);
	}

	public function getMesh(body:RigidBody):Mesh {
		if (body.skin != null) {
			return cast(body.skin, JigLibMesh).mesh;
		} 
		else {
			return null;
		}
	}

	public function createGround(material:Material, width:Int = 50, height:Int = 50, level:Int = 0):RigidBody {
		var ground:Mesh = Mesh.CreateGround("ground", width, height, level, scene);
		ground.material = material;
		
		var jGround:JPlane = new JPlane(new JigLibMesh(ground), new Vector3D(0, 1, 0));
		jGround.z = level;
		jGround.movable = false;
		addBody(jGround);
		
		return jGround;
	}

	public function createCube(material:Material, size:Int = 5, ?scaling:Vector3):RigidBody {
		if (scaling == null) {
			scaling = Vector3.One();
		}
		
		var cube:Mesh = Mesh.CreateBox("box", size, scene);
		cube.scaling = scaling;
		
		var jBox:JBox = new JBox(new JigLibMesh(cube), size * scaling.x, size * scaling.z, size * scaling.y);
		addBody(jBox);
		
		return jBox;
	}

	public function createSphere(material:Material, radius:Float = 5):RigidBody {
		var sphere:Mesh = Mesh.CreateSphere("sphere", 6, radius, scene);
		
		var jsphere:JSphere = new JSphere(new JigLibMesh(sphere), radius / 2);
		addBody(jsphere);
		
		return jsphere;
	}

	/*public function createTerrain(material : MeshMaterial, heightMap : BitmapData, width : Float = 1000, height : Float = 100, depth : Float = 1000, segmentsW : UInt = 30, segmentsH : UInt = 30, maxElevation:UInt = 255, minElevation:UInt = 0):JTerrain {
		var terrainMap:HeapsTerrain = new HeapsTerrain(heightMap, width, height, depth, segmentsW, segmentsH, maxElevation, minElevation);
		terrainMap.unindex();
		terrainMap.addNormals();
		var terrainMesh:Mesh = new Mesh(terrainMap, material, parent);

		var terrain:JTerrain = new JTerrain(terrainMap);
		addBody(terrain);

		return terrain;
	}*/

	/*
	public function createMesh(skin:Mesh,initPosition:Vector3D,initOrientation:Matrix3D,maxTrianglesPerCell:int = 10, minCellSize:Float = 10):JTriangleMesh{
		var mesh:JTriangleMesh=new JTriangleMesh(new Away3D4Mesh(skin),initPosition,initOrientation,maxTrianglesPerCell,minCellSize);
		addBody(mesh);
		return mesh;
	}
	*/
	
}
