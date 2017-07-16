package com.babylonhx.mesh.simplification;

import com.babylonhx.mesh.Mesh;
import com.babylonhx.tools.AsyncLoop;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.SimplificationQueue') class SimplificationQueue {
	
	private var _simplificationArray:Array<SimplificationTask>;
	public var running:Bool;
	

	public function new() {
		this.running = false;
		this._simplificationArray = [];
	}
	
	public function addTask(task:SimplificationTask) {
		this._simplificationArray.push(task);
	}

	public function executeNext() {
		var task = this._simplificationArray.pop();
		if (task != null) {
			this.running = true;
			this.runSimplification(task);
		} 
		else {
			this.running = false;
		}
	}

	public function runSimplification(task:SimplificationTask) {
		
		if (task.parallelProcessing) {
			//parallel simplifier
			for(setting in task.settings) {
				var simplifier = this.getSimplifier(task);
				simplifier.simplify(setting, function(newMesh:Mesh) {
					task.mesh.addLODLevel(setting.distance, newMesh);
					newMesh.isVisible = true;
					//check if it is the last
					if (setting.quality == task.settings[task.settings.length - 1].quality && task.successCallback != null) {
						//all done, run the success callback.
						task.successCallback();
					}
					this.executeNext();
				});
			}
		} else {
			//single simplifier.
			var simplifier = this.getSimplifier(task);
			
			var runDecimation = function(setting:ISimplificationSettings, callback:Void->Void) {
				simplifier.simplify(setting, function(newMesh:Mesh) {
					task.mesh.addLODLevel(setting.distance, newMesh);
					newMesh.isVisible = true;
					//run the next quality level
					callback();
				});
			}
			
			AsyncLoop.Run(task.settings.length, function(loop:AsyncLoop) {
				runDecimation(task.settings[loop.index], function() {
					loop.executeNext();
				});
			},function() {
				//execution ended, run the success callback.
				if (task.successCallback != null) {
					task.successCallback();
				}
				this.executeNext();
			});
		}
	}

	private function getSimplifier(task:SimplificationTask):ISimplifier {
		switch (task.simplificationType) {
			case SimplificationSettings.QUADRATIC:
				return new QuadraticErrorSimplification(task.mesh);
				
			default:
				return new QuadraticErrorSimplification(task.mesh);
		}
		
		return null;
	}
	
}
