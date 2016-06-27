package com.babylonhx.mesh;

import com.babylonhx.collisions.PickingInfo;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.ShaderMaterial;
import com.babylonhx.materials.Material;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector2;
import com.babylonhx.culling.Ray;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.LinesMesh') class LinesMesh extends Mesh {
	
	public var color:Color3 = new Color3(1, 1, 1);
	public var alpha:Float = 1;
	
	public var dashSize:Float = 0;
	public var gapSize:Float = 0;

	public var intersectionThreshold(get, set):Float;
	private var _intersectionThreshold:Float;
	private var _colorShader:ShaderMaterial;
	

	public function new(name:String, scene:Scene, parent:Node = null, ?source:LinesMesh, doNotCloneChildren:Bool = false) {
		super(name, scene, parent, source, doNotCloneChildren);
		
		if (source != null) {
            this.color = source.color.clone();
            this.alpha = source.alpha;
        }
		
		this._intersectionThreshold = 0.1;
		this._colorShader = new ShaderMaterial("colorShader", scene, "color",
			{
				attributes: ["position"],
				uniforms: ["worldViewProjection", "color"],
				needAlphaBlending: true
			});
	}
	
	/**
	 * The intersection Threshold is the margin applied when intersection a segment of the LinesMesh with a Ray.
	 * This margin is expressed in world space coordinates, so its value may vary.
	 * Default value is 0.1
	 * @returns the intersection Threshold value.
	 */
	private function get_intersectionThreshold():Float {
		return this._intersectionThreshold;
	}

	/**
	 * The intersection Threshold is the margin applied when intersection a segment of the LinesMesh with a Ray.
	 * This margin is expressed in world space coordinates, so its value may vary.
	 * @param value the new threshold to apply
	 */
	public function set_intersectionThreshold(value:Float):Float {
		if (this._intersectionThreshold == value) {
			return value;
		}
		
		this._intersectionThreshold = value;
		if (this.geometry != null) {
			this.geometry.boundingBias = new Vector2(0, value);
		}
		
		return value;
	}

	override private function get_material():Material {
		return this._colorShader;
	}

	override private function get_checkCollisions():Bool {
		return false;
	}
	
	override public function createInstance(name:String):InstancedMesh {
		trace("LinesMeshes do not support createInstance.");
		
		return null;
	}

	override public function _bind(subMesh:SubMesh, effect:Effect, fillMode:Int) {
		var engine = this.getScene().getEngine();
		
		var indexToBind = this._geometry.getIndexBuffer();
		
		// VBOs
		engine.bindBuffers(this._geometry.getVertexBuffer(VertexBuffer.PositionKind).getBuffer(), indexToBind, [3], 3 * 4, this._colorShader.getEffect());
		
		// Color
		this._colorShader.setColor4("color", this.color.toColor4(this.alpha));
	}

	override public function _draw(subMesh:SubMesh, fillMode:Int, ?instancesCount:Int) {
		if (this._geometry == null || this._geometry.getVertexBuffers() == null || this._geometry.getIndexBuffer() == null) {
			return;
		}
		
		var engine = this.getScene().getEngine();
		
		// Draw order
		engine.draw(false, subMesh.indexStart, subMesh.indexCount);
	}

	override public function dispose(doNotRecurse:Bool = false) {
		this._colorShader.dispose();
		
		super.dispose(doNotRecurse);
	}
	
	override public function clone(name:String, ?newParent:Node, doNotCloneChildren:Bool = false):LinesMesh {
		return new LinesMesh(name, this.getScene(), newParent, this, doNotCloneChildren);
	}
	
}
