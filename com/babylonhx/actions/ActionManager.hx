package com.babylonhx.actions;

import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.utils.Keycodes;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * Action Manager manages all events to be triggered on a given mesh or the global scene.
 * A single scene can have many Action Managers to handle predefined actions on specific meshes.
 */
@:expose('BABYLON.ActionManager') class ActionManager {
	
	// Statics
	public static inline var NothingTrigger:Int = 0;
	public static inline var OnPickTrigger:Int = 1;
	public static inline var OnLeftPickTrigger:Int = 2;
	public static inline var OnRightPickTrigger:Int = 3;
	public static inline var OnCenterPickTrigger:Int = 4;
	public static inline var OnPickDownTrigger:Int = 5;
	public static inline var OnPickUpTrigger:Int = 6;
	public static inline var OnLongPressTrigger:Int = 7;
	public static inline var OnPointerOverTrigger:Int = 8;
	public static inline var OnPointerOutTrigger:Int = 9;
	public static inline var OnEveryFrameTrigger:Int = 10;
	public static inline var OnIntersectionEnterTrigger:Int = 11;
	public static inline var OnIntersectionExitTrigger:Int = 12;
	public static inline var OnKeyDownTrigger:Int = 13;
	public static inline var OnKeyUpTrigger:Int = 14;
	public static inline var OnPickOutTrigger:Int = 15;
	
	public static inline var DragMovementThreshold:Int = 10; // in pixels
    public static inline var LongPressDelay:Int = 500; 	  // in milliseconds
	
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

	/**
	 * Does this action manager handles actions of any of the given triggers
	 * @param {number[]} triggers - the triggers to be tested
	 * @return {boolean} whether one (or more) of the triggers is handeled 
	 */
	public function hasSpecificTriggers(triggers:Array<Int>):Bool {
		for (index in 0...this.actions.length) {
			var action = this.actions[index];
			
			if (triggers.indexOf(action.trigger) > -1) {
				return true;
			}
		}
		
		return false;
	}
	
	/**
	 * Does this action manager handles actions of a given trigger
	 * @param {number} trigger - the trigger to be tested
	 * @return {boolean} whether the trigger is handeled 
	 */
	public function hasSpecificTrigger(trigger:Int):Bool {
		for (index in 0...this.actions.length) {
			var action = this.actions[index];
			
			if (action.trigger == trigger) {
				return true;
			}
		}
		
		return false;
	}

	/**
	 * Does this action manager has pointer triggers
	 * @return {boolean} whether or not it has pointer triggers
	 */
	public var hasPointerTriggers(get, never):Bool;
	private function get_hasPointerTriggers():Bool {
		for (index in 0...this.actions.length) {
			var action = this.actions[index];
			
			if (action.trigger >= ActionManager.OnPickTrigger && action.trigger <= ActionManager.OnPointerOutTrigger) {
				return true;
			}
		}
		
		return false;
	}

	/**
	 * Does this action manager has pick triggers
	 * @return {boolean} whether or not it has pick triggers
	 */
	public var hasPickTriggers(get, never):Bool;
	private function get_hasPickTriggers():Bool {
		for (index in 0...this.actions.length) {
			var action = this.actions[index];
			
			if (action.trigger >= ActionManager.OnPickTrigger && action.trigger <= ActionManager.OnPickUpTrigger) {
				return true;
			}
		}
		
		return false;
	}

	/**
	 * Registers an action to this action manager
	 * @param {BABYLON.Action} action - the action to be registered
	 * @return {BABYLON.Action} the action amended (prepared) after registration
	 */
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

	/**
	 * Process a specific trigger
	 * @param {number} trigger - the trigger to process
	 * @param evt {BABYLON.ActionEvent} the event details to be processed
	 */
	public function processTrigger(trigger:Int, evt:ActionEvent) {
		for (index in 0...this.actions.length) {
			var action = this.actions[index];
			
			if (action.trigger == trigger) {
				if (trigger == ActionManager.OnKeyUpTrigger || trigger == ActionManager.OnKeyDownTrigger) {
					var parameter = action.getTriggerParameter();
					if (parameter != null) {
						if (Keycodes.name(evt.sourceEvent) != parameter) {
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
	
	public static function Parse(parsedActions:Dynamic, object:AbstractMesh, scene:Scene) {
		var actionManager = new ActionManager(scene);
		if (object == null) {
			scene.actionManager = actionManager;
		}
		else {
			object.actionManager = actionManager;
		}
		
		/*// instanciate a new object
		var instanciate = (name: any, params: Array<any>): any => {
			var newInstance: Object = Object.create(BABYLON[name].prototype);
			newInstance.constructor.apply(newInstance, params);
			return newInstance;
		};

		var parseParameter = (name: string, value: string, target: any, propertyPath: string): any => {
			if (propertyPath === null) {
				// String, boolean or float
				var floatValue = parseFloat(value);

				if (value === "true" || value === "false")
					return value === "true";
				else
					return isNaN(floatValue) ? value : floatValue;
			}

			var effectiveTarget = propertyPath.split(".");
			var values = value.split(",");

			// Get effective Target
			for (var i = 0; i < effectiveTarget.length; i++) {
				target = target[effectiveTarget[i]];
			}

			// Return appropriate value with its type
			if (typeof (target) === "boolean")
				return values[0] === "true";

			if (typeof (target) === "string")
				return values[0];

			// Parameters with multiple values such as Vector3 etc.
			var split = new Array<number>();
			for (var i = 0; i < values.length; i++)
				split.push(parseFloat(values[i]));

			if (target instanceof Vector3)
				return Vector3.FromArray(split);

			if (target instanceof Vector4)
				return Vector4.FromArray(split);

			if (target instanceof Color3)
				return Color3.FromArray(split);

			if (target instanceof Color4)
				return Color4.FromArray(split);

			return parseFloat(values[0]);
		};

		// traverse graph per trigger
		var traverse = (parsedAction: any, trigger: any, condition: Condition, action: Action, combineArray: Array<Action> = null) => {
			if (parsedAction.detached)
				return;

			var parameters = new Array<any>();
			var target: any = null;
			var propertyPath: string = null;
			var combine = parsedAction.combine && parsedAction.combine.length > 0;

			// Parameters
			if (parsedAction.type === 2)
				parameters.push(actionManager);
			else
				parameters.push(trigger);

			if (combine) {
				var actions = new Array<Action>();
				for (var j = 0; j < parsedAction.combine.length; j++) {
					traverse(parsedAction.combine[j], ActionManager.NothingTrigger, condition, action, actions);
				}
				parameters.push(actions);
			}
			else {
				for (var i = 0; i < parsedAction.properties.length; i++) {
					var value = parsedAction.properties[i].value;
					var name = parsedAction.properties[i].name;
					var targetType = parsedAction.properties[i].targetType;

					if (name === "target")
						if (targetType !== null && targetType === "SceneProperties")
							value = target = scene;
						else
							value = target = scene.getNodeByName(value);
					else if (name === "parent")
						value = scene.getNodeByName(value);
					else if (name === "sound")
						value = scene.getSoundByName(value);
					else if (name !== "propertyPath") {
						if (parsedAction.type === 2 && name === "operator")
							value = ValueCondition[value];
						else
							value = parseParameter(name, value, target, name === "value" ? propertyPath : null);
					} else {
						propertyPath = value;
					}

					parameters.push(value);
				}
			}

			if (combineArray === null) {
				parameters.push(condition);
			}
			else {
				parameters.push(null);
			}

			// If interpolate value action
			if (parsedAction.name === "InterpolateValueAction") {
				var param = parameters[parameters.length - 2];
				parameters[parameters.length - 1] = param;
				parameters[parameters.length - 2] = condition;
			}

			// Action or condition(s) and not CombineAction
			var newAction = instanciate(parsedAction.name, parameters);

			if (newAction instanceof Condition && condition !== null) {
				var nothing = new DoNothingAction(trigger, condition);

				if (action)
					action.then(nothing);
				else
					actionManager.registerAction(nothing);

				action = nothing;
			}

			if (combineArray === null) {
				if (newAction instanceof Condition) {
					condition = newAction;
					newAction = action;
				} else {
					condition = null;
					if (action)
						action.then(newAction);
					else
						actionManager.registerAction(newAction);
				}
			}
			else {
				combineArray.push(newAction);
			}

			for (var i = 0; i < parsedAction.children.length; i++)
				traverse(parsedAction.children[i], trigger, condition, newAction, null);
		};

		// triggers
		for (var i = 0; i < parsedActions.children.length; i++) {
			var triggerParams: any;
			var trigger = parsedActions.children[i];

			if (trigger.properties.length > 0) {
				var param = trigger.properties[0].value;
				var value = trigger.properties[0].targetType === null ? param : scene.getMeshByName(param);
				triggerParams = { trigger: BABYLON.ActionManager[trigger.name], parameter: value };
			}
			else
				triggerParams = BABYLON.ActionManager[trigger.name];

			for (var j = 0; j < trigger.children.length; j++) {
				if (!trigger.detached)
					traverse(trigger.children[j], triggerParams, null, null);
			}
		}*/
		
		return null;
	}
	
}
