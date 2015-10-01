package com.babylonhx.physics;

import com.babylonhx.utils.Image;

import jiglib.plugin.ITerrain;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Terrain implements ITerrain {
	
	public var minW(get, never):Float;
    public var minH(get, never):Float;
    public var maxW(get, never):Float;
    public var maxH(get, never):Float;
    public var dw(get, never):Float;
    public var dh(get, never):Float;
    public var sw(get, never):Int;
    public var sh(get, never):Int;
    public var heights(get, never):Array<Array<Float>>;
    public var maxHeight(get, never):Float;
	
	//Min of coordinate horizontally;
	private var _minW:Float;
	//Min of coordinate vertically;
	private var _minH:Float;
	//Max of coordinate horizontally;
	private var _maxW:Float;
	//Max of coordinate vertically;
	private var _maxH:Float;
	//The horizontal length of each segment;
	private var _dw:Float;
	//The vertical length of each segment;
	private var _dh:Float;
	//the heights of all vertices
	private var _heights:Array<Array<Float>>;
	private var _segmentsW:Int;
	private var _segmentsH:Int;
	private var _maxHeight:Float;
	//private var _primitive:Polygon;
	

	public function new(heightMap:Image, width:Float = 1000, height:Float = 100, depth:Float = 1000, segmentsW:Int = 30, segmentsH:Int = 30, maxElevation:Int = 255, minElevation:Int = 0) {
		_segmentsW = segmentsW;
		_segmentsH = segmentsH;
		_maxHeight = maxElevation;
		
		var textureX = width / 2;
		var textureY = depth / 2;
		
		_minW = -textureX;
		_minH = -textureY;
		_maxW = textureX;
		_maxH = textureY;
		_dw = width / segmentsW;
		_dh = depth / segmentsH;
		
		var pixels = heightMap.getPixels();
		var pixelDW = (heightMap.width-1) / segmentsW;
		var pixelDH = (heightMap.height - 1) / segmentsH;
		
		var points:Array<Point> = [];
		_heights = [];
		for ( ix in 0..._segmentsW+1 ) {
			var row:Array<Float> = [];
			_heights.push(row);
			for ( iy in 0..._segmentsH+1 ) {
				var ptX = _minW + (_dw * ix);
				var ptY = _minH + (_dh * iy);

				var color:UInt = pixels.getPixel(Math.round(ix * pixelDW), Math.round(iy * pixelDH)) & 0xff;
				color = (color < minElevation) ? minElevation : (color > maxElevation) ? maxElevation : color;
				var ptHeight = color / 0xff * height;

				row.push(ptHeight);
				points.push(new Point(ptX, ptHeight, ptY));
			}
		}

		var idxs:IndexBuffer = new IndexBuffer();
		for ( ix in 0...segmentsW ) {
			for ( iy in 0...segmentsH ) {
				var offset = ix * (segmentsH+1);
				idxs.push(offset + iy);
				idxs.push(offset + iy + 1);
				idxs.push(offset + segmentsH + 1 + iy);

				idxs.push(offset + segmentsH + 1 + iy);
				idxs.push(offset + iy + 1);
				idxs.push(offset + segmentsH + 1 + iy + 1);
			}
		}

		super(points, idxs);
	}

	public function get_minW():Float {
		return _minW;
	}
	public function get_minH():Float {
		return _minH;
	}
	public function get_maxW():Float {
		return _maxW;
	}
	public function get_maxH():Float {
		return _maxH;
	}
	public function get_dw():Float {
		return _dw;
	}
	public function get_dh():Float {
		return _dh;
	}
	public function get_sw():Int {
		return _segmentsW;
	}
	public function get_sh():Int {
		return _segmentsH;
	}
	public function get_heights():Array<Array<Float>> {
		return _heights;
	}
	public function get_maxHeight():Float{
		return _maxHeight;
	}
	
}
