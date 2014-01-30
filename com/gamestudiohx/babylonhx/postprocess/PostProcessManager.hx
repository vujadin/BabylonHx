package com.gamestudiohx.babylonhx.postprocess;

import com.gamestudiohx.babylonhx.materials.Effect;
import com.gamestudiohx.babylonhx.mesh.Mesh.BabylonGLBuffer;
import com.gamestudiohx.babylonhx.Scene;


/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class PostProcessManager {
	
	public var _scene:Scene;
	public var _vertexDeclaration:Array<Int>;
	public var _vertexStrideSize:Int;
	public var _vertexBuffer:BabylonGLBuffer;
	public var _indexBuffer:BabylonGLBuffer;

	public function new(scene:Scene) {
		this._scene = scene;
        
        // VBO
        var vertices:Array<Float> = [1, 1, -1, 1, -1, -1, 1, -1];
        this._vertexDeclaration = [2];
        this._vertexStrideSize = 2 * 4;
        this._vertexBuffer = scene.getEngine().createVertexBuffer(vertices);

        // Indices
        var indices = [0, 1, 2, 0, 2, 3];
        this._indexBuffer = scene.getEngine().createIndexBuffer(indices);
	}
	
	public function _prepareFrame() {
        var postProcesses:Array<PostProcess> = this._scene.activeCamera._postProcesses;
        
        var postProcessesTakenIndices = this._scene.activeCamera._postProcessesTakenIndices;
    
        if (postProcessesTakenIndices.length == 0 || !this._scene.postProcessesEnabled) {
            return;
        }

        postProcesses[0].activate();
    }
	
	public function _finalizeFrame() {
        var postProcesses:Array<PostProcess> = this._scene.activeCamera._postProcesses;
        
        if (postProcesses.length == 0 || !this._scene.postProcessesEnabled) {
            return;
        }

        var engine = this._scene.getEngine();
        
        for (index in 0...postProcesses.length) {            
            if (index < postProcesses.length - 1) {
                postProcesses[index + 1].activate();
            } else {
                engine.restoreDefaultFramebuffer();
            }

            var effect:Effect = postProcesses[index].apply();

            if (effect != null) {
                // VBOs
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
