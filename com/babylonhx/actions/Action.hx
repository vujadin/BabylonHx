package com.babylonhx.actions;

import com.babylonhx.Scene;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.lights.Light;
import com.babylonhx.cameras.Camera;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.tools.Observable;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Action') class Action {
	
	public var trigger:Int;
	public var _actionManager:ActionManager;

	private var _nextActiveAction:Action;
	private var _child:Action;
	private var _condition:Condition;
	private var _triggerParameter:Dynamic;
	
	public var onBeforeExecuteObservable:Observable<Action> = new Observable<Action>();
	
	public var triggerOptions:Dynamic;
	

	public function new(triggerOptions:Dynamic, ?condition:Condition) {
		this.triggerOptions = triggerOptions;
		
		if (triggerOptions.parameter != null) {
			this.trigger = triggerOptions.trigger;
			this._triggerParameter = triggerOptions.parameter;
		} 
		else {
			this.trigger = triggerOptions;
		}
		
		this._nextActiveAction = this;
		this._condition = condition;
	}

	// Methods
	public function _prepare() { }

	public function getTriggerParameter():Dynamic {
		return this._triggerParameter;
	}

	public function _executeCurrent(evt:ActionEvent) {
		if (this._nextActiveAction._condition != null) {
			var condition = this._nextActiveAction._condition;
			var currentRenderId = this._actionManager.getScene().getRenderId();
			
			// We cache the current evaluation for the current frame
			if (condition._evaluationId == currentRenderId) {
				if (!condition._currentResult) {
					return;
				}
			} 
			else {
				condition._evaluationId = currentRenderId;
				
				if (!condition.isValid()) {
					condition._currentResult = false;					
					return;
				}
				
				condition._currentResult = true;
			}
		}
		
		this.onBeforeExecuteObservable.notifyObservers(this);
		this._nextActiveAction.execute(evt);
		
		this.skipToNextActiveAction();
	}

	public function execute(?evt:ActionEvent) { }
	
	public function skipToNextActiveAction() {
		if (this._nextActiveAction._child != null) {
			
			if (this._nextActiveAction._child._actionManager == null) {
				this._nextActiveAction._child._actionManager = this._actionManager;
			}
			
			this._nextActiveAction = this._nextActiveAction._child;
		} 
		else {
			this._nextActiveAction = this;
		}
	}

	public function then(action:Action):Action {
		this._child = action;
		
		action._actionManager = this._actionManager;
		action._prepare();
		
		return action;
	}

	public function _getProperty(propertyPath:String):String {
		return this._actionManager._getProperty(propertyPath);
	}

	public function _getEffectiveTarget(target:Dynamic, propertyPath:String):Dynamic {
		return this._actionManager._getEffectiveTarget(target, propertyPath);
	}
	
	public function serialize(parent:Dynamic):Dynamic {
		return null;
    }
        
	// Called by BABYLON.Action objects in serialize(...). Internal use
	public function _serialize(serializedAction:Dynamic, ?parent:Dynamic):Dynamic {
		var serializationObject:Dynamic = { 
			type: 1,
			children: [],
			name: serializedAction.name,
			properties: serializedAction.properties != null ? serializedAction.properties : []
		};
		
		// Serialize child
		if (this._child != null) { 
			this._child.serialize(serializationObject);
		}
		
		// Check if "this" has a condition
		/*if (this._condition != null) {
			var serializedCondition = this._condition.serialize();
			serializedCondition.children.push(serializationObject);
			
			if (parent != null) {
				parent.children.push(serializedCondition);
			}
			return serializedCondition;
		}*/
		
		if (parent != null) {
			parent.children.push(serializationObject);
		}
		return serializationObject;
	}
	
	public static function _SerializeValueAsString(value:Dynamic):String {
		if (Std.is(value, Float)) {
			return value + '';
		}
		
		if (Std.is(value, Bool)) {
			return value ? "true" : "false";
		}
		
		if (Std.is(value, Vector2)) {
			return value.x + ", " + value.y;
		}
		if (Std.is(value, Vector3)) {
			return value.x + ", " + value.y + ", " + value.z;
		}
		
		if (Std.is(value, Color3)) {
			return value.r + ", " + value.g + ", " + value.b;
		}
		if (Std.is(value, Color4)) {
			return value.r + ", " + value.g + ", " + value.b + ", " + value.a;
		}
		
		return value; // string
	}
	
	public static function _GetTargetProperty(target:Dynamic):Dynamic {
		return {
			name: "target",
			targetType: Std.is(target, Mesh) ? "MeshProperties"
						: Std.is(target, Light) ? "LightProperties"
						: Std.is(target, Camera) ? "CameraProperties"
						: "SceneProperties",
			value: Std.is(target, Scene) ? "Scene" : target.name
		}  
	}
	
}
