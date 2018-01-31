package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.cameras.ArcFollowCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.PointLight;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Space;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Quaternion;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.MeshBuilder;
import com.babylonhx.Scene;
import com.babylonhx.Engine;
import com.babylonhx.tools.ColorTools;
import com.babylonhx.tools.Tools;
import com.babylonhx.collisions.PickingInfo;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.PBRMaterial;
import com.babylonhx.materials.lib.normal.NormalMaterial;
import com.babylonhx.materials.ShaderMaterial;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.particles.ParticleSystem;
//import com.babylonhx.postprocess.SSAORenderingPipeline;
import com.babylonhx.materials.lib.water.WaterMaterial;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.lensflare.LensFlare;
import com.babylonhx.lensflare.LensFlareSystem;
import com.babylonhx.materials.FresnelParameters;
import com.babylonhx.loading.plugins.ctmfileloader.CTMFile;
import com.babylonhx.loading.plugins.ctmfileloader.CTMFileLoader;
import com.babylonhx.mesh.VertexBuffer;

import samples.bullet.Vehicle;
import samples.bullet.Physics;

import haxebullet.Bullet.BtRaycastVehicle;
import haxebullet.Bullet.BtVehicleTuning;
import haxebullet.Bullet.BtDefaultVehicleRaycaster;
import haxebullet.Bullet.BtCompoundShape;
import haxebullet.Bullet.BtCollisionShape;
import haxebullet.Bullet.BtSphereShape;
import haxebullet.Bullet.BtBoxShape;
import haxebullet.Bullet.BtCapsuleShape;
import haxebullet.Bullet.BtCylinderShape;
import haxebullet.Bullet.BtCylinderShapeX;
import haxebullet.Bullet.BtConeShape;
import haxebullet.Bullet.BtStaticPlaneShape;
import haxebullet.Bullet.BtConvexHullShape;
import haxebullet.Bullet.BtTriangleMesh;
import haxebullet.Bullet.BtBvhTriangleMeshShape;
import haxebullet.Bullet.BtConvexTriangleMeshShape;
import haxebullet.Bullet.BtTransform;
import haxebullet.Bullet.BtTransformPointer;
import haxebullet.Bullet.BtRigidBody;
import haxebullet.Bullet.BtRigidBodyPointer;
import haxebullet.Bullet.BtRigidBodyConstructionInfo;
import haxebullet.Bullet.BtVector3;
import haxebullet.Bullet.BtVector3Pointer;
import haxebullet.Bullet.BtQuaternion;
import haxebullet.Bullet.BtDynamicsWorld;
import haxebullet.Bullet.BtDiscreteDynamicsWorld;
import haxebullet.Bullet.BtDiscreteDynamicsWorldPointer;
import haxebullet.Bullet.BtDefaultCollisionConfiguration;
import haxebullet.Bullet.BtDefaultCollisionConfigurationPointer;
import haxebullet.Bullet.BtCollisionDispatcher;
import haxebullet.Bullet.BtCollisionDispatcherPointer;
import haxebullet.Bullet.BtDbvtBroadphase;
import haxebullet.Bullet.BtDbvtBroadphasePointer;
import haxebullet.Bullet.BtSequentialImpulseConstraintSolver;
import haxebullet.Bullet.BtSequentialImpulseConstraintSolverPointer;
import haxebullet.Bullet.BabylonHxMotionState;
import haxebullet.Bullet.BabylonHxMotionStatePointer;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Bullet2 {
	
	var m_pCollisionConfiguration:BtDefaultCollisionConfigurationPointer;
	var m_pDispatcher:BtCollisionDispatcherPointer;
	var m_pBroadphase:BtDbvtBroadphasePointer;
	var m_pSolver:BtSequentialImpulseConstraintSolverPointer;
	var m_pWorld:BtDiscreteDynamicsWorldPointer;
	
	var physObjs:Array<PhysicsObject> = [];
	
	var scene:Scene;
	
	var mainMaterial:StandardMaterial;
	var transMat:StandardMaterial;
	var normalMat:StandardMaterial;
	
	var carBody:Mesh;
	var cwheels:Array<Mesh> = [];
	
	var carSize = [7.8, 3.0, 19.4];
	var carMassCenter = [0.0, 0.6, 0.0];
	var wheelRadius = 1.40;
	var wheelDepth = 0.3;
	var wheelPos = [3.8, -0.70, 5.7];
	
	#if js
	var sharedBtVec3 = BtVector3.create(0, 0, 0);
	#end
	
	var mTriMesh = BtTriangleMesh.create(true, true);
	var vertices:Array<Float> = [];
	var indices:Array<Int> = [];
	
	var trackMesh:Mesh;

	public function new(scene:Scene) {
		this.scene = scene;
		
		transMat = new StandardMaterial("transmat", scene);
		transMat.alpha = 0.5;
		//transMat.disableDepthWrite = true;
		
		scene.getEngine().keyDown.push(function(keyCode:Int) {		
			trace(keyCode);
			switch (keyCode) {
				// axe L
				case 97: 
					Physics.key[0] = 1;
					
				case 100:          
					Physics.key[0] = Physics.key[0] = -1; // right, D
					
				case 119: 
					Physics.key[1] = Physics.key[1] = -1; // up, W, Z
					
				case 115:         
					Physics.key[1] = Physics.key[1] = 1; // down, S
					
				// axe R
				case 37:          
					Physics.key[2] = -1; // left
					
				case 39:          
					Physics.key[2] = 1; // right
					
				case 38:          
					Physics.key[3] = -1; // up
					
				case 40:          
					Physics.key[3] = 1; // down		
					
				case 17, 67:         
					Physics.key[5] = 1; // ctrl, C
					
				case 69:                   
					Physics.key[5] = 1; // E
					
				case 32:                   
					Physics.key[4] = 1; // space
					
				case 16:                   
					Physics.key[7] = 1; // shift
			}
		});
        scene.getEngine().keyUp.push(function(keyCode:Int) {			
			switch (keyCode) {
				// axe L
            case 97: 
				Physics.key[0] = 0;// left, A, Q
				
            case 100:          
				Physics.key[0] = 0; // right, D
				
            case 119: 
				Physics.key[1] = Physics.key[1] < 0 ? 0: Physics.key[1]; // up, W, Z
				
            case 115:          
				Physics.key[1] = Physics.key[1] > 0 ? 0: Physics.key[1]; // down, S
				
            // axe R
            case 37:          
				Physics.key[2] = Physics.key[2] < 0 ? 0: Physics.key[2]; // left
				
            case 39:          
				Physics.key[2] = Physics.key[2] > 0 ? 0: Physics.key[2]; // right
				
            case 38:          
				Physics.key[3] = Physics.key[3] < 0 ? 0: Physics.key[3]; // up
				
            case 40:          
				Physics.key[3] = Physics.key[3] > 0 ? 0: Physics.key[3]; // down

			case 17, 67:          
				Physics.key[5] = 0; // ctrl, C
				
            case 69:                  
				Physics.key[5] = 0; // E
				
            case 32:                   
				Physics.key[4] = 0; // space
				
            case 16:                   
				Physics.key[7] = 0; // shift
				
			}
		});
		
		var camera:ArcRotateCamera = new ArcRotateCamera("Camera", 3 * Math.PI / 2, Math.PI / 8, 20, new Vector3(-144, 4, -37), scene);
		camera.upperRadiusLimit = 50;
		camera.lowerRadiusLimit = 5;
		camera.maxZ = 10000;
		camera.attachControl();
		
		//var ssao = new SSAORenderingPipeline('ssaopipeline', scene, 0.75);
		//scene.postProcessRenderPipelineManager.attachCamerasToRenderPipeline("ssaopipeline", camera);
		//scene.postProcessRenderPipelineManager.enableEffectInPipeline("ssaopipeline", ssao.SSAOCombineRenderEffect, camera);
		
		var light = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
		light.intensity = 0.4;
		
		mainMaterial = new StandardMaterial("mainmat", scene);
		mainMaterial.diffuseTexture = new Texture("assets/img/10.jpg", scene);
		mainMaterial.specularColor = new Color3(0, 0, 0);
		//untyped mainMaterial.diffuseTexture.uScale = 8;
		//untyped mainMaterial.diffuseTexture.vScale = 8;
		//mainMaterial.specularPower = 50;
		mainMaterial.freeze();
		
		/*var groundMaterial = new StandardMaterial("groundmat", scene);
		groundMaterial.diffuseTexture = new Texture("assets/img/floor.png", scene);
		untyped groundMaterial.diffuseTexture.uScale = 8;
		untyped groundMaterial.diffuseTexture.vScale = 8;
		groundMaterial.freeze();*/
		
		initializePhysics();
		
		//physObjs.push(createBoxObject(new Vector3(380, 10, 380), new Vector3(0, -7, 0), null, 0));
		//physObjs[0].mesh.material = normalMat;// groundMaterial;
		
		/*CTMFileLoader.load("assets/models/terrain.ctm", scene, function(meshes:Array<Mesh>, triangleCount:Int) {
			var mat = new StandardMaterial("roadmat", scene);
			mat.diffuseTexture = new Texture("assets/img/ground7.jpg", scene);
			untyped mat.diffuseTexture.uScale = mat.diffuseTexture.vScale = 150; 
			mat.specularColor = Color3.Black();
			mat.backFaceCulling = false;
			trackMesh = meshes[0];
			trackMesh.material = mat;
			trackMesh.receiveShadows = true;
			mat.freeze();
			
			var vertices = trackMesh.getVerticesData(VertexBuffer.PositionKind);
			var indices = trackMesh.getIndices();
			
			physObjs.push(createMeshObject(vertices, indices, triangleCount, new Vector3(0, 0, 0), null, 0));
			
			trackMesh.convertToUnIndexedMesh();
			trackMesh.freezeWorldMatrix();
		});*/
		
		CTMFileLoader.load("assets/models/laketrack.ctm", scene, function(meshes:Array<Mesh>, triangleCount:Int) {
			var mat = new StandardMaterial("roadmat", scene);
			mat.diffuseTexture = new Texture("assets/img/track.png", scene);
			mat.specularColor = Color3.Black();
			mat.backFaceCulling = false;
			trackMesh = meshes[0];
			trackMesh.material = mat;
			trackMesh.receiveShadows = true;
			mat.freeze();
			
			trackMesh.convertToUnIndexedMesh();
			trackMesh.freezeWorldMatrix();
		});
		
		/*CTMFileLoader.load("assets/models/laketrackfence.ctm", scene, function(meshes:Array<Mesh>, triangleCount:Int) {
			var mat = new StandardMaterial("roadmat", scene);
			mat.diffuseTexture = new Texture("assets/img/track.png", scene);
			mat.specularColor = Color3.Black();
			mat.backFaceCulling = false;
			trackMesh = meshes[0];
			trackMesh.material = mat;
			trackMesh.receiveShadows = true;
			mat.freeze();
			
			trackMesh.convertToUnIndexedMesh();
			trackMesh.freezeWorldMatrix();
		});*/
		
		CTMFileLoader.loadGeometry("assets/models/laketrackcollider.ctm", function(file:CTMFile) {			
			for (i in 0...file.body.vertices.length) {
				vertices.push(file.body.vertices[i]);
			}
			
			for (i in 0...file.body.indices.length) {
				indices.push(file.body.indices[i]);
			}
			
			physObjs.push(createMeshObject(vertices, indices, file.header.triangleCount, new Vector3(0, 0, 0), null, 0));
		});
		
		
		/*CTMFileLoader.loadGeometry("assets/models/terrain.ctm", function(file:CTMFile) {			
			for (i in 0...file.body.vertices.length) {
				vertices.push(file.body.vertices[i]);
			}
			
			for (i in 0...file.body.indices.length) {
				indices.push(file.body.indices[i]);
			}
			
			physObjs.push(createMeshObject(vertices, indices, file.header.triangleCount, new Vector3(0, 0, 0), null, 0));
		});*/
		
		//physObjs.push(createBoxObject(new Vector3(40, 10, 40), new Vector3(0, -7, -5), new Vector3(Math.PI / 9, 0, 0), 0));
		
		//physObjs.push(createBoxObject(new Vector3(40, 10, 40), new Vector3(0, -7, -52), new Vector3(Math.PI / 9, -Math.PI, 0), 0));
		
		/*for (i in 0...20) {
			physObjs.push(createCylinderObject(1.1, 2, new Vector3(3.2 * (i + 1), 0.1, 15), null, 400));
		}
		
		for (i in 0...30) {
			physObjs.push(createConeObject(0.5, 1, new Vector3(1 * (i + 1), 1, 0), null, 150));
		}*/
		
		/*for (i in 0...20) {
			physObjs.push(createCylinderObject(1.1, 2, new Vector3(-8.2 * (i + 1), 10, 15), null, 400));
		}
		
		for (i in 0...30) {
			physObjs.push(createConeObject(0.5, 1, new Vector3(-2 * (i + 1), 10, 0), null, 150));
		}*/
		
		/*for (i in 0...20) {
			physObjs.push(createCylinderObject(4, 6, new Vector3(-8.2 * (i + 1), 10, 15), null, 400));
		}
		
		for (i in 0...30) {
			physObjs.push(createConeObject(3, 4, new Vector3(-2 * (i + 1), 10, 0), null, 150));
		}*/
		
		var _vehicle = new Vehicle(cast m_pWorld, {
			type: 'box',
			name: 'car',
			helper: true,
			pos: [-10, -50, -37], // start position of car 
			rot: [0, 0, 0], // start rotation of car
			size: carSize, // chassis size
			massCenter: carMassCenter, // local center of mass (best is on chassis bottom)
			
			friction: 0.3, 
			restitution: 0.0, 
			linearDamping: 1.3, 
			angularDamping: 0.3,
			
			radius: wheelRadius,// wheels radius
			deep: wheelDepth, // wheels deep only for three cylinder
			wPos: wheelPos, // wheels position on chassis
			
			// car setting
			
			mass: 1200,// mass of vehicle in kg
			engine: 300, // Maximum driving force of the vehicle
			acceleration: 1000, // engine increment 
			
			// suspension setting
			
			// Damping relaxation should be slightly larger than compression
			s_compression: 6.4,// 0.1 to 0.3 are real values default 0.84
			s_relaxation: 2.8, // The damping coefficient for when the suspension is expanding. default : 0.88
			
			s_stiffness: 20,// 10 = Offroad buggy, 50 = Sports car, 200 = F1 Car 
			s_travel: 500, // The maximum distance the suspension can be compressed in Cm
			s_force: 10000, // Maximum suspension force
			s_length: 0.6,//0.1, // The maximum length of the suspension in meter
			
			// wheel setting
			
			// friction: The constant friction of the wheels on the surface.
			// For realistic TS It should be around 0.8. 
			// But may be greatly increased to improve controllability (1000 and more)
			// Set large (10000.0) for kart racers
			w_friction: 10000,
			// roll: reduces torque from the wheels
			// reducing vehicle barrel chance
			// 0 - no torque, 1 - the actual physical behavior
			w_roll: 1,
		});
		
		//physObjs.push(createBoxObject(new Vector3(2, 2, 2), new Vector3(0, 25, 0), null, 100));
		
		carBody = MeshBuilder.CreateBox("carbody", { width: carSize[0], height: carSize[1], depth: carSize[2] }, scene);
		carBody.rotationQuaternion = new Quaternion();
		carBody.locallyTranslate(new Vector3(0, 0.6, 0));
		carBody.bakeCurrentTransformIntoVertices();
		carBody.position.set(0, 1, 0);
		carBody.rotation.set(0, Math.PI / 2, 0);
		carBody.material = transMat;
		//carBody.renderOutline = true;
		
		var skybox = Mesh.CreateBox("skyBox", 5100.0, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/TropicalSunnyDay", scene);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		skyboxMaterial.disableLighting = true;
		skybox.material = skyboxMaterial;
		skybox.infiniteDistance = true;
		skyboxMaterial.freeze();
		
		normalMat = new StandardMaterial("normat", scene);
		normalMat.reflectionTexture = new CubeTexture("assets/img/skybox/TropicalSunnyDay", scene);
		normalMat.reflectionTexture.coordinatesMode = Texture.SPHERICAL_MODE;
		normalMat.specularPower = 128;
		normalMat.specularColor = new Color3(1, 1, 1);
		normalMat.diffuseColor = new Color3(0.3, 0.3, 0.3);
		normalMat.freeze();
		
		var light2 = new DirectionalLight("light2", new Vector3(3, -5, 5), scene);
		light2.intensity = 1.5;
		
		/*var materialSphere = new PBRMaterial("Material_body", scene);
	    materialSphere.reflectionTexture = skyboxMaterial.reflectionTexture;
	    materialSphere.albedoColor.copyFromFloats(0.2, 0.9, 1.0);
	    materialSphere.reflectivityColor = new Color3(1, 1, 1);
		materialSphere.microSurface = 0.5;
		materialSphere.usePhysicalLightFalloff = false;
		materialSphere.albedoTexture = new Texture("assets/img/pat2.jpg", scene);*/
		
		//var camera = new FreeCamera("freecam", carBody.position.clone(), scene);
		
		// Shadows
        var shadowGenerator = new ShadowGenerator(512, light2);
		shadowGenerator.useBlurVarianceShadowMap = true;
		shadowGenerator.blurBoxOffset = 2.0;
		
		var lightSphere0 = Mesh.CreateSphere("Sphere0", 16, 0.5, scene);
		lightSphere0.position = new Vector3(-831.84, 620, -2000.26);
		
		var lensFlareSystem = new LensFlareSystem("lensFlareSystem", lightSphere0, scene);
		var flare00 = new LensFlare(0.2, 0, new Color3(1, 1, 1), "assets/img/lens5.png", lensFlareSystem);
		var flare01 = new LensFlare(0.5, 0.2, new Color3(0.5, 0.5, 1), "assets/img/lens4.png", lensFlareSystem);
		var flare02 = new LensFlare(0.2, 1.0, new Color3(1, 1, 1), "assets/img/lens4.png", lensFlareSystem);
		var flare03 = new LensFlare(0.4, 0.4, new Color3(1, 0.5, 1), "assets/img/flare.png", lensFlareSystem);
		var flare04 = new LensFlare(0.1, 0.6, new Color3(1, 1, 1), "assets/img/lens5.png", lensFlareSystem);
		var flare05 = new LensFlare(0.3, 0.8, new Color3(1, 1, 1), "assets/img/lens4.png", lensFlareSystem);
		
		/*var waterMesh = Mesh.CreateGround("waterMesh", 2000, 2000, 6, scene);
		waterMesh.position.y = -13.7;
		var water = new WaterMaterial("water", scene, new Vector2(1024, 1024));
		water.backFaceCulling = true;
		water.bumpTexture = new Texture("assets/img/waterbump.jpg", scene);
		water.windForce = -2;
		water.waveHeight = 0;
		water.bumpHeight = 0.05;
		water.colorBlendFactor = 0;
		water.freeze();
		water.addToRenderList(skybox);
		water.addToRenderList(trackMesh);
		waterMesh.material = water;*/
		
		//var camera = new ArcFollowCamera("followcam", Math.PI * 2, Math.PI / 6, 20, carBody, scene);
		//camera.target = carBody;
		
		for (i in 0...4) {
			cwheels.push(MeshBuilder.CreateCylinder("wheel" + i, { height: wheelDepth * 2, diameterTop: wheelRadius * 2, diameterBottom: wheelRadius * 2, tessellation: 10, subdivisions: 1, enclose: true }, scene));
			cwheels[i].rotation.z = Math.PI / 2;			
			untyped cwheels[i].bakeCurrentTransformIntoVertices();
			cwheels[i].rotationQuaternion = new Quaternion();
			cwheels[i].material = transMat;
			//cwheels[i].renderOutline = true;
		}
		
		// Fog
		/*scene.fogMode = Scene.FOGMODE_EXP;
		scene.fogDensity = 0.001;*/
		
		var camaro:Mesh = null;
		SceneLoader.ImportMesh("", "assets/models/", "Camaro.babylon", scene, function (newMeshes:Array<AbstractMesh>, newParticles:Array<ParticleSystem>, newSkeletons:Array<Skeleton>) {
			camaro = cast newMeshes[0]; 
			//camaro.convertToUnIndexedMesh();
			
			var metal = new PBRMaterial("metal", scene);
			metal.reflectionTexture = new CubeTexture("assets/img/skybox/TropicalSunnyDay", scene);
			metal.directIntensity = 2.3;
			metal.environmentIntensity = 2.3;
			metal.cameraExposure = 0.75;
			metal.cameraContrast = 1.1;
			metal.microSurface = 0.96;
			metal.reflectivityColor = new Color3(0.4, 0.4, 0.4);
			metal.albedoColor = new Color3(0.8, 0.8, 0.8);
			metal.backFaceCulling = false;
			metal.freeze();
			
			camaro.material = metal;
			
			for (m in newMeshes) {
				m.rotation.y = Math.PI;
				m.translate(new Vector3(0, 1, 0), -2.3, Space.LOCAL);
				m.translate(new Vector3(1, 0, 0), -0.2, Space.LOCAL);
				m.translate(new Vector3(0, 0, 1), 0.1, Space.LOCAL);
				untyped m.convertToUnIndexedMesh();
				untyped m.bakeCurrentTransformIntoVertices();
				m.parent = carBody;
			}
		});
		
		/*SceneLoader.ImportMesh("", "assets/models/dzip/", "dzip.babylon", scene, function (newMeshes:Array<AbstractMesh>, newParticles:Array<ParticleSystem>, newSkeletons:Array<Skeleton>) {
			for (mesh in newMeshes) {
				mesh.parent = carBody;
				untyped mesh.convertToUnIndexedMesh();
				mesh.material = normalMat;
				
				//water.addToRenderList(mesh);
				//mesh.receiveShadows = true;
				shadowGenerator.getShadowMap().renderList.push(mesh);
			}
		});
		
		SceneLoader.ImportMesh("", "assets/models/dzip/", "wheel.babylon", scene, function (newMeshes:Array<AbstractMesh>, newParticles:Array<ParticleSystem>, newSkeletons:Array<Skeleton>) {
			newMeshes[0].scaling.set(0.012, 0.012, 0.012);
			newMeshes[0].parent = cwheels[0];
			untyped newMeshes[0].convertToUnIndexedMesh();
			untyped newMeshes[0].bakeCurrentTransformIntoVertices();
			untyped newMeshes[0].material.freeze();
			//newMeshes[0].material = normalMat;
			
			var m1 = cast (newMeshes[0], Mesh).createInstance("m1");
			m1.parent = cwheels[3];
			
			//water.addToRenderList(newMeshes[0]);
			shadowGenerator.getShadowMap().renderList.push(newMeshes[0]);
			//water.addToRenderList(m1);
			shadowGenerator.getShadowMap().renderList.push(m1);
		});
		
		SceneLoader.ImportMesh("", "assets/models/dzip/", "wheel.babylon", scene, function (newMeshes:Array<AbstractMesh>, newParticles:Array<ParticleSystem>, newSkeletons:Array<Skeleton>) {
			newMeshes[0].scaling.set(0.012, 0.012, 0.012);
			newMeshes[0].rotation.y = Math.PI;
			untyped newMeshes[0].bakeCurrentTransformIntoVertices();
			untyped newMeshes[0].convertToUnIndexedMesh();
			newMeshes[0].parent = cwheels[1];
			//newMeshes[0].material = normalMat;
			
			var m2 = cast (newMeshes[0], Mesh).createInstance("m2");
			m2.parent = cwheels[2];
			
			//water.addToRenderList(newMeshes[0]);
			shadowGenerator.getShadowMap().renderList.push(newMeshes[0]);
			//water.addToRenderList(m2);
			shadowGenerator.getShadowMap().renderList.push(m2);
		});*/
		
		//Dynamically create a 6*6 ranges of sphere demoing most of the 
		//reflectivity glossiness combinaisons.	
		/*var x = 38;
		for (i in 0...6) {
			var reflectivity = i / 5;
			var z = -55; 
			for (j in 0...6) {
				var glossiness = j / 5;
				var m = createMesh(x, z, reflectivity, glossiness, cast skyboxMaterial.reflectionTexture);	
				water.addToRenderList(m);
				z = z + 15;
			}	
			x = x - 15;
		}*/
		
		var editControl:com.babylonhxext.editcontrol.EditControl = null;
		
		scene.onPointerDown = function (x:Int, y:Int, button:Int, pickResult:PickingInfo) {
			if (pickResult.hit) {
				if (editControl != null && editControl.isPointerOver()) return;
				if (editControl != null) {
					editControl.detach();
				}
				editControl = new com.babylonhxext.editcontrol.EditControl(cast pickResult.pickedMesh, camera, 1.0);			
				editControl.enableTranslation();	
				
				trace(pickResult.pickedMesh.position, pickResult.pickedMesh.name);
			}
		};
		
	/*#if js
		var worker = new js.html.Worker('ammoworker.js');
		var m:Dynamic = {};
		m._vehicle = _vehicle;
		m.m_pWorld = m_pWorld;
		m.physObjs = physObjs;
		m.scene = scene;
		m.carBody = carBody;
		m.cwheels = cwheels;
		worker.postMessage(m); // Start the worker.
	#end*/
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
			
		#if js
		
			m_pWorld.stepSimulation(scene.getEngine().getDeltaTime() / 1000);
			
			for (p in physObjs) {
				if (!p.isStatic) {
					p.motionState.getWorldTransform(p.trans);
					p.mesh.rotationQuaternion.set(p.trans.getRotation().x(), p.trans.getRotation().y(), p.trans.getRotation().z(), p.trans.getRotation().w());
					p.mesh.position.set(p.trans.getOrigin().x(), p.trans.getOrigin().y(), p.trans.getOrigin().z());
				}
			}
			
			_vehicle.stepVehicle(carBody, cwheels);
			
		#elseif cpp
		
			m_pWorld.ref.stepSimulation(scene.getEngine().getDeltaTime() / 1000);
			
			for (p in physObjs) {
				if (!p.isStatic) {
					p.motionState.ref.getBabylonWorldTransform();
					p.mesh.rotationQuaternion.set(p.motionState.ref.rotX, p.motionState.ref.rotY, p.motionState.ref.rotZ, p.motionState.ref.rotW);
					p.mesh.position.set(p.motionState.ref.posX, p.motionState.ref.posY, p.motionState.ref.posZ);
				}
			}
			_vehicle.stepVehicle(carBody, cwheels);
			
		#end
			
			camera.setTarget(carBody.position);
		});
	}
	
	function createMesh(x:Float, z:Float, reflectivity:Float, glossiness:Float, reflectionTexture:Texture):Mesh {
		//Creation of a sphere
		var sphere = Mesh.CreateSphere("Sphere_x_" + x +"_z_" + z, 20, 10.0, scene);
		sphere.position.z = z;
		sphere.position.x = x;
		
		//Creation of a material
	    var materialSphere = new PBRMaterial("Material_x_" + x +"_z_" + z, scene);
	    materialSphere.reflectionTexture = reflectionTexture;
	    materialSphere.albedoColor = new Color3(0.2, 0.9, 1.0);
	    materialSphere.reflectivityColor = new Color3(reflectivity, reflectivity, reflectivity);
		materialSphere.microSurface = glossiness;
		materialSphere.usePhysicalLightFalloff  = false;
		
		//Attach the material to the sphere
		sphere.material = materialSphere;
		sphere.isPickable = true;
		
		return sphere;
	}
	
	private function initializePhysics() {
		// create the collision configuration
		m_pCollisionConfiguration = BtDefaultCollisionConfiguration.create();
		// create the dispatcher
		m_pDispatcher = BtCollisionDispatcher.create(m_pCollisionConfiguration);
		// create the broadphase
		m_pBroadphase = BtDbvtBroadphase.create();
		// create the constraint solver
		m_pSolver = BtSequentialImpulseConstraintSolver.create();
		// create the world
		m_pWorld = BtDiscreteDynamicsWorld.create(m_pDispatcher, m_pBroadphase, m_pSolver, m_pCollisionConfiguration);
		
		#if cpp
		m_pWorld.ref.setGravity(BtVector3.create(0, -9.8, 0).ref);
		#else
		m_pWorld.setGravity(BtVector3.create(0, -9.8, 0));
		#end
	}
	
	private function createBoxObject(size:Vector3, position:Vector3, ?rotation:Vector3, mass:Float = 1.0, ?localInteria:Vector3, restitution:Float = 0.1, friction:Float = 0.6):PhysicsObject {
		if (localInteria == null) {
			localInteria = Vector3.Zero();
		}
		
		if (rotation == null) {
			rotation = Vector3.Zero();
		}
		
		var mesh = MeshBuilder.CreateBox("box_" + Tools.uuid(), { width: size.x, height: size.y, depth: size.z }, scene);
		mesh.position.copyFrom(position);		
		mesh.rotationQuaternion = Quaternion.RotationYawPitchRoll(rotation.y, rotation.x, rotation.z);
		
		mesh.material = mainMaterial;
		
		var transform = BtTransform.create();
		
		#if cpp
		var pBoxShape = BtBoxShape.create(BtVector3.create(size.x / 2, size.y / 2, size.z / 2).ref);
		transform.ref.setIdentity();
		transform.ref.setOrigin(BtVector3.create(position.x, position.y, position.z).ref);
		transform.ref.setRotation(BtQuaternion.create(mesh.rotationQuaternion.x, mesh.rotationQuaternion.y, mesh.rotationQuaternion.z, mesh.rotationQuaternion.w).ref);
		
		var pMotionState = BabylonHxMotionState.create(transform.ref);
		
		var _localInertia = BtVector3.create(localInteria.x, localInteria.y, localInteria.z);
		if (mass > 0.0) {
			pBoxShape.ref.calculateLocalInertia(mass, _localInertia.ref);	 
		}
		var rbInfo = BtRigidBodyConstructionInfo.create(mass, pMotionState, pBoxShape, _localInertia.ref);
		rbInfo.ref.m_friction = friction;
		rbInfo.ref.m_restitution = restitution;
		var pRigidBody = BtRigidBody.create(rbInfo.ref);
		
		m_pWorld.ref.addRigidBody(pRigidBody);
		#else
		sharedBtVec3.setValue(size.x / 2, size.y / 2, size.z / 2);
		var pBoxShape = BtBoxShape.create(sharedBtVec3);
		transform.setIdentity();
		sharedBtVec3.setValue(position.x, position.y, position.z);
		transform.setOrigin(sharedBtVec3);
		transform.setRotation(BtQuaternion.create(mesh.rotationQuaternion.x, mesh.rotationQuaternion.y, mesh.rotationQuaternion.z, mesh.rotationQuaternion.w));
		
		var pMotionState = BabylonHxMotionState.create(transform);
		
		sharedBtVec3.setValue(localInteria.x, localInteria.y, localInteria.z);
		if (mass > 0.0) {
			pBoxShape.calculateLocalInertia(mass, sharedBtVec3);	
		}
		var rbInfo = BtRigidBodyConstructionInfo.create(mass, pMotionState, pBoxShape, sharedBtVec3);
		rbInfo.m_friction = friction;
		rbInfo.m_restitution = restitution;
		var pRigidBody = BtRigidBody.create(rbInfo);
		
		m_pWorld.addRigidBody(pRigidBody);
		#end
		
		return new PhysicsObject({ mesh: mesh, body: pRigidBody, shape: pBoxShape, motionState: pMotionState, trans: transform, isStatic: mass == 0 });
	}
	
	private function createSphereObject(radius:Float, position:Vector3, mass:Float = 1.0, ?localInteria:Vector3):PhysicsObject {
		if (localInteria == null) {
			localInteria = Vector3.Zero();
		}
		
		var rotation = new Quaternion();
		
		var mesh = Mesh.CreateSphere("sphere_" + Tools.uuid(), 8, radius, scene);
		mesh.position.copyFrom(position);
		mesh.rotationQuaternion = new Quaternion();
		
		mesh.material = mainMaterial;
		
		var pSphereShape = BtSphereShape.create(radius / 2);		
		var transform = BtTransform.create();
		
		#if cpp		
		transform.ref.setIdentity();
		transform.ref.setOrigin(BtVector3.create(position.x, position.y, position.z).ref);
		transform.ref.setRotation(BtQuaternion.create(rotation.x, rotation.y, rotation.z, rotation.w).ref);
		
		var pMotionState = BabylonHxMotionState.create(transform.ref);
		
		var _localInertia = BtVector3.create(localInteria.x, localInteria.y, localInteria.z);
		pSphereShape.ref.calculateLocalInertia(mass, _localInertia.ref);	 
		var rbInfo = BtRigidBodyConstructionInfo.create(mass, pMotionState, pSphereShape, _localInertia.ref);
		var pRigidBody = BtRigidBody.create(rbInfo.ref);
		
		m_pWorld.ref.addRigidBody(pRigidBody);
		#else
		sharedBtVec3.setValue(position.x, position.y, position.z);
		transform.setIdentity();
		transform.setOrigin(sharedBtVec3);
		transform.setRotation(BtQuaternion.create(rotation.x, rotation.y, rotation.z, rotation.w));
		
		var pMotionState = BabylonHxMotionState.create(transform);
		
		sharedBtVec3.setValue(localInteria.x, localInteria.y, localInteria.z);
		if (mass > 0.0) {
			pSphereShape.calculateLocalInertia(mass, sharedBtVec3);	
		}
		var rbInfo = BtRigidBodyConstructionInfo.create(mass, pMotionState, pSphereShape, sharedBtVec3);
		var pRigidBody = BtRigidBody.create(rbInfo);
		
		m_pWorld.addRigidBody(pRigidBody);
		#end
		
		return new PhysicsObject({ mesh: mesh, body: pRigidBody, motionState: pMotionState, trans: transform, isStatic: mass == 0 });
	}
	
	private function createCapsuleObject(radius:Float, height:Float, position:Vector3, ?rotation:Vector3, mass:Float = 1.0, ?localInteria:Vector3):PhysicsObject {
		if (localInteria == null) {
			localInteria = Vector3.Zero();
		}
		
		if (rotation == null) {
			rotation = Vector3.Zero();
		}
		
		var mesh = Mesh.CreateCapsule("capsule_" + Tools.uuid(), radius, height, 10, scene);		
		mesh.position.copyFrom(position);		
		mesh.rotationQuaternion = Quaternion.RotationYawPitchRoll(rotation.y, rotation.x, rotation.z);
		
		mesh.material = mainMaterial;
		
		var pCapsuleShape = BtCapsuleShape.create(radius / 2, height);
		var transform = BtTransform.create();
		
		#if cpp	
		transform.ref.setIdentity();
		transform.ref.setOrigin(BtVector3.create(position.x, position.y, position.z).ref);
		transform.ref.setRotation(BtQuaternion.create(mesh.rotationQuaternion.x, mesh.rotationQuaternion.y, mesh.rotationQuaternion.z, mesh.rotationQuaternion.w).ref);
		
		var pMotionState = BabylonHxMotionState.create(transform.ref);
		
		var _localInertia = BtVector3.create(localInteria.x, localInteria.y, localInteria.z);
		if (mass > 0.0) {
			pCapsuleShape.ref.calculateLocalInertia(mass, _localInertia.ref);
		}
		var rbInfo = BtRigidBodyConstructionInfo.create(mass, pMotionState, pCapsuleShape, _localInertia.ref);
		var pRigidBody = BtRigidBody.create(rbInfo.ref);
		
		m_pWorld.ref.addRigidBody(pRigidBody);
		#else
		sharedBtVec3.setValue(position.x, position.y, position.z);
		transform.setIdentity();
		transform.setOrigin(sharedBtVec3);
		transform.setRotation(BtQuaternion.create(mesh.rotationQuaternion.x, mesh.rotationQuaternion.y, mesh.rotationQuaternion.z, mesh.rotationQuaternion.w));
		
		var pMotionState = BabylonHxMotionState.create(transform);
		
		sharedBtVec3.setValue(localInteria.x, localInteria.y, localInteria.z);
		if (mass > 0.0) {
			pCapsuleShape.calculateLocalInertia(mass, sharedBtVec3);
		}
		var rbInfo = BtRigidBodyConstructionInfo.create(mass, pMotionState, pCapsuleShape, sharedBtVec3);
		var pRigidBody = BtRigidBody.create(rbInfo);
		
		m_pWorld.addRigidBody(pRigidBody);
		#end
		
		return new PhysicsObject({ mesh: mesh, body: pRigidBody, motionState: pMotionState, trans: transform, isStatic: mass == 0 });
	}
	
	private function createCylinderObject(diameter:Float, height:Float, position:Vector3, ?rotation:Vector3, mass:Float = 1.0, ?localInteria:Vector3):PhysicsObject {
		if (localInteria == null) {
			localInteria = Vector3.Zero();
		}
		
		if (rotation == null) {
			rotation = Vector3.Zero();
		}
		
		var mesh = MeshBuilder.CreateCylinder("cylinder_" + Tools.uuid, { height: height, diameterTop: diameter, diameterBottom: diameter, tessellation: 10, subdivisions: 1, enclose: true }, scene);
		mesh.position.copyFrom(position);
		mesh.rotationQuaternion = Quaternion.RotationYawPitchRoll(rotation.y, rotation.x, rotation.z);
		
		mesh.material = mainMaterial;
		
		var transform = BtTransform.create();
		
		#if cpp	
		var pCylinderShape = BtCylinderShape.create(BtVector3.create(diameter / 2, height / 2, diameter / 2).ref);
		transform.ref.setIdentity();
		transform.ref.setOrigin(BtVector3.create(position.x, position.y, position.z).ref);
		transform.ref.setRotation(BtQuaternion.create(mesh.rotationQuaternion.x, mesh.rotationQuaternion.y, mesh.rotationQuaternion.z, mesh.rotationQuaternion.w).ref);
		
		var pMotionState = BabylonHxMotionState.create(transform.ref);
		
		var _localInertia = BtVector3.create(localInteria.x, localInteria.y, localInteria.z);
		if (mass > 0.0) {
			pCylinderShape.ref.calculateLocalInertia(mass, _localInertia.ref);	
		}
		var rbInfo = BtRigidBodyConstructionInfo.create(mass, pMotionState, pCylinderShape, _localInertia.ref);
		var pRigidBody = BtRigidBody.create(rbInfo.ref);
		
		m_pWorld.ref.addRigidBody(pRigidBody);
		#else
		var pCylinderShape = BtCylinderShape.create(BtVector3.create(diameter / 2, height / 2, diameter / 2));
		sharedBtVec3.setValue(position.x, position.y, position.z);
		transform.setIdentity();
		transform.setOrigin(sharedBtVec3);
		transform.setRotation(BtQuaternion.create(mesh.rotationQuaternion.x, mesh.rotationQuaternion.y, mesh.rotationQuaternion.z, mesh.rotationQuaternion.w));
		
		var pMotionState = BabylonHxMotionState.create(transform);
		
		sharedBtVec3.setValue(localInteria.x, localInteria.y, localInteria.z);
		if (mass > 0.0) {
			pCylinderShape.calculateLocalInertia(mass, sharedBtVec3);	 
		}
		var rbInfo = BtRigidBodyConstructionInfo.create(mass, pMotionState, pCylinderShape, sharedBtVec3);
		var pRigidBody = BtRigidBody.create(rbInfo);
		
		m_pWorld.addRigidBody(pRigidBody);
		#end
		
		return new PhysicsObject({ mesh: mesh, body: pRigidBody, motionState: pMotionState, trans: transform, isStatic: mass == 0 });
	}
	
	private function createConeObject(diameter:Float, height:Float, position:Vector3, ?rotation:Vector3, mass:Float = 1.0, ?localInteria:Vector3):PhysicsObject {
		if (localInteria == null) {
			localInteria = Vector3.Zero();
		}		
		
		if (rotation == null) {
			rotation = Vector3.Zero();
		}
		
		var mesh = MeshBuilder.CreateCylinder("cylinder_" + Tools.uuid, { height: height, diameterTop: 0, diameterBottom: diameter, tessellation: 10, subdivisions: 1, enclose: true }, scene);
		mesh.position.copyFrom(position);
		mesh.rotationQuaternion = Quaternion.RotationYawPitchRoll(rotation.y, rotation.x, rotation.z);
		
		mesh.material = mainMaterial;
		
		var transform = BtTransform.create();
		
		var pConeShape = BtConeShape.create(diameter / 2, height);
		#if cpp	
		transform.ref.setIdentity();
		transform.ref.setOrigin(BtVector3.create(position.x, position.y, position.z).ref);
		transform.ref.setRotation(BtQuaternion.create(mesh.rotationQuaternion.x, mesh.rotationQuaternion.y, mesh.rotationQuaternion.z, mesh.rotationQuaternion.w).ref);
		
		var pMotionState = BabylonHxMotionState.create(transform.ref);
		
		var _localInertia = BtVector3.create(localInteria.x, localInteria.y, localInteria.z);
		if (mass > 0.0) {
			pConeShape.ref.calculateLocalInertia(mass, _localInertia.ref);	
		}
		var rbInfo = BtRigidBodyConstructionInfo.create(mass, pMotionState, pConeShape, _localInertia.ref);
		var pRigidBody = BtRigidBody.create(rbInfo.ref);
		
		m_pWorld.ref.addRigidBody(pRigidBody);
		#else
		sharedBtVec3.setValue(position.x, position.y, position.z);
		transform.setIdentity();
		transform.setOrigin(sharedBtVec3);
		transform.setRotation(BtQuaternion.create(mesh.rotationQuaternion.x, mesh.rotationQuaternion.y, mesh.rotationQuaternion.z, mesh.rotationQuaternion.w));
		
		var pMotionState = BabylonHxMotionState.create(transform);
		
		sharedBtVec3.setValue(localInteria.x, localInteria.y, localInteria.z);
		if (mass > 0.0) {
			pConeShape.calculateLocalInertia(mass, sharedBtVec3);	
		}
		var rbInfo = BtRigidBodyConstructionInfo.create(mass, pMotionState, pConeShape, sharedBtVec3);
		var pRigidBody = BtRigidBody.create(rbInfo);
		
		m_pWorld.addRigidBody(pRigidBody);
		#end
		
		return new PhysicsObject({ mesh: mesh, body: pRigidBody, motionState: pMotionState, trans: transform, isStatic: mass == 0 });
	}
	
	//var vertexes:Array<cpp.Pointer<BtVector3>> = [];
	public function createMeshObject(vertices:Array<Float>, indices:Array<Int>, triangleCount:Int, position:Vector3, ?rotation:Vector3, mass:Float = 1.0, ?localInteria:Vector3):PhysicsObject {
		if (localInteria == null) {
			localInteria = Vector3.Zero();
		}		
		
		if (rotation == null) {
			rotation = Vector3.Zero();
		}
		
		// TODO: create debug mesh
		
		var transform = BtTransform.create();
		
	#if cpp	
		
		var removeDuplicateVertices = true;
		
		for (i in 0...triangleCount) {
			var index0 = indices[i * 3];
			var index1 = indices[i * 3 + 1];
			var index2 = indices[i * 3 + 2];
			
			var vertex0 = (BtVector3.create(vertices[index0 * 3], vertices[index0 * 3 + 1], vertices[index0 * 3 + 2]));
			var vertex1 = (BtVector3.create(vertices[index1 * 3], vertices[index1 * 3 + 1], vertices[index1 * 3 + 2]));
			var vertex2 = (BtVector3.create(vertices[index2 * 3], vertices[index2 * 3 + 1], vertices[index2 * 3 + 2]));
			
			/*vertex0 *= localScaling;
			vertex1 *= localScaling;
			vertex2 *= localScaling;*/
			
			mTriMesh.ref.addTriangle(vertex0.ref, vertex1.ref, vertex2.ref);
		}
		
		var shape = BtBvhTriangleMeshShape.create(mTriMesh, true, true);
		
		transform.ref.setIdentity();
		transform.ref.setOrigin(BtVector3.create(position.x, position.y, position.z).ref);
		transform.ref.setRotation(BtQuaternion.create(0, 0, 0, 1).ref);
		
		var pMotionState = BabylonHxMotionState.create(transform.ref);
		
		var _localInertia = BtVector3.create(localInteria.x, localInteria.y, localInteria.z);
		if (mass > 0.0) {
			shape.ref.calculateLocalInertia(mass, _localInertia.ref);	
		}
		var rbInfo = BtRigidBodyConstructionInfo.create(mass, pMotionState, shape, _localInertia.ref);
		var pRigidBody = BtRigidBody.create(rbInfo.ref);
		
		m_pWorld.ref.addRigidBody(pRigidBody);
		
	#else
	
		var removeDuplicateVertices = true;
		
		for (i in 0...triangleCount) {
			var index0 = indices[i * 3];
			var index1 = indices[i * 3 + 1];
			var index2 = indices[i * 3 + 2];
			
			var vertex0 = BtVector3.create(vertices[index0 * 3], vertices[index0 * 3 + 1], vertices[index0 * 3 + 2]);
			var vertex1 = BtVector3.create(vertices[index1 * 3], vertices[index1 * 3 + 1], vertices[index1 * 3 + 2]);
			var vertex2 = BtVector3.create(vertices[index2 * 3], vertices[index2 * 3 + 1], vertices[index2 * 3 + 2]);
			
			/*vertex0 *= localScaling;
			vertex1 *= localScaling;
			vertex2 *= localScaling;*/
			
			mTriMesh.addTriangle(vertex0, vertex1, vertex2);
		}
		
		var shape = BtBvhTriangleMeshShape.create(mTriMesh, true, true);
		
		sharedBtVec3.setValue(position.x, position.y, position.z);
		transform.setIdentity();
		transform.setOrigin(sharedBtVec3);
		transform.setRotation(BtQuaternion.create(0, 0, 0, 1));
		
		var pMotionState = BabylonHxMotionState.create(transform);
		
		sharedBtVec3.setValue(localInteria.x, localInteria.y, localInteria.z);
		//if (mass > 0.0) {
			shape.calculateLocalInertia(mass, sharedBtVec3);	
		//}
		var rbInfo = BtRigidBodyConstructionInfo.create(mass, pMotionState, shape, sharedBtVec3);
		var pRigidBody = BtRigidBody.create(rbInfo);
		
		m_pWorld.addRigidBody(pRigidBody);
	#end
		trace("ok5");
		return new PhysicsObject({ mesh: null, body: pRigidBody, motionState: pMotionState, trans: transform, isStatic: mass == 0 });
	}
	
}

class PhysicsObject {
	
	public var mesh:Mesh;
	public var body:BtRigidBodyPointer;
	public var motionState:BabylonHxMotionStatePointer;
	public var trans:BtTransformPointer;
	public var isStatic:Bool;
	public var mass:Float;
	
	
	public function new(options:Dynamic) {
		this.mesh = options.mesh;
		this.body = options.body;
		this.motionState = options.motionState;
		this.trans = options.trans;
		this.isStatic = options.isStatic;
	}
	
}
