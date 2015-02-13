package com.babylonhx.rendering;

import com.babylonhx.materials.ShaderMaterial;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Matrix;
import com.babylonhx.mesh.BabylonBuffer;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.mesh.VertexData;
import com.babylonhx.tools.SmartArray;
import com.babylonhx.culling.BoundingBox;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.BoundingBoxRenderer') class BoundingBoxRenderer {
	
	public var frontColor:Color3 = new Color3(1, 1, 1);
	public var backColor:Color3 = new Color3(0.1, 0.1, 0.1);
	public var showBackLines:Bool = true;
	public var renderList:SmartArray = new SmartArray(32);// SmartArray<BoundingBox> = new SmartArray<BoundingBox>(32);

	private var _scene:Scene;
	private var _colorShader:ShaderMaterial;
	private var _vb:VertexBuffer;
	private var _ib:BabylonBuffer;
	

	public function new(scene:Scene) {
		this._scene = scene;
		this._colorShader = new ShaderMaterial("colorShader", scene, "color",
			{
				attributes:["position"],
				uniforms:["worldViewProjection", "color"]
			});


		var engine = this._scene.getEngine();
		var boxdata = VertexData.CreateBox(1.0);
		this._vb = new VertexBuffer(engine, boxdata.positions, VertexBuffer.PositionKind, false);
		this._ib = engine.createIndexBuffer([0, 1, 1, 2, 2, 3, 3, 0, 4, 5, 5, 6, 6, 7, 7, 4, 0, 7, 1, 6, 2, 5, 3, 4]);
	}

	public function reset() {
		this.renderList.reset();
	}

	public function render() {
		if (this.renderList.length == 0 || !this._colorShader.isReady()) {
			return;
		}
		
		var engine = this._scene.getEngine();
		engine.setDepthWrite(false);
		this._colorShader._preBind();
		for (boundingBoxIndex in 0...this.renderList.length) {
			var boundingBox = this.renderList.data[boundingBoxIndex];
			var min = boundingBox.minimum;
			var max = boundingBox.maximum;
			var diff = max.subtract(min);
			var median = min.add(diff.scale(0.5));
			
			var worldMatrix = Matrix.Scaling(diff.x, diff.y, diff.z)
				.multiply(Matrix.Translation(median.x, median.y, median.z))
				.multiply(boundingBox.getWorldMatrix());
				
			// VBOs
			engine.bindBuffers(this._vb.getBuffer(), this._ib, [3], 3 * 4, this._colorShader.getEffect());
			
			if (this.showBackLines) {
				// Back
				engine.setDepthFunctionToGreaterOrEqual();
				this._scene.resetCachedMaterial();
				this._colorShader.setColor4("color", this.backColor.toColor4());
				this._colorShader.bind(worldMatrix);
				
				// Draw order
				engine.draw(false, 0, 24);
			}
			
			// Front
			engine.setDepthFunctionToLess();
			this._scene.resetCachedMaterial();
			this._colorShader.setColor4("color", this.frontColor.toColor4());
			this._colorShader.bind(worldMatrix);
			
			// Draw order
			engine.draw(false, 0, 24);
		}
		
		this._colorShader.unbind();
		engine.setDepthFunctionToLessOrEqual();
		engine.setDepthWrite(true);
	}

	public function dispose() {
		this._colorShader.dispose();
		this._vb.dispose();
		this._scene.getEngine()._releaseBuffer(this._ib);
	}
	
}
