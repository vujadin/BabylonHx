package com.babylonhx.animations;

import com.babylonhx.math.Path2;
import com.babylonhx.math.Vector3;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PathCursor {

	private var _onchange:Array<PathCursor->Void = [];
	private var path:Path2;
	private var value:Float = 0;
	private var animations:Array<Animation> = [];
	

	public function new(path:Path2) {
		this.path = path;
	}

	public function getPoint():Vector3 {
		var point = this.path.getPointAtLengthPosition(this.value);		
		return new Vector3(point.x, 0, point.y);
	}

	public function moveAhead(step:Float = 0.002):PathCursor {
		this.move(step);
		
		return this;
	}

	public function moveBack(step:Float = 0.002):PathCursor {
		this.move(-step);
		
		return this;
	}

	public function move(step:Float):PathCursor {
		if (Math.abs(step) > 1) {
			throw "step size should be less than 1.";
		}
		
		this.value += step;
		this.ensureLimits();
		this.raiseOnChange();
		
		return this;
	}

	private function ensureLimits():PathCursor {
		while (this.value > 1) {
			this.value -= 1;
		}
		while (this.value < 0) {
			this.value += 1;
		}
		
		return this;
	}

	// used by animation engine
	private function markAsDirty(propertyName:String):PathCursor {
		this.ensureLimits();
		this.raiseOnChange();
		
		return this;
	}

	private function raiseOnChange():PathCursor {
		for (f in this._onchange) {
			f(this);
		}
		
		return this;
	}

	public function onchange(f:PathCursor->Void):PathCursor {
		this._onchange.push(f);
		
		return this;
	}
	
}
