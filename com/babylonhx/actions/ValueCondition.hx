package com.babylonhx.actions;

/**
 * ...
 * @author Krtolica Vujadin
 */

class ValueCondition extends Condition {
	
	// Statics
	private static var IsEqual:Int = 0;
	private static var IsDifferent:Int = 1;
	private static var IsGreater:Int = 2;
	private static var IsLesser:Int = 3;

	private var _target:Dynamic;
	private var _property:String;
	
	public var propertyPath:String;
	public var value:Dynamic;
	public var operator:Int;
	

	public function new(actionManager:ActionManager, target:Dynamic, propertyPath:String, value:Dynamic, operator:Int = ValueCondition.IsEqual) {
		super(actionManager);
		
		this._target = this._getEffectiveTarget(target, this.propertyPath);
		this._property = this._getProperty(this.propertyPath);
		
		this.propertyPath = propertyPath;
		this.value = value;
		this.operator = operator;
	}

	// Methods
	override public function isValid():Bool {
		switch (this.operator) {
			case ValueCondition.IsGreater:
				return this._target[this._property] > this.value;
			case ValueCondition.IsLesser:
				return this._target[this._property] < this.value;
			case ValueCondition.IsEqual, ValueCondition.IsDifferent:
				var check:Bool = false;
				
				if (this.value.equals) {
					check = this.value.equals(this._target[this._property]);
				} else {
					check = this.value == this._target[this._property];
				}
				return this.operator == ValueCondition.IsEqual ? check : !check;
		}
		
		return false;
	}
	
}
