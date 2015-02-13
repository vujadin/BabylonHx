package com.babylonhx.materials;

import com.babylonhx.ISmartArrayCompatible;
import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.materials.textures.RenderTargetTexture;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.tools.SmartArray;
import com.babylonhx.math.Matrix;
import com.babylonhx.mesh.Mesh;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Material') class Material implements ISmartArrayCompatible {
	
	public static var TriangleFillMode:Int = 0;
	public static var WireFrameFillMode:Int = 1;
	public static var PointFillMode:Int = 2;


	public var id:String;
	public var name:String;
	public var checkReadyOnEveryCall:Bool = true;
	public var checkReadyOnlyOnce:Bool = false;
	public var state:String = "";
	public var alpha:Float = 1.0;
	public var backFaceCulling:Bool = true;
	public var onCompiled:Effect->Void;
	public var onError:Effect->String->Void;
	public var onDispose:Void->Void;
	public var onBind:Material->Void;
	public var getRenderTargetTextures:Void->SmartArray; // SmartArray<RenderTargetTexture>;
	
	public var __smartArrayFlags:Array<Int>;

	public var _effect:Effect;
	public var _wasPreviouslyReady:Bool = false;
	private var _scene:Scene;
	private var _fillMode:Int = Material.TriangleFillMode;

	public var pointSize:Float = 1.0;

	public var wireframe(get, set):Bool;
	private function get_wireframe():Bool {
		return this._fillMode == Material.WireFrameFillMode;
	}
	private function set_wireframe(value:Bool):Bool {
		this._fillMode = (value ? Material.WireFrameFillMode : Material.TriangleFillMode);
		return value;
	}

	public var pointsCloud(get, set):Bool;
	private function get_pointsCloud():Bool {
		return this._fillMode == Material.PointFillMode;
	}
	private function set_pointsCloud(value:Bool):Bool {
		this._fillMode = (value ? Material.PointFillMode : Material.TriangleFillMode);
		return value;
	}

	public var fillMode(get, set):Int;
	private function get_fillMode():Int {
		return this._fillMode;
	}
	private function set_fillMode(value:Int):Int {
		this._fillMode = value;
		return value;
	}

	public function new(name:String, scene:Scene, doNotAdd:Bool = false) {
		this.id = name;
		this.name = name;
		
		this._scene = scene;
		
		if (!doNotAdd) {
			scene.materials.push(this);
		}
	}

	public function isReady(?mesh:AbstractMesh, useInstances:Bool = false):Bool {
		return true;
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

	public function trackCreation(onCompiled:Effect->Void, onError:Effect->String->Void) {
		
	}

	public function _preBind():Void {
		var engine = this._scene.getEngine();
		
		engine.enableEffect(this._effect);
		engine.setState(this.backFaceCulling);
	}

	public function bind(world:Matrix, ?mesh:Mesh) {
		this._scene._cachedMaterial = this;
		
        if (this.onBind != null) {
            this.onBind(this);
        }
	}

	public function bindOnlyWorldMatrix(world:Matrix) {
	}

	public function unbind():Void {
	}

	public function dispose(forceDisposeEffect:Bool = false) {
		// Remove from scene
		this._scene.materials.remove(this);
		
		// Shader are kept in cache for further use but we can get rid of this by using forceDisposeEffect
		if (forceDisposeEffect && this._effect != null) {
			this._scene.getEngine()._releaseEffect(this._effect);
			this._effect = null;
		}
		
		// Callback
		if (this.onDispose != null) {
			this.onDispose();
		}
	}
	
}
