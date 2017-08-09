package com.babylonhx.materials;

import com.babylonhx.ISmartArrayCompatible;
import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.materials.textures.RenderTargetTexture;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.BaseSubMesh;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Plane;
import com.babylonhx.tools.SmartArray;
import com.babylonhx.tools.Tools;
import com.babylonhx.tools.Tags;
import com.babylonhx.tools.Observable;
import com.babylonhx.tools.Observer;
import com.babylonhx.tools.EventState;
import com.babylonhx.tools.serialization.SerializationHelper;
import haxe.Timer;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Material') class Material implements ISmartArrayCompatible {
	
	public static inline var TriangleFillMode:Int = 0;
	public static inline var WireFrameFillMode:Int = 1;
	public static inline var PointFillMode:Int = 2;
	
	public static inline var ClockWiseSideOrientation:Int = 0;
	public static inline var CounterClockWiseSideOrientation:Int = 1;
	
	public static inline var TextureDirtyFlag:Int = 1;
	public static inline var LightDirtyFlag:Int = 2;
	public static inline var FresnelDirtyFlag:Int = 4;
	public static inline var AttributesDirtyFlag:Int = 8;
	public static inline var MiscDirtyFlag:Int = 16;
	
	@serialize()
	public var id:String;
	
	@serialize()
	public var name:String;
	
	@serialize()
	public var checkReadyOnEveryCall:Bool = false;
	
	@serialize()
	public var checkReadyOnlyOnce:Bool = false;
	
	@serialize()
	public var state:String = "";
	
	@serialize()
	public var alpha:Float = 1.0;
	
	@serialize("backFaceCulling")
	private var _backFaceCulling:Bool = true;
	public var backFaceCulling(get, set):Bool;
	private function set_backFaceCulling(value:Bool):Bool {
		if (this._backFaceCulling == value) {
			return value;
		}
		this._backFaceCulling = value;
		this.markAsDirty(Material.TextureDirtyFlag);
		
		return value;
	}
	private function get_backFaceCulling():Bool {
		return this._backFaceCulling;
	}
	
	@serialize()
	public var sideOrientation:Int = Material.CounterClockWiseSideOrientation;
	
	public var onCompiled:Effect->Void;
	public var onError:Effect->String->Void;
	public var getRenderTargetTextures:Void->SmartArray<RenderTargetTexture>;
	
	public var doNotSerialize:Bool = false;

	public var storeEffectOnSubMeshes:Bool = false;
	
	/**
	* An event triggered when the material is disposed.
	* @type {BABYLON.Observable}
	*/
	public var onDisposeObservable:Observable<Material> = new Observable<Material>();
	private var _onDisposeObserver:Observer<Material>;
	public var onDispose(never, set):Material->Null<EventState>->Void;
	private function set_onDispose(callback:Material->Null<EventState>->Void):Material->Null<EventState>->Void {
		if (this._onDisposeObserver != null) {
			this.onDisposeObservable.remove(this._onDisposeObserver);
		}
		this._onDisposeObserver = this.onDisposeObservable.add(callback);
		
		return callback;
	}

	/**
	* An event triggered when the material is bound.
	* @type {BABYLON.Observable}
	*/
	public var onBindObservable:Observable<AbstractMesh> = new Observable<AbstractMesh>();
	private var _onBindObserver:Observer<AbstractMesh>;
	public var onBind(never, set):AbstractMesh->Null<EventState>->Void;
	private function set_onBind(callback:AbstractMesh->Null<EventState>->Void):AbstractMesh->Null<EventState>->Void {
		if (this._onBindObserver != null) {
			this.onBindObservable.remove(this._onBindObserver);
		}
		this._onBindObserver = this.onBindObservable.add(callback);
		
		return callback;
	}
	
	/**
    * An event triggered when the material is unbound.
    * @type {BABYLON.Observable}
    */
    public var onUnBindObservable:Observable<Material> = new Observable<Material>();
	
	@serialize()
	public var alphaMode:Int = Engine.ALPHA_COMBINE;
	
	@serialize()
	public var disableDepthWrite:Bool = false;
	
	@serialize("fogEnabled")
	private var _fogEnabled:Bool = true;
	public var fogEnabled(get, set):Bool;
	private function set_fogEnabled(value:Bool):Bool {
		if (this._fogEnabled == value) {
			return value;
		}
		this._fogEnabled = value;
		this.markAsDirty(Material.MiscDirtyFlag);
		
		return value;
	}
	private function get_fogEnabled():Bool {
		return this._fogEnabled;
	}

	@serialize()
	public var pointSize:Float = 1.0;
	
	@serialize()
	public var zOffset:Float = 0.0;

	@serialize()
	public var wireframe(get, set):Bool;
	private function get_wireframe():Bool {
		return this._fillMode == Material.WireFrameFillMode;
	}
	private function set_wireframe(value:Bool):Bool {
		this._fillMode = (value ? Material.WireFrameFillMode : Material.TriangleFillMode);
		return value;
	}
	
	@serialize()
	public var pointsCloud(get, set):Bool;
	private function get_pointsCloud():Bool {
		return this._fillMode == Material.PointFillMode;
	}
	private function set_pointsCloud(value:Bool):Bool {
		this._fillMode = (value ? Material.PointFillMode : Material.TriangleFillMode);
		return value;
	}

	@serialize()
	public var fillMode(get, set):Int;
	private function get_fillMode():Int {
		return this._fillMode;
	}
	private function set_fillMode(value:Int):Int {
		this._fillMode = value;
		return value;
	}
	
	public var isFrozen(get, never):Bool;

	public var _effect:Effect;
	public var _wasPreviouslyReady:Bool = false;
	private var _useUBO:Bool;
	private var _scene:Scene;
	private var _fillMode:Int = Material.TriangleFillMode;
	private var _cachedDepthWriteState:Bool;
	
	private var _uniformBuffer:UniformBuffer;
	
	
	public var __smartArrayFlags:Array<Int> = [];	// BHX
	public var __serializableMembers:Dynamic;		// BHX
	

	public function new(name:String, scene:Scene = null, doNotAdd:Bool = false) {
		this.name = name;
		this.id = name != null ? name : Tools.uuid();
		
		this._scene = scene != null ? scene : Engine.LastCreatedScene;
		
		if (this._scene.useRightHandedSystem) {
			this.sideOrientation = Material.ClockWiseSideOrientation;
		} 
		else {
			this.sideOrientation = Material.CounterClockWiseSideOrientation;
		}
		
		this._uniformBuffer = new UniformBuffer(this._scene.getEngine());
		this._useUBO = this.getScene().getEngine().webGLVersion > 1;
		
		if (!doNotAdd) {
			this._scene.materials.push(this);
		}
		
		// TODO: macro ...
		#if purejs
		untyped __js__("Object.defineProperty(this, 'wireframe', { get: this.get_wireframe, set: this.set_wireframe })");
		untyped __js__("Object.defineProperty(this, 'fillMode', { get: this.get_fillMode, set: this.set_fillMode })");
		untyped __js__("Object.defineProperty(this, 'pointsCloud', { get: this.get_pointsCloud, set: this.set_pointsCloud })");
		#end
	}
	
	/**
	 * @param {boolean} fullDetails - support for multiple levels of logging within scene loading
	 * subclasses should override adding information pertainent to themselves
	 */
	public function toString(fullDetails:Bool = false):String {
		var ret = "Name: " + this.name;
		if (fullDetails) {
		}
		return ret;
	}
	
	/**
	 * Child classes can use it to update shaders         
	 */
	
	public function getClassName():String {
		return "Material";
	}
	
	private function get_isFrozen():Bool {
		return this.checkReadyOnlyOnce;
	}
	
	public function freeze() {
		this.checkReadyOnlyOnce = true;
	}
	
	public function unfreeze() {
		this.checkReadyOnlyOnce = false;
	}

	public function isReady(?mesh:AbstractMesh, useInstances:Bool = false):Bool {
		return true;
	}
	
	public function isReadyForSubMesh(mesh:AbstractMesh, subMesh:BaseSubMesh, useInstances:Bool = false):Bool {
		return false;            
	}

	public function getEffect():Effect {
		return this._effect;
	}

	public function getScene():Scene {
		return this._scene;
	}

	public function needAlphaBlending():Bool {
		return (this.alpha < 1.0);
	}

	public function needAlphaTesting():Bool {
		return false;
	}

	public function getAlphaTestTexture():BaseTexture {
		return null;
	}
	
	public function markDirty() {
		this._wasPreviouslyReady = false;
	}

	public function _preBind(?effect:Effect):Void {
		var engine = this._scene.getEngine();
		
		var reverse = this.sideOrientation == Material.ClockWiseSideOrientation;
		
		engine.enableEffect(effect != null ? effect : this._effect);
		engine.setState(this.backFaceCulling, this.zOffset, false, reverse);
	}

	public function bind(world:Matrix, ?mesh:Mesh) { }
	
	public function bindForSubMesh(world:Matrix, mesh:Mesh, subMesh:SubMesh) { }

	public function bindOnlyWorldMatrix(world:Matrix) { }
	
	public function bindSceneUniformBuffer(effect:Effect, sceneUbo:UniformBuffer) {
		sceneUbo.bindToEffect(effect, "Scene");
	}

	public function bindView(effect:Effect) {
		if (!this._useUBO) {
			effect.setMatrix("view", this.getScene().getViewMatrix());
		} 
		else {
			this.bindSceneUniformBuffer(effect, this.getScene().getSceneUniformBuffer());
		}
	}

	public function bindViewProjection(effect:Effect) {
		if (!this._useUBO) {
			effect.setMatrix("viewProjection", this.getScene().getTransformMatrix());
		} 
		else {
			this.bindSceneUniformBuffer(effect, this.getScene().getSceneUniformBuffer());
		}
	}

	public function _afterBind(mesh:Mesh, ?effect:Effect) {
		this._scene._cachedMaterial = this;
		
		this.onBindObservable.notifyObservers(mesh);
		
		if (this.disableDepthWrite) {
			var engine = this._scene.getEngine();
			this._cachedDepthWriteState = engine.getDepthWrite();
			engine.setDepthWrite(false);
		}
	}

	public function unbind() {
		this.onUnBindObservable.notifyObservers(this);
		
		if (this.disableDepthWrite) {
            var engine = this._scene.getEngine();
            engine.setDepthWrite(this._cachedDepthWriteState);
        }
	}
	
	public function getActiveTextures():Array<BaseTexture> {
		return new Array<BaseTexture>();
	}
	
	public function hasTexture(texture:BaseTexture):Bool {
		return false;
	}
	
	public function clone(name:String, cloneChildren:Bool = false):Material {
		return null;
	}
	
	public function getBindedMeshes():Array<AbstractMesh> {
		var result = new Array<AbstractMesh>();
		
		for (index in 0...this._scene.meshes.length) {
			var mesh = this._scene.meshes[index];
			
			if (mesh.material == this) {
				result.push(mesh);
			}
		}
		
		return result;
	}
	
	/*
	 * Force shader compilation including textures ready check
	 */
	var checkReady:Void->Void = null;
	public function forceCompilation(mesh:AbstractMesh, onCompiled:Material->Void, ?options:Dynamic) {
		var subMesh = new BaseSubMesh();
		var scene = this.getScene();
		var engine = getScene().getEngine();
		
		checkReady = function() {
			if (this._scene == null || this._scene.getEngine() == null) {
                return;
            }
			
			if (subMesh._materialDefines != null) {
				subMesh._materialDefines._renderId = -1;
			}
			
			var alphaTestState = engine.getAlphaTesting();
			var clipPlaneState = scene.clipPlane;
			
			engine.setAlphaTesting(options != null ? options.alphaTest : this.needAlphaTesting());
			
			if (options.clipPlane != null && options.clipPlane == true) {
				scene.clipPlane = new Plane(0, 0, 0, 1);
			}
			
			if (this.storeEffectOnSubMeshes) {
				if (this.isReadyForSubMesh(mesh, subMesh)) {				
					if (onCompiled != null) {
						onCompiled(this);
					}
				}
				else {
					Timer.delay(checkReady, 16);
				}
			}
			else {
				if (this.isReady(mesh)) {
					if (onCompiled != null) {
						onCompiled(this);
					}
				}
				else {
					Timer.delay(checkReady, 16);
				}
			}
			
			engine.setAlphaTesting(alphaTestState);
			
			if (options.clipPlane != null && options.clipPlane == true) {
				scene.clipPlane = clipPlaneState;
			}
		};
		
		checkReady();
	}
   
	public function markAsDirty(flag:Int) {
		if (flag & Material.TextureDirtyFlag != 0) {
			this._markAllSubMeshesAsTexturesDirty();
		}
		
		if (flag & Material.LightDirtyFlag != 0) {
			this._markAllSubMeshesAsLightsDirty();
		}
		
		if (flag & Material.FresnelDirtyFlag != 0) {
			this._markAllSubMeshesAsFresnelDirty();
		}
		
		if (flag & Material.AttributesDirtyFlag != 0) {
			this._markAllSubMeshesAsAttributesDirty();
		}
		
		if (flag & Material.MiscDirtyFlag != 0) {
			this._markAllSubMeshesAsMiscDirty();
		}
		
		this.getScene().resetCachedMaterial();
	}

	public function _markAllSubMeshesAsDirty(func:MaterialDefines->Void) {
		for (mesh in this.getScene().meshes) {
			if (mesh.subMeshes == null) {
				continue;
			}
			for (subMesh in mesh.subMeshes) {
				if (subMesh.getMaterial() != this) {
					continue;
				}
				
				if (subMesh._materialDefines == null) {
					continue;
				}
				
				func(subMesh._materialDefines);
			}
		}
	}
	
	public function _markAllSubMeshesAsImageProcessingDirty() {
		this._markAllSubMeshesAsDirty(function(defines:MaterialDefines) { defines.markAsImageProcessingDirty(); } );
	} 

	public function _markAllSubMeshesAsTexturesDirty() {
		this._markAllSubMeshesAsDirty(function(defines:MaterialDefines) { defines.markAsTexturesDirty(); } );
	}

	public function _markAllSubMeshesAsFresnelDirty() {
		this._markAllSubMeshesAsDirty(function(defines:MaterialDefines) { defines.markAsFresnelDirty(); } );
	}

	public function _markAllSubMeshesAsLightsDirty() {
		this._markAllSubMeshesAsDirty(function(defines:MaterialDefines) { defines.markAsLightDirty(); } );
	}

	public function _markAllSubMeshesAsAttributesDirty() {
		this._markAllSubMeshesAsDirty(function(defines:MaterialDefines) { defines.markAsAttributesDirty(); } );
	}

	public function _markAllSubMeshesAsMiscDirty() {
		this._markAllSubMeshesAsDirty(function(defines:MaterialDefines) { defines.markAsMiscDirty(); } );
	}

	public function dispose(forceDisposeEffect:Bool = false, forceDisposeTextures:Bool = false) {	
		// Animations
        this.getScene().stopAnimation(this);
		
		// Remove from scene
		var index = this._scene.materials.indexOf(this);
		if (index >= 0) {
			this._scene.materials.splice(index, 1);
		}
		
		// Remove from meshes
		var mesh:AbstractMesh = null;
		for (index in 0...this._scene.meshes.length) {
			mesh = this._scene.meshes[index];
			
			if (mesh.material == this) {
				mesh.material = null;
				
				if (mesh.getClassName() == "Mesh" && untyped mesh.geometry != null) {
					var geometry = untyped mesh.geometry;
					
					if (this.storeEffectOnSubMeshes) {
						for (subMesh in mesh.subMeshes) {
							geometry._releaseVertexArrayObject(subMesh._materialEffect);
						}
					} 
					else {
						geometry._releaseVertexArrayObject(this._effect);
					}
				}
			}
		}
		
		this._uniformBuffer.dispose();
		
		// Shader are kept in cache for further use but we can get rid of this by using forceDisposeEffect
		if (forceDisposeEffect && this._effect != null) {
			if (this.storeEffectOnSubMeshes) {
				for (subMesh in mesh.subMeshes) {
					this._scene.getEngine()._releaseEffect(subMesh._materialEffect); 
				}
			} 
			else {
				this._scene.getEngine()._releaseEffect(this._effect);                    
			}
			this._effect = null;
		}
		
		// Callback
		this.onDisposeObservable.notifyObservers(this);
		
		this.onDisposeObservable.clear();
        this.onBindObservable.clear();
		this.onUnBindObservable.clear();
	}
	
	public function copyTo(other:Material) {
		other.checkReadyOnlyOnce = this.checkReadyOnlyOnce;
		other.checkReadyOnEveryCall = this.checkReadyOnEveryCall;
		other.alpha = this.alpha;
		other.fillMode = this.fillMode;
		other.backFaceCulling = this.backFaceCulling;
		other.wireframe = this.wireframe;
		other.fogEnabled = this.fogEnabled;
		other.wireframe = this.wireframe;
		other.zOffset = this.zOffset;
		other.alphaMode = this.alphaMode;
		other.sideOrientation = this.sideOrientation;
		other.disableDepthWrite = this.disableDepthWrite;
		other.pointSize = this.pointSize;
		other.pointsCloud = this.pointsCloud;
	}
	
	public function serialize():Dynamic {
		return SerializationHelper.Serialize(Material, this);
	}
	
	public static function ParseMultiMaterial(parsedMultiMaterial:Dynamic, scene:Scene):MultiMaterial {
		var multiMaterial = new MultiMaterial(parsedMultiMaterial.name, scene);
		
		multiMaterial.id = parsedMultiMaterial.id;
		
		Tags.AddTagsTo(multiMaterial, parsedMultiMaterial.tags);
		
		for (matIndex in 0...parsedMultiMaterial.materials.length) {
			var subMatId = parsedMultiMaterial.materials[matIndex];
			
			if (subMatId != null) {
				multiMaterial.subMaterials.push(scene.getMaterialByID(subMatId));
			} 
			else {
				multiMaterial.subMaterials.push(null);
			}
		}
		
		return multiMaterial;
	}

	public static function Parse(parsedMaterial:Dynamic, scene:Scene, rootUrl:String):Material {
		if (parsedMaterial.customType == null) {
			return StandardMaterial.Parse(parsedMaterial, scene, rootUrl);
		}
		
		var materialType = Type.resolveClass(parsedMaterial.customType);
		
		if (materialType != null) {
			return Type.createEmptyInstance(materialType).Parse(parsedMaterial, scene, rootUrl);
		}
		
		return null;
	}
	
}
