package com.babylonhx.actions;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.StateCondition') class StateCondition extends Condition {
	
	// Members
	private var _target:Dynamic;
	private var value:String;
	

	public function new(actionManager:ActionManager, target:Dynamic, value:String) {
		super(actionManager);
		
		this._target = target;
		this.value = value;
	}

	// Methods
	override public function isValid():Bool {
		return this._target.state == this.value;
	}
	
}
