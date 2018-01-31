package samples;

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
class Physics3 {

	public function new(scene:Scene) {
		var skybox = Mesh.CreateBox("skyBox", 10000.0, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/Sky_FantasyClouds1_Low", scene);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		skyboxMaterial.disableLighting = true;
		skybox.material = skyboxMaterial;
		skybox.infiniteDistance = true;
		
		
	}
	
}