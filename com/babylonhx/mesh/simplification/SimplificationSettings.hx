package com.babylonhx.mesh.simplification;

/**
 * ...
 * @author Krtolica Vujadin
 */
 
@:expose('BABYLON.SimplificationSettings') class SimplificationSettings implements ISimplificationSettings {
	
	/**
     * The implemented types of simplification.
     * At the moment only Quadratic Error Decimation is implemented.
     */
	public static inline var QUADRATIC:Int = 0;
		
	public var quality:Int;
    public var distance:Float;
	public var optimizeMesh:Bool;
	

	public function new(quality:Int, distance:Float, optimizeMesh:Bool = false) {
		this.quality = quality;
		this.distance = distance;
		this.optimizeMesh = optimizeMesh;
	}
	
}
