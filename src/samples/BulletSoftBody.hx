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
import com.babylonhx.materials.lib.pbr.PBRMaterial;
import com.babylonhx.materials.lib.normal.NormalMaterial;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.materials.lib.water.WaterMaterial;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.lensflare.LensFlare;
import com.babylonhx.lensflare.LensFlareSystem;
import com.babylonhx.materials.FresnelParameters;
import com.babylonhx.loading.plugins.ctmfileloader.CTMFile;
import com.babylonhx.loading.plugins.ctmfileloader.CTMFileLoader;
import com.babylonhx.mesh.VertexBuffer;

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
import haxebullet.Bullet.BtSoftBodyWorldInfo;
import haxebullet.Bullet.BtSoftBodyWorldInfoPointer;
import haxebullet.Bullet.BtSoftRigidDynamicsWorld;
import haxebullet.Bullet.BtSoftRigidDynamicsWorldPointer;
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
class BulletSoftBody {
	
	var m_pCollisionConfiguration:BtDefaultCollisionConfigurationPointer;
	var m_pDispatcher:BtCollisionDispatcherPointer;
	var m_pBroadphase:BtDbvtBroadphasePointer;
	var m_pSolver:BtSequentialImpulseConstraintSolverPointer;
	var m_softBodyWorldInfo:BtSoftBodyWorldInfoPointer;
	var m_pWorld:BtSoftRigidDynamicsWorldPointer;
	
	var physObjs:Array<PhysicsObject> = [];
	
	var scene:Scene;

	public function new(scene:Scene) {
		this.scene = scene;
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
		m_pWorld = BtSoftRigidDynamicsWorld.create(m_pDispatcher, m_pBroadphase, m_pSolver, m_pCollisionConfiguration);
		
		m_softBodyWorldInfo.ref.m_dispatcher = m_pDispatcher;
		m_softBodyWorldInfo.ref.m_broadphase = m_pBroadphase;
		m_softBodyWorldInfo.ref.m_sparsesdf.Initialize();
		
		#if cpp
		m_pWorld.ref.setGravity(BtVector3.create(0, -9.8, 0).ref);
		#else
		m_pWorld.setGravity(BtVector3.create(0, -9.8, 0));
		#end
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
