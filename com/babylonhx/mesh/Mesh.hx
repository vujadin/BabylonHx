package com.babylonhx.mesh;

import com.babylonhx.Node;
import com.babylonhx.engine.Engine;
import com.babylonhx.animations.IAnimatable;
import com.babylonhx.animations.Animatable;
import com.babylonhx.animations.Animation;
import com.babylonhx.culling.BoundingSphere;
import com.babylonhx.materials.Effect;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Path3D;
import com.babylonhx.math.Plane;
import com.babylonhx.math.PositionNormalVertex;
import com.babylonhx.math.Quaternion;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Tools.BabylonMinMax;
import com.babylonhx.math.Vector4;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Tmp;
import com.babylonhx.math.Tools as MathTools;
import com.babylonhx.mesh.MeshBuilder.BoxOptions;
import com.babylonhx.mesh.MeshBuilder.CapsuleOptions;
import com.babylonhx.mesh.MeshBuilder.CylinderOptions;
import com.babylonhx.mesh.MeshBuilder.DashedLinesOptions;
import com.babylonhx.mesh.MeshBuilder.DiscOptions;
import com.babylonhx.mesh.MeshBuilder.GroundFromHeightmapOptions;
import com.babylonhx.mesh.MeshBuilder.GroundOptions;
import com.babylonhx.mesh.MeshBuilder.IcoSphereOptions;
import com.babylonhx.mesh.MeshBuilder.LatheOptions;
import com.babylonhx.mesh.MeshBuilder.LinesOptions;
import com.babylonhx.mesh.MeshBuilder.PlaneOptions;
import com.babylonhx.mesh.MeshBuilder.PolyhedronOptions;
import com.babylonhx.mesh.MeshBuilder.RibbonOptions;
import com.babylonhx.mesh.MeshBuilder.SphereOptions;
import com.babylonhx.mesh.MeshBuilder.TiledGroundOptions;
import com.babylonhx.mesh.MeshBuilder.TorusKnotOptions;
import com.babylonhx.mesh.MeshBuilder.TorusOptions;
import com.babylonhx.mesh.MeshBuilder.TubeOptions;
import com.babylonhx.mesh.simplification.ISimplificationSettings;
import com.babylonhx.mesh.simplification.ISimplifier;
import com.babylonhx.mesh.simplification.QuadraticErrorSimplification;
import com.babylonhx.mesh.simplification.SimplificationSettings;
import com.babylonhx.mesh.simplification.SimplificationTask;
import com.babylonhx.mesh.LinesMesh;
import com.babylonhx.cameras.Camera;
import com.babylonhx.culling.BoundingInfo;
import com.babylonhx.particles.IParticleSystem;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.tools.AsyncLoop;
import com.babylonhx.tools.Observable;
import com.babylonhx.tools.Observer;
import com.babylonhx.tools.EventState;
import com.babylonhx.tools.Tools;
import com.babylonhx.tools.Tags;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.physics.PhysicsBodyCreationOptions;
import com.babylonhx.materials.Material;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.morph.MorphTargetManager;
import com.babylonhx.utils.Image;

import haxe.Json;
import haxe.ds.Vector;

import com.babylonhx.utils.typedarray.UInt32Array;
import com.babylonhx.utils.typedarray.Float32Array;
import com.babylonhx.utils.typedarray.UInt8Array;
import com.babylonhx.utils.typedarray.ArrayBuffer;
import com.babylonhx.utils.typedarray.Int32Array;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Mesh') class Mesh extends AbstractMesh implements IGetSetVerticesData implements IAnimatable {
	
	public static inline var FRONTSIDE:Int = 0;			// Mesh side orientation : usually the external or front surface
	public static inline var BACKSIDE:Int = 1;			// Mesh side orientation : usually the internal or back surface
	public static inline var DOUBLESIDE:Int = 2;		// Mesh side orientation : both internal and external or front and back surfaces
	public static inline var DEFAULTSIDE:Int = 0;		// Mesh side orientation : by default, `FRONTSIDE`
	public static inline var NO_CAP:Int = 0;			// Mesh cap setting : no cap
    public static inline var CAP_START:Int = 1;			// Mesh cap setting : one cap at the beginning of the mesh
    public static inline var CAP_END:Int = 2;			// Mesh cap setting : one cap at the end of the mesh
    public static inline var CAP_ALL:Int = 3;			// Mesh cap setting : two caps, one at the beginning  and one at the end of the mesh
	
	// Events 

	// BHX: observables moved to AbstractMesh as InstancedMesh inherits it
	
	// Members
	public var delayLoadState:Int = Engine.DELAYLOADSTATE_NONE;
	public var instances:Array<InstancedMesh> = [];
	public var delayLoadingFile:String;
	public var _binaryInfo:Dynamic;
	private var _LODLevels:Array<MeshLODLevel> = [];
	public var onLODLevelSelection:Float->Mesh->Mesh->Void;
	
	// Morph
	private var _morphTargetManager:MorphTargetManager;
	public var morphTargetManager(get, set):MorphTargetManager;
	inline private function get_morphTargetManager():MorphTargetManager {
		return this._morphTargetManager;
	}
	inline private function set_morphTargetManager(value:MorphTargetManager):MorphTargetManager {
		if (this._morphTargetManager == value) {
			return value;
		}
		this._morphTargetManager = value;
		this._syncGeometryWithMorphTargetManager();
		return value;
	}

	// Private
	@:allow(com.babylonhx.mesh.Geometry) 
	private var _geometry:Geometry;	
	public var _delayInfo:Array<String>; //ANY
	public var _delayLoadingFunction:Dynamic->Mesh->Void;
	
	public var _visibleInstances:_VisibleInstances;
	private var _renderIdForInstances:Array<Int> = [];
	private var _batchCache:_InstancesBatch = new _InstancesBatch();
	private var _instancesBufferSize:Int = Std.int(32 * 16 * 4); // let's start with a maximum of 32 instances
	private var _instancesBuffer:Buffer;
	private var _instancesData:Float32Array;
	private var _overridenInstanceCount:Int;
	
	private var _effectiveMaterial:Material;
	
	public var _shouldGenerateFlatShading:Bool = false;
	private var _preActivateId:Int;
	
	// Use by builder only to know what orientation were the mesh build in.
    public var _originalBuilderSideOrientation:Int = Mesh.DEFAULTSIDE;
	
	public var overrideMaterialSideOrientation:Int = -1;
	
	private var _areNormalsFrozen:Bool = false; // Will be used by ribbons mainly
	
	public var areNormalsFrozen(get, never):Bool;
	
	private var _sourcePositions:Float32Array; 	// Will be used to save original positions when using software skinning
    private var _sourceNormals:Float32Array; 	// Will be used to save original normals when using software skinning
	
	public var cap:Int = Mesh.NO_CAP;
	
	@:noCompletion
	public var _tags:String;
	@:noCompletion
	public var hasTags:Void->Bool;
	@:noCompletion
	public var addTags:String->Void;
	@:noCompletion
	public var removeTags:String->Void;
	
	// for extrusion
	public var path3D:Path3D;
	public var pathArray:Array<Array<Vector3>>;
	public var tessellation:Int;
	public var arc:Float;
	public var radius:Float;
	
	// for ribbon	
	@:allow(com.babylonhx.mesh.MeshBuilder.CreateRibbon) 
	private var _closePath:Bool = false;
	@:allow(com.babylonhx.mesh.MeshBuilder.CreateRibbon)
	private var _closeArray:Bool = false;
	@:allow(com.babylonhx.mesh.MeshBuilder.CreateRibbon) 
	private var _idx:Array<Int>;
	
	// Will be used to save a source mesh reference, If any
	private var _source:Mesh = null;
	public var source(get, never):Mesh;
	inline private function get_source():Mesh {
		return this._source;
	}
	
	public var isUnIndexed(get, set):Bool;
	inline private function get_isUnIndexed():Bool {
        return this._unIndexed;
    }
    inline private function set_isUnIndexed(value:Bool):Bool {
        if (this._unIndexed != value) {
			this._unIndexed = value;
			this._markSubMeshesAsAttributesDirty();
		}
		return value;
	}

	

	/**
	  * @constructor
	  * @param {string} name - The value used by scene.getMeshByName() to do a lookup.
	  * @param {Scene} scene - The scene to add this mesh to.
	  * @param {Node} parent - The parent of this mesh, if it has one
	  * @param {Mesh} source - An optional Mesh from which geometry is shared, cloned.
	  * @param {boolean} doNotCloneChildren - When cloning, skip cloning child meshes of source, default False.
	  *                  When false, achieved by calling a clone(), also passing False.
	  *                  This will make creation of children, recursive.
	  */
	public function new(name:String, scene:Scene = null, parent:Node = null, ?source:Mesh, doNotCloneChildren:Bool = false, clonePhysicsImpostor:Bool = true) {
		super(name, scene);
		
		scene = this.getScene();
		
		if (source != null) {
			// Source mesh
			this._source = source;
			
			// Geometry
			if (source._geometry != null) {
				source._geometry.applyToMesh(this);
			}
			
			// copy
			_deepCopy(source, this);
			
			// Tags
			if (Tags.HasTags(source)) {
				Tags.AddTagsTo(this, Tags.GetTags(source, true));
			}
			
			this.metadata = source.metadata;
			
			// Parent
			this.parent = source.parent;
			
			// Pivot                
			this.setPivotMatrix(source.getPivotMatrix());
			
			this.id = name + "." + source.id;
			
			// Material
			this.material = source.material;
			
			if (!doNotCloneChildren) {
				// Children
				var directDescendants = source.getDescendants(true);
				for (index in 0...directDescendants.length) {
					var child = directDescendants[index];
					
					if (Reflect.hasField(child, "clone")) {
						untyped child.clone(name + "." + child.name, this); 
					}
				}
			}
			
			// Physics clone  
			/*var physicsEngine = this.getScene().getPhysicsEngine();
			if (clonePhysicsImpostor && physicsEngine != null) {
				var impostor = physicsEngine.getImpostorForPhysicsObject(source);
				if (impostor != null) {
					this.physicsImpostor = impostor.clone(this);
				}
			}*/
			
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
		dest.position = source.position.clone();
		dest.rotation = source.rotation.clone();
		if (source.rotationQuaternion != null) {
			dest.rotationQuaternion = source.rotationQuaternion.clone();
		}
		dest.scaling = source.scaling.clone();
		dest.billboardMode = source.billboardMode;
		dest.alphaIndex = source.alphaIndex;
		dest.infiniteDistance = source.infiniteDistance;
		dest.isVisible = source.isVisible;
		dest.showBoundingBox = source.showBoundingBox;
		dest.showSubMeshesBoundingBox = source.showSubMeshesBoundingBox;
		//dest.onDispose = source.onDispose;
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
		dest.state = source.state;
		dest.definedFacingForward = source.definedFacingForward;
		dest.animations = source.animations.copy();
		dest.visibility = source.visibility;
		dest.isPickable = source.isPickable;
		dest.receiveShadows = source.receiveShadows;
		dest.computeBonesUsingShaders = source.computeBonesUsingShaders;
		dest.scalingDeterminant = source.scalingDeterminant;
		dest.numBoneInfluencers = source.numBoneInfluencers;		
		dest.alwaysSelectAsActiveMesh = source.alwaysSelectAsActiveMesh;
		dest.edgesWidth = source.edgesWidth;
		dest.edgesColor = source.edgesColor.clone();
		dest.delayLoadState = source.delayLoadState;
		dest.checkCollisions = source.checkCollisions;
		
		dest.__smartArrayFlags = source.__smartArrayFlags.copy();
		
		/*
		dest.isBlocked = source.isBlocked;		
		dest.areNormalsFrozen = source.areNormalsFrozen;
		dest.useBones = source.useBones;
		dest.worldMatrixFromCache = source.worldMatrixFromCache.clone();
		dest.absolutePosition = source.absolutePosition.clone();
		dest.isWorldMatrixFrozen = source.isWorldMatrixFrozen;		
		*/	
	}

	// Methods
	
	/**
	 * Returns the string "Mesh".  
	 */
	override public function getClassName():String {
		return "Mesh";
	}   

	/**
	 * Returns a string.  
	 * @param {boolean} fullDetails - support for multiple levels of logging within scene loading
	 */
	override public function toString(fullDetails:Bool = false):String {
		var ret = super.toString(fullDetails);
		ret += ", n vertices: " + this.getTotalVertices();
		ret += ", parent: " + (this._waitingParentId != null ? this._waitingParentId : (this.parent != null ? this.parent.name : "NONE"));
		
		if (this.animations != null) {
			for (i in 0...this.animations.length) {
				ret += ", animation[0]: " + this.animations[i].toString(fullDetails);
			}
		}
		
		if (fullDetails) {
			ret += ", flat shading: " + (this._geometry != null ? (this.getVerticesData(VertexBuffer.PositionKind).length / 3 == this.getIndices().length ? "YES" : "NO") : "UNKNOWN");
		}
		return ret;
	}
	
	public var hasLODLevels(get, never):Bool;
	private function get_hasLODLevels():Bool {
		return this._LODLevels.length > 0;
	}
	
	/**
     * Gets the list of {BABYLON.MeshLODLevel} associated with the current mesh
     * @returns an array of {BABYLON.MeshLODLevel} 
     */
	inline public function getLODLevels():Array<MeshLODLevel> {
        return this._LODLevels;
    }
	
	private function _sortLODLevels() {
		this._LODLevels.sort(function(a:MeshLODLevel, b:MeshLODLevel):Int {
			if (a.distance < b.distance) {
				return 1;
			}
			
			if (a.distance > b.distance) {
				return -1;
			}
			
			return 0;
		});
	}

	/**
	 * Add a mesh as LOD level triggered at the given distance.
	 * tutorial : http://doc.babylonjs.com/tutorials/How_to_use_LOD
	 * @param {number} distance - the distance from the center of the object to show this level
	 * @param {BABYLON.Mesh} mesh - the mesh to be added as LOD level
	 * @return {BABYLON.Mesh} this mesh (for chaining)
	 */
	public function addLODLevel(distance:Float, mesh:Mesh = null):Mesh {
		if (mesh != null && mesh._masterMesh != null) {
			Tools.Warn("You cannot use a mesh as LOD level twice");
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
	
	/**
	 * Returns the LOD level mesh at the passed distance or null if not found.  
	 * It is related to the method `addLODLevel(distance, mesh)`. 
	 * tutorial : http://doc.babylonjs.com/tutorials/How_to_use_LOD   
	 * Returns an object Mesh or `null`.  
	 */
	public function getLODLevelAtDistance(distance:Float):Mesh {
		for (index in 0...this._LODLevels.length) {
			var level = this._LODLevels[index];
			
			if (level.distance == distance) {
				return level.mesh;
			}
		}
		
		return null;
	}

	/**
	 * Remove a mesh from the LOD array
	 * @param {BABYLON.Mesh} mesh - the mesh to be removed.
	 * @return {BABYLON.Mesh} this mesh (for chaining)
	 */
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

	/**
	 * Returns the registered LOD mesh distant from the parameter `camera` position if any, else returns the current mesh.
	 * tuto : http://doc.babylonjs.com/tutorials/How_to_use_LOD
	 */
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
	
	public var geometry(get, never):Geometry;
	private function get_geometry():Geometry {
		return this._geometry;
	}

	/**
	 * Returns a positive integer : the total number of vertices within the mesh geometry or zero if the mesh has no geometry.
	 */
	override public function getTotalVertices():Int {
		if (this._geometry == null) {
			return 0;
		}
		
		return this._geometry.getTotalVertices();
	}

	/**
     * Returns an array of integers or floats, or a Float32Array, depending on the requested `kind` 
	 * (positions, indices, normals, etc).
     * If `copywhenShared` is true (default false) and if the mesh geometry is shared among some other meshes, 
	 * the returned array is a copy of the internal one.
     * Returns null if the mesh has no geometry or no vertex buffer.
     */
	override public function getVerticesData(kind:String, copyWhenShared:Bool = false, forceCopy:Bool = false):Float32Array {
		if (this._geometry == null) {
			return null;
		}
		
		return this._geometry.getVerticesData(kind, copyWhenShared);
	}

	/**
     * Returns the mesh `VertexBuffer` object from the requested `kind` : positions, indices, normals, etc.
     * Returns `undefined` if the mesh has no geometry.
     */
	public function getVertexBuffer(kind:String):VertexBuffer {
		if (this._geometry == null) {
			return null;
		}
		
		return this._geometry.getVertexBuffer(kind);
	}

	/**
	  * Returns a boolean depending on the existence of the Vertex Data for the requested `kind`.
	  */
	override public function isVerticesDataPresent(kind:String):Bool {
		if (this._geometry == null) {
			if (this._delayInfo != null) {
				return this._delayInfo.indexOf(kind) != -1;
			}
			
			return false;
		}
		
		return this._geometry.isVerticesDataPresent(kind);
	}
	
	/**
     * Returns a boolean defining if the vertex data for the requested `kind` is updatable.
	 */
	public function isVertexBufferUpdatable(kind:String):Bool {
        if (this._geometry == null) {
            if (this._delayInfo != null) {
                return this._delayInfo.indexOf(kind) != -1;
            }
            return false;
        }
        return this._geometry.isVertexBufferUpdatable(kind);
    }

	/**
	  * Returns a string : the list of existing `kinds` of Vertex Data for this mesh.
	  */
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

	/**
	  * Returns a positive integer : the total number of indices in this mesh geometry.
	  * Returns zero if the mesh has no geometry.
	  */
	public function getTotalIndices():Int {
		if (this._geometry == null) {
			return 0;
		}
		
		return this._geometry.getTotalIndices();
	}

	/**
     * Returns an array of integers or a Int32Array populated with the mesh indices.
     * If the parameter `copyWhenShared` is true (default false) and and if the mesh geometry 
	 * is shared among some other meshes, the returned array is a copy of the internal one.
     * Returns an empty array if the mesh has no geometry.
     */
	override public function getIndices(copyWhenShared:Bool = false):UInt32Array {
		if (this._geometry == null) {
			#if purejs 
			return untyped [];
			#else
			return new UInt32Array();
			#end
		}
		
		return this._geometry.getIndices(copyWhenShared);
	}

	override private function get_isBlocked():Bool {
		return this._masterMesh != null;
	}

	/**
	 * Determine if the current mesh is ready to be rendered
	 * @param completeCheck defines if a complete check (including materials and lights) has to be done (false by default)
	 * @param forceInstanceSupport will check if the mesh will be ready when used with instances (false by default)
	 * @returns true if all associated assets are ready (material, textures, shaders)
	 */
	override public function isReady(completeCheck:Bool = false, forceInstanceSupport:Bool = false):Bool {
		if (this.delayLoadState == Engine.DELAYLOADSTATE_LOADING) {
			return false;
		}
		
		if (!super.isReady(completeCheck)) {
			return false;
		}
		
		if (this.subMeshes == null || this.subMeshes.length == 0) {
			return true;
		}
		
		if (!completeCheck) {
            return true;
        }
		
		var engine = this.getEngine();
		var scene = this.getScene();
		var hardwareInstancedRendering = forceInstanceSupport || engine.getCaps().instancedArrays && this.instances.length > 0;
		
		this.computeWorldMatrix();
		
		var mat = this.material != null ? this.material : scene.defaultMaterial;
		if (mat != null) {			
			if (mat.storeEffectOnSubMeshes) {
				for (subMesh in this.subMeshes) {
					var effectiveMaterial = subMesh.getMaterial();
					if (effectiveMaterial != null) {
						if (!effectiveMaterial.isReadyForSubMesh(this, subMesh, hardwareInstancedRendering)) {
							return false;
						}
					}
				}
			} 
			else {
				if (!mat.isReady(this, hardwareInstancedRendering)) {
					return false;
				}
			}			
		}
		
		// Shadows
		for (light in this._lightSources) {
			var generator = light.getShadowGenerator();
			
			if (generator != null) {
				for (subMesh in this.subMeshes) {
					if (!generator.isReady(subMesh, hardwareInstancedRendering)) {
						return false;
					}
				}
			}
		}
		
		// LOD
		for (lod in this._LODLevels) {
			if (lod.mesh != null && !lod.mesh.isReady(hardwareInstancedRendering)) {
				return false;
			}
		}
		
		return true;
	}
	
	/**
	 * Boolean : true if the normals aren't to be recomputed on next mesh `positions` array update.
	 * This property is pertinent only for updatable parametric shapes.
	 */
	inline private function get_areNormalsFrozen():Bool {
		return this._areNormalsFrozen;
	}
	
	/**  
	 * This function affects parametric shapes on vertex position update only : ribbons, tubes, etc. 
	 * It has no effect at all on other shapes.
	 * It prevents the mesh normals from being recomputed on next `positions` array update.  
	 * Returns the Mesh.  
	 */
	inline public function freezeNormals() {
		this._areNormalsFrozen = true;
	}
	
	/**  
	 * This function affects parametric shapes on vertex position update only : ribbons, tubes, etc. 
	 * It has no effect at all on other shapes.
	 * It reactivates the mesh normals computation if it was previously frozen.  
	 * Returns the Mesh.  
	 */
	inline public function unfreezeNormals() {
		this._areNormalsFrozen = false;
	}
	
	/**
	 * Overrides instance count. Only applicable when custom instanced InterleavedVertexBuffer are used rather than InstancedMeshs
	 */
	public var overridenInstanceCount(never, set):Int;
	inline private function set_overridenInstanceCount(count:Int):Int {
		return this._overridenInstanceCount = count;
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
	
	override public function _preActivateForIntermediateRendering(renderId:Int) {
        if (this._visibleInstances != null) {
            this._visibleInstances.intermediateDefaultRenderId = renderId;
        }
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

	/**
	 * This method recomputes and sets a new BoundingInfo to the mesh unless it is locked.
	 * This means the mesh underlying bounding box and sphere are recomputed.
	 * Returns the Mesh.
	 */
	public function refreshBoundingInfo():Mesh {
		if (this._boundingInfo != null && this._boundingInfo.isLocked) {
			return this;
		}
		
		var data = this.getVerticesData(VertexBuffer.PositionKind);
		if (data != null) {
			var extend = MathTools.ExtractMinAndMax(data, 0, this.getTotalVertices());
			this._boundingInfo = new BoundingInfo(extend.minimum, extend.maximum);
		}
		
		if (this.subMeshes != null) {
			for (index in 0...this.subMeshes.length) {
				this.subMeshes[index].refreshBoundingInfo();
			}
		}
		
		this._updateBoundingInfo();
		return this;
	}

	private function _getPositionData(applySkeleton:Bool):Float32Array {
		var data = this.getVerticesData(VertexBuffer.PositionKind);
		
		if (data != null && applySkeleton && this.skeleton != null) {
			data = data.subarray(0, data.length);
			
			var matricesIndicesData = this.getVerticesData(VertexBuffer.MatricesIndicesKind);
			var matricesWeightsData = this.getVerticesData(VertexBuffer.MatricesWeightsKind);
			if (matricesWeightsData != null && matricesIndicesData != null) {
				var needExtras = this.numBoneInfluencers > 4;
				var matricesIndicesExtraData = needExtras ? this.getVerticesData(VertexBuffer.MatricesIndicesExtraKind) : null;
				var matricesWeightsExtraData = needExtras ? this.getVerticesData(VertexBuffer.MatricesWeightsExtraKind) : null;
				
				var skeletonMatrices = this.skeleton.getTransformMatrices(this);
				
				var tempVector:Vector3 = Tmp.vector3[0];
				var finalMatrix:Matrix = Tmp.matrix[0];
				var tempMatrix:Matrix = Tmp.matrix[1];
				
				var matWeightIdx:Int = 0;
				var index:Int = 0;
				while (index < data.length) {
					finalMatrix.reset();
					
					var weight:Float = 0;
					for (inf in 0...4) {
						weight = matricesWeightsData[matWeightIdx + inf];
						if (weight <= 0) {
							break;
						}
						Matrix.FromFloat32ArrayToRefScaled(skeletonMatrices, Std.int(matricesIndicesData[matWeightIdx + inf] * 16), weight, tempMatrix);
						finalMatrix.addToSelf(tempMatrix);
					}
					if (needExtras) {
						for (inf in 0...4) {
							weight = matricesWeightsExtraData[matWeightIdx + inf];
							if (weight <= 0) {
								break;
							}
							Matrix.FromFloat32ArrayToRefScaled(skeletonMatrices, Std.int(matricesIndicesExtraData[matWeightIdx + inf] * 16), weight, tempMatrix);
							finalMatrix.addToSelf(tempMatrix);
						}
					}
					
					Vector3.TransformCoordinatesFromFloatsToRef(data[index], data[index + 1], data[index + 2], finalMatrix, tempVector);
					tempVector.toFloat32Array(data, index);
					
					index += 3;
					matWeightIdx += 4;
				}
			}
		}
		
		return data;
	}

	public function _createGlobalSubMesh(force:Bool):SubMesh {
		var totalVertices = this.getTotalVertices();
		if (totalVertices == 0 || this.getIndices() == null) {
			return null;
		}
		
		// Check if we need to recreate the submeshes
		if (this.subMeshes != null && this.subMeshes.length > 0) {
			var ib = this.getIndices();
			
			if (ib == null) {
				return null;
			}
			
			var totalIndices = ib.length;
			var needToRecreate = false;
			
			if (force) {
				needToRecreate = true;
			} 
			else {
				for (submesh in this.subMeshes) {
					if (submesh.indexStart + submesh.indexCount >= totalIndices) {
						needToRecreate = true;
						break;
					}
					
					if (submesh.verticesStart + submesh.verticesCount >= totalVertices) {
						needToRecreate = true;
						break;
					}
				}
			}
			
			if (!needToRecreate) {
				return this.subMeshes[0];
			}
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

	/**
     * Sets the vertex data of the mesh geometry for the requested `kind`.
     * If the mesh has no geometry, a new `Geometry` object is set to the mesh and then passed this vertex data.
     * The `data` are either a numeric array either a Float32Array.
     * The parameter `updatable` is passed as is to the underlying `Geometry` object constructor (if initianilly none) or updater.
     * The parameter `stride` is an optional positive integer, it is usually automatically deducted from the `kind` (3 for positions or normals, 2 for UV, etc).
     * Note that a new underlying `VertexBuffer` object is created each call.
     * If the `kind` is the `PositionKind`, the mesh `BoundingInfo` is renewed, so the bounding box and sphere, and the mesh World Matrix is recomputed.
     */
	override public function setVerticesData(kind:String, data:Float32Array, updatable:Bool = false, ?stride:Int) {
		trace(kind);
		trace(data);
		if (this._geometry == null) {
			var vertexData = new VertexData();
			vertexData.set(data, kind);
			
			var scene = this.getScene();
			new Geometry(Tools.uuid(), scene, vertexData, updatable, this);
		}
		else {
			this._geometry.setVerticesData(kind, data, updatable, stride);
		}
	}
	
	public function markVerticesDataAsUpdatable(kind:String, updatable:Bool = true) {
		if (this.getVertexBuffer(kind).isUpdatable() == updatable) {
			return;
		}
		
		this.setVerticesData(kind, this.getVerticesData(kind), updatable);
	}
	
	public function setVerticesBuffer(buffer:VertexBuffer) {
		if (this._geometry == null) {
			this._geometry = Geometry.CreateGeometryForMesh(this);
		}
		
		this._geometry.setVerticesBuffer(buffer);
	}

	/**
     * Updates the existing vertex data of the mesh geometry for the requested `kind`.
     * If the mesh has no geometry, it is simply returned as it is.
     * The `data` are either a numeric array either a Float32Array.
     * No new underlying `VertexBuffer` object is created.
     * If the `kind` is the `PositionKind` and if `updateExtends` is true, the mesh `BoundingInfo` is renewed, so the bounding box and sphere, and the mesh World Matrix is recomputed.
     * If the parameter `makeItUnique` is true, a new global geometry is created from this positions and is set to the mesh.
     */
	override public function updateVerticesData(kind:String, data:Float32Array, updateExtends:Bool = false, makeItUnique:Bool = false) {
		if (this._geometry == null) {
			return;
		}
		
		if (!makeItUnique) {
			this._geometry.updateVerticesData(kind, data, updateExtends);
		} 
		else {
			this.makeGeometryUnique();
			this.updateVerticesData(kind, data, updateExtends, false);
		}
	}
	
	// Mesh positions update function :
	// updates the mesh positions according to the positionFunction returned values.
	// The positionFunction argument must be a javascript function accepting the mesh "positions" array as parameter.
	// This dedicated positionFunction computes new mesh positions according to the given mesh type.
	public function updateMeshPositions(positionFunction:Float32Array->Void, computeNormals:Bool = true):Mesh {
		var positions = this.getVerticesData(VertexBuffer.PositionKind);
		
		if (positions == null) {
			return this;
		}
		
		positionFunction(positions);
		this.updateVerticesData(VertexBuffer.PositionKind, positions, false, false);
		if (computeNormals) {
			var indices = this.getIndices();
			var normals = this.getVerticesData(VertexBuffer.NormalKind);
			
			if (normals == null) {
				return this;
			}
			
			VertexData.ComputeNormals(positions, indices, normals);
			this.updateVerticesData(VertexBuffer.NormalKind, normals, false, false);
		}
		
		return this;
	}
	
	/**
	 * This method will force the computation of normals for the mesh.
	 * Please note that the mesh must have normals vertex data already.
	 * Returns the Mesh. 
	 */
	public function recomputeNormals(markDataAsUpdatable:Bool = false):Mesh {
		var positions = this.getVerticesData(VertexBuffer.PositionKind);
		var indices = this.getIndices();
		var normals:Float32Array = null;
		
		if (this.isVerticesDataPresent(VertexBuffer.NormalKind)) {
			normals = this.getVerticesData(VertexBuffer.NormalKind);
		} 
		else {
			#if purejs
			normals = new Float32Array([]);
			#else
			normals = new Float32Array();
			#end
		}
		VertexData.ComputeNormals(positions, indices, normals);
		this.setVerticesData(VertexBuffer.NormalKind, normals, markDataAsUpdatable);
		
		return this;
	}

	/**
	 * Creates a un-shared specific occurence of the geometry for the mesh.  
	 * Returns the Mesh.  
	 */
	public function makeGeometryUnique() {
		if (this._geometry == null) {
			return;
		}
		
		var oldGeometry = this._geometry;
		var geometry = this._geometry.copy(Tools.uuid());
		oldGeometry.releaseForMesh(this, true);
		geometry.applyToMesh(this);
	}

	override public function setIndices(indices:UInt32Array, totalVertices:Int = -1, updatable:Bool = false) {
		if (this._geometry == null) {
			var vertexData = new VertexData();
			vertexData.indices = indices;
			
			var scene = this.getScene();
			
			new Geometry(Tools.uuid(), scene, vertexData, updatable, this);
		} 
		else {
			this._geometry.setIndices(indices, totalVertices, updatable);
		}
	}
	
	/**
     * Update the current index buffer
     * Expects a typed array (Int32Array)
     * Returns the Mesh. 
     */
    override public function updateIndices(indices:UInt32Array, offset:Int = 0):AbstractMesh {
        if (this._geometry == null) {
            return this;
        }
		
        this._geometry.updateIndices(indices, offset);
        return this;
    }
	
	/**
	 * Invert the geometry to move from a right handed system to a left handed one.  
	 * Returns the Mesh.  
	 */
	public function toLeftHanded() {
		if (this._geometry == null) {
			return;
		}
		this._geometry.toLeftHanded();
	}

	public function _bind(subMesh:SubMesh, effect:Effect, fillMode:Int) {
		if (this._geometry == null) {
			return;
		}
		
		var engine:Engine = this.getScene().getEngine();
		
		// Wireframe
		var indexBufferToBind:WebGLBuffer = null;
		
		if (this._unIndexed) {
            indexBufferToBind = null;
		} 
		else {
			switch (fillMode) {
				case Material.PointFillMode:
					indexBufferToBind = null;
					
				case Material.WireFrameFillMode:
					indexBufferToBind = subMesh.getLinesIndexBuffer(this.getIndices(), engine);
					
				case Material.TriangleFillMode:
					indexBufferToBind = this._unIndexed ? null : this._geometry.getIndexBuffer();
					
				default:
					indexBufferToBind = this._unIndexed ? null : this._geometry.getIndexBuffer();
			}
		}
		
		// VBOs
		this._geometry._bind(effect, indexBufferToBind);
	}

	public function _draw(subMesh:SubMesh, fillMode:Int, instancesCount:Int = 0, alternate:Bool = false) {	
		if (this._geometry == null || this._geometry.getVertexBuffers() == null || this._geometry.getIndexBuffer() == null) {
			return;
		}
		
		this.onBeforeDrawObservable.notifyObservers(this);
		
		var scene:Scene = this.getScene();
		var engine:Engine = scene.getEngine();
		
		// Draw order
		if (this._unIndexed || fillMode == Material.PointFillMode) {
            // or triangles as points
            engine.drawArraysType(fillMode, subMesh.verticesStart, subMesh.verticesCount, instancesCount);
        } 
		else if (fillMode == Material.WireFrameFillMode) {
            // Triangles as wireframe
            engine.drawElementsType(fillMode, 0, subMesh.linesIndexCount, instancesCount);
        } 
		else {
            engine.drawElementsType(fillMode, subMesh.indexStart, subMesh.indexCount, instancesCount);
        }
		
		if (scene._isAlternateRenderingEnabled && !alternate) {
			var effect = subMesh.effect != null ? subMesh.effect : this._effectiveMaterial.getEffect();
			if (effect == null || scene.activeCamera == null) {
				return;
			}
			scene._switchToAlternateCameraConfiguration(true);
			this._effectiveMaterial.bindView(effect);
			this._effectiveMaterial.bindViewProjection(effect);
			
			engine.setViewport(scene.activeCamera._alternateCamera.viewport);
			this._draw(subMesh, fillMode, instancesCount, true);
			engine.setViewport(scene.activeCamera.viewport);
			
			scene._switchToAlternateCameraConfiguration(false);
			this._effectiveMaterial.bindView(effect);
			this._effectiveMaterial.bindViewProjection(effect);
		}
	}

	/**
	 * Registers for this mesh a function called just before the rendering process.
	 * This function is passed the current mesh.  
	 * Return the Mesh.  
	 */
	public function registerBeforeRender(func:AbstractMesh->Null<EventState>->Void) {
		this.onBeforeRenderObservable.add(func);
	}

	/**
	 * Disposes a previously registered javascript function called before the rendering.
	 * This function is passed the current mesh.  
	 * Returns the Mesh.  
	 */
	public function unregisterBeforeRender(func:AbstractMesh->Null<EventState>->Void) {
		this.onBeforeRenderObservable.removeCallback(func);
	}

	/**
	 * Registers for this mesh a javascript function called just after the rendering is complete.
	 * This function is passed the current mesh.  
	 * Returns the Mesh.  
	 */
	public function registerAfterRender(func:AbstractMesh->Null<EventState>->Void) {
		this.onAfterRenderObservable.add(func);
	}

	/**
	 * Disposes a previously registered javascript function called after the rendering.
	 * This function is passed the current mesh.  
	 * Return the Mesh.  
	 */
	public function unregisterAfterRender(func:AbstractMesh->Null<EventState>->Void) {
		this.onAfterRenderObservable.removeCallback(func);
	}

	public function _getInstancesRenderList(subMeshId:Int):_InstancesBatch {
		var scene = this.getScene();
		this._batchCache.mustReturn = false;
		this._batchCache.renderSelf[subMeshId] = this.isEnabled() && this.isVisible;
		this._batchCache.visibleInstances[subMeshId] = null;
		
		if (this._visibleInstances != null) {
			var currentRenderId:Int = scene.getRenderId();
			var defaultRenderId = (scene._isInIntermediateRendering() ? this._visibleInstances.intermediateDefaultRenderId : this._visibleInstances.defaultRenderId);
			this._batchCache.visibleInstances[subMeshId] = this._visibleInstances.map[currentRenderId];
			var selfRenderId:Int = this._renderId;
			
			if (this._batchCache.visibleInstances[subMeshId] == null && defaultRenderId > 0) {
                this._batchCache.visibleInstances[subMeshId] = this._visibleInstances.map[defaultRenderId];
                currentRenderId = cast Math.max(defaultRenderId, currentRenderId);
				selfRenderId = cast Math.max(this._visibleInstances.selfDefaultRenderId, currentRenderId);
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
		
		if (visibleInstances == null) {
			return;
		}
		
		var matricesCount = visibleInstances.length + 1;
		var bufferSize = Std.int(matricesCount * 16 * 4);
		
		var currentInstancesBufferSize = this._instancesBufferSize;
		var instancesBuffer = this._instancesBuffer;
		
		while (this._instancesBufferSize < bufferSize) {
			this._instancesBufferSize *= 2;
		}
		
		if (this._instancesData == null || currentInstancesBufferSize != this._instancesBufferSize) {
			this._instancesData = new Float32Array(Std.int(this._instancesBufferSize / 4));
		}
		
		var offset:Int = 0;
		var instancesCount:Int = 0;
		
		var world:Matrix = this.getWorldMatrix();
		if (batch.renderSelf[subMesh._id]) {
			world.copyToFloat32Array(this._instancesData, offset);
			offset += 16;
			instancesCount++;
		}
		
		if (visibleInstances != null) {
			for (instanceIndex in 0...visibleInstances.length) {
				var instance = visibleInstances[instanceIndex];
				instance.getWorldMatrix().copyToFloat32Array(this._instancesData, offset);
				offset += 16;
				instancesCount++;
			}
		}
		
		if (instancesBuffer == null || currentInstancesBufferSize != this._instancesBufferSize) {
			if (instancesBuffer != null) {
				instancesBuffer.dispose();
			}
			
			instancesBuffer = new Buffer(engine, this._instancesData, true, 16, false, true);
			this._instancesBuffer = instancesBuffer;
			
			this.setVerticesBuffer(instancesBuffer.createVertexBuffer("world0", 0, 4));
			this.setVerticesBuffer(instancesBuffer.createVertexBuffer("world1", 4, 4));
			this.setVerticesBuffer(instancesBuffer.createVertexBuffer("world2", 8, 4));
			this.setVerticesBuffer(instancesBuffer.createVertexBuffer("world3", 12, 4));
		} 
		else {
			instancesBuffer.updateDirectly(this._instancesData, 0, instancesCount);
		}
		
		this._bind(subMesh, effect, fillMode);		
		this._draw(subMesh, fillMode, instancesCount);
		
		engine.unbindInstanceAttributes();
	}
	
	public function _processRendering(subMesh:SubMesh, effect:Effect, fillMode:Int, batch:_InstancesBatch, hardwareInstancedRendering:Bool, onBeforeDraw:Bool->Matrix->Null<Material>->Void, ?effectiveMaterial:Material) {
		var scene = this.getScene();
		var engine = scene.getEngine();
		
		if (hardwareInstancedRendering) {
			this._renderWithInstances(subMesh, fillMode, batch, effect, engine);
		} 
		else {
			if (batch.renderSelf[subMesh._id]) {
				// Draw
				if (onBeforeDraw != null) {
					onBeforeDraw(false, this.getWorldMatrix(), effectiveMaterial);
				}
				
				this._draw(subMesh, fillMode, this._overridenInstanceCount);
			}
			
			var visibleInstancesForSubMesh = batch.visibleInstances[subMesh._id];
			
			if (visibleInstancesForSubMesh != null) {
				for (instanceIndex in 0...visibleInstancesForSubMesh.length) {
					var instance = batch.visibleInstances[subMesh._id][instanceIndex];
					
					// World
					var world = instance.getWorldMatrix();
					if (onBeforeDraw != null) {
						onBeforeDraw(true, world, effectiveMaterial);
					}
					
					// Draw
					this._draw(subMesh, fillMode);
				}
			}
		}
	}

	/**
     * Triggers the draw call for the mesh.
     * Usually, you don't need to call this method by yourself because the mesh rendering is handled by the scene rendering manager. 
     */
	public function render(subMesh:SubMesh, enableAlphaMode:Bool) {
		this.checkOcclusionQuery();
        if (this._isOccluded) {
            return;
        }
		
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
		
		this.onBeforeRenderObservable.notifyObservers(this);
		
		var engine = scene.getEngine();
		var hardwareInstancedRendering = (engine.getCaps().instancedArrays) && (batch.visibleInstances[subMesh._id] != null) && (batch.visibleInstances.length > subMesh._id && batch.visibleInstances[subMesh._id] != null);
		
		// Material
		var material = subMesh.getMaterial();
		
		if (material == null) {
			return;
		}
		
		this._effectiveMaterial = material;
		
		if (this._effectiveMaterial.storeEffectOnSubMeshes) {
			if (!this._effectiveMaterial.isReadyForSubMesh(this, subMesh, hardwareInstancedRendering)) {
				return;
			}
		} 
		else if (!this._effectiveMaterial.isReady(this, hardwareInstancedRendering)) {
			return;
		}
		
		// Alpha mode
		if (enableAlphaMode) {
			engine.setAlphaMode(this._effectiveMaterial.alphaMode);
		}
		
		// Outline - step 1
		var savedDepthWrite = engine.getDepthWrite();
		if (this.renderOutline) {
			engine.setDepthWrite(false);
			scene.getOutlineRenderer().render(subMesh, batch);
			engine.setDepthWrite(savedDepthWrite);
		}
		
		var effect:Effect;
		if (this._effectiveMaterial.storeEffectOnSubMeshes) {
			effect = subMesh.effect;
		} 
		else {
			effect = this._effectiveMaterial.getEffect();
		}
		
		if (effect == null) {
			return;
		}
		
		var sideOrientation = this.overrideMaterialSideOrientation;
        if (sideOrientation == -1) {
            sideOrientation = this._effectiveMaterial.sideOrientation;
            if (this._getWorldMatrixDeterminant() < 0) {
                sideOrientation = (sideOrientation == Material.ClockWiseSideOrientation ? Material.CounterClockWiseSideOrientation : Material.ClockWiseSideOrientation);
            }
        }
		
        var reverse = this._effectiveMaterial._preBind(effect, sideOrientation);
		
		if (this._effectiveMaterial.forceDepthWrite) {
            engine.setDepthWrite(true);
        }
		
		// Bind
		var fillMode = scene.forcePointsCloud ? Material.PointFillMode : (scene.forceWireframe ? Material.WireFrameFillMode : this._effectiveMaterial.fillMode);
		
		if (!hardwareInstancedRendering) { // Binding will be done later because we need to add more info to the VB
            this._bind(subMesh, effect, fillMode);
        }
		
		var world = this.getWorldMatrix();
		
		if (this._effectiveMaterial.storeEffectOnSubMeshes) {
			this._effectiveMaterial.bindForSubMesh(world, this, subMesh);
		} 
		else {
			this._effectiveMaterial.bind(world, this);
		}
		
		if (!this._effectiveMaterial.backFaceCulling && this._effectiveMaterial.separateCullingPass) {
            engine.setState(true, this._effectiveMaterial.zOffset, false, !reverse);
            this._processRendering(subMesh, effect, fillMode, batch, hardwareInstancedRendering, this._onBeforeDraw, this._effectiveMaterial);
            engine.setState(true, this._effectiveMaterial.zOffset, false, reverse);
        }
		
		// Draw
		this._processRendering(subMesh, effect, fillMode, batch, hardwareInstancedRendering, this._onBeforeDraw, this._effectiveMaterial);
		
		// Unbind
		this._effectiveMaterial.unbind();
		
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
		
		this.onAfterRenderObservable.notifyObservers(this);
	}
	
	inline private function _onBeforeDraw(isInstance:Bool, world:Matrix, effectiveMaterial:Material) {
        if (isInstance && effectiveMaterial != null) {
			if (effectiveMaterial != null) {
				effectiveMaterial.bindOnlyWorldMatrix(world);
			}            
        }
    }

	inline public function getEmittedParticleSystems():Array<IParticleSystem> {
		var results = new Array<IParticleSystem>();
		for (index in 0...this.getScene().particleSystems.length) {
			var particleSystem = this.getScene().particleSystems[index];
			if (particleSystem.emitter == this) {
				results.push(particleSystem);
			}
		}
		
		return results;
	}

	/**
	 * Returns an array populated with ParticleSystem objects whose this mesh or its children are the emitter.
	 */
	inline public function getHierarchyEmittedParticleSystems():Array<IParticleSystem> {
		var results = new Array<IParticleSystem>();
		var descendants = this.getDescendants();
		descendants.push(this);
		
		for (index in 0...this.getScene().particleSystems.length) {
			var particleSystem = this.getScene().particleSystems[index];
			var emitter = particleSystem.emitter;
			
			if (Std.is(emitter, Node) && emitter.position != null && descendants.indexOf(cast emitter) != -1) {
				results.push(particleSystem);
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
			
			this._queueLoad(this, scene);
		}
	}
	
	private function _queueLoad(mesh:Mesh, scene:Scene) {
		/*scene._addPendingData(mesh);
		
		var getBinaryData = (this.delayLoadingFile.indexOf(".babylonbinarymeshdata") != -1);
		
		Tools.LoadFile(this.delayLoadingFile, function(data) {
			
			if (Std.is(data, ArrayBuffer)) {
				this._delayLoadingFunction(data, this);
			}
			else {
				this._delayLoadingFunction(Json.parse(data), this);
			}
			
			for (instance in this.instances) {
				instance._syncSubMeshes();
			}
			
			this.delayLoadState = Engine.DELAYLOADSTATE_LOADED;
			scene._removePendingData(this);
			
		}, function() { }, scene.database, getBinaryData);*/
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

	/**
     * Sets the mesh material by the material or multiMaterial `id` property.
     * The material `id` is a string identifying the material or the multiMaterial.
     * This method returns nothing.
     */
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

	/**
     * Returns as a new array populated with the mesh material and/or skeleton, if any.
     */
	inline public function getAnimatables():Array<IAnimatable> {
		var results:Array<IAnimatable> = [];
		
		if (this.material != null) {
			results.push(cast this.material);
		}
		
		if (this.skeleton != null) {
			results.push(cast this.skeleton);
		}
		
		return results;
	}

	/**
     * Modifies the mesh geometry according to the passed transformation matrix.
     * This method modifies the mesh even if it's originally not set as updatable.
     * The mesh normals are modified accordingly the same transformation.
     * tutorial : http://doc.babylonjs.com/tutorials/How_Rotations_and_Translations_Work#baking-transform
     * Note that, under the hood, this method sets a new VertexBuffer each call.
     */
	public function bakeTransformIntoVertices(transform:Matrix) {
		// Position
		if (!this.isVerticesDataPresent(VertexBuffer.PositionKind)) {
			return;
		}
		
		var submeshes = this.subMeshes.splice(0, this.subMeshes.length);
		
		this._resetPointsArrayCache();
		
		var data:Float32Array = this.getVerticesData(VertexBuffer.PositionKind);
		var temp:Array<Float> = [];
		var index:Int = 0;
		while(index < data.length) {
			Vector3.TransformCoordinates(Vector3.FromFloat32Array(data, index), transform).toArray(temp, index);
			index += 3;
		}
		
		this.setVerticesData(VertexBuffer.PositionKind, new Float32Array(temp), this.getVertexBuffer(VertexBuffer.PositionKind).isUpdatable());
		
		// Normals
		if (!this.isVerticesDataPresent(VertexBuffer.NormalKind)) {
			return;
		}		
		data = this.getVerticesData(VertexBuffer.NormalKind);
		temp = [];
		index = 0;
		while(index < data.length) {
			Vector3.TransformNormal(Vector3.FromFloat32Array(data, index), transform).normalize().toArray(temp, index);
			index += 3;
		}		
		this.setVerticesData(VertexBuffer.NormalKind, new Float32Array(temp), this.getVertexBuffer(VertexBuffer.NormalKind).isUpdatable());
		
		// flip faces?
        if (transform.m[0] * transform.m[5] * transform.m[10] < 0) { 
			this.flipFaces(); 
		}
		
		// Restore submeshes
        this.releaseSubMeshes();
        this.subMeshes = submeshes;
	}
	
	/**
     * Modifies the mesh geometry according to its own current World Matrix.
     * The mesh World Matrix is then reset.
     * This method returns nothing but really modifies the mesh even if it's originally not set as updatable.
     * tutorial : http://doc.babylonjs.com/tutorials/How_Rotations_and_Translations_Work#baking-transform
     * Note that, under the hood, this method sets a new VertexBuffer each call.
     */
    public function bakeCurrentTransformIntoVertices() {
        this.bakeTransformIntoVertices(this.computeWorldMatrix(true));
        this.scaling.copyFromFloats(1, 1, 1);
        this.position.copyFromFloats(0, 0, 0);
        this.rotation.copyFromFloats(0, 0, 0);
        //only if quaternion is already set
        if(this.rotationQuaternion != null) {
            this.rotationQuaternion = Quaternion.Identity();
        }
        this._worldMatrix = Matrix.Identity();
    }

	// Cache
	//public var _positions(get, never):Array<Vector3>;
	override private function get__positions():Array<Vector3> {
		if (this._geometry != null) {
			return this._geometry._positions;
		}
		return null;
	}
	
	inline public function _resetPointsArrayCache() {
		if (this._geometry != null) {
			this._geometry._resetPointsArrayCache();
		}
	}

	override public function _generatePointsArray():Bool {
		if (this._geometry != null) {
			return this._geometry._generatePointsArray();
		}
		return false;
	}

	/**
     * Returns a new `Mesh` object generated from the current mesh properties.
     * This method must not get confused with createInstance().
     * The parameter `name` is a string, the name given to the new mesh.
     * The optional parameter `newParent` can be any `Node` object (default `null`).
     * The optional parameter `doNotCloneChildren` (default `false`) allows/denies the recursive cloning 
	 * of the original mesh children if any.
     * The parameter `clonePhysicsImpostor` (default `true`)  allows/denies the cloning in the same time 
	 * of the original mesh `body` used by the physics engine, if any.
     */
	override public function clone(name:String, newParent:Node = null, doNotCloneChildren:Bool = false):Mesh {
		return new Mesh(name, this.getScene(), newParent, this, doNotCloneChildren);
	}

	/**
     * Disposes the mesh.
     * By default, all the mesh children are also disposed unless the parameter `doNotRecurse` is set to `true`.
     */
	override public function dispose(doNotRecurse:Bool = false) {
		this.morphTargetManager = null;
		
		if (this._geometry != null) {
			this._geometry.releaseForMesh(this, true);
		}
		
		// Sources
		var meshes = this.getScene().meshes;
		for (mesh in meshes) {
			if (mesh.getClassName() == 'Mesh' && untyped mesh._source != null && mesh._source == this) {
				untyped mesh._source = null;
			}
		}
		this._source = null;
		
		// Instances
		if (this._instancesBuffer != null) {
			this._instancesBuffer.dispose();
			this._instancesBuffer = null;
		}
		
		while (this.instances.length > 0) {
			this.instances[0].dispose();
			this.instances.shift();
		}
		
		// Effect layers
        var effectLayers = this.getScene().effectLayers;
        for (i in 0...effectLayers.length) {
            var effectLayer = effectLayers[i];
            if (effectLayer != null) {
                effectLayer._disposeMesh(this);
            }
        }		
		super.dispose(doNotRecurse);
	}

	/**
     * Modifies the mesh geometry according to a displacement map.
     * A displacement map is a colored image. Each pixel color value (actually a gradient computed from 
	 * red, green, blue values) will give the displacement to apply to each mesh vertex.
     * The mesh must be set as updatable. Its internal geometry is directly modified, no new buffer are allocated.
     * This method returns nothing.
     * The parameter `url` is a string, the URL from the image file is to be downloaded.
     * The parameters `minHeight` and `maxHeight` are the lower and upper limits of the displacement.
     * The parameter `onSuccess` is an optional Javascript function to be called just after the mesh is modified. 
	 * It is passed the modified mesh and must return nothing.
     */
	public function applyDisplacementMap(url:String, minHeight:Float, maxHeight:Float, ?onSuccess:Mesh->Void, invert:Bool = false) {
		var scene = this.getScene();
		
		var onload = function(img:Image) {						
			this.applyDisplacementMapFromBuffer(img.data, img.width, img.height, minHeight, maxHeight, invert);
			
			if (onSuccess != null) {
				onSuccess(this);
			}
		};
		
		Tools.LoadImage(url, onload);
	}

	/**
     * Modifies the mesh geometry according to a displacementMap buffer.
     * A displacement map is a colored image. Each pixel color value (actually a gradient computed from 
	 * red, green, blue values) will give the displacement to apply to each mesh vertex.
     * The mesh must be set as updatable. Its internal geometry is directly modified, no new buffer are allocated.
     * The parameter `buffer` is a `Uint8Array` buffer containing series of `Uint8` lower than 255, the red, 
	 * green, blue and alpha values of each successive pixel.
     * The parameters `heightMapWidth` and `heightMapHeight` are positive integers to set the width and height 
	 * of the buffer image.
     * The parameters `minHeight` and `maxHeight` are the lower and upper limits of the displacement.
     */
	public function applyDisplacementMapFromBuffer(buffer:UInt8Array, heightMapWidth:Float, heightMapHeight:Float, minHeight:Float, maxHeight:Float, invert:Bool = false) {
		if (!this.isVerticesDataPresent(VertexBuffer.PositionKind)
			|| !this.isVerticesDataPresent(VertexBuffer.NormalKind)
			|| !this.isVerticesDataPresent(VertexBuffer.UVKind)) {
			Tools.Warn("Cannot call applyDisplacementMap:Given mesh is not complete. Position, Normal or UV are missing or not updatable!");
			return;
		}
		
		var positions = this.getVerticesData(VertexBuffer.PositionKind);
		var normals = this.getVerticesData(VertexBuffer.NormalKind);
		var uvs = this.getVerticesData(VertexBuffer.UVKind);
		var position = Vector3.Zero();
		var normal = Vector3.Zero();
		var uv = Vector2.Zero();
		
		var index:Int = 0;
		while (index < positions.length) {
			Vector3.FromFloat32ArrayToRef(positions, index, position);
			Vector3.FromFloat32ArrayToRef(normals, index, normal);
			Vector2.FromFloat32ArrayToRef(uvs, Std.int((index / 3) * 2), uv);
			
			// Compute height
			var u = Std.int((Math.abs(uv.x) * heightMapWidth) % heightMapWidth);
			var v = Std.int((Math.abs(uv.y) * heightMapHeight) % heightMapHeight);
			
			var pos = Std.int((u + v * heightMapWidth) * 4);
			#if (!js && !purejs)
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
			if(invert) {
				normal.scaleInPlace(-1);
			}
			position = position.add(normal);
			
			position.toFloat32Array(positions, index);
			
			index += 3;
		}
		
		VertexData.ComputeNormals(positions, this.getIndices(), normals);
		
		this.updateVerticesData(VertexBuffer.PositionKind, positions);
		this.updateVerticesData(VertexBuffer.NormalKind, normals);
	}
	
	/**
     * Modify the mesh to get a flat shading rendering.
     * This means each mesh facet will then have its own normals. 
	 * Usually new vertices are added in the mesh geometry to get this result.
     * Warning : the mesh is really modified even if not set originally as updatable and, 
	 * under the hood, a new VertexBuffer is allocated.
     */
	public function convertToFlatShadedMesh() {
		// Update normals and vertices to get a flat shading rendering.
		// Warning:This may imply adding vertices to the mesh in order to get exactly 3 vertices per face
		
		var kinds = this.getVerticesDataKinds();
		var vbs:Map<String, VertexBuffer> = new Map<String, VertexBuffer>();
		var data:Map<String, Float32Array> = new Map<String, Float32Array>();
		var newdata:Map<String, Array<Float>> = new Map<String, Array<Float>>();
		var updatableNormals = false;		
		var kindIndex:Int = 0;
		var kind:String;
		while (kindIndex < kinds.length) {
			kind = kinds[kindIndex];
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
		var positions:Array<Float> = newdata[VertexBuffer.PositionKind];
		var index:Int = 0;
		while (index < totalIndices) {
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
		this.setVerticesData(VertexBuffer.NormalKind, new Float32Array(normals), updatableNormals);
		
		// Updating vertex buffers
		for (kindIndex in 0...kinds.length) {
			var kind = kinds[kindIndex];
			this.setVerticesData(kind, new Float32Array(newdata[kind]), vbs[kind].isUpdatable());
		}
		
		// Updating submeshes
		this.releaseSubMeshes();
		for (submeshIndex in 0...previousSubmeshes.length) {
			var previousOne = previousSubmeshes[submeshIndex];
			var subMesh = new SubMesh(previousOne.materialIndex, previousOne.indexStart, previousOne.indexCount, previousOne.indexStart, previousOne.indexCount, this);
		}
		
		this.synchronizeInstances();
	}
	
	/**
     * This method removes all the mesh indices and add new vertices (duplication) in order to unfold facets into buffers.
     * In other words, more vertices, no more indices and a single bigger VBO.
     * The mesh is really modified even if not set originally as updatable. Under the hood, a new VertexBuffer is allocated.
     */
	public function convertToUnIndexedMesh() {
		// Remove indices by unfolding faces into buffers 
		// Warning: This implies adding vertices to the mesh in order to get exactly 3 vertices per face 
		var kinds:Array<String> = this.getVerticesDataKinds();
		var vbs:Map<String, VertexBuffer> = new Map();
		var data:Map<String, Float32Array> = new Map();
		var newdata:Map<String, Float32Array> = new Map();
		var updatableNormals:Bool = false;		
		var kind:String = "";
		
		for (kindIndex in 0...kinds.length) {
			kind = kinds[kindIndex];
			var vertexBuffer:VertexBuffer = this.getVertexBuffer(kind);
			vbs[kind] = vertexBuffer;
			data[kind] = vbs[kind].getData();
			//newdata[kind] = [];
		}
		
		// Save previous submeshes
		var previousSubmeshes:Array<SubMesh> = this.subMeshes.slice(0);
		
		var indices:UInt32Array = this.getIndices();
		var totalIndices:Int = this.getTotalIndices();
		
		// Generating unique vertices per face
		for (index in 0...totalIndices) {
			var vertexIndex = indices[index];
			
			for (kindIndex in 0...kinds.length) {
				kind = kinds[kindIndex];
				var stride = vbs[kind].getStrideSize();
				newdata[kind] = new Float32Array(stride);
				for (offset in 0...stride) {
					newdata[kind][offset] = data[kind][vertexIndex * stride + offset];
				}
			}
		}
		
		// Updating indices
		var index:Int = 0;
		while (index < totalIndices) {
			indices[index] = index;
			indices[index + 1] = index + 1;
			indices[index + 2] = index + 2;
			
			index += 3;
		}
		
		this.setIndices(indices);
		
		// Updating vertex buffers
		for (kindIndex in 0...kinds.length) {
			kind = kinds[kindIndex];
			this.setVerticesData(kind, newdata[kind], vbs[kind].isUpdatable());
		}
		
		// Updating submeshes
		this.releaseSubMeshes();
		for (submeshIndex in 0...previousSubmeshes.length) {
			var previousOne = previousSubmeshes[submeshIndex];
			var subMesh = new SubMesh(previousOne.materialIndex, previousOne.indexStart, previousOne.indexCount, previousOne.indexStart, previousOne.indexCount, this);
		}
		
		this._unIndexed = true;
		
		this.synchronizeInstances();
	}
	
	/**
     * Inverses facet orientations and inverts also the normals with `flipNormals` (default `false`) if true.
     * Warning : the mesh is really modified even if not set originally as updatable. 
	 * A new VertexBuffer is created under the hood each call.
	 */
	public function flipFaces(flipNormals:Bool = false):Mesh {
		var vertex_data = VertexData.ExtractFromMesh(this);
		
		if (flipNormals && this.isVerticesDataPresent(VertexBuffer.NormalKind) && vertex_data.normals != null) {
			for (i in 0...vertex_data.normals.length) {
				vertex_data.normals[i] *= -1;
			}
		}
		
		if (vertex_data.indices != null) {
			var temp:Int = 0;
			var i:Int = 0;
			while (i < vertex_data.indices.length) {
				// reassign indices
				temp = vertex_data.indices[i + 1];
				vertex_data.indices[i + 1] = vertex_data.indices[i + 2];
				vertex_data.indices[i + 2] = temp;
				
				i += 3;
			}
		}
		
		vertex_data.applyToMesh(this);
		return this;
	}

	// Instances
	
	/**
     * Creates a new `InstancedMesh` object from the mesh model.
     * An instance shares the same properties and the same material than its model.
     * Only these properties of each instance can then be set individually :
     * - position
     * - rotation
     * - rotationQuaternion
     * - setPivotMatrix
     * - scaling
     * tutorial : http://doc.babylonjs.com/tutorials/How_to_use_Instances
	 * Warning : this method is not supported for `Line` mesh and `LineSystem`
     */
	public function createInstance(name:String):InstancedMesh {
		return new InstancedMesh(name, this);
	}

	/**
     * Synchronises all the mesh instance submeshes to the current mesh submeshes, if any.
     * After this call, all the mesh instances have the same submeshes than the current mesh.
     */
	inline public function synchronizeInstances():Mesh {
		for (instanceIndex in 0...this.instances.length) {
			var instance = this.instances[instanceIndex];
			instance._syncSubMeshes();
		}
		return this;
	}
	
	/**
	 * Simplify the mesh according to the given array of settings.
	 * Function will return immediately and will simplify async.
	 * @param settings a collection of simplification settings.
	 * @param parallelProcessing should all levels calculate parallel or one after the other.
	 * @param type the type of simplification to run.
	 * @param successCallback optional success callback to be called after the simplification finished processing all settings.
	 */
	public function simplify(settings:Array<ISimplificationSettings>, parallelProcessing:Bool = true, simplificationType:Int = SimplificationSettings.QUADRATIC, ?successCallback:Void->Void):Mesh {
		this.getScene().simplificationQueue.addTask(new SimplificationTask(settings, simplificationType, this, successCallback, parallelProcessing)); 
		return this;
	}
	
	/**
	 * Optimization of the mesh's indices, in case a mesh has duplicated vertices.
	 * The function will only reorder the indices and will not remove unused vertices to avoid problems with submeshes.
	 * This should be used together with the simplification to avoid disappearing triangles.
	 * @param successCallback an optional success callback to be called after the optimization finished.
	 */
	public function optimizeIndices(?successCallback:Mesh->Void):Mesh {
		var indices = this.getIndices();
		var positions = this.getVerticesData(VertexBuffer.PositionKind);
		
		if (positions == null || indices == null) {
			return this;
		}
		
		var vectorPositions:Array<Vector3> = [];
		var pos:Int = 0;
		while(pos < positions.length) {
			vectorPositions.push(Vector3.FromFloat32Array(positions, pos));
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
		return this;
	}
	
	override public function serialize(?serializationObject:Dynamic):Dynamic {
		serializationObject = super.serialize(serializationObject);
		
		serializationObject.name = this.name;
		serializationObject.id = this.id;
		serializationObject.type = this.getClassName();
		
		if (Tags.HasTags(this)) {
			serializationObject.tags = Tags.GetTags(this);
		}
		
		serializationObject.position = this.position.asArray();
		
		if (this.rotationQuaternion != null) {
			serializationObject.rotationQuaternion = this.rotationQuaternion.asArray();
		} 
		else if (this.rotation != null) {
			serializationObject.rotation = this.rotation.asArray();
		}
		
		serializationObject.scaling = this.scaling.asArray();
		serializationObject.localMatrix = this.getPivotMatrix().asArray();
		
		serializationObject.isEnabled = this.isEnabled(false);
		serializationObject.isVisible = this.isVisible;
		serializationObject.infiniteDistance = this.infiniteDistance;
		serializationObject.pickable = this.isPickable;
		
		serializationObject.receiveShadows = this.receiveShadows;
		
		serializationObject.billboardMode = this.billboardMode;
		serializationObject.visibility = this.visibility;
		
		serializationObject.checkCollisions = this.checkCollisions;
		serializationObject.isBlocker = this.isBlocker;
		
		// Parent
		if (this.parent != null) {
			serializationObject.parentId = this.parent.id;
		}
		
		// Geometry
		serializationObject.isUnIndexed = this.isUnIndexed;
		var geometry = this._geometry;
		if (geometry != null) {
			var geometryId = geometry.id;
			serializationObject.geometryId = geometryId;
			
			// SubMeshes
			serializationObject.subMeshes = [];
			for (subIndex in 0...this.subMeshes.length) {
				var subMesh = this.subMeshes[subIndex];
				
				serializationObject.subMeshes.push({
					materialIndex: subMesh.materialIndex,
					verticesStart: subMesh.verticesStart,
					verticesCount: subMesh.verticesCount,
					indexStart: subMesh.indexStart,
					indexCount: subMesh.indexCount
				});
			}
		}
		
		// Material
		if (this.material != null) {
			serializationObject.materialId = this.material.id;
		} 
		else {
			this.material = null;
		}
		
		// Morph targets
		if (this.morphTargetManager != null) {
			serializationObject.morphTargetManagerId = this.morphTargetManager.uniqueId;
		}
		
		// Skeleton
		if (this.skeleton != null) {
			serializationObject.skeletonId = this.skeleton.id;
		}
		
		// Physics
		//TODO implement correct serialization for physics impostors.
		/*if (this.getPhysicsImpostor() != null) {
			var impostor = this.getPhysicsImpostor();
			serializationObject.physicsMass = impostor.getParam("mass");
			serializationObject.physicsFriction = impostor.getParam("friction");
			serializationObject.physicsRestitution = impostor.getParam("mass");
			serializationObject.physicsImpostor = this.getPhysicsImpostor().type;
		}*/
		
		// Metadata
		if (this.metadata != null) {
			serializationObject.metadata = this.metadata;
		}
		
		// Instances
		serializationObject.instances = [];
		for (index in 0...this.instances.length) {
			var instance = this.instances[index];
			var serializationInstance:Dynamic = {
				name: instance.name,
				position: instance.position.asArray(),
				scaling: instance.scaling.asArray()
			};
			if (instance.rotationQuaternion != null) {
				serializationInstance.rotationQuaternion = instance.rotationQuaternion.asArray();
			} 
			else if (instance.rotation != null) {
				serializationInstance.rotation = instance.rotation.asArray();
			}
			serializationObject.instances.push(serializationInstance);
			
			// Animations
			Animation.AppendSerializedAnimations(instance, serializationInstance);
			serializationInstance.ranges = instance.serializeAnimationRanges();
		}
		
		// 
		
		// Animations
		Animation.AppendSerializedAnimations(this, serializationObject);
		serializationObject.ranges = this.serializeAnimationRanges();
		
		// Layer mask
		serializationObject.layerMask = this.layerMask;
		
		// Alpha
		serializationObject.alphaIndex = this.alphaIndex;
		serializationObject.hasVertexAlpha = this.hasVertexAlpha;
		
		// Overlay
		serializationObject.overlayAlpha = this.overlayAlpha;
		serializationObject.overlayColor = this.overlayColor.asArray();
		serializationObject.renderOverlay = this.renderOverlay;
		
		// Fog
		serializationObject.applyFog = this.applyFog;
		
		// Action Manager
		if (this.actionManager != null) {
			serializationObject.actions = this.actionManager.serialize(this.name);
		}
		
		return serializationObject;
	}
	
	public function _syncGeometryWithMorphTargetManager() {
		if (this.geometry == null) {
			return;
		}
		
		this._markSubMeshesAsAttributesDirty();
		
		var morphTargetManager = this._morphTargetManager;
        if (morphTargetManager != null && morphTargetManager.vertexCount > 0) {
			if (this._morphTargetManager.vertexCount != this.getTotalVertices()) {
				Tools.Error("Mesh is incompatible with morph targets. Targets and mesh must all have the same vertices count.");
				this.morphTargetManager = null;
				return;
			}
			
			for (index in 0...morphTargetManager.numInfluencers) {
				var morphTarget = morphTargetManager.getActiveTarget(index);
				
				var positions = morphTarget.getPositions(); 
				if (positions == null) {
					Tools.Error("Invalid morph target. Target must have positions.");
					return;
				}
				
				this.geometry.setVerticesData(VertexBuffer.PositionKind + index, positions, false, 3);
				
				var normals = morphTarget.getNormals();
				if (normals != null) {
					this.geometry.setVerticesData(VertexBuffer.NormalKind + index, normals, false, 3);
				}
				
				var tangents = morphTarget.getTangents();
				if (tangents != null) {
					this.geometry.setVerticesData(VertexBuffer.TangentKind + index, tangents, false, 3);
				}
			}
		} 
		else {
			var index = 0;
			
			// Positions
			while (this.geometry.isVerticesDataPresent(VertexBuffer.PositionKind + index)) {
				this.geometry.removeVerticesData(VertexBuffer.PositionKind + index);
				
				if (this.geometry.isVerticesDataPresent(VertexBuffer.NormalKind + index)) {
					this.geometry.removeVerticesData(VertexBuffer.NormalKind + index);
				}
				if (this.geometry.isVerticesDataPresent(VertexBuffer.TangentKind + index)) {
					this.geometry.removeVerticesData(VertexBuffer.TangentKind + index);
				}
				index++;
			}    
		}
	}

	// Statics
	
	public static function CreateRibbon(name:String, pathArray:Array<Array<Vector3>>, ?closeArray:Bool = false, ?closePath:Bool = false, ?offset:Int = 0, ?scene:Scene, ?updatable:Bool = false, ?sideOrientation:Int = Mesh.DEFAULTSIDE, ?instance:Mesh):Mesh {
		var options:RibbonOptions = {
			pathArray: pathArray, 
			closeArray: closeArray, 
			closePath: closePath, 
			offset: offset,
			instance: instance,
			sideOrientation: sideOrientation,
			updatable: updatable
		};
		return MeshBuilder.CreateRibbon(name, options, scene);
	}
	
	public static function CreateDisc(name:String, radius:Float, tessellation:Int, scene:Scene, updatable:Bool = false, sideOrientation:Int = Mesh.DEFAULTSIDE):Mesh {
		var options:DiscOptions = {
			radius: radius,
			tessellation: tessellation,
			sideOrientation: sideOrientation,
			updatable: updatable
		};
		
		return MeshBuilder.CreateDisc(name, options, scene);
	}
		
	public static function CreateBox(name:String, size:Float, scene:Scene, updatable:Bool = false, sideOrientation:Int = Mesh.DEFAULTSIDE):Mesh {	
		var options:BoxOptions = {
			width: size,
			height: size,
			depth: size,
			sideOrientation: sideOrientation,
			updatable: updatable
		};
		
		return MeshBuilder.CreateBox(name, options, scene);
	}

	public static function CreateSphere(name:String, segments:Int, diameter:Float, scene:Scene, updatable:Bool = false, sideOrientation:Int = Mesh.DEFAULTSIDE):Mesh {
		var options:SphereOptions = {
			segments: segments,
			diameterX: diameter,
			diameterY: diameter,
			diameterZ: diameter,
			sideOrientation: sideOrientation,
			updatable: updatable
		};
		
		return MeshBuilder.CreateSphere(name, options, scene);
	}
	
	// Cylinder and cone
	public static function CreateCylinder(name:String, height:Float, diameterTop:Float, diameterBottom:Float, tessellation:Int, subdivisions:Int, scene:Scene, updatable:Bool = false, sideOrientation:Int = Mesh.DEFAULTSIDE):Mesh {
		var options:CylinderOptions = {
			height: height,
			diameterTop: diameterTop,
			diameterBottom: diameterBottom,
			tessellation: tessellation,
			subdivisions: subdivisions,
			sideOrientation: sideOrientation,
			updatable: updatable,
			enclose: true
		};
		
		return MeshBuilder.CreateCylinder(name, options, scene);
	}
	
	public static function CreateCapsule(name:String, scene:Scene, radius:Float = 1, height:Float = 2, segmentsW:Int = 16, segmentsH:Int = 16, updatable:Bool = false, sideOrientation:Int = Mesh.DEFAULTSIDE):Mesh {
		var options:CapsuleOptions = {
			radius: radius,
			height: height,
			segmentsW: segmentsW,
			segmentsH: segmentsH,
			sideOrientation: sideOrientation,
			updatable: updatable
		};
		
		return MeshBuilder.CreateCapsule(name, scene, options);
	}

	// Torus  (Code from SharpDX.org)
	public static function CreateTorus(name:String, diameter:Float, thickness:Float, tessellation:Int, scene:Scene, updatable:Bool = false, sideOrientation:Int = Mesh.DEFAULTSIDE):Mesh {				
		var options:TorusOptions = {
			diameter: diameter,
			thickness: thickness,
			tessellation: tessellation,
			sideOrientation: sideOrientation,
			updatable: updatable
		};
		
		return MeshBuilder.CreateTorus(name, scene, options);
	}
	
	public static function CreateTorusKnot(name:String, radius:Float, tube:Float, radialSegments:Int, tubularSegments:Int, p:Int, q:Int, scene:Scene, updatable:Bool = false, sideOrientation:Int = Mesh.DEFAULTSIDE):Mesh {	
		var options:TorusKnotOptions = {
			radius: radius,
			tube: tube,
			radialSegments: radialSegments,
			tubularSegments: tubularSegments,
			p: p,
			q: q,
			sideOrientation: sideOrientation,
			updatable: updatable
		};
		
		return MeshBuilder.CreateTorusKnot(name, options, scene);
	}
	
	// Lines
	public static function CreateLines(name:String, points:Array<Vector3>, scene:Scene, updatable:Bool = false, ?instance:LinesMesh):LinesMesh {
		var options:LinesOptions = {
			points: points,
			updatable: updatable,
			instance: instance
		};
		
		return MeshBuilder.CreateLines(name, options, scene);
	}

	// Dashed Lines
    public static function CreateDashedLines(name:String, points:Array<Vector3>, dashSize:Float, gapSize:Float, dashNb:Float, scene:Scene, updatable:Bool = false, ?instance:LinesMesh):LinesMesh { 
		var options:DashedLinesOptions = {
			points: points,
			dashSize: dashSize,
			gapSize: gapSize,
			dashNb: dashNb,
			updatable: updatable,
			instance: instance
		}
		
		return MeshBuilder.CreateDashedLines(name, options, scene);
	}
	
	// Extrusion
	public static function ExtrudeShape(name:String, shape:Array<Vector3>, path:Array<Vector3>, scale:Float = 1, rotation:Float = 0, cap:Int = Mesh.NO_CAP, scene:Scene, updatable:Bool = false, sideOrientation:Int = Mesh.DEFAULTSIDE, extrudedInstance:Mesh = null):Mesh {
		var options = {
			shape: shape,
			path: path,
			scale: scale,
			rotation: rotation,
			cap: cap,
			sideOrientation: sideOrientation,
			extrudedInstance: extrudedInstance,
			updatable: updatable
		};
		
		return MeshBuilder.ExtrudeShape(name, options, scene);
	}

	public static function ExtrudeShapeCustom(name:String, shape:Array<Vector3>, path:Array<Vector3>, scaleFunction:Float->Float->Float, rotationFunction:Float->Float->Float, ribbonCloseArray:Bool = false, ribbonClosePath:Bool = false, cap:Int = Mesh.NO_CAP, scene:Scene, updatable:Bool = false, sideOrientation:Int = Mesh.DEFAULTSIDE, extrudedInstance:Mesh = null):Mesh {
		var options = {
			shape: shape,
			path: path,
			scaleFunction: scaleFunction,
			rotationFunction: rotationFunction,
			ribbonCloseArray: ribbonCloseArray,
			ribbonClosePath: ribbonClosePath,
			cap: cap,
			sideOrientation: sideOrientation,
			extrudedInstance: extrudedInstance,
			updatable: updatable
		};
		
		return MeshBuilder.ExtrudeShapeCustom(name, options, scene);
	}
	
	// Lathe
	public static function CreateLathe(name:String, shape:Array<Vector3>, radius:Float = 1, tessellation:Int = 0, scene:Scene, updatable:Bool = false, sideOrientation:Int = Mesh.DEFAULTSIDE):Mesh {
		var options:LatheOptions = {
			shape: shape,
			radius: radius,
			tesselation: tessellation,
			sideOrientation: sideOrientation,
			updatable: updatable
		};
		
		return MeshBuilder.CreateLathe(name, options, scene);
	}

	// Plane & ground
	public static function CreatePlane(name:String, size:Float, scene:Scene, updatable:Bool = false, sideOrientation:Int = Mesh.DEFAULTSIDE):Mesh {	   	  
		var options:PlaneOptions = {
			width: size,
			height: size,
			sideOrientation: sideOrientation,
			updatable: updatable
		}
		
		return MeshBuilder.CreatePlane(name, options, scene);
	}
	
	public static function CreateGround(name:String, width:Float, height:Float, subdivisions:Int, scene:Scene, updatable:Bool = false):Mesh {
		var options:GroundOptions = {
			width: width,
			height: height,
			subdivisions: subdivisions,
			updatable: updatable
		}
		
		return MeshBuilder.CreateGround(name, options, scene);
	}
	
	public static function CreateTiledGround(name:String, xmin:Float, zmin:Float, xmax:Float, zmax:Float, subdivisions:Int, precision:Int, scene:Scene, updatable:Bool = false): Mesh{
		var options:TiledGroundOptions = {
			xmin: xmin,
			zmin: zmin,
			xmax: xmax,
			zmax: zmax,
			subdivisions: subdivisions,
			precision: precision,
			updatable: updatable
		};
		
		return MeshBuilder.CreateTiledGround(name, options, scene);
	}
		
	public static function CreateGroundFromHeightMap(name:String, url:String, width:Float, height:Float, subdivisions:Int, minHeight:Float, maxHeight:Float, scene:Scene, updatable:Bool = false, ?onReady:GroundMesh->Void):GroundMesh {
		var options:GroundFromHeightmapOptions = {
			width: width,
			height: height,
			subdivisions: subdivisions,
			minHeight: minHeight,
			maxHeight: maxHeight,
			updatable: updatable,
			onReady: onReady
		};
		
		return MeshBuilder.CreateGroundFromHeightMap(name, url, options, scene);
	}
	
	public static function CreateTube(name:String, path:Array<Vector3>, radius:Float, tessellation:Int, radiusFunction:Int->Float->Float, cap:Int, scene:Scene, updatable:Bool = false, sideOrientation:Int = Mesh.DEFAULTSIDE, ?instance:Mesh):Mesh {		
		var options:TubeOptions = {
			path: path,
			radius: radius,
			tessellation: tessellation,
			radiusFunction: radiusFunction,
			arc: 1,
			cap: cap,
			updatable: updatable,
			sideOrientation: sideOrientation,
			instance: instance
		}
		
		return MeshBuilder.CreateTube(name, options, scene);
	}
	
	public static function CreatePolyhedron(name:String, options:PolyhedronOptions, scene:Scene):Mesh {		
		return MeshBuilder.CreatePolyhedron(name, options, scene);
	}
	
	public static function CreateIcoSphere(name:String, options:IcoSphereOptions, scene:Scene):Mesh {
		return MeshBuilder.CreateIcoSphere(name, options, scene);
	}
	
	// Decals	
    public static function CreateDecal(name:String, sourceMesh:AbstractMesh, position:Vector3, normal:Vector3, size:Vector3, angle:Float = 0) {
        var options = {
			position: position,
			normal: normal,
			size: size, 
			angle: angle
		}
		
		return MeshBuilder.CreateDecal(name, sourceMesh, options);
    }
	
	// Skeletons
	/**
	 * @returns original positions used for CPU skinning.  Useful for integrating Morphing with skeletons in same mesh.
	 */
	public function setPositionsForCPUSkinning():Float32Array {
		if (this._sourcePositions == null) {
			var source = this.getVerticesData(VertexBuffer.PositionKind);
			
			if (source == null) {
				return this._sourcePositions;
			}
			
			this._sourcePositions = source.subarray(0, source.length);
			
			if (!this.isVertexBufferUpdatable(VertexBuffer.PositionKind)) {
				this.setVerticesData(VertexBuffer.PositionKind, source, true);
			}
		}
		
		return this._sourcePositions;
	}

	/**
	 * @returns original normals used for CPU skinning.  Useful for integrating Morphing with skeletons in same mesh.
	 */
	public function setNormalsForCPUSkinning():Float32Array {
		if (this._sourceNormals == null) {
			var source = this.getVerticesData(VertexBuffer.NormalKind);
			
			if (source == null) {
                return this._sourceNormals;
            }
			
			this._sourceNormals = source;
			
			if (!this.isVertexBufferUpdatable(VertexBuffer.NormalKind)) {
				this.setVerticesData(VertexBuffer.NormalKind, source, true);
			}
		}
		
		return this._sourceNormals;
	}

	/**
	 * Update the vertex buffers by applying transformation from the bones
	 * @param {skeleton} skeleton to apply
	 */
	public function applySkeleton(skeleton:Skeleton):Mesh {
		if (this.geometry == null) {
			return this;
		}
		
		if (this.geometry._softwareSkinningRenderId == this.getScene().getRenderId()) {
			return this;
		}
		
		this.geometry._softwareSkinningRenderId = this.getScene().getRenderId();
		
		if (!this.isVerticesDataPresent(VertexBuffer.PositionKind)) {
			return this;
		}
		if (!this.isVerticesDataPresent(VertexBuffer.NormalKind)) {
			return this;
		}
		if (!this.isVerticesDataPresent(VertexBuffer.MatricesIndicesKind)) {
			return this;
		}
		if (!this.isVerticesDataPresent(VertexBuffer.MatricesWeightsKind)) {
			return this;
		}
		
		if (this._sourcePositions == null) {
			var submeshes = this.subMeshes.copy();
			this.setPositionsForCPUSkinning();
			this.subMeshes = submeshes;
		}
		
		if (this._sourceNormals == null) {
			this.setNormalsForCPUSkinning();
		}
		
		// positionsData checks for not being Float32Array will only pass at most once
		var positionsData = this.getVerticesData(VertexBuffer.PositionKind);
		
		if (positionsData == null) {
            return this;
        }
		
		// normalsData checks for not being Float32Array will only pass at most once
		var normalsData = this.getVerticesData(VertexBuffer.NormalKind);
		
		if (normalsData == null) {
            return this;
        }
		
		var matricesIndicesData = this.getVerticesData(VertexBuffer.MatricesIndicesKind);
		var matricesWeightsData = this.getVerticesData(VertexBuffer.MatricesWeightsKind);
		
		if (matricesWeightsData == null || matricesIndicesData == null) {
            return this;
        }
		
		var needExtras:Bool = this.numBoneInfluencers > 4;
        var matricesIndicesExtraData = needExtras ? this.getVerticesData(VertexBuffer.MatricesIndicesExtraKind) : null;
        var matricesWeightsExtraData = needExtras ? this.getVerticesData(VertexBuffer.MatricesWeightsExtraKind) : null;
		
		var skeletonMatrices = skeleton.getTransformMatrices(this);
		
		var tempVector3 = Vector3.Zero();
		var finalMatrix = new Matrix();
		var tempMatrix = new Matrix();
		
		var matWeightIdx:Int = 0;
		var index:Int = 0;
		while (index < positionsData.length) {
			for (inf in 0...4){
                var weight = matricesWeightsData[matWeightIdx + inf];
                if (weight > 0) {
                    Matrix.FromFloat32ArrayToRefScaled(skeletonMatrices, Std.int(matricesIndicesData[matWeightIdx + inf] * 16), weight, tempMatrix);
                    finalMatrix.addToSelf(tempMatrix);                    
                }
				else {
					break;   
				}
            }
			
			if (needExtras) {
                for (inf in 0...4) {
                    var weight = matricesWeightsExtraData[matWeightIdx + inf];
                    if (weight > 0) {
                        Matrix.FromFloat32ArrayToRefScaled(new Float32Array(skeletonMatrices), cast (matricesIndicesExtraData[matWeightIdx + inf] * 16), weight, tempMatrix);
                        finalMatrix.addToSelf(tempMatrix);
                    } 
					else {
						break;           
					}
                }
            }
			
			Vector3.TransformCoordinatesFromFloatsToRef(this._sourcePositions[index], this._sourcePositions[index + 1], this._sourcePositions[index + 2], finalMatrix, tempVector3);
			tempVector3.toFloat32Array(positionsData, index);
			
			Vector3.TransformNormalFromFloatsToRef(this._sourceNormals[index], this._sourceNormals[index + 1], this._sourceNormals[index + 2], finalMatrix, tempVector3);
			tempVector3.toFloat32Array(normalsData, index);
			
			finalMatrix.reset();
			
			index += 3;
			matWeightIdx += 4;
		}
		
		this.updateVerticesData(VertexBuffer.PositionKind, positionsData);
		this.updateVerticesData(VertexBuffer.NormalKind, normalsData);
		
		return this;
	}

	// Tools
	
	/**
     * Returns an object `{min: Vector3, max: Vector3}`
     * This min and max `Vector3` are the minimum and maximum vectors of each mesh bounding 
	 * box from the passed array, in the World system
     */
	public static function MinMax(meshes:Array<AbstractMesh>):BabylonMinMax {
		var minVector:Vector3 = null;
		var maxVector:Vector3 = null;
		
		for (mesh in meshes) {
			var boundingInfo = mesh.getBoundingInfo();
			
			var boundingBox = boundingInfo.boundingBox;
			if (minVector == null || maxVector == null) {
				minVector = boundingBox.minimumWorld;
				maxVector = boundingBox.maximumWorld;
			} 
			else {
				minVector.MinimizeInPlace(boundingBox.minimumWorld);
				maxVector.MaximizeInPlace(boundingBox.maximumWorld);
			}
		}
		
		if (minVector == null || maxVector == null) {
			return {
				minimum: Vector3.Zero(),
				maximum: Vector3.Zero()
			}
		}
		
		return { minimum: minVector, maximum: maxVector };
	}

	/**
     * Returns a `Vector3`, the center of the `{min: Vector3, max: Vector3}` or the center of 
	 * MinMax vector3 computed from a mesh array.
     */
	public static function Center(meshesOrMinMaxVector:Dynamic):Vector3 {
		var minMaxVector:BabylonMinMax = Std.is(meshesOrMinMaxVector, Array) ? Mesh.MinMax(meshesOrMinMaxVector) : meshesOrMinMaxVector;
		return Vector3.Center(minMaxVector.minimum, minMaxVector.maximum);
	}
	
	/**
	 * Merge the array of meshes into a single mesh for performance reasons.
	 * @param {Array<Mesh>} meshes - The vertices source.  They should all be of the same material.  Entries can empty
	 * @param {boolean} disposeSource - When true (default), dispose of the vertices from the source meshes
	 * @param {boolean} allow32BitsIndices - When the sum of the vertices > 64k, this must be set to true.
	 * @param {Mesh} meshSubclass - When set, vertices inserted into this Mesh.  Meshes can then be merged into a Mesh sub-class.
	 */
	public static function MergeMeshes(meshes:Array<Mesh>, disposeSource:Bool = true, allow32BitsIndices:Bool = false, ?meshSubclass:Mesh, subdivideWithSubMeshes:Bool = false):Mesh {
		if (!allow32BitsIndices) {
			var totalVertices = 0;
			
			// Counting vertices
			for (index in 0...meshes.length) {
				if (meshes[index] != null) {
					totalVertices += meshes[index].getTotalVertices();
					
					if (totalVertices > 65536) {
						trace("Cannot merge meshes because resulting mesh will have more than 65536 vertices. Please use allow32BitsIndices = true to use 32 bits indices");
						return null;
					}
				}
			}
		}
		
		// Merge
		var vertexData:VertexData = null;
		var otherVertexData:VertexData = null;
		var indiceArray:Array<Int> = [];
		var source:Mesh = null;
		for (index in 0...meshes.length) {
			if (meshes[index] != null) {
				meshes[index].computeWorldMatrix(true);
				otherVertexData = VertexData.ExtractFromMesh(meshes[index], true);
				otherVertexData.transform(meshes[index].getWorldMatrix());
				
				if (vertexData != null) {
					vertexData.merge(otherVertexData);
				}
				else {
					vertexData = otherVertexData;
					source = meshes[index];
				}
				
				if (subdivideWithSubMeshes) {
					indiceArray.push(meshes[index].getTotalIndices());
				}
			}
		}
		
		if (meshSubclass == null) {
			meshSubclass = new Mesh(source.name + "_merged", source.getScene());
		}
		vertexData.applyToMesh(meshSubclass);
		
		// Setting properties
		meshSubclass.material = source.material;
		meshSubclass.checkCollisions = source.checkCollisions;
		
		// Cleaning
		if (disposeSource) {
			for (index in 0...meshes.length) {
				if (meshes[index] != null) {
					meshes[index].dispose();
				}
			}
		}
		
		// Subdivide
		if (subdivideWithSubMeshes) {
			//-- Suppresions du submesh global
			meshSubclass.releaseSubMeshes();
			var index:Int = 0;
			var offset:Int = 0;
			
			//-- aplique la subdivision en fonction du tableau d'indices
			while (index < indiceArray.length) {
				SubMesh.CreateFromIndices(0, offset, indiceArray[index], meshSubclass);
				offset += indiceArray[index];
				index++;
			}
		}
		
		return meshSubclass;
	}
	
	/**
     * Returns a new `Mesh` object what is a deep copy of the passed mesh.
     * The parameter `parsedMesh` is the mesh to be copied.
     * The parameter `rootUrl` is a string, it's the root URL to prefix the `delayLoadingFile` property with
     */
	public static function Parse(parsedMesh:Dynamic, scene:Scene, rootUrl:String):Mesh {
        var mesh:Mesh = null;
		
		if (parsedMesh.type != null && parsedMesh.type == "GroundMesh") {
			mesh = GroundMesh.Parse(parsedMesh, scene);
		} 
		else {
			mesh = new Mesh(parsedMesh.name, scene);
		}
		mesh.id = parsedMesh.id;
		
		if (parsedMesh.tags != null) {
			Tags.AddTagsTo(mesh, parsedMesh.tags);
		}
		
		if (parsedMesh.position != null) {
			mesh.position = Vector3.FromArray(parsedMesh.position);
		}
		
		if (parsedMesh.metadata != null) {
			mesh.metadata = parsedMesh.metadata;
		}
		
		if (parsedMesh.rotationQuaternion != null) {
			mesh.rotationQuaternion = Quaternion.FromArray(parsedMesh.rotationQuaternion);
		} 
		else if (parsedMesh.rotation != null) {
			mesh.rotation = Vector3.FromArray(parsedMesh.rotation);
		}
		
		if (parsedMesh.scaling != null) {
			mesh.scaling = Vector3.FromArray(parsedMesh.scaling);
		}
		
		if (parsedMesh.localMatrix != null) {
			mesh.setPreTransformMatrix(Matrix.FromArray(parsedMesh.localMatrix));
		} 
		else if (parsedMesh.pivotMatrix != null) {
			mesh.setPivotMatrix(Matrix.FromArray(parsedMesh.pivotMatrix));
		}
		
		if (parsedMesh.isEnabled != null) {
			mesh.setEnabled(parsedMesh.isEnabled);
		}
		if (parsedMesh.isVisible != null) {
			mesh.isVisible = parsedMesh.isVisible;
		}
		if (parsedMesh.infiniteDistance != null) {
			mesh.infiniteDistance = parsedMesh.infiniteDistance;
		}
		
		if (parsedMesh.showBoundingBox != null) {
			mesh.showBoundingBox = parsedMesh.showBoundingBox;
		}
		if (parsedMesh.showSubMeshesBoundingBox != null) {
			mesh.showSubMeshesBoundingBox = parsedMesh.showSubMeshesBoundingBox;
		}
		
		if (parsedMesh.applyFog != null) {
			mesh.applyFog = parsedMesh.applyFog;
		}
		
		if (parsedMesh.pickable != null) {
			mesh.isPickable = parsedMesh.pickable;
		}
		
		if (parsedMesh.alphaIndex != null) {
			mesh.alphaIndex = parsedMesh.alphaIndex;
		}
		
		if (parsedMesh.receiveShadows != null) {
			mesh.receiveShadows = parsedMesh.receiveShadows;
		}
		
		if (parsedMesh.billboardMode != null) {
			mesh.billboardMode = parsedMesh.billboardMode;
		}
		
		if (parsedMesh.visibility != null) {
			mesh.visibility = parsedMesh.visibility;
		}
		
		if (parsedMesh.checkCollisions != null) {
			mesh.checkCollisions = parsedMesh.checkCollisions;
		}
		
		if (parsedMesh.isBlocker != null) {
			mesh.isBlocker = parsedMesh.isBlocker;
		}
		
		if (parsedMesh.useFlatShading != null) {
			mesh._shouldGenerateFlatShading = parsedMesh.useFlatShading;
		}
		
		// freezeWorldMatrix
		if (parsedMesh.freezeWorldMatrix != null) {
			mesh._waitingFreezeWorldMatrix = parsedMesh.freezeWorldMatrix;
		}
		
		// Parent
		if (parsedMesh.parentId != null && parsedMesh.parentId != "") {
			mesh._waitingParentId = parsedMesh.parentId;
		}
		
		// Actions
		if (parsedMesh.actions != null) {
			mesh._waitingActions = parsedMesh.actions;
		}
		
		// Overlay
		if (parsedMesh.overlayAlpha != null) {
			mesh.overlayAlpha = parsedMesh.overlayAlpha;
		}
		
		if (parsedMesh.overlayColor != null) {
			mesh.overlayColor = Color3.FromArray(parsedMesh.overlayColor);
		}
		
		if (parsedMesh.renderOverlay != null) {
			mesh.renderOverlay = parsedMesh.renderOverlay;
		}
		
		// Geometry
		if (parsedMesh.isUnIndexed != null) {
			mesh.isUnIndexed = parsedMesh.isUnIndexed;
		}
		if (parsedMesh.hasVertexAlpha != null) {
			mesh.hasVertexAlpha = parsedMesh.hasVertexAlpha;
		}
		
		if (parsedMesh.delayLoadingFile != null) {
			mesh.delayLoadState = Engine.DELAYLOADSTATE_NOTLOADED;
			mesh.delayLoadingFile = rootUrl + parsedMesh.delayLoadingFile;
			mesh._boundingInfo = new BoundingInfo(Vector3.FromArray(parsedMesh.boundingBoxMinimum), Vector3.FromArray(parsedMesh.boundingBoxMaximum));
			
			if (parsedMesh._binaryInfo != null) {
				mesh._binaryInfo = parsedMesh._binaryInfo;
			}
			
			mesh._delayInfo = [];
			if (parsedMesh.hasUVs) {
				mesh._delayInfo.push(VertexBuffer.UVKind);
			}
			
			if (parsedMesh.hasUVs2) {
				mesh._delayInfo.push(VertexBuffer.UV2Kind);
			}
			
			if (parsedMesh.hasUVs3) {
				mesh._delayInfo.push(VertexBuffer.UV3Kind);
			}
			
			if (parsedMesh.hasUVs4) {
				mesh._delayInfo.push(VertexBuffer.UV4Kind);
			}
			
			if (parsedMesh.hasUVs5) {
				mesh._delayInfo.push(VertexBuffer.UV5Kind);
			}
			
			if (parsedMesh.hasUVs6) {
				mesh._delayInfo.push(VertexBuffer.UV6Kind);
			}
			
			if (parsedMesh.hasColors) {
				mesh._delayInfo.push(VertexBuffer.ColorKind);
			}
			
			if (parsedMesh.hasMatricesIndices) {
				mesh._delayInfo.push(VertexBuffer.MatricesIndicesKind);
			}
			
			if (parsedMesh.hasMatricesWeights) {
				mesh._delayInfo.push(VertexBuffer.MatricesWeightsKind);
			}
			
			mesh._delayLoadingFunction = Geometry._ImportGeometry;
			
			if (SceneLoader.ForceFullSceneLoadingForIncremental) {
				mesh._checkDelayState();
			}
		} 
		else {
			Geometry._ImportGeometry(parsedMesh, mesh);
		}
		
		// Material
		if (parsedMesh.materialId != null && parsedMesh.materialId != "") {
			mesh.setMaterialByID(parsedMesh.materialId);
		} 
		else {
			mesh.material = null;
		}
		
		// Morph targets
		if (parsedMesh.morphTargetManagerId > -1) {
			mesh.morphTargetManager = scene.getMorphTargetManagerById(parsedMesh.morphTargetManagerId);
		}
		
		// Skeleton
		if (parsedMesh.skeletonId > -1) {
			mesh.skeleton = scene.getLastSkeletonByID(parsedMesh.skeletonId);
			if (parsedMesh.numBoneInfluencers != null) {
				mesh.numBoneInfluencers = parsedMesh.numBoneInfluencers;
			}
		}
		
		// Animations
		if (parsedMesh.animations != null) {
			for (animationIndex in 0...parsedMesh.animations.length) {
				var parsedAnimation = parsedMesh.animations[animationIndex];
				
				mesh.animations.push(Animation.Parse(parsedAnimation));
			}
			Node.ParseAnimationRanges(mesh, parsedMesh, scene);
		}
		
		if (parsedMesh.autoAnimate) {
			scene.beginAnimation(mesh, parsedMesh.autoAnimateFrom, parsedMesh.autoAnimateTo, parsedMesh.autoAnimateLoop, parsedMesh.autoAnimateSpeed != null ? parsedMesh.autoAnimateSpeed : 1.0);
		}
		
		// Layer Mask
		if (parsedMesh.layerMask != null && (!Math.isNaN(parsedMesh.layerMask))) {
			mesh.layerMask = Std.parseInt(parsedMesh.layerMask);
		} 
		else {
			mesh.layerMask = 0x0FFFFFFF;
		}
		
		// VK TODO:
		// Physics
		/*if (parsedMesh.physicsImpostor != null) {
			mesh.physicsImpostor = new PhysicsImpostor(mesh, parsedMesh.physicsImpostor, {
				mass: parsedMesh.physicsMass,
				friction: parsedMesh.physicsFriction,
				restitution: parsedMesh.physicsRestitution
			}, scene);
		}*/
		
		// Instances
		if (parsedMesh.instances != null) {
			for (index in 0...parsedMesh.instances.length) {
				var parsedInstance = parsedMesh.instances[index];
				var instance = mesh.createInstance(parsedInstance.name);
				
				if (parsedInstance.tags != null) {
					Tags.AddTagsTo(instance, parsedInstance.tags);
				}
				
				if (parsedInstance.position != null) {
					instance.position = Vector3.FromArray(parsedInstance.position);
				}
				
				if (parsedInstance.parentId != null) {
					instance._waitingParentId = parsedInstance.parentId;
				}
				
				if (parsedInstance.rotationQuaternion != null) {
					instance.rotationQuaternion = Quaternion.FromArray(parsedInstance.rotationQuaternion);
				} 
				else if (parsedInstance.rotation != null) {
					instance.rotation = Vector3.FromArray(parsedInstance.rotation);
				}
				
				if (parsedInstance.scaling != null) {
					instance.scaling = Vector3.FromArray(parsedInstance.scaling);
				}
				
				if (parsedInstance.checkCollisions != null) {
					instance.checkCollisions = mesh.checkCollisions;
				}
				
				if (parsedMesh.animations != null) {
					for (animationIndex in 0...parsedMesh.animations.length) {
						var parsedAnimation = parsedMesh.animations[animationIndex];
						
						instance.animations.push(Animation.Parse(parsedAnimation));
					}
					Node.ParseAnimationRanges(instance, parsedMesh, scene);
				}
			}
		}
		
		return mesh;
    }
	
}
