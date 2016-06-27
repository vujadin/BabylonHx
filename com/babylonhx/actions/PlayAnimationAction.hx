package com.babylonhx.actions;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.PlayAnimationAction') class PlayAnimationAction extends Action {
	
	private var _target:Dynamic;
	public var from:Int;
	public var to:Int;
	public var loop:Bool;
	

	public function new(triggerOptions:Dynamic, target:Dynamic, from:Int, to:Int, ?loop:Bool, ?condition:Condition) {
		super(triggerOptions, condition);
		
		this._target = target;
		this.from = from;
		this.to = to;
		this.loop = loop;
	}

	override public function execute(?evt:ActionEvent) {
		var scene = this._actionManager.getScene();
		scene.beginAnimation(this._target, this.from, this.to, this.loop);
	}
	
}
