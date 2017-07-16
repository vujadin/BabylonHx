package com.babylonhx.actions;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.StopAnimationAction') class StopAnimationAction extends Action {
	
	private var _target:Dynamic;
	

	public function new(triggerOptions:Dynamic, target:Dynamic, ?condition:Condition) {
		super(triggerOptions, condition);
		
		this._target = target;
	}

	override public function execute(?evt:ActionEvent) {
		var scene = this._actionManager.getScene();
		scene.stopAnimation(this._target);
	}
	
}
