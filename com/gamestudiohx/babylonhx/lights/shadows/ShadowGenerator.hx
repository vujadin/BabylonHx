package com.gamestudiohx.babylonhx.lights.shadows;

import com.gamestudiohx.babylonhx.Engine;
import com.gamestudiohx.babylonhx.lights.Light;
import com.gamestudiohx.babylonhx.lights.DirectionalLight;
import com.gamestudiohx.babylonhx.materials.Effect;
import com.gamestudiohx.babylonhx.materials.textures.RenderTargetTexture;
import com.gamestudiohx.babylonhx.materials.textures.Texture;
import com.gamestudiohx.babylonhx.mesh.Mesh;
import com.gamestudiohx.babylonhx.mesh.SubMesh;
import com.gamestudiohx.babylonhx.mesh.VertexBuffer;
import com.gamestudiohx.babylonhx.Scene;
import com.gamestudiohx.babylonhx.tools.math.Matrix;
import com.gamestudiohx.babylonhx.tools.math.Vector3;
import com.gamestudiohx.babylonhx.tools.SmartArray;


/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class ShadowGenerator {
	
	public var _light:Light;
	public var _scene:Scene;
	
	public var _shadowMap:RenderTargetTexture;
	
	public var _viewMatrix:Matrix;
	public var _projectionMatrix:Matrix;
	public var _transformMatrix:Matrix;
	public var _worldViewProjection:Matrix;
	
	public var useVarianceShadowMap:Bool;
	
	public var _cachedDefines:String;
	public var _cachedPosition:Vector3;
	public var _cachedDirection:Vector3;
	
	public var _effect:Effect;
	

	public function new(mapSize:Float, light:Light) {
		this._light = light;
        this._scene = light.getScene();

        light._shadowGenerator = this;

        // Render target
        this._shadowMap = new RenderTargetTexture(light.name + "_shadowMap", mapSize, this._scene, false);
        this._shadowMap.wrapU = Texture.CLAMP_ADDRESSMODE;
        this._shadowMap.wrapV = Texture.CLAMP_ADDRESSMODE;
        this._shadowMap.renderParticles = false;
                
        // Custom render function
        var renderSubMesh = function (subMesh:SubMesh) {
            var mesh:Mesh = subMesh.getMesh();
            var world:Matrix = mesh.getWorldMatrix();
            var engine:Engine = this._scene.getEngine();

            if (this.isReady(mesh)) {
                engine.enableEffect(this._effect);
                
                // Bones
                if (mesh.skeleton != null && mesh.isVerticesDataPresent(VertexBuffer.MatricesIndicesKind) && mesh.isVerticesDataPresent(VertexBuffer.MatricesWeightsKind)) {
                    this._effect.setMatrix("world", world);
                    this._effect.setMatrix("viewProjection", this.getTransformMatrix());

                    this._effect.setMatrices("mBones", mesh.skeleton.getTransformMatrices());
                } else {
                    world.multiplyToRef(this.getTransformMatrix(), this._worldViewProjection);
                    this._effect.setMatrix("worldViewProjection", this._worldViewProjection);
                }

                // Bind and draw
                mesh.bindAndDraw(subMesh, this._effect, false);
            }
        };

        this._shadowMap.customRenderFunction = function(opaqueSubMeshes:SmartArray, alphaTestSubMeshes:SmartArray) {
            for (index in 0...opaqueSubMeshes.length) {
                renderSubMesh(opaqueSubMeshes.data[index]);
            }
            
            for (index in 0...alphaTestSubMeshes.length) {
                renderSubMesh(alphaTestSubMeshes.data[index]);
            }
        };
        
        // Internals
        this._viewMatrix = Matrix.Zero();
        this._projectionMatrix = Matrix.Zero();
        this._transformMatrix = Matrix.Zero();
        this._worldViewProjection = Matrix.Zero();
		
		this.useVarianceShadowMap = true;
	}
	
	public function isReady(mesh:Mesh):Bool {
        var defines:Array<String> = [];
        
        if (this.useVarianceShadowMap) {
            defines.push("#define VSM");
        }
        
        var attribs:Array<String> = [VertexBuffer.PositionKind];
        if (mesh.skeleton != null && mesh.isVerticesDataPresent(VertexBuffer.MatricesIndicesKind) && mesh.isVerticesDataPresent(VertexBuffer.MatricesWeightsKind)) {
            attribs.push(VertexBuffer.MatricesIndicesKind);
            attribs.push(VertexBuffer.MatricesWeightsKind);
            defines.push("#define BONES");
            defines.push("#define BonesPerMesh " + mesh.skeleton.bones.length);
        }

        // Get correct effect      
        var join:String = defines.join("\n");
        if (this._cachedDefines != join) {
            this._cachedDefines = join;
            this._effect = this._scene.getEngine().createEffect("shadowMap",
                attribs,
                ["world", "mBones", "viewProjection", "worldViewProjection"],
                [], join);
        }

        return this._effect.isReady();
    }
	
	public function getShadowMap():RenderTargetTexture {
        return this._shadowMap;
    }
	
	public function getLight():Light {
        return this._light;
    }
	
	inline public function getTransformMatrix():Matrix {
        var lightPosition = Reflect.field(this._light, "position");
        var lightDirection = Reflect.field(this._light, "direction");
        
        if (cast(this._light, DirectionalLight)._computeTransformedPosition()) {
            lightPosition = cast(this._light, DirectionalLight)._transformedPosition;
        }

        if (this._cachedPosition == null || this._cachedDirection == null || !lightPosition.equals(this._cachedPosition) || !lightDirection.equals(this._cachedDirection)) {

            this._cachedPosition = lightPosition.clone();
            this._cachedDirection = lightDirection.clone();

            var activeCamera = this._scene.activeCamera;

            Matrix.LookAtLHToRef(lightPosition, Reflect.field(this._light, "position").add(lightDirection), Vector3.Up(), this._viewMatrix);
            Matrix.PerspectiveFovLHToRef(Math.PI / 2.0, 1.0, activeCamera.minZ, activeCamera.maxZ, this._projectionMatrix);

            this._viewMatrix.multiplyToRef(this._projectionMatrix, this._transformMatrix);
        }

        return this._transformMatrix;
    }
	
	public function dispose() {
        this._shadowMap.dispose();
		this._shadowMap = null;
    }
	
}
