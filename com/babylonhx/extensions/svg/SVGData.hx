package com.babylonhx.extensions.svg;

import haxe.ds.StringMap;

// https://github.com/openfl/svg
class SVGData extends Group {	
	
	private static inline var SIN45:Float = 0.70710678118654752440084436210485;
	private static inline var TAN22:Float = 0.4142135623730950488016887242097;
	
	private static var mStyleSplit = ~/;/g;
	private static var mStyleValue = ~/\s*(.*)\s*:\s*(.*)\s*/;
	private static var mTranslateMatch = ~/translate\((.*)[, ](.*)\)/;
	private static var mScaleMatch = ~/scale\((.*)\)/;
	private static var mMatrixMatch = ~/matrix\((.*?)[, ]+(.*?)[, ]+(.*?)[, ]+(.*?)[, ]+(.*?)[, ]+(.*?)\)/;
	private static var mRotationMatch = ~/rotate\(([0-9\.]+)(\s+([0-9\.]+)\s*[, ]\s*([0-9\.]+))?\)/;
	private static var mURLMatch = ~/url\(#(.*)\)/;
	private static var mRGBMatch = ~/rgb\s*\(\s*(\d+)\s*(%)?\s*,\s*(\d+)\s*(%)?\s*,\s*(\d+)\s*(%)?\s*\)/;
	
	public var height(default, null):Float;
	public var width(default, null):Float;

	private var mConvertCubics:Bool;
	private var mPathParser:PathParser;
	
	
	public function new(inXML:Xml, inConvertCubics:Bool = false) {		
		super();
		
		var svg = inXML.firstElement();
		
		if (svg == null || (svg.nodeName != "svg" && svg.nodeName != "svg:svg")) {
			throw "Not an SVG file (" + (svg == null ? "null" : svg.nodeName) + ")";
		}
		
		mPathParser = new PathParser();
		mConvertCubics = inConvertCubics;
		
		loadGroup(this, svg);		
	}

	inline function trimToFloat(value:String) {
		return Std.parseFloat(StringTools.trim(value));
	}	
	
	private function dumpGroup(g:Group, indent:String) {		
		indent += "  ";
		
		for (e in g.children) {			
			switch (e) {				
				case DisplayPath(path): 
					//trace(indent + "Path" + "  " + path.matrix);
					
				case DisplayGroup(group): 
					dumpGroup(group, indent + "   ");
					
				//case DisplayText(text): 
					//trace(indent + "Text " + text.text);				
			}			
		}		
	}
	
	public function loadGroup(g:Group, inG:Xml):Group {		
		if (inG.exists("inkscape:label")) {			
			g.name = inG.get("inkscape:label");			
		} 
		else if (inG.exists("id")) {			
			g.name = inG.get("id");			
		}
		
		for (el in inG.elements()) {			
			var name = el.nodeName;
			
			if (name.substr(0, 4) == "svg:") {				
				name = name.substr(4);				
			}
			
			if (el.exists("display") && el.get("display") == "none") {
				continue;
			}
			
			if (name == "g") {				
				if (!(el.exists("display") && el.get("display") == "none")) {				
					g.children.push(DisplayGroup(loadGroup(new Group(), el)));					
				}				
			} 
			else if (name == "path" || name == "line" || name == "polyline") {				
				g.children.push(DisplayPath(loadPath(el, false, false)));				
			} 
			else if (name == "rect") {				
				g.children.push(DisplayPath(loadPath(el, true, false)));				
			} 
			else if (name == "polygon") {				
				g.children.push(DisplayPath(loadPath(el, false, false)));
			} 
			else if (name == "ellipse") {				
				g.children.push(DisplayPath(loadPath(el, false, true)));				
			} 
			else if (name == "circle") {				
				g.children.push(DisplayPath(loadPath(el, false, true, true)));				
			} 
			else {				
				// throw("Unknown child : " + el.nodeName );				
			}			
		}
		
		return g;		
	}	
	
	public function loadPath(inPath:Xml, inIsRect:Bool, inIsEllipse:Bool, inIsCircle:Bool = false):Path {		
		var name = inPath.exists("id") ? inPath.get("id") : "";
		var path = new Path();
		
		path.segments = [];
		path.name = name;
		
		if (inIsRect) {			
			var x = inPath.exists("x") ? Std.parseFloat(inPath.get("x")) : 0;
			var y = inPath.exists("y") ? Std.parseFloat(inPath.get("y")) : 0;
			var w = Std.parseFloat(inPath.get("width"));
			var h = Std.parseFloat(inPath.get("height"));
			var rx = inPath.exists("rx") ? Std.parseFloat(inPath.get("rx")) : 0.0;
			var ry = inPath.exists("ry") ? Std.parseFloat(inPath.get("ry")) : 0.0;
			
			if (rx == 0 || ry == 0) {				
				path.segments.push(new MoveSegment(x , y));
				path.segments.push(new DrawSegment(x + w, y));
				path.segments.push(new DrawSegment(x + w, y + h));
				path.segments.push(new DrawSegment(x, y + h));
				path.segments.push(new DrawSegment(x, y));				
			} 
			else {				
				path.segments.push(new MoveSegment(x, y + ry));
				
				// top-left
				path.segments.push(new QuadraticSegment(x, y, x + rx, y));
				path.segments.push(new DrawSegment(x + w - rx, y));
				
				// top-right
				path.segments.push(new QuadraticSegment(x + w, y, x + w, y + rx));
				path.segments.push(new DrawSegment(x + w, y + h - ry));
				
				// bottom-right
				path.segments.push(new QuadraticSegment(x + w, y + h, x + w - rx, y + h));
				path.segments.push(new DrawSegment(x + rx, y + h));
				
				// bottom-left
				path.segments.push(new QuadraticSegment(x, y + h, x, y + h - ry));
				path.segments.push(new DrawSegment(x, y + ry));				
			}			
		} 
		else if (inIsEllipse) {			
			var x = inPath.exists("cx") ? Std.parseFloat(inPath.get("cx")) : 0;
			var y = inPath.exists("cy") ? Std.parseFloat(inPath.get("cy")) : 0;
			var r = inIsCircle && inPath.exists("r") ? Std.parseFloat(inPath.get("r")) : 0.0; 
			var w = inIsCircle ? r : inPath.exists("rx") ? Std.parseFloat(inPath.get("rx")) : 0.0;
			var w_ = w * SIN45;
			var cw_ = w * TAN22;
			var h = inIsCircle ? r : inPath.exists("ry") ? Std.parseFloat(inPath.get("ry")) : 0.0;
			var h_ = h * SIN45;
			var ch_ = h * TAN22;
			
			path.segments.push(new MoveSegment(x + w, y));
			path.segments.push(new QuadraticSegment(x + w, y + ch_, x + w_, y + h_));
			path.segments.push(new QuadraticSegment(x + cw_, y + h, x, y + h));
			path.segments.push(new QuadraticSegment(x - cw_, y + h, x - w_, y + h_));
			path.segments.push(new QuadraticSegment(x - w, y + ch_, x - w, y));
			path.segments.push(new QuadraticSegment(x - w, y - ch_, x - w_, y - h_));
			path.segments.push(new QuadraticSegment(x - cw_, y - h, x, y - h));
			path.segments.push(new QuadraticSegment(x + cw_, y - h, x + w_, y - h_));
			path.segments.push(new QuadraticSegment(x + w, y - ch_, x + w, y));			
		} 
		else {			
			var d = inPath.exists("points") ? ("M" + inPath.get("points") + "z") : 
					inPath.exists("x1") ? ("M" + inPath.get("x1") + "," + inPath.get("y1") + " " + inPath.get("x2") + "," + inPath.get("y2") + "z") : inPath.get("d");
			
			for (segment in mPathParser.parse(d, mConvertCubics)) {				
				path.segments.push(segment);				
			}			
		}
		
		return path;		
	}

}
