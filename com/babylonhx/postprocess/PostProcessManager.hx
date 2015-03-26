package com.babylonhx.postprocess;

import com.babylonhx.mesh.BabylonBuffer;
import com.babylonhx.materials.textures.BabylonTexture;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.PostProcessManager') class PostProcessManager {
	
	private var _scene:Scene;
	private var _indexBuffer:BabylonBuffer;
	private var _vertexDeclaration:Array<Int> = [2];
	private var _vertexStrideSize:Int = 2 * 4;
	private var _vertexBuffer:BabylonBuffer;
	

	public function new(scene:Scene) {
		this._scene = scene;
	}
	
	private function _prepareBuffers() {
		if (this._vertexBuffer != null) {
			return;
		}
		
		// VBO
		var vertices:Array<Float> = [];
		vertices.push(1);
		vertices.push(1);
		vertices.push( -1);
		vertices.push(1);
		vertices.push( -1);
		vertices.push(-1);
		vertices.push(1);
		vertices.push(-1);
		this._vertexBuffer = this._scene.getEngine().createVertexBuffer(vertices);
		
		// Indices
		var indices:Array<Int> = [];
		indices.push(0);
		indices.push(1);
		indices.push(2);
		
		indices.push(0);
		indices.push(2);
		indices.push(3);
		
		this._indexBuffer = this._scene.getEngine().createIndexBuffer(indices);
	}

	// Methods
	public function _prepareFrame(?sourceTexture:BabylonTexture):Bool {
		var postProcesses = this._scene.activeCamera._postProcesses;
		var postProcessesTakenIndices = this._scene.activeCamera._postProcessesTakenIndices;
		
		if (postProcessesTakenIndices.length == 0 || !this._scene.postProcessesEnabled) {
			return false;
		}
		
		postProcesses[this._scene.activeCamera._postProcessesTakenIndices[0]].activate(this._scene.activeCamera, sourceTexture);
		
		return true;
	}
	
	public function directRender(postProcesses:Array<PostProcess>, ?targetTexture:BabylonTexture) {
		var engine = this._scene.getEngine();
		
		for (index in 0...postProcesses.length) {
			if (index < postProcesses.length - 1) {
				postProcesses[index + 1].activate(this._scene.activeCamera, targetTexture);
			} else {
				if (targetTexture != null) {
					engine.bindFramebuffer(targetTexture);
				} else {
					engine.restoreDefaultFramebuffer();
				}
			}
			
			var pp = postProcesses[index];
			var effect = pp.apply();
			
			if (effect != null) {
				if (pp.onBeforeRender != null) {
					pp.onBeforeRender(effect);
				}
				
				// VBOs
				this._prepareBuffers();
				engine.bindBuffers(this._vertexBuffer, this._indexBuffer, this._vertexDeclaration, this._vertexStrideSize, effect);
				
				// Draw order
				engine.draw(true, 0, 6);
			}
		}
		
		// Restore depth buffer
		engine.setDepthBuffer(true);
		engine.setDepthWrite(true);
	}

	public function _finalizeFrame(doNotPresent:Bool = false, ?targetTexture:BabylonTexture, ?postProcesses:Array<PostProcess>) {
		if (postProcesses == null) {
			postProcesses = this._scene.activeCamera._postProcesses;
		}
		
		var postProcessesTakenIndices = this._scene.activeCamera._postProcessesTakenIndices;
		if (postProcessesTakenIndices.length == 0 || !this._scene.postProcessesEnabled) {
			return;
		}
		
		var engine = this._scene.getEngine();
		
		for (index in 0...postProcessesTakenIndices.length) {
			if (index < postProcessesTakenIndices.length - 1) {
				postProcesses[postProcessesTakenIndices[index + 1]].activate(this._scene.activeCamera);
			} else {
				if (targetTexture != null) {
					engine.bindFramebuffer(targetTexture);
				} else {
					engine.restoreDefaultFramebuffer();
				}
			}
			
			if (doNotPresent) {
				break;
			}
			
			var pp = postProcesses[postProcessesTakenIndices[index]];
			var effect = pp.apply();
			
			if (effect != null) {
				if (pp.onBeforeRender != null) {
					pp.onBeforeRender(effect);
				}
				
				// VBOs
				this._prepareBuffers();
				engine.bindBuffers(this._vertexBuffer, this._indexBuffer, this._vertexDeclaration, this._vertexStrideSize, effect);
				
				// Draw order
				engine.draw(true, 0, 6);
			}
		}
		
		// Restore depth buffer
		engine.setDepthBuffer(true);
		engine.setDepthWrite(true);
	}

	public function dispose() {
		if (this._vertexBuffer != null) {
			this._scene.getEngine()._releaseBuffer(this._vertexBuffer);
			this._vertexBuffer = null;
		}
		
		if (this._indexBuffer != null) {
			this._scene.getEngine()._releaseBuffer(this._indexBuffer);
			this._indexBuffer = null;
		}
	}
	
}
