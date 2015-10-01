package com.babylonhx.physics.plugins;

import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Quaternion;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.physics.IPhysicsEnginePlugin;

import cannonhx.world.World;
import cannonhx.objects.Body;
import cannonhx.shapes.Sphere;
import cannonhx.shapes.Plane;
import cannonhx.shapes.Box;
import cannonhx.shapes.ConvexPolyhedron;
import cannonhx.constraints.PointToPointConstraint;
import cannonhx.math.Vec3;
import cannonhx.material.Material;
import cannonhx.material.ContactMaterial;
import cannonhx.collision.NaiveBroadphase;


/**
 * ...
 * @author Krtolica Vujadin
 */
class CannonPlugin implements IPhysicsEnginePlugin {
	
	private var _world:World;
	private var _registeredMeshes:Array<Dynamic> = [];
	private var _physicsMaterials:Array<Material> = [];

	public function new() {
		//
	}
	
	public function initialize(?iterations:Int = 5) {
		this._world = new World();
		this._world.broadphase = new NaiveBroadphase();
		this._world.solver.iterations = iterations;
	}
	
	private function _checkWithEpsilon(value:Float):Float {
		return value < PhysicsEngine.Epsilon ? PhysicsEngine.Epsilon : value;
	}
	
	static var vpos:Vec3 = new Vec3();
	public function runOneStep(delta:Float) {
		this._world.step(delta);
		
		for (index in 0...this._registeredMeshes.length) {
			var registeredMesh = this._registeredMeshes[index];
			
			if (registeredMesh.isChild != null) {
				continue;
			}
			
			// Body position
			var bodyX = registeredMesh.body.position.x;
			var	bodyY = registeredMesh.body.position.y;
			var	bodyZ = registeredMesh.body.position.z;
			
			var deltaPos = registeredMesh.delta;
			registeredMesh.mesh.position.x = bodyX + deltaPos.x;
			registeredMesh.mesh.position.y = bodyZ + deltaPos.y;
			registeredMesh.mesh.position.z = bodyY + deltaPos.z;
						
			registeredMesh.mesh.rotationQuaternion.x = registeredMesh.body.quaternion.x;
			registeredMesh.mesh.rotationQuaternion.y = registeredMesh.body.quaternion.z;
			registeredMesh.mesh.rotationQuaternion.z = registeredMesh.body.quaternion.y;
			registeredMesh.mesh.rotationQuaternion.w = -registeredMesh.body.quaternion.w;
		}
	}

	public function setGravity(gravity:Vector3) {
		this._world.gravity.set(gravity.x, gravity.z, gravity.y);
	}

	public function registerMesh(mesh:AbstractMesh, impostor:Int, options:PhysicsBodyCreationOptions):Dynamic {
		this.unregisterMesh(mesh);
		
		mesh.computeWorldMatrix(true);
		
		switch (impostor) {
			case PhysicsEngine.SphereImpostor:
				var bbox = mesh.getBoundingInfo().boundingBox;
				var radiusX = bbox.maximumWorld.x - bbox.minimumWorld.x;
				var radiusY = bbox.maximumWorld.y - bbox.minimumWorld.y;
				var radiusZ = bbox.maximumWorld.z - bbox.minimumWorld.z;
				
				var mmax = Math.max(this._checkWithEpsilon(radiusX), this._checkWithEpsilon(radiusY));
				return this._createSphere(Math.max(mmax, this._checkWithEpsilon(radiusZ)) / 2, mesh, options);
				
			case PhysicsEngine.BoxImpostor:
				var bbox = mesh.getBoundingInfo().boundingBox;
				var min = bbox.minimumWorld;
				var max = bbox.maximumWorld;
				var box = max.subtract(min).scale(0.5);
				return this._createBox(this._checkWithEpsilon(box.x), this._checkWithEpsilon(box.y), this._checkWithEpsilon(box.z), mesh, options);
				
			case PhysicsEngine.PlaneImpostor:
				return this._createPlane(mesh, options);
				
			case PhysicsEngine.MeshImpostor:
				var rawVerts = mesh.getVerticesData(VertexBuffer.PositionKind);
				var rawFaces = mesh.getIndices();
				
				return this._createConvexPolyhedron(rawVerts, rawFaces, mesh, options);
		}
		
		return null;
	}

	private function _createSphere(radius:Float, mesh:AbstractMesh, ?options:PhysicsBodyCreationOptions):Dynamic {
		var shape = new Sphere(radius);
		
		if (options == null) {
			return shape;
		}
		
		return this._createRigidBodyFromShape(shape, mesh, options.mass, options.friction, options.restitution);
	}

	private function _createBox(x:Float, y:Float, z:Float, mesh:AbstractMesh, ?options:PhysicsBodyCreationOptions):Dynamic {
		var shape = new Box(new Vec3(x, z, y));
		
		if (options == null) {
			return shape;
		}
		
		return this._createRigidBodyFromShape(shape, mesh, options.mass, options.friction, options.restitution);
	}

	private function _createPlane(mesh:AbstractMesh, ?options:PhysicsBodyCreationOptions):Dynamic {
		var shape = new Plane();
		
		if (options == null) {
			return shape;
		}
		
		return this._createRigidBodyFromShape(shape, mesh, options.mass, options.friction, options.restitution);
	}

	private function _createConvexPolyhedron(rawVerts:Array<Float>, rawFaces:Array<Int>, mesh:AbstractMesh, ?options:PhysicsBodyCreationOptions):Dynamic {
		/*var verts:Array<Vec3> = [];
		var faces:Array<Float> = [];
		
		mesh.computeWorldMatrix(true);
		
		// Get vertices
		var i:Int = 0;
		while (i < rawVerts.length) {
			var transformed = Vector3.Zero();
			Vector3.TransformNormalFromFloatsToRef(rawVerts[i], rawVerts[i + 1], rawVerts[i + 2], mesh.getWorldMatrix(), transformed);
			verts.push(new Vec3(transformed.x, transformed.z, transformed.y));
			i += 3;
		}
		
		// Get faces
		var j:Int = 0;
		while(j < rawFaces.length) {
			faces.push(rawFaces[j]);
			faces.push(rawFaces[j + 2]);
			faces.push(rawFaces[j + 1]);
			j += 3;
		}
		
		var shape = new ConvexPolyhedron(verts, faces);
		
		if (options == null) {
			return shape;
		}
		
		return this._createRigidBodyFromShape(shape, mesh, options.mass, options.friction, options.restitution);*/
		return null;
	}

	private function _addMaterial(friction:Float, restitution:Float):Material {
		var mat:Material = null;
		
		for (index in 0...this._physicsMaterials.length) {
			mat = this._physicsMaterials[index];
			
			if (mat.friction == friction && mat.restitution == restitution) {
				return mat;
			}
		}
		
		var currentMat = new Material();
		currentMat.friction = friction;
		currentMat.restitution = restitution;
		this._physicsMaterials.push(currentMat);
		
		for (index in 0...this._physicsMaterials.length) {
			mat = this._physicsMaterials[index];
			
			var contactMaterial = new ContactMaterial(mat, currentMat, { friction: mat.friction * currentMat.friction, restitution: mat.restitution * currentMat.restitution });
			contactMaterial.contactEquationStiffness = 1e10;
			contactMaterial.contactEquationRelaxation = 10;
			
			this._world.addContactMaterial(contactMaterial);
		}
		
		return currentMat;
	}

	private function _createRigidBodyFromShape(shape:Dynamic, mesh:AbstractMesh, mass:Float, friction:Float, restitution:Float):Dynamic {
		var initialRotation:Quaternion = null;
		
		if (mesh.rotationQuaternion != null) {
			initialRotation = mesh.rotationQuaternion.clone();
		} else {
			initialRotation = mesh.rotation.toQuaternion();
		}
		mesh.rotationQuaternion = new Quaternion(0, 0, 0, 1);
		mesh.computeWorldMatrix(true);
		
		// The delta between the mesh position and the mesh bounding box center
		var bbox = mesh.getBoundingInfo().boundingBox;
		var deltaPosition = mesh.position.subtract(bbox.center);
		
		var m = new Matrix();
		initialRotation.toRotationMatrix(m);
		deltaPosition = Vector3.TransformCoordinates(deltaPosition, m);
		
		var material = this._addMaterial(friction, restitution);
		var body = new cannonhx.objects.Body({ mass: mass, shape: shape, material: material });
		
		if (initialRotation != null) {
			body.quaternion.x = initialRotation.z;
			body.quaternion.y = initialRotation.x;
			body.quaternion.z = initialRotation.y;
			body.quaternion.w = -initialRotation.w;
		}
		
		body.position.set(bbox.center.x, bbox.center.z, bbox.center.y);
		this._world.addBody(body);
		
		this._registeredMeshes.push( { mesh: mesh, body: body, material: material, delta: deltaPosition } );
		
		return body;
	}

	public function registerMeshesAsCompound(parts:Array<PhysicsCompoundBodyPart>, options:PhysicsBodyCreationOptions):Dynamic {
		/*var compoundShape = new Compound();

		for (var index = 0; index < parts.length; index++) {
			var mesh = parts[index].mesh;

			var shape = this.registerMesh(mesh, parts[index].impostor);

			if (index == 0) { // Parent
				compoundShape.addChild(shape, new CANNON.Vec3(0, 0, 0));
			} else {
				compoundShape.addChild(shape, new CANNON.Vec3(mesh.position.x, mesh.position.z, mesh.position.y));
			}
		}

		var initialMesh = parts[0].mesh;
		var body = this._createRigidBodyFromShape(compoundShape, initialMesh, options.mass, options.friction, options.restitution);

		body.parts = parts;

		return body;*/
		
		return null;
	}

	private function _unbindBody(body:cannonhx.objects.Body) {
		for (index in 0...this._registeredMeshes.length) {
			var registeredMesh = this._registeredMeshes[index];
			
			if (registeredMesh.body == body) {
				registeredMesh.body = null;
				registeredMesh.delta = 0;
			}
		}
	}

	public function unregisterMesh(mesh:AbstractMesh) {
		for (index in 0...this._registeredMeshes.length) {
			var registeredMesh = this._registeredMeshes[index];
			
			if (registeredMesh.mesh == mesh) {
				// Remove body
				if (registeredMesh.body != null) {
					this._world.removeBody(registeredMesh.body);
					this._unbindBody(registeredMesh.body);
				}
				
				this._registeredMeshes.splice(index, 1);
				return;
			}
		}
	}

	public function applyImpulse(mesh:AbstractMesh, force:Vector3, contactPoint:Vector3) {
		var worldPoint = new Vec3(contactPoint.x, contactPoint.z, contactPoint.y);
		var impulse = new Vec3(force.x, force.z, force.y);
		
		for (index in 0...this._registeredMeshes.length) {
			var registeredMesh = this._registeredMeshes[index];
			
			if (registeredMesh.mesh == mesh) {
				registeredMesh.body.applyImpulse(impulse, worldPoint);
				return;
			}
		}
	}

	public function updateBodyPosition(mesh:AbstractMesh) {
		for (index in 0...this._registeredMeshes.length) {
			var registeredMesh = this._registeredMeshes[index];
			if (registeredMesh.mesh == mesh || registeredMesh.mesh == mesh.parent) {
				var body = registeredMesh.body;
				
				var center = mesh.getBoundingInfo().boundingBox.center;
				body.position.set(center.x, center.z, center.y);
				
				body.quaternion.x = mesh.rotationQuaternion.x;
				body.quaternion.z = mesh.rotationQuaternion.y;
				body.quaternion.y = mesh.rotationQuaternion.z;
				body.quaternion.w = -mesh.rotationQuaternion.w;
				return;
			}
		}
	}

	public function createLink(mesh1:AbstractMesh, mesh2:AbstractMesh, pivot1:Vector3, pivot2:Vector3, ?options:Dynamic):Bool {
		var body1 = null;
		var body2 = null;
		for (index in 0...this._registeredMeshes.length) {
			var registeredMesh = this._registeredMeshes[index];
			
			if (registeredMesh.mesh == mesh1) {
				body1 = registeredMesh.body;
			} 
			else if (registeredMesh.mesh == mesh2) {
				body2 = registeredMesh.body;
			}
		}
		
		if (body1 == null || body2 == null) {
			return false;
		}
		
		var constraint = new PointToPointConstraint(body1, new Vec3(pivot1.x, pivot1.z, pivot1.y), body2, new Vec3(pivot2.x, pivot2.z, pivot2.y));
		this._world.addConstraint(constraint);
		
		return true;
	}

	public function dispose() {
		while (this._registeredMeshes.length > 0) {
			this.unregisterMesh(this._registeredMeshes[0].mesh);
		}
	}

	public function isSupported():Bool {
		return true;
	}
	
}
