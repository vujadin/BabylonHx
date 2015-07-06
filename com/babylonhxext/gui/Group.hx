package babylonhxext.gui;

import com.babylonhxext.gui.System;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * A group of GUI elements
 * @param name
 * @param gui
 * @constructor
 */
class Group {
	
	public var guiSystem:System;
	public var name:String;
	public var elements:Array<Dynamic>;
	

	public function new(name:String, guiSystem:System) {
		this.guiSystem = gui;
        this.name = name;
        this.elements = [];
        this.guiSystem.groups.push(this);
	}
	
	/**
     * Set visible or invisible each element of the group
     * @param bool
     */
    public function setVisible(bool:Bool) {
        for(e in this.elements) {
            e.setVisible(bool);
        }
    }
	
    public function add(guiElement:Dynamic) {
        this.elements.push(guiElement);
    }
	
}
