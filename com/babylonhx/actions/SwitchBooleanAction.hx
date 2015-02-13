package com.babylonhx.actions;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.SwitchBooleanAction') class SwitchBooleanAction extends Action {
	
	private var _target:Dynamic;
	private var _property:String;
	
	public var propertyPath:String;
	

	public function new(triggerOptions:Dynamic, target:Dynamic, propertyPath:String, ?condition:Condition) {
		super(triggerOptions, condition);
		this._target = target;
		this.propertyPath = propertyPath;
	}

	override public function _prepare() {
		this._target = this._getEffectiveTarget(this._target, this.propertyPath);
		this._property = this._getProperty(this.propertyPath);
	}

	override public function execute(?evt:ActionEvent) {
		this._target[this._property] = !this._target[this._property];
	}
	
}
