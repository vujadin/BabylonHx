package com.babylonhx.actions;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.PredicateCondition') class PredicateCondition extends Condition {
	
	// Members
	public var predicate:Void->Bool;


	public function new(actionManager:ActionManager, predicate:Void->Bool) {
		super(actionManager);
		
		this.predicate = predicate;
	}

	override public function isValid():Bool {
		return this.predicate();
	}
	
}
