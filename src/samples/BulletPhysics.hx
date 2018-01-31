package samples;

import com.babylonhx.Engine;
import com.babylonhx.Scene;
import com.babylonhx.materials.textures.MirrorTexture;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Quaternion;
import com.babylonhx.math.Plane;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.MeshBuilder;
import com.babylonhx.tools.Tools;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.PointLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.tools.EventState;
import com.babylonhx.math.Space;

#if js
import js.Browser;
#end

import samples.bullet.Vehicle;
import samples.bullet.Physics;
//import samples.bullet.RigidBody;

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
import haxebullet.Bullet.BtTransform;
import haxebullet.Bullet.BtTransformPointer;
import haxebullet.Bullet.BtRigidBody;
import haxebullet.Bullet.BtRigidBodyPointer;
import haxebullet.Bullet.BtRigidBodyConstructionInfo;
import haxebullet.Bullet.BtVector3;
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
import haxebullet.Bullet.BtDefaultMotionState;
import haxebullet.Bullet.BtDefaultMotionStatePointer;
import haxebullet.Bullet.BabylonHxMotionState;
import haxebullet.Bullet.BabylonHxMotionStatePointer;

/**
 * ...
 * @author Krtolica Vujadin
 */
class BulletPhysics {
	
	var m_pCollisionConfiguration:BtDefaultCollisionConfigurationPointer;
	var m_pDispatcher:BtCollisionDispatcherPointer;
	var m_pBroadphase:BtDbvtBroadphasePointer;
	var m_pSolver:BtSequentialImpulseConstraintSolverPointer;
	var m_pWorld:BtDiscreteDynamicsWorldPointer;
	var m_defaultContactProcessingThreshold:Float = 1000000.0;
	
	var physObjs:Array<PhysicsObject> = [];
	
	var scene:Scene;
	
	var mainMaterial:StandardMaterial;
	
	#if js
	var sharedBtVec3:BtVector3 = BtVector3.create(0, 0, 0);
	#end
	
	var carBody:Mesh;
	
	

	public function new(scene:Scene) {
		this.scene = scene;
		
		var camera:ArcRotateCamera = new ArcRotateCamera("Camera", 12.2598, 1.2501, 50, Vector3.Zero(), scene);
		camera.upperRadiusLimit = 500;
		//camera.upperBetaLimit = 1.6;
		camera.attachControl();
		
		var engine = scene.getEngine();
		
		engine.keyDown.push(function(keyCode:Int) {		
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
        engine.keyUp.push(function(keyCode:Int) {			
			switch (keyCode) {
				// axe L
            case 97: 
				Physics.key[0] = Physics.key[0] < 0 ? 0: Physics.key[0];// left, A, Q
				
            case 100:          
				Physics.key[0] = Physics.key[0] > 0 ? 0: Physics.key[0]; // right, D
				
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
		
		var skybox = Mesh.CreateBox("skyBox", 10000.0, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/skybox", scene);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		skyboxMaterial.disableLighting = true;
		skybox.infiniteDistance = true;
		skybox.material = skyboxMaterial;
		
		var light = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
		/*var light = new PointLight("Omni", new Vector3(10, 10, 50), scene);
		var light2 = new PointLight("Omni", new Vector3(10, 10, -20), scene);
		light.intensity = 0.7;
		light2.intensity = 0.6;*/
		
		mainMaterial = new StandardMaterial("mainmat", scene);
		mainMaterial.diffuseTexture = new Texture("assets/img/10.jpg", scene);
		//mainMaterial.diffuseColor = new Color3(0.8, 0.0, 0.0);
		mainMaterial.specularColor = new Color3(0, 0, 0);
		mainMaterial.specularPower = 50;
		mainMaterial.freeze();
		
		//initializePhysics();
		
		var mirrorMaterial = new StandardMaterial("texture4", scene);
		//mirrorMaterial.diffuseColor = new Color3(0.4, 0.4, 0.4);
		mirrorMaterial.diffuseTexture = new Texture("assets/img/floor.png", scene);
		//mirrorMaterial.bumpTexture = new Texture("assets/img/floor_bump.png", scene);
		untyped mirrorMaterial.diffuseTexture.uScale = 8;
		untyped mirrorMaterial.diffuseTexture.vScale = 8;
		/*untyped mirrorMaterial.bumpTexture.uScale = 5;
		untyped mirrorMaterial.bumpTexture.vScale = 5;*/
		//mirrorMaterial.specularPower = 50;
		//mirrorMaterial.specularColor = new Color3(0.3, 0.3, 0.3);
		//mirrorMaterial.reflectionTexture = new MirrorTexture("mirror", 1024, scene, true); //Create a mirror texture
		//cast (mirrorMaterial.reflectionTexture, MirrorTexture).mirrorPlane = new Plane(0, -1.0, 0, -7);
		//mirrorMaterial.reflectionTexture.level = 0.5;
		
		//physObjs.push(createBoxObject(new Vector3(380, 1, 380), new Vector3(0, -7, 0), null, 0));
		
		//physObjs.push(createBoxObject(new Vector3(40, 1, 40), new Vector3(0, -7, -5), new Vector3(Math.PI / 9, 0, 0), 0));
		
		//physObjs.push(createSphereObject(5, new Vector3(0, 15, 0), 20));
		/*for (i in 0...10) {
			physObjs.push(createCapsuleObject(1, 3, new Vector3(0.5 * (i + 1), 10, 0), new Vector3(0.2, 0.1, 0.3), 100));
		}*/
		
		/*for (i in 0...10) {
			physObjs.push(createCylinderObject(5, 12, new Vector3(5.5 * (i + 1), 18 * (i + 1), 0)));
		}
		
		for (i in 0...10) {
			physObjs.push(createConeObject(5, 12, new Vector3(5.5 * (i + 1), 50 * (i + 1), 0)));
		}*/
		
		/*var _vehicle = new Vehicle(cast m_pWorld, {
			type: 'box',
			name: 'car',
			helper: true,
			pos: [0, 1, 0], // start position of car 
			rot: [0, 90, 0], // start rotation of car
			size: [1.6, 0.4, 3.6], // chassis size
			massCenter: [0.0, 0.6, 0.0], // local center of mass (best is on chassis bottom)
			
			friction: 0.6, 
			restitution: 0.0, 
			linearDamping: 3.3, 
			angularDamping: 0.3,
			
			radius: 0.4,// wheels radius
			deep: 0.3, // wheels deep only for three cylinder
			wPos: [0.95, 0.5, 1.4], // wheels position on chassis
			
			// car setting
			
			mass: 600,// mass of vehicle in kg
			engine: 1000, // Maximum driving force of the vehicle
			acceleration: 10, // engine increment 
			
			// suspension setting
			
			// Damping relaxation should be slightly larger than compression
			s_compression: 2.4,// 0.1 to 0.3 are real values default 0.84
			s_relaxation: 2.8, // The damping coefficient for when the suspension is expanding. default : 0.88
			
			s_stiffness: 10,// 10 = Offroad buggy, 50 = Sports car, 200 = F1 Car 
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
		
		physObjs.push(createBoxObject(new Vector3(2, 2, 2), new Vector3(0, 5, 0), null, 100));
		
		carBody = MeshBuilder.CreateBox("carbody", { width: 1.6, height: 0.4, depth: 3.6 }, scene);
		carBody.rotationQuaternion = new Quaternion();
		for (i in 0...4) {
			cwheels.push(MeshBuilder.CreateCylinder("wheel" + i, { height: 0.3, diameterTop: 0.8, diameterBottom: 0.8, tessellation: 10, subdivisions: 1, enclose: true }, scene));
			cwheels[i].rotation.z = Math.PI / 2;			
			cwheels[i].bakeCurrentTransformIntoVertices();
			cwheels[i].rotationQuaternion = new Quaternion();
		}
		carBody.locallyTranslate(new Vector3(0, 0.6, 0));
		carBody.bakeCurrentTransformIntoVertices();
		carBody.position.set(0, 1, 0);
		carBody.rotation.set(0, Math.PI / 2, 0);
		*/
		
		/*physObjs.push(createBoxObject(new Vector3(0.2, 10, 50), new Vector3(-25, -5, 0), null, 0));
		physObjs.push(createBoxObject(new Vector3(0.2, 10, 50), new Vector3(25, -5, 0), null, 0));
		physObjs.push(createBoxObject(new Vector3(50, 10, 0.2), new Vector3(0, -5, -25), null, 0));
		physObjs.push(createBoxObject(new Vector3(50, 10, 0.2), new Vector3(0, -5, 25), null, 0));*/
		
		physObjs[0].mesh.material = mirrorMaterial;
		
		/*var dominoBox = new Vector3(Arrangments.block_thickness, Arrangments.block_height, Arrangments.block_width);
		
		var p:Array<Dynamic> = Arrangments.arrangePyramid();
		
		for (i in 0...p.length) {
			physObjs.push(createBoxObject(dominoBox, p[i].position));
		}
		
		Tools.delay(function() {
			#if cpp
			physObjs[1].body.ref.setAngularVelocity(BtVector3.create(-10, 0, 0).ref);
			physObjs[1].body.ref.setLinearVelocity(BtVector3.create(-10, 0, 0).ref);
			#else
			physObjs[1].body.setAngularVelocity(BtVector3.create(-10, 0, 0));
			physObjs[1].body.setLinearVelocity(BtVector3.create(-10, 0, 0));
			#end
		}, 2000);*/
		
		/*var p:Array<Dynamic> = Arrangments.arrangeCircle(70);
		for (i in 0...p.length) {
			var rot = new Vector3(0, p[i].angle, 0);
			physObjs.push(createBoxObject(dominoBox, p[i].position, rot));
		}
		
		Tools.delay(function() {
			#if cpp
			physObjs[1].body.ref.setAngularVelocity(BtVector3.create(0, 0, 10).ref);
			physObjs[1].body.ref.setLinearVelocity(BtVector3.create(0, 0, 10).ref);
			#else
			physObjs[1].body.setAngularVelocity(BtVector3.create(0, 0, 10));
			physObjs[1].body.setLinearVelocity(BtVector3.create(0, 0, 10));
			#end
		}, 2000);
		
		var p:Array<Dynamic> = Arrangments.arrangeCircle(50);
		for (i in 0...p.length) {
			var rot = new Vector3(0, p[i].angle, 0);
			physObjs.push(createBoxObject(dominoBox, p[i].position, rot));
		}
		
		Tools.delay(function() {
			#if cpp
			physObjs[120].body.ref.setAngularVelocity(BtVector3.create(0, 0, -10).ref);
			physObjs[120].body.ref.setLinearVelocity(BtVector3.create(0, 0, -10).ref);
			#else
			physObjs[120].body.setAngularVelocity(BtVector3.create(0, 0, -10));
			physObjs[120].body.setLinearVelocity(BtVector3.create(0, 0, -10));
			#end
		}, 2000);
		
		var p:Array<Dynamic> = Arrangments.arrangeCircle(30);
		for (i in 0...p.length) {
			var rot = new Vector3(0, p[i].angle, 0);
			physObjs.push(createBoxObject(dominoBox, p[i].position, rot));
		}
		
		Tools.delay(function() {
			#if cpp
			physObjs[150].body.ref.setAngularVelocity(BtVector3.create(0, 0, 10).ref);
			physObjs[150].body.ref.setLinearVelocity(BtVector3.create(0, 0, 10).ref);
			#else
			physObjs[150].body.setAngularVelocity(BtVector3.create(0, 0, 10));
			physObjs[150].body.setLinearVelocity(BtVector3.create(0, 0, 10));
			#end
		}, 2000);*/
		
		/*physObjs.push(createSphereObject(10, new Vector3(0, 400, 0), 20));
		
		var height = 50;
		var radius = 7;
		var sz = 8;
		var sy = sz * 0.15;
		var px:Float = 0;
		var py:Float = 0;
		var pz:Float = 0;
		var angle:Float = 0;
		var rad:Float = 0;
		
		
		for (j in 0...height) {
			for (i in 0...5) {
				rad = radius;
				angle = (Math.PI * 2 / 5 * (i + j * 0.5));
				px = Math.cos(angle) * rad;
				py = j * sy / 2;
				pz = -Math.sin(angle) * rad;
				
				physObjs.push(createBoxObject(new Vector3(sz * 0.15, sz * 0.15, sz), new Vector3(px, j * (sz * 0.15), pz), new Vector3(0, angle, 0), 0.02));
			}
		}*/
		
		/*Tools.delay(function() {
			#if cpp
			physObjs[1].body.ref.setAngularVelocity(BtVector3.create(0, 0, 2).ref);
			#else
			physObjs[1].body.setAngularVelocity(BtVector3.create(0, 0, 2));
			#end
		}, 2000);
		
		/*physObjs.push(createBoxObject(Vector3.One(), new Vector3(-0.3, 0, -0.2)));
		physObjs.push(createBoxObject(Vector3.One(), new Vector3(0.4, 5, 0.4)));
		physObjs.push(createBoxObject(new Vector3(2, 2, 6), new Vector3(1.4, 10, -0.4)));
		
		for (i in 2...40) {
			physObjs.push(createBoxObject(new Vector3(Tools.randomFloat(0.2, 1), Tools.randomFloat(0.2, 1), Tools.randomFloat(4, 8)), new Vector3(1.4, 2 * i, -0.4)));
		}
		
		for (i in 2...40) {
			physObjs.push(createSphereObject(Tools.randomFloat(1, 3), new Vector3(-Tools.randomFloat(0, 2), 2 * i, Tools.randomFloat(-3, 3))));
		}*/
		
		/*for (i in 1...physObjs.length) {
			untyped mirrorMaterial.reflectionTexture.renderList.push(physObjs[i].mesh);
		}*/
		
		//Engine.mouseUp.push(function(x:Int, y:Int, button:Int) {
			//trace(camera.alpha, camera.beta, camera.radius);
		//});
		
		//scene.registerBeforeRender(function(scene:Scene, es:Null<EventState>) {
			/*for (i in 1...physObjs.length) {
				physObjs[i].mesh.rotation.x += 0.01;
			}*/
			//camera.alpha += 0.001;
		//});
		
		scene.getEngine().runRenderLoop(function () {			
			/*#if js
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
			#end*/
			
			//_vehicle.stepVehicle(carBody, cwheels);
			
			//camera.setTarget(carBody.position);		
			
			scene.render();	
        });
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
		
		/*#if cpp
		m_pWorld.ref.setGravity(BtVector3.create(0, -9.8, 0).ref);
		#else
		m_pWorld.setGravity(BtVector3.create(0, -9.8, 0));
		#end*/
	}
	
	#if cpp
	@:functionCode('
		delete m_pWorld;
		delete m_pSolver;
		delete m_pBroadphase;
		delete m_pDispatcher;
		delete m_pCollisionConfiguration;
	')
	#end
	private function shutdownPhysics() { 
		m_pWorld = null;
		m_pSolver = null;
		m_pBroadphase = null;
		m_pDispatcher = null;
		m_pCollisionConfiguration = null;
	}
	
}

class PhysicsObject {
	
	public var mesh:Mesh;
	public var body:BtRigidBodyPointer;
	public var motionState:BabylonHxMotionStatePointer;
	public var trans:BtTransformPointer;
	public var isStatic:Bool;
	public var mass:Float;
	//public var shape:BtCollisionShape = null;
	
	
	public function new(options:Dynamic) {
		this.mesh = options.mesh;
		this.body = options.body;
		this.motionState = options.motionState;
		this.trans = options.trans;
		this.isStatic = options.isStatic;
		/*if (options.shape != null) {
			this.shape = options.shape;
		}*/
	}
	
}

class Arrangments {
	
	inline static public var block_width:Float = 1.5;
	inline static public var block_height:Float = 3;
	inline static public var block_thickness:Float = 0.5;
	inline static public var table_height:Float = -4.5;
	
	static public function arrangePyramid():Array<Dynamic> {
		var height = 30;
		var pyramid_top = new Vector3(height * (0.75 * block_width), 0, 3 * block_width);
		var pieces:Dynamic = [];
		var xOffset = table_height * 0.1;
		
		for (i in 1...height + 1) {
			var zOffset = i * (-0.75 * block_width);
			
			for (j in 0...i) {
				var current = Vector3.Zero();
				current.copyFrom(pyramid_top);
				current.x -= i * (0.6 * block_height) - xOffset;
				current.z += zOffset + (j * (1.25 * block_width));
				
				pieces.push({ position: current });
			}
		}
		
		return pieces;
	}

	static public function arrangeCircle(piecesCount:Int):Array<Dynamic> {
		var center = new Vector3(0, 0, 0);
		var picesCount = piecesCount;
		var radius = (picesCount / 5) * block_width;		
		
		var pieces:Array<Dynamic> = [];
		
		for(i in 0...picesCount) {
			var pos = Vector3.Zero().copyFrom(center);
			
			// var angle = -1 * degreesToRadians((360 / picesCount) * i);
			var angle = -2 * Math.PI / picesCount * i;
			var x = Math.cos(angle) * radius;
			var z = Math.sin(angle) * radius;
			
			pos.x += x;
			pos.z += z;
			
			angle = Math.PI / 2 - angle;
			
			pieces.push({ position: pos, angle: angle });
		}
		
		return pieces;
	}

	static public function arrangeSpirala():Array<Dynamic> {
		var pieces = [];
		var angleDelta = 2 * Math.PI / 36;
		var angle = 0.0;
		var radius = 10 * block_width;
		var center = Vector3.Zero();	
		var pos = Vector3.Zero();
		var i = 0;
		var z = 0.0;
		var x = 0.0;
		
		do {
			pos = Vector3.Zero().copyFrom(center);
			angle = angleDelta * i;
			x = Math.cos(angle) * radius;
			z = Math.sin(angle) * radius;
			
			pos.x += x;
			pos.z += z;
			
			angle = Math.PI / 2 - angle;
			radius -= 0.15;
			
			var color = (i % 2 == 0) ? Color3.White() : Color3.Green();
			pieces.push({ position: pos, angle: angle, color: color });
			i++;
		} 
		while (Vector3.Distance(center, pos) > 1.5 * block_width);
		
		return pieces;
	}
	
}
