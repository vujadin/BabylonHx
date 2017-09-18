package com.babylonhx.particles;

import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color4;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Particle') class Particle {
	
	public var position:Vector3 = Vector3.Zero();
	public var direction:Vector3 = Vector3.Zero();
	public var color:Color4 = new Color4(0, 0, 0, 0);
	public var colorStep:Color4 = new Color4(0, 0, 0, 0);
	
	public var lifeTime:Float = 1.0;
	public var age:Float = 0;
	public var size:Float = 0;
	public var angle:Float = 0;
	public var angularSpeed:Float = 0;
	
	private var _currentFrameCounter:Float = 0;
	public var cellIndex:Int = 0;
	
	private var particleSystem:ParticleSystem;
	

	inline public function new(particleSystem:ParticleSystem) {
		this.particleSystem = particleSystem;
		if (!this.particleSystem.isAnimationSheetEnabled) {
			return;
		}
		
		this.cellIndex = this.particleSystem.startSpriteCellID;
		
		if (this.particleSystem.spriteCellChangeSpeed == 0) {
			this.updateCellIndex = this.updateCellIndexWithSpeedCalculated;
		}
		else {
			this.updateCellIndex = this.updateCellIndexWithCustomSpeed;
		}
	}
	
	public var updateCellIndex:Float->Void;
	
	private function updateCellIndexWithSpeedCalculated(scaledUpdateSpeed:Float) {
		//   (ageOffset / scaledUpdateSpeed) / available cells
		var numberOfScaledUpdatesPerCell = ((this.lifeTime - this.age) / scaledUpdateSpeed) / (this.particleSystem.endSpriteCellID + 1 - this.cellIndex);
		
		this._currentFrameCounter += scaledUpdateSpeed;
		if (this._currentFrameCounter >= numberOfScaledUpdatesPerCell * scaledUpdateSpeed) {
			this._currentFrameCounter = 0;
			this.cellIndex++;
			if (this.cellIndex > this.particleSystem.endSpriteCellID) {
				this.cellIndex = this.particleSystem.endSpriteCellID;
			}
		}
	}

	private function updateCellIndexWithCustomSpeed(scaledUpdateSpeed:Float = 0) {
		if (this._currentFrameCounter >= this.particleSystem.spriteCellChangeSpeed) {
			this.cellIndex++;
			this._currentFrameCounter = 0;
			if (this.cellIndex > this.particleSystem.endSpriteCellID) {
				if (this.particleSystem.spriteCellLoop) {
					this.cellIndex = this.particleSystem.startSpriteCellID;
				}
				else {
					this.cellIndex = this.particleSystem.endSpriteCellID;
				}
			}
		}
		else {
			this._currentFrameCounter++;
		}
	}
	
	inline public function copyTo(other:Particle) {
		other.position.copyFrom(this.position);
		other.direction.copyFrom(this.direction);
		other.color.copyFrom(this.color);
		other.colorStep.copyFrom(this.colorStep);
		other.lifeTime = this.lifeTime;
		other.age = this.age;
		other.size = this.size;
		other.angle = this.angle;
		other.angularSpeed = this.angularSpeed;
		other.particleSystem = this.particleSystem;
		other.cellIndex = this.cellIndex;
	}
	
}
