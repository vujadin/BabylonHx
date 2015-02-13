package com.babylonhx.mesh.simplification;

/**
 * ...
 * @author Krtolica Vujadin
 */
 
@:expose('BABYLON.SimplificationSettings') class SimplificationSettings implements ISimplificationSettings {
	
	public static inline var QUADRATIC:Int = 0;
	
	public var quality:Int;
    public var distance:Float;
	

	public function new(quality:Int, distance:Float) {
		this.quality = quality;
		this.distance = distance;
	}
	
}
