package com.babylonhx.collisions;

import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.sprites.Sprite;

/**
* ...
* @author Krtolica Vujadin
*/
@:expose('BABYLON.PickingInfo') class PickingInfo {
	
	public var hit:Bool = false;
	public var distance:Float = 0;
	public var pickedPoint:Vector3 = null;
	public var pickedMesh:AbstractMesh = null;
	public var bu:Float = 0;
	public var bv:Float = 0;
	public var faceId:Int = -1;
	public var subMeshId:Int = 0;
	public var pickedSprite:Sprite = null;
	
	
	public function new() {
		
	}

	// Methods
	public function getNormal(useWorldCoordinates:Bool = false, useVerticesNormals:Bool = true):Vector3 {
		if (this.pickedMesh == null || !this.pickedMesh.isVerticesDataPresent(VertexBuffer.NormalKind)) {
			return null;
		}
		
		var indices = this.pickedMesh.getIndices();
		var result:Vector3 = Vector3.Zero();
		
		if (useVerticesNormals) {
			var normals = this.pickedMesh.getVerticesData(VertexBuffer.NormalKind);
			
			var normal0 = Vector3.FromFloat32Array(normals, indices[this.faceId * 3] * 3);
			var normal1 = Vector3.FromFloat32Array(normals, indices[this.faceId * 3 + 1] * 3);
			var normal2 = Vector3.FromFloat32Array(normals, indices[this.faceId * 3 + 2] * 3);
			
			normal0 = normal0.scale(this.bu);
			normal1 = normal1.scale(this.bv);
			normal2 = normal2.scale(1.0 - this.bu - this.bv);
			
			result = new Vector3(normal0.x + normal1.x + normal2.x, normal0.y + normal1.y + normal2.y, normal0.z + normal1.z + normal2.z);
		} 
		else {
			var positions = this.pickedMesh.getVerticesData(VertexBuffer.PositionKind);
			
			var vertex1 = Vector3.FromFloat32Array(positions, indices[this.faceId * 3] * 3);
			var vertex2 = Vector3.FromFloat32Array(positions, indices[this.faceId * 3 + 1] * 3);
			var vertex3 = Vector3.FromFloat32Array(positions, indices[this.faceId * 3 + 2] * 3);
			
			var p1p2 = vertex1.subtract(vertex2);
			var p3p2 = vertex3.subtract(vertex2);
			
			result = Vector3.Cross(p1p2, p3p2);
		}
		
		if (useWorldCoordinates) {
			result = Vector3.TransformNormal(result, this.pickedMesh.getWorldMatrix());
		}
		
		return Vector3.Normalize(result);
	}

	public function getTextureCoordinates():Vector2 {
		if (this.pickedMesh == null || !this.pickedMesh.isVerticesDataPresent(VertexBuffer.UVKind)) {
			return null;
		}
		
		var indices = this.pickedMesh.getIndices();
		var uvs = this.pickedMesh.getVerticesData(VertexBuffer.UVKind);
		
		var uv0 = Vector2.FromFloat32Array(uvs, indices[this.faceId * 3] * 2);
		var uv1 = Vector2.FromFloat32Array(uvs, indices[this.faceId * 3 + 1] * 2);
		var uv2 = Vector2.FromFloat32Array(uvs, indices[this.faceId * 3 + 2] * 2);
		
		uv0 = uv0.scale(1.0 - this.bu - this.bv);
        uv1 = uv1.scale(this.bu);
        uv2 = uv2.scale(this.bv);
		
		return new Vector2(uv0.x + uv1.x + uv2.x, uv0.y + uv1.y + uv2.y);
	}
	
}
