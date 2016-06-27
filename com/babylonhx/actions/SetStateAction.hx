package com.babylonhx.actions;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.SetStateAction') class SetStateAction extends Action {
	
	private var _target:Dynamic;	
	public var value:String;
	

	public function new(triggerOptions:Dynamic, target:Dynamic, value:String, ?condition:Condition) {
		super(triggerOptions, condition);
		
		this._target = target;
	}

	override public function execute(?evt:ActionEvent) {
		this._target.state = this.value;
	}
	
}
