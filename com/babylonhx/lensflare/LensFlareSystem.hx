package com.babylonhx.lensflare;

import com.babylonhx.materials.Effect;
import com.babylonhx.culling.Ray;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Viewport;
import com.babylonhx.mesh.WebGLBuffer;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.tools.Tools;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.LensFlareSystem') class LensFlareSystem {
	
	public var name:String;
	public var lensFlares:Array<LensFlare> = new Array<LensFlare>();
	public var borderLimit:Float = 300;
	public var meshesSelectionPredicate:Mesh->Bool;
	public var layerMask:Int = 0x0FFFFFFF;
	public var id:String;

	private var _scene:Scene;
	private var _emitter:Dynamic;
	private var _vertexDeclaration:Array<Int>;
	private var _vertexStrideSize:Int;				// 2 * 4;
	private var _vertexBuffer:WebGLBuffer;
	private var _indexBuffer:WebGLBuffer;
	private var _effect:Effect;
	private var _positionX:Float;
	private var _positionY:Float;
	private var _isEnabled:Bool = true;	
	

	public function new(name:String, emitter:Dynamic, scene:Scene) {		
		this.name = name;
		this.id = name;
		this._scene = scene;
		this._emitter = emitter;
		scene.lensFlareSystems.push(this);
		
		this.meshesSelectionPredicate = function(m:Mesh):Bool {
			return m.material != null && m.isVisible && m.isEnabled() && m.isBlocker && ((m.layerMask & scene.activeCamera.layerMask) != 0);
		}
		
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
		var indices:Array<Int> = [];
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
	}

	public var isEnabled(get, null):Bool;
	private function get_isEnabled():Bool {
		return this._isEnabled;
	}
	private function set_isEnabled(value:Bool):Bool {
		this._isEnabled = value;
		return value;
	}

	public function getScene():Scene {
		return this._scene;
	}

	public function getEmitter():Dynamic {
		return this._emitter;
	}
	
	public function setEmitter(newEmitter:Dynamic) {
		this._emitter = newEmitter;
	}

	public function getEmitterPosition():Vector3 {
		return this._emitter.getAbsolutePosition != null ? this._emitter.getAbsolutePosition() : this._emitter.position;
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
		if (!this._isEnabled) {
			return false;
		}
		
		var emitterPosition = this.getEmitterPosition();
		var direction = emitterPosition.subtract(this._scene.activeCamera.position);
		var distance = direction.length();
		direction.normalize();
		
		var ray = new Ray(this._scene.activeCamera.position, direction);
		var pickInfo = this._scene.pickWithRay(ray, this.meshesSelectionPredicate, true);
		
		return !pickInfo.hit || pickInfo.distance > distance;
	}

	public function render():Bool {
		if (!this._effect.isReady()) {
			return false;
		}
		
		var engine = this._scene.getEngine();
		var viewport = this._scene.activeCamera.viewport;
		var globalViewport = viewport.toGlobal(engine.getRenderWidth(true), engine.getRenderHeight(true));
		
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
		} 
		else if (this._positionX > globalViewport.x + globalViewport.width - this.borderLimit) {
			awayX = this._positionX - globalViewport.x - globalViewport.width + this.borderLimit;
		} 
		else {
			awayX = 0;
		}
		
		if (this._positionY < this.borderLimit + globalViewport.y) {
			awayY = this.borderLimit + globalViewport.y - this._positionY;
		} 
		else if (this._positionY > globalViewport.y + globalViewport.height - this.borderLimit) {
			awayY = this._positionY - globalViewport.y - globalViewport.height + this.borderLimit;
		} 
		else {
			awayY = 0;
		}
		
		var away = (awayX > awayY) ? awayX :awayY;
		if (away > this.borderLimit) {
			away = this.borderLimit;
		}
		
		var intensity = 1.0 - (away / this.borderLimit);
		if (intensity < 0) {
			return false;
		}
		
		if (intensity > 1.0) {
			intensity = 1.0;
		}
		
		// Position
		var centerX = globalViewport.x + globalViewport.width / 2;
		var centerY = globalViewport.y + globalViewport.height / 2;
		var distX = centerX - this._positionX;
		var distY = centerY - this._positionY;
		
		// Effects
		engine.enableEffect(this._effect);
		engine.setState(false);
		engine.setDepthBuffer(false);
		engine.setAlphaMode(Engine.ALPHA_ONEONE);
		
		// VBOs
		engine.bindBuffers(this._vertexBuffer, this._indexBuffer, this._vertexDeclaration, this._vertexStrideSize, this._effect);
		
		// Flares
		for (index in 0...this.lensFlares.length) {
			var flare = this.lensFlares[index];
			
			var x = centerX - (distX * flare.position);
			var y = centerY - (distY * flare.position);
			
			var cw = flare.size;
			var ch = flare.size * engine.getAspectRatio(this._scene.activeCamera, true);
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

	public function dispose():Void {
		if (this._vertexBuffer != null) {
			this._scene.getEngine()._releaseBuffer(this._vertexBuffer);
			this._vertexBuffer = null;
		}
		
		if (this._indexBuffer != null) {
			this._scene.getEngine()._releaseBuffer(this._indexBuffer);
			this._indexBuffer = null;
		}
		
		while (this.lensFlares.length > 0) {
			this.lensFlares[0].dispose();
		}
		
		// Remove from scene
		this._scene.lensFlareSystems.remove(this);
	}
	
	public static function Parse(parsedLensFlareSystem:Dynamic, scene:Scene, rootUrl:String):LensFlareSystem {
		var emitter = scene.getLastEntryByID(parsedLensFlareSystem.emitterId);
		
		var _name = parsedLensFlareSystem.name != null ? parsedLensFlareSystem.name : "lensFlareSystem#" + parsedLensFlareSystem.emitterId;
		
		var lensFlareSystem = new LensFlareSystem(_name, emitter, scene);
		if (parsedLensFlareSystem.id != null) {
            lensFlareSystem.id = parsedLensFlareSystem.id;
        }
		lensFlareSystem.borderLimit = parsedLensFlareSystem.borderLimit;
		
		var _flares:Array<Dynamic> = cast parsedLensFlareSystem.flares;
		for (index in 0..._flares.length) {
			var parsedFlare = _flares[index];
			var flare = new LensFlare(parsedFlare.size, parsedFlare.position, Color3.FromArray(parsedFlare.color), rootUrl + parsedFlare.textureName, lensFlareSystem);
		}
		
		return lensFlareSystem;
	}

	public function serialize():Dynamic {
		var serializationObject:Dynamic = { };
		
		serializationObject.id = this.id;
        serializationObject.name = this.name;
		
		serializationObject.emitterId = this.getEmitter().id;
		serializationObject.borderLimit = this.borderLimit;
		
		serializationObject.flares = [];
		for (index in 0...this.lensFlares.length) {
			var flare = this.lensFlares[index];
			
			serializationObject.flares.push({
				size: flare.size,
				position: flare.position,
				color: flare.color.asArray(),
				textureName: Tools.GetFilename(flare.texture.name)
			});
		}
		
		return serializationObject;
	}
	
}
