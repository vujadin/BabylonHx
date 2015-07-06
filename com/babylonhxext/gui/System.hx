package com.babylonhxext.gui;

import com.babylonhx.cameras.Camera;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */

// based on https://github.com/Temechon/bGUI

/**
 * The main part of bGUI system.
 * @param scene The scene to build the GUI on
 * @param guiWidth The desired guiWidth
 * @param guiHeight The desired guiHeight
 * @constructor
 */
class System {
	
	public static inline var LAYER_MASK:Int = 8;
	
	private var _scene:Scene;
	public var _camera:Camera;
	public var zoom:Float;
	public var objects:Array<Object>;
	public var groups:Array<Group>;
	

	public function new(scene:Scene, guiWidth:Int, guiHeight:Int) {
		// The babylon scene
        this._scene = scene;
		
        // Push the activecamera in activeCameras
        var mainCam = scene.activeCamera;
        this._scene.activeCameras.push(mainCam);
		
        // Compute the zoom level for the camera
        this.zoom = Math.max(guiWidth, guiHeight) / Math.max(scene.getEngine().getRenderingCanvas().width, scene.getEngine().getRenderingCanvas().height);
		
        // Init the GUI camera
        this._camera = null;
        this._initCamera();
		
        this._scene.activeCamera = mainCam;
		
        // Contains all gui objects
        this.objects = [];
		
        // Contains all gui groups
        this.groups = [];
	}
	
	public function getScene():Scene {
        return this._scene;
    }
	
	private function _initCamera() {
        this._camera =  new FreeCamera("GUICAMERA", new Vector3(0,0,-30), this._scene);
        this._camera.mode = Camera.ORTHOGRAPHIC_CAMERA;
        this._camera.setTarget(Vector3.Zero());
        this._camera.layerMask = System.LAYER_MASK;
		
        var width = this._scene.getEngine().getRenderWidth();
        var height = this._scene.getEngine().getRenderHeight();
		
        var right = width;
        var top = height;
        this._camera.orthoTop = top / 2;
        this._camera.orthoRight = right / 2;
        this._camera.orthoBottom = -top / 2;
        this._camera.orthoLeft = -right / 2;
		
        this.guiWidth = right;
        this.guiHeight = top;
		
        this._scene.activeCameras.push(this._camera);
		
        // The camera to use for picks
        this._scene.cameraToUseForPointers = this._camera;
    }
	
	public function dispose() {
		for (object in objects) {
			object.dispose();
		}
        this._camera.dispose();
    }
	
	public function add(mesh:Mesh):Object {
        var p = new Object(mesh, this);
        this.objects.push(p);
        return p;
    }
	
	/**
     * Return a GUi object by its name. Returns the first object found in the list.
     * Returns null if not found
     * @param name
     */
    public function getObjectByName(name:String):Object {
        for (object in objects) {
            if (object.mesh.name == name) {
                return object;
            }
        }
        return null;
    }
	
	/**
     * Returns a GUIGroup by its name
     * @param name
     * @returns {GUIGroup}
     */
	public function getGroupByName(name:String):Group {
        for (group in groups) {
            if (group.name == name) {
                return group;
            }
        }
        return null;
    }
	
}
