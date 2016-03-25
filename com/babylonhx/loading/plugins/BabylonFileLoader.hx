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
import com.babylonhx.physics.IPhysicsEnginePlugin;
import com.babylonhx.physics.plugins.OimoPlugin;
//import com.babylonhx.physics.plugins.CannonPlugin;
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
			var parsedData:Dynamic = Json.parse(data);			
				
            var loadedSkeletonsIds:Array<Int> = [];
            var loadedMaterialsIds:Array<String> = [];
            var hierarchyIds:Array<Int> = [];
			
			var pdm:Array<Dynamic> = cast parsedData.meshes;
            for (index in 0...pdm.length) {
                var parsedMesh = pdm[index];
				
                if (meshesNames == null || meshesNames == "" || isDescendantOf(parsedMesh, meshesNames, hierarchyIds)) {
					if (Std.is(meshesNames, Array)) {
                        // Remove found mesh name from list.
                        meshesNames.splice(meshesNames.indexOf(parsedMesh.name), 1);
                    }
					
					//Geometry?
                    if (parsedMesh.geometryId != null) {
                        //does the file contain geometries?
                        if (parsedData.geometries != null) {
                            //find the correct geometry and add it to the scene
                            var found:Bool = false;
                            for (geometryType in ["boxes", "spheres", "cylinders", "toruses", "grounds", "planes", "torusKnots", "vertexData"]) {
                                if (found || Reflect.getProperty(parsedData.geometries, geometryType) == null || !(Std.is(Reflect.getProperty(parsedData.geometries, geometryType), Array))) {
                                    continue;
                                } 
								else {
									var geomData:Array<Dynamic> = cast Reflect.getProperty(parsedData.geometries, geometryType);
									for (parsedGeometryData in geomData) {
                                        if (parsedGeometryData.id == parsedMesh.geometryId) {
                                            switch (geometryType) {
                                                case "boxes":
                                                    Box.Parse(parsedGeometryData, scene);
                                                    
                                                case "spheres":
                                                    Sphere.Parse(parsedGeometryData, scene);
                                                    
                                                case "cylinders":
                                                    Cylinder.Parse(parsedGeometryData, scene);
                                                    
                                                case "toruses":
                                                    Torus.Parse(parsedGeometryData, scene);
                                                    
                                                case "grounds":
                                                    Ground.Parse(parsedGeometryData, scene);
                                                    
                                                case "planes":
                                                    com.babylonhx.mesh.primitives.Plane.Parse(parsedGeometryData, scene);
                                                    
                                                case "torusKnots":
                                                    TorusKnot.Parse(parsedGeometryData, scene);
                                                    
                                                case "vertexData":
                                                    Geometry.Parse(parsedGeometryData, scene, rootUrl);
                                                    
                                            }
                                            found = true;
                                        }
                                    }
                                }
                            }
                            if (!found) {
								trace("Geometry not found for mesh " + parsedMesh.id);
                            }
                        }
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
                                        var subMatId = pdmmm[matIndex];
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
									skeletons.push(Skeleton.Parse(parsedSkeleton, scene));
                                    loadedSkeletonsIds.push(parsedSkeleton.id);
                                }
                            }
                        }
                    }
					
                    var mesh = Mesh.Parse(parsedMesh, scene, rootUrl);
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
			
			// freeze and compute world matrix application
			for (index in 0...scene.meshes.length) {
				var currentMesh = scene.meshes[index];
				if (currentMesh._waitingFreezeWorldMatrix) {
					currentMesh.freezeWorldMatrix();
					currentMesh._waitingFreezeWorldMatrix = false;
				} 
				else {
					currentMesh.computeWorldMatrix(true);
				}
			}
			
            // Particles
            if (parsedData.particleSystems != null) {
				var pdp:Array<Dynamic> = cast parsedData.particleSystems;
                for (index in 0...pdp.length) {
					var parsedParticleSystem = pdp[index];				
                    if (hierarchyIds.indexOf(parsedParticleSystem.emitterId) != -1) {
                        particleSystems.push(ParticleSystem.Parse(parsedParticleSystem, scene, rootUrl));
                    }
                }
            }
			
            return true;
        },
		load: function(scene:Scene, data:Dynamic, rootUrl:String):Bool {
			// Entire method running in try block, so ALWAYS logs as far as it got, only actually writes details
            // when SceneLoader.debugLogging = true (default), or exception encountered.
            // Everything stored in var log instead of writing separate lines to support only writing in exception,
            // and avoid problems with multiple concurrent .babylon loads.
            var log:String = "importScene has failed JSON parse";
            try {
				var parsedData = Json.parse(data);
                log = "";
                var fullDetails:Bool = true;
                
                // Scene
                scene.useDelayedTextureLoading = parsedData.useDelayedTextureLoading != null && !SceneLoader.ForceFullSceneLoadingForIncremental;
                scene.autoClear = parsedData.autoClear;
                scene.clearColor = Color3.FromArray(parsedData.clearColor);
                scene.ambientColor = Color3.FromArray(parsedData.ambientColor);
                if (parsedData.gravity != null) {
                    scene.gravity = Vector3.FromArray(parsedData.gravity);
                }
                
                // Fog
                if (parsedData.fogMode != 0) {
                    scene.fogMode = parsedData.fogMode;
                    scene.fogColor = Color3.FromArray(parsedData.fogColor);
                    scene.fogStart = parsedData.fogStart;
                    scene.fogEnd = parsedData.fogEnd;
                    scene.fogDensity = parsedData.fogDensity;
                    log += "\tFog mode for scene:  ";
                    switch (scene.fogMode) {
                        // getters not compiling, so using hardcoded
                        case 1: 
							log += "exp\n"; 
							
                        case 2: 
							log += "exp2\n"; 
							
                        case 3: 
							log += "linear\n"; 
                    }
                }
                
                //Physics                
				if (parsedData.physicsEnabled == true) {
					var physicsPlugin:IPhysicsEnginePlugin = null;
					if (parsedData.physicsEngine != null) {
						//if (parsedData.physicsEngine == "cannon") {
						//	physicsPlugin = new CannonPlugin();
						//} 
						//else if (parsedData.physicsEngine == "oimo") {
							physicsPlugin = new OimoPlugin();
						//}
						log = "\tPhysics engine " + parsedData.physicsEngine + " enabled\n";
					}
					
					//else - default engine, which is currently oimo
					var physicsGravity = parsedData.physicsGravity != null ? Vector3.FromArray(parsedData.physicsGravity) : null;
					scene.enablePhysics(physicsGravity, physicsPlugin);
				}
                
                //collisions, if defined. otherwise, default is true
                if (parsedData.collisionsEnabled == true) {
                    scene.collisionsEnabled = parsedData.collisionsEnabled;
                }
                //scene.workerCollisions = !!parsedData.workerCollisions;
				
                var pdL:Array<Dynamic> = cast parsedData.lights;
                // Lights
                for (index in 0...pdL .length) {
					var parsedLight = pdL[index];
                    var light = Light.Parse(parsedLight, scene);
                    log += (index == 0 ? "\n\tLights:" : "");
                    //log += "\n\t\t" + light.toString(fullDetails);
                }
				
                // Animations
                if (parsedData.animations != null) {
					var pdAnims:Array<Dynamic> = cast parsedData.animations;
                    for (index in 0...pdAnims.length) {
                        var parsedAnimation = pdAnims[index];
                        var animation = Animation.Parse(parsedAnimation);
                        scene.animations.push(animation);
                        log += (index == 0 ? "\n\tAnimations:" : "");
                        //log += "\n\t\t" + animation.toString(fullDetails);
                    }
                }
				
                // Materials
                if (parsedData.materials != null) {
					var pdMats:Array<Dynamic> = cast parsedData.materials;
                    for (index in 0...pdMats.length) {
                        var parsedMaterial = pdMats[index];
                        var mat = Material.Parse(parsedMaterial, scene, rootUrl);
                        log += (index == 0 ? "\n\tMaterials:" : "");
                        //log += "\n\t\t" + mat.toString(fullDetails);
                    }
                }
				
                if (parsedData.multiMaterials != null) {
					var pdMultiMats:Array<Dynamic> = cast parsedData.multiMaterials;
                    for (index in 0...pdMultiMats.length) {
                        var parsedMultiMaterial = pdMultiMats[index];
                        var mmat = Material.ParseMultiMaterial(parsedMultiMaterial, scene);
                        log += (index == 0 ? "\n\tMultiMaterials:" : "");
                        //log += "\n\t\t" + mmat.toString(fullDetails);
                    }
                }
				
                // Skeletons
                if (parsedData.skeletons != null) {
					var pdSkels:Array<Dynamic> = cast parsedData.skeletons;
                    for (index in 0...pdSkels.length) {
						var parsedSkeleton = pdSkels[index];
                        var skeleton = Skeleton.Parse(parsedSkeleton, scene);
                        log += (index == 0 ? "\n\tSkeletons:" : "");
                        //log += "\n\t\t" + skeleton.toString(fullDetails);
                    }
                }
				
                // Geometries
                var geometries = parsedData.geometries;
                if (geometries != null) {
                    // Boxes
					var boxes:Array<Dynamic> = cast geometries.boxes;
                    if (boxes != null) {
                        for (index in 0...boxes.length) {
                            var parsedBox = boxes[index];
                            Box.Parse(parsedBox, scene);
                        }
                    }
					
                    // Spheres
                    var spheres:Array<Dynamic> = cast geometries.spheres;
                    if (spheres != null) {
                        for (index in 0...spheres.length) {
                            var parsedSphere = spheres[index];
                            Sphere.Parse(parsedSphere, scene);
                        }
                    }
					
                    // Cylinders
                    var cylinders:Array<Dynamic> = cast geometries.cylinders;
                    if (cylinders != null) {
                        for (index in 0...cylinders.length) {
                            var parsedCylinder = cylinders[index];
                            Cylinder.Parse(parsedCylinder, scene);
                        }
                    }
					
                    // Toruses
                    var toruses:Array<Dynamic> = cast geometries.toruses;
                    if (toruses != null) {
                        for (index in 0...toruses.length) {
                            var parsedTorus = toruses[index];
                            Torus.Parse(parsedTorus, scene);
                        }
                    }
					
                    // Grounds
                    var grounds:Array<Dynamic> = cast geometries.grounds;
                    if (grounds != null) {
                        for (index in 0...grounds.length) {
                            var parsedGround = grounds[index];
                            Ground.Parse(parsedGround, scene);
                        }
                    }
					
                    // Planes
                    var planes:Array<Dynamic> = cast geometries.planes;
                    if (planes != null) {
                        for (index in 0...planes.length) {
                            var parsedPlane = planes[index];
                            com.babylonhx.mesh.primitives.Plane.Parse(parsedPlane, scene);
                        }
                    }
					
                    // TorusKnots
                    var torusKnots:Array<Dynamic> = cast geometries.torusKnots;
                    if (torusKnots != null) {
                        for (index in 0...torusKnots.length) {
                            var parsedTorusKnot = torusKnots[index];
                            TorusKnot.Parse(parsedTorusKnot, scene);
                        }
                    }
					
                    // VertexData
                    var vertexData:Array<Dynamic> = cast geometries.vertexData;
                    if (vertexData != null) {
                        for (index in 0...vertexData.length) {
                            var parsedVertexData = vertexData[index];
                            Geometry.Parse(parsedVertexData, scene, rootUrl);
                        }
                    }
                }
				
                // Meshes
				var pdMeshes:Array<Dynamic> = cast parsedData.meshes;
                for (index in 0...pdMeshes.length) {
                    var parsedMesh = pdMeshes[index];
                    var mesh = Mesh.Parse(parsedMesh, scene, rootUrl);
                    log += (index == 0 ? "\n\tMeshes:" : "");
                    //log += "\n\t\t" + mesh.toString(fullDetails);
                }
				
                // Cameras
				var pdCameras:Array<Dynamic> = cast parsedData.cameras;
                for (index in 0...pdCameras.length) {
                    var parsedCamera = pdCameras[index];
                    var camera = Camera.Parse(parsedCamera, scene);
                    log += (index == 0 ? "\n\tCameras:" : "");
                    //log += "\n\t\t" + camera.toString(fullDetails);
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
				
                // Sounds
                /*var loadedSounds: Sound[] = [];
                var loadedSound: Sound;
                if (AudioEngine && parsedData.sounds) {
                    for (index = 0, cache = parsedData.sounds.length; index < cache; index++) {
                        var parsedSound = parsedData.sounds[index];
                        if (Engine.audioEngine.canUseWebAudio) {
                            if (!parsedSound.url) parsedSound.url = parsedSound.name;
                            if (!loadedSounds[parsedSound.url]) {
                                loadedSound = Sound.Parse(parsedSound, scene, rootUrl);
                                loadedSounds[parsedSound.url] = loadedSound;
                            }
                            else {
                                Sound.Parse(parsedSound, scene, rootUrl, loadedSounds[parsedSound.url]);
                            }
                        } else {
                            var emptySound = new Sound(parsedSound.name, null, scene);
                        }
                    }
                    log += (index === 0 ? "\n\tSounds:" : "");
                    //log += "\n\t\t" + mat.toString(fullDetails);
                }
				
                loadedSounds = [];*/
				
                // Connect parents & children and parse actions
                for (index in 0...scene.meshes.length) {
                    var mesh = scene.meshes[index];
                    if (mesh._waitingParentId != null) {
                        mesh.parent = scene.getLastEntryByID(mesh._waitingParentId);
                        mesh._waitingParentId = null;
                    }
                    if (mesh._waitingActions != null) {
                        ActionManager.Parse(mesh._waitingActions, mesh, scene);
                        mesh._waitingActions = null;
                    }
                }
				
                // freeze world matrix application
                for (index in 0...scene.meshes.length) {
                    var currentMesh = scene.meshes[index];
                    if (currentMesh._waitingFreezeWorldMatrix) {
                        currentMesh.freezeWorldMatrix();
						currentMesh._waitingFreezeWorldMatrix = false;
                    } 
					else {
                        currentMesh.computeWorldMatrix(true);
                    }
                }
				
                // Particles Systems
                if (parsedData.particleSystems != null) {
					var pdPSys:Array<Dynamic> = cast parsedData.particleSystems;
                    for (index in 0...pdPSys.length) {
					var parsedParticleSystem = pdPSys[index];
                        ParticleSystem.Parse(parsedParticleSystem, scene, rootUrl);
                    }
                }
				
                // Lens flares
                if (parsedData.lensFlareSystems != null) {
					var pdLFS:Array<Dynamic> = cast parsedData.lensFlareSystems;
                    for (index in 0...pdLFS.length) {
						var parsedLensFlareSystem = pdLFS[index];
                        LensFlareSystem.Parse(parsedLensFlareSystem, scene, rootUrl);
                    }
                }
				
                // Shadows
                if (parsedData.shadowGenerators != null) {
				var pdSG:Array<Dynamic> = cast parsedData.shadowGenerators;
                    for (index in 0...pdSG.length) {
                        var parsedShadowGenerator = pdSG[index];
                        ShadowGenerator.Parse(parsedShadowGenerator, scene);
                    }
                }
				
                // Actions (scene)
                if (parsedData.actions != null) {
                    ActionManager.Parse(parsedData.actions, null, scene);
                }
				
                // Finish
                return true;
            } 
			catch (err:Dynamic) {
				//trace(logOperation("importScene", parsedData.producer) + log);
                //log = null;
                trace(err);
				
				return false;
            } 
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

    public static function parseMaterialById(id:String, parsedData:Dynamic, scene:Scene, rootUrl:String):Material {
        for (index in 0...parsedData.materials.length) {
            var parsedMaterial = parsedData.materials[index];
			
            if (parsedMaterial.id == id) {
                return StandardMaterial.Parse(parsedMaterial, scene, rootUrl);
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
            } 
			else {
                multiMaterial.subMaterials.push(null);
            }
        }
		
        return multiMaterial;
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
        } 
		else if (parsedGeometry.positions != null && parsedGeometry.normals != null && parsedGeometry.indices != null) {
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
                } 
				else {
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
