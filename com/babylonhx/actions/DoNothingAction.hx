package com.babylonhx.actions;

/**
 * ...
 * @author Krtolica Vujadin
 */

class DoNothingAction extends Action {
	
	public function new(triggerOptions:Dynamic = 0/*ActionManager.NothingTrigger*/, ?condition:Condition) {
		super(triggerOptions, condition);
	}
	
}
