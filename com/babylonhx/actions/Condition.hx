package com.babylonhx.actions;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Condition') class Condition {
	
	public var _actionManager:ActionManager;

	public var _evaluationId:Int;
	public var _currentResult:Bool = false;
	
	
	public function new(actionManager:ActionManager) {
		this._actionManager = actionManager;
	}

	public function isValid():Bool {
		return true;
	}

	public function _getProperty(propertyPath:String):String {
		return this._actionManager._getProperty(propertyPath);
	}

	public function _getEffectiveTarget(target:Dynamic, propertyPath:String):Dynamic {
		return this._actionManager._getEffectiveTarget(target, propertyPath);
	}
	
}
