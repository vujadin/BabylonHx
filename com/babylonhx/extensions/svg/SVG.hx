package com.babylonhx.extensions.svg;

// https://github.com/openfl/svg

typedef GroupPath = Array<String>;
typedef ObjectFilter = String->GroupPath->Bool;

class SVG {
	
	public static var SQRT2:Float = Math.sqrt(2);

	var mSvg:SVGData;
    var mRoot:Group;
    var mFilter:ObjectFilter;
    var mGroupPath:GroupPath;
	var mGfx:SVGDataToPointsArray;
	
	
	public function new(content:String) {		
		if (content != null) {			
			mSvg = new SVGData(Xml.parse(content));
			mRoot = mSvg;
		}		
	}
	
	public static function ToPointArray(inXML:String, ?inFilter:ObjectFilter):Array<String> {
		return new SVG(inXML).iterate(new SVGDataToPointsArray(), inFilter).commands;
    }
	
	public function iterate(inGfx:SVGDataToPointsArray, ?inFilter:ObjectFilter):SVGDataToPointsArray {
       mGfx = inGfx;
       mFilter = inFilter;
       mGroupPath = [];
       iterateGroup(mRoot, true);
       return inGfx;
    }
	
    public function hasGroup(inName:String):Bool {
        return mRoot.hasGroup(inName);
    }
	
	public function iteratePath(inPath:Path) {
		if (mFilter != null && !mFilter(inPath.name, mGroupPath)) {
			return;
		}
		
		if (inPath.segments.length == 0 || mGfx == null) {
			return;
		}
		
		var context = new RenderContext();
		
		var geomOnly = false;// mGfx.geometryOnly();
		if (!geomOnly) {
			inPath.segments[0].toGfx(mGfx, context);
		}
		
		for(segment in inPath.segments) {
			segment.toGfx(mGfx, context);
		}
    }

    public function iterateGroup(inGroup:Group, inIgnoreDot:Bool) {
		// Convention for hidden layers ...
		if (inIgnoreDot && inGroup.name != null && inGroup.name.substr(0, 1) == ".") {
			return;
		}
		
		mGroupPath.push(inGroup.name);
		
		for(child in inGroup.children) {
			switch(child) {
				case DisplayGroup(group):
					iterateGroup(group, inIgnoreDot);
					
				case DisplayPath(path):
					iteratePath(path);
			}
		}
		
		mGroupPath.pop();
    }
	
}
