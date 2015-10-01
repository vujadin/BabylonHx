package com.babylonhx.physics;

import com.babylonhx.mesh.VertexBuffer;
import jiglib.math.Matrix3D;
import jiglib.math.Vector3D;
import jiglib.plugin.ISkin3D;
import jiglib.data.TriangleVertexIndices;

import com.babylonhx.mesh.Mesh;

/**
 * ...
 * @author Krtolica Vujadin
 */
class JigLibMesh implements ISkin3D {
	
	public var transform(get, set):Matrix3D;
	public var vertices(get, never):Array<Vector3D>;
	public var indices(get, never):Array<TriangleVertexIndices>;
	public var mesh(get, never):Mesh;

	private var _mesh:Mesh;
	private var _translationOffset:Vector3D;
	private var _scale:Vector3D;
	private var _transform:Matrix3D = new Matrix3D();
	

	public function new(mesh:Mesh, ?offset:Vector3D) {
		this._mesh = mesh;
		
		_transform.identity();
		
		if (offset != null) {
			_translationOffset = offset.clone();
		}
		
		if (mesh.scaling.x != 1 || mesh.scaling.y != 1 || mesh.scaling.z != 1) {
			_scale = new Vector3D(mesh.scaling.x, mesh.scaling.y, mesh.scaling.z);
		}
	}
	
	private function get_transform():Matrix3D {
		return _transform;
	}

	private function set_transform(m:Matrix3D) {
		_transform.identity();
		if (_translationOffset != null) {
			_transform.appendTranslation(_translationOffset.x, _translationOffset.y, _translationOffset.z);
		}
		if (_scale != null) {
			_transform.appendScale(_scale.x, _scale.y, _scale.z);
		}
		_transform.append(m);
		
		var decom = _transform.decompose();
		var pos = decom[0];
		var rot = decom[1];
		var scale = decom[2];
		
		_mesh.position.set(pos.x, pos.y, pos.z);
		_mesh.rotation.set(rot.x, rot.y, rot.z);
		_mesh.scaling.set(scale.x, scale.y, scale.z);
		
		return _transform;
	}

	function get_mesh():Mesh {
		return _mesh;
	}

	function get_vertices():Array<Vector3D> {
		var result:Array<Vector3D> = new Array<Vector3D>();
		
		var vts = _mesh.getVertexBuffer(VertexBuffer.PositionKind).getData();
		
		var i:Int = 0;
		while (i < vts.length) {
			result.push(new Vector3D(vts[i], vts[i + 1], vts[i + 2]));
			i += 3;
		}
		
		return result;
	}

	function get_indices():Array<TriangleVertexIndices> {	
		var result:Array<TriangleVertexIndices> = [];
		
		var ids:Array<Int> = _mesh.getIndices();
		var i:Int = 0;
		while (i < ids.length) {
			result.push(new TriangleVertexIndices(ids[i], ids[i + 1], ids[i + 2]));
			i += 3;
		}
		
		return result;
	}
	
}
