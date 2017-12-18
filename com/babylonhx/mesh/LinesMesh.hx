package com.babylonhx.mesh;

import com.babylonhx.collisions.PickingInfo;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.ShaderMaterial;
import com.babylonhx.materials.Material;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector2;
import com.babylonhx.culling.Ray;
import com.babylonhx.tools.Tools;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.LinesMesh') class LinesMesh extends Mesh {
	
	public var dashSize:Float = 0;
	public var gapSize:Float = 0;
	
	public var color:Color3 = new Color3(1, 1, 1);
	public var alpha:Float = 1;
	
	public var useVertexColor:Bool = false;
	public var useVertexAlpha:Bool = false;

	private var _intersectionThreshold:Float;
	private var _colorShader:ShaderMaterial;
	
	/**
	 * The intersection Threshold is the margin applied when intersection a segment of the LinesMesh with a Ray.
	 * This margin is expressed in world space coordinates, so its value may vary.
	 * Default value is 0.1
	 * @returns the intersection Threshold value.
	 */
	public var intersectionThreshold(get, set):Float;
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
	

	public function new(name:String, scene:Scene, parent:Node = null, ?source:LinesMesh, doNotCloneChildren:Bool = false, useVertexColor:Bool = false, useVertexAlpha:Bool = false) {
		super(name, scene, parent, source, doNotCloneChildren);
		
		if (source != null) {
            this.color = source.color.clone();
            this.alpha = source.alpha;
			this.useVertexColor = source.useVertexColor;
			this.useVertexAlpha = source.useVertexAlpha;
        }
		
		this._intersectionThreshold = 0.1;
		
		var defines:Array<String> = [];
		var options = {
			attributes: [VertexBuffer.PositionKind],
			uniforms: ["world", "viewProjection"],
			needAlphaBlending: true,
			defines: defines
		};
		
		if (useVertexAlpha == false) {
            options.needAlphaBlending = false;
        }
		
		if (!useVertexColor) {
			options.uniforms.push("color");
		}
		else {
			options.defines.push("#define VERTEXCOLOR");
			options.attributes.push(VertexBuffer.ColorKind);
		}
		
		this._colorShader = new ShaderMaterial("colorShader", this.getScene(), "color", options);
	}
	
	override public function getClassName():String {
		return "LinesMesh";
	}

	override private function get_material():Material {
		return this._colorShader;
	}

	override private function get_checkCollisions():Bool {
		return false;
	}
	
	override public function createInstance(name:String):InstancedMesh {
		Tools.Log("LinesMeshes do not support createInstance.");		
		return null;
	}

	override public function _bind(subMesh:SubMesh, effect:Effect, fillMode:Int) {
		// VBOs
		this._geometry._bind(this._colorShader.getEffect() );
		
		// Color
		if (!this.useVertexColor) {
			this._colorShader.setColor4("color", this.color.toColor4(this.alpha));
		}
	}

	// BHX: alternate needed, iherited from mesh._draw()
	override public function _draw(subMesh:SubMesh, fillMode:Int, instancesCount:Int = 0, alternate:Bool = false) {
		if (this._geometry == null || this._geometry.getVertexBuffers() == null || this._geometry.getIndexBuffer() == null) {
			return;
		}
		
		var engine = this.getScene().getEngine();
		
		// Draw order
		engine.drawElementsType(Material.LineListDrawMode, subMesh.indexStart, subMesh.indexCount);
	}

	override public function dispose(doNotRecurse:Bool = false) {
		this._colorShader.dispose();
		
		super.dispose(doNotRecurse);
	}
	
	override public function clone(name:String, newParent:Node = null, doNotCloneChildren:Bool = false):LinesMesh {
		return new LinesMesh(name, this.getScene(), newParent, this, doNotCloneChildren);
	}
	
}
