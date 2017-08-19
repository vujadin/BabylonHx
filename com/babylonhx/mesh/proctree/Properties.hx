package com.babylonhx.mesh.proctree;

/**
 * ...
 * @author Krtolica Vujadin
 */

// ported from https://github.com/supereggbert/proctree.js
class Properties {

	public var clumpMax:Float = 0.454;
	public var clumpMin:Float = 0.404;
	public var lengthFalloffFactor:Float = 0.85;
	public var lengthFalloffPower:Float = 0.99;
	public var branchFactor:Float = 2.45;
	public var radiusFalloffRate:Float = 0.73;
	public var climbRate:Float = 1.5;
	public var trunkKink:Float = 0.093;
	public var maxRadius:Float = 0.139;
	public var treeSteps:Int = 5;
	public var taperRate:Float = 0.95;
	public var twistRate:Int = 13;
	public var segments:Int = 6;
	public var levels:Int = 5;
	public var sweepAmount:Int = 0;
	public var initalBranchLength:Float = 0.85;
	public var trunkLength:Float = 2.5;
	public var dropAmount:Float = -0.1;
	public var growAmount:Float = 0.235;
	public var vMultiplier:Float = 2.36;
	public var twigScale:Float = 0.39;
	public var seed:Int = 262;
	public var rseed:Int = 10;
	

	public function new() { }

	public function random(?aFixed:Float):Float {
		if (aFixed == null) {
			aFixed = rseed++;
		}
		
		return Math.abs(Math.cos(aFixed + aFixed * aFixed));
	}

}
