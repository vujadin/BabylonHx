package com.babylonhx.actions;

import com.babylonhx.math.Vector3;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.SetParentAction') class SetParentAction extends Action {
	
	private var _parent:Dynamic;
	private var _target:Dynamic;
	

	public function new(triggerOptions:Dynamic, target:Dynamic, parent:Dynamic, ?condition:Condition) {
		super(triggerOptions, condition);
		
		this._target = target;
		this._parent = parent;
	}

	override public function execute(?evt:ActionEvent) {
		if (this._target.parent == this._parent) {
			return;
		}
		
		var invertParentWorldMatrix = this._parent.getWorldMatrix().clone();
		invertParentWorldMatrix.invert();
		
		this._target.position = Vector3.TransformCoordinates(this._target.position, cast invertParentWorldMatrix);
		
		this._target.parent = this._parent;
	}
	
}
