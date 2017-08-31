package com.babylonhx.cameras;

import com.babylonhx.tools.Tools;
import com.babylonhx.tools.serialization.SerializationHelper;

/**
 * ...
 * @author Krtolica Vujadin
 */
 
class CameraInputsManager {

	var attached:Map<String, ICameraInput>;
	
	public var noPreventDefault:Bool;
	var camera:Camera;
	var checkInputs:Void->Void;
	

	public function new(camera:Camera) {
		this.attached = new Map();
		this.camera = camera;
		this.checkInputs = function() { };
	}

	public function add(input:ICameraInput) {
		var type = input.getSimpleName();
		if (this.attached[type] != null) {
			Tools.Warn('camera input of type ${type} already exists on camera');
			
			return;
		}
		
		this.attached[type] = input;
		
		input.camera = this.camera;
		
		//for checkInputs, we are dynamically creating a function
		//the goal is to avoid the performance penalty of looping for inputs in the render loop
		if (input.checkInputs != null) {
			this.checkInputs = this._addCheckInputs(input.checkInputs);
		}
		
		/*if (this.attachedElement) {
			input.attachControl(this.attachedElement);
		}*/
	}

	public function remove(inputToRemove:ICameraInput) {
		for (cam in this.attached.keys()) {
			var input = this.attached[cam];
			if (input == inputToRemove) {
				input.detachControl();
				input.camera = null;
				this.attached.remove(cam);
				this.rebuildInputCheck();
			}
		}
	}

	public function removeByType(inputType:String) {
		for (cam in this.attached.keys()) {
			var input = this.attached[cam];
			if (input.getClassName() == inputType) {
				input.detachControl();
				input.camera = null;
				this.attached.remove(cam);
				this.rebuildInputCheck();
			}
		}
	}

	private function _addCheckInputs(fn:Void->Void):Void->Void {
		var current = this.checkInputs;
		return function() {
			current();
			fn();
		};
	}

	public function attachInput(input:ICameraInput) {
		input.attachControl();
	}

	/*public attachElement(element: HTMLElement, noPreventDefault?: boolean) {
		if (this.attachedElement) {
			return;
		}

		noPreventDefault = Camera.ForceAttachControlToAlwaysPreventDefault ? false : noPreventDefault;
		this.attachedElement = element;
		this.noPreventDefault = noPreventDefault;

		for (var cam in this.attached) {
			var input = this.attached[cam];
			this.attached[cam].attachControl(element, noPreventDefault);
		}
	}

	public detachElement(element: HTMLElement) {
		if (this.attachedElement !== element) {
			return;
		}

		for (var cam in this.attached) {
			var input = this.attached[cam];
			this.attached[cam].detachControl(element);
		}

		this.attachedElement = null;
	}*/

	public function rebuildInputCheck() {
		this.checkInputs = function() { };
		
		for (cam in this.attached.keys()) {
			var input = this.attached[cam];
			if (input.checkInputs != null) {
				this.checkInputs = this._addCheckInputs(input.checkInputs);
			}
		}
	}

	public function clear() {
		/*if (this.attachedElement) {
			this.detachElement(this.attachedElement);
		}*/
		this.attached = new Map();
		//this.attachedElement = null;
		this.checkInputs = function() { };
	}

	public function serialize(serializedCamera:Dynamic) {
		/*var inputs:Dynamic = { };
		for (cam in this.attached.keys()) {
			var input = this.attached[cam];
			var res = SerializationHelper.Serialize(input);
			Reflect.setField(inputs, input.getTypeName(), res);
		}
		
		serializedCamera.inputsmgr = inputs;*/
	}

	/*public function parse(parsedCamera:Dynamic) {
		var parsedInputs = parsedCamera.inputsmgr;
		if (parsedInputs != null) {
			this.clear();
			
			for (var n in parsedInputs) {
				var construct = CameraInputTypes[n];
				if (construct) {
					var parsedinput = parsedInputs[n];
					var input = SerializationHelper.Parse(() => { return new construct() }, parsedinput, null);
					this.add(input as any);
				}
			}
		} 
		else { 
			//2016-03-08 this part is for managing backward compatibility
			for (var n in this.attached) {
				var construct = CameraInputTypes[this.attached[n].getTypeName()];
				if (construct) {
					var input = SerializationHelper.Parse(() => { return new construct() }, parsedCamera, null);
					this.remove(this.attached[n]);
					this.add(input as any);
				}
			}
		}
	}*/
	
}
