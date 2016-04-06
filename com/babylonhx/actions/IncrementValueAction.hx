package com.babylonhx.actions;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.IncrementValueAction') class IncrementValueAction extends Action {
	
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
		
		var isInt = Std.is(Reflect.getProperty(this._target, this._property), Int);
		var isFloat = Std.is(Reflect.getProperty(this._target, this._property), Float);
		if (!isInt && !isFloat) {
			trace("Warning:IncrementValueAction can only be used with number values");
		}
	}

	override public function execute(?evt:ActionEvent) {
		var val = Reflect.getProperty(this._target, this._property);
		Reflect.setProperty(this._target, this._property, val + this.value);
	}
	
}
