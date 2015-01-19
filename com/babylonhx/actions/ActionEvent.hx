package com.babylonhx.actions;

import com.babylonhx.mesh.AbstractMesh;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.ActionEvent') class ActionEvent {
	
	public var source:AbstractMesh;
	public var pointerX:Float;
	public var pointerY:Float;
	public var meshUnderPointer:AbstractMesh;
	public var sourceEvent:Dynamic;
	
	
	public function new(source:AbstractMesh, pointerX:Float, pointerY:Float, meshUnderPointer:AbstractMesh, ?sourceEvent:Dynamic) {
		this.source = source;
		this.pointerX = pointerX;
		this.pointerY = pointerY;
		this.meshUnderPointer = meshUnderPointer;
		this.sourceEvent = sourceEvent;
	}

	// Statics
	public static function CreateNew(source:AbstractMesh):ActionEvent {
		var scene = source.getScene();
		return new ActionEvent(source, scene.pointerX, scene.pointerY, scene.meshUnderPointer);
	}

	public static function CreateNewFromScene(scene:Scene, evt:Dynamic):ActionEvent {
		return new ActionEvent(null, scene.pointerX, scene.pointerY, scene.meshUnderPointer, evt);
	}
	
}
