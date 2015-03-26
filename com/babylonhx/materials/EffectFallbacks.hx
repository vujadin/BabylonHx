package com.babylonhx.materials;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.EffectFallbacks') class EffectFallbacks {
	
	private var _defines:Array<Array<String>> = [];
	private var _currentRank:Int = 32;
	private var _maxRank:Int = -1;
	
	public var isMoreFallbacks(get, never):Bool;
	
	
	public function new() {
		// 
	}	

	public function addFallback(rank:Int, define:String):Void {
		if (this._defines[rank] == null) {
			if (rank < this._currentRank) {
				this._currentRank = rank;
			}
			
			if (rank > this._maxRank) {
				this._maxRank = rank;
			}
			
			this._defines[rank] = new Array<String>();
		}
		
		this._defines[rank].push(define);
	}

	public function reduce(currentDefines:String):String {
		
		var currentFallbacks = this._defines[this._currentRank];
		
		for (index in 0...currentFallbacks.length) {
			currentDefines = StringTools.replace(currentDefines, "#define " + currentFallbacks[index], "");
		}
		
		this._currentRank++;
		
		return currentDefines;
	}
	
	private function get_isMoreFallbacks():Bool {
		return this._currentRank <= this._maxRank;
	}
	
}
