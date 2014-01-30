package com.gamestudiohx.babylonhx.materials;

import com.gamestudiohx.babylonhx.Engine;
import com.gamestudiohx.babylonhx.mesh.Mesh;
import com.gamestudiohx.babylonhx.Scene;
import com.gamestudiohx.babylonhx.tools.math.Matrix;


/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class Material {
	
	public var name:String;
	public var id:String;
	
	public var _renderId:Int;
	private var _scene:Scene;
	
	// Members
    public var checkReadyOnEveryCall:Bool;
    public var checkReadyOnlyOnce:Bool;
    public var alpha:Float;
    public var wireframe:Bool;
    public var backFaceCulling:Bool;
    public var _effect:Effect;
    public var _wasPreviouslyReady:Bool;

    public var onDispose:Void->Void;

	public function new(name:String, scene:Scene) {
		this.name = name;
        this.id = name;
        
        this._scene = scene;
        scene.materials.push(this);
		
		// Members
		this.checkReadyOnEveryCall = true;
		this.checkReadyOnlyOnce = false;
		this.alpha = 1.0;
		this.wireframe = false;
		this.backFaceCulling = true;
		this._effect = null;
		this._wasPreviouslyReady = false;

		this.onDispose = null;
	}
	
	public function isReady(mesh:Mesh = null):Bool {		// to be overriden
        return true;
    }
	
	public function getEffect():Effect {
        return this._effect;
    }
	
	public function needAlphaBlending():Bool {
        return (this.alpha < 1.0);
    }
	
	public function needAlphaTesting():Bool {
        return false;
    }
	
	public function _preBind() {
        var engine:Engine = this._scene.getEngine();
        
        engine.enableEffect(this._effect);
        engine.setState(this.backFaceCulling);
    }
	
	public function bind(world:Matrix, mesh:Mesh) { 		// to be overriden
		
    }
	
	public function unbind() {								// to be overriden
		
	}
	
	public function baseDispose() {
        // Remove from scene
        var index = Lambda.indexOf(this._scene.materials, this);
        this._scene.materials.splice(index, 1);
		//this._scene.materials.remove(this);

        // Callback
        if (this.onDispose != null) {
            this.onDispose();
        }
    }
	
	public function dispose() {
        this.baseDispose();
    }
	
}
