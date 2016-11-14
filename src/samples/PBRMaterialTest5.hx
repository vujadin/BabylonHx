package samples;

/*import calikohx.FabrikBone2D;
import calikohx.FabrikBone3D;
import calikohx.FabrikChain2D;
import calikohx.FabrikChain3D;
import calikohx.FabrikJoint2D;
import calikohx.FabrikJoint3D;
import calikohx.FabrikStructure2D;
import calikohx.FabrikStructure3D;*/

import com.babylonhx.Scene;
import com.babylonhx.Engine;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.MeshBuilder;
import com.babylonhx.lights.PointLight;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.HDRCubeTexture;
import com.babylonhx.materials.PBRMaterial;
import com.babylonhx.loading.plugins.ctmfileloader.CTMFile;
import com.babylonhx.loading.plugins.ctmfileloader.CTMFileLoader;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.math.Tools;
import com.babylonhx.math.Quaternion;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.particles.ParticleSystem;

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
class PBRMaterialTest5 {
	
	var shadowCasters:Array<Mesh> = [];
	var shadowGenerator:ShadowGenerator;
	var shadowGenerator2:ShadowGenerator;
	var shadowGenerator3:ShadowGenerator;
	
	var m_pCollisionConfiguration:BtDefaultCollisionConfigurationPointer;
	var m_pDispatcher:BtCollisionDispatcherPointer;
	var m_pBroadphase:BtDbvtBroadphasePointer;
	var m_pSolver:BtSequentialImpulseConstraintSolverPointer;
	var m_pWorld:BtDiscreteDynamicsWorldPointer;
	
	var physObjs:Array<PhysicsObject> = [];
	var allPBRMaterials:Array<PBRMaterial> = [];
	
	#if js
	var sharedBtVec3 = BtVector3.create(0, 0, 0);
	#end
	
	var mTriMesh = BtTriangleMesh.create(true, true);
	
	var scene:Scene;
	var runPhysics:Bool = true;
	

	public function new(scene:Scene) {
		this.scene = scene;
		var camera = new ArcRotateCamera("Camera", -Math.PI / 4, Math.PI / 2.5, 200, Vector3.Zero(), scene);
		camera.attachControl();
		
		var light = new DirectionalLight("light1", new Vector3(5, -5, 5), scene);
		light.intensity = 0.6;
		
		// Shadows
        shadowGenerator = new ShadowGenerator(1024, light);
		shadowGenerator.useVarianceShadowMap = true;
		
		initializePhysics();
		
		// Light
		new PointLight("point", new Vector3(0, 40, 0), scene);
		
		var elephant:Mesh = null;
		CTMFileLoader.load("assets/models/elephant.ctm", scene, function(meshes:Array<Mesh>, triangleCount:Int) {
			elephant = meshes[0];
			//elephant.receiveShadows = true;
			shadowGenerator.getShadowMap().renderList.push(elephant);
			camera.setTarget(elephant.position);
		});
		
		CTMFileLoader.loadGeometry("assets/models/elephantcollider.ctm", function(file:CTMFile) {	
			var vertices:Array<Float> = [];
			for (i in 0...file.body.vertices.length) {
				vertices.push(file.body.vertices[i]);
			}
			
			var indices:Array<Int> = [];
			for (i in 0...file.body.indices.length) {
				indices.push(file.body.indices[i]);
			}
			
			createMeshObject(vertices, indices, file.header.triangleCount, new Vector3(0, 0, 0), null, 0);
		});
		
		// Environment Texture
		var hdrTexture = new HDRCubeTexture("assets/img/room.hdr", scene, 512);
		//var hdrTexture = new CubeTexture("assets/img/skybox/TropicalSunnyDay", scene);
		
		/*SceneLoader.ImportMesh("", "assets/models/", "angkor_statu.babylon", scene, function (newMeshes:Array<AbstractMesh>, newParticles:Array<ParticleSystem>, newSkeletons:Array<Skeleton>) {
			var statuemat = new PBRMaterial("wood", scene);
			statuemat.reflectionTexture = hdrTexture;
			statuemat.directIntensity = 0.0;
			statuemat.microSurface = 0;
			statuemat.albedoColor = Color3.White();
			statuemat.reflectivityColor = new Color3(0.0, 0.0, 0.0);
			statuemat.albedoTexture = new Texture("assets/models/angKorColor.png", scene);
			statuemat.bumpTexture = new Texture("assets/models/angKorNormalfinal.png", scene);
			statuemat.freeze();
			for (mesh in newMeshes) {
				mesh.material = statuemat;	
				mesh.position.set(0, 10, 18);
			}
		});*/
		
		// Skybox
		var hdrSkybox = Mesh.CreateBox("hdrSkyBox", 10000.0, scene);
		var hdrSkyboxMaterial = new PBRMaterial("skyBox", scene);
		hdrSkyboxMaterial.backFaceCulling = false;
		hdrSkyboxMaterial.reflectionTexture = hdrTexture.clone();
		hdrSkyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		hdrSkyboxMaterial.microSurface = 1.0;
		hdrSkyboxMaterial.cameraExposure = 0.6;
		hdrSkyboxMaterial.cameraContrast = 1.6;
		hdrSkyboxMaterial.disableLighting = true;
		hdrSkybox.material = hdrSkyboxMaterial;
		hdrSkybox.infiniteDistance = true;
		hdrSkyboxMaterial.freeze();
		
		// Create materials
		var glass = new PBRMaterial("glass", scene);
		glass.reflectionTexture = hdrTexture;
		glass.refractionTexture = hdrTexture;
		glass.linkRefractionWithTransparency = true;
		glass.indexOfRefraction = 0.52;
		glass.alpha = 0;
		glass.directIntensity = 0.0;
		glass.environmentIntensity = 0.5;
		glass.cameraExposure = 0.5;
		glass.cameraContrast = 1.7;
		glass.microSurface = 1;
		glass.reflectivityColor = new Color3(0.1, 0.1, 0.1);
		glass.albedoColor = new Color3(0.3, 0.3, 0.3);
		glass.freeze();
		
		allPBRMaterials.push(glass);
		
		var glassBlack = new PBRMaterial("glass", scene);
		glassBlack.reflectionTexture = hdrTexture;
		glassBlack.refractionTexture = hdrTexture;
		glassBlack.linkRefractionWithTransparency = true;
		glassBlack.indexOfRefraction = 0.52;
		glassBlack.alpha = 0;
		glassBlack.directIntensity = 0.0;
		glassBlack.environmentIntensity = 0.7;
		glassBlack.cameraExposure = 0.66;
		glassBlack.cameraContrast = 1.66;
		glassBlack.microSurface = 1;
		glassBlack.reflectivityColor = new Color3(0.2, 0.2, 0.2);
		glassBlack.albedoColor = new Color3(0.95, 0.95, 0.95);
		glassBlack.freeze();
		
		allPBRMaterials.push(glassBlack);
		
		var pearl = new PBRMaterial("pearl", scene);
		pearl.reflectionTexture = hdrTexture;
		pearl.refractionTexture = hdrTexture;
		pearl.linkRefractionWithTransparency = true;
		pearl.indexOfRefraction = 0.12;
		pearl.alpha = 0.5;
		pearl.directIntensity = 1.0;
		pearl.environmentIntensity = 0.2;
		pearl.cameraExposure = 2.5;
		pearl.cameraContrast = 1.7;
		pearl.microSurface = 0.8;
		pearl.reflectivityColor = new Color3(0, 0.4, 0.1);
		pearl.albedoColor = new Color3(1.0, 1.0, 1.0);
		pearl.freeze();
		
		allPBRMaterials.push(pearl);
		
		var gold = new PBRMaterial("gold", scene);
		gold.reflectionTexture = hdrTexture;
		gold.directIntensity = 0.3;
		gold.environmentIntensity = 0.7;
		gold.cameraExposure = 0.6;
		gold.cameraContrast = 1.6;
		gold.microSurface = 0.96;
		gold.reflectivityColor = new Color3(1.0, 0.8, 0);
		gold.albedoColor = new Color3(1.0, 0.8, 0);
		gold.freeze();
		
		allPBRMaterials.push(gold);
		
		var metal = new PBRMaterial("metal", scene);
		metal.reflectionTexture = hdrTexture;
		metal.directIntensity = 0.3;
		metal.environmentIntensity = 0.7;
		metal.cameraExposure = 0.6;
		metal.cameraContrast = 1.6;
		metal.microSurface = 0.96;
		metal.reflectivityColor = new Color3(0.9, 0.9, 0.9);
		metal.albedoColor = new Color3(1.0, 1.0, 1.0);
		metal.freeze();
		
		allPBRMaterials.push(metal);
		
		var plastic = new PBRMaterial("plastic", scene);
		plastic.reflectionTexture = hdrTexture;
		plastic.microSurface = 0.96;
		plastic.albedoColor = new Color3(0.206, 0.94, 1);
		plastic.reflectivityColor = new Color3(0.05, 0.05, 0.05);
		plastic.cameraExposure = 0.66;
		plastic.cameraContrast = 1.66;
		plastic.albedoColor = Color3.White();
		plastic.freeze();
		
		allPBRMaterials.push(plastic);
		
		var plastic2 = new PBRMaterial("pbr", scene);
		plastic2.reflectionTexture = hdrTexture;
		plastic2.albedoColor =  new Color3(0.206, 0.94, 1);
		plastic2.reflectivityColor = new Color3(0.0, 0.0, 0.0);
		plastic2.microSurface = 0;
		plastic2.directIntensity = 0;
		plastic2.freeze();
		
		allPBRMaterials.push(plastic2);
		
		elephant.material = plastic;
		
		var floor = createBoxObject(new Vector3(150, 1.5, 150), Vector3.Zero(), null, 0);
		floor.mesh.receiveShadows = true;
		floor.mesh.material = new StandardMaterial("woodmat", scene);
		untyped floor.mesh.material.diffuseTexture = new Texture("assets/img/10.jpg", scene);
		untyped floor.mesh.material.diffuseTexture.uScale = floor.mesh.material.diffuseTexture.vScale = 6;
		untyped floor.mesh.material.specularColor = Color3.Black();
		floor.mesh.material.freeze();
		
		var glasst = new PBRMaterial("glass", scene);
		glasst.reflectionTexture = hdrTexture;    
		glasst.indexOfRefraction = 0.52;
		glasst.alpha = 0.5;
		glasst.directIntensity = 0.0;
		glasst.environmentIntensity = 0.7;
		glasst.cameraExposure = 0.66;
		glasst.cameraContrast = 1.66;
		glasst.microSurface = 1;
		glasst.reflectivityColor = new Color3(0.2, 0.2, 0.2);
		glasst.albedoColor = new Color3(0.95, 0.95, 0.95);
		glasst.freeze();
		
		var wall1 = createBoxObject(new Vector3(150, 20, 2), new Vector3(0, 10, 75), null, 0);
		wall1.mesh.material = glasst;
		var wall2 = createBoxObject(new Vector3(150, 20, 2), new Vector3(0, 10, -75), null, 0);
		wall2.mesh.material = glasst;
		var wall3 = createBoxObject(new Vector3(2, 20, 150), new Vector3(75, 10, 0), null, 0);
		wall3.mesh.material = glasst;
		var wall4 = createBoxObject(new Vector3(2, 20, 150), new Vector3( -75, 10, 0), null, 0);
		wall4.mesh.material = glasst;
		
		var wall5 = createBoxObject(new Vector3(35, 30, 2), new Vector3(0, 45, 22), new Vector3(Math.PI / 3, 0, 0), 0);
		wall5.mesh.material = glasst;
		
		var m = 0;
		for (i in 0...25) {
			physObjs.push(createCapsuleObject(Tools.randomFloat(3, 4), Tools.randomFloat(3, 6), new Vector3(-1.5, 75 + m, 15)));
			physObjs[i].mesh.material = allPBRMaterials[Tools.randomInt(0, allPBRMaterials.length - 1)];
			shadowGenerator.getShadowMap().renderList.push(physObjs[i].mesh);
			m += 7;
		}
		
		m = 0;
		for (i in 25...50) {
			physObjs.push(createCylinderObject(Tools.randomFloat(3, 4), Tools.randomFloat(3, 4), new Vector3(-1.4, 75 + m, 20)));
			physObjs[i].mesh.material = allPBRMaterials[Tools.randomInt(0, allPBRMaterials.length - 1)];
			shadowGenerator.getShadowMap().renderList.push(physObjs[i].mesh);
			m += 7;
		}
		
		m = 0;
		for (i in 50...75) {
			physObjs.push(createConeObject(Tools.randomFloat(3, 5), Tools.randomFloat(3, 5), new Vector3(-2.5, 75 + m, 25)));
			physObjs[i].mesh.material = allPBRMaterials[Tools.randomInt(0, allPBRMaterials.length - 1)];
			shadowGenerator.getShadowMap().renderList.push(physObjs[i].mesh);
			m += 7;
		}
		
		m = 0;
		for (i in 75...100) {
			physObjs.push(createSphereObject(Tools.randomFloat(4, 7), new Vector3(-0.5, 75 + m, 20)));
			physObjs[i].mesh.material = allPBRMaterials[Tools.randomInt(0, allPBRMaterials.length - 1)];
			shadowGenerator.getShadowMap().renderList.push(physObjs[i].mesh);
			m += 7;
		}
		
		m = 0;
		for (i in 100...125) {
			physObjs.push(createBoxObject(new Vector3(Tools.randomInt(3, 6), Tools.randomInt(3, 6), Tools.randomInt(3, 6)), new Vector3(-3.5, 75 + m, 25)));
			physObjs[i].mesh.material = allPBRMaterials[Tools.randomInt(0, allPBRMaterials.length - 1)];
			shadowGenerator.getShadowMap().renderList.push(physObjs[i].mesh);
			m += 7;
		}
		
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
			
			if (runPhysics) {
			#if js
				
				m_pWorld.stepSimulation(scene.getEngine().getDeltaTime() / 1000);
				
				for (p in physObjs) {
					if (!p.isStatic) {
						p.motionState.getWorldTransform(p.trans);
						p.mesh.rotationQuaternion.set(p.trans.getRotation().x(), p.trans.getRotation().y(), p.trans.getRotation().z(), p.trans.getRotation().w());
						p.mesh.position.set(p.trans.getOrigin().x(), p.trans.getOrigin().y(), p.trans.getOrigin().z());
					}
				}
				
			#elseif cpp
			
				m_pWorld.ref.stepSimulation(scene.getEngine().getDeltaTime() / 1000);
				
				for (p in physObjs) {
					if (!p.isStatic) {
						p.motionState.ref.getBabylonWorldTransform();
						p.mesh.rotationQuaternion.set(p.motionState.ref.rotX, p.motionState.ref.rotY, p.motionState.ref.rotZ, p.motionState.ref.rotW);
						p.mesh.position.set(p.motionState.ref.posX, p.motionState.ref.posY, p.motionState.ref.posZ);
					}
				}	
				
			#end
			}
		});
		
		Engine.keyDown.push(function(keyCode:Int) {
			reset(keyCode);
		});
	}
	
	var velZero = BtVector3.create(0, 0, 0);
	var rotZero = BtQuaternion.create(0, 0, 0, 1);
	private function reset(keyCode:Int) {
		if (keyCode == 112) {
			runPhysics = !runPhysics;
			return;
		}
		
		if (keyCode == 111) {
			for (i in 0...physObjs.length) {
				#if js
				physObjs[i].body.getWorldTransform().setRotation(rotZero);
				physObjs[i].body.setLinearVelocity(velZero);
				physObjs[i].body.setAngularVelocity(velZero);
				#else
				physObjs[i].body.ref.getWorldTransform().setRotation(rotZero.ref);
				physObjs[i].body.ref.setLinearVelocity(velZero.ref);
				physObjs[i].body.ref.setAngularVelocity(velZero.ref);
				#end
			}
			
			var m = 0;
			for (i in 0...25) {
				#if js
				physObjs[i].body.getWorldTransform().setOrigin(BtVector3.create( -1.5, 75 + m, 15));
				#else
				//physObjs[i].body.ref.getWorldTransform().setOrigin((BtVector3.create( -1.5, 75 + m, 15)).ref);
				#end
				m += 7;
			}
			
			m = 0;
			for (i in 25...50) {
				#if js
				physObjs[i].body.getWorldTransform().setOrigin(BtVector3.create( -1.4, 75 + m, 20));
				#else
				//physObjs[i].body.ref.getWorldTransform().setOrigin(BtVector3.create( -1.4, 75 + m, 20).ref);
				#end
				m += 7;
			}
			
			m = 0;
			for (i in 50...75) {
				#if js
				physObjs[i].body.getWorldTransform().setOrigin(BtVector3.create( -2.5, 75 + m, 25));
				#else
				//physObjs[i].body.ref.getWorldTransform().setOrigin(BtVector3.create(-2.5, 75 + m, 25).ref);
				#end
				m += 7;
			}
			
			m = 0;
			for (i in 75...100) {
				#if js
				physObjs[i].body.getWorldTransform().setOrigin(BtVector3.create( -0.5, 75 + m, 20));
				#else
				//physObjs[i].body.ref.getWorldTransform().setOrigin(BtVector3.create(-0.5, 75 + m, 20).ref);
				#end
				m += 7;
			}
			
			m = 0;
			for (i in 100...125) {
				#if js
				physObjs[i].body.getWorldTransform().setOrigin(BtVector3.create( -3.5, 75 + m, 25));
				#else
				//physObjs[i].body.ref.getWorldTransform().setOrigin(BtVector3.create(-3.5, 75 + m, 25).ref);
				#end
				m += 7;
			}	
		}
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
		var _t = BtVector3.create(0, -29.8, 0);
		m_pWorld.ref.setGravity(_t.ref);
		#else
		m_pWorld.setGravity(BtVector3.create(0, -29.8, 0));
		#end
	}
	
	private function createBoxObject(size:Vector3, position:Vector3, ?rotation:Vector3, mass:Float = 1.0, ?localInteria:Vector3, restitution:Float = 0.1, friction:Float = 0.6):PhysicsObject {
		if (localInteria == null) {
			localInteria = Vector3.Zero();
		}
		
		if (rotation == null) {
			rotation = Vector3.Zero();
		}
		
		var mesh = MeshBuilder.CreateBox("box_", { width: size.x, height: size.y, depth: size.z }, scene);
		mesh.position.copyFrom(position);		
		mesh.rotationQuaternion = Quaternion.RotationYawPitchRoll(rotation.y, rotation.x, rotation.z);
		
		var transform = BtTransform.create();
		
		#if cpp
		var _t = BtVector3.create(size.x / 2, size.y / 2, size.z / 2);
		var pBoxShape = BtBoxShape.create(_t.ref);
		transform.ref.setIdentity();
		_t = BtVector3.create(position.x, position.y, position.z);
		transform.ref.setOrigin(_t.ref);
		var _q = BtQuaternion.create(mesh.rotationQuaternion.x, mesh.rotationQuaternion.y, mesh.rotationQuaternion.z, mesh.rotationQuaternion.w);
		transform.ref.setRotation(_q.ref);
		
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
		
		return new PhysicsObject(mesh, pRigidBody, pMotionState, transform, mass == 0);
	}
	
	private function createSphereObject(radius:Float, position:Vector3, mass:Float = 1.0, ?localInteria:Vector3):PhysicsObject {
		if (localInteria == null) {
			localInteria = Vector3.Zero();
		}
		
		var rotation = new Quaternion();
		
		var mesh = Mesh.CreateSphere("sphere_", 48, radius, scene);
		mesh.position.copyFrom(position);
		mesh.rotationQuaternion = new Quaternion();
		
		var pSphereShape = BtSphereShape.create(radius / 2);		
		var transform = BtTransform.create();
		
		#if cpp		
		transform.ref.setIdentity();
		var _t = BtVector3.create(position.x, position.y, position.z);
		transform.ref.setOrigin(_t.ref);
		var _q = BtQuaternion.create(rotation.x, rotation.y, rotation.z, rotation.w);
		transform.ref.setRotation(_q.ref);
		
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
		
		return new PhysicsObject(mesh, pRigidBody, pMotionState, transform, mass == 0);
	}
	
	private function createCapsuleObject(radius:Float, height:Float, position:Vector3, ?rotation:Vector3, mass:Float = 1.0, ?localInteria:Vector3):PhysicsObject {
		if (localInteria == null) {
			localInteria = Vector3.Zero();
		}
		
		if (rotation == null) {
			rotation = Vector3.Zero();
		}
		
		var mesh = Mesh.CreateCapsule("capsule_", radius, height, 10, scene);		
		mesh.position.copyFrom(position);		
		mesh.rotationQuaternion = Quaternion.RotationYawPitchRoll(rotation.y, rotation.x, rotation.z);
		
		var pCapsuleShape = BtCapsuleShape.create(radius / 2, height);
		var transform = BtTransform.create();
		
		#if cpp	
		transform.ref.setIdentity();
		var _t = BtVector3.create(position.x, position.y, position.z);
		transform.ref.setOrigin(_t.ref);
		var _q = BtQuaternion.create(mesh.rotationQuaternion.x, mesh.rotationQuaternion.y, mesh.rotationQuaternion.z, mesh.rotationQuaternion.w);
		transform.ref.setRotation(_q.ref);
		
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
		
		return new PhysicsObject(mesh, pRigidBody, pMotionState, transform, mass == 0);
	}
	
	private function createCylinderObject(diameter:Float, height:Float, position:Vector3, ?rotation:Vector3, mass:Float = 1.0, ?localInteria:Vector3):PhysicsObject {
		if (localInteria == null) {
			localInteria = Vector3.Zero();
		}
		
		if (rotation == null) {
			rotation = Vector3.Zero();
		}
		
		var mesh = MeshBuilder.CreateCylinder("cylinder_", { height: height, diameterTop: diameter, diameterBottom: diameter, tessellation: 20, subdivisions: 5, enclose: true }, scene);
		mesh.position.copyFrom(position);
		mesh.rotationQuaternion = Quaternion.RotationYawPitchRoll(rotation.y, rotation.x, rotation.z);
		
		var transform = BtTransform.create();
		
		#if cpp	
		var _t = BtVector3.create(diameter / 2, height / 2, diameter / 2);
		var pCylinderShape = BtCylinderShape.create(_t.ref);
		transform.ref.setIdentity();
		_t = BtVector3.create(position.x, position.y, position.z);
		transform.ref.setOrigin(_t.ref);
		var _q = BtQuaternion.create(mesh.rotationQuaternion.x, mesh.rotationQuaternion.y, mesh.rotationQuaternion.z, mesh.rotationQuaternion.w);
		transform.ref.setRotation(_q.ref);
		
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
		
		return new PhysicsObject(mesh, pRigidBody, pMotionState, transform, mass == 0);
	}
	
	private function createConeObject(diameter:Float, height:Float, position:Vector3, ?rotation:Vector3, mass:Float = 1.0, ?localInteria:Vector3):PhysicsObject {
		if (localInteria == null) {
			localInteria = Vector3.Zero();
		}		
		
		if (rotation == null) {
			rotation = Vector3.Zero();
		}
		
		var mesh = MeshBuilder.CreateCylinder("cylinder_", { height: height, diameterTop: 0, diameterBottom: diameter, tessellation: 20, subdivisions: 5, enclose: true }, scene);
		mesh.position.copyFrom(position);
		mesh.rotationQuaternion = Quaternion.RotationYawPitchRoll(rotation.y, rotation.x, rotation.z);
		
		var transform = BtTransform.create();
		
		var pConeShape = BtConeShape.create(diameter / 2, height);
		#if cpp	
		transform.ref.setIdentity();
		var _t = BtVector3.create(position.x, position.y, position.z);
		var _q = BtQuaternion.create(mesh.rotationQuaternion.x, mesh.rotationQuaternion.y, mesh.rotationQuaternion.z, mesh.rotationQuaternion.w);
		transform.ref.setOrigin(_t.ref);
		transform.ref.setRotation(_q.ref);
		
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
		
		return new PhysicsObject(mesh, pRigidBody, pMotionState, transform, mass == 0);
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
		var _t = BtVector3.create(position.x, position.y, position.z);
		transform.ref.setOrigin(_t.ref);
		var _q = BtQuaternion.create(0, 0, 0, 1);
		transform.ref.setRotation(_q.ref);
		
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
	
		return new PhysicsObject(null, pRigidBody, pMotionState, transform, mass == 0);
	}
	
}

class PhysicsObject {
	
	public var mesh:Mesh;
	public var body:BtRigidBodyPointer;
	public var motionState:BabylonHxMotionStatePointer;
	public var trans:BtTransformPointer;
	public var isStatic:Bool;
	public var mass:Float;
	
	
	public function new(mesh:Mesh, body:BtRigidBodyPointer, mstate:BabylonHxMotionStatePointer, trans:BtTransformPointer, isStatic:Bool) {
		this.mesh = mesh;
		this.body = body;
		this.motionState = mstate;
		this.trans = trans;
		this.isStatic = isStatic;
	}
	
}