package com.babylonhx.extensions.manipulationhelper;

import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Plane;
import com.babylonhx.math.Quaternion;
import com.babylonhx.culling.Ray;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.events.PointerEventTypes;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:enum 
abstract ManFlags(Int) {
	var DragMode = 0x01;
	var FirstHit = 0x02;
	var Plane2 = 0x04;
	var Exiting = 0x08;
}
 

/**
 * This class is used to manipulated a single node.
 * Right now only node of type AbstractMesh is support.
 * In the future, manipulation on multiple selection could be possible.
 *
 * A manipulation start when left clicking and moving the mouse. It can be cancelled if the right mouse button is clicked before releasing the left one (this feature is only possible if noPreventContextMenu is false).
 * Per default translation is peformed when manipulating the arrow (axis or cone) or the plane anchor. If you press the shift key it will switch to rotation manipulation. The Shift key can be toggle while manipulating, the current manipulation is accept and a new one starts.
 *
 * You can set the rotation/translationStep (in radian) to enable snapping.
 *
 * The current implementation of this class creates a radix with all the features selected.
 */
class ManipulatorInteractionHelper {
	
	private var _flags:ManFlags;
	private var _firstMousePos:Vector2;
	private var _prevMousePos:Vector2;
	private var _shiftKeyState:Bool;
	private var _pos:Vector3;
	private var _right:Vector3;
	private var _up:Vector3;
	private var _view:Vector3;
	private var _oldPos:Vector3;
	private var _prevHit:Vector3;
	private var _firstTransform:Matrix;
	private var _scene:Scene;
	private var _manipulatedMode:RadixFeatures;
	private var _rotationFactor:Float;
	private var _manipulatedNode:Node;
	private var _radix:Radix;

	/**
	 * Rotation Step in Radian to perform rotation with the given step instead of a smooth one.
	 * Set back to null/undefined to disable
	 */
	public var rotationStep:Float;

	/**
	 * Translation Step in World unit to perform translation at the given step instread of a smooth one.
	 * Set back to null/undefined to disable
	 */
	public var translationStep:Float;

	/**
	 * Set to true if you want the context menu to be displayed while manipulating. The manipulation cancel feature (which is triggered by a right click) won't work in this case. Default value is false (context menu is not showed when right clicking during manipulation) and this should fit most of the cases.
	 */
	public var noPreventContextMenu:Bool;

	/**
	 * Attach a node to manipulate. Right now, only manipulation on a single node is supported, but this api will allow manipulation on a multiple selection in the future.
	 * @param node
	 */
	public function attachManipulatedNode(node:Node) {
		this._manipulatedNode = node;
		this._radix.show();
	}

	/**
	 * Detach the node to manipulate. Right now, only manipulation on a single node is supported, but this api will allow manipulation on a multiple selection in the future.
	 */
	public function detachManipulatedNode(node:Node) {
		this._manipulatedNode = null;
		this._radix.hide();
	}

	
	public function new(scene:Scene) {
		this.noPreventContextMenu = false;
		this._flags = 0;
		this._rotationFactor = 1;
		this._scene = scene;
		this._radix = new Radix(scene);
		this._shiftKeyState = false;
		
		this._scene.onBeforeRenderObservable.add(function(e, s) { this.onBeforeRender(e, s); });
		this._scene.onPointerObservable.add(function(e, s) { this.onPointer(e, s); }, -1, true);
	}

	private function onBeforeRender(scene:Scene, state:EventState) {
		this.renderManipulator();
	}

	private function onPointer(e:PointerInfo, state:EventState) {
		if (this._manipulatedNode == null) {
			return;
		}
		
		var rayPos = this.getRayPosition(e.event);
		var shiftKeyState = e.event.shiftKey;
		
		// Detect Modifier Key changes for shift while manipulating: commit and start a new manipulation
		if (this.hasManFlags(ManFlags.DragMode) && shiftKeyState != this._shiftKeyState) {
			this.beginDrag(rayPos, e.event);
		}
		
		// Mouse move
		if (e.type == PointerEventTypes.POINTERMOVE) {
			// Right button release while left is down => cancel the manipulation. only processed when the context menu is not showed during manipulation
			if (!this.noPreventContextMenu && e.event.button == 2 && e.event.buttons == 1) {
				this.setManipulatedNodeWorldMatrix(this._firstTransform);
				this.setManFlags(ManFlags.Exiting);
			}			
			else if (this.hasManFlags(ManFlags.DragMode) && !this.hasManFlags(ManFlags.Exiting)) {
				state.skipNextObservers = true;
				
				if (shiftKeyState || this.hasManipulatedMode(RadixFeatures.Rotations)) {
					this.doRot(rayPos);
				} 
				else {
					this.doPos(rayPos);
				}
			} 
			else {
				this._radix.highlighted = this._radix.intersect(rayPos);
			}
		}		
		// Left button down
		else if (e.type == PointerEventTypes.POINTERDOWN && e.event.button == 0) {
			this._manipulatedMode = this._radix.intersect(rayPos);
			
			if (this._manipulatedMode != RadixFeatures.None) {
				state.skipNextObservers = true;
				this.beginDrag(rayPos, e.event);
				
				if (this.hasManipulatedMode(RadixFeatures.Rotations)) {
					this.doRot(rayPos);
				} 
				else {
					this.doPos(rayPos);
				}
			}
		}
		else if (e.type == PointerEventTypes.POINTERUP) {
			if (this.hasManFlags(ManFlags.DragMode)) {
				state.skipNextObservers = true;
			}
			this._radix.highlighted = this._radix.intersect(rayPos);
			
			// Left up: end manipulation
			if (e.event.button == 0) {
				this.endDragMode();
			}
		}
	}

	private function beginDrag(rayPos:Vector2, event:PointerEvent) {
		this._firstMousePos = rayPos;
		this._prevMousePos = this._firstMousePos.clone();
		this._shiftKeyState = event.shiftKey;
		
		var mtx = this.getManipulatedNodeWorldMatrix();
		this._pos = mtx.getTranslation();
		this._right = mtx.getRow(0).toVector3();
		this._up = mtx.getRow(1).toVector3();
		this._view = mtx.getRow(2).toVector3();
		
		this._oldPos = this._pos.clone();
		this._firstTransform = mtx.clone();
		this._flags |= ManFlags.FirstHit | ManFlags.DragMode;
	}

	private function endDragMode() {
		this.clearManFlags(ManFlags.DragMode | ManFlags.Exiting);
	}

	private function doRot(rayPos:Vector2) {
		if (this.hasManFlags(ManFlags.FirstHit)) {
			this.clearManFlags(ManFlags.FirstHit);
			return;
		}
		
		var dx = rayPos.x - this._prevMousePos.x;
		var dy = rayPos.y - this._prevMousePos.y;
		
		var cr = this._scene.getEngine().getRenderingCanvasClientRect();
		
		var ax = (dx / cr.width) * Math.PI * 2 * this._rotationFactor;
		var ay = (dy / cr.height) * Math.PI * 2 * this._rotationFactor;
		
		if (this.rotationStep != 0) {
			var rem = ax % this.rotationStep;
			ax -= rem;
			
			rem = ay % this.rotationStep;
			ay -= rem;
		}
		
		var mtx = Matrix.Identity();
		
		if (this.hasManipulatedMode(RadixFeatures.ArrowX | RadixFeatures.RotationX)) {
			mtx = Matrix.RotationX(ay);
		}
		else if (this.hasManipulatedMode(RadixFeatures.ArrowY | RadixFeatures.RotationY)) {
			mtx = Matrix.RotationY(ay);
		}
		else if (this.hasManipulatedMode(RadixFeatures.ArrowZ | RadixFeatures.RotationZ)) {
			mtx = Matrix.RotationZ(ay);
		}
		else {
			if (this.hasManipulatedMode(/*RadixFeatures.CenterSquare |*/ RadixFeatures.PlaneSelectionXY | RadixFeatures.PlaneSelectionXZ)) {
				mtx = mtx.multiply(Matrix.RotationX(ay));
			}
			
			if (this.hasManipulatedMode(RadixFeatures.PlaneSelectionXY | RadixFeatures.PlaneSelectionYZ)) {
				mtx = mtx.multiply(Matrix.RotationY(ax));
			}
			
			if (this.hasManipulatedMode(RadixFeatures.PlaneSelectionXZ)) {
				mtx = mtx.multiply(Matrix.RotationZ(ay));
			}
			
			if (this.hasManipulatedMode(/*RadixFeatures.CenterSquare |*/ RadixFeatures.PlaneSelectionXZ)) {
				mtx = mtx.multiply(Matrix.RotationZ(ax));
			}
		}
		
		var tmtx = mtx.multiply(this._firstTransform);
		this.setManipulatedNodeWorldMatrix(tmtx);
	}

	private function doPos(rayPos:Vector2) {
		var v = Vector3.Zero();
		var ray = this._scene.createPickingRay(rayPos.x, rayPos.y, Matrix.Identity(), this._scene.activeCamera);
		
		if (this.hasManipulatedMode(RadixFeatures.PlaneSelectionXY | RadixFeatures.PlaneSelectionXZ | RadixFeatures.PlaneSelectionYZ)) {
			var pl0:Plane = null;
			var hit:Vector3 = null;
			
			if (this.hasManipulatedMode(RadixFeatures.PlaneSelectionXY)) {
				pl0 = Plane.FromPoints(this._pos, this._pos.add(this._right), this._pos.add(this._up));
			}
			else if (this.hasManipulatedMode(RadixFeatures.PlaneSelectionXZ)) {
				pl0 = Plane.FromPoints(this._pos, this._pos.add(this._right), this._pos.add(this._view));
			}
			else if (this.hasManipulatedMode(RadixFeatures.PlaneSelectionYZ)) {
				pl0 = Plane.FromPoints(this._pos, this._pos.add(this._up), this._pos.add(this._view));
			}
			else {
				// TODO Exception
			}
			
			var clip = 0.06;
			
			//Check if the plane is too parallel to the ray
			if (Math.abs(Vector3.Dot(pl0.normal, ray.direction)) < clip) {
				return;
			}
			
			//Make the intersection
			var distance = ray.intersectsPlane(pl0);
			hit = ManipulatorInteractionHelper.ComputeRayHit(ray, distance);
			
			//Check if it's the first call
			if (this.hasManFlags(ManFlags.FirstHit)) {
				this._flags &= ~ManFlags.FirstHit;
				this._prevHit = hit;
				return;
			}
			
			//Compute the vector
			v = hit.subtract(this._prevHit);
		}
		else if ((this._manipulatedMode & (RadixFeatures.ArrowX | RadixFeatures.ArrowY | RadixFeatures.ArrowZ)) !== 0) {
			var pl0:Plane = null;
			var pl1:Plane = null;
			var hit:Vector3 = null;
			var s:Float = 0;
			
			if (this.hasManFlags(ManFlags.FirstHit)) {
				var res = this.setupIntersectionPlanes(this._manipulatedMode);
				pl0 = res.p0;
				pl1 = res.p1;
				
				if (Math.abs(Vector3.Dot(pl0.normal, ray.direction)) > Math.abs(Vector3.Dot(pl1.normal, ray.direction))) {
					var distance = ray.intersectsPlane(pl0);
					hit = ManipulatorInteractionHelper.ComputeRayHit(ray, distance);
					let number = ~ManFlags.Plane2;
					this._flags &= number;
				}
				else {
					var distance = ray.intersectsPlane(pl1);
					hit = ManipulatorInteractionHelper.ComputeRayHit(ray, distance);
					this._flags |= ManFlags.Plane2;
				}
				
				this._flags &= ~ManFlags.FirstHit;
				this._prevHit = hit;
				return;
			}
			else {
				var axis:Vector3 = null;
				var res = this.setupIntersectionPlane(this._manipulatedMode, this.hasManFlags(ManFlags.Plane2));
				pl0 = res.plane;
				axis = res.axis;
				
				let distance = ray.intersectsPlane(pl0);
				hit = ManipulatorInteractionHelper.ComputeRayHit(ray, distance);
				v = hit.subtract(this._prevHit);
				s = Vector3.Dot(axis, v);
				v = axis.multiplyByFloats(s, s, s);
			}
		}
		
		if (this.translationStep != 0) {
			v.x -= v.x % this.translationStep;
			v.y -= v.y % this.translationStep;
			v.z -= v.z % this.translationStep;
		}
		
		var mtx = this._firstTransform.clone();
		mtx.setTranslation(mtx.getTranslation().add(v));
		this._pos = mtx.getTranslation();
		
		this.setManipulatedNodeWorldMatrix(mtx);
	}

	private function hasManipulatedMode(value:RadixFeatures):Bool {
		return (this._manipulatedMode & value) != 0;
	}

	private function hasManFlags(value:ManFlags):Bool {
		return (this._flags & value) != 0;
	}

	private function clearManFlags(values:ManFlags):ManFlags {
		this._flags &= ~values;
		return this._flags;
	}

	private function setManFlags(values:ManFlags):ManFlags {
		this._flags |= values;
		return this._flags;
	}

	private static function ComputeRayHit(ray:Ray, distance:Float): Vector3 {
		return ray.origin.add(ray.direction.multiplyByFloats(distance, distance, distance));
	}

	private function setManipulatedNodeWorldMatrix(mtx:Matrix) {
		if (this._manipulatedNode == null) {
			return;
		}
		
		if (Std.is(this._manipulatedNode, AbstractMesh)) {
			var mesh:AbstractMesh = cast this._manipulatedNode;
			
			if (mesh.parent != null) {
				mtx = mtx.multiply(mesh.parent.getWorldMatrix().clone().invert());
			}
			
			var pos = Vector3.Zero();
			var scale = Vector3.Zero();
			var rot = new Quaternion();
			mtx.decompose(scale, rot, pos);
			mesh.position = pos;
			mesh.rotationQuaternion = rot;
			mesh.scaling = scale;
		}          
	}        

	private function getManipulatedNodeWorldMatrix():Matrix {
		if (this._manipulatedNode == null) {
			return null;
		}
		
		if (Std.is(this._manipulatedNode, AbstractMesh)) {
			return untyped this._manipulatedNode.getWorldMatrix();
		}
	}

	private function setupIntersectionPlane(mode:RadixFeatures, plane2:Bool):Dynamic {
		var res = this.setupIntersectionPlanes(mode);
		
		var pl = plane2 ? res.p1 : res.p0;
		var axis:Vector3 = null;
		
		switch (mode) {
			case RadixFeatures.ArrowX:
				axis = this._right;
				
			case RadixFeatures.ArrowY:
				axis = this._up;
				
			case RadixFeatures.ArrowZ:
				axis = this._view;
				
			default:
				axis = Vector3.Zero();
				
		}
		
		return { plane: pl, axis: axis };
	}

	private function setupIntersectionPlanes(mode:RadixFeatures):Dynamic {
		var p0:Plane = null;
		var	p1:Plane = null;

		switch (mode) {
			case RadixFeatures.ArrowX:
				p0 = Plane.FromPoints(this._pos, this._pos.add(this._view), this._pos.add(this._right));
				p1 = Plane.FromPoints(this._pos, this._pos.add(this._right), this._pos.add(this._up));
				
			case RadixFeatures.ArrowY:
				p0 = Plane.FromPoints(this._pos, this._pos.add(this._up), this._pos.add(this._right));
				p1 = Plane.FromPoints(this._pos, this._pos.add(this._up), this._pos.add(this._view));
				
			case RadixFeatures.ArrowZ:
				p0 = Plane.FromPoints(this._pos, this._pos.add(this._view), this._pos.add(this._right));
				p1 = Plane.FromPoints(this._pos, this._pos.add(this._view), this._pos.add(this._up));
		}
		
		return { p0: p0, p1: p1 };
	}

	private function getRayPosition(event:MouseEvent):Vector2 {
		var canvasRect = this._scene.getEngine().getRenderingCanvasClientRect();
		
		var x = event.clientX - canvasRect.left;
		var y = event.clientY - canvasRect.top;
		
		return new Vector2(x, y);
	}

	private function renderManipulator() {
		if (this._manipulatedNode == null) {
			return;
		}
		
		if (Std.is(this._manipulatedNode, AbstractMesh)) {
			var mesh:AbstractMesh = cast this._manipulatedNode;
			var worldMtx = mesh.getWorldMatrix();
			var l = Vector3.Distance(this._scene.activeCamera.position, worldMtx.getTranslation());
			var vpWidth = this._scene.getEngine().getRenderWidth();
			var s = this.fromScreenToWorld(vpWidth / 100, l) * 20;
			var scale = Vector3.Zero();
			var position = Vector3.Zero();
			var rotation = Quaternion.Identity();
			
			var res = Matrix.Scaling(s, s, s).multiply(worldMtx);
			
			res.decompose(scale, rotation, position);
			
			this._radix.setWorld(position, rotation, scale);
		}
	}

	private function fromScreenToWorld(l:Float, z:Float):Float {
		var camera = this._scene.activeCamera;
		var r0 = this._scene.createPickingRay(0, 0, Matrix.Identity(), camera, true);
		var r1 = this._scene.createPickingRay(l, 0, Matrix.Identity(), camera, true);
		
		var p0 = ManipulatorInteractionHelper.evalPosition(r0, z);
		var p1 = ManipulatorInteractionHelper.evalPosition(r1, z);
		
		return p1.x - p0.x;
	}

	inline private static function evalPosition(ray:Ray, u:Float):Vector3 {
		return ray.origin.add(ray.direction.multiplyByFloats(u, u, u));
	}
	
}
