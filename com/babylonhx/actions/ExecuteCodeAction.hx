package com.babylonhx.actions;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.ExecuteCodeAction') class ExecuteCodeAction extends Action {
	
	public var func:ActionEvent->Void;
	
	
	public function new(triggerOptions:Dynamic, func:ActionEvent->Void, ?condition:Condition) {
		super(triggerOptions, condition);
		
		this.func = func;
	}

	override public function execute(?evt:ActionEvent) {
		this.func(evt);
	}
	
}
