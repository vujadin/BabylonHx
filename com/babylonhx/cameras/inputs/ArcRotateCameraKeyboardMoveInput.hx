package com.babylonhx.cameras.inputs;

import com.babylonhx.utils.Keycodes;

/**
 * ...
 * @author Krtolica Vujadin
 */
class ArcRotateCameraKeyboardMoveInput implements ICameraInput {

	public var camera:ArcRotateCamera;
	private var _keys:Int = [];
	private var _onKeyDown:Int->Void = function(keycode:Int) { };
	private var _onKeyUp:Int->Void = function(keycode:Int) { };
	private var _onLostFocus:Void->Void;
	
	@serialize()
	public var keysUp:Array<Int> = [Keycodes.up];

	@serialize()
	public var keysDown:Array<Int> = [Keycodes.down];

	@serialize()
	public var keysLeft:Array<Int> = [Keycodes.left];

	@serialize()
	public var keysRight:Array<Int> = [Keycodes.right];
	
	
	public function new() {
		// ...
	}

	public function attachControl() {
		element.tabIndex = 1;
		
		this._onKeyDown = function(keyCode:Int) {
			if (this.keysUp.indexOf(keyCode) != -1 ||
				this.keysDown.indexOf(keyCode) != -1 ||
				this.keysLeft.indexOf(keyCode) != -1 ||
				this.keysRight.indexOf(keyCode) != -1) {
				var index = this._keys.indexOf(keyCode);
				
				if (index == -1) {
					this._keys.push(keyCode);
				}
			}
		};
		
		this._onKeyUp = function(keyCode:Int) {
			if (this.keysUp.indexOf(keyCode) != -1 ||
				this.keysDown.indexOf(keyCode) != -1 ||
				this.keysLeft.indexOf(keyCode) != -1 ||
				this.keysRight.indexOf(keyCode) != -1) {
				var index = this._keys.indexOf(keyCode);
				
				if (index >= 0) {
					this._keys.splice(index, 1);
				}
			}
		};
		
		this._onLostFocus = function() {
			this._keys = [];
		};
		
		#if !mobile
		this.camera.getScene().getEngine().keyDown.push(this._onKeyDown);
		this.camera.getScene().getEngine().keyUp.push(this._onKeyUp);
		#end
		
		#if purejs
		com.babylonhx.tools.Tools.RegisterTopRootEvents([
			{ name: "keydown", handler: this._onKeyDown },
			{ name: "keyup", handler: this._onKeyUp },
			{ name: "blur", handler: this._onLostFocus }
		]);
		#end
	}

	public function detachControl() {
		#if purejs
		com.babylonhx.tools.Tools.UnregisterTopRootEvents([
			{ name: "keydown", handler: this._onKeyDown },
			{ name: "keyup", handler: this._onKeyUp },
			{ name: "blur", handler: this._onLostFocus }
		]);
		#end
		
		#if !mobile
		this.camera.getScene().getEngine().keyDown.remove(this._onKeyDown);
		this.camera.getScene().getEngine().keyUp.remove(this._onKeyUp);
		#end
		
		this._keys = [];
		this._onKeyDown = null;
		this._onKeyUp = null;
		this._onLostFocus = null;
	}

	public function checkInputs() {
		if (this._onKeyDown != null) {
			var camera = this.camera;
			
			for (index in 0...this._keys.length) {
				var keyCode = this._keys[index];
				if (this.keysLeft.indexOf(keyCode) != -1) {
					camera.inertialAlphaOffset -= 0.01;
				} 
				else if (this.keysUp.indexOf(keyCode) != -1) {
					camera.inertialBetaOffset -= 0.01;
				} 
				else if (this.keysRight.indexOf(keyCode) != -1) {
					camera.inertialAlphaOffset += 0.01;
				} 
				else if (this.keysDown.indexOf(keyCode) != -1) {
					camera.inertialBetaOffset += 0.01;
				}
			}
		}
	}

	public function getTypeName():String {
		return "ArcRotateCameraKeyboardMoveInput";
	}
	
	public function getSimpleName():String {
		return "keyboard";
	}
	
}
