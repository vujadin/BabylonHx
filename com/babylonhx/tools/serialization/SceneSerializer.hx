package com.babylonhx.tools;

import com.babylonhx.animations.Animation;
import com.babylonhx.animations.IAnimatable;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.cameras.*;
import com.babylonhx.lensflare.LensFlareSystem;
import com.babylonhx.lights.*;
import com.babylonhx.materials.FresnelParameters;
import com.babylonhx.materials.MultiMaterial;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.MirrorTexture;
import com.babylonhx.materials.textures.RenderTargetTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Geometry;
import com.babylonhx.mesh.InstancedMesh;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.primitives._Primitive;
import com.babylonhx.mesh.primitives.Box;
import com.babylonhx.mesh.primitives.Cylinder;
import com.babylonhx.mesh.primitives.Ground;
import com.babylonhx.mesh.primitives.Plane;
import com.babylonhx.mesh.primitives.Sphere;
import com.babylonhx.mesh.primitives.Torus;
import com.babylonhx.mesh.primitives.TorusKnot;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.physics.PhysicsEngine;
import com.babylonhx.Scene;
import com.babylonhx.tools.Tags;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.SceneSerializer') class SceneSerializer {
	
	static var serializedGeometries:Map<String, Geometry> = new Map<String, Geometry>();
	
	public static function ClearCache() {
		serializedGeometries = [];
	}
		
	public static function Serialize(scene:Scene):Dynamic {
		var serializationObject:Dynamic = { };
		
		// Scene
		serializationObject.useDelayedTextureLoading = scene.useDelayedTextureLoading;
		serializationObject.autoClear = scene.autoClear;
		serializationObject.clearColor = scene.clearColor.asArray();
		serializationObject.ambientColor = scene.ambientColor.asArray();
		serializationObject.gravity = scene.gravity.asArray();
		serializationObject.collisionsEnabled = scene.collisionsEnabled;
		serializationObject.workerCollisions = scene.workerCollisions;
		
		// Fog
		if (scene.fogMode != 0) {
			serializationObject.fogMode = scene.fogMode;
			serializationObject.fogColor = scene.fogColor.asArray();
			serializationObject.fogStart = scene.fogStart;
			serializationObject.fogEnd = scene.fogEnd;
			serializationObject.fogDensity = scene.fogDensity;
		}
		
		//Physics
		if (scene.isPhysicsEnabled()) {
			serializationObject.physicsEnabled = true;
			//serializationObject.physicsGravity = scene.getPhysicsEngine().gravity.asArray();
			//serializationObject.physicsEngine = scene.getPhysicsEngine().getPhysicsPluginName();
		}
		
		// Lights
		serializationObject.lights = [];
		for (index in 0...scene.lights.length) {
			var light = scene.lights[index];
			
			serializationObject.lights.push(serializeLight(light));
		}
		
		// Cameras
		serializationObject.cameras = [];
		for (index in 0...scene.cameras.length) {
			var camera = scene.cameras[index];
			serializationObject.cameras.push(serializeCamera(camera));
		}
		
		if (scene.activeCamera != null) {
			serializationObject.activeCameraID = scene.activeCamera.id;
		}
		
		// Animations
        Animation.AppendSerializedAnimations(scene, serializationObject);
		
		// Materials
		serializationObject.materials = [];
		serializationObject.multiMaterials = [];
		var material:Material;
		for (index in 0...scene.materials.length) {
			material = scene.materials[index];
			serializationObject.materials.push(material.serialize());
		}
		
		// MultiMaterials
		serializationObject.multiMaterials = [];
		for (index in 0...scene.multiMaterials.length) {
			var multiMaterial = scene.multiMaterials[index];
			serializationObject.multiMaterials.push(multiMaterial.serialize());
		}
		
		// Skeletons
		serializationObject.skeletons = [];
		for (index in 0...scene.skeletons.length) {
			serializationObject.skeletons.push(serializeSkeleton(scene.skeletons[index]));
		}
		
		// Geometries
		serializationObject.geometries = { };
		
		serializationObject.geometries.boxes = [];
		serializationObject.geometries.spheres = [];
		serializationObject.geometries.cylinders = [];
		serializationObject.geometries.toruses = [];
		serializationObject.geometries.grounds = [];
		serializationObject.geometries.planes = [];
		serializationObject.geometries.torusKnots = [];
		serializationObject.geometries.vertexData = [];
		
		serializedGeometries = new Map<String, Geometry>();
		var geometries = scene.getGeometries();
		for (index in 0...geometries.length) {
			var geometry = geometries[index];
			
			if (geometry.isReady()) {
				serializeGeometry(geometry, serializationObject.geometries);
			}
		}
		
		// Meshes
		serializationObject.meshes = [];
		for (index in 0...scene.meshes.length) {
			var abstractMesh = scene.meshes[index];
			
			if (Std.is(abstractMesh, Mesh)) {
				var mesh:Mesh = cast abstractMesh;
				if (mesh.delayLoadState == Engine.DELAYLOADSTATE_LOADED || mesh.delayLoadState == Engine.DELAYLOADSTATE_NONE) {
					serializationObject.meshes.push(serializeMesh(mesh, serializationObject));
				}
			}
		}
		
		// Particles Systems
		serializationObject.particleSystems = [];
		for (index in 0...scene.particleSystems.length) {
			serializationObject.particleSystems.push(serializeParticleSystem(scene.particleSystems[index]));
		}
		
		// Lens flares
		serializationObject.lensFlareSystems = [];
		for (index in 0...scene.lensFlareSystems.length) {
			serializationObject.lensFlareSystems.push(serializeLensFlareSystem(scene.lensFlareSystems[index]));
		}
		
		// Shadows
		serializationObject.shadowGenerators = [];
		for (index in 0...scene.lights.length) {
			var light = scene.lights[index];
			
			if (light.getShadowGenerator() != null) {
				serializationObject.shadowGenerators.push(serializeShadowGenerator(light));
			}
		}
		
		// Action Manager
		if (scene.actionManager != null) {
			serializationObject.actions = scene.actionManager.serialize("scene");
		}
		
		return serializationObject;
	}
	
	public static function SerializeMesh(toSerialize:Dynamic, withParents:Bool = false, withChildren:Bool = false):Dynamic {
		var serializationObject:Dynamic = { };
		
		var _toSerialize:Array<Mesh> = cast (Std.is(toSerialize, Array) ? toSerialize : [toSerialize]);
		
		if (withParents || withChildren) {
			//deliberate for loop! not for each, appended should be processed as well.
			if (withChildren) {
				for (node in toSerialize[i].getDescendants()) {
					if (Std.is(node, Mesh) && (toSerialize.indexOf(node) < 0)) {
						toSerialize.push(node);
					}
				}
			}
			//make sure the array doesn't contain the object already
			if (withParents && toSerialize[i].parent != null && (toSerialize.indexOf(toSerialize[i].parent) < 0)) {
				toSerialize.push(toSerialize[i].parent);
			}
		}
		
		for(mesh in _toSerialize) {
			finalizeSingleMesh(mesh, serializationObject);
		}
		
		return serializationObject;
	}
	
	static function serializeGeometry(geometry:Geometry, serializationGeometries:Dynamic) {
        if (serializedGeometries[geometry.id] != null) {
            return;
        }
		
        if (Std.is(geometry, Box)) {
            serializationGeometries.boxes.push(serializeBox(cast geometry));
        }
        else if (Std.is(geometry, Sphere)) {
            serializationGeometries.spheres.push(serializeSphere(cast geometry));
        }
        else if (Std.is(geometry, Cylinder)) {
            serializationGeometries.cylinders.push(serializeCylinder(cast geometry));
        }
        else if (Std.is(geometry, Torus)) {
            serializationGeometries.toruses.push(serializeTorus(cast geometry));
        }
        else if (Std.is(geometry, Ground)) {
			serializationGeometries.grounds.push(serializeGround(cast geometry));
        }
        else if (Std.is(geometry, Plane)) {
			serializationGeometries.planes.push(serializePlane(cast geometry));
        }
        else if (Std.is(geometry, TorusKnot)) {
            serializationGeometries.torusKnots.push(serializeTorusKnot(cast geometry));
        }
        else if (Std.is(geometry, _Primitive)) {
			trace("Unknown primitive type");
        }
        else {
            serializationGeometries.vertexData.push(serializeVertexData(geometry));
        }
		
        serializedGeometries[geometry.id] = geometry;
    }
	
	static function serializeMesh(mesh:Mesh, serializationScene:Scene):Dynamic {
        var serializationObject:Dynamic = { };
		
        serializationObject.name = mesh.name;
        serializationObject.id = mesh.id;
		
        if (Tags.HasTags(mesh)) {
            serializationObject.tags = Tags.GetTags(mesh);
        }
		
        serializationObject.position = mesh.position.asArray();
        if (mesh.rotationQuaternion != null) {
            serializationObject.rotationQuaternion = mesh.rotationQuaternion.asArray();
        }
        else if (mesh.rotation != null) {
            serializationObject.rotation = mesh.rotation.asArray();
        }
		
        serializationObject.scaling = mesh.scaling.asArray();
        serializationObject.localMatrix = mesh.getPivotMatrix().asArray();
		
        serializationObject.isEnabled = mesh.isEnabled();
        serializationObject.isVisible = mesh.isVisible;
        serializationObject.infiniteDistance = mesh.infiniteDistance;
        serializationObject.pickable = mesh.isPickable;
		
        serializationObject.receiveShadows = mesh.receiveShadows;
		
        serializationObject.billboardMode = mesh.billboardMode;
        serializationObject.visibility = mesh.visibility;
		
        serializationObject.checkCollisions = mesh.checkCollisions;
		
        // Parent
        if (mesh.parent != null) {
            serializationObject.parentId = mesh.parent.id;
        }
        // Geometry
        var geometry = mesh._geometry;
        if (geometry != null) {
            var geometryId = geometry.id;
            serializationObject.geometryId = geometryId;
            if (mesh.getScene().getGeometryByID(geometryId) == null) {
                // geometry was in the memory but not added to the scene, nevertheless it's better to serialize too be able to reload the mesh with its geometry
                serializeGeometry(geometry, serializationScene.getGeometries());
            }
			
            // SubMeshes
            serializationObject.subMeshes = new Array<Dynamic>();
            for (subIndex in 0...mesh.subMeshes.length) {
                var subMesh:SubMesh = mesh.subMeshes[subIndex];
                serializationObject.subMeshes.push({
                    materialIndex: subMesh.materialIndex,
                    verticesStart: subMesh.verticesStart,
                    verticesCount: subMesh.verticesCount,
                    indexStart: subMesh.indexStart,
                    indexCount: subMesh.indexCount
                });
            }
        }
		
        // Material
        if (mesh.material != null) {
            serializationObject.materialId = mesh.material.id;
        }
        else {
            mesh.material = null;
        }
		
        // Skeleton
        if (mesh.skeleton != null) {
            serializationObject.skeletonId = mesh.skeleton.id;
        }
		
        // Physics
		// TODO implement correct serialization for physics impostors.
        if (mesh.getPhysicsImpostor() != PhysicsEngine.NoImpostor) {
            //serializationObject.physicsMass = mesh.getPhysicsMass();
            //serializationObject.physicsFriction = mesh.getPhysicsFriction();
            //serializationObject.physicsRestitution = mesh.getPhysicsRestitution();
            //serializationObject.physicsImpostor = mesh.getPhysicsImpostor().type;
        }
		
        // Instances
        serializationObject.instances = [];
        for (index in 0...mesh.instances.length) {
            var instance = mesh.instances[index];
            var serializationInstance:Dynamic = {
                name: instance.name,
                position: instance.position.asArray(),
                scaling: instance.scaling.asArray()
            };
            if (instance.rotationQuaternion != null) {
                serializationInstance.rotationQuaternion = instance.rotationQuaternion.asArray();
            } 
			else if (instance.rotation != null) {
                serializationInstance.rotation = instance.rotation.asArray();
            }
            serializationObject.instances.push(serializationInstance);
			
            // Animations
            Animation.AppendSerializedAnimations(instance, serializationInstance);
            serializationInstance.ranges = instance.serializeAnimationRanges();
        }
		
        // Animations
        Animation.AppendSerializedAnimations(mesh, serializationObject);
        serializationObject.ranges = mesh.serializeAnimationRanges();
		
        // Layer mask
        serializationObject.layerMask = mesh.layerMask;
		
        // Action Manager
        if (mesh.actionManager != null) {
            serializationObject.actions = mesh.actionManager.serialize(mesh.name);
        }
		
        return serializationObject;
    }
	
	private static function finalizeSingleMesh(mesh:Mesh, serializationObject:Dynamic) {
        //only works if the mesh is already loaded
        if (mesh.delayLoadState == Engine.DELAYLOADSTATE_LOADED || mesh.delayLoadState == Engine.DELAYLOADSTATE_NONE) {
            //serialize material
            if (mesh.material != null) {
                if (Std.is(mesh.material, StandardMaterial)) {
                    serializationObject.materials = serializationObject.materials != null ? serializationObject.materials : [];
					
					for (mat in serializationObject.materials) {
						if (mat.id != mesh.material.id) {
							serializationObject.materials.push(mesh.material.serialize());
						}
					}
                } 
				else if (Std.is(mesh.material, MultiMaterial)) {
                    serializationObject.multiMaterials = serializationObject.multiMaterials != null ? serializationObject.multiMaterials : [];
					
					for (mat in serializationObject.multiMaterials) {
						if (mat.id != mesh.material.id) {
							serializationObject.multiMaterials.push(mesh.material.serialize());
						}
					}
                }
            }
			
            //serialize geometry
            var geometry = mesh._geometry;
            if (geometry != null) {
                if (serializationObject.geometries == null) {
                    serializationObject.geometries = { };
					
                    serializationObject.geometries.boxes = [];
                    serializationObject.geometries.spheres = [];
                    serializationObject.geometries.cylinders = [];
                    serializationObject.geometries.toruses = [];
                    serializationObject.geometries.grounds = [];
                    serializationObject.geometries.planes = [];
                    serializationObject.geometries.torusKnots = [];
                    serializationObject.geometries.vertexData = [];
                }
				
                serializeGeometry(geometry, serializationObject.geometries);
            }
			
            // Skeletons
            if (mesh.skeleton != null) {
                serializationObject.skeletons = serializationObject.skeletons != null ? serializationObject.skeletons : [];
                serializationObject.skeletons.push(serializeSkeleton(mesh.skeleton));
            }
			
            //serialize the actual mesh
            serializationObject.meshes = serializationObject.meshes != null ? serializationObject.meshes : [];
            serializationObject.meshes.push(serializeMesh(mesh, serializationObject));
        }
    }
	
}
