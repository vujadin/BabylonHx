package com.babylonhx.actions;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.CombineAction') class CombineAction extends Action {
	
	public var children:Array<Action> = [];
	
	
	public function new(triggerOptions:Dynamic, children:Array<Action>, ?condition:Condition) {
		super(triggerOptions, condition);
		
		this.children = children;
	}

	override public function _prepare() {
		for (index in 0...this.children.length) {
			this.children[index]._actionManager = this._actionManager;
			this.children[index]._prepare();
		}
	}

	override public function execute(?evt:ActionEvent) {
		for (index in 0...this.children.length) {
			this.children[index].execute(evt);
		}
	}
	
}
