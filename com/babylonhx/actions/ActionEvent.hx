package com.babylonhx.actions;

import com.babylonhx.math.Vector2;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.sprites.Sprite;

/**
 * ...
 * @author Krtolica Vujadin
 */

 
/**
 * ActionEvent is the event beint sent when an action is triggered.
 */
@:expose('BABYLON.ActionEvent') class ActionEvent {
	
	public var source:Dynamic;
	public var pointerX:Float;
	public var pointerY:Float;
	public var meshUnderPointer:Dynamic;
	public var sourceEvent:Dynamic;
	public var additionalData:Dynamic;
	
	
	/**
	 * @constructor
	 * @param source The mesh or sprite that triggered the action.
	 * @param pointerX The X mouse cursor position at the time of the event
	 * @param pointerY The Y mouse cursor position at the time of the event
	 * @param meshUnderPointer The mesh that is currently pointed at (can be null)
	 * @param sourceEvent the original (browser) event that triggered the ActionEvent
	 */
	public function new(source:Dynamic, pointerX:Float, pointerY:Float, meshUnderPointer:AbstractMesh, ?sourceEvent:Dynamic, ?additionalData:Dynamic) {
		this.source = source;
		this.pointerX = pointerX;
		this.pointerY = pointerY;
		this.meshUnderPointer = meshUnderPointer;
		this.sourceEvent = sourceEvent;
		this.additionalData = additionalData;
	}

	/**
	 * Helper function to auto-create an ActionEvent from a source mesh.
	 * @param source The source mesh that triggered the event
	 */
	public static function CreateNew(source:AbstractMesh, ?evt:Dynamic, ?additionalData:Dynamic):ActionEvent {
		var scene = source.getScene();
		return new ActionEvent(source, scene.pointerX, scene.pointerY, scene.meshUnderPointer, additionalData);
	}
	
	/**
	 * Helper function to auto-create an ActionEvent from a source mesh.
	 * @param source The source sprite that triggered the event
	 * @param scene Scene associated with the sprite
	 * @param evt {Event} The original (browser) event
	 */
	public static function CreateNewFromSprite(source:Sprite, scene:Scene, ?evt:Dynamic, ?additionalData:Dynamic):ActionEvent {
		return new ActionEvent(source, scene.pointerX, scene.pointerY, scene.meshUnderPointer, evt, additionalData);
	}

	/**
	 * Helper function to auto-create an ActionEvent from a scene. If triggered by a mesh use ActionEvent.CreateNew
	 * @param scene the scene where the event occurred
	 * @param evt {Event} The original (browser) event
	 */
	public static function CreateNewFromScene(scene:Scene, evt:Dynamic):ActionEvent {
		return new ActionEvent(null, scene.pointerX, scene.pointerY, scene.meshUnderPointer, evt);
	}
	
	public static function CreateNewFromPrimitive(prim:Dynamic, pointerPos:Vector2, ?evt:Dynamic, ?additionalData:Dynamic): ActionEvent {
        return new ActionEvent(prim, pointerPos.x, pointerPos.y, null, evt, additionalData);
	}
	
}
