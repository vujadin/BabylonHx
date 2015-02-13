package com.babylonhx.mesh;

import com.babylonhx.cameras.Camera;
import com.babylonhx.Node;
import com.babylonhx.math.Vector3;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.materials.Material;
import com.babylonhx.culling.BoundingInfo;
import com.babylonhx.culling.BoundingSphere;
import com.babylonhx.tools.Tools;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.InstancedMesh') class InstancedMesh extends AbstractMesh {
	
	private var _sourceMesh:Mesh;
	private var _currentLOD:Mesh;
	

	public function new(name:String, source:Mesh) {
		super(name, source.getScene());
		
		source.instances.push(this);
		
		this._sourceMesh = source;
		
		this.position.copyFrom(source.position);
		this.rotation.copyFrom(source.rotation);
		this.scaling.copyFrom(source.scaling);
		
		if (source.rotationQuaternion != null) {
			this.rotationQuaternion = source.rotationQuaternion.clone();
		}
		
		this.infiniteDistance = source.infiniteDistance;
		
		this.setPivotMatrix(source.getPivotMatrix());
		
		this.refreshBoundingInfo();
		this._syncSubMeshes();
	}

	// Methods
	//public var receiveShadows(get, null):Bool;
	override private function get_receiveShadows():Bool {
		return this._sourceMesh.receiveShadows;
	}

	//public var material(get, null):Material;
	override private function get_material():Material {
		return this._sourceMesh.material;
	}

	//public var visibility(get, null):Float;
	override private function get_visibility():Float {
		return this._sourceMesh.visibility;
	}

	//public var skeleton(get, null):Skeleton;
	override private function get_skeleton():Skeleton {
		return this._sourceMesh.skeleton;
	}

	override public function getTotalVertices():Int {
		return this._sourceMesh.getTotalVertices();
	}

	public var sourceMesh(get, null):Mesh;
	private function get_sourceMesh():Mesh {
		return this._sourceMesh;
	}

	override public function getVerticesData(kind:String):Array<Float> {
		return this._sourceMesh.getVerticesData(kind);
	}

	override public function isVerticesDataPresent(kind:String):Bool {
		return this._sourceMesh.isVerticesDataPresent(kind);
	}

	override public function getIndices():Array<Int> {
		return this._sourceMesh.getIndices();
	}

	//public var _positions(get, null):Array<Vector3>;
	override private function get_positions():Array<Vector3> {
		return this._sourceMesh._positions;
	}

	public function refreshBoundingInfo() {
		var data = this._sourceMesh.getVerticesData(VertexBuffer.PositionKind);
		
		if (data != null) {
			var extend = Tools.ExtractMinAndMax(data, 0, this._sourceMesh.getTotalVertices());
			this._boundingInfo = new BoundingInfo(extend.minimum, extend.maximum);
		}
		
		this._updateBoundingInfo();
	}

	override public function _preActivate() {
		if (this._currentLOD != null) {
			this._currentLOD._preActivate();
		}
	}
	
	override public function _activate(renderId:Int) {
		this.sourceMesh._registerInstanceForRenderId(this, renderId);
	}
	
	override public function getLOD(camera:Camera, ?boundingSphere:BoundingSphere):AbstractMesh {
		this._currentLOD = cast this.sourceMesh.getLOD(this.getScene().activeCamera, this.getBoundingInfo().boundingSphere);
		
		if (this._currentLOD == this.sourceMesh) {
            return this;
        }
		
		return this._currentLOD;
	}

	public function _syncSubMeshes() {
		this.releaseSubMeshes();
		if(this._sourceMesh.subMeshes != null) {
			for (index in 0...this._sourceMesh.subMeshes.length) {
				this._sourceMesh.subMeshes[index].clone(this, this._sourceMesh);
			}
		}
	}

	override public function _generatePointsArray():Bool {
		return this._sourceMesh._generatePointsArray();
	}

	// Clone
	override public function clone(name:String, newParent:Node = null, doNotCloneChildren:Bool = false/*?doNotCloneChildren:Bool*/):InstancedMesh {
		var result = this._sourceMesh.createInstance(name);
		
		// Deep copy
		Tools.DeepCopy(this, result, ["name"], []);
		
		// Bounding info
		this.refreshBoundingInfo();
		
		// Parent
		if (newParent != null) {
			result.parent = newParent;
		}
		
		if (!doNotCloneChildren) {
			// Children
			for (index in 0...this.getScene().meshes.length) {
				var mesh = this.getScene().meshes[index];
				
				if (mesh.parent == this) {
					mesh.clone(mesh.name, result);
				}
			}
		}
		
		result.computeWorldMatrix(true);
		
		return result;
	}

	// Dispose
	override public function dispose(doNotRecurse:Bool = false/*?doNotRecurse:Bool*/) {
		// Remove from mesh
		this._sourceMesh.instances.remove(this);
		
		super.dispose(doNotRecurse);
	}
	
}
