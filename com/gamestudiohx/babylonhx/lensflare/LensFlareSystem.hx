package com.gamestudiohx.babylonhx.lensflare;

import com.gamestudiohx.babylonhx.materials.Effect;
import com.gamestudiohx.babylonhx.mesh.Mesh;
import com.gamestudiohx.babylonhx.Scene;
import com.gamestudiohx.babylonhx.Engine;
import com.gamestudiohx.babylonhx.tools.math.Vector3;
import com.gamestudiohx.babylonhx.tools.math.Matrix;
import com.gamestudiohx.babylonhx.tools.math.Viewport;
import com.gamestudiohx.babylonhx.tools.math.Ray;
import openfl.gl.GLBuffer;

/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class LensFlareSystem {
	
	public var name:String;
	public var borderLimit:Float;
	public var lensFlares:Array<LensFlare>;
	public var _emitter:Dynamic;	// Emitter of the lens flare system : it can be a camera, a light or a mesh. 
	public var _scene:Scene;
	
	public var _vertexDeclaration:Array<Int>;
	public var _vertexStrideSize:Int;
	public var _vertexBuffer:BabylonGLBuffer;		
	public var _indexBuffer:BabylonGLBuffer;		
	public var _effect:Effect;				
	public var _positionX:Float;
	public var _positionY:Float;
	
	public var meshesSelectionPredicate:Mesh->Bool;
	

	public function new(name:String, emitter:Dynamic, scene:Scene) {
		this.lensFlares = [];
        this._scene = scene;
        this._emitter = emitter;
        this.name = name;
		
		borderLimit = 300;

        scene.lensFlareSystems.push(this);
        
        // VBO
        var vertices:Array<Float> = [];
        vertices.push(1);
		vertices.push(1);
        vertices.push(-1);
		vertices.push(1);
        vertices.push(-1);
		vertices.push(-1);
        vertices.push(1);
		vertices.push(-1);
        this._vertexDeclaration = [2];
        this._vertexStrideSize = 2 * 4;
        this._vertexBuffer = scene.getEngine().createVertexBuffer(vertices);

        // Indices
        var indices = [];
        indices.push(0);
        indices.push(1);
        indices.push(2);

        indices.push(0);
        indices.push(2);
        indices.push(3);

        this._indexBuffer = scene.getEngine().createIndexBuffer(indices);       

        // Effects
        this._effect = this._scene.getEngine().createEffect("lensFlare",
                    ["position"],
                    ["color", "viewportMatrix"],
                    ["textureSampler"], "");
					
		this.meshesSelectionPredicate = function(m:Mesh):Bool {
			return m.material != null && m.isVisible && m.isEnabled() && m.checkCollisions;
		};
	}
	
	public function getScene():Scene {
		return this._scene;
	}
	
	public function getEmitterPosition():Vector3 {
		return Reflect.field(this._emitter, "getAbsolutePosition") != null ? this._emitter.getAbsolutePosition() : this._emitter.position;
	}
	
	public function computeEffectivePosition(globalViewport:Viewport):Bool {
		var position = this.getEmitterPosition();

        position = Vector3.Project(position, Matrix.Identity(), this._scene.getTransformMatrix(), globalViewport);

        this._positionX = position.x;
        this._positionY = position.y;

        position = Vector3.TransformCoordinates(this.getEmitterPosition(), this._scene.getViewMatrix());

        if (position.z > 0) {
            if ((this._positionX > globalViewport.x) && (this._positionX < globalViewport.x + globalViewport.width)) {
                if ((this._positionY > globalViewport.y) && (this._positionY < globalViewport.y + globalViewport.height))
                    return true;
            }
        }

        return false;
	}
	
	public function _isVisible():Bool {
		var emitterPosition:Vector3 = this.getEmitterPosition();
        var direction:Vector3 = emitterPosition.subtract(this._scene.activeCamera.position);
        var distance:Float = direction.length();
        direction.normalize();
        
        var ray:Ray = new Ray(this._scene.activeCamera.position, direction);
        var pickInfo = this._scene.pickWithRay(ray, this.meshesSelectionPredicate, true);

        return !pickInfo.hit || pickInfo.distance > distance;
	}
	
	public function render():Bool {
		if (!this._effect.isReady())
            return false;

        var engine:Engine = this._scene.getEngine();
        var viewport = this._scene.activeCamera.viewport;
        var globalViewport:Viewport = viewport.toGlobal(engine);
        
        // Position
        if (!this.computeEffectivePosition(globalViewport)) {
            return false;
        }
        
        // Visibility
        if (!this._isVisible()) {
            return false;
        }

        // Intensity
        var awayX:Float = 0;
        var awayY:Float = 0;

        if (this._positionX < this.borderLimit + globalViewport.x) {
            awayX = this.borderLimit + globalViewport.x - this._positionX;
        } else if (this._positionX > globalViewport.x + globalViewport.width - this.borderLimit) {
            awayX = this._positionX - globalViewport.x - globalViewport.width + this.borderLimit;
        } else {
            awayX = 0;
        }

        if (this._positionY < this.borderLimit + globalViewport.y) {
            awayY = this.borderLimit + globalViewport.y - this._positionY;
        } else if (this._positionY > globalViewport.y + globalViewport.height - this.borderLimit) {
            awayY = this._positionY - globalViewport.y - globalViewport.height + this.borderLimit;
        } else {
            awayY = 0;
        }

        var away:Float = (awayX > awayY) ? awayX : awayY;
        if (away > this.borderLimit) {
            away = this.borderLimit;
        }

        var intensity:Float = 1.0 - (away / this.borderLimit);
        if (intensity < 0) {
            return false;
        }
        
        if (intensity > 1.0) {
            intensity = 1.0;
        }

        // Position
        var centerX:Float = globalViewport.x + globalViewport.width / 2;
        var centerY:Float = globalViewport.y + globalViewport.height / 2;
        var distX:Float = centerX - this._positionX;
        var distY:Float = centerY - this._positionY;

        // Effects
        engine.enableEffect(this._effect);
        engine.setState(false);
        engine.setDepthBuffer(false);
        engine.setAlphaMode(Engine.ALPHA_ADD);
        
        // VBOs
        engine.bindBuffers(this._vertexBuffer, this._indexBuffer, this._vertexDeclaration, this._vertexStrideSize, this._effect);

        // Flares
        for (index in 0...this.lensFlares.length) {
            var flare:LensFlare = this.lensFlares[index];

            var x = centerX - (distX * flare.position);
            var y = centerY - (distY * flare.position);
            
            var cw = flare.size;
            var ch = flare.size * engine.getAspectRatio(this._scene.activeCamera);
            var cx = 2 * (x / globalViewport.width) - 1.0;
            var cy = 1.0 - 2 * (y / globalViewport.height);
            
            var viewportMatrix = Matrix.FromValues(
                                    cw / 2, 0, 0, 0,
                                    0, ch / 2, 0, 0,
                                    0, 0, 1, 0,
                                    cx, cy, 0, 1);

            this._effect.setMatrix("viewportMatrix", viewportMatrix);
            
            // Texture
            this._effect.setTexture("textureSampler", flare.texture);

            // Color
            this._effect.setFloat4("color", flare.color.r * intensity, flare.color.g * intensity, flare.color.b * intensity, 1.0);

            // Draw order
            engine.draw(true, 0, 6);
        }
        
        engine.setDepthBuffer(true);
        engine.setAlphaMode(Engine.ALPHA_DISABLE);
        return true;
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

		// TODO - clean this array properly
        while (this.lensFlares.length > 0) {
            this.lensFlares[0].dispose();
        }

        // Remove from scene
        //var index = Lambda.indexOf(this._scene.lensFlareSystems, this);
        //this._scene.lensFlareSystems.splice(index, 1);
		this._scene.lensFlareSystems.remove(this);
	}
	
}
