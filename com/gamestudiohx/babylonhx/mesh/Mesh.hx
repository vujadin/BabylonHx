package com.gamestudiohx.babylonhx.mesh;

import com.gamestudiohx.babylonhx.animations.Animation;
import com.gamestudiohx.babylonhx.bones.Skeleton;
import com.gamestudiohx.babylonhx.collisions.Collider;
import com.gamestudiohx.babylonhx.collisions.PickingInfo;
import com.gamestudiohx.babylonhx.materials.Effect;
import com.gamestudiohx.babylonhx.materials.Material;
import com.gamestudiohx.babylonhx.Engine;
import com.gamestudiohx.babylonhx.materials.StandardMaterial;
import com.gamestudiohx.babylonhx.Node;
import com.gamestudiohx.babylonhx.Scene;
import com.gamestudiohx.babylonhx.tools.math.Vector2;
import com.gamestudiohx.babylonhx.tools.Tools;
import com.gamestudiohx.babylonhx.tools.math.Matrix;
import com.gamestudiohx.babylonhx.tools.math.Plane;
import com.gamestudiohx.babylonhx.tools.math.Quaternion;
import com.gamestudiohx.babylonhx.tools.math.Ray;
import com.gamestudiohx.babylonhx.tools.math.Vector3;
import com.gamestudiohx.babylonhx.culling.BoundingInfo;
import com.gamestudiohx.babylonhx.particles.ParticleSystem;
import flash.display.BitmapData;
import haxe.io.BufferInput;

import openfl.gl.GLBuffer;
import openfl.utils.Float32Array;

/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

typedef MeshCache = {
	localMatrixUpdated: Null<Bool>,
	position: Null<Vector3>,
	scaling: Null<Vector3>,
	rotation: Null<Vector3>,
	rotationQuaternion: Null<Quaternion>,
	pivotMatrixUpdated: Null<Bool>
}

class BabylonGLBuffer {
	
	public var buffer:GLBuffer;
	public var references:Int;
	
	
	public function new(buffer:GLBuffer) {
		this.buffer = buffer;
		this.references = 1;
	}
	
}
 
class Mesh extends Node {
	
	public static var BILLBOARDMODE_NONE:Int = 0;
	public static var BILLBOARDMODE_X:Int = 1;
	public static var BILLBOARDMODE_Y:Int = 2;
	public static var BILLBOARDMODE_Z:Int = 4;
	public static var BILLBOARDMODE_ALL:Int = 7;


	public var rotation:Vector3;
	public var scaling:Vector3;
	public var rotationQuaternion:Quaternion;
	public var subMeshes:Array<SubMesh>;
	public var animations:Array<Animation>;
	public var infiniteDistance:Bool;
	
	// privates ?
	public var delayLoadState:Int;
	public var delayLoadingFile:String;
	public var material:Dynamic;			// Material or MultiMaterial
	public var isVisible:Bool;
	public var isPickable:Bool;
	public var visibility:Float;		// Int ?
	public var billboardMode:Int;
	public var checkCollisions:Bool;
	public var receiveShadows:Bool;

	public var onDispose:Void->Void;
	public var skeleton:Skeleton;
	public var renderingGroupId:Int;
	
	public var _animationStarted:Bool;
	public var _scaleFactor:Float;
	public var _isDisposed:Bool;
	public var _totalVertices:Int;
	public var _worldMatrix:Matrix;
	public var _pivotMatrix:Matrix;
	public var _vertexStrideSize:Float;						// Float ?
	public var _indices:Array<Int>;
	public var _renderId:Int;
	public var _onBeforeRenderCallbacks:Array<Dynamic>;		// TODO
	public var _localScaling:Matrix;
	public var _localRotation:Matrix;
	public var _localTranslation:Matrix;
	public var _localBillboard:Matrix;
	public var _localPivotScaling:Matrix;
	public var _localPivotScalingRotation:Matrix;
	public var _localWorld:Matrix;
	public var _rotateYByPI:Matrix;
	
	public var _boundingInfo:BoundingInfo;
	public var _collisionsTransformMatrix:Matrix;
	public var _collisionsScalingMatrix:Matrix;
	public var _absolutePosition:Vector3;
	public var _currentRenderId:Int;
	
	public var _positions:Array<Vector3>;
	
	public var _vertexBuffers:Map<String, VertexBuffer>;			// TODO - this can be both VertexBuffer and BabylonGLBuffer
	public var _vertexBuffersB:Map<String, BabylonGLBuffer>;		// so this one is created to separate these two ...
	public var _delayInfo:Array<String>;
	public var _indexBuffer:BabylonGLBuffer;
	
	public var parentId(get, null):String;
	function get_parentId():String {
		if (this.parent != null) {
			return this.parent.id;
		} 
		return "";
	}
	

	public function new(name:String, scene:Scene) {
		super(scene);
		
		this.name = name;
        this.id = name;
        this._scene = scene;

        this._totalVertices = 0;
        this._worldMatrix = Matrix.Identity();

        scene.meshes.push(this);

        this.position = new Vector3(0, 0, 0);
        this.rotation = new Vector3(0, 0, 0);
        this.rotationQuaternion = null;
        this.scaling = new Vector3(1, 1, 1);

        this._pivotMatrix = Matrix.Identity();

        this._indices = [];
        this.subMeshes = [];

        this._renderId = 0;

        this._onBeforeRenderCallbacks = [];
        
        // Animations
        this.animations = [];

        // Cache
        this._positions = null;
		this._cache = {
			localMatrixUpdated: false,
			position: Vector3.Zero(),
			scaling: Vector3.Zero(),
			rotation: Vector3.Zero(),
			rotationQuaternion: new Quaternion(0, 0, 0, 0),
			pivotMatrixUpdated: null
		};
        //this._initCache();

        this._localScaling = Matrix.Zero();
        this._localRotation = Matrix.Zero();
        this._localTranslation = Matrix.Zero();
        this._localBillboard = Matrix.Zero();
        this._localPivotScaling = Matrix.Zero();
        this._localPivotScalingRotation = Matrix.Zero();
        this._localWorld = Matrix.Zero();
        this._worldMatrix = Matrix.Zero();
        this._rotateYByPI = Matrix.RotationY(Math.PI);

        this._collisionsTransformMatrix = Matrix.Zero();
        this._collisionsScalingMatrix = Matrix.Zero();

        this._absolutePosition = Vector3.Zero();
		
		this.delayLoadState = Engine.DELAYLOADSTATE_NONE;
		material = null;
		isVisible = true;
		isPickable = true;
		visibility = 1.0;
		billboardMode = Mesh.BILLBOARDMODE_NONE;
		checkCollisions = false;
		receiveShadows = false;

		_isDisposed = false;
		onDispose = null;

		skeleton = null;
		
		renderingGroupId = 0;
		
		infiniteDistance = false;
	}
	
	public function _resetPointsArrayCache() {
		this._positions = null;
	}
	
	public function _generatePointsArray() {
		if (this._positions != null)
            return;

        this._positions = [];

        var data = this._vertexBuffers.get(VertexBuffer.PositionKind).getData();
		var index:Int = 0;
        while (index < data.length) {
            this._positions.push(Vector3.FromArray(data, index));
			index += 3;
        }
	}
	
	inline public function _collideForSubMesh(subMesh:SubMesh, transformMatrix:Matrix, collider:Collider) {
		this._generatePointsArray();
        // Transformation
        if (subMesh._lastColliderWorldVertices == null || !subMesh._lastColliderTransformMatrix.equals(transformMatrix)) {
            subMesh._lastColliderTransformMatrix = transformMatrix;
            subMesh._lastColliderWorldVertices = [];
            var start = subMesh.verticesStart;
            var end = (subMesh.verticesStart + subMesh.verticesCount);
            for (i in start...end) {
                subMesh._lastColliderWorldVertices.push(Vector3.TransformCoordinates(this._positions[i], transformMatrix));
            }
        }
        // Collide
        collider._collide(subMesh, subMesh._lastColliderWorldVertices, this._indices, subMesh.indexStart, subMesh.indexStart + subMesh.indexCount, subMesh.verticesStart);
	}
	
	inline public function _processCollisionsForSubModels(collider:Collider, transformMatrix:Matrix) {
        for (index in 0...this.subMeshes.length) {
            var subMesh = this.subMeshes[index];

            // Bounding test
            if (this.subMeshes.length > 1 && !subMesh._checkCollision(collider))
                continue;

            this._collideForSubMesh(subMesh, transformMatrix, collider);
        }
    }
	
	inline public function _checkCollision(collider:Collider) {
        // Bounding box test
        if (this._boundingInfo._checkCollision(collider)) {
			// Transformation matrix
			Matrix.ScalingToRef(1.0 / collider.radius.x, 1.0 / collider.radius.y, 1.0 / collider.radius.z, this._collisionsScalingMatrix);
			this._worldMatrix.multiplyToRef(this._collisionsScalingMatrix, this._collisionsTransformMatrix);

			this._processCollisionsForSubModels(collider, this._collisionsTransformMatrix);
		}
    }

	public function getBoundingInfo():BoundingInfo {
		return this._boundingInfo;
	}
	
	public function getScene():Scene {
		return this._scene;
	}
	
	override inline public function getWorldMatrix():Matrix {
		if (this._currentRenderId != this._scene.getRenderId()) {
            this.computeWorldMatrix();
        }
        return this._worldMatrix;
	}
	
	public function getTotalVertices():Int {
		return this._totalVertices;
	}
	
	inline public function getAbsolutePosition():Vector3 {
		this.computeWorldMatrix();
        return this._absolutePosition;
    }
	
	// param: absolutePosition can be Array<Float> or Vector3
	public function setAbsolutePosition(absolutePosition:Dynamic = null) {
        if (absolutePosition == null) {
            return;
        }

        var absolutePositionX:Float = 0;
        var absolutePositionY:Float = 0;
        var absolutePositionZ:Float = 0;

        if (Std.is(absolutePosition, Array)) {
            if (absolutePosition.length < 3) {
                return;
            }
            absolutePositionX = absolutePosition[0];
            absolutePositionY = absolutePosition[1];
            absolutePositionZ = absolutePosition[2];
        } else {	// its Vector3
            absolutePositionX = absolutePosition.x;
            absolutePositionY = absolutePosition.y;
            absolutePositionZ = absolutePosition.z;
        }

        // worldMatrix = pivotMatrix * scalingMatrix * rotationMatrix * translateMatrix * parentWorldMatrix
        // => translateMatrix = invertRotationMatrix * invertScalingMatrix * invertPivotMatrix * worldMatrix * invertParentWorldMatrix

        // get this matrice before the other ones since
        // that will update them if they have to be updated

        var worldMatrix = this.getWorldMatrix().clone();

        worldMatrix.m[12] = absolutePositionX;
        worldMatrix.m[13] = absolutePositionY;
        worldMatrix.m[14] = absolutePositionZ;

        var invertRotationMatrix = this._localRotation.clone();
        invertRotationMatrix.invert();

        var invertScalingMatrix = this._localScaling.clone();
        invertScalingMatrix.invert();

        var invertPivotMatrix = this._pivotMatrix.clone();
        invertPivotMatrix.invert();

        var translateMatrix = invertRotationMatrix.multiply(invertScalingMatrix);

        translateMatrix.multiplyToRef(invertPivotMatrix, invertScalingMatrix); // reuse matrix
        invertScalingMatrix.multiplyToRef(worldMatrix, translateMatrix);

        if (this.parent != null) {
            var invertParentWorldMatrix = this.parent.getWorldMatrix().clone();
            invertParentWorldMatrix.invert();

            translateMatrix.multiplyToRef(invertParentWorldMatrix, invertScalingMatrix); // reuse matrix
            translateMatrix = invertScalingMatrix;
        }

        this.position.x = translateMatrix.m[12];
        this.position.y = translateMatrix.m[13];
        this.position.z = translateMatrix.m[14];
    }
	
	public function getVerticesData(kind:String):Array<Float> /*Array<Dynamic>*/ {		// TODO - Float32Array ??
		return this._vertexBuffers.get(kind).getData();
	}
	
	public function getVertexBuffer(kind:String):VertexBuffer {
        return this._vertexBuffers.get(kind);
    }
	
	public function isVerticesDataPresent(kind:String):Bool {
		if (this._vertexBuffers == null && this._delayInfo != null) {            
            return Lambda.indexOf(this._delayInfo, kind) != -1;
        }

        return this._vertexBuffers.get(kind) != null;
	}
	
	public function getVerticesDataKinds():Array<String> {
        var result:Array<String> = [];
        if (this._vertexBuffers == null && this._delayInfo != null) {
            for (kind in this._delayInfo) {
                result.push(kind);
            }
        } else {
            for (kind in this._vertexBuffers.keys()) {
                result.push(kind);
            }
        }

        return result;
    }
	
	public function getTotalIndicies():Int {
		return this._indices.length;
	}
	
	public function getIndices():Array<Int> {
		return this._indices;
	}
	
	public function getVertexStrideSize():Float {
		return this._vertexStrideSize;
	}
		
	inline public function setPivotMatrix(matrix:Matrix) {
		this._pivotMatrix = matrix;
        this._cache.pivotMatrixUpdated = true;
	}
	
	public function getPivotMatrix():Matrix {
		return this._pivotMatrix;
	}
	
	override public function isSynchronized(updateCache:Bool = false):Bool {
		if (this.billboardMode != Mesh.BILLBOARDMODE_NONE)
            return false;

        if (this._cache.pivotMatrixUpdated) {
            return false;
        }
        
        if (this.infiniteDistance) {
            return false;
        }

        if (!this._cache.position.equals(this.position))
            return false;

        if (this.rotationQuaternion != null) {
            if (!this._cache.rotationQuaternion.equals(this.rotationQuaternion))
                return false;
        } else {
            if (!this._cache.rotation.equals(this.rotation))
                return false;
        }

        if (!this._cache.scaling.equals(this.scaling))
            return false;

        return true;
	}
		
	public function isAnimated():Bool {
		return this._animationStarted;
	}
	
	public function isDisposed():Bool {
        return this._isDisposed;
    }
	
	override public function _initCache() {
		this._cache.localMatrixUpdated = false;
		this._cache.position = Vector3.Zero();
		this._cache.scaling = Vector3.Zero();
		this._cache.rotation = Vector3.Zero();
		this._cache.rotationQuaternion = new Quaternion(0, 0, 0, 0);
		this._cache.pivotMatrixUpdated = null;
	}
	
	public function markAsDirty(property:String) {
		if (property == "rotation") {
            this.rotationQuaternion = null;
        }
        this._childrenFlag = 1;
	}
	
	public inline function refreshBoudningInfo() {
		var data = this.getVerticesData(VertexBuffer.PositionKind);

        if (data == null) {
            return;
        }

        var extend = Tools.ExtractMinAndMax(data, 0, this._totalVertices);
        this._boundingInfo = new BoundingInfo(extend.minimum, extend.maximum);

        for (index in 0...this.subMeshes.length) {
            this.subMeshes[index].refreshBoundingInfo();
        }
        
        this._updateBoundingInfo();
	}
	
	public inline function _updateBoundingInfo() {
        if (this._boundingInfo != null) {
            this._scaleFactor = Math.max(this.scaling.x, this.scaling.y);
            this._scaleFactor = Math.max(this._scaleFactor, this.scaling.z);

            if (this.parent != null && Reflect.field(this.parent, "_scaleFactor") != null)
                this._scaleFactor = this._scaleFactor * Reflect.field(this.parent, "_scaleFactor");

            this._boundingInfo._update(this._worldMatrix, this._scaleFactor);

            for (subIndex in 0...this.subMeshes.length) {
                var subMesh = this.subMeshes[subIndex];

                subMesh.updateBoundingInfo(this._worldMatrix, this._scaleFactor);
            }
        }
    }
	
	public inline function computeWorldMatrix(force:Bool = false):Matrix {
		var ret = this._worldMatrix;
		if (!force && (this._currentRenderId == this._scene.getRenderId() || this.isSynchronized())) {
            this._childrenFlag = 0;
        } else {
			this._childrenFlag = 1;
			this._cache.position.copyFrom(this.position);
			this._cache.scaling.copyFrom(this.scaling);
			this._cache.pivotMatrixUpdated = false;
			this._currentRenderId = this._scene.getRenderId();

			// Scaling
			Matrix.ScalingToRef(this.scaling.x, this.scaling.y, this.scaling.z, this._localScaling);

			// Rotation
			if (this.rotationQuaternion != null) {
				this.rotationQuaternion.toRotationMatrix(this._localRotation);
				this._cache.rotationQuaternion.copyFrom(this.rotationQuaternion);
			} else {
				Matrix.RotationYawPitchRollToRef(this.rotation.y, this.rotation.x, this.rotation.z, this._localRotation);
				this._cache.rotation.copyFrom(this.rotation);
			}

			// Translation
			if (this.infiniteDistance) {
				var camera = this._scene.activeCamera;
				Matrix.TranslationToRef(this.position.x + camera.position.x, this.position.y + camera.position.y, this.position.z + camera.position.z, this._localTranslation);
			} else {
				Matrix.TranslationToRef(this.position.x, this.position.y, this.position.z, this._localTranslation);
			}

			// Composing transformations
			this._pivotMatrix.multiplyToRef(this._localScaling, this._localPivotScaling);
			this._localPivotScaling.multiplyToRef(this._localRotation, this._localPivotScalingRotation);

			// Billboarding
			if (this.billboardMode != Mesh.BILLBOARDMODE_NONE) {
				var localPosition:Vector3 = this.position.clone();
				var zero:Vector3 = this._scene.activeCamera.position.clone();

				if (this.parent != null && this.parent.position != null) {
					localPosition.addInPlace(this.parent.position);
					Matrix.TranslationToRef(localPosition.x, localPosition.y, localPosition.z, this._localTranslation);
				}

				if (this.billboardMode & Mesh.BILLBOARDMODE_ALL == Mesh.BILLBOARDMODE_ALL) {
					zero = this._scene.activeCamera.position;
				} else {
					if ((this.billboardMode & Mesh.BILLBOARDMODE_X) != 0)
						zero.x = localPosition.x + Engine.epsilon;
					if ((this.billboardMode & Mesh.BILLBOARDMODE_Y) != 0)
						zero.y = localPosition.y + Engine.epsilon;
					if ((this.billboardMode & Mesh.BILLBOARDMODE_Z) != 0)
						zero.z = localPosition.z + Engine.epsilon;
				}

				Matrix.LookAtLHToRef(localPosition, zero, Vector3.Up(), this._localBillboard);
				this._localBillboard.m[12] = this._localBillboard.m[13] = this._localBillboard.m[14] = 0;

				this._localBillboard.invert();

				this._localPivotScalingRotation.multiplyToRef(this._localBillboard, this._localWorld);
				this._rotateYByPI.multiplyToRef(this._localWorld, this._localPivotScalingRotation);
			}

			// Parent
			if (this.parent != null && this.parent.getWorldMatrix() != null && this.billboardMode == Mesh.BILLBOARDMODE_NONE) {
				this._localPivotScalingRotation.multiplyToRef(this._localTranslation, this._localWorld);
				var parentWorld = this.parent.getWorldMatrix();

				this._localWorld.multiplyToRef(parentWorld, this._worldMatrix);
			} else {
				this._localPivotScalingRotation.multiplyToRef(this._localTranslation, this._worldMatrix);
			}

			// Bounding info
			this._updateBoundingInfo();

			// Absolute position
			this._absolutePosition.copyFromFloats(this._worldMatrix.m[12], this._worldMatrix.m[13], this._worldMatrix.m[14]);
			ret = this._worldMatrix;
		}

        return ret;
	}
	
	public function _createGlobalSubMesh():SubMesh {
		if (this._totalVertices == 0 || this._indices == null) {
            return null;
        }

        this.subMeshes = [];
        return new SubMesh(0, 0, this._totalVertices, 0, this._indices.length, this);
	}
	
	public function subdivide(count:Int) {
		if (count < 1) {
            return;
        }

        var subdivisionSize:Int = Std.int(this._indices.length / count);
        var offset:Int = 0;

        this.subMeshes = [];
        for (index in 0...count) {
            SubMesh.CreateFromIndices(0, offset, Std.int(Math.min(subdivisionSize, this._indices.length - offset)), this);

            offset += subdivisionSize;
        }
	}
	
	public function setVerticesData(data:Array<Float>, kind:String, updatable:Bool) {
		if (this._vertexBuffers == null) {
            this._vertexBuffers = new Map<String, VertexBuffer>();
        }

        if (this._vertexBuffers.exists(kind)) {
            this._vertexBuffers.get(kind).dispose();
			this._vertexBuffers.remove(kind);
        }

        this._vertexBuffers.set(kind, new VertexBuffer(this, data, kind, updatable));

        if (kind == VertexBuffer.PositionKind) {
            var stride = this._vertexBuffers.get(kind).getStrideSize();
            this._totalVertices = Std.int(data.length / stride);

            var extend = Tools.ExtractMinAndMax(data, 0, this._totalVertices);
            this._boundingInfo = new BoundingInfo(extend.minimum, extend.maximum);

            this._createGlobalSubMesh();
        }
	}
	
	public function updateVerticesData(kind:String, data:Array<Float>) {
		if (this._vertexBuffers.exists(kind)) {
            this._vertexBuffers.get(kind).update(data);
        }
	}
	
	public function setIndices(indices:Array<Int>) {
		if (this._indexBuffer != null) {
            this._scene.getEngine()._releaseBuffer(this._indexBuffer);
        }

        this._indexBuffer = this._scene.getEngine().createIndexBuffer(indices);
        this._indices = indices;

        this._createGlobalSubMesh();
	}
	
	inline public function bindAndDraw(subMesh:SubMesh, effect:Effect, wireframe:Bool) {
		var engine:Engine = this._scene.getEngine();

        // Wireframe
        var indexToBind = this._indexBuffer;
        var useTriangles = true;

        if (wireframe) {
            indexToBind = subMesh.getLinesIndexBuffer(this._indices, engine);
            useTriangles = false;
        }

        // VBOs
        engine.bindMultiBuffers(this._vertexBuffers, indexToBind, effect);

        // Draw order
        engine.draw(useTriangles, useTriangles ? subMesh.indexStart : 0, useTriangles ? subMesh.indexCount : subMesh.linesIndexCount);
	}
	
	public function registerBeforeRender(func:Dynamic) {
		this._onBeforeRenderCallbacks.push(func);
	}
	
	public function unregisterBeforeRender(func:Dynamic) {
		var index = Lambda.indexOf(this._onBeforeRenderCallbacks, func);

        if (index > -1) {
            this._onBeforeRenderCallbacks.splice(index, 1);
        }
		
		//this._onBeforeRenderCallbacks.remove(func);
	}
	
	public function render(subMesh:SubMesh) {
		if (this._vertexBuffers == null || this._indexBuffer == null) {
            return;
        }
        
        for (callbackIndex in 0...this._onBeforeRenderCallbacks.length) {
            this._onBeforeRenderCallbacks[callbackIndex]();
        }
        
        // World
        var world:Matrix = this.getWorldMatrix();

        // Material
        var effectiveMaterial = subMesh.getMaterial();
        if (effectiveMaterial == null || !effectiveMaterial.isReady(this)) {
            return;
        }

		if(Std.is(effectiveMaterial, Material)) {
			effectiveMaterial._preBind();
			effectiveMaterial.bind(world, this);
		}

        // Bind and draw
        var engine:Engine = this._scene.getEngine();
        this.bindAndDraw(subMesh, effectiveMaterial.getEffect(), engine.forceWireframe || effectiveMaterial.wireframe);

        // Unbind
        effectiveMaterial.unbind();
	}
		
	public function getEmittedParticleSystems():Array<ParticleSystem> {
		var results:Array<ParticleSystem> = [];
        for (index in 0...this._scene.particleSystems.length) {
            var particleSystem = this._scene.particleSystems[index];
            if (particleSystem.emitter == this) {
                results.push(particleSystem);
            }
        }

        return results;
	}
	
	public function getHierarchyEmittedParticleSystems():Array<ParticleSystem> {
		var results:Array<ParticleSystem> = [];
        var descendants:Array<Dynamic> = this.getDescendants();
        descendants.push(this);

        for (index in 0...this._scene.particleSystems.length) {
            var particleSystem = this._scene.particleSystems[index];
            if (Lambda.indexOf(descendants, particleSystem.emitter) != -1) {
                results.push(particleSystem);
            }
        }

        return results;
	}
	
	public function getChildren():Array<Mesh> {
		var results:Array<Mesh> = [];
        for (index in 0...this._scene.meshes.length) {
            var mesh:Mesh = this._scene.meshes[index];
            if (mesh.parent == this) {
                results.push(mesh);
            }
        }

        return results;
	}
	
	public function isInFrustrum(frustumPlanes:Array<Plane>):Bool {
		if (this.delayLoadState == Engine.DELAYLOADSTATE_LOADING) {
            return false;
        }

        var result:Bool = this._boundingInfo.isInFrustrum(frustumPlanes);
        
		// TODO
        /*if (result && this.delayLoadState == Engine.DELAYLOADSTATE_NOTLOADED) {
            this.delayLoadState = Engine.DELAYLOADSTATE_LOADING;
            var that = this;

            this._scene._addPendingData(this);

            BABYLON.Tools.LoadFile(this.delayLoadingFile, function (data) {
                BABYLON.SceneLoader._ImportGeometry(JSON.parse(data), that);
                that.delayLoadState = BABYLON.Engine.DELAYLOADSTATE_LOADED;
                that._scene._removePendingData(that);
            }, function () { }, this._scene.database);
        }*/

        return result;
	}
	
	public function setMaterialByID(id:String) {
		var materials = this._scene.materials;
        for (index in 0...materials.length) {
            if (materials[index].id == id) {
                this.material = materials[index];
                return;
            }
        }

        // Multi
        var multiMaterials = this._scene.multiMaterials;
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

        return results;
	}
	
	inline public function setLocalTranslation(vector3:Vector3) {
		this.computeWorldMatrix();
        var worldMatrix = this._worldMatrix.clone();
        worldMatrix.setTranslation(Vector3.Zero());

        this.position = Vector3.TransformCoordinates(vector3, worldMatrix);
	}
	
	inline public function getLocalTranslation():Vector3 {
		this.computeWorldMatrix();
        var invWorldMatrix = this._worldMatrix.clone();
        invWorldMatrix.setTranslation(Vector3.Zero());
        invWorldMatrix.invert();

        return Vector3.TransformCoordinates(this.position, invWorldMatrix);
	}
	
	inline public function bakeTransformIntoVertices(transform:Matrix) {
		// Position
        if (this.isVerticesDataPresent(VertexBuffer.PositionKind)) {
			this._resetPointsArrayCache();

			var data = this._vertexBuffers.get(VertexBuffer.PositionKind).getData();
			var temp:Array<Float> = [];
			var index:Int = 0;
			while(index < data.length) {
				Vector3.TransformCoordinates(Vector3.FromArray(data, index), transform).toArray(temp, index);
				index += 3;
			}

			this.setVerticesData(temp, VertexBuffer.PositionKind, this._vertexBuffers.get(VertexBuffer.PositionKind).isUpdatable());

			// Normals
			if (this.isVerticesDataPresent(VertexBuffer.NormalKind)) {
				data = this._vertexBuffers[VertexBuffer.NormalKind].getData();
				index = 0;
				while(index < data.length) {
					Vector3.TransformNormal(Vector3.FromArray(data, index), transform).toArray(temp, index);
					index += 1;
				}

				this.setVerticesData(temp, VertexBuffer.NormalKind, this._vertexBuffers[VertexBuffer.NormalKind].isUpdatable());
			}			
        }        
	}

	inline public function intersectsMesh(mesh:Mesh, precise:Bool):Bool {
		var ret = false;
		if (this._boundingInfo == null || mesh._boundingInfo == null) {
            ret = false;
        } else {
			ret = this._boundingInfo.intersects(mesh._boundingInfo, precise);
		}
		return ret;
	}
	
	inline public function intersectsPoint(point:Vector3):Bool {
		var ret = false;
		if (this._boundingInfo != null) {
            ret = this._boundingInfo.intersectsPoint(point);
        }
        return ret;
	}
	
	public function intersects(ray:Ray, fastCheck:Bool):PickingInfo {
		var pickingInfo = new PickingInfo();

        if (this._boundingInfo == null || !ray.intersectsSphere(this._boundingInfo.boundingSphere) || !ray.intersectsBox(this._boundingInfo.boundingBox)) {
            return pickingInfo;
        }

        this._generatePointsArray();

        var distance:Float = Math.POSITIVE_INFINITY;

        for (index in 0...this.subMeshes.length) {
            var subMesh = this.subMeshes[index];

            // Bounding test
            if (this.subMeshes.length > 1 && !subMesh.canIntersects(ray))
                continue;

            var currentDistance = subMesh.intersects(ray, this._positions, this._indices, fastCheck);

            if (currentDistance > 0) {
                if (fastCheck || currentDistance < distance) {
                    distance = currentDistance;

                    if (fastCheck) {
                        break;
                    }
                }
            }
        }

        if (distance >= 0 && distance < Math.POSITIVE_INFINITY) {
            // Get picked point
            var world:Matrix = this.getWorldMatrix();
            var worldOrigin:Vector3 = Vector3.TransformCoordinates(ray.origin, world);
            var direction:Vector3 = ray.direction.clone();
            direction.normalize();
            direction = direction.scale(distance);
            var worldDirection:Vector3 = Vector3.TransformNormal(direction, world);

            var pickedPoint:Vector3 = worldOrigin.add(worldDirection);

            // Return result
            pickingInfo.hit = true;
            pickingInfo.distance = Vector3.Distance(worldOrigin, pickedPoint);
            pickingInfo.pickedPoint = pickedPoint;
            pickingInfo.pickedMesh = this;
            return pickingInfo;
        }

        return pickingInfo;
	}
	
	public function clone(name:String, newParent:Mesh, doNotCloneChildren:Bool = false):Mesh {
		var result:Mesh = new Mesh(name, this._scene);

        // Buffers
        result._vertexBuffers = this._vertexBuffers;
        for (kind in result._vertexBuffers.keys()) {
            result._vertexBuffers.get(kind)._buffer.references++;
        }

        result._indexBuffer = this._indexBuffer;
        this._indexBuffer.references++;

        // Deep copy
        Tools.DeepCopy(this, result, ["name", "material", "skeleton"], ["_indices", "_totalVertices"]);		

        // Bounding info
        var extend = Tools.ExtractMinAndMax(this.getVerticesData(VertexBuffer.PositionKind), 0, this._totalVertices);
        result._boundingInfo = new BoundingInfo(extend.minimum, extend.maximum);

        // Material
        result.material = this.material;

        // Parent
        if (newParent != null) {
            result.parent = newParent;
        }

        if (!doNotCloneChildren) {
            // Children
            for (index in 0...this._scene.meshes.length) {
                var mesh = this._scene.meshes[index];

                if (mesh.parent == this) {
                    mesh.clone(mesh.name, result);
                }
            }
        }

        // Particles
        for (index in 0...this._scene.particleSystems.length) {
            var system = this._scene.particleSystems[index];

            if (system.emitter == this) {
                system.clone(system.name, result);
            }
        }

        return result;
	}

	public function dispose(doNotRecurse:Bool = false) {
		if (this._vertexBuffers != null) {
            for (key in this._vertexBuffers.keys()) {
                this._vertexBuffers.get(key).dispose();
				this._vertexBuffers.remove(key);
            }
            this._vertexBuffers = null;
        }

        if (this._indexBuffer != null) {
            this._scene.getEngine()._releaseBuffer(this._indexBuffer);
            this._indexBuffer = null;
        }

        // Remove from scene
        //var index = this._scene.meshes.indexOf(this);
        //this._scene.meshes.splice(index, 1);
		this._scene.meshes.remove(this);

        if (!doNotRecurse) {
            // Particles
			var index:Int = 0;
			while(index < this._scene.particleSystems.length) {
                if (this._scene.particleSystems[index].emitter == this) {
                    this._scene.particleSystems[index].dispose();
                    index--;
                }
				index++;
            }

            // Children
            var objects = this._scene.meshes.slice(0);
            for (index in 0...objects.length) {
                if (objects[index].parent == this) {
                    objects[index].dispose();
                }
            }
        }

        this._isDisposed = true;

        // Callback
        if (this.onDispose != null) {
            this.onDispose();
        }
	}
	
	
	// Physics
    /*public function setPhysicsState(options) {
        if (this._scene._physicsEngine == null) {
            return;
        }

        options.impostor = options.impostor || BABYLON.PhysicsEngine.NoImpostor;
        options.mass = options.mass || 0;
        options.friction = options.friction || 0.0;
        options.restitution = options.restitution || 0.9;

        this._physicImpostor = options.impostor;
        this._physicsMass = options.mass;
        this._physicsFriction = options.friction;
        this._physicRestitution = options.restitution;

        if (options.impostor === BABYLON.PhysicsEngine.NoImpostor) {
            this._scene._physicsEngine._unregisterMesh(this);
            return;
        }
        
        this._scene._physicsEngine._registerMesh(this, options);
    }

    public function getPhysicsImpostor() {
        if (!this._physicImpostor) {
            return BABYLON.PhysicsEngine.NoImpostor;
        }

        return this._physicImpostor;
    }

    public function getPhysicsMass() {
        if (!this._physicsMass) {
            return 0;
        }

        return this._physicsMass;
    }
    
    public function getPhysicsFriction() {
        if (!this._physicsFriction) {
            return 0;
        }

        return this._physicsFriction;
    }
    
    public function getPhysicsRestitution() {
        if (!this._physicRestitution) {
            return 0;
        }

        return this._physicRestitution;
    }

    public function applyImpulse(force, contactPoint) {
        if (!this._physicImpostor) {
            return;
        }

        this._scene._physicsEngine._applyImpulse(this, force, contactPoint);
    }

	public function setPhysicsLinkWith(otherMesh, pivot1, pivot2) {
        if (!this._physicImpostor) {
            return;
        }
        
        this._scene._physicsEngine._createLink(this, otherMesh, pivot1, pivot2);
    }*/
	
	// Geometric tools
	public function convertToFlatShadedMesh() {
        /// <summary>Update normals and vertices to get a flat shading rendering.</summary>
        /// <summary>Warning: This may imply adding vertices to the mesh in order to get exactly 3 vertices per face</summary>

        var kinds:Array<String> = this.getVerticesDataKinds();
        var vbs:Map<String, VertexBuffer> = new Map();
        var data:Map<String, Array<Float>> = new Map();
        var newdata:Map<String, Array<Float>> = new Map();
        var updatableNormals:Bool = false;
		for(kindIndex in 0...kinds.length) {
            var kind = kinds[kindIndex];

            if (kind == VertexBuffer.NormalKind) {
                updatableNormals = this.getVertexBuffer(kind).isUpdatable();
                kinds.remove(kind);
                continue;
            }
		}
		for(kind in kinds) {
            vbs.set(kind, this.getVertexBuffer(kind));
            data.set(kind, vbs.get(kind).getData());
            newdata.set(kind, []);
        }

        // Save previous submeshes
        var previousSubmeshes:Array<SubMesh> = this.subMeshes.slice(0);

        var indices:Array<Int> = this.getIndices();

        // Generating unique vertices per face
        for (index in 0...indices.length) {
            var vertexIndex:Int = indices[index];

            for (kindIndex in 0...kinds.length) {
                var kind = kinds[kindIndex];
                var stride = vbs.get(kind).getStrideSize();

                for (offset in 0...stride) {
                    newdata[kind].push(data[kind][vertexIndex * stride + offset]);
                }
            }
        }

        // Updating faces & normal
        var normals:Array<Float> = [];
        var positions = newdata[VertexBuffer.PositionKind];
		var index:Int = 0;
		while(index < indices.length) {
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
        this.setVerticesData(normals, VertexBuffer.NormalKind, updatableNormals);

        // Updating vertex buffers
        for (kindIndex in 0...kinds.length) {
            var kind:String = kinds[kindIndex];
            this.setVerticesData(newdata.get(kind), kind, vbs.get(kind).isUpdatable());
        }

        // Updating submeshes
        this.subMeshes = [];
        for (submeshIndex in 0...previousSubmeshes.length) {
            var previousOne:SubMesh = previousSubmeshes[submeshIndex];
            var subMesh = new SubMesh(previousOne.materialIndex, previousOne.indexStart, previousOne.indexCount, previousOne.indexStart, previousOne.indexCount, this);
        }
    }
	
	// Statics
	public static function CreateBox(name:String, size:Float, scene:Scene, updatable:Bool = false):Mesh {
		var box:Mesh = new Mesh(name, scene);

        var normalsSource:Array<Vector3> = [
            new Vector3(0, 0, 1),
            new Vector3(0, 0, -1),
            new Vector3(1, 0, 0),
            new Vector3(-1, 0, 0),
            new Vector3(0, 1, 0),
            new Vector3(0, -1, 0)
        ];

        var indices:Array<Int> = [];
        var positions:Array<Float> = [];
        var normals:Array<Float> = [];
        var uvs:Array<Float> = [];

        // Create each face in turn.
        for (index in 0...normalsSource.length) {
            var normal:Vector3 = normalsSource[index];

            // Get two vectors perpendicular to the face normal and to each other.
            var side1:Vector3 = new Vector3(normal.y, normal.z, normal.x);
            var side2:Vector3 = Vector3.Cross(normal, side1);

            // Six indices (two triangles) per face.
            var verticesLength:Int = Std.int(positions.length / 3);
            indices.push(verticesLength);
            indices.push(verticesLength + 1);
            indices.push(verticesLength + 2);

            indices.push(verticesLength);
            indices.push(verticesLength + 2);
            indices.push(verticesLength + 3);

            // Four vertices per face.
            var vertex:Vector3 = normal.subtract(side1).subtract(side2).scale(size / 2);
            positions.push(vertex.x);
			positions.push(vertex.y);
			positions.push(vertex.z);
            normals.push(normal.x);
			normals.push(normal.y);
			normals.push(normal.z);
            uvs.push(1.0);
			uvs.push(1.0);

            vertex = normal.subtract(side1).add(side2).scale(size / 2);
            positions.push(vertex.x);
			positions.push(vertex.y);
			positions.push(vertex.z);
            normals.push(normal.x);
			normals.push(normal.y);
			normals.push(normal.z);
            uvs.push(0.0);
			uvs.push(1.0);

            vertex = normal.add(side1).add(side2).scale(size / 2);
            positions.push(vertex.x);
			positions.push(vertex.y);
			positions.push(vertex.z);
            normals.push(normal.x);
			normals.push(normal.y);
			normals.push(normal.z);
            uvs.push(0.0);
			uvs.push(0.0);

            vertex = normal.add(side1).subtract(side2).scale(size / 2);
            positions.push(vertex.x);
			positions.push(vertex.y);
			positions.push(vertex.z);
            normals.push(normal.x);
			normals.push(normal.y);
			normals.push(normal.z);
            uvs.push(1.0);
			uvs.push(0.0);
        }

        box.setVerticesData(positions, VertexBuffer.PositionKind, updatable);
        box.setVerticesData(normals, VertexBuffer.NormalKind, updatable);
        box.setVerticesData(uvs, VertexBuffer.UVKind, updatable);
        box.setIndices(indices);

        return box;
	}
	
	public static function CreateCylinder(name:String, height:Float, diameterTop:Float, diameterBottom:Float, tessellation:Int, scene:Scene, updatable:Bool):Mesh {
		var radiusTop:Float = diameterTop / 2;
        var radiusBottom:Float = diameterBottom / 2;
        
		var indices:Array<Int> = [];
        var positions:Array<Float> = [];
        var normals:Array<Float> = [];
        var uvs:Array<Float> = [];
		
        var cylinder:Mesh = new Mesh(name, scene);

        function getCircleVector(i:Int):Vector3 {
            var angle = (i * 2 * Math.PI / tessellation);
            var dx = Math.sin(angle);
            var dz = Math.cos(angle);

            return new Vector3(dx, 0, dz);
        }

        function createCylinderCap(isTop:Bool) {
            var radius:Float = isTop ? radiusTop : radiusBottom;
            
            if (radius == 0) {
                return;
            }

            // Create cap indices.
            for (i in 0...tessellation - 2) {
                var i1 = (i + 1) % tessellation;
                var i2 = (i + 2) % tessellation;

                if (!isTop) {
                    var tmp = i1;
                    var i1 = i2;
                    i2 = tmp;
                }

                var vbase = Std.int(positions.length / 3);
                indices.push(vbase);
                indices.push(vbase + i1);
                indices.push(vbase + i2);
            }


            // Which end of the cylinder is this?
            var normal = new Vector3(0, -1, 0);
            var textureScale = new Vector2(-0.5, -0.5);

            if (!isTop) {
                normal = normal.scale(-1);
                textureScale.x = -textureScale.x;
            }

            // Create cap vertices.
            for (i in 0...tessellation) {
                var circleVector = getCircleVector(i);
                var position = circleVector.scale(radius).add(normal.scale(height));
                var textureCoordinate = new Vector2(circleVector.x * textureScale.x + 0.5, circleVector.z * textureScale.y + 0.5);

                positions.push(position.x);
				positions.push(position.y);
				positions.push(position.z);
                normals.push(normal.x);
				normals.push(normal.y);
				normals.push(normal.z);
                uvs.push(textureCoordinate.x);
				uvs.push(textureCoordinate.y);
            }
        }

        height /= 2;

        var topOffset:Vector3 = new Vector3(0, 1, 0).scale(height);

        var stride = tessellation + 1;

        // Create a ring of triangles around the outside of the cylinder.
        for (i in 0...tessellation+1) {
            var normal = getCircleVector(i);
            var sideOffsetBottom = normal.scale(radiusBottom);
            var sideOffsetTop = normal.scale(radiusTop);
            var textureCoordinate = new Vector2(i / tessellation, 0);

            var position = sideOffsetBottom.add(topOffset);
            positions.push(position.x);
			positions.push(position.y);
			positions.push(position.z);
            normals.push(normal.x);
			normals.push(normal.y);
			normals.push(normal.z);
            uvs.push(textureCoordinate.x);
			uvs.push(textureCoordinate.y);

            position = sideOffsetTop.subtract(topOffset);
            textureCoordinate.y += 1;
            positions.push(position.x);
			positions.push(position.y);
			positions.push(position.z);
            normals.push(normal.x);
			normals.push(normal.y);
			normals.push(normal.z);
            uvs.push(textureCoordinate.x);
			uvs.push(textureCoordinate.y);

            indices.push(i * 2);
            indices.push((i * 2 + 2) % (stride * 2));
            indices.push(i * 2 + 1);

            indices.push(i * 2 + 1);
            indices.push((i * 2 + 2) % (stride * 2));
            indices.push((i * 2 + 3) % (stride * 2));
        }

        // Create flat triangle fan caps to seal the top and bottom.
        createCylinderCap(true);
        createCylinderCap(false);

        cylinder.setVerticesData(positions, VertexBuffer.PositionKind, updatable);
        cylinder.setVerticesData(normals, VertexBuffer.NormalKind, updatable);
        cylinder.setVerticesData(uvs, VertexBuffer.UVKind, updatable);
        cylinder.setIndices(indices);

        return cylinder;
	}
	
	public static function CreateTorus(name:String, diameter:Float, thickness:Float, tessellation:Int, scene:Scene, updatable:Bool):Mesh {
		var torus:Mesh = new Mesh(name, scene);

        var indices:Array<Int> = [];
        var positions:Array<Float> = [];
        var normals:Array<Float> = [];
        var uvs:Array<Float> = [];

        var stride = tessellation + 1;

        for (i in 0...tessellation+1) {
            var u:Float = i / tessellation;

            var outerAngle:Float = i * Math.PI * 2.0 / tessellation - Math.PI / 2.0;

            var transform = Matrix.Translation(diameter / 2.0, 0, 0).multiply(Matrix.RotationY(outerAngle));

            for (j in 0...tessellation+1) {
                var v = 1 - j / tessellation;

                var innerAngle = j * Math.PI * 2.0 / tessellation + Math.PI;
                var dx = Math.cos(innerAngle);
                var dy = Math.sin(innerAngle);

                // Create a vertex.
                var normal = new Vector3(dx, dy, 0);
                var position:Vector3 = normal.scale(thickness / 2);
                var textureCoordinate = new Vector2(u, v);

                position = Vector3.TransformCoordinates(position, transform);
                normal = Vector3.TransformNormal(normal, transform);

                positions.push(position.x);
				positions.push(position.y);
				positions.push(position.z);
                normals.push(normal.x);
				normals.push(normal.y);
				normals.push(normal.z);
                uvs.push(textureCoordinate.x);
				uvs.push(textureCoordinate.y);

                // And create indices for two triangles.
                var nextI = (i + 1) % stride;
                var nextJ = (j + 1) % stride;

                indices.push(i * stride + j);
                indices.push(i * stride + nextJ);
                indices.push(nextI * stride + j);

                indices.push(i * stride + nextJ);
                indices.push(nextI * stride + nextJ);
                indices.push(nextI * stride + j);
            }
        }

        torus.setVerticesData(positions, VertexBuffer.PositionKind, updatable);
        torus.setVerticesData(normals, VertexBuffer.NormalKind, updatable);
        torus.setVerticesData(uvs, VertexBuffer.UVKind, updatable);
        torus.setIndices(indices);

        return torus;
	}
	
	public static function CreateSphere(name:String, segments:Int, diameter:Float, scene:Scene, updatable:Bool = false):Mesh {
		var sphere:Mesh = new Mesh(name, scene);
		
        var radius:Float = diameter / 2;

        var totalZRotationSteps:Int = 2 + segments;
        var totalYRotationSteps:Int = 2 * totalZRotationSteps;

        var indices:Array<Int> = [];
        var positions:Array<Float> = [];
        var normals:Array<Float> = [];
        var uvs:Array<Float> = [];

        for (zRotationStep in 0...totalZRotationSteps+1) {
            var normalizedZ:Float = zRotationStep / totalZRotationSteps;
            var angleZ:Float = (normalizedZ * Math.PI);

            for (yRotationStep in 0...totalYRotationSteps+1) {
                var normalizedY:Float = yRotationStep / totalYRotationSteps;

                var angleY:Float = normalizedY * Math.PI * 2;

                var rotationZ = Matrix.RotationZ(-angleZ);
                var rotationY = Matrix.RotationY(angleY);
                var afterRotZ = Vector3.TransformCoordinates(Vector3.Up(), rotationZ);
                var complete = Vector3.TransformCoordinates(afterRotZ, rotationY);

                var vertex = complete.scale(radius);
                var normal = Vector3.Normalize(vertex);

                positions.push(vertex.x);
				positions.push(vertex.y);
				positions.push(vertex.z);
                normals.push(normal.x);
				normals.push(normal.y);
				normals.push(normal.z);
                uvs.push(normalizedZ);
				uvs.push(normalizedY);
            }

            if (zRotationStep > 0) {
                var verticesCount = positions.length / 3;
				var firstIndex:Int = Std.int(verticesCount - 2 * (totalYRotationSteps + 1));
				while((firstIndex + totalYRotationSteps + 2) < verticesCount) {                
                    indices.push((firstIndex));
                    indices.push((firstIndex + 1));
                    indices.push(firstIndex + totalYRotationSteps + 1);

                    indices.push((firstIndex + totalYRotationSteps + 1));
                    indices.push((firstIndex + 1));
                    indices.push((firstIndex + totalYRotationSteps + 2));
					
					firstIndex++;
                }
            }
        }

        sphere.setVerticesData(positions, VertexBuffer.PositionKind, updatable);
        sphere.setVerticesData(normals, VertexBuffer.NormalKind, updatable);
        sphere.setVerticesData(uvs, VertexBuffer.UVKind, updatable);
        sphere.setIndices(indices);
		
        return sphere;
	}
	
	public static function CreatePlane(name:String, size:Float, scene:Scene, updatable:Bool):Mesh {
		var plane:Mesh = new Mesh(name, scene);

        var indices:Array<Int> = [];
        var positions:Array<Float> = [];
        var normals:Array<Float> = [];
        var uvs:Array<Float> = [];

        // Vertices
        var halfSize:Float = size / 2.0;
        positions.push( -halfSize);
		positions.push( -halfSize);
		positions.push(0);
        normals.push(0);
		normals.push(0);
		normals.push(-1.0);
        uvs.push(0.0);
		uvs.push(0.0);

        positions.push(halfSize);
		positions.push( -halfSize);
		positions.push(0);
        normals.push(0);
		normals.push(0);
		normals.push( -1.0);
        uvs.push(1.0);
		uvs.push(0.0);

        positions.push(halfSize);
		positions.push(halfSize);
		positions.push(0);
        normals.push(0);
		normals.push(0);
		normals.push(-1.0);
        uvs.push(1.0);
		uvs.push(1.0);

        positions.push( -halfSize);
		positions.push(halfSize);
		positions.push(0);
        normals.push(0);
		normals.push(0);
		normals.push(-1.0);
        uvs.push(0.0);
		uvs.push(1.0);

        // Indices
        indices.push(0);
        indices.push(1);
        indices.push(2);

        indices.push(0);
        indices.push(2);
        indices.push(3);

        plane.setVerticesData(positions, VertexBuffer.PositionKind, updatable);
        plane.setVerticesData(normals, VertexBuffer.NormalKind, updatable);
        plane.setVerticesData(uvs, VertexBuffer.UVKind, updatable);
        plane.setIndices(indices);

        return plane;
	}
	
	public static function CreateGround(name:String, width:Float, height:Float, subdivisions:Int, scene:Scene, updatable:Bool):Mesh {
		var ground:Mesh = new Mesh(name, scene);

        var indices:Array<Int> = [];
        var positions:Array<Float> = [];
        var normals:Array<Float> = [];
        var uvs:Array<Float> = [];

        for (row in 0...subdivisions+1) {
            for (col in 0...subdivisions) {
                var position = new Vector3((col * width) / subdivisions - (width / 2.0), 0, ((subdivisions - row) * height) / subdivisions - (height / 2.0));
                var normal = new Vector3(0, 1.0, 0);

                positions.push(position.x);
				positions.push(position.y);
				positions.push(position.z);
                normals.push(normal.x);
				normals.push(normal.y);
				normals.push(normal.z);
                uvs.push(col / subdivisions);
				uvs.push(1.0 - row / subdivisions);
            }
        }

        for (row in 0...subdivisions) {
            for (col in 0...subdivisions) {
                indices.push(col + 1 + (row + 1) * (subdivisions + 1));
                indices.push(col + 1 + row * (subdivisions + 1));
                indices.push(col + row * (subdivisions + 1));

                indices.push(col + (row + 1) * (subdivisions + 1));
                indices.push(col + 1 + (row + 1) * (subdivisions + 1));
                indices.push(col + row * (subdivisions + 1));
            }
        }

        ground.setVerticesData(positions, VertexBuffer.PositionKind, updatable);
        ground.setVerticesData(normals, VertexBuffer.NormalKind, updatable);
        ground.setVerticesData(uvs, VertexBuffer.UVKind, updatable);
        ground.setIndices(indices);

        return ground;
	}
	
	public static function CreateGroundFromHeightMap(name:String, url:String, width:Float, height:Float, subdivisions:Int, minHeight:Float, maxHeight:Float, scene:Scene, updatable:Bool):Mesh {
		var ground:Mesh = new Mesh(name, scene);

        function onload(img:BitmapData) {
            var indices:Array<Int> = [];
            var positions:Array<Float> = [];
            var normals:Array<Float> = [];
            var uvs:Array<Float> = [];
            
            // Getting height map data
            var heightMapWidth = img.width;
            var heightMapHeight = img.height;
            
            #if html5
			var buffer = img.getPixels(img.rect).byteView;
			#else
			var buffer = BitmapData.getRGBAPixels(img);
			#end
						
            // Vertices
            for (row in 0...subdivisions+1) {
                for (col in 0...subdivisions+1) {
                    var position = new Vector3((col * width) / subdivisions - (width / 2.0), 0, ((subdivisions - row) * height) / subdivisions - (height / 2.0));

                    // Compute height
                    var heightMapX:Float = (((position.x + width / 2) / width) * (heightMapWidth - 1));
                    var heightMapY:Float = ((1.0 - (position.z + height / 2) / height) * (heightMapHeight - 1));

                    var pos:Int = Std.int((heightMapX + heightMapY * heightMapWidth) * 4);
                    var r = buffer[pos] / 255.0;
                    var g = buffer[pos + 1] / 255.0;
                    var b = buffer[pos + 2] / 255.0;
					
                    var gradient = r * 0.3 + g * 0.59 + b * 0.11;

                    position.y = minHeight + (maxHeight - minHeight) * gradient;

                    // Add  vertex
                    positions.push(position.x);
					positions.push(position.y);
					positions.push(position.z);
                    normals.push(0);
					normals.push(0);
					normals.push(0);
                    uvs.push(col / subdivisions);
					uvs.push(1.0 - row / subdivisions);
                }
            }

            // Indices
            for (row in 0...subdivisions) {
                for (col in 0...subdivisions) {
                    indices.push(col + 1 + (row + 1) * (subdivisions + 1));
                    indices.push(col + 1 + row * (subdivisions + 1));
                    indices.push(col + row * (subdivisions + 1));

                    indices.push(col + (row + 1) * (subdivisions + 1));
                    indices.push(col + 1 + (row + 1) * (subdivisions + 1));
                    indices.push(col + row * (subdivisions + 1));
                }
            }

            // Normals
            Mesh.ComputeNormal(positions, normals, indices);
			
			trace(positions.length);
			trace(normals.length);
			trace(indices.length);

            // Transfer
            ground.setVerticesData(positions, VertexBuffer.PositionKind, updatable);
            ground.setVerticesData(normals, VertexBuffer.NormalKind, updatable);
            ground.setVerticesData(uvs, VertexBuffer.UVKind, updatable);
            ground.setIndices(indices);

            ground._isReady = true;
        }

        Tools.LoadImage(url, onload);

        //ground._isReady = false;

        return ground;
	}
	
	public static function ComputeNormal(positions:Array<Float>, normals:Array<Float>, indices:Array<Int>) {
		var positionVectors:Array<Vector3> = [];
        var facesOfVertices:Array<Array<Int>> = [];
		
        var index:Int = 0;

		while(index < positions.length) {
            var vector3 = new Vector3(positions[index], positions[index + 1], positions[index + 2]);
            positionVectors.push(vector3);
            facesOfVertices.push([]);
			index += 3;
        }
		
        // Compute normals
        var facesNormals:Array<Vector3> = [];
        for (index in 0...Std.int(indices.length / 3)) {
            var i1 = indices[index * 3];
            var i2 = indices[index * 3 + 1];
            var i3 = indices[index * 3 + 2];

            var p1 = positionVectors[i1];
            var p2 = positionVectors[i2];
            var p3 = positionVectors[i3];

            var p1p2 = p1.subtract(p2);
            var p3p2 = p3.subtract(p2);

            facesNormals[index] = Vector3.Normalize(Vector3.Cross(p1p2, p3p2));
            facesOfVertices[i1].push(index);
            facesOfVertices[i2].push(index);
            facesOfVertices[i3].push(index);
        }

        for (index in 0...positionVectors.length) {
            var faces:Array<Int> = facesOfVertices[index];

            var normal:Vector3 = Vector3.Zero();
            for (faceIndex in 0...faces.length) {
                normal.addInPlace(facesNormals[faces[faceIndex]]);
            }

            normal = Vector3.Normalize(normal.scale(1.0 / faces.length));

            normals[index * 3] = normal.x;
            normals[index * 3 + 1] = normal.y;
            normals[index * 3 + 2] = normal.z;
        }
	}
	
}
