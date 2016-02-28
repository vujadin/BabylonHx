package com.babylonhx.tools.hdr;

import com.babylonhx.math.Vector3;


/**
 * ...
 * @author Krtolica Vujadin
 */
class FileFaceOrientation {

	public var name:String;
	public var worldAxisForNormal:Vector3; // the world axis corresponding to the normal to the face
	public var worldAxisForFileX:Vector3; // the world axis corresponding to texture right x-axis in file
	public var worldAxisForFileY:Vector3; // the world axis corresponding to texture down y-axis in file
	

	public function new(name:String, worldAxisForNormal:Vector3, worldAxisForFileX:Vector3, worldAxisForFileY:Vector3) {
		this.name = name;
		this.worldAxisForNormal = worldAxisForNormal;
		this.worldAxisForFileX = worldAxisForFileX;
		this.worldAxisForFileY = worldAxisForFileY;
	}
	
}
