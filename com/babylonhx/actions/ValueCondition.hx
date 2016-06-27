package com.babylonhx.actions;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.ValueCondition') class ValueCondition extends Condition {
	
	// Statics
	public static inline var IsEqual:Int = 0;
	public static inline var IsDifferent:Int = 1;
	public static inline var IsGreater:Int = 2;
	public static inline var IsLesser:Int = 3;

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
				return Reflect.getProperty(this._target, this._property) > this.value;
				
			case ValueCondition.IsLesser:
				return Reflect.getProperty(this._target, this._property) < this.value;
				
			case ValueCondition.IsEqual, ValueCondition.IsDifferent:
				var check:Bool = false;
				
				if (this.value.equals != null) {
					check = this.value.equals(Reflect.getProperty(this._target, this._property));
				} 
				else {
					check = this.value == Reflect.getProperty(this._target, this._property);
				}
				
				return this.operator == ValueCondition.IsEqual ? check : !check;
		}
		
		return false;
	}
	
}
