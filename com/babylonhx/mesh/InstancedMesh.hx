package com.babylonhx.mesh;

import com.babylonhx.cameras.Camera;
import com.babylonhx.Node;
import com.babylonhx.math.Vector3;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.materials.Material;
import com.babylonhx.culling.BoundingInfo;
import com.babylonhx.culling.BoundingSphere;
import com.babylonhx.tools.Tools;
import com.babylonhx.animations.IAnimatable;

import lime.utils.UInt32Array;
import lime.utils.Float32Array;


/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * Creates an instance based on a source mesh.
 */
@:expose('BABYLON.InstancedMesh') class InstancedMesh extends AbstractMesh implements IAnimatable {
	
	private var _sourceMesh:Mesh;
	private var _currentLOD:Mesh;
	
	public var sourceMesh(get, null):Mesh;
	

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
	
	override public function getClassName():String {
		return "InstancedMesh";
	}

	// Methods
	override private function get_receiveShadows():Bool {
		return this._sourceMesh.receiveShadows;
	}

	override private function get_material():Material {
		return this._sourceMesh.material;
	}

	private function get_visibility():Float {
		return this._sourceMesh.visibility;
	}

	override private function get_skeleton():Skeleton {
		return this._sourceMesh.skeleton;
	}
	
	override private function get_renderingGroupId():Int {
		return this._sourceMesh.renderingGroupId;
	}

	override public function getTotalVertices():Int {
		return this._sourceMesh.getTotalVertices();
	}

	private function get_sourceMesh():Mesh {
		return this._sourceMesh;
	}
	
	/**
     * Is this node ready to be used/rendered
     * @return {boolean} is it ready
     */
    override public function isReady(forceInstanceSupport:Bool = false):Bool {
        return this._sourceMesh.isReady(true);
    }

	/**
	 * Returns a Float32Array of the requested kind of data : positons, normals, uvs, etc.  
	 */
	override public function getVerticesData(kind:String, copyWhenShared:Bool = false, forceCopy:Bool = false):Float32Array {
		return this._sourceMesh.getVerticesData(kind, copyWhenShared);
	}
	
	override public function setVerticesData(kind:String, data:Float32Array, updatable:Bool = false, ?stride:Int) {
		if (this.sourceMesh != null) {
		   this.sourceMesh.setVerticesData(kind, data, updatable, stride);
		}
	}
	
	override public function updateVerticesData(kind:String, data:Float32Array, updateExtends:Bool = false, makeItUnique:Bool = false) {
		if (this.sourceMesh != null) {
		   this.sourceMesh.updateVerticesData(kind, data, updateExtends, makeItUnique);
		}
	}
	
	override public function setIndices(indices:UInt32Array, totalVertices:Int = -1, updatable:Bool = false) {
		if (this.sourceMesh != null) {
		   this.sourceMesh.setIndices(indices, totalVertices);
		}
	}

	override public function isVerticesDataPresent(kind:String):Bool {
		return this._sourceMesh.isVerticesDataPresent(kind);
	}

	override public function getIndices(copyWhenShared:Bool = false):UInt32Array {
		return this._sourceMesh.getIndices(copyWhenShared);
	}

	override private function get__positions():Array<Vector3> {
		return this._sourceMesh._positions;
	}

	inline public function refreshBoundingInfo() {
		var meshBB = this._sourceMesh.getBoundingInfo();
		
		if (meshBB != null) {
			this._boundingInfo = new BoundingInfo(meshBB.minimum.clone(), meshBB.maximum.clone());
		}
		
		this._updateBoundingInfo();
	}

	override public function _preActivate() {
		if (this._currentLOD != null) {
			this._currentLOD._preActivate();
		}
	}
	
	override public function _activate(renderId:Int) {
		if (this._currentLOD != null) {
			this._currentLOD._registerInstanceForRenderId(this, renderId);
		}
	}
	
	/**
	 * Returns the current associated LOD AbstractMesh.  
	 */
	override public function getLOD(camera:Camera, ?boundingSphere:BoundingSphere):AbstractMesh {
		if (camera == null) {
            return this;
        }
		
        var boundingInfo = this.getBoundingInfo();
		
        if (boundingInfo == null) {
            return this;
        }
		
        this._currentLOD = cast this.sourceMesh.getLOD(camera, boundingInfo.boundingSphere);
		
		if (this._currentLOD == this.sourceMesh) {
            return this;
        }
		
		return this._currentLOD;
	}

	inline public function _syncSubMeshes() {
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
	override public function clone(name:String, newParent:Node = null, doNotCloneChildren:Bool = false):Mesh {
		var result = this._sourceMesh.createInstance(name);
		
		// TODO: Deep copy
		//Tools.DeepCopy(this, result, ["name"], []);
		
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
		
		return cast result;
	}

	// Dispose
	override public function dispose(doNotRecurse:Bool = false) {
		// Remove from mesh
		this._sourceMesh.instances.remove(this);
		
		super.dispose(doNotRecurse);
	}
	
}
