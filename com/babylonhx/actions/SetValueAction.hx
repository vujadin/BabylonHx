package com.babylonhx.actions;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.SetValueAction') class SetValueAction extends Action {
	
	private var _target:Dynamic;
	private var _property:String;
	
	public var propertyPath:String;
	public var value:Dynamic;
	

	public function new(triggerOptions:Dynamic, target:Dynamic, propertyPath:String, value:Dynamic, ?condition:Condition) {
		super(triggerOptions, condition);
		
		this._target = target;
		
		this.propertyPath = propertyPath;
		this.value = value;
	}

	override public function _prepare() {
		this._target = this._getEffectiveTarget(this._target, this.propertyPath);
		this._property = this._getProperty(this.propertyPath);
	}

	override public function execute(?evt:ActionEvent) {
		Reflect.setProperty(this._target, this._property, this.value);
		
		if (this._target.markAsDirty != null) {
			this._target.markAsDirty(this._property);
        }
	}
}
