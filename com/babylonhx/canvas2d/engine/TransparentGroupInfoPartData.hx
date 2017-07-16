package com.babylonhx.canvas2d.engine;

/**
 * ...
 * @author Krtolica Vujadin
 */
class TransparentGroupInfoPartData extends GroupInfoPartData {

	public function new(stride:Int, zoff:Int) {
		super(stride);
		
		this._partData.compareValueOffset = zoff;
		this._partData.sortingAscending = false;
	}
	
}