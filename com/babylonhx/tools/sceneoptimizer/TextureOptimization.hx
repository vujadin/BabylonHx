package com.babylonhx.tools.sceneoptimizer;

import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.TextureOptimization') class TextureOptimization extends SceneOptimization {

	public var maximumSize:Int;
	
	
	public function new(priority:Int = 0, maximumSize:Int = 1024) {
		super(priority);
		
		this.maximumSize = maximumSize;
	}
	
	override public function apply(scene:Scene, updateSelectionTree:Bool = false):Bool {
		var allDone:Bool = true;
		
		for (index in 0...scene.textures.length) {
			var texture = scene.textures[index];
			
			if (Reflect.getProperty(texture, "canRescale") != true) {
				continue;
			}
			
			var currentSize = texture.getSize();
			var maxDimension = Math.max(currentSize.width, currentSize.height);
			
			if (maxDimension > this.maximumSize) {
				texture.scale(0.5);
				allDone = false;
			}
		}
		
		return allDone;
	}
	
}
