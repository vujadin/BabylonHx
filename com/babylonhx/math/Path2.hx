package com.babylonhx.math;

import com.babylonhx.math.Vector2;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.Path2') class Path2 {
	
	private var _points:Array<Vector2> = [];
	private var _length:Float = 0;
	private var closed:Bool = false;
	

	public function new(x:Float, y:Float) {
		this._points.push(new Vector2(x, y));
	}
	
	public function addLineTo(x:Float, y:Float):Path2 {
		if (closed) {
			trace("cannot add lines to closed paths");
			return this;
		}
		var newPoint = new Vector2(x, y);
		var previousPoint = this._points[this._points.length - 1];
		this._points.push(newPoint);
		this._length += newPoint.subtract(previousPoint).length();
		return this;
	}

	public function addArcTo(midX:Float, midY:Float, endX:Float, endY:Float, numberOfSegments:Int = 36):Path2 {
		if (closed) {
			trace("cannot add arcs to closed paths");
			return this;
		}
		
		var startPoint = this._points[this._points.length - 1];
		var midPoint = new Vector2(midX, midY);
		var endPoint = new Vector2(endX, endY);
		
		var arc = new Arc(startPoint, midPoint, endPoint);
		
		var increment = arc.angle.radians() / numberOfSegments;
		if (arc.orientation == Angle.Orientation_CW) {
			increment *= -1;
		}
		var currentAngle = arc.startAngle.radians() + increment;
		
		for (i in 0...numberOfSegments) {
			var x = Math.cos(currentAngle) * arc.radius + arc.centerPoint.x;
			var y = Math.sin(currentAngle) * arc.radius + arc.centerPoint.y;
			this.addLineTo(x, y);
			currentAngle += increment;
		}
		
		return this;
	}

	public function close():Path2 {
		return this;
	}
	
	public function length():Float {
		var result = this._length;
		
		if (!this.closed) {
			var lastPoint = this._points[this._points.length - 1];
			var firstPoint = this._points[0];
			result += (firstPoint.subtract(lastPoint).length());
		}
		
		return result;
	}
	
	public function getPoints():Array<Vector2> {
		return this._points;
	}
	
	public function getPointAtLengthPosition(normalizedLengthPosition:Int):Vector2 {
		if (normalizedLengthPosition < 0 || normalizedLengthPosition > 1) {
			trace("normalized length position should be between 0 and 1.");
			return null;
		}
		
		var lengthPosition = normalizedLengthPosition * this.length();
		
		var previousOffset = 0.0;
		for (i in 0...this._points.length) {
			var j = (i + 1) % this._points.length;
			
			var a = this._points[i];
			var b = this._points[j];
			var bToA = b.subtract(a);
			
			var nextOffset = (bToA.length() + previousOffset);
			if (lengthPosition >= previousOffset && lengthPosition <= nextOffset) {
				var dir = bToA.normalize();
				var localOffset = lengthPosition - previousOffset;
				
				return new Vector2(
					a.x + (dir.x * localOffset),
					a.y + (dir.y * localOffset)
					);
			}
			previousOffset = nextOffset;
		}
		
		throw("internal error");
	}

	static public function StartingAt(x:Float, y:Float):Path2 {
		return new Path2(x, y);
	}
	
}
