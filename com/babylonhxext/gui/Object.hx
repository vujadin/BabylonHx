package com.babylonhxext.gui;

import com.babylonhx.actions.ActionManager;
import com.babylonhx.actions.ExecuteCodeAction;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * Represents an object in the gui system
 * @param mesh
 * @param guisystem
 * @param onclick
 * @constructor
 */
class Object {
	
	public var mesh:Mesh;
	public var guiSystem:System;
	public var onClick:Dynamic;
	
	public var guiPosition:Vector3;
	

	public function new(mesh:Mesh, guiSystem:System) {
		this.mesh = mesh;
        this.guiSystem = guiSystem;
        this.onClick = null;
		
        this.mesh.actionManager = new ActionManager(guiSystem.getScene());
		
        var updateOnPointerUp = new ExecuteCodeAction(ActionManager.OnPickUpTrigger,
            function(e:Dynamic) {
                if (this.onClick != null) {
                    this.onClick(e);
                }
            }
        );
        this.mesh.actionManager.registerAction(updateOnPointerUp);
		
        this.mesh.layerMask = System.LAYER_MASK;
		
        this.guiSystem.objects.push(this);
		
        // The object position in the gui system
        this.guiposition(Vector3.Zero());
	}
	
	/**
     * Set the absolute position of this object in the gui world
     * @param guiposition
     */
    public function guiposition(gp:Vector3) {
        this.guiPosition = gp;
		
        // Update the object posion
        this.mesh.position = new Vector3(
            gp.x / this.guiSystem.zoom - this.guiSystem.guiWidth / 2,
            this.guiSystem.guiHeight / 2 - gp.y / this.guiSystem.zoom,
            gp.z);
    }
	
    /**
     * Set the object in percentage position of the screen.
     * @param wp
     * @param hp
     * @param z
     */
    public function relativePosition(pos:Vector3):Vector3 {
        if (pos) {
            this.mesh.position.x = this.guiSystem.guiWidth * pos.x - this.guiSystem.guiWidth / 2;
            this.mesh.position.y = this.guiSystem.guiHeight * (1 - pos.y) - this.guiSystem.guiHeight / 2;
            this.mesh.position.z = pos.z;
			return this.mesh.position;
        } 
		else {
            return new Vector3(
                (this.mesh.position.x + this.guiSystem.guiWidth / 2) / this.guiSystem.guiWidth,
                (this.guiSystem.guiHeight / 2 - this.mesh.position.y) / this.guiSystem.guiHeight,
                this.mesh.position.z
            );
        }
    }
	
    public function position(?pos:Vector3):Vector3 {
        if (pos != null) {
            // Update the object position
            this.mesh.position = pos;
            // Compute the gui position
            this.guiPosition = new Vector3(
                this.guiSystem.guiWidth / 2 + pos.x,
                this.guiSystem.guiHeight / 2 + pos.y,
                pos.z);
        } 
		
        return this.mesh.position;
    }
	
    public function scaling(?scale:Float) {
        if (scale != null) {
            // Update the object position
            this.mesh.scaling = scale;
        } 
		
        return this.mesh.scaling;
    }
    
	public function dispose() {
        this.mesh.dispose();
    }
	
    public function setVisible(bool:Bool) {
        this.mesh.isVisible = bool;
    }
	
}
