package com.babylonhx.actions;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.ActionManager') class ActionManager {
	
	// Statics
	public static var NothingTrigger:Int = 0;
	public static var OnPickTrigger:Int = 1;
	public static var OnLeftPickTrigger:Int = 2;
	public static var OnRightPickTrigger:Int = 3;
	public static var OnCenterPickTrigger:Int = 4;
	public static var OnPointerOverTrigger:Int = 5;
	public static var OnPointerOutTrigger:Int = 6;
	public static var OnEveryFrameTrigger:Int = 7;
	public static var OnIntersectionEnterTrigger:Int = 8;
	public static var OnIntersectionExitTrigger = 9;
	public static var OnKeyDownTrigger:Int = 10;
	public static var OnKeyUpTrigger:Int = 11;

	
	// Members
	public var actions:Array<Action> = [];
	private var _scene:Scene;
	

	public function new(scene:Scene) {
		this._scene = scene;
		
		scene._actionManagers.push(this);
	}

	// Methods
	public function dispose():Void {
		var index = this._scene._actionManagers.indexOf(this);
		
		if (index > -1) {
			this._scene._actionManagers.splice(index, 1);
		}
	}

	public function getScene():Scene {
		return this._scene;
	}

	public function hasSpecificTriggers(triggers:Array<Int>):Bool {
		for (index in 0...this.actions.length) {
			var action = this.actions[index];
			
			if (triggers.indexOf(action.trigger) > -1) {
				return true;
			}
		}
		
		return false;
	}

	public var hasPointerTriggers(get, null):Bool;
	private function get_hasPointerTriggers():Bool {
		for (index in 0...this.actions.length) {
			var action = this.actions[index];
			
			if (action.trigger >= ActionManager.OnPickTrigger && action.trigger <= ActionManager.OnPointerOutTrigger) {
				return true;
			}
		}
		
		return false;
	}

	public var hasPickTriggers(get, null):Bool;
	private function get_hasPickTriggers():Bool {
		for (index in 0...this.actions.length) {
			var action = this.actions[index];
			
			if (action.trigger >= ActionManager.OnPickTrigger && action.trigger <= ActionManager.OnCenterPickTrigger) {
				return true;
			}
		}
		
		return false;
	}

	public function registerAction(action:Action):Action {
		if (action.trigger == ActionManager.OnEveryFrameTrigger) {
			if (this.getScene().actionManager != this) {
				trace("OnEveryFrameTrigger can only be used with scene.actionManager");
				return null;
			}
		}
		
		this.actions.push(action);
		
		action._actionManager = this;
		action._prepare();
		
		return action;
	}

	public function processTrigger(trigger:Int, evt:ActionEvent) {
		for (index in 0...this.actions.length) {
			var action = this.actions[index];
			
			if (action.trigger == trigger) {
				if (trigger == ActionManager.OnKeyUpTrigger || trigger == ActionManager.OnKeyDownTrigger) {
					var parameter = action.getTriggerParameter();
					
					if (parameter != null) {
						if (evt.sourceEvent.key != parameter) {
							continue;
						}
					}
				}
				
				action._executeCurrent(evt);
			}
		}
	}

	public function _getEffectiveTarget(target:Dynamic, propertyPath:String):Dynamic {
		var properties = propertyPath.split(".");
		
		for (index in 0...properties.length - 1) {
			target = Reflect.getProperty(target, properties[index]);
		}
		
		return target;
	}

	public function _getProperty(propertyPath:String):String {
		var properties = propertyPath.split(".");
		
		return properties[properties.length - 1];
	}
	
}
