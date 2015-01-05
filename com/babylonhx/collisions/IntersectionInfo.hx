package com.babylonhx.collisions;

/**
 * ...
 * @author Krtolica Vujadin
 */
class IntersectionInfo {
	
	public var faceId:Int = 0;
	public var bu:Float;
	public var bv:Float;
	public var distance:Float;
	

	public function new(bu:Float, bv:Float, distance:Float) {
		this.bu = bu;
		this.bv = bv;
		this.distance = distance;
	}
	
}
