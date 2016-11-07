package com.babylonhx.d2.display;

import com.babylonhx.d2.geom.Rectangle;

import com.babylonhx.utils.GL;

/**
 * ...
 * @author Krtolica Vujadin
 */

/** 
 * A basic class for rendering bitmaps
 * 
 * @author Ivan Kuckir
 * @version 1.0
 */
class Bitmap extends InteractiveObject {
	
	public var bitmapData:BitmapData;

	
	public function new(bd:BitmapData) {
		super();
		
		this.bitmapData = bd;
	}
	
	override private function _getLocRect():Rectangle {
		return this.bitmapData.rect;
	}
	
	override public function _render(st:Stage) {
		//return;
		var tbd = this.bitmapData;
		if (tbd._dirty) {
			tbd._syncWithGPU();
		}
		GL.uniformMatrix4fv(st._sprg.tMatUniform, false, st._mstack.top());
		st._cmstack.update();
		
		Stage._setVC(tbd._vBuffer);
		Stage._setTC(tbd._tcBuffer);
		Stage._setUT(1);
		Stage._setTEX(tbd._texture);
		Stage._setEBF(st._unitIBuffer);
		
        GL.drawElements(GL.TRIANGLES, 6, GL.UNSIGNED_SHORT, 0);
	}
	
}
