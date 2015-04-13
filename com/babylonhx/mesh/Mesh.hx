package com.babylonhx.mesh;

import com.babylonhx.animations.IAnimatable;
import com.babylonhx.animations.Animatable;
import com.babylonhx.culling.BoundingSphere;
import com.babylonhx.Engine;
import com.babylonhx.materials.Effect;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Path3D;
import com.babylonhx.math.Plane;
import com.babylonhx.math.PositionNormalVertex;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.mesh.simplification.ISimplificationSettings;
import com.babylonhx.mesh.simplification.ISimplifier;
import com.babylonhx.mesh.simplification.QuadraticErrorSimplification;
import com.babylonhx.mesh.simplification.SimplificationSettings;
import com.babylonhx.mesh.simplification.SimplificationTask;
import com.babylonhx.Node;
import com.babylonhx.mesh.LinesMesh;
import com.babylonhx.cameras.Camera;
import com.babylonhx.culling.BoundingInfo;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.tools.AsyncLoop;
import com.babylonhx.tools.Tools;
import com.babylonhx.materials.Material;
import com.babylonhx.materials.textures.Texture;

import haxe.Json;

import com.babylonhx.utils.Image;
import com.babylonhx.utils.typedarray.Float32Array;
import com.babylonhx.utils.typedarray.UInt8Array;
import com.babylonhx.utils.typedarray.ArrayBuffer;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Mesh') class Mesh extends AbstractMesh implements IGetSetVerticesData {
	
	public static inline var FRONTSIDE:Int = 0;
	public static inline var BACKSIDE:Int = 1;
	public static inline var DOUBLESIDE:Int = 2;
	public static inline var DEFAULTSIDE:Int = 0;
	
	// Members
	public var delayLoadState = Engine.DELAYLOADSTATE_NONE;
	public var instances:Array<InstancedMesh> = [];
	public var delayLoadingFile:String;
	public var _binaryInfo:Dynamic;
	private var _LODLevels:Array<MeshLODLevel> = [];
	public var onLODLevelSelection:Float->Mesh->Mesh->Void;

	// Private
	public var _geometry:Geometry;
	private var _onBeforeRenderCallbacks:Array<AbstractMesh->Void> = [];
	private var _onAfterRenderCallbacks:Array<AbstractMesh->Void> = [];
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
	private var _sideOrientation:Int = Mesh.DEFAULTSIDE;
	public var sideOrientation(get, set):Int;
	
	// for extrusion
	public var path3D:Path3D;
	public var pathArray:Array<Array<Vector3>>;
	public var tessellation:Float;
	

	public function new(name:String, scene:Scene, parent:Node = null, ?source:Mesh, doNotCloneChildren:Bool = false) {
		super(name, scene);
		
		if (source != null){
			// Geometry
			if (source._geometry != null) {
				source._geometry.applyToMesh(this);
			}
			
			// Deep copy
			_deepCopy(source, this);
			
			// Material
			//this.material = source.material;
			
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
	
	static private function _deepCopy(source:Mesh, dest:Mesh) {
		dest.__smartArrayFlags = source.__smartArrayFlags.copy();
		dest._LODLevels = source._LODLevels.copy();
		dest._absolutePosition = source._absolutePosition.clone();
		dest._batchCache = source._batchCache;
		dest._boundingInfo = source._boundingInfo;
		dest._cache = source._cache;
		dest._checkCollisions = source._checkCollisions;
		dest._childrenFlag = source._childrenFlag;
		dest._collider = source._collider;
		dest._collisionsScalingMatrix = source._collisionsScalingMatrix.clone();
		dest._collisionsTransformMatrix = source._collisionsTransformMatrix.clone();
		dest._diffPositionForCollisions = source._diffPositionForCollisions.clone();
		dest._geometry = source._geometry;
		dest._instancesBufferSize = source._instancesBufferSize;
		dest._intersectionsInProgress = source._intersectionsInProgress.copy();
		dest._isBlocked	= source._isBlocked;
		dest._isDirty = source._isDirty;
		dest._isDisposed = source._isDisposed;
		dest._isEnabled = source._isEnabled;
		dest._isPickable = source._isPickable;
		dest._isReady = source._isReady;
		dest._localBillboard = source._localBillboard.clone();
		dest._localPivotScaling = source._localPivotScaling.clone();
		dest._localRotation = source._localRotation.clone();
		dest._localScaling = source._localScaling.clone();
		dest._localTranslation = source._localTranslation.clone();
		dest._localWorld = source._localWorld;
		dest._masterMesh = source._masterMesh;		// ??
		dest._material = source._material;
		dest._newPositionForCollisions = source._newPositionForCollisions.clone();
		dest._oldPositionForCollisions = source._oldPositionForCollisions.clone();
		dest._onAfterRenderCallbacks = source._onAfterRenderCallbacks;
		dest._onAfterWorldMatrixUpdate = source._onAfterWorldMatrixUpdate;
		dest._onBeforeRenderCallbacks = source._onBeforeRenderCallbacks;
		dest._parentRenderId = source._parentRenderId;
		dest._physicImpostor = source._physicImpostor;
		dest._physicRestitution = source._physicRestitution;
		dest._physicsFriction = source._physicsFriction;
		dest._physicsMass = source._physicsMass;
		dest._pivotMatrix = source._pivotMatrix.clone();
		if(source._positions != null) dest._positions = source._positions.copy();
		dest._preActivateId = source._preActivateId;
		dest._receiveShadows = source._receiveShadows;
		dest._renderId = source._renderId;
		dest._renderIdForInstances = source._renderIdForInstances.copy();
		dest._rotateYByPI = source._rotateYByPI.clone();
		dest._savedMaterial = source._savedMaterial;
		dest._scene = source._scene;
		dest._shouldGenerateFlatShading = source._shouldGenerateFlatShading;
		//dest._skeleton = source._skeleton.clone(Tools.uuid(), Tools.uuid());
		dest._submeshesOctree = source._submeshesOctree;
		dest._visibility = source._visibility;
		dest._visibleInstances = source._visibleInstances;
		dest._waitingActions = source._waitingActions;
		dest._waitingParentId = source._waitingParentId;
		//if(source._worldMatricesInstancesArray != null) dest._worldMatricesInstancesArray = source._worldMatricesInstancesArray.copy();
		dest._worldMatricesInstancesBuffer = source._worldMatricesInstancesBuffer;
		dest._worldMatrix = source._worldMatrix.clone();
		
				
		dest.definedFacingForward = source.definedFacingForward;
		dest.position = source.position.clone();
		dest.rotation = source.rotation.clone();
		if(source.rotationQuaternion != null) dest.rotationQuaternion = source.rotationQuaternion.clone();
		dest.scaling = source.scaling.clone();
		dest.billboardMode = source.billboardMode;
		dest.alphaIndex = source.alphaIndex;
		dest.infiniteDistance = source.infiniteDistance;
		dest.isVisible = source.isVisible;
		dest.showBoundingBox = source.showBoundingBox;
		dest.showSubMeshesBoundingBox = source.showSubMeshesBoundingBox;
		dest.onDispose = source.onDispose;
		dest.isBlocker = source.isBlocker;
		dest.renderingGroupId = source.renderingGroupId;
		dest.actionManager = source.actionManager;
		dest.renderOutline = source.renderOutline;
		dest.outlineColor = source.outlineColor.clone();
		dest.outlineWidth = source.outlineWidth;
		dest.renderOverlay = source.renderOverlay;
		dest.overlayColor = source.overlayColor.clone();
		dest.overlayAlpha = source.overlayAlpha;
		dest.hasVertexAlpha = source.hasVertexAlpha;
		dest.useVertexColors = source.useVertexColors;
		dest.applyFog = source.applyFog;
		dest.useOctreeForRenderingSelection = source.useOctreeForRenderingSelection;
		dest.useOctreeForPicking = source.useOctreeForPicking;
		dest.useOctreeForCollisions = source.useOctreeForCollisions;
		dest.layerMask = source.layerMask;
		dest.ellipsoid = source.ellipsoid.clone();
		dest.ellipsoidOffset = source.ellipsoidOffset.clone();
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
	
	public function getLODLevelAtDistance(distance:Float):Mesh {
		for (index in 0...this._LODLevels.length) {
			var level = this._LODLevels[index];
			
			if (level.distance == distance) {
				return level.mesh;
			}
		}
		
		return null;
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
			if (this.onLODLevelSelection != null) {
                this.onLODLevelSelection(distanceToCamera, this, this._LODLevels[this._LODLevels.length - 1].mesh);
            }
			return this;
		}
		
		for (index in 0...this._LODLevels.length) {
			var level = this._LODLevels[index];
			
			if (level.distance < distanceToCamera) {
				if (level.mesh != null) {
					level.mesh._preActivate();
                    level.mesh._updateSubMeshesBoundingInfo(this.worldMatrixFromCache);
				}
				
				if (this.onLODLevelSelection != null) {
                    this.onLODLevelSelection(distanceToCamera, this, level.mesh);
                }
				return level.mesh;
			}
		}
		
		if (this.onLODLevelSelection != null) {
            this.onLODLevelSelection(distanceToCamera, this, this);
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
	
	private function get_sideOrientation():Int {
		return this._sideOrientation;
	}

	private function set_sideOrientation(value:Int):Int {
		this._sideOrientation = value;
		return value;
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
	
	// Mesh positions update function :
	// updates the mesh positions according to the positionFunction returned values.
	// The positionFunction argument must be a javascript function accepting the mesh "positions" array as parameter.
	// This dedicated positionFunction computes new mesh positions according to the given mesh type.
	public function updateMeshPositions(positionFunction:Dynamic, computeNormals:Bool = true) {
		var positions = this.getVerticesData(VertexBuffer.PositionKind);
		positionFunction(positions);
		this.updateVerticesData(VertexBuffer.PositionKind, positions, false, false);
		if (computeNormals) {
			var indices = this.getIndices();
			var normals = this.getVerticesData(VertexBuffer.NormalKind);
			VertexData.ComputeNormals(positions, indices, normals);
			this.updateVerticesData(VertexBuffer.NormalKind, normals, false, false);
		}
	}

	public function makeGeometryUnique() {
		if (this._geometry == null) {
			return;
		}
		
		var geometry = this._geometry.copy(Geometry.RandomId());
		geometry.applyToMesh(this);
	}

	public function setIndices(indices:Array<Int>, totalVertices:Int = -1) {
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

	public function registerBeforeRender(func:AbstractMesh->Void) {
		this._onBeforeRenderCallbacks.push(func);
	}

	public function unregisterBeforeRender(func:AbstractMesh->Void) {
		var index = this._onBeforeRenderCallbacks.indexOf(func);
		if (index > -1) {
			this._onBeforeRenderCallbacks.splice(index, 1);
		}
	}

	public function registerAfterRender(func:AbstractMesh->Void) {
		this._onAfterRenderCallbacks.push(func);
	}

	public function unregisterAfterRender(func:AbstractMesh->Void) {
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
	
	public function _processRendering(subMesh:SubMesh, effect:Effect, fillMode:Int, batch:_InstancesBatch, hardwareInstancedRendering:Bool,
		onBeforeDraw:Bool->Matrix->Void) {
		var scene = this.getScene();
		var engine = scene.getEngine();

		if (hardwareInstancedRendering) {
			this._renderWithInstances(subMesh, fillMode, batch, effect, engine);
		} else {
			if (batch.renderSelf[subMesh._id]) {
				// Draw
				if (onBeforeDraw != null) {
					onBeforeDraw(false, this.getWorldMatrix());
				}
				
				this._draw(subMesh, fillMode);
			}
			
			if (batch.visibleInstances[subMesh._id] != null) {
				for (instanceIndex in 0...batch.visibleInstances[subMesh._id].length) {
					var instance = batch.visibleInstances[subMesh._id][instanceIndex];
					
					// World
					var world = instance.getWorldMatrix();
					if (onBeforeDraw != null) {
						onBeforeDraw(true, world);
					}
					
					// Draw
					this._draw(subMesh, fillMode);
				}
			}
		}
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
			this._onBeforeRenderCallbacks[callbackIndex](this);
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
			this._onAfterRenderCallbacks[callbackIndex](this);
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
			
			var getBinaryData = (this.delayLoadingFile.indexOf(".babylonbinarymeshdata") != -1);
			
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
		
		var onload = function(img:Image) {						
			this.applyDisplacementMapFromBuffer(img.data, img.width, img.height, minHeight, maxHeight);
			
			if (onSuccess != null) {
				onSuccess(this);
			}
		};
		
		Tools.LoadImage(url, onload);
	}

	public function applyDisplacementMapFromBuffer(buffer:UInt8Array, heightMapWidth:Float, heightMapHeight:Float, minHeight:Float, maxHeight:Float) {
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
			#if !js
			var r = buffer.__get(pos) / 255.0;
			var g = buffer.__get(pos + 1) / 255.0;
			var b = buffer.__get(pos + 2) / 255.0;
			#else
			var r = buffer[pos] / 255.0;
			var g = buffer[pos + 1] / 255.0;
			var b = buffer[pos + 2] / 255.0;
			#end
			
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
	 * @param successCallback optional success callback to be called after the simplification finished processing all settings.
	 */
	public function simplify(settings:Array<ISimplificationSettings>, parallelProcessing:Bool = true, simplificationType:Int = SimplificationSettings.QUADRATIC, ?successCallback:Void->Void) {
		this.getScene().simplificationQueue.addTask(new SimplificationTask(settings, simplificationType, this, successCallback, parallelProcessing));  
	}
	
	/**
	 * Optimization of the mesh's indices, in case a mesh has duplicated vertices.
	 * The function will only reorder the indices and will not remove unused vertices to avoid problems with submeshes.
	 * This should be used together with the simplification to avoid disappearing triangles.
	 * @param successCallback an optional success callback to be called after the optimization finished.
	 */
	public function optimizeIndices(?successCallback:Mesh->Void) {
		var indices = this.getIndices();
		var positions = this.getVerticesData(VertexBuffer.PositionKind);
		var vectorPositions:Array<Vector3> = [];
		var pos:Int = 0;
		while(pos < positions.length) {
			vectorPositions.push(Vector3.FromArray(positions, pos));
			pos += 3;
		}
		var dupes:Array<Int> = [];
		
		AsyncLoop.SyncAsyncForLoop(vectorPositions.length, 40, function (iteration:Int) {
			var realPos:Int = vectorPositions.length - 1 - iteration;
			var testedPosition:Vector3 = vectorPositions[realPos];
			for (j in 0...realPos) {
				var againstPosition = vectorPositions[j];
				if (testedPosition.equals(againstPosition)) {
					dupes[realPos] = j;
					break;
				}
			}
		}, function() {
			for (i in 0...indices.length) {
				indices[i] = dupes[indices[i]];// != null ? dupes[indices[i]] : indices[i];
			}
			
			//indices are now reordered
			var originalSubMeshes = this.subMeshes.slice(0);
			this.setIndices(indices);
			this.subMeshes = originalSubMeshes;
			if (successCallback != null) {
				successCallback(this);
			}
		});
	}

	// Statics
	public static function CreateRibbon(?name:String, pathArray:Array<Array<Vector3>>, ?closeArray:Bool = false, ?closePath:Bool = false, ?offset:Int, scene:Scene, ?updatable:Bool = false, ?sideOrientation:Int = Mesh.DEFAULTSIDE, ribbonInstance:Mesh = null):Mesh {
		if (ribbonInstance != null) {   // existing ribbon instance update
			// positionFunction : ribbon case
			// only pathArray and sideOrientation parameters are taken into account for positions update
			var positionsOfRibbon = function (pathArray:Array<Array<Vector3>>, sideOrientation:Int) {
				var positionFunction = function (positions) {
					var minlg = pathArray[0].length;
					var i:Int = 0;
					var ns = (sideOrientation == Mesh.DOUBLESIDE) ? 2 : 1;
					for (si in 1...ns+1) {
						for (p in 0...pathArray.length) {
							var path = pathArray[p];
							var l = path.length;
							minlg = (minlg < l) ? minlg : l;
							var j:Int = 0;
							while (j < minlg) {
								positions[i] = path[j].x;
								positions[i + 1] = path[j].y;
								positions[i + 2] = path[j].z;
								j++;
								i += 3;
							}
						}
					}
				};
				return positionFunction;
			};
			var sideOrientation = ribbonInstance.sideOrientation;
			var positionFunction = positionsOfRibbon(pathArray, sideOrientation);
			ribbonInstance.updateMeshPositions(positionFunction);
			
			return ribbonInstance;
		}
		else {  // new ribbon creation
			var ribbon = new Mesh(name, scene);
			ribbon.sideOrientation = sideOrientation;
			var vertexData = VertexData.CreateRibbon(pathArray, closeArray, closePath, offset, sideOrientation);
			
			vertexData.applyToMesh(ribbon, updatable);
			
			return ribbon;
		}
	}
	
	public static function CreateBox(name:String, size:Float, scene:Scene, updatable:Bool = false, sideOrientation:Int = Mesh.DEFAULTSIDE):Mesh {
		var box = new Mesh(name, scene);
		var vertexData = VertexData.CreateBox(size, sideOrientation);
		
		vertexData.applyToMesh(box, updatable);
		
		return box;
	}

	public static function CreateSphere(name:String, segments:Int, diameter:Float, scene:Scene, updatable:Bool = false, sideOrientation:Int = Mesh.DEFAULTSIDE):Mesh {
		var sphere = new Mesh(name, scene);
		var vertexData = VertexData.CreateSphere(segments, diameter, sideOrientation);
		
		vertexData.applyToMesh(sphere, updatable);
		
		return sphere;
	}

	// Cylinder and cone (Code inspired by SharpDX.org)
	public static function CreateCylinder(name:String, height:Float, diameterTop:Float, diameterBottom:Float, tessellation:Int, subdivisions:Int, scene:Scene, updatable:Bool = false, sideOrientation:Int = Mesh.DEFAULTSIDE):Mesh {		
		var cylinder = new Mesh(name, scene);
		var vertexData = VertexData.CreateCylinder(height, diameterTop, diameterBottom, tessellation, subdivisions, sideOrientation);
		
		vertexData.applyToMesh(cylinder, updatable);
		
		return cylinder;
	}

	// Torus  (Code from SharpDX.org)
	public static function CreateTorus(name:String, diameter:Float, thickness:Float, tessellation:Int, scene:Scene, updatable:Bool = false, sideOrientation:Int = Mesh.DEFAULTSIDE):Mesh {
		var torus = new Mesh(name, scene);
		var vertexData = VertexData.CreateTorus(diameter, thickness, tessellation, sideOrientation);
		
		vertexData.applyToMesh(torus, updatable);
		
		return torus;
	}

	public static function CreateTorusKnot(name:String, radius:Float, tube:Float, radialSegments:Int, tubularSegments:Int, p:Float, q:Float, scene:Scene, updatable:Bool = false, sideOrientation:Int = Mesh.DEFAULTSIDE):Mesh {
		var torusKnot = new Mesh(name, scene);
		var vertexData = VertexData.CreateTorusKnot(radius, tube, radialSegments, tubularSegments, p, q, sideOrientation);		
		vertexData.applyToMesh(torusKnot, updatable);		
		return torusKnot;
	}

	// Lines
	public static function CreateLines(name:String, points:Array<Vector3>, scene:Scene, updatable:Bool = false, linesInstance:LinesMesh = null):LinesMesh {
		if (linesInstance != null) { // lines update
			var positionsOfLines = function (points:Array<Vector3>):Dynamic {
				var positionFunction = function (positions:Array<Float>) {
					var i:Int = 0;
					for(p in 0...points.length) {
						positions[i] = points[p].x;
						positions[i + 1] = points[p].y;
						positions[i + 2] = points[p].z;
						i += 3;
					}
				};
				return positionFunction;
			};
			var positionFunction = positionsOfLines(points);
			linesInstance.updateMeshPositions(positionFunction, false);
			
			return linesInstance;			
		}
		
		// lines creation
		var lines = new LinesMesh(name, scene, updatable);
		var vertexData = VertexData.CreateLines(points);
		vertexData.applyToMesh(lines, updatable);
		
		return lines;
	}
	
	// Extrusion
	public static function ExtrudeShape(name:String, shape:Array<Vector3>, path:Array<Vector3>, scale:Float = 1, rotation:Float = 0, scene:Scene, updatable:Bool = false, sideOrientation:Int = Mesh.DEFAULTSIDE, extrudedInstance:Mesh = null):Mesh {
		var extruded = Mesh._ExtrudeShapeGeneric(name, shape, path, scale, rotation, null, null, false, false, false, scene, updatable, sideOrientation, extrudedInstance);
		return extruded;
	}

	public static function ExtrudeShapeCustom(name:String, shape:Array<Vector3>, path:Array<Vector3>, scaleFunction, rotateFunction, ribbonCloseArray:Bool = false, ribbonClosePath:Bool = false, scene:Scene, updatable:Bool = false, sideOrientation:Int = Mesh.DEFAULTSIDE, extrudedInstance:Mesh = null):Mesh {
		var extrudedCustom = Mesh._ExtrudeShapeGeneric(name, shape, path, null, null, scaleFunction, rotateFunction, ribbonCloseArray, ribbonClosePath, true, scene, updatable, sideOrientation, extrudedInstance);
		return extrudedCustom;
	}

	private static function _ExtrudeShapeGeneric(name:String, shape:Array<Vector3>, curve:Array<Vector3>, ?scale:Float, ?rotation:Float, scaleFunction:Float->Float->Float, rotateFunction:Float->Float->Float, rbCA:Bool, rbCP:Bool, custom:Bool, scene:Scene, updtbl:Bool, side:Int, instance:Mesh = null):Mesh {
		// extrusion geometry
		var extrusionPathArray = function(shape:Array<Vector3>, curve:Array<Vector3>, path3D:Path3D, shapePaths:Array<Array<Vector3>>, scale:Float, rotation:Float, scaleFunction:Int->Float->Float, rotateFunction:Int->Float->Float, custom:Bool) {
			var tangents:Array<Vector3> = path3D.getTangents();
			var normals:Array<Vector3> = path3D.getNormals();
			var binormals:Array<Vector3> = path3D.getBinormals();
			var distances:Array<Float> = path3D.getDistances();
			
			var angle:Float = 0;
			var returnScale = function(i:Int, distance:Float):Float { 
				return scale; 
			};
			var returnRotation = function(i:Int, distance:Float):Float { 
				return rotation; 
			};
			var rotate = custom ? rotateFunction : returnRotation;
			var scl = custom ? scaleFunction : returnScale;
			var index:Int = 0;
			
			for (i in 0...curve.length) {
				var shapePath = new Array<Vector3>();
				var angleStep = rotate(i, distances[i]);
				var scaleRatio = scl(i, distances[i]);
				for (p in 0...shape.length) {
					var rotationMatrix = Matrix.RotationAxis(tangents[i], angle);
					var planed = ((tangents[i].scale(shape[p].z)).add(normals[i].scale(shape[p].x)).add(binormals[i].scale(shape[p].y)));
					var rotated = Vector3.TransformCoordinates(planed, rotationMatrix).scaleInPlace(scaleRatio).add(curve[i]);
					shapePath.push(rotated);
				}
				shapePaths[index] = shapePath;
				angle += angleStep;
				index++;
			}
			return shapePaths;
		};
		
		if (instance != null) { // instance update
			
			var path3D = instance.path3D.update(curve);
			var pathArray = extrusionPathArray(shape, curve, instance.path3D, instance.pathArray, scale, rotation, scaleFunction, rotateFunction, custom);
			instance = Mesh.CreateRibbon(null, pathArray, null, null, null, null, null, null, instance);
			
			return instance;
		}
		// extruded shape creation
		
		var path3D:Path3D = new Path3D(curve);
		var newShapePaths:Array<Array<Vector3>> = [];
		var pathArray = extrusionPathArray(shape, curve, path3D, newShapePaths, scale, rotation, scaleFunction, rotateFunction, custom);
		
		var extrudedGeneric = Mesh.CreateRibbon(name, pathArray, rbCA, rbCP, 0, scene, updtbl, side);
		extrudedGeneric.pathArray = pathArray;
		extrudedGeneric.path3D = path3D;
		
		return extrudedGeneric;
	}

	// Plane & ground
	public static function CreatePlane(name:String, size:Float, scene:Scene, updatable:Bool = false, sideOrientation:Int = Mesh.DEFAULTSIDE):Mesh {
		var plane = new Mesh(name, scene);
		var vertexData = VertexData.CreatePlane(size, sideOrientation);
		vertexData.applyToMesh(plane, updatable);
		return plane;
	}
	
	public static function CreateDisc(name:String, radius:Float, tessellation:Int, scene:Scene, updatable:Bool = false, sideOrientation:Int = Mesh.DEFAULTSIDE):Mesh {
        var disc = new Mesh(name, scene);
        var vertexData = VertexData.CreateDisc(radius, tessellation, sideOrientation);
		
        vertexData.applyToMesh(disc, updatable);
		
        return disc;
    }

	public static function CreateGround(name:String, width:Float, height:Float, subdivisions:Int, scene:Scene, updatable:Bool = false):Mesh {
		var ground = new GroundMesh(name, scene);
		ground._setReady(false);
		ground.subdivisions = subdivisions;
		
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
		ground.subdivisions = subdivisions;
		ground._setReady(false);
		
		var onload = function(img:Image) {
			var vertexData = VertexData.CreateGroundFromHeightMap(width, height, subdivisions, minHeight, maxHeight, img.data, img.width, img.height);
			
			vertexData.applyToMesh(ground, updatable);
			
			ground._setReady(true);
			
			//execute ready callback, if set
			if (onReady != null) {
				onReady(ground);
			}
		}
		
		Tools.LoadImage(url, onload);
				
		return ground;
	}
	
	public static function CreateTube(name:String, path:Array<Vector3>, radius:Float, tessellation:Float, radiusFunction:Int->Float->Float, scene:Scene, updatable:Bool = false, sideOrientation:Int = Mesh.DEFAULTSIDE, tubeInstance:Mesh = null):Mesh {
		// tube geometry
		var tubePathArray = function (path:Array<Vector3>, path3D:Path3D, circlePaths:Array<Array<Vector3>>, radius:Float, tessellation:Float, ?radiusFunction:Int->Float->Float) {
			var tangents = path3D.getTangents();
			var normals = path3D.getNormals();
			var distances = path3D.getDistances();
			var pi2 = Math.PI * 2;
			var step = pi2 / tessellation;
			var returnRadius:Int->Float->Float = function(i:Int, distance:Float):Float { return radius; };
			var radiusFunctionFinal:Int->Float->Float = radiusFunction != null ? radiusFunction : returnRadius;
			
			var circlePath:Array<Vector3> = [];
			var rad:Float = 0;
			var normal:Vector3 = Vector3.Zero();
			var rotated:Vector3 = Vector3.Zero();
			var rotationMatrix:Matrix;
			var index:Int = 0;
			for (i in 0...path.length) {
				rad = radiusFunctionFinal(i, distances[i]); // current radius
				circlePath = [];              				// current circle array
				normal = normals[i];          				// current normal  
				var ang:Float = 0.0;
				while(ang < pi2) {
					rotationMatrix = Matrix.RotationAxis(tangents[i], ang);
					rotated = Vector3.TransformCoordinates(normal, rotationMatrix).scaleInPlace(rad).add(path[i]);
					circlePath.push(rotated);
					ang += step;
				}
				circlePaths[index] = circlePath;
				index++;
			}
			return circlePaths;
		};
		
		if (tubeInstance != null) { // tube update
			var path3D = tubeInstance.path3D.update(path);
			var pathArray = tubePathArray(path, path3D, tubeInstance.pathArray, radius, tubeInstance.tessellation, radiusFunction);
			tubeInstance = Mesh.CreateRibbon(null, pathArray, null, null, null, null, null, null, tubeInstance);
			
			return tubeInstance;
		}
		
		// tube creation
		var path3D:Path3D = new Path3D(path);
		var newPathArray:Array<Array<Vector3>> = [];
		var pathArray = tubePathArray(path, path3D, newPathArray, radius, tessellation, radiusFunction);
		var tube = Mesh.CreateRibbon(name, pathArray, false, true, 0, scene, updatable, sideOrientation);
		tube.pathArray = pathArray;
		tube.path3D = path3D;
		tube.tessellation = tessellation;
		
		return tube;
	}
	
	// Decals
    public static function CreateDecal(name:String, sourceMesh:AbstractMesh, position:Vector3, normal:Vector3, size:Vector3, angle:Float = 0) {
        var indices:Array<Int> = sourceMesh.getIndices();
        var positions:Array<Float> = sourceMesh.getVerticesData(VertexBuffer.PositionKind);
        var normals:Array<Float> = sourceMesh.getVerticesData(VertexBuffer.NormalKind);
		
        // Getting correct rotation
        if (normal == null) {
            var target:Vector3 = new Vector3(0, 0, 1);
            var camera:Camera = sourceMesh.getScene().activeCamera;
            var cameraWorldTarget:Vector3 = Vector3.TransformCoordinates(target, camera.getWorldMatrix());
			
            normal = camera.globalPosition.subtract(cameraWorldTarget);
        }
		
        var yaw:Float = -Math.atan2(normal.z, normal.x) - Math.PI / 2;
        var len:Float = Math.sqrt(normal.x * normal.x + normal.z * normal.z);
        var pitch:Float = Math.atan2(normal.y, len);
		
        // Matrix
        var decalWorldMatrix:Matrix = Matrix.RotationYawPitchRoll(yaw, pitch, angle).multiply(Matrix.Translation(position.x, position.y, position.z));
        var inverseDecalWorldMatrix:Matrix = Matrix.Invert(decalWorldMatrix);
        var meshWorldMatrix:Matrix = sourceMesh.getWorldMatrix();
        var transformMatrix:Matrix = meshWorldMatrix.multiply(inverseDecalWorldMatrix);
		
        var vertexData:VertexData = new VertexData();
        vertexData.indices = [];
        vertexData.positions = [];
        vertexData.normals = [];
        vertexData.uvs = [];
		
        var currentVertexDataIndex:Int = 0;
		
        var extractDecalVector3 = function(indexId:Int):PositionNormalVertex {
            var vertexId:Int = indices[indexId];
            var result:PositionNormalVertex = new PositionNormalVertex();
            result.position = new Vector3(positions[vertexId * 3], positions[vertexId * 3 + 1], positions[vertexId * 3 + 2]);
			
            // Send vector to decal local world
            result.position = Vector3.TransformCoordinates(result.position, transformMatrix);
			
            // Get normal
            result.normal = new Vector3(normals[vertexId * 3], normals[vertexId * 3 + 1], normals[vertexId * 3 + 2]);
			
            return result;
        }
        
        // Inspired by https://github.com/mrdoob/three.js/blob/eee231960882f6f3b6113405f524956145148146/examples/js/geometries/DecalGeometry.js
        var clip = function(vertices:Array<PositionNormalVertex>, axis:Vector3):Array<PositionNormalVertex> {
            if (vertices.length == 0) {
                return vertices;
            }
			
            var clipSize = 0.5 * Math.abs(Vector3.Dot(size, axis));
			
            var clipVertices = function(v0:PositionNormalVertex, v1:PositionNormalVertex):PositionNormalVertex {
                var clipFactor = Vector3.GetClipFactor(v0.position, v1.position, axis, clipSize);
				
                return new PositionNormalVertex(
                    Vector3.Lerp(v0.position, v1.position, clipFactor),
                    Vector3.Lerp(v0.normal, v1.normal, clipFactor)
                );
            }
			
            var result:Array<PositionNormalVertex> = [];
			
			var v1Out:Bool = false;
			var v2Out:Bool = false;
			var v3Out:Bool = false;
			var total = 0;
			var nV1:PositionNormalVertex = null;
			var nV2:PositionNormalVertex = null;
			var nV3:PositionNormalVertex = null;
			var nV4:PositionNormalVertex = null;
			
			var d1:Float = 0.0;
			var d2:Float = 0.0;
			var d3:Float = 0.0;
			
			var index = 0;
			while(index < vertices.length) {				
                d1 = Vector3.Dot(vertices[index].position, axis) - clipSize;
                d2 = Vector3.Dot(vertices[index + 1].position, axis) - clipSize;
                d3 = Vector3.Dot(vertices[index + 2].position, axis) - clipSize;
				
                v1Out = d1 > 0;
                v2Out = d2 > 0;
                v3Out = d3 > 0;
				
                total = (v1Out ? 1 : 0) + (v2Out ? 1 : 0) + (v3Out ? 1 : 0);
				
                switch (total) {
                    case 0:
                        result.push(vertices[index]);
                        result.push(vertices[index + 1]);
                        result.push(vertices[index + 2]);
                        
                    case 1:
                        if (v1Out) {
                            nV1 = vertices[index + 1];
                            nV2 = vertices[index + 2];
                            nV3 = clipVertices(vertices[index], nV1);
                            nV4 = clipVertices(vertices[index], nV2);
                        }
						
                        if (v2Out) {
                            nV1 = vertices[index];
                            nV2 = vertices[index + 2];
                            nV3 = clipVertices(vertices[index + 1], nV1);
                            nV4 = clipVertices(vertices[index + 1], nV2);
							
                            result.push(nV3);
                            result.push(nV2.clone());
                            result.push(nV1.clone());
							
                            result.push(nV2.clone());
                            result.push(nV3.clone());
                            result.push(nV4);
                            //break;
                        } else {
							if (v3Out) {
								nV1 = vertices[index];
								nV2 = vertices[index + 1];
								nV3 = clipVertices(vertices[index + 2], nV1);
								nV4 = clipVertices(vertices[index + 2], nV2);
							}
							
							result.push(nV1.clone());
							result.push(nV2.clone());
							result.push(nV3);
							
							result.push(nV4);
							result.push(nV3.clone());
							result.push(nV2.clone());
						}
                        
                    case 2:
                        if (!v1Out) {
                            nV1 = vertices[index].clone();
                            nV2 = clipVertices(nV1, vertices[index + 1]);
                            nV3 = clipVertices(nV1, vertices[index + 2]);
                            result.push(nV1);
                            result.push(nV2);
                            result.push(nV3);
                        }
                        if (!v2Out) {
                            nV1 = vertices[index + 1].clone();
                            nV2 = clipVertices(nV1, vertices[index + 2]);
                            nV3 = clipVertices(nV1, vertices[index]);
                            result.push(nV1);
                            result.push(nV2);
                            result.push(nV3);
                        }
                        if (!v3Out) {
                            nV1 = vertices[index + 2].clone();
                            nV2 = clipVertices(nV1, vertices[index]);
                            nV3 = clipVertices(nV1, vertices[index + 1]);
                            result.push(nV1);
                            result.push(nV2);
                            result.push(nV3);
                        }
                        
                    case 3:
                        //
                }
				
				index += 3;
            }
			
            return result;
        }
		
		var faceVertices:Array<PositionNormalVertex> = [];
		var index = 0;
		while(index < indices.length) {
            faceVertices = [];
			
            faceVertices.push(extractDecalVector3(index));
            faceVertices.push(extractDecalVector3(index + 1));
            faceVertices.push(extractDecalVector3(index + 2));
			
            // Clip
            faceVertices = clip(faceVertices, new Vector3(1, 0, 0));
            faceVertices = clip(faceVertices, new Vector3(-1, 0, 0));
            faceVertices = clip(faceVertices, new Vector3(0, 1, 0));
            faceVertices = clip(faceVertices, new Vector3(0, -1, 0));
            faceVertices = clip(faceVertices, new Vector3(0, 0, 1));
            faceVertices = clip(faceVertices, new Vector3(0, 0, -1));
			
            if (faceVertices.length == 0) {
				index += 3;
                continue;
            }
              
            // Add UVs and get back to world
			var localRotationMatrix = Matrix.RotationYawPitchRoll(yaw, pitch, angle);
			var vertex:PositionNormalVertex = null;
            for (vIndex in 0...faceVertices.length) {
                vertex = faceVertices[vIndex];
				
                vertexData.indices.push(currentVertexDataIndex);
                vertex.position.toArray(vertexData.positions, currentVertexDataIndex * 3);
                vertex.normal.toArray(vertexData.normals, currentVertexDataIndex * 3);
                vertexData.uvs.push(0.5 + vertex.position.x / size.x);
                vertexData.uvs.push(0.5 + vertex.position.y / size.y);
				
                currentVertexDataIndex++;
            }
			
			index += 3;
        }
		
        // Return mesh
        var decal = new Mesh(name, sourceMesh.getScene());
        vertexData.applyToMesh(decal);
		
		decal.position = position.clone();
		decal.rotation = new Vector3(pitch, yaw, angle);
		
        return decal;
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
	
	public static function MergeMeshes(meshes:Array<Mesh>, disposeSource:Bool = true, allow32BitsIndices:Bool = false):Mesh {
		var source:Mesh = meshes[0];
		var material:Material = source.material;
		var scene:Scene = source.getScene();
		
		if (!allow32BitsIndices) {
			var totalVertices = 0;
			
			// Counting vertices
			for (index in 0...meshes.length) {
				totalVertices += meshes[index].getTotalVertices();
				
				if (totalVertices > 65536) {
					trace("Cannot merge meshes because resulting mesh will have more than 65536 vertices. Please use allow32BitsIndices = true to use 32 bits indices");
					return null;
				}
			}
		}
		
		// Merge
		var vertexData:VertexData = VertexData.ExtractFromMesh(source);
		vertexData.transform(source.getWorldMatrix());
		
		for (index in 1...meshes.length) {
			var otherVertexData = VertexData.ExtractFromMesh(meshes[index]);
			otherVertexData.transform(meshes[index].getWorldMatrix());
			
			vertexData.merge(otherVertexData);
		}
		
		var newMesh:Mesh = new Mesh(source.name + "_merged", scene);
		
		vertexData.applyToMesh(newMesh);
		
		// Setting properties
		newMesh.material = material;
		newMesh.checkCollisions = source.checkCollisions;
		
		// Cleaning
		if (disposeSource) {
			for (index in 0...meshes.length) {
				meshes[index].dispose();
			}
		}
		
		return newMesh;
	}
	
}
