package com.babylonhx.extensions.svg;

// https://github.com/openfl/svg

enum DisplayElement {
	
   DisplayPath(path:Path);
   DisplayGroup(group:Group);
   
}

typedef DisplayElements = Array<DisplayElement>;


class Group {
	
	public var name:String;
	public var children:Array<DisplayElement>;
	
	
	public function new() {
		name = "";
		children = [];
	}

	public function hasGroup(inName:String) {
		return findGroup(inName) != null;
	}
	
	public function findGroup(inName:String):Group {
		for(child in children) {
			switch(child) {
				case DisplayGroup(group):
					if (group.name == inName) {
						return group;
					}
					var inGroup:Group = group.findGroup(inName);
					if (inGroup != null) {
						return inGroup;
					}
				default:
			}
		}
		return null;
    }
	
}
