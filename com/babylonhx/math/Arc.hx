package com.babylonhx.math;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.Arc') class Arc {

	public var startPoint:Vector2;
	public var midPoint:Vector2;
	public var endPoint:Vector2;
	
	public var centerPoint:Vector2;
	public var radius:Float;
	public var angle:Angle;
	public var startAngle:Angle;
	public var orientation:Int;

	
	public function new(startPoint:Vector2, midPoint:Vector2, endPoint:Vector2) {
		this.startPoint = startPoint;
		this.midPoint = midPoint;
		this.endPoint = endPoint;
		
		var temp = Math.pow(midPoint.x, 2) + Math.pow(midPoint.y, 2);
		var startToMid = (Math.pow(startPoint.x, 2) + Math.pow(startPoint.y, 2) - temp) / 2;
		var midToEnd = (temp - Math.pow(endPoint.x, 2) - Math.pow(endPoint.y, 2)) / 2;
		var det = (startPoint.x - midPoint.x) * (midPoint.y - endPoint.y) - (midPoint.x - endPoint.x) * (startPoint.y - midPoint.y);
		
		this.centerPoint = new Vector2(
			(startToMid * (midPoint.y - endPoint.y) - midToEnd * (startPoint.y - midPoint.y)) / det,
			((startPoint.x - midPoint.x) * midToEnd - (midPoint.x - endPoint.x) * startToMid) / det
			);
			
		this.radius = this.centerPoint.subtract(this.startPoint).length();		
		this.startAngle = Angle.BetweenTwoPoints(this.centerPoint, this.startPoint);
		
		var a1 = this.startAngle.degrees();
		var a2 = Angle.BetweenTwoPoints(this.centerPoint, this.midPoint).degrees();
		var a3 = Angle.BetweenTwoPoints(this.centerPoint, this.endPoint).degrees();
		
		// angles correction
		if (a2 - a1 > 180.0) a2 -= 360.0;
		if (a2 - a1 < -180.0) a2 += 360.0;
		if (a3 - a2 > 180.0) a3 -= 360.0;
		if (a3 - a2 < -180.0) a3 += 360.0;
		
		this.orientation = (a2 - a1) < 0 ? Angle.Orientation_CW : Angle.Orientation_CCW;
		this.angle = Angle.FromDegrees(this.orientation == Angle.Orientation_CW ? a1 - a3 : a3 - a1);
	}
	
}
