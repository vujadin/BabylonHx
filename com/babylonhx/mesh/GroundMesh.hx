package com.babylonhx.mesh;

import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector4;
import com.babylonhx.culling.Ray;
import com.babylonhx.math.Tmp;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.GroundMesh') class GroundMesh extends Mesh {
	
	public var generateOctree:Bool = false;

	private var _worldInverse:Matrix = new Matrix();
	private var _heightQuads:Array<Dynamic>; // { slope: Vector2; facet1: Vector4; facet2: Vector4 } [];
	
	public var _subdivisionsX:Int;
	public var _subdivisionsY:Int;
	public var _width:Float;
	public var _height:Float;
	public var _minX:Float;
	public var _maxX:Float;
	public var _minZ:Float;
	public var _maxZ:Float;
	
	public var subdivisions(get, never):Int;
	public var subdivisionsX(get, never):Int;
	public var subdivisionsY(get, never):Int;
	
	
	public function new(name:String, scene:Scene) {
		super(name, scene);
	}
	
	override public function getClassName():String {
		return "GroundMesh";
	}  
	
	private function get_subdivisions():Int {
		return Std.int(Math.min(this._subdivisionsX, this._subdivisionsY));
	}
	
	private function get_subdivisionsX():Int {
		return _subdivisionsX;
	}
	
	private function get_subdivisionsY():Int {
		return _subdivisionsY;
	}

	public function optimize(chunksCount:Int, octreeBlocksSize:Int = 32) {
		this._subdivisionsX = chunksCount;
		this._subdivisionsY = chunksCount;
		this.subdivide(chunksCount);
		this.createOrUpdateSubmeshesOctree(octreeBlocksSize);
	}

	/**
	 * Returns a height (y) value in the Worl system :
	 * the ground altitude at the coordinates (x, z) expressed in the World system.
	 * Returns the ground y position if (x, z) are outside the ground surface.
	 */
	public function getHeightAtCoordinates(x:Float, z:Float):Float {
		var world = this.getWorldMatrix();
		var invMat = Tmp.matrix[5];
		world.invertToRef(invMat);
		var tmpVect = Tmp.vector3[8];
		Vector3.TransformCoordinatesFromFloatsToRef(x, 0.0, z, invMat, tmpVect); // transform x,z in the mesh local space
		x = tmpVect.x;
		z = tmpVect.z;
		if (x < this._minX || x > this._maxX || z < this._minZ || z > this._maxZ) {
			return this.position.y;
		}
		if (this._heightQuads == null || this._heightQuads.length == 0) {
			this._initHeightQuads();
			this._computeHeightQuads();
		}
		var facet = this._getFacetAt(x, z);
		var y = -(facet.x * x + facet.z * z + facet.w) / facet.y;
		// return y in the World system
		Vector3.TransformCoordinatesFromFloatsToRef(0.0, y, 0.0, world, tmpVect);
		return tmpVect.y;
	}
	
	/**
	 * Returns a normalized vector (Vector3) orthogonal to the ground
	 * at the ground coordinates (x, z) expressed in the World system.
	 * Returns Vector3(0, 1, 0) if (x, z) are outside the ground surface.
	 * Not pertinent if the ground is rotated.
	 */
	inline public function getNormalAtCoordinates(x:Float, z:Float):Vector3 {
		var normal = new Vector3(0, 1, 0);
		this.getNormalAtCoordinatesToRef(x, z, normal);		
		return normal;
	}
	
	/**
	 * Updates the Vector3 passed a reference with a normalized vector orthogonal to the ground
	 * at the ground coordinates (x, z) expressed in the World system.
	 * Doesn't uptade the reference Vector3 if (x, z) are outside the ground surface.
	 */
	inline public function getNormalAtCoordinatesToRef(x:Float, z:Float, ref:Vector3):GroundMesh {
		var world = this.getWorldMatrix();
		var tmpMat = Tmp.matrix[5];
		world.invertToRef(tmpMat);
		var tmpVect = Tmp.vector3[8];
		Vector3.TransformCoordinatesFromFloatsToRef(x, 0.0, z, tmpMat, tmpVect); // transform x,z in the mesh local space
		x = tmpVect.x;
		z = tmpVect.z;
		if (x < this._minX || x > this._maxX || z < this._minZ || z > this._maxZ) {
			return this;
		}
		if (this._heightQuads == null || this._heightQuads.length == 0) {
			this._initHeightQuads();
			this._computeHeightQuads();
		}
		var facet = this._getFacetAt(x, z);
		Vector3.TransformNormalFromFloatsToRef(facet.x, facet.y, facet.z, world, ref);
		return this;
	}
	
	/**
	* Force the heights to be recomputed for getHeightAtCoordinates() or getNormalAtCoordinates()
	* if the ground has been updated.
	* This can be used in the render loop
	*/
	inline public function updateCoordinateHeights():GroundMesh {
		if (this._heightQuads == null || this._heightQuads.length == 0) {
			this._initHeightQuads();
		}
		this._computeHeightQuads();
		return this;
	}
	
	// Returns the element "facet" from the heightQuads array relative to (x, z) local coordinates
	private function _getFacetAt(x:Float, z:Float):Vector4 {
		// retrieve col and row from x, z coordinates in the ground local system
		var col = Math.floor((x + this._maxX) * this._subdivisionsX / this._width);
		var row = Math.floor( -(z + this._maxZ) * this._subdivisionsY / this._height + this._subdivisionsY);
		var quad = this._heightQuads[row * this._subdivisionsX + col];
		var facet:Vector4 = null;
		if (z < quad.slope.x * x + quad.slope.y) {
			facet = quad.facet1;
		} 
		else {
			facet = quad.facet2;
		}
		
		return facet;
	}
	
	//  Creates and populates the heightMap array with "facet" elements :
	// a quad is two triangular facets separated by a slope, so a "facet" element is 1 slope + 2 facets
	// slope : Vector2(c, h) = 2D diagonal line equation setting appart two triangular facets in a quad : z = cx + h
	// facet1 : Vector4(a, b, c, d) = first facet 3D plane equation : ax + by + cz + d = 0
	// facet2 :  Vector4(a, b, c, d) = second facet 3D plane equation : ax + by + cz + d = 0
	private function _initHeightQuads():GroundMesh {
		this._heightQuads = [];
		for (row in 0...this._subdivisionsY) {
			for (col in 0...this._subdivisionsX) {
				var quad = { slope: Vector2.Zero(), facet1: new Vector4(0, 0, 0, 0), facet2: new Vector4(0, 0, 0, 0) };
				this._heightQuads[row * this._subdivisionsX + col] = quad;
			}
		}
		return this;
	}

	// Populates the heightMap array with "facet" elements :
	// a quad is two triangular facets separated by a slope, so a "facet" element is 1 slope + 2 facets
	// slope : Vector2(c, h) = 2D diagonal line equation setting appart two triangular facets in a quad : z = cx + h
	// facet1 : Vector4(a, b, c, d) = first facet 3D plane equation : ax + by + cz + d = 0
	// facet2 :  Vector4(a, b, c, d) = second facet 3D plane equation : ax + by + cz + d = 0
	private function _computeHeightQuads():GroundMesh {
		var positions = this.getVerticesData(VertexBuffer.PositionKind);
		var v1 = Tmp.vector3[0];
		var v2 = Tmp.vector3[1];
		var v3 = Tmp.vector3[2];
		var v4 = Tmp.vector3[3];
		var v1v2 = Tmp.vector3[4];
		var v1v3 = Tmp.vector3[5];
		var v1v4 = Tmp.vector3[6];
		var norm1 = Tmp.vector3[7];
		var norm2 = Tmp.vector3[8];
		var i = 0;
		var j = 0;
		var k = 0;
		var cd = 0.0;     // 2D slope coefficient : z = cd * x + h
		var h = 0.0;
		var d1 = 0.0;     // facet plane equation : ax + by + cz + d = 0
		var d2 = 0.0;
		
		for (row in 0...this._subdivisionsY) {
			for (col in 0...this._subdivisionsX) {
				i = Std.int(col * 3);
				j = Std.int(row * (this._subdivisionsX + 1) * 3);
				k = Std.int((row + 1) * (this._subdivisionsX + 1) * 3);
				v1.x = positions[j + i];
				v1.y = positions[j + i + 1];
				v1.z = positions[j + i + 2];
				v2.x = positions[j + i + 3];
				v2.y = positions[j + i + 4];
				v2.z = positions[j + i + 5];
				v3.x = positions[k + i];
				v3.y = positions[k + i + 1];
				v3.z = positions[k + i + 2];
				v4.x = positions[k + i + 3];
				v4.y = positions[k + i + 4];
				v4.z = positions[k + i + 5];
				
				// 2D slope V1V4
				cd = (v4.z - v1.z) / (v4.x - v1.x);
				h = v1.z - cd * v1.x;             // v1 belongs to the slope
				
				// facet equations :
				// we compute each facet normal vector
				// the equation of the facet plane is : norm.x * x + norm.y * y + norm.z * z + d = 0
				// we compute the value d by applying the equation to v1 which belongs to the plane
				// then we store the facet equation in a Vector4
				v2.subtractToRef(v1, v1v2);
				v3.subtractToRef(v1, v1v3);
				v4.subtractToRef(v1, v1v4);
				Vector3.CrossToRef(v1v4, v1v3, norm1);
				Vector3.CrossToRef(v1v2, v1v4, norm2);
				norm1.normalize();
				norm2.normalize();
				d1 = -(norm1.x * v1.x + norm1.y * v1.y + norm1.z * v1.z);
				d2 = -(norm2.x * v2.x + norm2.y * v2.y + norm2.z * v2.z);
				
				var quad = this._heightQuads[row * this._subdivisionsX + col];
				quad.slope.copyFromFloats(cd, h);
				quad.facet1.copyFromFloats(norm1.x, norm1.y, norm1.z, d1);
				quad.facet2.copyFromFloats(norm2.x, norm2.y, norm2.z, d2);
			}
		}
		
		return this;
	}
	
	override public function serialize(serializationObject:Dynamic) {
		super.serialize(serializationObject);
		serializationObject.subdivisionsX = this._subdivisionsX;
		serializationObject.subdivisionsY = this._subdivisionsY;
		
		serializationObject.minX = this._minX;
		serializationObject.maxX = this._maxX;
		
		serializationObject.minZ = this._minZ;
		serializationObject.maxZ = this._maxZ;
		
		serializationObject.width = this._width;
		serializationObject.height = this._height;
	}

	public static function Parse(parsedMesh:Dynamic, scene:Scene):GroundMesh {
		var result = new GroundMesh(parsedMesh.name, scene);
		
		result._subdivisionsX = parsedMesh.subdivisionsX != null ? parsedMesh.subdivisionsX : 1;
		result._subdivisionsY = parsedMesh.subdivisionsY != null ? parsedMesh.subdivisionsY : 1;
		
		result._minX = parsedMesh.minX;
		result._maxX = parsedMesh.maxX;
		
		result._minZ = parsedMesh.minZ;
		result._maxZ = parsedMesh.maxZ;
		
		result._width = parsedMesh.width;
		result._height = parsedMesh.height;
		
		return result;
	}
	
}
