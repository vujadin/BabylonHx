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

@:expose('BABYLON.BabylonLiteFileLoader') class BabylonLiteFileLoader {
	
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
			
			var pdm:Array<Dynamic> = cast parsedData.mhs;
            for (index in 0...pdm.length) {
                var parsedMesh = pdm[index];
                if (meshesNames == null || meshesNames == "" || isDescendantOf(parsedMesh, meshesNames, hierarchyIds)) {
					if (Std.is(meshesNames, Array)) {
                        // Remove found mesh name from list.
                        meshesNames.splice(meshesNames.indexOf(parsedMesh.n), 1);
                    }
					
                    // Material ?
                    if (Reflect.hasField(parsedMesh, "mId")) {
                        var materialFound = (loadedMaterialsIds.indexOf(parsedMesh.mId) != -1);
						
                        if (!materialFound) {
							var pdmm:Array<Dynamic> = cast parsedData.mMs;
                            for (multimatIndex in 0...pdmm.length) {
                                var parsedMultiMaterial = pdmm[multimatIndex];
                                if (parsedMultiMaterial.id == parsedMesh.mId) {
									var pdmmm:Array<Dynamic> = cast parsedMultiMaterial.ms;
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
                            loadedMaterialsIds.push(parsedMesh.mId);
                            parseMaterialById(cast parsedMesh.mId, parsedData, scene, rootUrl);
                        }
                    }
					
                    // Skeleton ?
                    if (parsedMesh.sId > -1 && scene.skeletons != null) {
                        var skeletonAlreadyLoaded = (loadedSkeletonsIds.indexOf(parsedMesh.sId) > -1);
						
                        if (!skeletonAlreadyLoaded) {
							var pds:Array<Dynamic> = cast parsedData.ss;
                            for (skeletonIndex in 0...pds.length) {
                                var parsedSkeleton = pds[skeletonIndex];
								
                                if (parsedSkeleton.id == parsedMesh.sId) {
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
            if (parsedData.pSs != null) {
				var pdp:Array<Dynamic> = cast parsedData.pSs;
                for (index in 0...pdp.length) {
					var parsedParticleSystem = pdp[index];				
                    if (hierarchyIds.indexOf(parsedParticleSystem.eId) != -1) {
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
            scene.autoClear = parsedData.aC;
            scene.clearColor = Color3.FromArray(parsedData.cC);
            scene.ambientColor = Color3.FromArray(parsedData.ambC);
            scene.gravity = Vector3.FromArray(parsedData.g);
			
            // Fog
            if (parsedData.fM != null && parsedData.fM != 0) {
                scene.fogMode = parsedData.fM;
                scene.fogColor = Color3.FromArray(parsedData.fC);
                scene.fogStart = parsedData.fS;
                scene.fogEnd = parsedData.fE;
                scene.fogDensity = parsedData.fD;
            }
			
            // Lights
            for (index in 0...parsedData.ls.length) {
                var parsedLight = parsedData.ls[index];
                parseLight(parsedLight, scene);
            }
			
            // Materials
            if (parsedData.ms != null) {
                for (index in 0...parsedData.ms.length) {
                    var parsedMaterial = parsedData.ms[index];
                    parseMaterial(parsedMaterial, scene, rootUrl);
                }
            }
			
            if (parsedData.mMs != null) {
                for (index in 0...parsedData.mMs.length) {
                    var parsedMultiMaterial = parsedData.mMs[index];
                    parseMultiMaterial(parsedMultiMaterial, scene);
                }
            }
			
            // Skeletons
            if (parsedData.ss != null) {
                for (index in 0...parsedData.ss.length) {
                    var parsedSkeleton = parsedData.ss[index];
                    parseSkeleton(parsedSkeleton, scene);
                }
            }
			
            // Geometries
            var geometries = parsedData.gs;
            if (geometries != null) {
                // Boxes
                var boxes:Array<Dynamic> = geometries.bs;
                if (boxes != null) {
                    for (index in 0...boxes.length) {
                        var parsedBox = boxes[index];
                        parseBox(parsedBox, scene);
                    }
                }
				
                // Spheres
                var spheres:Array<Dynamic> = geometries.ss;
                if (spheres != null) {
                    for (index in 0...spheres.length) {
                        var parsedSphere = spheres[index];
                        parseSphere(parsedSphere, scene);
                    }
                }
				
                // Cylinders
                var cylinders:Array<Dynamic> = geometries.cs;
                if (cylinders != null) {
                    for (index in 0...cylinders.length) {
                        var parsedCylinder = cylinders[index];
                        parseCylinder(parsedCylinder, scene);
                    }
                }
				
                // Toruses
                var toruses:Array<Dynamic> = geometries.ts;
                if (toruses != null) {
                    for (index in 0...toruses.length) {
                        var parsedTorus = toruses[index];
                        parseTorus(parsedTorus, scene);
                    }
                }
				
                // Grounds
                var grounds:Array<Dynamic> = geometries.gs;
                if (grounds != null) {
                    for (index in 0...grounds.length) {
                        var parsedGround = grounds[index];
                        parseGround(parsedGround, scene);
                    }
                }
				
                // Planes
                var planes:Array<Dynamic> = geometries.ps;
                if (planes != null) {
                    for (index in 0...planes.length) {
                        var parsedPlane = planes[index];
                        parsePlane(parsedPlane, scene);
                    }
                }
				
                // TorusKnots
                var torusKnots:Array<Dynamic> = geometries.tKs;
                if (torusKnots != null) {
                    for (index in 0...torusKnots.length) {
                        var parsedTorusKnot = torusKnots[index];
                        parseTorusKnot(parsedTorusKnot, scene);
                    }
                }
				
                // VertexData
                var vertexData:Array<Dynamic> = geometries.vD;
                if (vertexData != null) {
                    for (index in 0...vertexData.length) {
                        var parsedVertexData = vertexData[index];
                        parseVertexData(parsedVertexData, scene, rootUrl);
                    }
                }
            }
			
            // Meshes
			var pdm:Array<Dynamic> = cast parsedData.mhs;
            for (index in 0...pdm.length) {
                var parsedMesh = pdm[index];
                parseMesh(parsedMesh, scene, rootUrl);
            }
			
            // Cameras
			var pdc:Array<Dynamic> = cast parsedData.cs;
            for (index in 0...parsedData.cs.length) {
                var parsedCamera = parsedData.cs[index];
                parseCamera(parsedCamera, scene);
            }
			
            if (parsedData.aCId != null) {
                scene.setActiveCameraByID(parsedData.aCId);
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
            if (parsedData.pSs != null) {
                for (index in 0...parsedData.pSs.length) {
                    var parsedParticleSystem = parsedData.pSs[index];
                    parseParticleSystem(parsedParticleSystem, scene, rootUrl);
                }
            }
			
            // Lens flares
            if (parsedData.lFSs != null) {
				trace(parsedData.lFSs);
                for (index in 0...parsedData.lFSs.length) {
                    var parsedLensFlareSystem = parsedData.lFSs[index];
                    parseLensFlareSystem(parsedLensFlareSystem, scene, rootUrl);
                }
            }
			
            // Shadows
            if (parsedData.sGs != null) {
                for (index in 0...parsedData.sGs.length) {
                    var parsedShadowGenerator = parsedData.sGs[index];
                    parseShadowGenerator(parsedShadowGenerator, scene);
                }
            }
			
			// Actions (scene)
            if (parsedData.as != null) {
                parseActions(parsedData.as, null, scene);
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
        var texture = new CubeTexture(rootUrl + parsedTexture.n, scene);
		
        texture.name = parsedTexture.n;
        texture.hasAlpha = parsedTexture.hA;
        texture.level = parsedTexture.l;
        texture.coordinatesMode = parsedTexture.cM;
		
        return texture;
    }

	public static function loadTexture(rootUrl:String, parsedTexture:Dynamic, scene:Scene):Dynamic {
        if (parsedTexture.n != null && parsedTexture.iRT == true) {
            return null;
        }
		
        if (parsedTexture.iC != null && parsedTexture.iC == true) {
            return loadCubeTexture(rootUrl, parsedTexture, scene);
        }
		
        var texture:Texture = null;
		
        if (parsedTexture.mP != null) {
            texture = new MirrorTexture(parsedTexture.n, parsedTexture.rTS, scene, true);
            cast(texture, MirrorTexture)._waitingRenderList = parsedTexture.rL;
            cast(texture, MirrorTexture).mirrorPlane = Plane.FromArray(parsedTexture.mP);
        } else if (parsedTexture.iRT != null && parsedTexture.isRenderTarget == true) {
            texture = new RenderTargetTexture(parsedTexture.n, parsedTexture.rTS, scene, true);
            cast(texture, RenderTargetTexture)._waitingRenderList = parsedTexture.rL;
        } else {
            texture = new Texture(rootUrl + parsedTexture.n, scene);
        }
		
        texture.name = parsedTexture.n;
        texture.hasAlpha = parsedTexture.hA;
		texture.getAlphaFromRGB = parsedTexture.gAFRGB;
        texture.level = parsedTexture.l;
		
        texture.coordinatesIndex = parsedTexture.cI;
        texture.coordinatesMode = parsedTexture.cM;
        texture.uOffset = parsedTexture.uO;
        texture.vOffset = parsedTexture.vO;
        texture.uScale = parsedTexture.uS;
        texture.vScale = parsedTexture.vS;
        texture.uAng = parsedTexture.uA;
        texture.vAng = parsedTexture.vA;
        texture.wAng = parsedTexture.wA;
		
        texture.wrapU = parsedTexture.wU;
        texture.wrapV = parsedTexture.wV;
		
        // Animations
        if (parsedTexture.as != null) {
            for (animationIndex in 0...parsedTexture.as.length) {
                var parsedAnimation = parsedTexture.as[animationIndex];
				
                texture.animations.push(parseAnimation(parsedAnimation));
            }
        }
		
        return texture;
    }

    public static function parseSkeleton(parsedSkeleton:Dynamic, scene:Scene):Skeleton {
        var skeleton = new Skeleton(parsedSkeleton.n, parsedSkeleton.id, scene);
		try {
        for (index in 0...parsedSkeleton.bones.length) {
            var parsedBone = parsedSkeleton.bs[index];
			
            var parentBone = null;
            if (parsedBone.parentBoneIndex > -1) {
                parentBone = skeleton.bones[parsedBone.pBI];
            }
			
            var bone = new Bone(parsedBone.n, skeleton, parentBone, Matrix.FromArray(parsedBone.m));
			
            if (parsedBone.a != null) {
                bone.animations.push(parseAnimation(parsedBone.a));
            }
        }
		} catch (err:Dynamic) {
			trace(err);
		}
		
        return skeleton;
    }

    public static function parseFresnelParameters(parsedFresnelParameters:Dynamic):FresnelParameters {
        var fresnelParameters = new FresnelParameters();
		
        fresnelParameters.isEnabled = parsedFresnelParameters.iE;
        fresnelParameters.leftColor = Color3.FromArray(parsedFresnelParameters.lC);
        fresnelParameters.rightColor = Color3.FromArray(parsedFresnelParameters.rC);
        fresnelParameters.bias = parsedFresnelParameters.b;
        fresnelParameters.power = parsedFresnelParameters.p != null ? parsedFresnelParameters.p : 1.0;
		
        return fresnelParameters;
    }

    public static function parseMaterial(parsedMaterial:Dynamic, scene:Scene, rootUrl:String):Material {
        var material = new StandardMaterial(parsedMaterial.n, scene);
		
        material.ambientColor = Color3.FromArray(parsedMaterial.am);
        material.diffuseColor = Color3.FromArray(parsedMaterial.d);
        material.specularColor = Color3.FromArray(parsedMaterial.s);
        material.specularPower = parsedMaterial.sP;
        material.emissiveColor = Color3.FromArray(parsedMaterial.e);
		
        material.alpha = parsedMaterial.a;
		
        material.id = parsedMaterial.id;
		
        Tags.AddTagsTo(material, parsedMaterial.ts);
        material.backFaceCulling = parsedMaterial.bFC;
        material.wireframe = parsedMaterial.w;
		
        if (parsedMaterial.dT != null) {
            material.diffuseTexture = loadTexture(rootUrl, parsedMaterial.dT, scene);
        }
		
        if (parsedMaterial.dFPs != null) {
            material.diffuseFresnelParameters = parseFresnelParameters(parsedMaterial.dFPs);
        }
		
        if (parsedMaterial.aT != null) {
            material.ambientTexture = loadTexture(rootUrl, parsedMaterial.aT, scene);
        }
		
        if (parsedMaterial.oT != null) {
            material.opacityTexture = loadTexture(rootUrl, parsedMaterial.oT, scene);
        }
		
        if (parsedMaterial.oFPs != null) {
            material.opacityFresnelParameters = parseFresnelParameters(parsedMaterial.oFPs);
        }
		
        if (parsedMaterial.rT != null) {
            material.reflectionTexture = loadTexture(rootUrl, parsedMaterial.rT, scene);
        }
		
        if (parsedMaterial.rFPs != null) {
            material.reflectionFresnelParameters = parseFresnelParameters(parsedMaterial.rFPs);
        }
		
        if (parsedMaterial.eT != null) {
            material.emissiveTexture = loadTexture(rootUrl, parsedMaterial.eT, scene);
        }
		
        if (parsedMaterial.eFPs != null) {
            material.emissiveFresnelParameters = parseFresnelParameters(parsedMaterial.eFPs);
        }
		
        if (parsedMaterial.sT != null) {
            material.specularTexture = loadTexture(rootUrl, parsedMaterial.sT, scene);
        }
		
        if (parsedMaterial.bT != null) {
            material.bumpTexture = loadTexture(rootUrl, parsedMaterial.bT, scene);
        }
		
        return material;
    }

    public static function parseMaterialById(id:String, parsedData:Dynamic, scene:Scene, rootUrl:String):Material {
        for (index in 0...parsedData.ms.length) {
            var parsedMaterial = parsedData.ms[index];
            if (parsedMaterial.id == id) {
                return parseMaterial(parsedMaterial, scene, rootUrl);
            }
        }
		
        return null;
    }

    public static function parseMultiMaterial(parsedMultiMaterial:Dynamic, scene:Scene):MultiMaterial {
        var multiMaterial = new MultiMaterial(parsedMultiMaterial.n, scene);
		
        multiMaterial.id = parsedMultiMaterial.id;
		
        Tags.AddTagsTo(multiMaterial, parsedMultiMaterial.ts);
		
        for (matIndex in 0...parsedMultiMaterial.ms.length) {
            var subMatId = parsedMultiMaterial.ms[matIndex];
			
            if (subMatId != null) {
                multiMaterial.subMaterials.push(scene.getMaterialByID(subMatId));
            } else {
                multiMaterial.subMaterials.push(null);
            }
        }
		
        return multiMaterial;
    }

    public static function parseLensFlareSystem(parsedLensFlareSystem:Dynamic, scene:Scene, rootUrl:String):LensFlareSystem {
        var emitter = scene.getLastEntryByID(parsedLensFlareSystem.eId);
		
        var lensFlareSystem = new LensFlareSystem("lensFlareSystem#" + parsedLensFlareSystem.eId, emitter, scene);
        lensFlareSystem.borderLimit = parsedLensFlareSystem.bL;
		
		trace(parsedLensFlareSystem);
        for (index in 0...parsedLensFlareSystem.fs.length) {
            var parsedFlare = parsedLensFlareSystem.fs[index];
            var flare = new LensFlare(parsedFlare.s, parsedFlare.p, Color3.FromArray(parsedFlare.c), rootUrl + parsedFlare.tN, lensFlareSystem);
        }
		
        return lensFlareSystem;
    }

    public static function parseParticleSystem(parsedParticleSystem:Dynamic, scene:Scene, rootUrl:String):ParticleSystem {
        var emitter = scene.getLastMeshByID(parsedParticleSystem.eId);
        
        var particleSystem = new ParticleSystem("particles#" + emitter.name, parsedParticleSystem.c, scene);
        if (parsedParticleSystem.tN != null && parsedParticleSystem.tN != "") {
            particleSystem.particleTexture = new Texture(rootUrl + parsedParticleSystem.tN, scene);
            particleSystem.particleTexture.name = parsedParticleSystem.tN;
        }
		
        particleSystem.minAngularSpeed = parsedParticleSystem.mnAS;
        particleSystem.maxAngularSpeed = parsedParticleSystem.mxAS;
        particleSystem.minSize = parsedParticleSystem.mnS;
        particleSystem.maxSize = parsedParticleSystem.mxS;
        particleSystem.minLifeTime = parsedParticleSystem.mnLT;
        particleSystem.maxLifeTime = parsedParticleSystem.mxLT;
        particleSystem.emitter = emitter;
        particleSystem.emitRate = parsedParticleSystem.eR;
        particleSystem.minEmitBox = Vector3.FromArray(parsedParticleSystem.mnEB);
        particleSystem.maxEmitBox = Vector3.FromArray(parsedParticleSystem.mxEB);
        particleSystem.gravity = Vector3.FromArray(parsedParticleSystem.g);
        particleSystem.direction1 = Vector3.FromArray(parsedParticleSystem.d1);
        particleSystem.direction2 = Vector3.FromArray(parsedParticleSystem.d2);
        particleSystem.color1 = Color4.FromArray(parsedParticleSystem.c1);
        particleSystem.color2 = Color4.FromArray(parsedParticleSystem.c2);
        particleSystem.colorDead = Color4.FromArray(parsedParticleSystem.cD);
        particleSystem.updateSpeed = parsedParticleSystem.uS;
        particleSystem.targetStopDuration = parsedParticleSystem.tSF;
        particleSystem.textureMask = Color4.FromArray(parsedParticleSystem.tM);
        particleSystem.blendMode = parsedParticleSystem.bM;
        particleSystem.start();

        return particleSystem;
    }

    private static function parseShadowGenerator(parsedShadowGenerator:Dynamic, scene:Scene):ShadowGenerator {
        var light:DirectionalLight = cast scene.getLightByID(parsedShadowGenerator.lId);
        var shadowGenerator:ShadowGenerator = new ShadowGenerator(parsedShadowGenerator.mS, light);
		
        for (meshIndex in 0...parsedShadowGenerator.rL.length) {
            var mesh = scene.getMeshByID(parsedShadowGenerator.rL[meshIndex]);
            shadowGenerator.getShadowMap().renderList.push(mesh);
        }
		
        if (parsedShadowGenerator.uPS != null) {
            shadowGenerator.usePoissonSampling = true;
        } else if (parsedShadowGenerator.uVSM != null) {
            shadowGenerator.useVarianceShadowMap = true;
        } else if (parsedShadowGenerator.uBVSM != null) {
            shadowGenerator.useBlurVarianceShadowMap = true;
			
            if (parsedShadowGenerator.bS != null) {
                shadowGenerator.blurScale = parsedShadowGenerator.bS;
            }
			
            if (parsedShadowGenerator.bBO != null) {
                shadowGenerator.blurBoxOffset = parsedShadowGenerator.bBO;
            }
        }
		
        if (parsedShadowGenerator.b != null) {
            shadowGenerator.bias = parsedShadowGenerator.b;
        }
		
        return shadowGenerator;
    }

    private static function parseAnimation(parsedAnimation:Dynamic):Animation {
        var animation = new Animation(parsedAnimation.n, parsedAnimation.p, parsedAnimation.fPS, parsedAnimation.dT, parsedAnimation.lB);
		
        var dataType = parsedAnimation.dT;
        var keys:Array<BabylonFrame> = [];
        for (index in 0...parsedAnimation.ks.length) {
            var key = parsedAnimation.ks[index];
			
            var data:Dynamic = null;
			
            switch (dataType) {
                case Animation.ANIMATIONTYPE_FLOAT:
                    data = key.vs[0];
                    
                case Animation.ANIMATIONTYPE_QUATERNION:
                    data = Quaternion.FromArray(key.vs);
                    
                case Animation.ANIMATIONTYPE_MATRIX:
                    data = Matrix.FromArray(key.vs);
                    
                case Animation.ANIMATIONTYPE_VECTOR3:
					data = Vector3.FromArray(key.vs);
					
                default:
                    data = Vector3.FromArray(key.vs);
                    
            }
			
            keys.push({
                frame: key.f,
                value: data
            });
        }
		
        animation.setKeys(keys);
		
        return animation;
    }

    public static function parseLight(parsedLight:Dynamic, scene:Scene):Light {
        var light:Light = null;
				
        switch (parsedLight.t) {
            case 0:
                light = new PointLight(parsedLight.n, Vector3.FromArray(parsedLight.p), scene);
				
            case 1:
                light = new DirectionalLight(parsedLight.n, Vector3.FromArray(parsedLight.d), scene);
                cast(light, DirectionalLight).position = Vector3.FromArray(parsedLight.p);
				
            case 2:
                light = new SpotLight(parsedLight.n, Vector3.FromArray(parsedLight.p), Vector3.FromArray(parsedLight.d), parsedLight.a, parsedLight.e, scene);
				
            case 3:
                light = new HemisphericLight(parsedLight.n, Vector3.FromArray(parsedLight.d), scene);
                cast(light, HemisphericLight).groundColor = Color3.FromArray(parsedLight.gC);
				
        }				
		
        light.id = parsedLight.id;
		
		if(parsedLight.ts != null) {
			Tags.AddTagsTo(light, parsedLight.ts);
		}
		
        if (parsedLight.i != null) {
            light.intensity = parsedLight.i;
        }
		
        if (parsedLight.r != null) {
            light.range = parsedLight.r;
        }
		
        light.diffuse = Color3.FromArray(parsedLight.df);
        light.specular = Color3.FromArray(parsedLight.s);
		
        if (parsedLight.eMIds != null && parsedLight.eMIds.length > 0) {
            light._excludedMeshesIds = parsedLight.eMIds;
        }
		
        // Parent
        if (parsedLight.pId != null) {
            light._waitingParentId = parsedLight.pId;
        }
		
        if (parsedLight.iOMIds != null && parsedLight.iOMIds.length > 0) {
            light._includedOnlyMeshesIds = parsedLight.iOMIds;
        }
		
        // Animations
        if (parsedLight.as != null) {
            for (animationIndex in 0...parsedLight.as.length) {
                var parsedAnimation = parsedLight.as[animationIndex];
                light.animations.push(parseAnimation(parsedAnimation));
            }
        }
		
        if (parsedLight.aA != null) {
            scene.beginAnimation(light, parsedLight.aAF, parsedLight.aAT, parsedLight.aAL, 1.0);
        }
		
		return light;
    }

    public static function parseCamera(parsedCamera:Dynamic, scene:Scene):Camera {
        var camera:Camera = null;
        var position:Vector3 = Vector3.FromArray(parsedCamera.p);
        var lockedTargetMesh = (parsedCamera.lTId != null) ? scene.getLastMeshByID(parsedCamera.lTId) : null;
		
        if (parsedCamera.t == "AnaglyphArcRotateCamera" || parsedCamera.t == "ArcRotateCamera") {
            var alpha = parsedCamera.a;
            var beta = parsedCamera.b;
            var radius = parsedCamera.r;
            if (parsedCamera.t == "AnaglyphArcRotateCamera") {
                var eye_space = parsedCamera.es;
                camera = new AnaglyphArcRotateCamera(parsedCamera.n, alpha, beta, radius, lockedTargetMesh, eye_space, scene);
            } else {
                camera = new ArcRotateCamera(parsedCamera.n, alpha, beta, radius, lockedTargetMesh, scene);
            }
			
        } else if (parsedCamera.t == "AnaglyphFreeCamera") {
            var eye_space = parsedCamera.es;
            camera = new AnaglyphFreeCamera(parsedCamera.n, position, eye_space, scene);
			
        } else if (parsedCamera.t == "DeviceOrientationCamera") {
            //camera = new DeviceOrientationCamera(parsedCamera.name, position, scene);
			
        } else if (parsedCamera.t == "FollowCamera") {
            camera = new FollowCamera(parsedCamera.n, position, scene);
            cast(camera, FollowCamera).heightOffset = parsedCamera.hO;
            cast(camera, FollowCamera).radius = parsedCamera.r;
            cast(camera, FollowCamera).rotationOffset = parsedCamera.rO;
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
            camera = new FreeCamera(parsedCamera.n, position, scene);
        }
		
        // Test for lockedTargetMesh & FreeCamera outside of if-else-if nest, since things like GamepadCamera extend FreeCamera
        if (lockedTargetMesh != null && Std.is(camera, FreeCamera)) {
            cast(camera, FreeCamera).lockedTarget = lockedTargetMesh;
        }
		
        camera.id = parsedCamera.id;
		
        Tags.AddTagsTo(camera, parsedCamera.ts);
		
        // Parent
        if (parsedCamera.pId != null) {
            camera._waitingParentId = parsedCamera.pId;
        }
		
        // Target
        if (parsedCamera.tg != null) {
			if(Std.is(camera, FreeCamera)) {
				cast(camera, FreeCamera).setTarget(Vector3.FromArray(parsedCamera.tg));
			} else {
				// For ArcRotateCamera
				cast(camera, ArcRotateCamera).target = Vector3.FromArray(parsedCamera.tg);
			}
        } else {
            cast(camera, FreeCamera).rotation = Vector3.FromArray(parsedCamera.rt);
        }
		
        camera.fov = parsedCamera.fov;
        camera.minZ = parsedCamera.minZ;
        camera.maxZ = parsedCamera.maxZ;
		
        cast(camera, FreeCamera).speed = parsedCamera.s;
        cast(camera, FreeCamera).inertia = parsedCamera.i;
		
        cast(camera, FreeCamera).checkCollisions = parsedCamera.cCs;
        cast(camera, FreeCamera).applyGravity = parsedCamera.aG;
		
        if (parsedCamera.e != null) {
            cast(camera, FreeCamera).ellipsoid = Vector3.FromArray(parsedCamera.e);
        }
		
        // Animations
        if (parsedCamera.as != null) {
            for (animationIndex in 0...parsedCamera.as.length) {
                var parsedAnimation = parsedCamera.as[animationIndex];
                camera.animations.push(parseAnimation(parsedAnimation));
            }
        }
		
        if (parsedCamera.aA != null && parsedCamera.aA == true) {
            scene.beginAnimation(camera, parsedCamera.aAF, parsedCamera.aAT, parsedCamera.aAL, 1.0);
        }
		
        // Layer Mask
        if (parsedCamera.lM != null) {
            camera.layerMask = Std.int(Math.abs(Std.int(parsedCamera.lM)));
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
		
        var box = new Box(parsedBox.id, scene, parsedBox.s, parsedBox.cBR, null);
        Tags.AddTagsTo(box, parsedBox.ts);
		
        scene.pushGeometry(box, true);
		
        return box;
    }

    private static function parseSphere(parsedSphere:Dynamic, scene:Scene):Geometry {
        if (parseGeometry(parsedSphere, scene) == null) {
            return null; // null since geometry could be something else than a sphere...
        }
		
        var sphere = new Sphere(parsedSphere.id, scene, parsedSphere.ss, parsedSphere.d, parsedSphere.cBR, null);
        Tags.AddTagsTo(sphere, parsedSphere.ts);
		
        scene.pushGeometry(sphere, true);
		
        return sphere;
    }

	private static function parseCylinder(parsedCylinder:Dynamic, scene:Scene):Geometry {
        if (parseGeometry(parsedCylinder, scene) == null) {
            return null; // null since geometry could be something else than a cylinder...
        }
		
        var cylinder = new Cylinder(parsedCylinder.id, scene, parsedCylinder.h, parsedCylinder.dT, parsedCylinder.dB, parsedCylinder.t, parsedCylinder.ss, parsedCylinder.cBR, null);
        Tags.AddTagsTo(cylinder, parsedCylinder.ts);
		
        scene.pushGeometry(cylinder, true);
		
        return cylinder;
    }

    private static function parseTorus(parsedTorus:Dynamic, scene:Scene):Geometry {
        if (parseGeometry(parsedTorus, scene) == null) {
            return null; // null since geometry could be something else than a torus...
        }
		
        var torus = new Torus(parsedTorus.id, scene, parsedTorus.d, parsedTorus.t, parsedTorus.tsl, parsedTorus.sBR, null);
        Tags.AddTagsTo(torus, parsedTorus.ts);
		
        scene.pushGeometry(torus, true);
		
        return torus;
    }

    private static function parseGround(parsedGround:Dynamic, scene:Scene):Dynamic {
        if (parseGeometry(parsedGround, scene) == null) {
            return null; // null since geometry could be something else than a ground...
        }
		
        var ground = new Ground(parsedGround.id, scene, parsedGround.w, parsedGround.h, parsedGround.ss, parsedGround.cBR, null);
        Tags.AddTagsTo(ground, parsedGround.ts);
		
        scene.pushGeometry(ground, true);
		
        return ground;
    }

    private static function parsePlane(parsedPlane:Dynamic, scene:Scene):Geometry {
        if (parseGeometry(parsedPlane, scene) == null) {
            return null; // null since geometry could be something else than a plane...
        }
		
        var plane = new com.babylonhx.mesh.primitives.Plane(parsedPlane.id, scene, parsedPlane.s, parsedPlane.cBR, null);
        Tags.AddTagsTo(plane, parsedPlane.ts);
		
        scene.pushGeometry(plane, true);
		
        return plane;
    }

    private static function parseTorusKnot(parsedTorusKnot:Dynamic, scene:Scene):Geometry {
        if (parseGeometry(parsedTorusKnot, scene) == null) {
            return null; // null since geometry could be something else than a torusKnot...
        }
		
        var torusKnot = new TorusKnot(parsedTorusKnot.id, scene, parsedTorusKnot.r, parsedTorusKnot.t, parsedTorusKnot.rSs, parsedTorusKnot.tSs, parsedTorusKnot.p, parsedTorusKnot.q, parsedTorusKnot.cBR, null);
        Tags.AddTagsTo(torusKnot, parsedTorusKnot.ts);
		
        scene.pushGeometry(torusKnot, true);
		
        return torusKnot;
    }

    private static function parseVertexData(parsedVertexData:Dynamic, scene:Scene, rootUrl:String):Geometry {
        if (parseGeometry(parsedVertexData, scene) == null) {
            return null; // null since geometry could be a primitive
        }
		
        var geometry = new Geometry(parsedVertexData.id, scene);
		
        Tags.AddTagsTo(geometry, parsedVertexData.ts);
		
        if (parsedVertexData.dLF != null && parsedVertexData.dLF == true) {
            geometry.delayLoadState = Engine.DELAYLOADSTATE_NOTLOADED;
            geometry.delayLoadingFile = rootUrl + parsedVertexData.dLF;
            geometry._boundingInfo = new BoundingInfo(Vector3.FromArray(parsedVertexData.bBMn), Vector3.FromArray(parsedVertexData.bBMx));
			
            geometry._delayInfo = [];
            if (parsedVertexData.hUVs) {
                geometry._delayInfo.push(VertexBuffer.UVKind);
            }
			
            if (parsedVertexData.hUVs2) {
                geometry._delayInfo.push(VertexBuffer.UV2Kind);
            }
			
            if (parsedVertexData.hCs) {
                geometry._delayInfo.push(VertexBuffer.ColorKind);
            }
			
            if (parsedVertexData.hMIs) {
                geometry._delayInfo.push(VertexBuffer.MatricesIndicesKind);
            }
			
            if (parsedVertexData.hMWs) {
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
        var mesh = new Mesh(parsedMesh.n, scene);
        mesh.id = parsedMesh.id;
		
        Tags.AddTagsTo(mesh, parsedMesh.ts);
        mesh.position = Vector3.FromArray(parsedMesh.p);
		
        if (parsedMesh.rQ != null) {
            mesh.rotationQuaternion = Quaternion.FromArray(parsedMesh.rQ);
        } else if (parsedMesh.r != null) {
            mesh.rotation = Vector3.FromArray(parsedMesh.r);
        }
		
        mesh.scaling = Vector3.FromArray(parsedMesh.s);
		
        if (parsedMesh.lM != null) {
            mesh.setPivotMatrix(Matrix.FromArray(parsedMesh.lM));
        } else if (parsedMesh.pM != null) {
            mesh.setPivotMatrix(Matrix.FromArray(parsedMesh.pM));
        }
		
        mesh.setEnabled(parsedMesh.iE);
        mesh.isVisible = parsedMesh.iV;
        mesh.infiniteDistance = parsedMesh.iD;
		
        mesh.showBoundingBox = parsedMesh.sBB;
        mesh.showSubMeshesBoundingBox = parsedMesh.sSMBB;
		
		if (parsedMesh.aF != null && parsedMesh.aF) {
			mesh.applyFog = parsedMesh.aF;
        }
		
        if (parsedMesh.pck != null) {
            mesh.isPickable = parsedMesh.pck;
        }
		
		if (parsedMesh.aI != null) {
			mesh.alphaIndex = parsedMesh.aI;
		}
		
        mesh.receiveShadows = parsedMesh.rSs;
        mesh.billboardMode = parsedMesh.bM;
		
        if (parsedMesh.v != null) {
            mesh.visibility = parsedMesh.v;
        }
		
        mesh.checkCollisions = parsedMesh.cCs;
        mesh._shouldGenerateFlatShading = parsedMesh.uFS;
		
        // Parent
        if (parsedMesh.pId != null) {
            mesh._waitingParentId = parsedMesh.pId;
        }
		
		// Actions
        if (parsedMesh.acs != null) {
            mesh._waitingActions = parsedMesh.acs;
        }
		
        // Geometry
        mesh.hasVertexAlpha = parsedMesh.hVA;
		
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
        if (parsedMesh.mId != null) {
            mesh.setMaterialByID(parsedMesh.mId);
        } else {
            mesh.material = null;
        }
		
        // Skeleton
        if (parsedMesh.sId > -1) {
            mesh.skeleton = scene.getLastSkeletonByID(parsedMesh.sId);
        }
		
        // Physics
        if (parsedMesh.pI != null) {
            if (!scene.isPhysicsEnabled()) {
                scene.enablePhysics();
            }
			
			var physicsOptions:PhysicsBodyCreationOptions = new PhysicsBodyCreationOptions();
			physicsOptions.mass = parsedMesh.phM;
			physicsOptions.friction = parsedMesh.pF;
			physicsOptions.restitution = parsedMesh.pR;
				
            mesh.setPhysicsState(parsedMesh.pI, physicsOptions);
        }
		
        // Animations
        if (parsedMesh.as != null) {
            for (animationIndex in 0...parsedMesh.as.length) {
                var parsedAnimation = parsedMesh.as[animationIndex];				
                mesh.animations.push(parseAnimation(parsedAnimation));
            }
        }
		
        if (parsedMesh.aA != null) {
            scene.beginAnimation(mesh, parsedMesh.aAF, parsedMesh.aAT, parsedMesh.aAL, 1.0);
        }
		
        // Layer Mask
        if (parsedMesh.lyM != null) {
            mesh.layerMask = Std.int(Math.abs(parsedMesh.lyM));
        } else {
            mesh.layerMask = 0xFFFFFFFF;
        }
		
        // Instances
        if (parsedMesh.ins != null) {
            for (index in 0...parsedMesh.ins.length) {
                var parsedInstance = parsedMesh.ins[index];
                var instance = mesh.createInstance(parsedInstance.n);
				
                Tags.AddTagsTo(instance, parsedInstance.ts);
				
                instance.position = Vector3.FromArray(parsedInstance.p);
				
                if (parsedInstance.rQ != null) {
                    instance.rotationQuaternion = Quaternion.FromArray(parsedInstance.rQ);
                } else if (parsedInstance.r != null) {
                    instance.rotation = Vector3.FromArray(parsedInstance.r);
                }
				
                instance.scaling = Vector3.FromArray(parsedInstance.s);
				
                instance.checkCollisions = mesh.checkCollisions;
				
                if (parsedMesh.as != null) {
                    for (animationIndex in 0...parsedMesh.as.length) {
                        var parsedAnimation = parsedMesh.as[animationIndex];
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
        function traverse(parsedAction:Dynamic, trigger:Dynamic, condition:Condition, action:Action) {
			if (parsedAction.detached != null && parsedAction.detached == true) {
				return;
			}
            var parameters:Array<Dynamic> = [];
            var target:Dynamic = null;
            var propertyPath:String = "";
			
            // Parameters
            if (parsedAction.type == 2) {
                parameters.push(actionManager);
			}
            else {
                parameters.push(trigger);
			}
			
            for (i in 0...parsedAction.properties.length) {
                var value:String = parsedAction.properties[i].value;
                var name:String = parsedAction.properties[i].name;
				var val:Dynamic = null;
				
                if (name == "target") {
                    val = target = scene.getNodeByName(value);
				}
                else if (name == "parent") {
                    val = scene.getNodeByName(value);
				}
                else if (name == "sound") {
					// TODO
					continue;
                    //val = scene.getSoundByName(value);
				}
                else if (name != "propertyPath") {
                    if (parsedAction.type == 2 && name == "operator") {
                        val = Reflect.field(ValueCondition, cast value);
					}
                    else {
                        val = parseParameter(name, cast value, target, name == "value" ? propertyPath : null);
					}
                } 
				else {
                    propertyPath = cast value;
                }
				
                parameters.push(val);
            }
            parameters.push(condition);
			
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
        var geometryId = parsedGeometry.gId;
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
        } else if (parsedGeometry.ps != null && parsedGeometry.ns != null && parsedGeometry.is != null) {
            mesh.setVerticesData(VertexBuffer.PositionKind, parsedGeometry.ps, false);
            mesh.setVerticesData(VertexBuffer.NormalKind, parsedGeometry.ns, false);
			
            if (parsedGeometry.uvs != null) {
                mesh.setVerticesData(VertexBuffer.UVKind, parsedGeometry.uvs, false);
            }
			
            if (parsedGeometry.uvs2 != null) {
                mesh.setVerticesData(VertexBuffer.UV2Kind, parsedGeometry.uvs2, false);
            }
			
            if (parsedGeometry.cs != null) {
                mesh.setVerticesData(VertexBuffer.ColorKind, checkColors4(parsedGeometry.cs, Std.int(parsedGeometry.ps.length / 3)), false);
            }
			
            if (parsedGeometry.mIs != null) {
                if (!parsedGeometry.mIs._isExpanded) {
                    var floatIndices:Array<Float> = [];
					
                    for (i in 0...parsedGeometry.mIs.length) {
                        var matricesIndex = parsedGeometry.mIs[i];
						
                        floatIndices.push(matricesIndex & 0x000000FF);
                        floatIndices.push((matricesIndex & 0x0000FF00) >> 8);
                        floatIndices.push((matricesIndex & 0x00FF0000) >> 16);
                        floatIndices.push(matricesIndex >> 24);
                    }
					
                    mesh.setVerticesData(VertexBuffer.MatricesIndicesKind, floatIndices, false);
                } else {
                    parsedGeometry.mIs._isExpanded = null;
                    mesh.setVerticesData(VertexBuffer.MatricesIndicesKind, parsedGeometry.mIs, false);
                }
            }
			
            if (parsedGeometry.mWs != null) {
                mesh.setVerticesData(VertexBuffer.MatricesWeightsKind, parsedGeometry.mWs, false);
            }
			
            mesh.setIndices(parsedGeometry.is);
			
            // SubMeshes
            if (parsedGeometry.sMs != null) {
                mesh.subMeshes = [];
                for (subIndex in 0...parsedGeometry.sMs.length) {
                    var parsedSubMesh = parsedGeometry.sMs[subIndex];
					
                    var subMesh = new SubMesh(parsedSubMesh.mI, parsedSubMesh.vS, parsedSubMesh.vC, parsedSubMesh.iS, parsedSubMesh.iC, mesh);
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