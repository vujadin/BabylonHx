package com.babylonhx.postprocess;

import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.mesh.WebGLBuffer;
import com.babylonhx.materials.textures.InternalTexture;

import lime.utils.Float32Array;
import lime.utils.Int32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.PostProcessManager') class PostProcessManager {
	
	private var _scene:Scene;
	private var _indexBuffer:WebGLBuffer;
	private var _vertexBuffers:Map<String, VertexBuffer> = new Map();
	

	public function new(scene:Scene) {
		this._scene = scene;
	}
	
	private function _prepareBuffers() {
		if (this._vertexBuffers[VertexBuffer.PositionKind] != null) {
			return;
		}
		
		// VBO
		var vertices:Float32Array = new Float32Array([1, 1, -1, 1, -1, -1, 1, -1]);
		this._vertexBuffers[VertexBuffer.PositionKind] = new VertexBuffer(this._scene.getEngine(), vertices, VertexBuffer.PositionKind, false, false, 2);
		
		// Indices
		var indices:Int32Array = new Int32Array([0, 1, 2, 0, 2, 3]);		
		this._indexBuffer = this._scene.getEngine().createIndexBuffer(indices);
	}

	// Methods
	public function _prepareFrame(?sourceTexture:InternalTexture, ?postProcesses:Array<PostProcess>):Bool {
		var postProcesses = postProcesses != null ? postProcesses : this._scene.activeCamera._postProcesses;
		
		if (postProcesses.length == 0 || !this._scene.postProcessesEnabled) {
			return false;
		}
		
		postProcesses[0].activate(this._scene.activeCamera, sourceTexture, postProcesses != null);		
		return true;
	}
	
	public function directRender(postProcesses:Array<PostProcess>, ?targetTexture:InternalTexture) {
		var engine = this._scene.getEngine();
		
		for (index in 0...postProcesses.length) {
			if (index < postProcesses.length - 1) {
				postProcesses[index + 1].activate(this._scene.activeCamera, targetTexture);
			} 
			else {
				if (targetTexture != null) {
					engine.bindFramebuffer(targetTexture);
				} 
				else {
					engine.restoreDefaultFramebuffer();
				}
			}
			
			var pp = postProcesses[index];
			var effect = pp.apply();
			
			if (effect != null) {
				pp.onBeforeRenderObservable.notifyObservers(effect);
				
				// VBOs
				this._prepareBuffers();
				engine.bindBuffers(this._vertexBuffers, this._indexBuffer, effect);
				
				// Draw order
				engine.draw(true, 0, 6);
				
				pp.onAfterRenderObservable.notifyObservers(effect);
			}
		}
		
		// Restore depth buffer
		engine.setDepthBuffer(true);
		engine.setDepthWrite(true);
	}

	public function _finalizeFrame(doNotPresent:Bool = false, ?targetTexture:InternalTexture, faceIndex:Int = 0, ?postProcesses:Array<PostProcess>) {
		if (postProcesses == null) {
			postProcesses = this._scene.activeCamera._postProcesses;
		}
		
		if (postProcesses.length == 0 || !this._scene.postProcessesEnabled) {
			return;
		}
		
		var engine = this._scene.getEngine();
		
		for (index in 0...postProcesses.length) {
			if (index < postProcesses.length - 1) {
				postProcesses[index + 1].activate(this._scene.activeCamera, targetTexture);
			} 
			else {
				if (targetTexture != null) {
					engine.bindFramebuffer(targetTexture, faceIndex);
				} 
				else {
					engine.restoreDefaultFramebuffer();
				}
			}
			
			if (doNotPresent) {
				break;
			}
			
			var pp = postProcesses[index];
			var effect = pp.apply();
			
			if (effect != null) {
				pp.onBeforeRenderObservable.notifyObservers(effect);
				
				// VBOs
				this._prepareBuffers();
				engine.bindBuffers(this._vertexBuffers, this._indexBuffer, effect);
				
				// Draw order
				engine.draw(true, 0, 6);
				
				pp.onAfterRenderObservable.notifyObservers(effect);
			}
		}
		
		// Restore depth buffer
		engine.setDepthBuffer(true);
		engine.setDepthWrite(true);
		engine.setAlphaMode(Engine.ALPHA_DISABLE);
	}

	public function dispose() {
		var buffer = this._vertexBuffers[VertexBuffer.PositionKind];
		if (buffer != null) {
			buffer.dispose();
			this._vertexBuffers[VertexBuffer.PositionKind] = null;
		}
		
		if (this._indexBuffer != null) {
			this._scene.getEngine()._releaseBuffer(this._indexBuffer);
			this._indexBuffer = null;
		}
	}
	
}
