package com.babylonhx.loading.plugins;

import com.babylonhx.actions.Action;
import com.babylonhx.actions.ActionManager;
import com.babylonhx.actions.Condition;
import com.babylonhx.actions.ValueCondition;
import com.babylonhx.animations.Animation;
import com.babylonhx.bones.Bone;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.cameras.AnaglyphArcRotateCamera;
import com.babylonhx.cameras.AnaglyphFreeCamera;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.cameras.Camera;
import com.babylonhx.cameras.FollowCamera;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.culling.BoundingInfo;
import com.babylonhx.lensflare.LensFlare;
import com.babylonhx.lensflare.LensFlareSystem;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.Light;
import com.babylonhx.lights.PointLight;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.lights.SpotLight;
import com.babylonhx.loading.plugins.BabylonFileLoader;
import com.babylonhx.materials.FresnelParameters;
import com.babylonhx.materials.Material;
import com.babylonhx.materials.MultiMaterial;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.MirrorTexture;
import com.babylonhx.materials.textures.RenderTargetTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Plane;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Quaternion;
import com.babylonhx.math.Vector4;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.Geometry;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.mesh.VertexData;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.mesh.primitives.Box;
import com.babylonhx.mesh.primitives.Cylinder;
import com.babylonhx.mesh.primitives.Ground;
import com.babylonhx.mesh.primitives.Sphere;
import com.babylonhx.mesh.primitives.Torus;
import com.babylonhx.mesh.primitives.TorusKnot;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.physics.PhysicsBodyCreationOptions;
import com.babylonhx.tools.Tags;
import com.babylonhx.actions.*;

import haxe.io.Bytes;
import haxe.Json;
import haxe.Timer;

import com.babylonhx.utils.typedarray.ArrayBuffer;
import com.babylonhx.utils.typedarray.Float32Array;
import com.babylonhx.utils.typedarray.Int32Array;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.ISceneLoaderPlugin') typedef ISceneLoaderPlugin = {
	var extensions:String;
	var importMesh:Dynamic->Scene->Dynamic->String->Array<AbstractMesh>->Array<ParticleSystem>->Array<Skeleton>->Bool;
	var load:Scene->Dynamic->String->Bool;
}

@:expose('BABYLON.BabylonFileLoader') class BabylonFileLoader {
		
	public static var plugin(get, never):ISceneLoaderPlugin;
	private static function get_plugin():ISceneLoaderPlugin {
		return _plugin;
	}
	private static var _plugin:ISceneLoaderPlugin = {
		extensions: ".babylon",
        importMesh: function(meshesNames:Dynamic, scene:Scene, data:Dynamic, rootUrl:String, meshes:Array<AbstractMesh>, particleSystems:Array<ParticleSystem>, skeletons:Array<Skeleton>):Bool {
						
			var parsedData:Dynamic = null;
			if (Std.is(data, String)) {
				parsedData = Json.parse(data);
			} else if(Std.is(data, Bytes)) {
				//parsedData = MsgPack.decode(data);
			} else {
				trace("Unknown data type!");
				return false;
			}
									
            var loadedSkeletonsIds:Array<Int> = [];
            var loadedMaterialsIds:Array<Int> = [];
            var hierarchyIds:Array<Int> = [];
			
			var pdm:Array<Dynamic> = cast parsedData.meshes;
            for (index in 0...pdm.length) {
                var parsedMesh = pdm[index];
                if (meshesNames == null || meshesNames == "" || isDescendantOf(parsedMesh, meshesNames, hierarchyIds)) {
					if (Std.is(meshesNames, Array)) {
                        // Remove found mesh name from list.
                        meshesNames.splice(meshesNames.indexOf(parsedMesh.name), 1);
                    }
					
                    // Material ?
                    if (Reflect.hasField(parsedMesh, "materialId")) {
                        var materialFound = (loadedMaterialsIds.indexOf(parsedMesh.materialId) != -1);
						
                        if (!materialFound && parsedData.multiMaterials != null) {
							var pdmm:Array<Dynamic> = cast parsedData.multiMaterials;
                            for (multimatIndex in 0...pdmm.length) {
                                var parsedMultiMaterial = pdmm[multimatIndex];
                                if (parsedMultiMaterial.id == parsedMesh.materialId) {
									var pdmmm:Array<Dynamic> = cast parsedMultiMaterial.materials;
                                    for (matIndex in 0...pdmmm.length) {
                                        var subMatId:Int = pdmmm[matIndex];
                                        loadedMaterialsIds.push(subMatId);
                                        parseMaterialById(Std.string(subMatId), parsedData, scene, rootUrl);
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
                            parseMaterialById(cast parsedMesh.materialId, parsedData, scene, rootUrl);
                        }
                    }
					
                    // Skeleton ?
                    if (parsedMesh.skeletonId > -1 && scene.skeletons != null) {
                        var skeletonAlreadyLoaded = (loadedSkeletonsIds.indexOf(parsedMesh.skeletonId) > -1);
						
                        if (!skeletonAlreadyLoaded) {
							var pds:Array<Dynamic> = cast parsedData.skeletons;
                            for (skeletonIndex in 0...pds.length) {
                                var parsedSkeleton = pds[skeletonIndex];
								
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
			
            // Connecting parents
            for (index in 0...scene.meshes.length) {
                var currentMesh = scene.meshes[index];
                if (currentMesh._waitingParentId != null) {
                    currentMesh.parent = scene.getLastEntryByID(currentMesh._waitingParentId);
					currentMesh._waitingParentId = null;
                }
            }
			
            // Particles
            if (parsedData.particleSystems != null) {
				var pdp:Array<Dynamic> = cast parsedData.particleSystems;
                for (index in 0...pdp.length) {
					var parsedParticleSystem = pdp[index];				
                    if (hierarchyIds.indexOf(parsedParticleSystem.emitterId) != -1) {
                        particleSystems.push(parseParticleSystem(parsedParticleSystem, scene, rootUrl));
                    }
                }
            }
			
            return true;
        },
		load: function(scene:Scene, data:Dynamic, rootUrl:String):Bool {
			var parsedData:Dynamic = null;
			if (Std.is(data, String)) {
				parsedData = Json.parse(data);
			} else if(Std.is(data, Bytes)) {
				//parsedData = MsgPack.decode(data);
			} else {
				trace("Unknown data type!");
				return false;
			}
			
			data = null;
						
            // Scene
            scene.useDelayedTextureLoading = parsedData.useDelayedTextureLoading && !SceneLoader.ForceFullSceneLoadingForIncremental;
            scene.autoClear = parsedData.autoClear;
            scene.clearColor = Color3.FromArray(parsedData.clearColor);
            scene.ambientColor = Color3.FromArray(parsedData.ambientColor);
            scene.gravity = Vector3.FromArray(parsedData.gravity);
			
            // Fog
            if (parsedData.fogMode != null && parsedData.fogMode != 0) {
                scene.fogMode = parsedData.fogMode;
                scene.fogColor = Color3.FromArray(parsedData.fogColor);
                scene.fogStart = parsedData.fogStart;
                scene.fogEnd = parsedData.fogEnd;
                scene.fogDensity = parsedData.fogDensity;
            }
			
            // Lights
            for (index in 0...parsedData.lights.length) {
                var parsedLight = parsedData.lights[index];
                parseLight(parsedLight, scene);
            }
			
            // Materials
            if (parsedData.materials != null) {
                for (index in 0...parsedData.materials.length) {
                    var parsedMaterial = parsedData.materials[index];
                    parseMaterial(parsedMaterial, scene, rootUrl);
                }
            }
			
            if (parsedData.multiMaterials != null) {
                for (index in 0...parsedData.multiMaterials.length) {
                    var parsedMultiMaterial = parsedData.multiMaterials[index];
                    parseMultiMaterial(parsedMultiMaterial, scene);
                }
            }
			
            // Skeletons
            if (parsedData.skeletons != null) {
                for (index in 0...parsedData.skeletons.length) {
                    var parsedSkeleton = parsedData.skeletons[index];
                    parseSkeleton(parsedSkeleton, scene);
                }
            }
			
            // Geometries
            var geometries = parsedData.geometries;
            if (geometries != null) {
                // Boxes
                var boxes:Array<Dynamic> = geometries.boxes;
                if (boxes != null) {
                    for (index in 0...boxes.length) {
                        var parsedBox = boxes[index];
                        parseBox(parsedBox, scene);
                    }
                }
				
                // Spheres
                var spheres:Array<Dynamic> = geometries.spheres;
                if (spheres != null) {
                    for (index in 0...spheres.length) {
                        var parsedSphere = spheres[index];
                        parseSphere(parsedSphere, scene);
                    }
                }
				
                // Cylinders
                var cylinders:Array<Dynamic> = geometries.cylinders;
                if (cylinders != null) {
                    for (index in 0...cylinders.length) {
                        var parsedCylinder = cylinders[index];
                        parseCylinder(parsedCylinder, scene);
                    }
                }
				
                // Toruses
                var toruses:Array<Dynamic> = geometries.toruses;
                if (toruses != null) {
                    for (index in 0...toruses.length) {
                        var parsedTorus = toruses[index];
                        parseTorus(parsedTorus, scene);
                    }
                }
				
                // Grounds
                var grounds:Array<Dynamic> = geometries.grounds;
                if (grounds != null) {
                    for (index in 0...grounds.length) {
                        var parsedGround = grounds[index];
                        parseGround(parsedGround, scene);
                    }
                }
				
                // Planes
                var planes:Array<Dynamic> = geometries.planes;
                if (planes != null) {
                    for (index in 0...planes.length) {
                        var parsedPlane = planes[index];
                        parsePlane(parsedPlane, scene);
                    }
                }
				
                // TorusKnots
                var torusKnots:Array<Dynamic> = geometries.torusKnots;
                if (torusKnots != null) {
                    for (index in 0...torusKnots.length) {
                        var parsedTorusKnot = torusKnots[index];
                        parseTorusKnot(parsedTorusKnot, scene);
                    }
                }
				
                // VertexData
                var vertexData:Array<Dynamic> = geometries.vertexData;
                if (vertexData != null) {
                    for (index in 0...vertexData.length) {
                        var parsedVertexData = vertexData[index];
                        parseVertexData(parsedVertexData, scene, rootUrl);
                    }
                }
            }
			
            // Meshes
			var pdm:Array<Dynamic> = cast parsedData.meshes;
            for (index in 0...pdm.length) {
                var parsedMesh = pdm[index];
                parseMesh(parsedMesh, scene, rootUrl);
            }
			
            // Cameras
			var pdc:Array<Dynamic> = cast parsedData.cameras;
            for (index in 0...parsedData.cameras.length) {
                var parsedCamera = parsedData.cameras[index];
                parseCamera(parsedCamera, scene);
            }
			
            if (parsedData.activeCameraID != null) {
                scene.setActiveCameraByID(parsedData.activeCameraID);
            }
			
            // Browsing all the graph to connect the dots
            for (index in 0...scene.cameras.length) {
                var camera = scene.cameras[index];
                if (camera._waitingParentId != null) {
                    camera.parent = scene.getLastEntryByID(camera._waitingParentId);
                    camera._waitingParentId = null;
                }
            }
			
            for (index in 0...scene.lights.length) {
                var light = scene.lights[index];
                if (light._waitingParentId != null) {
                    light.parent = scene.getLastEntryByID(light._waitingParentId);
                    light._waitingParentId = null;
                }
            }
			
			// Connect parents & children and parse actions
            for (index in 0...scene.meshes.length) {
                var mesh = scene.meshes[index];
                if (mesh._waitingParentId != null) {
                    mesh.parent = scene.getLastEntryByID(mesh._waitingParentId);
                    mesh._waitingParentId = null;
                }
				if (mesh._waitingActions != null) {
                    parseActions(mesh._waitingActions, mesh, scene);
                    mesh._waitingActions = null;
                }
            }
			
            // Particles Systems
            if (parsedData.particleSystems != null) {
                for (index in 0...parsedData.particleSystems.length) {
                    var parsedParticleSystem = parsedData.particleSystems[index];
                    parseParticleSystem(parsedParticleSystem, scene, rootUrl);
                }
            }
			
            // Lens flares
            if (parsedData.lensFlareSystems != null) {
                for (index in 0...parsedData.lensFlareSystems.length) {
                    var parsedLensFlareSystem = parsedData.lensFlareSystems[index];
                    parseLensFlareSystem(parsedLensFlareSystem, scene, rootUrl);
                }
            }
			
            // Shadows
            if (parsedData.shadowGenerators != null) {
                for (index in 0...parsedData.shadowGenerators.length) {
                    var parsedShadowGenerator = parsedData.shadowGenerators[index];
                    parseShadowGenerator(parsedShadowGenerator, scene);
                }
            }
			
			// Actions (scene)
            if (parsedData.actions != null) {
                parseActions(parsedData.actions, null, scene);
            }
			
            // Finish
            return true;
        }
	};

	private static function checkColors4(colors:Array<Float>, count:Int):Array<Float> {
        // Check if color3 was used
        if (colors.length == count * 3) {
            var colors4:Array<Float> = [];
			var index:Int = 0;
			while(index < colors.length) {            
                var newIndex = Std.int((index / 3) * 4);
                colors4[newIndex] = colors[index];
                colors4[newIndex + 1] = colors[index + 1];
                colors4[newIndex + 2] = colors[index + 2];
                colors4[newIndex + 3] = 1.0;
				
				index += 3;
            }
			
            return colors4;
        } 
		
        return colors;
    }

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
		texture.getAlphaFromRGB = parsedTexture.getAlphaFromRGB;
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
		try {
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
		} catch (err:Dynamic) {
			trace(err);
		}
		
        return skeleton;
    }

    public static function parseFresnelParameters(parsedFresnelParameters:Dynamic):FresnelParameters {
        var fresnelParameters = new FresnelParameters();
		
        fresnelParameters.isEnabled = parsedFresnelParameters.isEnabled;
        fresnelParameters.leftColor = Color3.FromArray(parsedFresnelParameters.leftColor);
        fresnelParameters.rightColor = Color3.FromArray(parsedFresnelParameters.rightColor);
        fresnelParameters.bias = parsedFresnelParameters.bias;
        fresnelParameters.power = parsedFresnelParameters.power != null ? parsedFresnelParameters.power : 1.0;
		
        return fresnelParameters;
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
		
        Tags.AddTagsTo(material, parsedMaterial.tags);
        material.backFaceCulling = parsedMaterial.backFaceCulling;
        material.wireframe = parsedMaterial.wireframe;
		
        if (parsedMaterial.diffuseTexture != null) {
            material.diffuseTexture = loadTexture(rootUrl, parsedMaterial.diffuseTexture, scene);
        }
		
        if (parsedMaterial.diffuseFresnelParameters != null) {
            material.diffuseFresnelParameters = parseFresnelParameters(parsedMaterial.diffuseFresnelParameters);
        }
		
        if (parsedMaterial.ambientTexture != null) {
            material.ambientTexture = loadTexture(rootUrl, parsedMaterial.ambientTexture, scene);
        }
		
        if (parsedMaterial.opacityTexture != null) {
            material.opacityTexture = loadTexture(rootUrl, parsedMaterial.opacityTexture, scene);
        }
		
        if (parsedMaterial.opacityFresnelParameters != null) {
            material.opacityFresnelParameters = parseFresnelParameters(parsedMaterial.opacityFresnelParameters);
        }
		
        if (parsedMaterial.reflectionTexture != null) {
            material.reflectionTexture = loadTexture(rootUrl, parsedMaterial.reflectionTexture, scene);
        }
		
        if (parsedMaterial.reflectionFresnelParameters != null) {
            material.reflectionFresnelParameters = parseFresnelParameters(parsedMaterial.reflectionFresnelParameters);
        }
		
        if (parsedMaterial.emissiveTexture != null) {
            material.emissiveTexture = loadTexture(rootUrl, parsedMaterial.emissiveTexture, scene);
        }
		
        if (parsedMaterial.emissiveFresnelParameters != null) {
            material.emissiveFresnelParameters = parseFresnelParameters(parsedMaterial.emissiveFresnelParameters);
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
		
        Tags.AddTagsTo(multiMaterial, parsedMultiMaterial.tags);
		
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
            particleSystem.particleTexture.name = parsedParticleSystem.textureName;
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

    private static function parseShadowGenerator(parsedShadowGenerator:Dynamic, scene:Scene):ShadowGenerator {
        var light:DirectionalLight = cast scene.getLightByID(parsedShadowGenerator.lightId);
        var shadowGenerator:ShadowGenerator = new ShadowGenerator(parsedShadowGenerator.mapSize, light);
		
        for (meshIndex in 0...parsedShadowGenerator.renderList.length) {
            var mesh = scene.getMeshByID(parsedShadowGenerator.renderList[meshIndex]);
            shadowGenerator.getShadowMap().renderList.push(mesh);
        }
		
        if (parsedShadowGenerator.usePoissonSampling != null) {
            shadowGenerator.usePoissonSampling = true;
        } else if (parsedShadowGenerator.useVarianceShadowMap != null) {
            shadowGenerator.useVarianceShadowMap = true;
        } else if (parsedShadowGenerator.useBlurVarianceShadowMap != null) {
            shadowGenerator.useBlurVarianceShadowMap = true;
			
            if (parsedShadowGenerator.blurScale != null) {
                shadowGenerator.blurScale = parsedShadowGenerator.blurScale;
            }
			
            if (parsedShadowGenerator.blurBoxOffset != null) {
                shadowGenerator.blurBoxOffset = parsedShadowGenerator.blurBoxOffset;
            }
        }
		
        if (parsedShadowGenerator.bias != null) {
            shadowGenerator.bias = parsedShadowGenerator.bias;
        }
		
        return shadowGenerator;
    }

    private static function parseAnimation(parsedAnimation:Dynamic):Animation {
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
					data = Vector3.FromArray(key.values);
					
                default:
                    data = Vector3.FromArray(key.values);
                    
            }
			
            keys.push({
                frame:key.frame,
                value:data
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
                cast(light, DirectionalLight).position = Vector3.FromArray(parsedLight.position);
				
            case 2:
                light = new SpotLight(parsedLight.name, Vector3.FromArray(parsedLight.position), Vector3.FromArray(parsedLight.direction), parsedLight.angle, parsedLight.exponent, scene);
				
            case 3:
                light = new HemisphericLight(parsedLight.name, Vector3.FromArray(parsedLight.direction), scene);
                cast(light, HemisphericLight).groundColor = Color3.FromArray(parsedLight.groundColor);
				
        }				
		
        light.id = parsedLight.id;
		
		if(parsedLight.tags != null) {
			Tags.AddTagsTo(light, parsedLight.tags);
		}
		
        if (parsedLight.intensity != null) {
            light.intensity = parsedLight.intensity;
        }
		
        if (parsedLight.range != null) {
            light.range = parsedLight.range;
        }
		
        light.diffuse = Color3.FromArray(parsedLight.diffuse);
        light.specular = Color3.FromArray(parsedLight.specular);
		
        if (parsedLight.excludedMeshesIds != null && parsedLight.excludedMeshesIds.length > 0) {
            light._excludedMeshesIds = parsedLight.excludedMeshesIds;
        }
		
        // Parent
        if (parsedLight.parentId != null) {
            light._waitingParentId = parsedLight.parentId;
        }
		
        if (parsedLight.includedOnlyMeshesIds != null && parsedLight.includedOnlyMeshesIds.length > 0) {
            light._includedOnlyMeshesIds = parsedLight.includedOnlyMeshesIds;
        }
		
        // Animations
        if (parsedLight.animations != null) {
            for (animationIndex in 0...parsedLight.animations.length) {
                var parsedAnimation = parsedLight.animations[animationIndex];
                light.animations.push(parseAnimation(parsedAnimation));
            }
        }
		
        if (parsedLight.autoAnimate != null) {
            scene.beginAnimation(light, parsedLight.autoAnimateFrom, parsedLight.autoAnimateTo, parsedLight.autoAnimateLoop, 1.0);
        }
		
		return light;
    }

    public static function parseCamera(parsedCamera:Dynamic, scene:Scene):Camera {
        var camera:Camera = null;
        var position:Vector3 = Vector3.FromArray(parsedCamera.position);
        var lockedTargetMesh = (parsedCamera.lockedTargetId != null) ? scene.getLastMeshByID(parsedCamera.lockedTargetId) : null;
		
        if (parsedCamera.type == "AnaglyphArcRotateCamera" || parsedCamera.type == "ArcRotateCamera") {
            var alpha = parsedCamera.alpha;
            var beta = parsedCamera.beta;
            var radius = parsedCamera.radius;
            if (parsedCamera.type == "AnaglyphArcRotateCamera") {
                var eye_space = parsedCamera.eye_space;
                camera = new AnaglyphArcRotateCamera(parsedCamera.name, alpha, beta, radius, lockedTargetMesh, eye_space, scene);
            } else {
                camera = new ArcRotateCamera(parsedCamera.name, alpha, beta, radius, lockedTargetMesh, scene);
            }
			
        } else if (parsedCamera.type == "AnaglyphFreeCamera") {
            var eye_space = parsedCamera.eye_space;
            camera = new AnaglyphFreeCamera(parsedCamera.name, position, eye_space, scene);
			
        } else if (parsedCamera.type == "DeviceOrientationCamera") {
            //camera = new DeviceOrientationCamera(parsedCamera.name, position, scene);
			
        } else if (parsedCamera.type == "FollowCamera") {
            camera = new FollowCamera(parsedCamera.name, position, scene);
            cast(camera, FollowCamera).heightOffset = parsedCamera.heightOffset;
            cast(camera, FollowCamera).radius = parsedCamera.radius;
            cast(camera, FollowCamera).rotationOffset = parsedCamera.rotationOffset;
            if (lockedTargetMesh != null) {
                cast(camera, FollowCamera).target = lockedTargetMesh;
			}
        /*} else if (parsedCamera.type == "GamepadCamera") {
            camera = new GamepadCamera(parsedCamera.name, position, scene);

        } else if (parsedCamera.type == "OculusCamera") {
            camera = new OculusCamera(parsedCamera.name, position, scene);

        } else if (parsedCamera.type == "TouchCamera") {
            camera = new TouchCamera(parsedCamera.name, position, scene);

        } else if (parsedCamera.type == "VirtualJoysticksCamera") {
            camera = new VirtualJoysticksCamera(parsedCamera.name, position, scene);

        } else if (parsedCamera.type == "WebVRCamera") {
            camera = new WebVRCamera(parsedCamera.name, position, scene);

        } else if (parsedCamera.type == "VRDeviceOrientationCamera") {
            camera = new VRDeviceOrientationCamera(parsedCamera.name, position, scene);*/

        } else {
            // Free Camera is the default value
            camera = new FreeCamera(parsedCamera.name, position, scene);
        }
		
        // Test for lockedTargetMesh & FreeCamera outside of if-else-if nest, since things like GamepadCamera extend FreeCamera
        if (lockedTargetMesh != null && Std.is(camera, FreeCamera)) {
            cast(camera, FreeCamera).lockedTarget = lockedTargetMesh;
        }
		
        camera.id = parsedCamera.id;
		
        Tags.AddTagsTo(camera, parsedCamera.tags);
		
        // Parent
        if (parsedCamera.parentId != null) {
            camera._waitingParentId = parsedCamera.parentId;
        }
		
        // Target
        if (parsedCamera.target != null) {
			if(Std.is(camera, FreeCamera)) {
				cast(camera, FreeCamera).setTarget(Vector3.FromArray(parsedCamera.target));
			} else {
				// For ArcRotateCamera
				cast(camera, ArcRotateCamera).target = Vector3.FromArray(parsedCamera.target);
			}
        } else {
            cast(camera, FreeCamera).rotation = Vector3.FromArray(parsedCamera.rotation);
        }
		
        camera.fov = parsedCamera.fov;
        camera.minZ = parsedCamera.minZ;
        camera.maxZ = parsedCamera.maxZ;
		
        cast(camera, FreeCamera).speed = parsedCamera.speed;
        cast(camera, FreeCamera).inertia = parsedCamera.inertia;
		
        cast(camera, FreeCamera).checkCollisions = parsedCamera.checkCollisions;
        cast(camera, FreeCamera).applyGravity = parsedCamera.applyGravity;
		
        if (parsedCamera.ellipsoid != null) {
            cast(camera, FreeCamera).ellipsoid = Vector3.FromArray(parsedCamera.ellipsoid);
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
		
        // Layer Mask
        if (parsedCamera.layerMask != null) {
            camera.layerMask = Std.int(Math.abs(Std.int(parsedCamera.layerMask)));
        } else {
            camera.layerMask = 0xFFFFFFFF;
        }
		
        return camera;
    }

    public static function parseGeometry(parsedGeometry:Dynamic, scene:Scene):Geometry {
        var id = parsedGeometry.id;
        return scene.getGeometryByID(id);
    }

    public static function parseBox(parsedBox:Dynamic, scene:Scene):Geometry {
        if (parseGeometry(parsedBox, scene) != null) {
            return null; // null since geometry could be something else than a box...
        }
		
        var box = new Box(parsedBox.id, scene, parsedBox.size, parsedBox.canBeRegenerated, null);
        Tags.AddTagsTo(box, parsedBox.tags);
		
        scene.pushGeometry(box, true);
		
        return box;
    }

    private static function parseSphere(parsedSphere:Dynamic, scene:Scene):Geometry {
        if (parseGeometry(parsedSphere, scene) == null) {
            return null; // null since geometry could be something else than a sphere...
        }
		
        var sphere = new Sphere(parsedSphere.id, scene, parsedSphere.segments, parsedSphere.diameter, parsedSphere.canBeRegenerated, null);
        Tags.AddTagsTo(sphere, parsedSphere.tags);
		
        scene.pushGeometry(sphere, true);
		
        return sphere;
    }

	private static function parseCylinder(parsedCylinder:Dynamic, scene:Scene):Geometry {
        if (parseGeometry(parsedCylinder, scene) == null) {
            return null; // null since geometry could be something else than a cylinder...
        }
		
        var cylinder = new Cylinder(parsedCylinder.id, scene, parsedCylinder.height, parsedCylinder.diameterTop, parsedCylinder.diameterBottom, parsedCylinder.tessellation, parsedCylinder.subdivisions, parsedCylinder.canBeRegenerated, null);
        Tags.AddTagsTo(cylinder, parsedCylinder.tags);
		
        scene.pushGeometry(cylinder, true);
		
        return cylinder;
    }

    private static function parseTorus(parsedTorus:Dynamic, scene:Scene):Geometry {
        if (parseGeometry(parsedTorus, scene) == null) {
            return null; // null since geometry could be something else than a torus...
        }
		
        var torus = new Torus(parsedTorus.id, scene, parsedTorus.diameter, parsedTorus.thickness, parsedTorus.tessellation, parsedTorus.canBeRegenerated, null);
        Tags.AddTagsTo(torus, parsedTorus.tags);
		
        scene.pushGeometry(torus, true);
		
        return torus;
    }

    private static function parseGround(parsedGround:Dynamic, scene:Scene):Dynamic {
        if (parseGeometry(parsedGround, scene) == null) {
            return null; // null since geometry could be something else than a ground...
        }
		
        var ground = new Ground(parsedGround.id, scene, parsedGround.width, parsedGround.height, parsedGround.subdivisions, parsedGround.canBeRegenerated, null);
        Tags.AddTagsTo(ground, parsedGround.tags);
		
        scene.pushGeometry(ground, true);
		
        return ground;
    }

    private static function parsePlane(parsedPlane:Dynamic, scene:Scene):Geometry {
        if (parseGeometry(parsedPlane, scene) == null) {
            return null; // null since geometry could be something else than a plane...
        }
		
        var plane = new com.babylonhx.mesh.primitives.Plane(parsedPlane.id, scene, parsedPlane.size, parsedPlane.canBeRegenerated, null);
        Tags.AddTagsTo(plane, parsedPlane.tags);
		
        scene.pushGeometry(plane, true);
		
        return plane;
    }

    private static function parseTorusKnot(parsedTorusKnot:Dynamic, scene:Scene):Geometry {
        if (parseGeometry(parsedTorusKnot, scene) == null) {
            return null; // null since geometry could be something else than a torusKnot...
        }
		
        var torusKnot = new TorusKnot(parsedTorusKnot.id, scene, parsedTorusKnot.radius, parsedTorusKnot.tube, parsedTorusKnot.radialSegments, parsedTorusKnot.tubularSegments, parsedTorusKnot.p, parsedTorusKnot.q, parsedTorusKnot.canBeRegenerated, null);
        Tags.AddTagsTo(torusKnot, parsedTorusKnot.tags);
		
        scene.pushGeometry(torusKnot, true);
		
        return torusKnot;
    }

    private static function parseVertexData(parsedVertexData:Dynamic, scene:Scene, rootUrl:String):Geometry {
        if (parseGeometry(parsedVertexData, scene) == null) {
            return null; // null since geometry could be a primitive
        }
		
        var geometry = new Geometry(parsedVertexData.id, scene);
		
        Tags.AddTagsTo(geometry, parsedVertexData.tags);
		
        if (parsedVertexData.delayLoadingFile != null && parsedVertexData.delayLoadingFile != "") {
            geometry.delayLoadState = Engine.DELAYLOADSTATE_NOTLOADED;
            geometry.delayLoadingFile = rootUrl + parsedVertexData.delayLoadingFile;
            geometry._boundingInfo = new BoundingInfo(Vector3.FromArray(parsedVertexData.boundingBoxMinimum), Vector3.FromArray(parsedVertexData.boundingBoxMaximum));
			
            geometry._delayInfo = [];
            if (parsedVertexData.hasUVs) {
                geometry._delayInfo.push(VertexBuffer.UVKind);
            }
			
            if (parsedVertexData.hasUVs2) {
                geometry._delayInfo.push(VertexBuffer.UV2Kind);
            }
			
			if (parsedVertexData.hasUVs3) {
                geometry._delayInfo.push(VertexBuffer.UV3Kind);
            }
			
            if (parsedVertexData.hasUVs4) {
                geometry._delayInfo.push(VertexBuffer.UV4Kind);
            }
			
            if (parsedVertexData.hasUVs5) {
                geometry._delayInfo.push(VertexBuffer.UV5Kind);
            }
			
            if (parsedVertexData.hasUVs6) {
                geometry._delayInfo.push(VertexBuffer.UV6Kind);
            }
			
            if (parsedVertexData.hasColors) {
                geometry._delayInfo.push(VertexBuffer.ColorKind);
            }
			
            if (parsedVertexData.hasMatricesIndices) {
                geometry._delayInfo.push(VertexBuffer.MatricesIndicesKind);
            }
			
            if (parsedVertexData.hasMatricesWeights) {
                geometry._delayInfo.push(VertexBuffer.MatricesWeightsKind);
            }
			
            geometry._delayLoadingFunction = importVertexData;
        } else {
            importVertexData(parsedVertexData, geometry);
        }
		
        scene.pushGeometry(geometry, true);
		
        return geometry;
    }

    private static function parseMesh(parsedMesh:Dynamic, scene:Scene, rootUrl:String):Mesh {
        var mesh = new Mesh(parsedMesh.name, scene);
        mesh.id = parsedMesh.id;
		
        Tags.AddTagsTo(mesh, parsedMesh.tags);
		
        mesh.position = Vector3.FromArray(parsedMesh.position);
		
        if (parsedMesh.rotationQuaternion != null) {
            mesh.rotationQuaternion = Quaternion.FromArray(parsedMesh.rotationQuaternion);
        } else if (parsedMesh.rotation != null) {
            mesh.rotation = Vector3.FromArray(parsedMesh.rotation);
        }
		
        mesh.scaling = Vector3.FromArray(parsedMesh.scaling);
		
        if (parsedMesh.localMatrix != null) {
            mesh.setPivotMatrix(Matrix.FromArray(parsedMesh.localMatrix));
        } else if (parsedMesh.pivotMatrix != null) {
            mesh.setPivotMatrix(Matrix.FromArray(parsedMesh.pivotMatrix));
        }
		
        mesh.setEnabled(parsedMesh.isEnabled);
        mesh.isVisible = parsedMesh.isVisible;
        mesh.infiniteDistance = parsedMesh.infiniteDistance;
		
        mesh.showBoundingBox = parsedMesh.showBoundingBox;
        mesh.showSubMeshesBoundingBox = parsedMesh.showSubMeshesBoundingBox;
		
		if (parsedMesh.applyFog != null && parsedMesh.applyFog) {
			mesh.applyFog = parsedMesh.applyFog;
        }
		
        if (parsedMesh.pickable != null) {
            mesh.isPickable = parsedMesh.pickable;
        }
		
		if (parsedMesh.alphaIndex != null) {
			mesh.alphaIndex = parsedMesh.alphaIndex;
		}
		
        mesh.receiveShadows = parsedMesh.receiveShadows;
        mesh.billboardMode = parsedMesh.billboardMode;
		
        if (parsedMesh.visibility != null) {
            mesh.visibility = parsedMesh.visibility;
        }
		
        mesh.checkCollisions = parsedMesh.checkCollisions;
        mesh._shouldGenerateFlatShading = parsedMesh.useFlatShading;
		
        // Parent
        if (parsedMesh.parentId != null) {
            mesh._waitingParentId = parsedMesh.parentId;
        }
		
		// Actions
        if (parsedMesh.actions != null) {
            mesh._waitingActions = parsedMesh.actions;
        }
		
        // Geometry
        mesh.hasVertexAlpha = parsedMesh.hasVertexAlpha;
		
        if (parsedMesh.delayLoadingFile != null && parsedMesh.delayLoadingFile == true) {
            mesh.delayLoadState = Engine.DELAYLOADSTATE_NOTLOADED;
            mesh.delayLoadingFile = rootUrl + parsedMesh.delayLoadingFile;
            mesh._boundingInfo = new BoundingInfo(Vector3.FromArray(parsedMesh.boundingBoxMinimum), Vector3.FromArray(parsedMesh.boundingBoxMaximum));
			
            if (parsedMesh._binaryInfo != null) {
                mesh._binaryInfo = parsedMesh._binaryInfo;
            }
			
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
			
            mesh._delayLoadingFunction = importGeometry;
			
            if (SceneLoader.ForceFullSceneLoadingForIncremental) {
                mesh._checkDelayState();
            }
			
        } else {
            importGeometry(parsedMesh, mesh);
        }
		
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
        if (parsedMesh.physicsImpostor != null) {
            if (!scene.isPhysicsEnabled()) {
                scene.enablePhysics();
            }
			
			var physicsOptions:PhysicsBodyCreationOptions = new PhysicsBodyCreationOptions();
			physicsOptions.mass = parsedMesh.physicsMass;
			physicsOptions.friction = parsedMesh.physicsFriction;
			physicsOptions.restitution = parsedMesh.physicsRestitution;
				
            mesh.setPhysicsState(parsedMesh.physicsImpostor, physicsOptions);
        }
		
        // Animations
        if (parsedMesh.animations != null) {
            for (animationIndex in 0...parsedMesh.animations.length) {
                var parsedAnimation = parsedMesh.animations[animationIndex];				
                mesh.animations.push(parseAnimation(parsedAnimation));
            }
        }
		
        if (parsedMesh.autoAnimate != null) {
            scene.beginAnimation(mesh, parsedMesh.autoAnimateFrom, parsedMesh.autoAnimateTo, parsedMesh.autoAnimateLoop, 1.0);
        }
		
        // Layer Mask
        if (parsedMesh.layerMask != null) {
            mesh.layerMask = Std.int(Math.abs(parsedMesh.layerMask));
        } else {
            mesh.layerMask = 0xFFFFFFFF;
        }
		
        // Instances
        if (parsedMesh.instances != null) {
            for (index in 0...parsedMesh.instances.length) {
                var parsedInstance = parsedMesh.instances[index];
                var instance = mesh.createInstance(parsedInstance.name);
				
                Tags.AddTagsTo(instance, parsedInstance.tags);
				
                instance.position = Vector3.FromArray(parsedInstance.position);
				
                if (parsedInstance.rotationQuaternion != null) {
                    instance.rotationQuaternion = Quaternion.FromArray(parsedInstance.rotationQuaternion);
                } else if (parsedInstance.rotation != null) {
                    instance.rotation = Vector3.FromArray(parsedInstance.rotation);
                }
				
                instance.scaling = Vector3.FromArray(parsedInstance.scaling);
				
                instance.checkCollisions = mesh.checkCollisions;
				
                if (parsedMesh.animations != null) {
                    for (animationIndex in 0...parsedMesh.animations.length) {
                        var parsedAnimation = parsedMesh.animations[animationIndex];
                        instance.animations.push(parseAnimation(parsedAnimation));
                    }
                }
            }
        }
		
        return mesh;
    }
	
	private static function parseActions(parsedActions:Dynamic, object:AbstractMesh, scene:Scene) {
        var actionManager = new ActionManager(scene);
        if (object == null) {
            scene.actionManager = actionManager;
		}
        else {
            object.actionManager = actionManager;
		}
		
        // instanciate a new object
        var instanciate = function(name:String, params:Array<Dynamic>):Dynamic {
			var newInstance:Dynamic = null;
			switch(name) {
				case "InterpolateValueAction":
					//newInstance = new InterpolateValueAction(params[0], params[1], params[2], params[3], params[4], params[5], params[6]);
					newInstance = Type.createInstance(InterpolateValueAction, params);
					//trace(Type.createInstance(InterpolateValueAction, params));
					
				case "PlayAnimationAction":
					//newInstance = new PlayAnimationAction(params[0], params[1], params[2], params[3], params[4], params[5]);
					newInstance = Type.createInstance(PlayAnimationAction, params);
					
				case "PlaySoundAction":
					//newInstance = new PlaySoundAction(params[0], params[1], params[2]);
					//newInstance = Type.createInstance(PlaySoundAction, params);
					
			}
			
            return newInstance;
        };
		
        var parseParameter = function(name:String, value:String, target:Dynamic, propertyPath:String):Dynamic {
            if (propertyPath == null) {
                // String, boolean or float
                var floatValue = Std.parseFloat(value);
				
                if (value == "true" || value == "false") {
                    return value == "true";
				}
                else {
                    return Math.isNaN(floatValue) ? value : floatValue;
				}
            }
			
            var effectiveTarget = propertyPath.split(".");
            var values = value.split(",");
			
            // Get effective Target
            for (i in 0...effectiveTarget.length) {
                target = Reflect.field(target, effectiveTarget[i]);
            }
			
            // Return appropriate value with its type
            if (Std.is(target, Bool)) {
                return values[0] == "true";
			}
			
            if (Std.is(target, String)) {
                return values[0];
			}
			
            // Parameters with multiple values such as Vector3 etc.
            var split:Array<Float> = [];
            for (i in 0...values.length) {
                split.push(Std.parseFloat(values[i]));
			}
			
            if (Std.is(target, Vector3)) {
                return Vector3.FromArray(split);
			}
			
            if (Std.is(target, Vector4)) {
                return Vector4.FromArray(split);
			}
			
            if (Std.is(target, Color3)) {
                return Color3.FromArray(split);
			}
			
            if (Std.is(target, Color4)) {
                return Color4.FromArray(split);
			}
			
            return Std.parseFloat(values[0]);
        };

        // traverse graph per trigger
        function traverse(parsedAction:Dynamic, trigger:Dynamic, condition:Condition, action:Action, combineArray:Array<Action> = null) {
			if (parsedAction.detached != null && parsedAction.detached == true) {
				return;
			}
            var parameters:Array<Dynamic> = [];
            var target:Dynamic = null;
            var propertyPath:String = "";
			var combine = parsedAction.combine != null && parsedAction.combine.length > 0;
			
            // Parameters
            if (parsedAction.type == 2) {
                parameters.push(actionManager);
			}
            else {
                parameters.push(trigger);
			}
			
			if (combine) {
				var actions = new Array<Action>();
                for (j in 0...parsedAction.combine.length) {
                    traverse(parsedAction.combine[j], ActionManager.NothingTrigger, condition, action, actions);
                }
                parameters.push(actions);
			} 
			else {
				for (i in 0...parsedAction.properties.length) {
					var value:Dynamic = parsedAction.properties[i].value;
					var name:String = parsedAction.properties[i].name;
					var targetType:String = parsedAction.properties[i].targetType;
					
					if (name == "target") {
						if (targetType != null && targetType == "SceneProperties") {
							value = target = scene;
						}
						else {
							value = target = scene.getNodeByName(value);
						}
					}
					else if (name == "parent") {
						value = scene.getNodeByName(value);
					}
					else if (name == "sound") {
						// TODO
						continue;
						//val = scene.getSoundByName(value);
					}
					else if (name != "propertyPath") {
						if (parsedAction.type == 2 && name == "operator") {
							// ??? TODO ???
							value = Reflect.field(ValueCondition, cast value);
						}
						else {
							value = parseParameter(name, cast value, target, name == "value" ? propertyPath : null);
						}
					} 
					else {
						propertyPath = cast value;
					}
					
					parameters.push(value);
				}
			}
            
			if (combineArray == null) {
				parameters.push(condition);
			}
			else {
				parameters.push(null);
			}
			
            // If interpolate value action
            if (parsedAction.name == "InterpolateValueAction") {
                var param = parameters[parameters.length - 2];
                parameters[parameters.length - 1] = param;
                parameters[parameters.length - 2] = condition;
            }
			
            // Action or condition(s)
            var newAction:Dynamic = instanciate(parsedAction.name, parameters);
			if(newAction != null) {
				if (Std.is(newAction, Condition)) {
					condition = newAction;
					newAction = action;
				} 
				else {
					condition = null;
					if (action != null) {
						action.then(newAction);
					}
					else {
						actionManager.registerAction(newAction);
					}
				}
			}
			
            for (i in 0...parsedAction.children.length) {
                traverse(parsedAction.children[i], trigger, condition, newAction);
			}
        };
		
        // triggers
        for (i in 0...parsedActions.children.length) {
            var triggerParams:Dynamic;
            var trigger = parsedActions.children[i];
			
            if (trigger.properties.length > 0) {
                //triggerParams = { trigger: Reflect.field(ActionManager, trigger.name), parameter: scene.getMeshByName(cast(trigger.properties, Array<Dynamic>)[0].value) };
				var param:Dynamic = cast(trigger.properties, Array<Dynamic>)[0].value;
				var value = cast(trigger.properties, Array<Dynamic>)[0].targetType == null ? param : scene.getMeshByName(cast param);
				triggerParams = { trigger: Reflect.field(ActionManager, trigger.name), parameter: value };
            }
            else {
                triggerParams = Reflect.field(ActionManager, trigger.name);
			}
			
            for (j in 0...trigger.children.length) {
				if(!trigger.detached) {
					traverse(cast(trigger.children, Array<Dynamic>)[j], triggerParams, null, null);
				}
			}
        }
    }

    public static function isDescendantOf(mesh:Dynamic, _names:Dynamic, hierarchyIds:Array<Int>):Bool {
        var names = Std.is(_names, Array) ? _names : [_names];
        for (name in names) {
            if (mesh.name == name) {
                hierarchyIds.push(mesh.id);
                return true;
            }
        }
		
        if (mesh.parentId != null && hierarchyIds.indexOf(mesh.parentId) != -1) {
            hierarchyIds.push(mesh.id);
            return true;
        }
		
        return false;
    }

    public static function importVertexData(parsedVertexData:Dynamic, geometry:Geometry) {
        var vertexData:VertexData = new VertexData();
		
        // positions
        var positions = parsedVertexData.positions;
        if (positions != null) {
            vertexData.set(positions, VertexBuffer.PositionKind);
        }
		
        // normals
        var normals = parsedVertexData.normals;
        if (normals != null) {
            vertexData.set(normals, VertexBuffer.NormalKind);
        }
		
        // uvs
        var uvs = parsedVertexData.uvs;
        if (uvs != null) {
            vertexData.set(uvs, VertexBuffer.UVKind);
        }
		
        // uv2s
        var uv2s = parsedVertexData.uv2s;
        if (uv2s != null) {
            vertexData.set(uv2s, VertexBuffer.UV2Kind);
        }
		
		// uv3s
        var uv3s = parsedVertexData.uv3s;
        if (uv3s != null) {
            vertexData.set(uv3s, VertexBuffer.UV3Kind);
        }
		
        // uv4s
        var uv4s = parsedVertexData.uv4s;
        if (uv4s != null) {
            vertexData.set(uv4s, VertexBuffer.UV4Kind);
        }
		
        // uv5s
        var uv5s = parsedVertexData.uv5s;
        if (uv5s != null) {
            vertexData.set(uv5s, VertexBuffer.UV5Kind);
        }
		
        // uv6s
        var uv6s = parsedVertexData.uv6s;
        if (uv6s != null) {
            vertexData.set(uv6s, VertexBuffer.UV6Kind);
        }
		
        // colors
        var colors = parsedVertexData.colors;
        if (colors != null) {
            vertexData.set(checkColors4(colors, Std.int(positions.length / 3)), VertexBuffer.ColorKind);
        }
		
        // matricesIndices
        var matricesIndices = parsedVertexData.matricesIndices;
        if (matricesIndices != null) {
            vertexData.set(matricesIndices, VertexBuffer.MatricesIndicesKind);
        }
		
        // matricesWeights
        var matricesWeights = parsedVertexData.matricesWeights;
        if (matricesWeights != null) {
            vertexData.set(matricesWeights, VertexBuffer.MatricesWeightsKind);
        }
		
        // indices
        var indices = parsedVertexData.indices;
        if (indices != null) {
            vertexData.indices = indices;
        }
		
        geometry.setAllVerticesData(vertexData, parsedVertexData.updatable);
    }

    public static function importGeometry(parsedGeometry:Dynamic, mesh:Mesh) {
        var scene:Scene = mesh.getScene();
		
        // Geometry
        var geometryId = parsedGeometry.geometryId;
        if (geometryId != null) {
            var geometry = scene.getGeometryByID(geometryId);
            if (geometry != null) {
                geometry.applyToMesh(mesh);
            }
        //} else if (Std.is(parsedGeometry, ArrayBuffer)) {
            /*var binaryInfo = mesh._binaryInfo;
			 * 
            if (binaryInfo.positionsAttrDesc != null && binaryInfo.positionsAttrDesc.count > 0) {
                var positionsData = new Float32Array(parsedGeometry, binaryInfo.positionsAttrDesc.offset, binaryInfo.positionsAttrDesc.count);
                mesh.setVerticesData(VertexBuffer.PositionKind, positionsData, false);
            }
			
            if (binaryInfo.normalsAttrDesc != null && binaryInfo.normalsAttrDesc.count > 0) {
                var normalsData = new Float32Array(parsedGeometry, binaryInfo.normalsAttrDesc.offset, binaryInfo.normalsAttrDesc.count);
                mesh.setVerticesData(VertexBuffer.NormalKind, normalsData, false);
            }
			
            if (binaryInfo.uvsAttrDesc != null && binaryInfo.uvsAttrDesc.count > 0) {
                var uvsData = new Float32Array(parsedGeometry, binaryInfo.uvsAttrDesc.offset, binaryInfo.uvsAttrDesc.count);
                mesh.setVerticesData(VertexBuffer.UVKind, uvsData, false);
            }
			
            if (binaryInfo.uvs2AttrDesc != null && binaryInfo.uvs2AttrDesc.count > 0) {
                var uvs2Data = new Float32Array(parsedGeometry, binaryInfo.uvs2AttrDesc.offset, binaryInfo.uvs2AttrDesc.count);
                mesh.setVerticesData(VertexBuffer.UV2Kind, uvs2Data, false);
            }
			
            if (binaryInfo.colorsAttrDesc != null && binaryInfo.colorsAttrDesc.count > 0) {
                var colorsData = new Float32Array(parsedGeometry, binaryInfo.colorsAttrDesc.offset, binaryInfo.colorsAttrDesc.count);
                mesh.setVerticesData(VertexBuffer.ColorKind, colorsData, false);
            }
			
            if (binaryInfo.matricesIndicesAttrDesc != null && binaryInfo.matricesIndicesAttrDesc.count > 0) {
                var matricesIndicesData = new Int32Array(parsedGeometry, binaryInfo.matricesIndicesAttrDesc.offset, binaryInfo.matricesIndicesAttrDesc.count);
                mesh.setVerticesData(VertexBuffer.MatricesIndicesKind, matricesIndicesData, false);
            }
			
            if (binaryInfo.matricesWeightsAttrDesc != null && binaryInfo.matricesWeightsAttrDesc.count > 0) {
                var matricesWeightsData = new Float32Array(parsedGeometry, binaryInfo.matricesWeightsAttrDesc.offset, binaryInfo.matricesWeightsAttrDesc.count);
                mesh.setVerticesData(VertexBuffer.MatricesWeightsKind, matricesWeightsData, false);
            }
			
            if (binaryInfo.indicesAttrDesc != null && binaryInfo.indicesAttrDesc.count > 0) {
                var indicesData = new Int32Array(parsedGeometry, binaryInfo.indicesAttrDesc.offset, binaryInfo.indicesAttrDesc.count);
                mesh.setIndices(indicesData);
            }
			
            if (binaryInfo.subMeshesAttrDesc != null && binaryInfo.subMeshesAttrDesc.count > 0) {
                var subMeshesData = new Int32Array(parsedGeometry, binaryInfo.subMeshesAttrDesc.offset, binaryInfo.subMeshesAttrDesc.count * 5);
				
                mesh.subMeshes = [];
                for (i in 0...binaryInfo.subMeshesAttrDesc.count) {
                    var materialIndex = subMeshesData[(i * 5) + 0];
                    var verticesStart = subMeshesData[(i * 5) + 1];
                    var verticesCount = subMeshesData[(i * 5) + 2];
                    var indexStart = subMeshesData[(i * 5) + 3];
                    var indexCount = subMeshesData[(i * 5) + 4];
					
                    var subMesh = new SubMesh(materialIndex, verticesStart, verticesCount, indexStart, indexCount, mesh);
                }
            }*/
        } else if (parsedGeometry.positions != null && parsedGeometry.normals != null && parsedGeometry.indices != null) {
            mesh.setVerticesData(VertexBuffer.PositionKind, parsedGeometry.positions, false);
            mesh.setVerticesData(VertexBuffer.NormalKind, parsedGeometry.normals, false);
			
            if (parsedGeometry.uvs != null) {
                mesh.setVerticesData(VertexBuffer.UVKind, parsedGeometry.uvs, false);
            }
			
            if (parsedGeometry.uvs2 != null) {
                mesh.setVerticesData(VertexBuffer.UV2Kind, parsedGeometry.uvs2, false);
            }
			
            if (parsedGeometry.colors != null) {
                mesh.setVerticesData(VertexBuffer.ColorKind, checkColors4(parsedGeometry.colors, Std.int(parsedGeometry.positions.length / 3)), false);
            }
			
            if (parsedGeometry.matricesIndices != null) {
                if (!parsedGeometry.matricesIndices._isExpanded) {
                    var floatIndices:Array<Float> = [];
					
                    for (i in 0...parsedGeometry.matricesIndices.length) {
                        var matricesIndex = parsedGeometry.matricesIndices[i];
						
                        floatIndices.push(matricesIndex & 0x000000FF);
                        floatIndices.push((matricesIndex & 0x0000FF00) >> 8);
                        floatIndices.push((matricesIndex & 0x00FF0000) >> 16);
                        floatIndices.push(matricesIndex >> 24);
                    }
					
                    mesh.setVerticesData(VertexBuffer.MatricesIndicesKind, floatIndices, false);
                } else {
                    parsedGeometry.matricesIndices._isExpanded = null;
                    mesh.setVerticesData(VertexBuffer.MatricesIndicesKind, parsedGeometry.matricesIndices, false);
                }
            }
			
            if (parsedGeometry.matricesWeights != null) {
                mesh.setVerticesData(VertexBuffer.MatricesWeightsKind, parsedGeometry.matricesWeights, false);
            }
			
            mesh.setIndices(parsedGeometry.indices);
			
            // SubMeshes
            if (parsedGeometry.subMeshes != null) {
                mesh.subMeshes = [];
                for (subIndex in 0...parsedGeometry.subMeshes.length) {
                    var parsedSubMesh = parsedGeometry.subMeshes[subIndex];
					
                    var subMesh = new SubMesh(parsedSubMesh.materialIndex, parsedSubMesh.verticesStart, parsedSubMesh.verticesCount, parsedSubMesh.indexStart, parsedSubMesh.indexCount, mesh);
                }
            }
        }
		
        // Flat shading
        if (mesh._shouldGenerateFlatShading) {
            mesh.convertToFlatShadedMesh();
            mesh._shouldGenerateFlatShading = false;// null;
        }
		
        // Update
        mesh.computeWorldMatrix(true);
		
        // Octree
        if (scene._selectionOctree != null) {
            scene._selectionOctree.addMesh(mesh);
        }
    }
	
}