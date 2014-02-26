package com.gamestudiohx.babylonhx.tools;

import com.gamestudiohx.babylonhx.animations.Animation;
import com.gamestudiohx.babylonhx.bones.Bone;
import com.gamestudiohx.babylonhx.bones.Skeleton;
import com.gamestudiohx.babylonhx.cameras.FreeCamera;
import com.gamestudiohx.babylonhx.culling.BoundingInfo;
import com.gamestudiohx.babylonhx.lensflare.LensFlare;
import com.gamestudiohx.babylonhx.lensflare.LensFlareSystem;
import com.gamestudiohx.babylonhx.lights.DirectionalLight;
import com.gamestudiohx.babylonhx.lights.HemisphericLight;
import com.gamestudiohx.babylonhx.lights.Light;
import com.gamestudiohx.babylonhx.lights.PointLight;
import com.gamestudiohx.babylonhx.lights.shadows.ShadowGenerator;
import com.gamestudiohx.babylonhx.lights.SpotLight;
import com.gamestudiohx.babylonhx.materials.Material;
import com.gamestudiohx.babylonhx.materials.MultiMaterial;
import com.gamestudiohx.babylonhx.materials.StandardMaterial;
import com.gamestudiohx.babylonhx.materials.textures.CubeTexture;
import com.gamestudiohx.babylonhx.materials.textures.MirrorTexture;
import com.gamestudiohx.babylonhx.materials.textures.RenderTargetTexture;
import com.gamestudiohx.babylonhx.materials.textures.Texture;
import com.gamestudiohx.babylonhx.mesh.Mesh;
import com.gamestudiohx.babylonhx.mesh.SubMesh;
import com.gamestudiohx.babylonhx.mesh.VertexBuffer;
import com.gamestudiohx.babylonhx.particles.ParticleSystem;
import com.gamestudiohx.babylonhx.Engine;
import com.gamestudiohx.babylonhx.Scene;
import com.gamestudiohx.babylonhx.tools.Tools;
import com.gamestudiohx.babylonhx.tools.math.Color3;
import com.gamestudiohx.babylonhx.tools.math.Color4;
import com.gamestudiohx.babylonhx.tools.math.Matrix;
import com.gamestudiohx.babylonhx.tools.math.Quaternion;
import com.gamestudiohx.babylonhx.tools.math.Vector3;
import com.gamestudiohx.babylonhx.tools.math.Plane;
import flash.Lib;
import haxe.Json;

/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class SceneLoader {

	public static function loadCubeTexture(rootUrl:String, parsedTexture:Dynamic, scene:Scene):CubeTexture {
        var texture = new CubeTexture(rootUrl + parsedTexture.name, scene);

        texture.name = parsedTexture.name;
        texture.hasAlpha = parsedTexture.hasAlpha;
        texture.level = parsedTexture.level;
        texture.coordinatesMode = parsedTexture.coordinatesMode;

        return texture;
    }
	
	public static function loadTexture(rootUrl:String, parsedTexture:Dynamic, scene:Scene):Dynamic {
        if (parsedTexture.name != null && parsedTexture.isRenderTarget == true) {
            return null;
        }

        if (parsedTexture.isCube != null && parsedTexture.isCube == true) {
            return loadCubeTexture(rootUrl, parsedTexture, scene);
        }

        var texture:Texture = null;

        if (parsedTexture.mirrorPlane != null) {
            texture = new MirrorTexture(parsedTexture.name, parsedTexture.renderTargetSize, scene, true);
            cast(texture, MirrorTexture)._waitingRenderList = parsedTexture.renderList;
            cast(texture, MirrorTexture).mirrorPlane = Plane.FromArray(parsedTexture.mirrorPlane);
        } else if (parsedTexture.isRenderTarget) {
            texture = new RenderTargetTexture(parsedTexture.name, parsedTexture.renderTargetSize, scene, true);
            cast(texture, RenderTargetTexture)._waitingRenderList = parsedTexture.renderList;
        } else {
            texture = new Texture(rootUrl + parsedTexture.name, scene);
        }

        texture.name = parsedTexture.name;								
        texture.hasAlpha = parsedTexture.hasAlpha;						
        texture.level = parsedTexture.level;							

        texture.coordinatesIndex = parsedTexture.coordinatesIndex;	    
        texture.coordinatesMode = parsedTexture.coordinatesMode;		
        texture.uOffset = parsedTexture.uOffset;						
        texture.vOffset = parsedTexture.vOffset;						
        texture.uScale = parsedTexture.uScale;							
        texture.vScale = parsedTexture.vScale;							
        texture.uAng = parsedTexture.uAng;								
        texture.vAng = parsedTexture.vAng;								
        texture.wAng = parsedTexture.wAng;								

        texture.wrapU = parsedTexture.wrapU;							
        texture.wrapV = parsedTexture.wrapV;
		
        // Animations
        if (parsedTexture.animations != null) {
            for (animationIndex in 0...parsedTexture.animations.length) {
                var parsedAnimation = parsedTexture.animations[animationIndex];

                texture.animations.push(parseAnimation(parsedAnimation));
            }
        }
		
        return texture;
    }
	
	public static function parseSkeleton(parsedSkeleton:Dynamic, scene:Scene):Skeleton {
        var skeleton = new Skeleton(parsedSkeleton.name, parsedSkeleton.id, scene);

        for (index in 0...parsedSkeleton.bones.length) {
            var parsedBone = parsedSkeleton.bones[index];

            var parentBone = null;
            if (parsedBone.parentBoneIndex > -1) {
                parentBone = skeleton.bones[parsedBone.parentBoneIndex];
            }

            var bone = new Bone(parsedBone.name, skeleton, parentBone, Matrix.FromArray(parsedBone.matrix));

            if (parsedBone.animation != null) {
                bone.animations.push(parseAnimation(parsedBone.animation));
            }
        }

        return skeleton;
    }
	
	public static function parseMaterial(parsedMaterial:Dynamic, scene:Scene, rootUrl:String):Material {
        var material = new StandardMaterial(parsedMaterial.name, scene);
		
        material.ambientColor = Color3.FromArray(parsedMaterial.ambient);
        material.diffuseColor = Color3.FromArray(parsedMaterial.diffuse);
        material.specularColor = Color3.FromArray(parsedMaterial.specular);
        material.specularPower = parsedMaterial.specularPower;
        material.emissiveColor = Color3.FromArray(parsedMaterial.emissive);

        material.alpha = parsedMaterial.alpha;

        material.id = parsedMaterial.id;
        material.backFaceCulling = parsedMaterial.backFaceCulling;

        if (parsedMaterial.diffuseTexture != null) {
            material.diffuseTexture = loadTexture(rootUrl, parsedMaterial.diffuseTexture, scene);
        }

        if (parsedMaterial.ambientTexture != null) {
            material.ambientTexture = loadTexture(rootUrl, parsedMaterial.ambientTexture, scene);
        }

        if (parsedMaterial.opacityTexture != null) {
            material.opacityTexture = loadTexture(rootUrl, parsedMaterial.opacityTexture, scene);
        }

        if (parsedMaterial.reflectionTexture != null) {
            material.reflectionTexture = loadTexture(rootUrl, parsedMaterial.reflectionTexture, scene);
        }

        if (parsedMaterial.emissiveTexture != null) {
            material.emissiveTexture = loadTexture(rootUrl, parsedMaterial.emissiveTexture, scene);
        }

        if (parsedMaterial.specularTexture != null) {
            material.specularTexture = loadTexture(rootUrl, parsedMaterial.specularTexture, scene);
        }

        if (parsedMaterial.bumpTexture != null) {
            material.bumpTexture = loadTexture(rootUrl, parsedMaterial.bumpTexture, scene);
        }

        return material;
    }
	
	public static function parseMaterialById(id:String, parsedData:Dynamic, scene:Scene, rootUrl:String):Material {
        for (index in 0...parsedData.materials.length) {
            var parsedMaterial = parsedData.materials[index];
            if (parsedMaterial.id == id) {
                return parseMaterial(parsedMaterial, scene, rootUrl);
            }
        }

        return null;
    }
	
	public static function parseMultiMaterial(parsedMultiMaterial:Dynamic, scene:Scene):MultiMaterial {
        var multiMaterial = new MultiMaterial(parsedMultiMaterial.name, scene);

        multiMaterial.id = parsedMultiMaterial.id;

        for (matIndex in 0...parsedMultiMaterial.materials.length) {
            var subMatId = parsedMultiMaterial.materials[matIndex];

            if (subMatId != null) {
                multiMaterial.subMaterials.push(scene.getMaterialByID(subMatId));
            } else {
                multiMaterial.subMaterials.push(null);
            }
        }

        return multiMaterial;
    }
	
	public static function parseLensFlareSystem(parsedLensFlareSystem:Dynamic, scene:Scene, rootUrl:String):LensFlareSystem {
        var emitter = scene.getLastEntryByID(parsedLensFlareSystem.emitterId);

        var lensFlareSystem = new LensFlareSystem("lensFlareSystem#" + parsedLensFlareSystem.emitterId, emitter, scene);
        lensFlareSystem.borderLimit = parsedLensFlareSystem.borderLimit;
        
        for (index in 0...parsedLensFlareSystem.flares.length) {
            var parsedFlare = parsedLensFlareSystem.flares[index];
            var flare = new LensFlare(parsedFlare.size, parsedFlare.position, Color3.FromArray(parsedFlare.color), rootUrl + parsedFlare.textureName, lensFlareSystem);
        }

        return lensFlareSystem;
    }
	
	public static function parseParticleSystem(parsedParticleSystem:Dynamic, scene:Scene, rootUrl:String):ParticleSystem {
        var emitter = scene.getLastMeshByID(parsedParticleSystem.emitterId);

        var particleSystem = new ParticleSystem("particles#" + emitter.name, parsedParticleSystem.capacity, scene);
        if (parsedParticleSystem.textureName != null && parsedParticleSystem.textureName != "") {
            particleSystem.particleTexture = new Texture(rootUrl + parsedParticleSystem.textureName, scene);
        }
        particleSystem.minAngularSpeed = parsedParticleSystem.minAngularSpeed;
        particleSystem.maxAngularSpeed = parsedParticleSystem.maxAngularSpeed;
        particleSystem.minSize = parsedParticleSystem.minSize;
        particleSystem.maxSize = parsedParticleSystem.maxSize;
        particleSystem.minLifeTime = parsedParticleSystem.minLifeTime;
        particleSystem.maxLifeTime = parsedParticleSystem.maxLifeTime;
        particleSystem.emitter = emitter;
        particleSystem.emitRate = parsedParticleSystem.emitRate;
        particleSystem.minEmitBox = Vector3.FromArray(parsedParticleSystem.minEmitBox);
        particleSystem.maxEmitBox = Vector3.FromArray(parsedParticleSystem.maxEmitBox);
        particleSystem.gravity = Vector3.FromArray(parsedParticleSystem.gravity);
        particleSystem.direction1 = Vector3.FromArray(parsedParticleSystem.direction1);
        particleSystem.direction2 = Vector3.FromArray(parsedParticleSystem.direction2);
        particleSystem.color1 = Color4.FromArray(parsedParticleSystem.color1);
        particleSystem.color2 = Color4.FromArray(parsedParticleSystem.color2);
        particleSystem.colorDead = Color4.FromArray(parsedParticleSystem.colorDead);
        particleSystem.updateSpeed = parsedParticleSystem.updateSpeed;
        particleSystem.targetStopDuration = parsedParticleSystem.targetStopFrame;
        particleSystem.textureMask = Color4.FromArray(parsedParticleSystem.textureMask);
        particleSystem.blendMode = parsedParticleSystem.blendMode;
        particleSystem.start();
		
        return particleSystem;
    }
	
	public static function parseShadowGenerator(parsedShadowGenerator:Dynamic, scene:Scene):ShadowGenerator {
        var light = scene.getLightByID(parsedShadowGenerator.lightId);
        var shadowGenerator = new ShadowGenerator(parsedShadowGenerator.mapSize, light);

        for (meshIndex in 0...parsedShadowGenerator.renderList.length) {
            var mesh = scene.getMeshByID(parsedShadowGenerator.renderList[meshIndex]);

            shadowGenerator.getShadowMap().renderList.push(mesh);
        }

        shadowGenerator.useVarianceShadowMap = parsedShadowGenerator.useVarianceShadowMap;

        return shadowGenerator;
    }
	
	public static function parseAnimation(parsedAnimation:Dynamic):Animation {
        var animation = new Animation(parsedAnimation.name, parsedAnimation.property, parsedAnimation.framePerSecond, parsedAnimation.dataType, parsedAnimation.loopBehavior);

        var dataType = parsedAnimation.dataType;
        var keys:Array<BabylonFrame> = [];
        for (index in 0...parsedAnimation.keys.length) {
            var key = parsedAnimation.keys[index];

            var data:Dynamic = null;

            switch (dataType) {
                case Animation.ANIMATIONTYPE_FLOAT:
                    data = key.values[0];
                
                case Animation.ANIMATIONTYPE_QUATERNION:
                    data = Quaternion.FromArray(key.values);
              
                case Animation.ANIMATIONTYPE_MATRIX:
                    data = Matrix.FromArray(key.values);
                
                case Animation.ANIMATIONTYPE_VECTOR3:
                default:
                    data = Vector3.FromArray(key.values);
                
            }

            keys.push({
                frame: key.frame,
                value: data
            });
        }

        animation.setKeys(keys);

        return animation;
    }
	
	public static function parseLight(parsedLight:Dynamic, scene:Scene):Light {
        var light:Light = null;

        switch (parsedLight.type) {
            case 0:
                light = new PointLight(parsedLight.name, Vector3.FromArray(parsedLight.position), scene);
                
            case 1:
                light = new DirectionalLight(parsedLight.name, Vector3.FromArray(parsedLight.direction), scene);
                light.position = Vector3.FromArray(parsedLight.position);
            
            case 2:
                light = new SpotLight(parsedLight.name, Vector3.FromArray(parsedLight.position), Vector3.FromArray(parsedLight.direction), parsedLight.angle, parsedLight.exponent, scene);
            
            case 3:
                light = new HemisphericLight(parsedLight.name, Vector3.FromArray(parsedLight.direction), scene);
                cast(light, HemisphericLight).groundColor = Color3.FromArray(parsedLight.groundColor);
            
        }

        light.id = parsedLight.id;

        if (parsedLight.intensity != null) {
            light.intensity = parsedLight.intensity;
        }
        light.diffuse = Color3.FromArray(parsedLight.diffuse);
        light.specular = Color3.FromArray(parsedLight.specular);
				
		return light;
    }
	
	public static function parseCamera(parsedCamera:Dynamic, scene:Scene):FreeCamera {
        var camera:FreeCamera = new FreeCamera(parsedCamera.name, Vector3.FromArray(parsedCamera.position), scene);
        camera.id = parsedCamera.id;

        // Parent
        if (parsedCamera.parentId != null) {
            camera._waitingParentId = parsedCamera.parentId;
        }

        // Target
        if (parsedCamera.target != null) {
            camera.setTarget(Vector3.FromArray(parsedCamera.target));
        } else {
            camera.rotation = Vector3.FromArray(parsedCamera.rotation);
        }

        // Locked target
        if (parsedCamera.lockedTargetId != null) {
            camera._waitingLockedTargetId = parsedCamera.lockedTargetId;
        }

        camera.fov = parsedCamera.fov;
        camera.minZ = parsedCamera.minZ;
        camera.maxZ = parsedCamera.maxZ;

        camera.speed = parsedCamera.speed;
        camera.inertia = parsedCamera.inertia;

        camera.checkCollisions = parsedCamera.checkCollisions;
        camera.applyGravity = parsedCamera.applyGravity;
        if (parsedCamera.ellipsoid != null) {
            camera.ellipsoid = Vector3.FromArray(parsedCamera.ellipsoid);
        }

        // Animations
        if (parsedCamera.animations != null) {
            for (animationIndex in 0...parsedCamera.animations.length) {
                var parsedAnimation = parsedCamera.animations[animationIndex];

                camera.animations.push(parseAnimation(parsedAnimation));
            }
        }

        if (parsedCamera.autoAnimate != null) {
            scene.beginAnimation(camera, parsedCamera.autoAnimateFrom, parsedCamera.autoAnimateTo, parsedCamera.autoAnimateLoop, 1.0);
        }

        return camera;
    }
	
	public static function parseMesh(parsedMesh:Dynamic, scene:Scene, rootUrl:String):Mesh {
        var mesh = new Mesh(parsedMesh.name, scene);
        mesh.id = parsedMesh.id;
		
        mesh.position = Vector3.FromArray(parsedMesh.position);
        if (parsedMesh.rotation != null) {
            mesh.rotation = Vector3.FromArray(parsedMesh.rotation);
        } else if (parsedMesh.rotationQuaternion != null) {
            mesh.rotationQuaternion = Quaternion.FromArray(parsedMesh.rotationQuaternion);
        }
        mesh.scaling = Vector3.FromArray(parsedMesh.scaling);

        if (parsedMesh.localMatrix != null) {
            mesh.setPivotMatrix(Matrix.FromArray(cast parsedMesh.localMatrix));
        }

        mesh.setEnabled(parsedMesh.isEnabled);
        mesh.isVisible = parsedMesh.isVisible;
        mesh.infiniteDistance = parsedMesh.infiniteDistance;
        
        mesh.receiveShadows = parsedMesh.receiveShadows;

        mesh.billboardMode = parsedMesh.billboardMode;

        if (parsedMesh.visibility != null) {
            mesh.visibility = parsedMesh.visibility;
        }

        mesh.checkCollisions = parsedMesh.checkCollisions;

        // Parent
        if (parsedMesh.parentId != null && parsedMesh.parentId != "") {
            mesh.parent = scene.getLastEntryByID(parsedMesh.parentId);
        }

        // Geometry
        /*if (parsedMesh.delayLoadingFile != null && parsedMesh.delayLoadingFile != "") {
            mesh.delayLoadState = Engine.DELAYLOADSTATE_NOTLOADED;
            mesh.delayLoadingFile = rootUrl + parsedMesh.delayLoadingFile;
            mesh._boundingInfo = new BoundingInfo(Vector3.FromArray(parsedMesh.boundingBoxMinimum), Vector3.FromArray(parsedMesh.boundingBoxMaximum));

            mesh._delayInfo = [];
            if (parsedMesh.hasUVs) {
                mesh._delayInfo.push(VertexBuffer.UVKind);
            }

            if (parsedMesh.hasUVs2) {
                mesh._delayInfo.push(VertexBuffer.UV2Kind);
            }

            if (parsedMesh.hasColors) {
                mesh._delayInfo.push(VertexBuffer.ColorKind);
            }

            if (parsedMesh.hasMatricesIndices) {
                mesh._delayInfo.push(VertexBuffer.MatricesIndicesKind);
            }

            if (parsedMesh.hasMatricesWeights) {
                mesh._delayInfo.push(VertexBuffer.MatricesWeightsKind);
            }

        } else {*/
            SceneLoader._ImportGeometry(parsedMesh, mesh);
        //}

        // Material
        if (parsedMesh.materialId != null) {
            mesh.setMaterialByID(parsedMesh.materialId);
        } else {
            mesh.material = null;
        }

        // Skeleton
        if (parsedMesh.skeletonId > -1) {
            mesh.skeleton = scene.getLastSkeletonByID(parsedMesh.skeletonId);
        }
        
        // Physics
		// TODO
        /*if (parsedMesh.physicsImpostor != null) {
            if (!scene.isPhysicsEnabled()) {
                scene.enablePhysics();
            }

            switch (parsedMesh.physicsImpostor) {
                case 1: // BOX
                    mesh.setPhysicsState({ impostor: BABYLON.PhysicsEngine.BoxImpostor, mass: parsedMesh.physicsMass, friction: parsedMesh.physicsFriction, restitution: parsedMesh.physicsRestitution });
                    
                case 2: // SPHERE
                    mesh.setPhysicsState({ impostor: BABYLON.PhysicsEngine.SphereImpostor, mass: parsedMesh.physicsMass, friction: parsedMesh.physicsFriction, restitution: parsedMesh.physicsRestitution });
                    
            }
        }*/

        // Animations
        if (parsedMesh.animations != null) {
            for (animationIndex in 0...parsedMesh.animations.length) {
                var parsedAnimation = parsedMesh.animations[animationIndex];
                mesh.animations.push(parseAnimation(parsedAnimation));
            }
        }

        if (parsedMesh.autoAnimate != null && parsedMesh.autoAnimate != false) {
            scene.beginAnimation(mesh, parsedMesh.autoAnimateFrom, parsedMesh.autoAnimateTo, parsedMesh.autoAnimateLoop, 1.0);
        }

        return mesh;
    }
	
	public static function isDescendantOf(mesh:Dynamic, name:String, hierarchyIds:Array<String>):Bool {
        if (mesh.name == name) {
            hierarchyIds.push(mesh.id);
            return true;
        }

        if (mesh.parentId != null && Lambda.indexOf(hierarchyIds, mesh.parentId) != -1) {
            hierarchyIds.push(mesh.id);
            return true;
        }

        return false;
    }
	
	public static function _ImportGeometry(parsedGeometry:Dynamic, mesh:Mesh) {
		// Geometry
		if (parsedGeometry.positions != null && parsedGeometry.normals != null && parsedGeometry.indices != null) {
			mesh.setVerticesData(parsedGeometry.positions, VertexBuffer.PositionKind, false);
			mesh.setVerticesData(parsedGeometry.normals, VertexBuffer.NormalKind, false);

			if (parsedGeometry.uvs != null) {
				mesh.setVerticesData(parsedGeometry.uvs, VertexBuffer.UVKind, false);
			}

			if (parsedGeometry.uvs2 != null) {
				mesh.setVerticesData(parsedGeometry.uvs2, VertexBuffer.UV2Kind, false);
			}

			if (parsedGeometry.colors != null) {
				mesh.setVerticesData(parsedGeometry.colors, VertexBuffer.ColorKind, false);
			}

			if (parsedGeometry.matricesIndices != null) {
				var floatIndices:Array<Float> = [];

				for (i in 0...parsedGeometry.matricesIndices.length) {
					var matricesIndex:Int = parsedGeometry.matricesIndices[i];

					floatIndices.push(matricesIndex & 0x000000FF);
					floatIndices.push((matricesIndex & 0x0000FF00) >> 8);
					floatIndices.push((matricesIndex & 0x00FF0000) >> 16);
					floatIndices.push(matricesIndex >> 24);
				}

				mesh.setVerticesData(floatIndices, VertexBuffer.MatricesIndicesKind, false);
			}

			if (parsedGeometry.matricesWeights != null) {
				mesh.setVerticesData(parsedGeometry.matricesWeights, VertexBuffer.MatricesWeightsKind, false);
			}

			mesh.setIndices(parsedGeometry.indices);
		}

		// SubMeshes
		if (parsedGeometry.subMeshes != null) {
			mesh.subMeshes = [];
			for (subIndex in 0...parsedGeometry.subMeshes.length) {
				var parsedSubMesh = parsedGeometry.subMeshes[subIndex];

				var subMesh = new SubMesh(parsedSubMesh.materialIndex, parsedSubMesh.verticesStart, parsedSubMesh.verticesCount, parsedSubMesh.indexStart, parsedSubMesh.indexCount, mesh);
			}
		}

		// Update
		mesh.computeWorldMatrix(true);

		var scene:Scene = mesh.getScene();
		if (scene._selectionOctree != null) {
			scene._selectionOctree.addMesh(mesh);
		}
	}
	
	public static function ImportMesh(?meshName:String, ?rootUrl:String, ?sceneFilename:String, ?scene:Scene, ?then:Array<Dynamic>->Array<Dynamic>->Array<Dynamic>->Void, ?progressCallBack:String->Void) {
		
		Tools.LoadFile(rootUrl + sceneFilename, function(data:String) {
			var parsedData = Json.parse(data);

			// Meshes
			var meshes:Array<Mesh> = [];
			var particleSystems:Array<ParticleSystem> = [];
			var skeletons:Array<Skeleton> = [];
			var loadedSkeletonsIds:Array<String> = [];
			var loadedMaterialsIds:Array<String> = [];
			var hierarchyIds:Array<String> = [];
			
			var _meshes:Array<Dynamic> = cast parsedData.meshes;
			for (index in 0..._meshes.length) {
				var parsedMesh:Dynamic = _meshes[index];

				if (meshName == null || isDescendantOf(parsedMesh, meshName, hierarchyIds)) {
					// Material ?
					if (parsedMesh.materialId != null) {
						var materialFound = Lambda.indexOf(loadedMaterialsIds, parsedMesh.materialId) != -1;

						if (!materialFound) {
							var _multiMaterials:Array<Dynamic> = cast parsedData.multiMaterials;
							for (multimatIndex in 0..._multiMaterials.length) {
								var parsedMultiMaterial = _multiMaterials[multimatIndex];
								if (parsedMultiMaterial.id == parsedMesh.materialId) {
									var _materials:Array<Dynamic> = cast parsedMultiMaterial.materials;
									for (matIndex in 0..._materials.length) {
										var subMatId = _materials[matIndex];
										loadedMaterialsIds.push(subMatId);
										parseMaterialById(subMatId, parsedData, scene, rootUrl);
									}

									loadedMaterialsIds.push(parsedMultiMaterial.id);
									parseMultiMaterial(parsedMultiMaterial, scene);
									materialFound = true;
									break;
								}
							}
						}

						if (!materialFound) {
							loadedMaterialsIds.push(parsedMesh.materialId);
							parseMaterialById(parsedMesh.materialId, parsedData, scene, rootUrl);
						}
					}

					// Skeleton ?
					if (parsedMesh.skeletonId > -1 && scene.skeletons != null) {
						var skeletonAlreadyLoaded = Lambda.indexOf(loadedSkeletonsIds, parsedMesh.skeletonId) > -1;

						if (!skeletonAlreadyLoaded) {
							var _skeletons:Array<Dynamic> = cast parsedData.skeletons;
							for (skeletonIndex in 0..._skeletons.length) {
								var parsedSkeleton = _skeletons[skeletonIndex];

								if (parsedSkeleton.id == parsedMesh.skeletonId) {
									skeletons.push(parseSkeleton(parsedSkeleton, scene));
									loadedSkeletonsIds.push(parsedSkeleton.id);
								}
							}
						}
					}

					var mesh = parseMesh(parsedMesh, scene, rootUrl);
					meshes.push(mesh);
				}
			}

			// Particles
			if (parsedData.particleSystems != null) {
				var ps:Array<ParticleSystem> = cast parsedData.particleSystems;
				for (index in 0...ps.length) {
					var parsedParticleSystem:ParticleSystem = ps[index];

					if (Lambda.indexOf(hierarchyIds, parsedParticleSystem.emitterId) != -1) {
						particleSystems.push(parseParticleSystem(parsedParticleSystem, scene, rootUrl));
					}
				}
			}

			if (then != null) {
				then(meshes, particleSystems, skeletons);
			}
		});
	}
	
	public static function Load(rootUrl:String, sceneFilename:String, engine:Engine, ?then:Scene->Void) {
		function loadSceneFromData(data:String) {			
			var parsedData = Json.parse(data);			
						
			var scene = new Scene(engine);
			//scene.database = database;

			// Scene
			scene.useDelayedTextureLoading = parsedData.useDelayedTextureLoading;
			scene.autoClear = parsedData.autoClear;
			scene.clearColor = Color4.FromArray(parsedData.clearColor);
			scene.ambientColor = Color3.FromArray(parsedData.ambientColor);
			scene.gravity = Vector3.FromArray(parsedData.gravity);
			
			// Fog
			var fogMode : Null<Int> = parsedData.fogMode;
			if (fogMode != null && fogMode != 0) {
				scene.fogMode = fogMode;
				scene.fogColor = Color3.FromArray(parsedData.fogColor);
				scene.fogStart = parsedData.fogStart;
				scene.fogEnd = parsedData.fogEnd;
				scene.fogDensity = parsedData.fogDensity;
			}

			
			// Lights
			var _lights:Array<Dynamic> = cast parsedData.lights;
			for (index in 0..._lights.length) {
				var parsedLight = _lights[index];				
				parseLight(parsedLight, scene);				
			}

			// Cameras
			var _cameras:Array<Dynamic> = cast parsedData.cameras;
			for (index in 0..._cameras.length) {
				var parsedCamera = _cameras[index];				
				parseCamera(parsedCamera, scene);				
			}

			if (parsedData.activeCameraID != null) {
				scene.activeCameraByID(parsedData.activeCameraID);
			}

			// Materials
			if (parsedData.materials != null) {
				var _materials:Array<Dynamic> = cast parsedData.materials;
				for (index in 0..._materials.length) {
					var parsedMaterial = _materials[index];
					parseMaterial(parsedMaterial, scene, rootUrl);
				}
			}

			if (parsedData.multiMaterials != null) {
				var _multiMaterials:Array<Dynamic> = cast parsedData.multiMaterials;
				for (index in 0..._multiMaterials.length) {
					var parsedMultiMaterial = parsedData.multiMaterials[index];
					parseMultiMaterial(parsedMultiMaterial, scene);
				}
			}

			// Skeletons
			if (parsedData.skeletons != null) {
				var _skeletons:Array<Dynamic> = cast parsedData.skeletons;
				for (index in 0..._skeletons.length) {
					var parsedSkeleton = parsedData.skeletons[index];
					parseSkeleton(parsedSkeleton, scene);
				}
			}

			// Meshes
			var _meshes:Array<Dynamic> = cast parsedData.meshes;
			for (index in 0..._meshes.length) {
				var parsedMesh = _meshes[index];
				parseMesh(parsedMesh, scene, rootUrl);
			}

			// Connecting cameras parents and locked target
			for (index in 0...scene.cameras.length) {
				var camera = scene.cameras[index];
				if (Reflect.field(camera, "_waitingParentId") != null) {
					camera.parent = scene.getLastEntryByID(Reflect.field(camera, "_waitingParentId"));
					Reflect.setField(camera, "_waitingParentId", null);
				}

				if (Reflect.field(camera, "_waitingLockedTargetId") != null) {
					Reflect.setField(camera, "lockedTarget", scene.getLastEntryByID(Reflect.field(camera, "_waitingLockedTargetId")));
					Reflect.setField(camera, "_waitingLockedTargetId", null);
				}
			}

			// Particles Systems
			if (parsedData.particleSystems != null) {
				var _particleSystems:Array<Dynamic> = cast parsedData.particleSystems;
				for (index in 0..._particleSystems.length) {
					var parsedParticleSystem = _particleSystems[index];
					parseParticleSystem(parsedParticleSystem, scene, rootUrl);
				}
			}

			// Lens flares
			if (parsedData.lensFlareSystems != null) {
				var _lensFlareSystems:Array<Dynamic> = cast parsedData.lensFlareSystems;
				for (index in 0..._lensFlareSystems.length) {
					var parsedLensFlareSystem = _lensFlareSystems[index];
					parseLensFlareSystem(parsedLensFlareSystem, scene, rootUrl);
				}
			}

			// Shadows
			if (parsedData.shadowGenerators != null) {
				var _shadowGenerators:Array<Dynamic> = cast parsedData.shadowGenerators;
				for (index in 0..._shadowGenerators.length) {
					var parsedShadowGenerator = _shadowGenerators[index];
					parseShadowGenerator(parsedShadowGenerator, scene);
				}
			}
						
			// Finish
			if (then != null) {
				then(scene);
			}
		}

		Tools.LoadFile(rootUrl + sceneFilename, loadSceneFromData);		
	}
	
}
