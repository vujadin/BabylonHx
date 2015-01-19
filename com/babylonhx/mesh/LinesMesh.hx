package com.babylonhx.mesh;

import com.babylonhx.collisions.PickingInfo;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.ShaderMaterial;
import com.babylonhx.materials.Material;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Ray;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.LinesMesh') class LinesMesh extends Mesh {
	
	public var color:Color3 = new Color3(1, 1, 1);
	public var alpha:Float = 1;

	private var _colorShader:ShaderMaterial;
	private var _ib:BabylonBuffer;

	private var _indicesLength:Int;
	private var _indices:Array<Int> = [];

	public function new(name:String, scene:Scene, updatable:Bool = false) {
		super(name, scene);
		
		this._colorShader = new ShaderMaterial("colorShader", scene, "color",
			{
				attributes: ["position"],
				uniforms: ["worldViewProjection", "color"],
				needAlphaBlending: true
			});
	}

	//public var material(get, never):Material;
	override private function get_material():Material {
		return this._colorShader;
	}

	//public var isPickable(get, never):Bool;
	override private function get_isPickable():Bool {
		return false;
	}

	//public var checkCollisions(get, never):Bool;
	override private function get_checkCollisions():Bool {
		return false;
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

	override public function intersects(ray:Ray, fastCheck:Bool = false/*?fastCheck:Bool*/):PickingInfo {
		return null;
	}

	override public function dispose(doNotRecurse:Bool = false/*?doNotRecurse:Bool*/) {
		this._colorShader.dispose();
		
		super.dispose(doNotRecurse);
	}
	
}
