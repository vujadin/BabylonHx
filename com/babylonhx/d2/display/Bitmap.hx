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
	
	override public function _render() {
		//return;
		var tbd = this.bitmapData;
		if (tbd._dirty) {
			tbd._syncWithGPU(this.stage);
		}
        this.stage.Gl.uniformMatrix4fv(this.stage._sprg.tMatUniform, false, this.stage._mstack.top()); //TODO mio
        this.stage._updateCMStack();

        this.stage._setVC(tbd._vBuffer);
        this.stage._setTC(tbd._tcBuffer);
        this.stage._setUT(1);
        this.stage._setTEX(tbd._texture);
        this.stage._setEBF(this.stage._unitIBuffer);

        this.stage.Gl.drawElements(GL.TRIANGLES, 6, GL.UNSIGNED_SHORT, 0);//TODO mio
	}
	
}
