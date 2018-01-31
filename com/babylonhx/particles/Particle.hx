package com.babylonhx.particles;

import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color4;


/**
 * ...
 * @author Krtolica Vujadin
 */
/**
 * A particle represents one of the element emitted by a particle system.
 * This is mainly define by its coordinates, direction, velocity and age.
 */
@:expose('BABYLON.Particle') class Particle {
	
	/**
	 * The world position of the particle in the scene.
	 */
	public var position:Vector3 = Vector3.Zero();
	
	/**
	 * The world direction of the particle in the scene.
	 */
	public var direction:Vector3 = Vector3.Zero();
	
	/**
	 * The color of the particle.
	 */
	public var color:Color4 = new Color4(0, 0, 0, 0);
	
	/**
	 * The color change of the particle per step.
	 */
	public var colorStep:Color4 = new Color4(0, 0, 0, 0);
	
	/**
	 * Defines how long will the life of the particle be.
	 */
	public var lifeTime:Float = 1.0;
	
	/**
	 * The current age of the particle.
	 */
	public var age:Float = 0;
	
	/**
	 * The current size of the particle.
	 */
	public var size:Float = 0;
	
	/**
	 * The current angle of the particle.
	 */
	public var angle:Float = 0;
	
	/**
	 * Defines how fast is the angle changing.
	 */
	public var angularSpeed:Float = 0;
	
	/**
	 * Defines the cell index used by the particle to be rendered from a sprite.
	 */
	public var cellIndex:Int = 0;
	
	private var _currentFrameCounter:Float = 0;
	
	private var particleSystem:ParticleSystem;
	

	/**
	 * Creates a new instance of @see Particle
	 * @param particleSystem the particle system the particle belongs to
	 */
	public function new(particleSystem:ParticleSystem) {
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
	
	/**
	 * Defines how the sprite cell index is updated for the particle. This is 
	 * defined as a callback.
	 */
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
	
	/**
	 * Copy the properties of particle to another one.
	 * @param other the particle to copy the information to.
	 */
	public function copyTo(other:Particle) {
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
