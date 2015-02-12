package com.babylonhx.mesh;

import com.babylonhx.animations.IAnimatable;
import com.babylonhx.animations.Animatable;
import com.babylonhx.culling.BoundingSphere;
import com.babylonhx.Engine;
import com.babylonhx.materials.Effect;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Plane;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.mesh.simplification.ISimplificationSettings;
import com.babylonhx.mesh.simplification.ISimplifier;
import com.babylonhx.mesh.simplification.QuadraticErrorSimplification;
import com.babylonhx.mesh.simplification.SimplificationSettings;
import com.babylonhx.Node;
import com.babylonhx.mesh.LinesMesh;
import com.babylonhx.cameras.Camera;
import com.babylonhx.culling.BoundingInfo;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.tools.AsyncLoop;
import com.babylonhx.tools.Tools;
import com.babylonhx.materials.Material;
import com.babylonhx.materials.textures.Texture;
import haxe.CallStack;
import haxe.Json;
import openfl.display.BitmapData;

#if nme
import nme.utils.Float32Array;
import nme.utils.ArrayBuffer;
import nme.utils.UInt8Array;
#elseif openfl
import openfl.Assets;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;
import openfl.utils.Float32Array;
import openfl.utils.ArrayBuffer;
import openfl.utils.UInt8Array;
#elseif snow
import snow.utils.Float32Array;
import snow.utils.UInt8Array;
import snow.utils.UInt8Array;
import snow.utils.ArrayBuffer;
import snow.utils.ByteArray;
#elseif kha
// TODO
#end

/**
 * ...
 * @author Krtolica Vujadin
 */

class Mesh extends AbstractMesh implements IGetSetVerticesData {
	
	// Members
	public var delayLoadState = Engine.DELAYLOADSTATE_NONE;
	public var instances:Array<InstancedMesh> = [];
	public var delayLoadingFile:String;
	public var _binaryInfo:Dynamic;
	private var _LODLevels:Array<MeshLODLevel> = [];

	// Private
	public var _geometry:Geometry;
	private var _onBeforeRenderCallbacks:Array<Void->Void> = [];
	private var _onAfterRenderCallbacks:Array<Void->Void> = [];
	public var _delayInfo:Array<String>; //ANY
	public var _delayLoadingFunction:Dynamic->Mesh->Void;
	public var _visibleInstances:_VisibleInstances;
	private var _renderIdForInstances:Array<Int> = [];
	private var _batchCache:_InstancesBatch = new _InstancesBatch();
	private var _worldMatricesInstancesBuffer:BabylonBuffer;
	private var _worldMatricesInstancesArray: #if html5 Float32Array #else Array<Float> #end;
	private var _instancesBufferSize:Int = 32 * 16 * 4; // let's start with a maximum of 32 instances
	public var _shouldGenerateFlatShading:Bool;
	private var _preActivateId:Int = -1;

	public function new(name:String, scene:Scene, parent:Node = null, ?source:Mesh, doNotCloneChildren:Bool = false) {
		super(name, scene);
		
		if (source != null){
			// Geometry
			if (source._geometry != null) {
				source._geometry.applyToMesh(this);
			}
			
			// Deep copy
			Tools.DeepCopy(source, this, ["name", "material", "skeleton"], []);
			
			// Material
			this.material = source.material;
			
			if (!doNotCloneChildren) {
				// Children
				for (index in 0...scene.meshes.length) {
					var mesh = scene.meshes[index];
					
					if (mesh.parent == source) {
						// doNotCloneChildren is always going to be False
						var newChild = mesh.clone(name + "." + mesh.name, this, doNotCloneChildren); 
					}
				}
			}
			
			// Particles
			for (index in 0...scene.particleSystems.length) {
				var system = scene.particleSystems[index];
				
				if (system.emitter == source) {
					system.clone(system.name, this);
				}
			}
			this.computeWorldMatrix(true);
		}
		
		// Parent
		if (parent != null) {
			this.parent = parent;
		}
	}

	// Methods
	public var hasLODLevels(get, never):Bool;
	private function get_hasLODLevels():Bool {
		return this._LODLevels.length > 0;
	}
	
	private function _sortLODLevels() {
		this._LODLevels.sort(function(a:MeshLODLevel, b:MeshLODLevel) {
			if (a.distance < b.distance) {
				return 1;
			}
			if (a.distance > b.distance) {
				return -1;
			}
			
			return 0;
		});
	}

	public function addLODLevel(distance:Float, mesh:Mesh = null):Mesh {
		if (mesh != null && mesh._masterMesh != null) {
			trace("You cannot use a mesh as LOD level twice");
			return this;
		}
		
		var level = new MeshLODLevel(distance, mesh);
		this._LODLevels.push(level);
		
		if (mesh != null) {
			mesh._masterMesh = this;
		}
		
		this._sortLODLevels();
		
		return this;
	}

	public function removeLODLevel(mesh:Mesh):Mesh {
		for (index in 0...this._LODLevels.length) {
			if (this._LODLevels[index].mesh == mesh) {
				this._LODLevels.splice(index, 1);
				if (mesh != null) {
					mesh._masterMesh = null;
				}
			}
		}
		
		this._sortLODLevels();
		return this;
	}

	override public function getLOD(camera:Camera, ?boundingSphere:BoundingSphere):AbstractMesh {
		if (this._LODLevels == null || this._LODLevels.length == 0) {
			return this;
		}
		
		var distanceToCamera = (boundingSphere != null ? boundingSphere : this.getBoundingInfo().boundingSphere).centerWorld.subtract(camera.position).length();
		
		if (this._LODLevels[this._LODLevels.length - 1].distance > distanceToCamera) {
			return this;
		}
		
		for (index in 0...this._LODLevels.length) {
			var level = this._LODLevels[index];
			
			if (level.distance < distanceToCamera) {
				if (level.mesh != null) {
					level.mesh._preActivate();
                    level.mesh._updateSubMeshesBoundingInfo(this.worldMatrixFromCache);
				}
				return level.mesh;
			}
		}
		
		return this;
	}

	override public function getTotalVertices():Int {
		if (this._geometry == null) {
			return 0;
		}
		return this._geometry.getTotalVertices();
	}

	override public function getVerticesData(kind:String):Array<Float> {
		if (this._geometry == null) {
			return null;
		}
		return this._geometry.getVerticesData(kind);
	}

	public function getVertexBuffer(kind:String):VertexBuffer {
		if (this._geometry == null) {
			return null;
		}
		return this._geometry.getVertexBuffer(kind);
	}

	override public function isVerticesDataPresent(kind:String):Bool {
		if (this._geometry == null) {
			if (this._delayInfo != null) {
				return this._delayInfo.indexOf(kind) != -1;
			}
			return false;
		}
		return this._geometry.isVerticesDataPresent(kind);
	}

	public function getVerticesDataKinds():Array<String> {
		if (this._geometry == null) {
			var result:Array<String> = [];
			if (this._delayInfo != null) {
				for (kind in this._delayInfo) {
					result.push(kind);
				}
			}
			return result;
		}
		return this._geometry.getVerticesDataKinds();
	}

	public function getTotalIndices():Int {
		if (this._geometry == null) {
			return 0;
		}
		return this._geometry.getTotalIndices();
	}

	override public function getIndices():Array<Int> {
		if (this._geometry == null) {
			return [];
		}
		return this._geometry.getIndices();
	}

	override private function get_isBlocked():Bool {
		return this._masterMesh != null;
	}

	override public function isReady():Bool {
		if (this.delayLoadState == Engine.DELAYLOADSTATE_LOADING) {
			return false;
		}
		
		return super.isReady();
	}

	public function isDisposed():Bool {
		return this._isDisposed;
	}

	// Methods  
	override public function _preActivate() {
		var sceneRenderId = this.getScene().getRenderId();
		if (this._preActivateId == sceneRenderId) {
			return;
		}
		
		this._preActivateId = sceneRenderId;
		this._visibleInstances = null;
	}

	public function _registerInstanceForRenderId(instance:InstancedMesh, renderId:Int) {
		if (this._visibleInstances == null) {
			this._visibleInstances = new _VisibleInstances(renderId, this._renderId);
		}
		
		if (!this._visibleInstances.map.exists(renderId)) {
			this._visibleInstances.map.set(renderId, []);
		}
		
		this._visibleInstances.map[renderId].push(instance);
	}

	public function refreshBoundingInfo() {
		var data = this.getVerticesData(VertexBuffer.PositionKind);
		
		if (data != null) {
			var extend = Tools.ExtractMinAndMax(data, 0, this.getTotalVertices());
			this._boundingInfo = new BoundingInfo(extend.minimum, extend.maximum);
		}
		
		if (this.subMeshes != null) {
			for (index in 0...this.subMeshes.length) {
				this.subMeshes[index].refreshBoundingInfo();
			}
		}
		
		this._updateBoundingInfo();
	}

	public function _createGlobalSubMesh():SubMesh {
		var totalVertices = this.getTotalVertices();
		if (totalVertices == 0 || this.getIndices() == null) {
			return null;
		}
		
		this.releaseSubMeshes();
		return new SubMesh(0, 0, totalVertices, 0, this.getTotalIndices(), this);
	}

	public function subdivide(count:Int) {
		if (count < 1) {
			return;
		}
		
		var totalIndices = this.getTotalIndices();
		var subdivisionSize = Std.int(totalIndices / count);
		var offset = 0;
		
		// Ensure that subdivisionSize is a multiple of 3
		while (subdivisionSize % 3 != 0) {
			subdivisionSize++;
		}
		
		this.releaseSubMeshes();
		for (index in 0...count) {
			if (offset >= totalIndices) {
				break;
			}
			
			SubMesh.CreateFromIndices(0, offset, Std.int(Math.min(subdivisionSize, totalIndices - offset)), this);
			offset += subdivisionSize;
		}
		
		this.synchronizeInstances();
	}

	public function setVerticesData(kind:String, data:Array<Float>, updatable:Bool = false, ?stride:Int) {
		if (this._geometry == null) {
			var vertexData = new VertexData();
			vertexData.set(data, kind);
			
			var scene = this.getScene();
			new Geometry(Geometry.RandomId(), scene, vertexData, updatable, this);
		}
		else {
			this._geometry.setVerticesData(kind, data, updatable, stride);
		}
	}

	public function updateVerticesData(kind:String, data:Array<Float>, updateExtends:Bool = false, makeItUnique:Bool = false) {
		if (this._geometry == null) {
			return;
		}
		
		if (!makeItUnique) {
			this._geometry.updateVerticesData(kind, data, updateExtends);
		} else {
			this.makeGeometryUnique();
			this.updateVerticesData(kind, data, updateExtends, false);
		}
	}

	public function updateVerticesDataDirectly(kind:String, data:Float32Array, offset:Int = 0, makeItUnique:Bool = false) {
		if (this._geometry == null) {
			return;
		}
		
		if (!makeItUnique) {
			this._geometry.updateVerticesDataDirectly(kind, data, offset);
		} else {
			this.makeGeometryUnique();
			this.updateVerticesDataDirectly(kind, data, offset, false);
		}
	}

	public function makeGeometryUnique() {
		if (this._geometry == null) {
			return;
		}
		
		var geometry = this._geometry.copy(Geometry.RandomId());
		geometry.applyToMesh(this);
	}

	public function setIndices(indices:Array<Int>) {
		if (this._geometry == null) {
			var vertexData = new VertexData();
			vertexData.indices = indices;
			
			var scene = this.getScene();
			new Geometry(Geometry.RandomId(), scene, vertexData, false, this);
		} else {
			this._geometry.setIndices(indices);
		}
	}

	public function _bind(subMesh:SubMesh, effect:Effect, fillMode:Int) {
		var engine = this.getScene().getEngine();
		
		// Wireframe
		var indexToBind:BabylonBuffer = null;
		
		switch (fillMode) {
			case Material.PointFillMode:
				indexToBind = null;
				
			case Material.WireFrameFillMode:
				indexToBind = subMesh.getLinesIndexBuffer(this.getIndices(), engine);
				
			case Material.TriangleFillMode:
				indexToBind = this._geometry.getIndexBuffer();
								
			default:
				indexToBind = this._geometry.getIndexBuffer();
		}
		
		// VBOs
		engine.bindMultiBuffers(this._geometry.getVertexBuffers(), indexToBind, effect);
	}

	public function _draw(subMesh:SubMesh, fillMode:Int, ?instancesCount:Int) {	
		if (this._geometry == null || this._geometry.getVertexBuffers() == null || this._geometry.getIndexBuffer() == null) {
			return;
		}
		
		var engine:Engine = this.getScene().getEngine();
		
		// Draw order
		switch (fillMode) {
			case Material.PointFillMode:
				engine.drawPointClouds(subMesh.verticesStart, subMesh.verticesCount, instancesCount);
				
			case Material.WireFrameFillMode:
				engine.draw(false, 0, subMesh.linesIndexCount, instancesCount);	
				
			default:
				engine.draw(true, subMesh.indexStart, subMesh.indexCount, instancesCount);
		}
	}

	public function registerBeforeRender(func:Void->Void) {
		this._onBeforeRenderCallbacks.push(func);
	}

	public function unregisterBeforeRender(func:Void->Void) {
		var index = this._onBeforeRenderCallbacks.indexOf(func);
		if (index > -1) {
			this._onBeforeRenderCallbacks.splice(index, 1);
		}
	}

	public function registerAfterRender(func:Void->Void) {
		this._onAfterRenderCallbacks.push(func);
	}

	public function unregisterAfterRender(func:Void->Void) {
		var index = this._onAfterRenderCallbacks.indexOf(func);
		if (index > -1) {
			this._onAfterRenderCallbacks.splice(index, 1);
		}
	}

	// TODO: cela funkcija
	public function _getInstancesRenderList(subMeshId:Int):_InstancesBatch {
		var scene = this.getScene();
		this._batchCache.mustReturn = false;
		this._batchCache.renderSelf[subMeshId] = this.isEnabled() && this.isVisible;
		this._batchCache.visibleInstances[subMeshId] = null;
		
		if (this._visibleInstances != null) {
			var currentRenderId:Int = scene.getRenderId();
			this._batchCache.visibleInstances[subMeshId] = this._visibleInstances.map[currentRenderId];
			var selfRenderId:Int = this._renderId;
			
			if (this._batchCache.visibleInstances[subMeshId] == null && this._visibleInstances.defaultRenderId > 0) {
				this._batchCache.visibleInstances[subMeshId] = this._visibleInstances.map[this._visibleInstances.defaultRenderId];
				currentRenderId = this._visibleInstances.defaultRenderId;
				selfRenderId = this._visibleInstances.selfDefaultRenderId;
			}
			
			if (this._batchCache.visibleInstances[subMeshId] != null && this._batchCache.visibleInstances[subMeshId].length > 0) {
				if (this._renderIdForInstances[subMeshId] == currentRenderId) {
					this._batchCache.mustReturn = true;
					return this._batchCache;
				}
				
				if (currentRenderId != selfRenderId) {
					this._batchCache.renderSelf[subMeshId] = false;
				}
				
			}
			this._renderIdForInstances[subMeshId] = currentRenderId;
		}
		
		return this._batchCache;
	}

	public function _renderWithInstances(subMesh:SubMesh, fillMode:Int, batch:_InstancesBatch, effect:Effect, engine:Engine) {
		var visibleInstances = batch.visibleInstances[subMesh._id];
        var matricesCount = visibleInstances.length + 1;
		var bufferSize = matricesCount * 16 * 4;
		
		while (this._instancesBufferSize < bufferSize) {
			this._instancesBufferSize *= 2;
		}
		
		if (this._worldMatricesInstancesBuffer == null || this._worldMatricesInstancesBuffer.capacity < this._instancesBufferSize) {
			if (this._worldMatricesInstancesBuffer != null) {
				engine.deleteInstancesBuffer(this._worldMatricesInstancesBuffer);
			}
			
			this._worldMatricesInstancesBuffer = engine.createInstancesBuffer(this._instancesBufferSize);
			this._worldMatricesInstancesArray = #if html5 new Float32Array(Std.int(this._instancesBufferSize / 4)) #else [] #end ;
		}
		
		var offset = 0;
		var instancesCount = 0;
		
		var world = this.getWorldMatrix();
		if (batch.renderSelf[subMesh._id]) {
			world.copyToArray(this._worldMatricesInstancesArray, offset);
			offset += 16;
			instancesCount++;
		}
		
		if (visibleInstances != null) {
			for (instanceIndex in 0...visibleInstances.length) {
				var instance = visibleInstances[instanceIndex];
				instance.getWorldMatrix().copyToArray(this._worldMatricesInstancesArray, offset);
				offset += 16;
				instancesCount++;
			}
		}
		
		var offsetLocation0 = effect.getAttributeLocationByName("world0");
		var offsetLocation1 = effect.getAttributeLocationByName("world1");
		var offsetLocation2 = effect.getAttributeLocationByName("world2");
		var offsetLocation3 = effect.getAttributeLocationByName("world3");
		
		var offsetLocations = [offsetLocation0, offsetLocation1, offsetLocation2, offsetLocation3];
		engine.updateAndBindInstancesBuffer(this._worldMatricesInstancesBuffer, this._worldMatricesInstancesArray, offsetLocations);
		this._draw(subMesh, fillMode, instancesCount);
		engine.unBindInstancesBuffer(this._worldMatricesInstancesBuffer, offsetLocations);
	}

	public function render(subMesh:SubMesh) {
		var scene = this.getScene();
				
		// Managing instances
		var batch = this._getInstancesRenderList(subMesh._id);
		if (batch.mustReturn) {
			return;
		}
		
		// Checking geometry state
		if (this._geometry == null || this._geometry.getVertexBuffers() == null || this._geometry.getIndexBuffer() == null) {
			return;
		}
		
		for (callbackIndex in 0...this._onBeforeRenderCallbacks.length) {
			this._onBeforeRenderCallbacks[callbackIndex]();
		}
		
		var engine = scene.getEngine();
		var hardwareInstancedRendering = (engine.getCaps().instancedArrays != null) && (batch.visibleInstances[subMesh._id] != null) && (batch.visibleInstances.length > subMesh._id && batch.visibleInstances[subMesh._id] != null);
		
		// Material
		var effectiveMaterial = subMesh.getMaterial();
		
		if (effectiveMaterial == null || !effectiveMaterial.isReady(this, hardwareInstancedRendering)) {
			return;
		}
		
		// Outline - step 1
		var savedDepthWrite = engine.getDepthWrite();
		if (this.renderOutline) {
			engine.setDepthWrite(false);
			scene.getOutlineRenderer().render(subMesh, batch);
			engine.setDepthWrite(savedDepthWrite);
		}
		
		effectiveMaterial._preBind();
		var effect = effectiveMaterial.getEffect();
		
		// Bind
		var fillMode = scene.forcePointsCloud ? Material.PointFillMode : (scene.forceWireframe ? Material.WireFrameFillMode : effectiveMaterial.fillMode);
		this._bind(subMesh, effect, fillMode);
		
		var world = this.getWorldMatrix();
		effectiveMaterial.bind(world, this);
		
		// Instances rendering
		if (hardwareInstancedRendering) {
			this._renderWithInstances(subMesh, fillMode, batch, effect, engine);
		} else {
			if (batch.renderSelf[subMesh._id]) {
				// Draw
				this._draw(subMesh, fillMode);
			}
			
			if (batch.visibleInstances[subMesh._id] != null) {
				for (instanceIndex in 0...batch.visibleInstances[subMesh._id].length) {
					var instance = batch.visibleInstances[subMesh._id][instanceIndex];
					
					// World
					world = instance.getWorldMatrix();
					effectiveMaterial.bindOnlyWorldMatrix(world);
					
					// Draw
					this._draw(subMesh, fillMode);
				}
			}
		}
		// Unbind
		effectiveMaterial.unbind();
		
		// Outline - step 2
		if (this.renderOutline && savedDepthWrite) {
			engine.setDepthWrite(true);
			engine.setColorWrite(false);
			scene.getOutlineRenderer().render(subMesh, batch);
			engine.setColorWrite(true);
		}
		
		// Overlay
        if (this.renderOverlay) {
            var currentMode = engine.getAlphaMode();
            engine.setAlphaMode(Engine.ALPHA_COMBINE);
            scene.getOutlineRenderer().render(subMesh, batch, true);
            engine.setAlphaMode(currentMode);
        }
		
		for (callbackIndex in 0...this._onAfterRenderCallbacks.length) {
			this._onAfterRenderCallbacks[callbackIndex]();
		}
	}

	public function getEmittedParticleSystems():Array<ParticleSystem> {
		var results = new Array<ParticleSystem>();
		for (index in 0...this.getScene().particleSystems.length) {
			var particleSystem = this.getScene().particleSystems[index];
			if (particleSystem.emitter == this) {
				results.push(particleSystem);
			}
		}
		
		return results;
	}

	public function getHierarchyEmittedParticleSystems():Array<ParticleSystem> {
		var results = new Array<ParticleSystem>();
		var descendants = this.getDescendants();
		descendants.push(this);
		
		for (index in 0...this.getScene().particleSystems.length) {
			var particleSystem = this.getScene().particleSystems[index];
			if (descendants.indexOf(particleSystem.emitter) != -1) {
				results.push(particleSystem);
			}
		}
		
		return results;
	}

	public function getChildren():Array<Node> {
		var results:Array<Node> = [];
		for (index in 0...this.getScene().meshes.length) {
			var mesh = this.getScene().meshes[index];
			if (mesh.parent == this) {
				results.push(mesh);
			}
		}
		
		return results;
	}

	public function _checkDelayState() {
		var that = this;
		var scene = this.getScene();
		
		if (this._geometry != null) {
			this._geometry.load(scene);
		}
		else if (that.delayLoadState == Engine.DELAYLOADSTATE_NOTLOADED) {
			that.delayLoadState = Engine.DELAYLOADSTATE_LOADING;
			
			scene._addPendingData(that);
			
			var getBinaryData = (this.delayLoadingFile.indexOf(".babylonbinarymeshdata") != -1) ? true : false;
			
			/*Tools.LoadFile(this.delayLoadingFile, function(data:Dynamic) {
			 * 
				if (Std.is(data, ArrayBuffer)) {
					this._delayLoadingFunction(data, this);
				}
				else {
					this._delayLoadingFunction(Json.parse(data), this);
				}
				
				this.delayLoadState = Engine.DELAYLOADSTATE_LOADED;
				scene._removePendingData(this);
			}, function() { }, scene.database, getBinaryData);*/
		}
	}

	override public function isInFrustum(frustumPlanes:Array<Plane>):Bool {
		if (this.delayLoadState == Engine.DELAYLOADSTATE_LOADING) {
			return false;
		}
		
		if (!super.isInFrustum(frustumPlanes)) {
			return false;
		}
		
		this._checkDelayState();
		
		return true;
	}

	public function setMaterialByID(id:String) {
		var materials = this.getScene().materials;
		for (index in 0...materials.length) {
			if (materials[index].id == id) {
				this.material = materials[index];
				return;
			}
		}
		
		// Multi
		var multiMaterials = this.getScene().multiMaterials;
		for (index in 0...multiMaterials.length) {
			if (multiMaterials[index].id == id) {
				this.material = multiMaterials[index];
				return;
			}
		}
	}

	public function getAnimatables():Array<Dynamic> {
		var results:Array<Dynamic> = [];
		
		if (this.material != null) {
			results.push(this.material);
		}
		
		if (this.skeleton != null) {
			results.push(this.skeleton);
		}
		
		return results;
	}

	// Geometry
	public function bakeTransformIntoVertices(transform:Matrix) {
		// Position
		if (!this.isVerticesDataPresent(VertexBuffer.PositionKind)) {
			return;
		}
		
		this._resetPointsArrayCache();
		
		var data = this.getVerticesData(VertexBuffer.PositionKind);
		var temp:Array<Float> = [];
		var index:Int = 0;
		while(index < data.length) {
			Vector3.TransformCoordinates(Vector3.FromArray(data, index), transform).toArray(temp, index);
			index += 3;
		}
		
		this.setVerticesData(VertexBuffer.PositionKind, temp, this.getVertexBuffer(VertexBuffer.PositionKind).isUpdatable());
		
		// Normals
		if (!this.isVerticesDataPresent(VertexBuffer.NormalKind)) {
			return;
		}
		
		data = this.getVerticesData(VertexBuffer.NormalKind);
		index = 0;
		while(index < data.length) {
			Vector3.TransformNormal(Vector3.FromArray(data, index), transform).toArray(temp, index);
			index += 3;
		}
		
		this.setVerticesData(VertexBuffer.NormalKind, temp, this.getVertexBuffer(VertexBuffer.NormalKind).isUpdatable());
	}

	// Cache
	public function _resetPointsArrayCache() {
		this._positions = null;
	}

	override public function _generatePointsArray():Bool {
		if (this._positions != null)
			return true;
			
		this._positions = [];
		
		var data = this.getVerticesData(VertexBuffer.PositionKind);
		
		if (data == null) {
			return false;
		}
		
		var index:Int = 0;
		while (index < data.length) {
			this._positions.push(Vector3.FromArray(data, index));
			index += 3;
		}
		
		return true;
	}

	// Clone
	override public function clone(name:String, newParent:Node = null, doNotCloneChildren:Bool = false):Mesh {
		return new Mesh(name, this.getScene(), newParent, this, doNotCloneChildren);
	}

	// Dispose
	override public function dispose(doNotRecurse:Bool = false/*?doNotRecurse:Bool*/) {
		if (this._geometry != null) {
			this._geometry.releaseForMesh(this, true);
		}
		
		// Instances
		if (this._worldMatricesInstancesBuffer != null) {
			this.getEngine().deleteInstancesBuffer(this._worldMatricesInstancesBuffer);
			this._worldMatricesInstancesBuffer = null;
		}
		
		while (this.instances.length > 0) {
			this.instances[0].dispose();
		}
		
		super.dispose(doNotRecurse);
	}

	// Geometric tools
	public function applyDisplacementMap(url:String, minHeight:Float, maxHeight:Float, ?onSuccess:Mesh->Void) {
		var scene = this.getScene();

		/*var onload = img => {
			// Getting height map data
			var canvas = document.createElement("canvas");
			var context = canvas.getContext("2d");
			var heightMapWidth = img.width;
			var heightMapHeight = img.height;
			canvas.width = heightMapWidth;
			canvas.height = heightMapHeight;
			
			context.drawImage(img, 0, 0);
			
			// Create VertexData from map data
			var buffer = context.getImageData(0, 0, heightMapWidth, heightMapHeight).data;*/
			
			var bmp = Assets.getBitmapData(url);
			var buffer = bmp.getPixels(new Rectangle(0, 0, bmp.width, bmp.height));
						
			this.applyDisplacementMapFromBuffer(buffer, bmp.width, bmp.height, minHeight, maxHeight);
			
			if (onSuccess != null) {
				onSuccess(this);
			}
		//};
		
		//Tools.LoadImage(url, onload, () => { }, scene.database);
	}

	public function applyDisplacementMapFromBuffer(buffer:ByteArray, heightMapWidth:Float, heightMapHeight:Float, minHeight:Float, maxHeight:Float) {
		if (!this.isVerticesDataPresent(VertexBuffer.PositionKind)
			|| !this.isVerticesDataPresent(VertexBuffer.NormalKind)
			|| !this.isVerticesDataPresent(VertexBuffer.UVKind)) {
			trace("Cannot call applyDisplacementMap:Given mesh is not complete. Position, Normal or UV are missing");
			return;
		}
		
		var positions = this.getVerticesData(VertexBuffer.PositionKind);
		var normals = this.getVerticesData(VertexBuffer.NormalKind);
		var uvs = this.getVerticesData(VertexBuffer.UVKind);
		var position = Vector3.Zero();
		var normal = Vector3.Zero();
		var uv = Vector2.Zero();
				
		var index:Int = 0;
		while(index < positions.length) {
			Vector3.FromArrayToRef(positions, index, position);
			Vector3.FromArrayToRef(normals, index, normal);
			Vector2.FromArrayToRef(uvs, Std.int((index / 3) * 2), uv);
			
			// Compute height
			var u = Std.int((Math.abs(uv.x) * heightMapWidth) % heightMapWidth);
			var v = Std.int((Math.abs(uv.y) * heightMapHeight) % heightMapHeight);
			
			var pos = Std.int((u + v * heightMapWidth) * 4);
			var r = buffer.__get(pos) / 255.0;
			var g = buffer.__get(pos + 1) / 255.0;
			var b = buffer.__get(pos + 2) / 255.0;
			
			var gradient = r * 0.3 + g * 0.59 + b * 0.11;
			
			normal.normalize();
			normal.scaleInPlace(minHeight + (maxHeight - minHeight) * gradient);
			position = position.add(normal);
			
			position.toArray(positions, index);
			
			index += 3;
		}
		
		VertexData.ComputeNormals(positions, this.getIndices(), normals);
		
		this.updateVerticesData(VertexBuffer.PositionKind, positions);
		this.updateVerticesData(VertexBuffer.NormalKind, normals);
	}

	public function convertToFlatShadedMesh() {
		/// <summary>Update normals and vertices to get a flat shading rendering.</summary>
		/// <summary>Warning:This may imply adding vertices to the mesh in order to get exactly 3 vertices per face</summary>
		var kinds = this.getVerticesDataKinds();
		var vbs:Map<String, VertexBuffer> = new Map<String, VertexBuffer>();
		var data:Map<String, Array<Float>> = new Map<String, Array<Float>>();
		var newdata:Map<String, Array<Float>> = new Map<String, Array<Float>>();
		var updatableNormals = false;
		
		var kindIndex:Int = 0;
		while(kindIndex < kinds.length) {
			var kind = kinds[kindIndex];
			var vertexBuffer = this.getVertexBuffer(kind);
			
			if (kind == VertexBuffer.NormalKind) {
				updatableNormals = vertexBuffer.isUpdatable();
				kinds.splice(kindIndex, 1);
				kindIndex--;
				continue;
			}
			
			vbs[kind] = vertexBuffer;
			data[kind] = vbs[kind].getData();
			newdata[kind] = [];
			
			kindIndex++;
		}
		
		// Save previous submeshes
		var previousSubmeshes = this.subMeshes.slice(0);
		
		var indices = this.getIndices();
		var totalIndices = this.getTotalIndices();
		
		// Generating unique vertices per face
		for (index in 0...totalIndices) {
			var vertexIndex = indices[index];
			
			for (kindIndex in 0...kinds.length) {
				var kind = kinds[kindIndex];
				var stride = vbs[kind].getStrideSize();
				
				for (offset in 0...stride) {
					newdata[kind].push(data[kind][vertexIndex * stride + offset]);
				}
			}
		}
		
		// Updating faces & normal
		var normals:Array<Float> = [];
		var positions = newdata[VertexBuffer.PositionKind];
		var index:Int = 0;
		while(index < totalIndices) {
			indices[index] = index;
			indices[index + 1] = index + 1;
			indices[index + 2] = index + 2;
			
			var p1 = Vector3.FromArray(positions, index * 3);
			var p2 = Vector3.FromArray(positions, (index + 1) * 3);
			var p3 = Vector3.FromArray(positions, (index + 2) * 3);
			
			var p1p2 = p1.subtract(p2);
			var p3p2 = p3.subtract(p2);
			
			var normal = Vector3.Normalize(Vector3.Cross(p1p2, p3p2));
			
			// Store same normals for every vertex
			for (localIndex in 0...3) {
				normals.push(normal.x);
				normals.push(normal.y);
				normals.push(normal.z);
			}
			index += 3;
		}
		
		this.setIndices(indices);
		this.setVerticesData(VertexBuffer.NormalKind, normals, updatableNormals);
		
		// Updating vertex buffers
		for (kindIndex in 0...kinds.length) {
			var kind = kinds[kindIndex];
			this.setVerticesData(kind, newdata[kind], vbs[kind].isUpdatable());
		}
		
		// Updating submeshes
		this.releaseSubMeshes();
		for (submeshIndex in 0...previousSubmeshes.length) {
			var previousOne = previousSubmeshes[submeshIndex];
			var subMesh = new SubMesh(previousOne.materialIndex, previousOne.indexStart, previousOne.indexCount, previousOne.indexStart, previousOne.indexCount, this);
		}
		
		this.synchronizeInstances();
	}

	// Instances
	public function createInstance(name:String):InstancedMesh {
		return new InstancedMesh(name, this);
	}

	public function synchronizeInstances() {
		for (instanceIndex in 0...this.instances.length) {
			var instance = this.instances[instanceIndex];
			instance._syncSubMeshes();
		}
	}
	
	/**
	 * Simplify the mesh according to the given array of settings.
	 * Function will return immediately and will simplify async.
	 * @param settings a collection of simplification settings.
	 * @param parallelProcessing should all levels calculate parallel or one after the other.
	 * @param type the type of simplification to run.
	 * successCallback optional success callback to be called after the simplification finished processing all settings.
	 */
	public function simplify(settings:Array<ISimplificationSettings>, parallelProcessing:Bool = true, type:Int = SimplificationSettings.QUADRATIC, ?successCallback:Void->Void) {
		
		var getSimplifier = function():ISimplifier {   
			switch (type) {
				case SimplificationSettings.QUADRATIC:
					return new QuadraticErrorSimplification(this);
				
				default:
					return new QuadraticErrorSimplification(this);
			}
		}
		
		if (parallelProcessing) {
			//parallel simplifier
			for(setting in settings) {
				var simplifier = getSimplifier();
				simplifier.simplify(setting, function(newMesh:Mesh) {
					this.addLODLevel(setting.distance, newMesh);
					//check if it is the last
					if (setting.quality == settings[settings.length - 1].quality && successCallback != null) {
						//all done, run the success callback.
						successCallback();
					}
				});
			};
		} else {
			//single simplifier.
			var simplifier = getSimplifier();
			
			var runDecimation = function(setting:ISimplificationSettings, cback:Void->Void) {
				simplifier.simplify(setting, function(newMesh:Mesh) {
					this.addLODLevel(setting.distance, newMesh);
					//run the next quality level
					cback();
				});
			}
			
			AsyncLoop.Run(settings.length, function(loop:AsyncLoop) {
				runDecimation(settings[loop.index], function() {
					loop.executeNext();
				});
			}, function() {
				//execution ended, run the success callback.
				if (successCallback != null) {
					successCallback();
				}
			});
		}
	}

	// Statics
	public static function CreateBox(name:String, size:Float, scene:Scene, updatable:Bool = false):Mesh {
		var box = new Mesh(name, scene);
		var vertexData = VertexData.CreateBox(size);
		
		vertexData.applyToMesh(box, updatable);
		
		return box;
	}

	public static function CreateSphere(name:String, segments:Int, diameter:Float, scene:Scene, updatable:Bool = false):Mesh {
		var sphere = new Mesh(name, scene);
		var vertexData = VertexData.CreateSphere(segments, diameter);
		
		vertexData.applyToMesh(sphere, updatable);
		
		return sphere;
	}

	// Cylinder and cone (Code inspired by SharpDX.org)
	public static function CreateCylinder(name:String, height:Float, diameterTop:Float, diameterBottom:Float, tessellation:Int, subdivisions:Int, scene:Scene, updatable:Bool = false):Mesh {		
		var cylinder = new Mesh(name, scene);
		var vertexData = VertexData.CreateCylinder(height, diameterTop, diameterBottom, tessellation, subdivisions);
		
		vertexData.applyToMesh(cylinder, updatable);
		
		return cylinder;
	}

	// Torus  (Code from SharpDX.org)
	public static function CreateTorus(name:String, diameter:Float, thickness:Float, tessellation:Int, scene:Scene, updatable:Bool = false):Mesh {
		var torus = new Mesh(name, scene);
		var vertexData = VertexData.CreateTorus(diameter, thickness, tessellation);
		
		vertexData.applyToMesh(torus, updatable);
		
		return torus;
	}

	public static function CreateTorusKnot(name:String, radius:Float, tube:Float, radialSegments:Int, tubularSegments:Int, p:Float, q:Float, scene:Scene, updatable:Bool = false):Mesh {
		var torusKnot = new Mesh(name, scene);
		var vertexData = VertexData.CreateTorusKnot(radius, tube, radialSegments, tubularSegments, p, q);		
		vertexData.applyToMesh(torusKnot, updatable);		
		return torusKnot;
	}

	// Lines
	public static function CreateLines(name:String, points:Array<Vector3>, scene:Scene, updatable:Bool = false):LinesMesh {
		var lines = new LinesMesh(name, scene, updatable);		
		var vertexData = VertexData.CreateLines(points);
		vertexData.applyToMesh(lines, updatable);
		return lines;
	}

	// Plane & ground
	public static function CreatePlane(name:String, size:Float, scene:Scene, updatable:Bool = false):Mesh {
		var plane = new Mesh(name, scene);
		var vertexData = VertexData.CreatePlane(size);
		vertexData.applyToMesh(plane, updatable);
		return plane;
	}

	public static function CreateGround(name:String, width:Float, height:Float, subdivisions:Int, scene:Scene, updatable:Bool = false):Mesh {
		var ground = new GroundMesh(name, scene);
		ground._setReady(false);
		ground._subdivisions = subdivisions;
		
		var vertexData = VertexData.CreateGround(width, height, subdivisions);
		vertexData.applyToMesh(ground, updatable);
		ground._setReady(true);
		return ground;
	}

	public static function CreateTiledGround(name:String, xmin:Float, zmin:Float, xmax:Float, zmax:Float, subdivisions:Dynamic, precision:Dynamic, scene:Scene, updatable:Bool = false):Mesh {
		var tiledGround = new Mesh(name, scene);
		var vertexData = VertexData.CreateTiledGround(xmin, zmin, xmax, zmax, subdivisions, precision);
		vertexData.applyToMesh(tiledGround, updatable);
		return tiledGround;
	}

	public static function CreateGroundFromHeightMap(name:String, url:String, width:Float, height:Float, subdivisions:Int, minHeight:Float, maxHeight:Float, scene:Scene, updatable:Bool = false, ?onReady:GroundMesh->Void):GroundMesh {
		var ground = new GroundMesh(name, scene);
		ground._subdivisions = subdivisions;
		ground._setReady(false);
		
		var onload = function(img:BitmapData):Void {
			var canvas = img;
			var heightMapWidth = canvas.width;
			var heightMapHeight = canvas.height;
			
			#if html5
			var buffer = canvas.getPixels(canvas.rect).byteView;
			#else
			var buffer = new UInt8Array(BitmapData.getRGBAPixels(canvas));
			#end
			//var buffer = context.getImageData(0, 0, heightMapWidth, heightMapHeight).data;
			var vertexData = VertexData.CreateGroundFromHeightMap(width, height, subdivisions, minHeight, maxHeight, cast buffer, heightMapWidth, heightMapHeight);
			
			vertexData.applyToMesh(ground, updatable);
			
			ground._setReady(true);
		}

		Tools.LoadImage(url,onload);
		
		return ground;
	}

	// Tools
	public static function MinMax(meshes:Array<AbstractMesh>):BabylonMinMax {
		var minVector:Vector3 = null;
		var maxVector:Vector3 = null;
		
		for (i in meshes) {
			var mesh = i;
			var boundingBox = mesh.getBoundingInfo().boundingBox;
			if (minVector == null) {
				minVector = boundingBox.minimumWorld;
				maxVector = boundingBox.maximumWorld;
				continue;
			}
			minVector.MinimizeInPlace(boundingBox.minimumWorld);
			maxVector.MaximizeInPlace(boundingBox.maximumWorld);
		}
		
		return { minimum: minVector, maximum: maxVector };
	}

	public static function Center(meshesOrMinMaxVector:Dynamic):Vector3 {
		var minMaxVector:BabylonMinMax = meshesOrMinMaxVector.min != null ? meshesOrMinMaxVector : Mesh.MinMax(meshesOrMinMaxVector);
		return Vector3.Center(minMaxVector.minimum, minMaxVector.maximum);
	}
	
}
