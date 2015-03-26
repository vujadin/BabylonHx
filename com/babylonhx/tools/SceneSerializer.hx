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
import samples.Fresnel;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.SceneSerializer') class SceneSerializer {
	
	static var serializedGeometries:Map<String, Geometry> = new Map<String, Geometry>();
	
		
	public static function serialize(scene:Scene):Dynamic {
		var serializationObject:Dynamic = { };
		
		// Scene
		serializationObject.useDelayedTextureLoading = scene.useDelayedTextureLoading;
		serializationObject.autoClear = scene.autoClear;
		serializationObject.clearColor = scene.clearColor.asArray();
		serializationObject.ambientColor = scene.ambientColor.asArray();
		serializationObject.gravity = scene.gravity.asArray();
		
		// Fog
		if (scene.fogMode != 0) {
			serializationObject.fogMode = scene.fogMode;
			serializationObject.fogColor = scene.fogColor.asArray();
			serializationObject.fogStart = scene.fogStart;
			serializationObject.fogEnd = scene.fogEnd;
			serializationObject.fogDensity = scene.fogDensity;
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
		
		// Materials
		serializationObject.materials = [];
		serializationObject.multiMaterials = [];
		for (index in 0...scene.materials.length) {
			var material = scene.materials[index];
			
			if (Std.is(material, StandardMaterial)) {
				serializationObject.materials.push(serializeMaterial(<StandardMaterial>material));
			} 
			else if (Std.is(material, MultiMaterial)) {
				serializationObject.multiMaterials.push(serializeMultiMaterial(<MultiMaterial>material));
			}
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

		serializedGeometries = [];
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
			light = scene.lights[index];
			
			if (light.getShadowGenerator()) {
				serializationObject.shadowGenerators.push(serializeShadowGenerator(light));
			}
		}
		
		serializedGeometries = new Map<String, Geometry>();
		
		return serializationObject;
	}
	
	static function serializeLight(light:Light):Dynamic {
        var serializationObject:Dynamic = { };
		
        serializationObject.name = light.name;
        serializationObject.id = light.id;
        serializationObject.tags = Tags.GetTags(light);

        if (Std.is(light, PointLight)) {
            serializationObject.type = 0;
            serializationObject.position = cast(light, PointLight).position.asArray();
        } 
		else if (Std.is(light, DirectionalLight)) {
            serializationObject.type = 1;
            var directionalLight:DirectionalLight = cast light;
            serializationObject.position = directionalLight.position.asArray();
            serializationObject.direction = directionalLight.direction.asArray();
        } 
		else if (Std.is(light, SpotLight)) {
            serializationObject.type = 2;
            var spotLight:SpotLight = cast light;
            serializationObject.position = spotLight.position.asArray();
            serializationObject.direction = spotLight.position.asArray();
            serializationObject.angle = spotLight.angle;
            serializationObject.exponent = spotLight.exponent;
        } 
		else if (Std.is(light, HemisphericLight)) {
            serializationObject.type = 3;
            var hemisphericLight:HemisphericLight = cast light;
            serializationObject.direction = hemisphericLight.direction.asArray();
            serializationObject.groundColor = hemisphericLight.groundColor.asArray();
        }
		
        if (light.intensity != null) {
            serializationObject.intensity = light.intensity;
        }
		
        serializationObject.range = light.range;
		
        serializationObject.diffuse = light.diffuse.asArray();
        serializationObject.specular = light.specular.asArray();
		
        return serializationObject;
    }
	
	static function serializeFresnelParameter(fresnelParameter:FresnelParameters):Dynamic {
        var serializationObject:Dynamic = { };
		
        serializationObject.isEnabled = fresnelParameter.isEnabled;
        serializationObject.leftColor = fresnelParameter.leftColor;
        serializationObject.rightColor = fresnelParameter.rightColor;
        serializationObject.bias = fresnelParameter.bias;
        serializationObject.power = fresnelParameter.power;
		
        return serializationObject;
    }
	
	static function serializeCamera(camera:Camera):Dynamic {
        var serializationObject:Dynamic = { };
        serializationObject.name = camera.name;
        serializationObject.tags = Tags.GetTags(camera);
        serializationObject.id = camera.id;
        serializationObject.position = camera.position.asArray();
		
        // Parent
        if (camera.parent != null) {
            serializationObject.parentId = camera.parent.id;
        }
		
        serializationObject.fov = camera.fov;
        serializationObject.minZ = camera.minZ;
        serializationObject.maxZ = camera.maxZ;
		
        serializationObject.inertia = camera.inertia;
		
        //setting the type
        if (Std.is(camera, FreeCamera)) {
            serializationObject.type = "FreeCamera";
        } 
		else if (Std.is(camera, ArcRotateCamera)) {
            serializationObject.type = "ArcRotateCamera";
        } 
		else if (Std.is(camera, AnaglyphArcRotateCamera)) {
            serializationObject.type = "AnaglyphArcRotateCamera";
        } 
		else if (Std.is(camera, AnaglyphFreeCamera)) {
            serializationObject.type = "AnaglyphFreeCamera";
		} 
		else if (Std.is(camera, FollowCamera)) {
            serializationObject.type = "FollowCamera";
		} /*else if (Std.is(camera, GamepadCamera)) {
            serializationObject.type = "GamepadCamera";
        } else if (Std.is(camera, DeviceOrientationCamera)) {
            serializationObject.type = "DeviceOrientationCamera";
        } else if (Std.is(camera, OculusCamera)) {
            serializationObject.type = "OculusCamera";
        } else if (Std.is(camera, OculusGamepadCamera)) {
            serializationObject.type = "OculusGamepadCamera";
        } else if (Std.is(camera, TouchCamera)) {
            serializationObject.type = "TouchCamera";
        } else if (Std.is(camera, VirtualJoysticksCamera)) {
            serializationObject.type = "VirtualJoysticksCamera";
        } else if (Std.is(camera, WebVRCamera)) {
            serializationObject.type = "WebVRCamera";
        } else if (Std.is(camera, VRDeviceOrientationCamera)) {
            serializationObject.type = "VRDeviceOrientationCamera";
        }*/ 
		
        //special properties of specific cameras
        if (Std.is(camera, ArcRotateCamera) || Std.is(camera, AnaglyphArcRotateCamera)) {
            var arcCamera:ArcRotateCamera = cast camera;
            serializationObject.alpha = arcCamera.alpha;
            serializationObject.beta = arcCamera.beta;
            serializationObject.radius = arcCamera.radius;
        } 
		else if (Std.is(camera, FollowCamera)) {
            var followCam:FollowCamera = cast camera;
            serializationObject.radius = followCam.radius;
            serializationObject.heightOffset = followCam.heightOffset;
            serializationObject.rotationOffset = followCam.rotationOffset;
        } 
		else if (Std.is(camera, AnaglyphFreeCamera) || Std.is(camera, AnaglyphArcRotateCamera)) {
            //eye space is a private member and can only be access like this. Without changing the implementation this is the best way to get it.
            if (Reflect.hasField(camera, "_eyeSpace")) {
                serializationObject.eye_space = Tools.ToDegrees(Reflect.field(camera, "_eyeSpace"));
            }
        }
		
        //general properties that not all cameras have. The [] is due to typescript's type safety
        if (Reflect.hasField(camera, "speed")) {
            serializationObject.speed = Reflect.field(camera, "speed");
        }
		
        // Target
        if (Reflect.hasField(camera, "rotation") && Std.is(Reflect.field(camera, "rotation"), Vector3)) {
            serializationObject.rotation = cast(Reflect.field(camera, "rotation"), Vector3).asArray();
        }
		
        // Locked target
        if (Reflect.hasField(camera, "lockedTarget") && Reflect.field(camera, "lockedTarget").id != null) {
            serializationObject.lockedTargetId = Reflect.field(camera, "lockedTarget").id;
        }
		
        if (Reflect.hasField(camera, "checkCollisions")) {
            serializationObject.checkCollisions = Reflect.field(camera, "checkCollisions");
        }
        
		if (Reflect.hasField(camera, "applyGravity")) {
            serializationObject.applyGravity = Reflect.field(camera, "applyGravity");
        }
		
        if (Reflect.hasField(camera, "ellipsoid")) {
            serializationObject.ellipsoid = Reflect.field(camera, "applyGravity").asArray();
        }
		
        // Animations
        appendAnimations(camera, serializationObject);
		
        // Layer mask
        serializationObject.layerMask = camera.layerMask;
		
        return serializationObject;
    }
	
	static function appendAnimations(source:IAnimatable, destination:Dynamic):Dynamic {
        if (source.animations != null) {
            destination.animations = [];
            for (animationIndex in 0...source.animations.length) {
                var animation = source.animations[animationIndex];
				
                destination.animations.push(serializeAnimation(animation));
            }
        }
		return destination;
    }
	
	static function serializeAnimation(animation:Animation):Dynamic {
        var serializationObject:Dynamic = { };
		
        serializationObject.name = animation.name;
        serializationObject.property = animation.targetProperty;
        serializationObject.framePerSecond = animation.framePerSecond;
        serializationObject.dataType = animation.dataType;
        serializationObject.loopBehavior = animation.loopMode;
		
        var dataType = animation.dataType;
        serializationObject.keys = new Array<Dynamic>();
        var keys = animation.getKeys();
        for (index in 0...keys.length) {
            var animationKey = keys[index];
			
            var key:BabylonFrame = { frame: animationKey.frame, value: [] };
			
            switch (dataType) {
                case Animation.ANIMATIONTYPE_FLOAT:
                    key.value = [animationKey.value];
                    
                case Animation.ANIMATIONTYPE_QUATERNION, Animation.ANIMATIONTYPE_MATRIX, Animation.ANIMATIONTYPE_VECTOR3:
                    key.value = animationKey.value.asArray();
                    
            }
			
            serializationObject.keys.push(key);
        }
		
        return serializationObject;
    }
	
	static function serializeMultiMaterial(material:MultiMaterial):Dynamic {
        var serializationObject:Dynamic = { };
		
        serializationObject.name = material.name;
        serializationObject.id = material.id;
        serializationObject.tags = Tags.GetTags(material);
		
        serializationObject.materials = new Array<Dynamic>();
		
        for (matIndex in 0...material.subMaterials.length) {
            var subMat = material.subMaterials[matIndex];
			
            if (subMat != null) {
                serializationObject.materials.push(subMat.id);
            } else {
                serializationObject.materials.push(null);
            }
        }
		
        return serializationObject;
    }
	
	static function serializeMaterial(material:StandardMaterial):Dynamic {
        var serializationObject:Dynamic = { };
		
        serializationObject.name = material.name;
		
        serializationObject.ambient = material.ambientColor.asArray();
        serializationObject.diffuse = material.diffuseColor.asArray();
        serializationObject.specular = material.specularColor.asArray();
        serializationObject.specularPower = material.specularPower;
        serializationObject.emissive = material.emissiveColor.asArray();
		
        serializationObject.alpha = material.alpha;
		
        serializationObject.id = material.id;
        serializationObject.tags = Tags.GetTags(material);
        serializationObject.backFaceCulling = material.backFaceCulling;
		
        if (material.diffuseTexture != null) {
            serializationObject.diffuseTexture = serializeTexture(material.diffuseTexture);
        }
		
        if (material.diffuseFresnelParameters != null) {
            serializationObject.diffuseFresnelParameters = serializeFresnelParameter(material.diffuseFresnelParameters);
        }
		
        if (material.ambientTexture != null) {
            serializationObject.ambientTexture = serializeTexture(material.ambientTexture);
        }
		
        if (material.opacityTexture != null) {
            serializationObject.opacityTexture = serializeTexture(material.opacityTexture);
        }
		
        if (material.opacityFresnelParameters != null) {
            serializationObject.opacityFresnelParameters = serializeFresnelParameter(material.opacityFresnelParameters);
        }
		
        if (material.reflectionTexture != null) {
            serializationObject.reflectionTexture = serializeTexture(material.reflectionTexture);
        }
		
        if (material.reflectionFresnelParameters != null) {
            serializationObject.reflectionFresnelParameters = serializeFresnelParameter(material.reflectionFresnelParameters);
        }
		
        if (material.emissiveTexture != null) {
            serializationObject.emissiveTexture = serializeTexture(material.emissiveTexture);
        }
		
        if (material.emissiveFresnelParameters != null) {
            serializationObject.emissiveFresnelParameters = serializeFresnelParameter(material.emissiveFresnelParameters);
        }
		
        if (material.specularTexture != null) {
            serializationObject.specularTexture = serializeTexture(material.specularTexture);
        }
		
        if (material.bumpTexture != null) {
            serializationObject.bumpTexture = serializeTexture(material.bumpTexture);
        }
		
        return serializationObject;
    }
	
	static function serializeTexture(texture:BaseTexture):Dynamic {
        var serializationObject:Dynamic = { };
		
        if (texture.name == null) {
            return null;
        }
		
        if (Std.is(texture, CubeTexture)) {
            serializationObject.name = texture.name;
            serializationObject.hasAlpha = texture.hasAlpha;
            serializationObject.level = texture.level;
            serializationObject.coordinatesMode = texture.coordinatesMode;
			
            return serializationObject;
        }
		
        if (Std.is(texture, MirrorTexture)) {
            var mirrorTexture:MirrorTexture = cast texture;
            serializationObject.renderTargetSize = mirrorTexture.getRenderSize();
            serializationObject.renderList = new Array<Dynamic>();
			
            for (index in 0...mirrorTexture.renderList.length) {
                serializationObject.renderList.push(mirrorTexture.renderList[index].id);
            }
			
            serializationObject.mirrorPlane = mirrorTexture.mirrorPlane.asArray();
        } 
		else if (Std.is(texture, RenderTargetTexture)) {
            var renderTargetTexture:RenderTargetTexture = cast texture;
            serializationObject.renderTargetSize = renderTargetTexture.getRenderSize();
            serializationObject.renderList = new Array<Dynamic>();
			
            for (index in 0...renderTargetTexture.renderList.length) {
                serializationObject.renderList.push(renderTargetTexture.renderList[index].id);
            }
        }
		
        var regularTexture:Texture = cast texture;
		
        serializationObject.name = texture.name;
        serializationObject.hasAlpha = texture.hasAlpha;
        serializationObject.level = texture.level;
		
        serializationObject.coordinatesIndex = texture.coordinatesIndex;
        serializationObject.coordinatesMode = texture.coordinatesMode;
        serializationObject.uOffset = regularTexture.uOffset;
        serializationObject.vOffset = regularTexture.vOffset;
        serializationObject.uScale = regularTexture.uScale;
        serializationObject.vScale = regularTexture.vScale;
        serializationObject.uAng = regularTexture.uAng;
        serializationObject.vAng = regularTexture.vAng;
        serializationObject.wAng = regularTexture.wAng;
		
        serializationObject.wrapU = texture.wrapU;
        serializationObject.wrapV = texture.wrapV;
		
        // Animations
        appendAnimations(texture, serializationObject);
		
        return serializationObject;
    }
	
	static function serializeSkeleton(skeleton:Skeleton):Dynamic {
        var serializationObject:Dynamic = { };
		
        serializationObject.name = skeleton.name;
        serializationObject.id = skeleton.id;
		
        serializationObject.bones = new Array<Dynamic>();
		
        for (index in 0...skeleton.bones.length) {
            var bone = skeleton.bones[index];
			
            var serializedBone:Dynamic = {
                parentBoneIndex: bone.getParent() != null ? skeleton.bones.indexOf(bone.getParent()) : -1,
                name: bone.name,
                matrix: bone.getLocalMatrix().toArray()
            };
			
            serializationObject.bones.push(serializedBone);
			
            if (bone.animations != null && bone.animations.length > 0) {
                serializedBone.animation = serializeAnimation(bone.animations[0]);
            }
        }
		
        return serializationObject;
    }
	
	static function serializeParticleSystem(particleSystem:ParticleSystem):Dynamic {
        var serializationObject:Dynamic = { };
		
        serializationObject.emitterId = particleSystem.emitter.id;
        serializationObject.capacity = particleSystem.getCapacity();
		
        if (particleSystem.particleTexture != null) {
            serializationObject.textureName = particleSystem.particleTexture.name;
        }
		
        serializationObject.minAngularSpeed = particleSystem.minAngularSpeed;
        serializationObject.maxAngularSpeed = particleSystem.maxAngularSpeed;
        serializationObject.minSize = particleSystem.minSize;
        serializationObject.maxSize = particleSystem.maxSize;
        serializationObject.minLifeTime = particleSystem.minLifeTime;
        serializationObject.maxLifeTime = particleSystem.maxLifeTime;
        serializationObject.emitRate = particleSystem.emitRate;
        serializationObject.minEmitBox = particleSystem.minEmitBox.asArray();
        serializationObject.maxEmitBox = particleSystem.maxEmitBox.asArray();
        serializationObject.gravity = particleSystem.gravity.asArray();
        serializationObject.direction1 = particleSystem.direction1.asArray();
        serializationObject.direction2 = particleSystem.direction2.asArray();
        serializationObject.color1 = particleSystem.color1.asArray();
        serializationObject.color2 = particleSystem.color2.asArray();
        serializationObject.colorDead = particleSystem.colorDead.asArray();
        serializationObject.updateSpeed = particleSystem.updateSpeed;
        serializationObject.targetStopDuration = particleSystem.targetStopDuration;
        serializationObject.textureMask = particleSystem.textureMask.asArray();
        serializationObject.blendMode = particleSystem.blendMode;
		
        return serializationObject;
    }
	
	static function serializeLensFlareSystem(lensFlareSystem:LensFlareSystem):Dynamic {
        var serializationObject:Dynamic = { };
		
        serializationObject.emitterId = lensFlareSystem.getEmitter().id;
        serializationObject.borderLimit = lensFlareSystem.borderLimit;
		
        serializationObject.flares = new Array<Dynamic>();
        for (index in 0...lensFlareSystem.lensFlares.length) {
            var flare = lensFlareSystem.lensFlares[index];
			
            serializationObject.flares.push({
                size: flare.size,
                position: flare.position,
                color: flare.color.asArray(),
                textureName: Tools.GetFilename(flare.texture.name)
            });
        }
		
        return serializationObject;
    }
	
	static function serializeShadowGenerator(light:Light):Dynamic {
        var serializationObject:Dynamic = { };
        var shadowGenerator = light.getShadowGenerator();
		
        serializationObject.lightId = light.id;
        serializationObject.mapSize = shadowGenerator.getShadowMap().getRenderSize();
        serializationObject.useVarianceShadowMap = shadowGenerator.useVarianceShadowMap;
        serializationObject.usePoissonSampling = shadowGenerator.usePoissonSampling;
		
        serializationObject.renderList = [];
        for (meshIndex in 0...shadowGenerator.getShadowMap().renderList.length) {
            var mesh = shadowGenerator.getShadowMap().renderList[meshIndex];
			
            serializationObject.renderList.push(mesh.id);
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
			trace("Unknow primitive type");
			throw("Unknow primitive type");
        }
        else {
            serializationGeometries.vertexData.push(serializeVertexData(geometry));
        }
		
        serializedGeometries[geometry.id] = geometry;
    }
	
	static function serializeGeometryBase(geometry:Geometry):Dynamic {
        var serializationObject:Dynamic = { };
		
        serializationObject.id = geometry.id;
		
        if (Tags.HasTags(geometry)) {
            serializationObject.tags = Tags.GetTags(geometry);
        }
		
        return serializationObject;
    }
	
	static function serializeVertexData(vertexData:Geometry):Dynamic {
        var serializationObject = serializeGeometryBase(vertexData);
		
        if (vertexData.isVerticesDataPresent(VertexBuffer.PositionKind)) {
            serializationObject.positions = vertexData.getVerticesData(VertexBuffer.PositionKind);
        }
		
        if (vertexData.isVerticesDataPresent(VertexBuffer.NormalKind)) {
            serializationObject.normals = vertexData.getVerticesData(VertexBuffer.NormalKind);
        }
		
        if (vertexData.isVerticesDataPresent(VertexBuffer.UVKind)) {
            serializationObject.uvs = vertexData.getVerticesData(VertexBuffer.UVKind);
        }
		
        if (vertexData.isVerticesDataPresent(VertexBuffer.UV2Kind)) {
            serializationObject.uvs2 = vertexData.getVerticesData(VertexBuffer.UV2Kind);
        }
		
        if (vertexData.isVerticesDataPresent(VertexBuffer.ColorKind)) {
            serializationObject.colors = vertexData.getVerticesData(VertexBuffer.ColorKind);
        }
		
        if (vertexData.isVerticesDataPresent(VertexBuffer.MatricesIndicesKind)) {
            serializationObject.matricesIndices = vertexData.getVerticesData(VertexBuffer.MatricesIndicesKind);
            serializationObject.matricesIndices._isExpanded = true;
        }
		
        if (vertexData.isVerticesDataPresent(VertexBuffer.MatricesWeightsKind)) {
            serializationObject.matricesWeights = vertexData.getVerticesData(VertexBuffer.MatricesWeightsKind);
        }
		
        serializationObject.indices = vertexData.getIndices();
		
        return serializationObject;
    }
	
	static function serializePrimitive(primitive:_Primitive):Dynamic {
        var serializationObject = serializeGeometryBase(primitive);		
        serializationObject.canBeRegenerated = primitive.canBeRegenerated();
		
        return serializationObject;
    }
	
	static function serializeBox(box:Box):Dynamic {
        var serializationObject = serializePrimitive(box);
        serializationObject.size = box.size;
		
        return serializationObject;
    }
	
	static function serializeSphere(sphere:Sphere):Dynamic {
        var serializationObject = serializePrimitive(sphere);
        serializationObject.segments = sphere.segments;
        serializationObject.diameter = sphere.diameter;
		
        return serializationObject;
    }
	
	static function serializeCylinder(cylinder:Cylinder):Dynamic {
        var serializationObject = serializePrimitive(cylinder);
        serializationObject.height = cylinder.height;
        serializationObject.diameterTop = cylinder.diameterTop;
        serializationObject.diameterBottom = cylinder.diameterBottom;
        serializationObject.tessellation = cylinder.tessellation;
		
        return serializationObject;
    }
	
	static function serializeTorus(torus:Torus):Dynamic {
        var serializationObject = serializePrimitive(torus);
        serializationObject.diameter = torus.diameter;
        serializationObject.thickness = torus.thickness;
        serializationObject.tessellation = torus.tessellation;
		
        return serializationObject;
    }
	
	static function serializeGround(ground:Ground):Dynamic {
        var serializationObject = serializePrimitive(ground);
        serializationObject.width = ground.width;
        serializationObject.height = ground.height;
        serializationObject.subdivisions = ground.subdivisions;
		
        return serializationObject;
    }
	
	static function serializePlane(plane:Plane):Dynamic {
        var serializationObject = serializePrimitive(plane);
        serializationObject.size = plane.size;
		
        return serializationObject;
    }
	
	static function serializeTorusKnot(torusKnot:TorusKnot):Dynamic {
        var serializationObject = serializePrimitive(torusKnot);
		
        serializationObject.radius = torusKnot.radius;
        serializationObject.tube = torusKnot.tube;
        serializationObject.radialSegments = torusKnot.radialSegments;
        serializationObject.tubularSegments = torusKnot.tubularSegments;
        serializationObject.p = torusKnot.p;
        serializationObject.q = torusKnot.q;
		
        return serializationObject;
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
                serializeGeometry(geometry, serializationScene.geometries);
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
        if (mesh.skeleton) {
            serializationObject.skeletonId = mesh.skeleton.id;
        }
        // Physics
        if (mesh.getPhysicsImpostor() != PhysicsEngine.NoImpostor) {
            serializationObject.physicsMass = mesh.getPhysicsMass();
            serializationObject.physicsFriction = mesh.getPhysicsFriction();
            serializationObject.physicsRestitution = mesh.getPhysicsRestitution();
            switch (mesh.getPhysicsImpostor()) {
                case PhysicsEngine.BoxImpostor:
                    serializationObject.physicsImpostor = 1;
                    
                case PhysicsEngine.SphereImpostor:
                    serializationObject.physicsImpostor = 2;
                    
            }
        }
		
        // Instances
        serializationObject.instances = new Array<Dynamic>();
        for (index in 0...mesh.instances.length) {
            var instance:InstancedMesh = mesh.instances[index];
            var serializationInstance = {
                name: instance.name,
                position: instance.position,
                rotation: instance.rotation,
                rotationQuaternion: instance.rotationQuaternion,
                scaling: instance.scaling
            };
            serializationObject.instances.push(serializationInstance);
            // Animations
            appendAnimations(instance, serializationInstance);
        }
		
        // Animations
        appendAnimations(mesh, serializationObject);
        // Layer mask
        serializationObject.layerMask = mesh.layerMask;
		
        return serializationObject;
    }
	
}
