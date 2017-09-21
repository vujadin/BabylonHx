package com.babylonhx.mesh.dynamicterrain;

import com.babylonhx.cameras.Camera;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.utils.Image;
import com.babylonhx.tools.Tools;

import lime.utils.Int32Array;
import lime.utils.Float32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
class DynamicTerrain {

	public var name:String;

	private var _terrainSub:Int;                    	// terrain number of subdivisions per axis
	private var _mapData:Float32Array;      			// data of the map
	private var _terrainIdx:Int;                    	// actual terrain vertex number per axis
	private var _mapSubX:Int;                       	// map number of subdivisions on X axis
	private var _mapSubZ:Int;                       	// map number of subdivisions on Z axis
	private var _mapUVs:Float32Array;       			// UV data of the map
	private var _mapColors:Float32Array;    			// Color data of the map
	private var _mapNormals:Float32Array;   			// Normal data of the map
	private var _scene:Scene;                           // current scene
	private var _subToleranceX:Int = 1;		            // how many cells flought over thy the camera on the terrain x axis before update
	private var _subToleranceZ:Int = 1;	                // how many cells flought over thy the camera on the terrain z axis before update
	private var _LODLimits:Array<Int> = [];             // array of LOD limits
	private var _initialLOD:Int = 1;	                // initial LOD value (integer > 0)
	private var _LODValue:Int = 1;	                    // current LOD value : initial + camera correction
	private var _cameraLODCorrection:Int = 0;	        // LOD correction (integer) according to the camera altitude
	private var _oldCorrection:Int = 0;                 // former correction
	private var _terrainCamera:Camera;                  // camera linked to the terrain
	private var _indices:Int32Array;
	private var _positions:Float32Array;
	private var _normals:Float32Array;
	private var _colors:Float32Array;
	private var _uvs:Float32Array;
	private var _deltaX:Float = 0.0;                    // camera / terrain x position delta
	private var _deltaZ:Float = 0.0;                    // camera-/ terrain z position delta
	private var _signX:Int = 0;                     	// x delta sign
	private var _signZ:INt = 0;                     	// z delta sign
	private var _deltaSubX:Int = 0;                 	// map x subdivision delta 
	private var _deltaSubZ:Int = 0;                 	// map z subdivision delta 
	private var _mapShiftX:Float = 0.0;                 // x shift in world space
	private var _mapShiftZ:Float = 0.0;                 // z shift in world space
	private var _mapFlgtNb:Int = 0;                     // tmp number of map cells flought over by the camera in the delta shift
	private var _needsUpdate:Bool = false;              // boolean : the ribbon needs to be recomputed
	private var _updateLOD:Bool = false;                // boolean : ribbon recomputation + LOD change
	private var _updateForced:Bool = false;             // boolean : forced ribbon recomputation
	private var _refreshEveryFrame:Bool = false;        // boolean : to force the terrain computation every frame
	private var _useCustomVertexFunction:Bool = false;  // boolean : to allow the call to updateVertex()
	private var _computeNormals:Bool = false;           // boolean : to skip or not the normal computation
	private var _datamap:Bool = false;                  // boolean : true if an data map is passed as parameter
	private var _uvmap:Bool = false;                    // boolean : true if an UV map is passed as parameter
	private var _colormap:Bool = false;                 // boolean : true if an color map is passed as parameter
	private var _vertex:Dynamic = {                     // current vertex object passed to the user custom function
		position: Vector3.Zero(),                       // vertex position in the terrain space (Vector3)
		uvs: Vector2.Zero(),                            // vertex uv
		color: new Color4(1.0, 1.0, 1.0, 1.0),          // vertex color (Color4)
		lodX: 1,                                        // vertex LOD value on X axis
		lodZ: 1,                                        // vertex LOD value on Z axis
		worldPosition: Vector3.Zero(),                  // vertex World position
		mapIndex: 0                                     // current map index
	};
	private var _averageSubSizeX:Float = 0.0;           // map cell average x size
	private var _averageSubSizeZ:Float = 0.0;           // map cell average z size
	private var _terrainSizeX:Float = 0.0;              // terrain x size
	private var _terrainSizeZ:Float = 0.0;              // terrain y size
	private var _terrainHalfSizeX:Float = 0.0;
	private var _terrainHalfSizeZ:Float = 0.0;
	private var _centerWorld:Vector3 = Vector3.Zero();  // terrain world center position
	private var _centerLocal:Vector3 = Vector3.Zero();  // terrain local center position
	private var _mapSizeX:Float = 0.0;                  // map x size
	private var _mapSizeZ:Float = 0.0;                  // map z size
	private var _terrain:Mesh;                          // reference to the ribbon
	private var _isAlwaysVisible:Bool = false;          // is the terrain mesh always selected for rendering
	private var _precomputeNormalsFromMap:Bool = false; // if the normals must be precomputed from the map data when assigning a new map to the existing terrain
	// tmp vectors
	private static var _v1:Vector3 = Vector3.Zero();
	private static var _v2:Vector3 = Vector3.Zero();
	private static var _v3:Vector3 = Vector3.Zero();
	private static var _v4:Vector3 = Vector3.Zero();
	private static var _vAvB:Vector3 = Vector3.Zero();
	private static var _vAvC:Vector3 = Vector3.Zero();
	private static var _norm:Vector3 = Vector3.Zero();
	private var _bbMin:Vector3 = Vector3.Zero();
	private var _bbMax:Vector3 = Vector3.Zero();

	/**
	 * constructor
	 * @param name 
	 * @param options 
	 * @param scene 
	 * @param {*} mapData the array of the map 3D data : x, y, z successive float values
	 * @param {*} mapSubX the data map number of x subdivisions : integer
	 * @param {*} mapSubZ the data map number of z subdivisions : integer
	 * @param {*} terrainSub the wanted terrain number of subdivisions : integer, multiple of 2.
	 * @param {*} mapUVs the array of the map UV data (optional) : u,v successive values, each between 0 and 1.
	 * @param {*} mapColors the array of the map Color data (optional) : x, y, z successive float values.
	 * @param {*} mapNormals the array of the map normal data (optional) : r,g,b successive values, each between 0 and 1.
	 * @param {*} invertSide boolean, to invert the terrain mesh upside down. Default false.
	 * @param {*} camera the camera to link the terrain to. Optional, by default the scene active camera
	 */
	public function new(name:String, options:Dynamic, scene:Scene) {		
		this.name = name;
		this._terrainSub = options.terrainSub != null ? options.terrainSub : 60;
		this._mapData = options.mapData; 
		this._terrainIdx = this._terrainSub + 1;
		this._mapSubX = options.mapSubX != null ? options.mapSubX : this._terrainIdx;
		this._mapSubZ = options.mapSubZ != null ? options.mapSubZ : this._terrainIdx;
		this._mapUVs = options.mapUVs;            // if not defined, it will be still populated by default values
		this._mapColors = options.mapColors;
		this._scene = scene;
		this._terrainCamera = options.camera != null ? options.camera : scene.activeCamera;
		
		// initialize the map arrays if not passed as parameters
		this._datamap = (this._mapData != null) ? true : false;
		this._uvmap = (this._mapUVs != null) ? true : false;
		this._colormap = (this._mapColors != null) ? true : false;
		this._mapData = (this._datamap) ? this._mapData : new Float32Array(this._terrainIdx * this._terrainIdx * 3);
		this._mapUVs = (this._uvmap) ? this._mapUVs : new Float32Array(this._terrainIdx * this._terrainIdx * 2);
		if (this._datamap) {
			this._mapNormals = options.mapNormals != null ? options.mapNormals : new Float32Array(this._mapSubX * this._mapSubZ * 3);
		} 
		else {
			this._mapNormals = new Float32Array(this._terrainIdx * this._terrainIdx * 3);
		}
		
		// Ribbon creation
		var index:Int = 0;                                          // current vertex index in the map array
		var posIndex:Int = 0;                                       // current position (coords) index in the map array
		var colIndex:Int = 0;                                       // current color index in the color array
		var uvIndex:Int = 0;                                        // current uv index in the uv array
		var color:Color4;                                           // current color
		var uv:Vector2;                                             // current uv
		var terIndex:Int = 0;                                       // current index in the terrain array
		var y:Float = 0.0;                                          // current y coordinate
		var terrainPath:Array<Vector3>;                             // current path
		var u:Float = 0.0;                                          // current u of UV
		var v:Float = 0.0;                                          // current v of UV
		var lg:Int = this._terrainIdx + 1;                          // augmented length for the UV to finish before
		var terrainData:Array<Array<Vector3>> = [];
		var terrainColor:Array<Float> = [];
		var terrainUV:Array<Float> = [];
		for (j in 0...this._terrainSub + 1) {
			terrainPath = [];
			for (i in 0...this._terrainSub + 1) {
				index = this._mod(j * 3, this._mapSubZ) * this._mapSubX + this._mod(i * 3, this._mapSubX);
				posIndex = index * 3;
				colIndex = index * 3;
				uvIndex = index * 2;
				terIndex = j * this._terrainIdx + i;
				// geometry
				if (this._datamap) {
					y = this._mapData[posIndex + 1];
				} 
				else {
					y = 0.0;
					this._mapData[3 * terIndex] = i;
					this._mapData[3 * terIndex + 1] = y;
					this._mapData[3 * terIndex + 2] = j;
				}
				terrainPath.push(new Vector3(i, y, j));
				// color
				if (this._colormap) {
					color = new Color4(this._mapColors[colIndex], this._mapColors[colIndex + 1], this._mapColors[colIndex + 2], 1.0);
				}
				else {
					color = new Color4(1.0, 1.0, 1.0, 1.0);
				}
				terrainColor.push(color);
				// uvs
				if (this._uvmap) {
					uv = new Vector2(this._mapUVs[uvIndex], this._mapUVs[uvIndex + 1]);
				}          
				else {
					u = 1.0 - Math.abs(1.0 - 2.0 * i / lg);
					v = 1.0 - Math.abs(1.0 - 2.0 * j / lg);
					this._mapUVs[2 * terIndex] = u;
					this._mapUVs[2 * terIndex + 1] = v;
					uv = new Vector2(u, v);
				}
				terrainUV.push(uv);
			}
			terrainData.push(terrainPath);
		}
		
		this._mapSizeX = Math.abs(this._mapData[(this._mapSubX - 1) * 3] - this._mapData[0]);
		this._mapSizeZ = Math.abs(this._mapData[(this._mapSubZ - 1) * this._mapSubX * 3 + 2] - this._mapData[2]);
		this._averageSubSizeX = this._mapSizeX / this._mapSubX;
		this._averageSubSizeZ = this._mapSizeZ / this._mapSubZ;
		var ribbonOptions = {
			pathArray: terrainData,
			sideOrientation: (options.invertSide == true) ? Mesh.FRONTSIDE : Mesh.BACKSIDE,
			colors: terrainColor,
			uvs: terrainUV,
			updatable: true
		};
		this._terrain = MeshBuilder.CreateRibbon("terrain", ribbonOptions, this._scene);
		this._indices = this._terrain.getIndices();
		this._positions = this._terrain.getVerticesData(VertexBuffer.PositionKind);
		this._normals = this._terrain.getVerticesData(VertexBuffer.NormalKind);
		this._uvs = this._terrain.getVerticesData(VertexBuffer.UVKind);
		this._colors = this._terrain.getVerticesData(VertexBuffer.ColorKind);
		this.computeNormalsFromMap();
		
		// update it immediatly and register the update callback function in the render loop
		this.update(true);
		this._terrain.position.x = this._terrainCamera.globalPosition.x - this._terrainHalfSizeX;
		this._terrain.position.z = this._terrainCamera.globalPosition.z - this._terrainHalfSizeZ;
		// initialize deltaSub to make
		var deltaNbSubX = (this._terrain.position.x - this._mapData[0]) / this._averageSubSizeX;
		var deltaNbSubZ = (this._terrain.position.z - this._mapData[2]) / this._averageSubSizeZ
		this._deltaSubX = (deltaNbSubX > 0) ? Math.floor(deltaNbSubX) : Math.ceil(deltaNbSubX);
		this._deltaSubZ = (deltaNbSubZ > 0) ? Math.floor(deltaNbSubZ) : Math.ceil(deltaNbSubZ);
		this._scene.registerBeforeRender(function(_, _) {
			this.beforeUpdate(this._refreshEveryFrame);
			this.update(this._refreshEveryFrame);
			this.afterUpdate(this._refreshEveryFrame);
		});  
		this.update(true); // recompute everything once the initial deltas are calculated       
	}

	/**
	 * Updates the terrain position and shape according to the camera position.
	 * `force` :Bool, forces the terrain update even if no camera position change.
	 * Returns the terrain.
	 */
	public function update(force:Bool):DynamicTerrain {	
		this._needsUpdate = false;
		this._updateLOD = false;
		this._updateForced = (force) ? true : false;
		this._deltaX = this._terrainHalfSizeX + this._terrain.position.x - this._terrainCamera.globalPosition.x;
		this._deltaZ = this._terrainHalfSizeZ + this._terrain.position.z - this._terrainCamera.globalPosition.z;
		this._oldCorrection = this._cameraLODCorrection;
		this._cameraLODCorrection = (this.updateCameraLOD(this._terrainCamera));
		this._updateLOD = (this._oldCorrection != this._cameraLODCorrection);
		
		this._LODValue = this._initialLOD + this._cameraLODCorrection;
		this._LODValue = (this._LODValue > 0) ? this._LODValue : 1;
		this._mapShiftX = this._averageSubSizeX * this._subToleranceX * this._LODValue;
		this._mapShiftZ = this._averageSubSizeZ * this._subToleranceZ * this._LODValue;
		
		if (Math.abs(this._deltaX) > this._mapShiftX) {
			this._signX = (this._deltaX > 0.0) ? -1 : 1;
			this._mapFlgtNb = Math.abs(this._deltaX / this._mapShiftX);
			this._terrain.position.x += this._mapShiftX * this._signX * this._mapFlgtNb;
			this._deltaSubX += (this._subToleranceX * this._signX * this._LODValue * this._mapFlgtNb);
			this._needsUpdate = true;
		}
		if (Math.abs(this._deltaZ) > this._mapShiftZ) {
			this._signZ = (this._deltaZ > 0.0) ? -1 : 1;
			this._mapFlgtNb = Math.abs(this._deltaZ / this._mapShiftZ);
			this._terrain.position.z += this._mapShiftZ * this._signZ * this._mapFlgtNb;
			this._deltaSubZ += (this._subToleranceZ * this._signZ * this._LODValue * this._mapFlgtNb);
			this._needsUpdate = true;
		}
		if (this._needsUpdate || this._updateLOD || this._updateForced) {
			this._deltaSubX = this._mod(this._deltaSubX, this._mapSubX);
			this._deltaSubZ = this._mod(this._deltaSubZ, this._mapSubZ); 
			this._updateTerrain();
		}
		this._updateForced = false;
		this._updateLOD = false;
		this._centerLocal.x = this._terrainHalfSizeX;
		this._centerLocal.y = this._terrain.position.y;
		this._centerLocal.z = this._terrainHalfSizeZ;
		this._centerWorld.x = this._terrain.position.x + this._terrainHalfSizeX;
		this._centerWorld.y = this._terrain.position.y;
		this._centerWorld.z = this._terrain.position.z + this._terrainHalfSizeZ; 
		return this;
	}

	// private : updates the underlying ribbon
	private function _updateTerrain() {
		var stepJ:Int = 0;
		var stepI:Int = 0;
		var LODLimitDown:Int = 0;
		var LODLimitUp:Int = 0;
		var LODValue:Int = this._LODValue;
		var lodI:Int = LODValue;
		var lodJ:Int = LODValue;
		var l:Int = 0;
		var index:Int = 0;          // current vertex index in the map data array
		var posIndex:Int = 0;       // current position index in the map data array
		var colIndex:Int = 0;       // current index in the map color array
		var uvIndex:Int = 0;        // current index in the map uv array
		var terIndex:Int = 0;       // current vertex index in the terrain map array when used as a data map
		var ribbonInd:Int = 0;      // current ribbon vertex index
		var ribbonPosInd:Int = 0;   // current ribbon position index (same than normal index)
		var ribbonUVInd:Int = 0;    // current ribbon UV index
		var ribbonColInd:Int = 0;   // current ribbon color index
		var ribbonPosInd1:Int = 0;
		var ribbonPosInd2:Int = 0;
		var ribbonPosInd3:Int = 0;
		// note : all the indexes are explicitly set as integers for the js optimizer (store them all in the stack)
		
		if (this._updateLOD || this._updateForced) {
			this.updateTerrainSize();
		}
		Vector3.FromFloatsToRef(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, this._bbMin); 
		Vector3.FromFloatsToRef(Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY, this._bbMax);
		
		for (j in 0...this._terrainSub + 1) {
			// LOD Z
			LODValue = this._LODValue;
			for (l in 0...this._LODLimits.length) {
				LODLimitDown = this._LODLimits[l];
				LODLimitUp = this._terrainSub - LODLimitDown - 1; 
				if (j < LODLimitDown || j > LODLimitUp) {
					LODValue = l + 1 + this._LODValue;
				}
				lodJ = LODValue; 
			}
			
			for (i in 0...this._terrainSub + 1) {
				// LOD X
				LODValue = this._LODValue;
				for (l in 0...this._LODLimits.length) {
					LODLimitDown = this._LODLimits[l];
					LODLimitUp = this._terrainSub - LODLimitDown - 1; 
					if (i < LODLimitDown || i > LODLimitUp) {
						LODValue = l + 1 + this._LODValue;
					} 
					lodI = LODValue;
				}
				
				// map current index
				index = this._mod(this._deltaSubZ + stepJ, this._mapSubZ) * this._mapSubX + this._mod(this._deltaSubX + stepI, this._mapSubX);
				terIndex = this._mod(this._deltaSubZ + stepJ, this._terrainIdx) * this._terrainIdx + this._mod(this._deltaSubX + stepI, this._terrainIdx);
				
				// related index in the array of positions (data map)
				if (this._datamap) {
					posIndex = 3 * index;
				}
				else {
					posIndex = 3 * terIndex;
				}
				// related index in the UV map
				if (this._uvmap) {
					uvIndex = 2 * index;
				}
				else {
					uvIndex = 2 * terIndex;
				}
				// related index in the color map
				if (this._colormap) {
					colIndex = 3 * index;
				}
				else {
					colIndex = 3 * terIndex;
				}
				// ribbon indexes
				ribbonPosInd = 3 * ribbonInd;
				ribbonColInd = 4 * ribbonInd;
				ribbonUVInd = 2 * ribbonInd;
				ribbonPosInd1 = ribbonPosInd;
				ribbonPosInd2 = ribbonPosInd + 1;
				ribbonPosInd3 = ribbonPosInd + 2;
				ribbonInd += 1;
				
				// geometry                  
				this._positions[ribbonPosInd1] = this._averageSubSizeX * stepI;
				this._positions[ribbonPosInd2] = this._mapData[posIndex + 1];
				this._positions[ribbonPosInd3] = this._averageSubSizeZ * stepJ;
				
				if (!this._computeNormals) {
					this._normals[ribbonPosInd1] = this._mapNormals[posIndex];
					this._normals[ribbonPosInd2] = this._mapNormals[posIndex + 1];
					this._normals[ribbonPosInd3] = this._mapNormals[posIndex + 2];
				}
				
				// bbox internal update
				if (this._positions[ribbonPosInd1] < this._bbMin.x) {
					this._bbMin.x = this._positions[ribbonPosInd1];
				}
				if (this._positions[ribbonPosInd1] > this._bbMax.x) {
					this._bbMax.x = this._positions[ribbonPosInd1];
				}
				if (this._positions[ribbonPosInd2] < this._bbMin.y) {
					this._bbMin.y = this._positions[ribbonPosInd2];
				}
				if (this._positions[ribbonPosInd2] > this._bbMax.y) {
					this._bbMax.y = this._positions[ribbonPosInd2];
				}
				if (this._positions[ribbonPosInd3] < this._bbMin.z) {
					this._bbMin.z = this._positions[ribbonPosInd3];
				}
				if (this._positions[ribbonPosInd3] > this._bbMax.z) {
					this._bbMax.z = this._positions[ribbonPosInd3];
				}
				// color
				var terrainIndex = j * this._terrainIdx + i;
				if (this._colormap) {
					this._colors[ribbonColInd] = this._mapColors[colIndex];
					this._colors[ribbonColInd + 1] = this._mapColors[colIndex + 1];
					this._colors[ribbonColInd + 2] = this._mapColors[colIndex + 2];
				}
				// uv : the array _mapUVs is always populated
				this._uvs[ribbonUVInd] = this._mapUVs[uvIndex];
				this._uvs[ribbonUVInd + 1] = this._mapUVs[uvIndex + 1];
				
				// call to user custom function with the current updated vertex object
				if (this._useCustomVertexFunction) {
					this._vertex.position.copyFromFloats(this._positions[ribbonPosInd1], this._positions[ribbonPosInd2], this._positions[ribbonPosInd3]);
					this._vertex.worldPosition.x = this._mapData[posIndex];
					this._vertex.worldPosition.y = this._vertex.position.y;
					this._vertex.worldPosition.z = this._mapData[posIndex + 2];
					this._vertex.lodX = lodI;
					this._vertex.lodZ = lodJ;
					this._vertex.color.r = this._colors[ribbonColInd];
					this._vertex.color.g = this._colors[ribbonColInd + 1];
					this._vertex.color.b = this._colors[ribbonColInd + 2];
					this._vertex.color.a = this._colors[ribbonColInd + 3];
					this._vertex.uvs.x = this._uvs[ribbonUVInd];
					this._vertex.uvs.y = this._uvs[ribbonUVInd + 1];
					this._vertex.mapIndex = index;
					this.updateVertex(this._vertex, i, j); // the user can modify the array values here
					this._colors[ribbonColInd] = this._vertex.color.r;
					this._colors[ribbonColInd + 1] = this._vertex.color.g;
					this._colors[ribbonColInd + 2] = this._vertex.color.b;
					this._colors[ribbonColInd + 3] = this._vertex.color.a;
					this._uvs[ribbonUVInd] = this._vertex.uvs.x;
					this._uvs[ribbonUVInd + 1] = this._vertex.uvs.y;
					this._positions[ribbonPosInd1] = this._vertex.position.x;
					this._positions[ribbonPosInd2] = this._vertex.position.y;
					this._positions[ribbonPosInd3] = this._vertex.position.z;
				}
				
				stepI += lodI;				
			}
			stepI = 0;
			stepJ += lodJ;
		}
		
		// ribbon update    
		this._terrain.updateVerticesData(VertexBuffer.PositionKind, this._positions, false, false);
		if (this._computeNormals) {
			VertexData.ComputeNormals(this._positions, this._indices, this._normals);
		} 
		this._terrain.updateVerticesData(VertexBuffer.NormalKind, this._normals, false, false);
		this._terrain.updateVerticesData(VertexBuffer.UVKind, this._uvs, false, false);
		this._terrain.updateVerticesData(VertexBuffer.ColorKind, this._colors, false, false);            
		this._terrain._boundingInfo = new BoundingInfo(this._bbMin, this._bbMax);
		this._terrain._boundingInfo.update(this._terrain._worldMatrix);
	}

	// private modulo, for dealing with negative indexes
	inline private function _mod(a:Int, b:Int):Int {
		return ((a % b) + b) % b;
	}

	/**
	 * Updates the mesh terrain size according to the LOD limits and the camera position.
	 * Returns the terrain.
	 */
	public function updateTerrainSize():DynamicTerrain { 
		var remainder:Int = this._terrainSub;                     // the remaining cells at the general current LOD value
		var nb:Int = 0;                                           // nb of cells in the current LOD limit interval
		var next:Int = 0;                                         // next cell index, if it exists
		var lod:Int = this._LODValue + 1;                         // lod value in the current LOD limit interval
		var tsx:Float = 0.0;                                      // current sum of cell sizes on x
		var tsz:Float = 0.0;                                      // current sum of cell sizes on z
		for (l in 0...this._LODLimits.length) {
			lod = this._LODValue + l + 1; 
			next = (l >= this._LODLimits.length - 1) ? 0 : this._LODLimits[l + 1];
			nb = 2 * (this._LODLimits[l] - next);
			tsx += this._averageSubSizeX * lod * nb;
			tsz += this._averageSubSizeZ * lod * nb;
			remainder -= nb;
		}
		tsx += remainder * this._averageSubSizeX * this._LODValue;
		tsz += remainder * this._averageSubSizeZ * this._LODValue;
		this._terrainSizeX = tsx;
		this._terrainSizeZ = tsz;
		this._terrainHalfSizeX = tsx * 0.5;
		this._terrainHalfSizeZ = tsz * 0.5;
		return this;
	}

	/**
	 * Returns the altitude (float) at the coordinates (x, z) of the map.  
	 * @param x 
	 * @param z 
	 * @param {normal: Vector3} (optional)
	 * If the optional object {normal: Vector3} is passed, then its property "normal" is updated with the normal vector value at the coordinates (x, z).  
	 */
	inline public function getHeightFromMap(x:Float, z:Float, ?options: {normal: Vector3} ): number {
		return DynamicTerrain._GetHeightFromMap(x, z, this._mapData, this._mapSubX, this._mapSubZ, this._mapSizeX, this._mapSizeZ, options);
	}

	/**
	 * Static : Returns the altitude (float) at the coordinates (x, z) of the passed map.
	 * @param x 
	 * @param z 
	 * @param mapSubX the number of points along the map width
	 * @param mapSubX the number of points along the map height
	 * @param {normal: Vector3} (optional)
	 * If the optional object {normal: Vector3} is passed, then its property "normal" is updated with the normal vector value at the coordinates (x, z).  
	 */
	public static GetHeightFromMap(x: number, z: number, mapData: number[]| Float32Array, mapSubX: number, mapSubZ: number, options? : {normal: Vector3}) : number {
		var mapSizeX = Math.abs(mapData[(mapSubX - 1) * 3] - mapData[0]);
		var mapSizeZ = Math.abs(mapData[(mapSubZ - 1) * mapSubX * 3 + 2] - mapData[2]);
		return DynamicTerrain._GetHeightFromMap(x, z, mapData, mapSubX, mapSubZ, mapSizeX, mapSizeZ, options);
	}

	// Computes the height and optionnally the normal at the coordinates (x ,z) from the passed map
	private static _GetHeightFromMap(x:Float, z:Float, mapData:Float32Array, mapSubX:Float, mapSubZ:Float, mapSizeX:Float, mapSizeZ:Float, ?normal:Vector3):Float {
		var x0 = mapData[0];
		var z0 = mapData[2];
		
		// reset x and z in the map space so they are between 0 and the axis map size
		x = x - Math.floor((x - x0) / mapSizeX) * mapSizeX;
		z = z - Math.floor((z - z0) / mapSizeZ) * mapSizeZ;
		
		var col1 = Math.floor((x - x0) * mapSubX / mapSizeX);
		var row1 = Math.floor((z - z0) * mapSubZ / mapSizeZ);
		var col2 = (col1 + 1) % mapSubX;
		var row2 = (row1 + 1) % mapSubZ;
		// starting indexes of the positions of 4 vertices defining a quad on the map
		var idx1 = 3 * (row1 * mapSubX + col1);
		var idx2 = 3 * (row1 * mapSubX + col2);
		var idx3 = 3 * ((row2) * mapSubX + col1);
		var idx4 = 3 * ((row2) * mapSubX + col2);
		
		DynamicTerrain._v1.copyFromFloats(mapData[idx1], mapData[idx1 + 1], mapData[idx1 + 2]);
		DynamicTerrain._v2.copyFromFloats(mapData[idx2], mapData[idx2 + 1], mapData[idx2 + 2]);
		DynamicTerrain._v3.copyFromFloats(mapData[idx3], mapData[idx3 + 1], mapData[idx3 + 2]);
		DynamicTerrain._v4.copyFromFloats(mapData[idx4], mapData[idx4 + 1], mapData[idx4 + 2]);
		
		var vA = DynamicTerrain._v1;
		var vB;
		var vC;
		var v;
		
		var xv4v1 = DynamicTerrain._v4.x - DynamicTerrain._v1.x;
		var zv4v1 = DynamicTerrain._v4.z - DynamicTerrain._v1.z;
		if (xv4v1 == 0 || zv4v1 == 0) {
			return DynamicTerrain._v1.y;
		}
		var cd = zv4v1 / xv4v1;
		var h = DynamicTerrain._v1.z - cd * DynamicTerrain._v1.x;
		if (z < cd * x + h) {
			vB = DynamicTerrain._v4;
			vC = DynamicTerrain._v2;
			v = vA;
		} 
		else {
			vB = DynamicTerrain._v3;
			vC = DynamicTerrain._v4;
			v = vB;
		}
		vB.subtractToRef(vA, DynamicTerrain._vAvB);
		vC.subtractToRef(vA, DynamicTerrain._vAvC);
		Vector3.CrossToRef(DynamicTerrain._vAvB, DynamicTerrain._vAvC, DynamicTerrain._norm);
		DynamicTerrain._norm.normalize();
		if (normal != null) {
			normal.copyFrom(DynamicTerrain._norm);
		}
		var d = -(DynamicTerrain._norm.x * v.x + DynamicTerrain._norm.y * v.y + DynamicTerrain._norm.z * v.z);
		var y = v.y;
		if (DynamicTerrain._norm.y != 0.0) {
			y = -(DynamicTerrain._norm.x * x + DynamicTerrain._norm.z * z + d) / DynamicTerrain._norm.y;
		}
		
		return y;
	}

	/**
	 * Static : Computes all the normals from the terrain data map  and stores them in the passed Float32Array reference.  
	 * This passed array must have the same size than the mapData array.
	 */
	public static function ComputeNormalsFromMapToRef(mapData:Float32Array, mapSubX:Float, mapSubZ:Float, normals:Float32Array) {
		var mapIndices = [];
		var tmp1 = Vector3.Zero();
		var tmp2 = Vector3.Zero();
		var l = mapSubX * (mapSubZ - 1);
		for (i in 0...l) {
			mapIndices.push(i + 1, i + mapSubX, i);
			mapIndices.push(i + mapSubX, i + 1, i + mapSubX + 1);
		}
		VertexData.ComputeNormals(mapData, mapIndices, normals);
		// seam process		
		var lastIdx = (mapSubX - 1) * 3;
		var colStart = 0;
		var colEnd = 0;
		for (i in 0...mapSubZ) {
			colStart = i * mapSubX * 3;
			colEnd = colStart + lastIdx;
			DynamicTerrain.GetHeightFromMap(mapData[colStart], mapData[colStart + 2], mapData, mapSubX, mapSubZ, tmp1);
			DynamicTerrain.GetHeightFromMap(mapData[colEnd], mapData[colEnd + 2], mapData, mapSubX, mapSubZ, tmp2);
			tmp1.normal.addInPlace(tmp2.normal).scaleInPlace(0.5);
			normals[colStart] = tmp1.normal.x;
			normals[colStart + 1] = tmp1.normal.y;
			normals[colStart + 2] = tmp1.normal.z;
			normals[colEnd] = tmp1.normal.x;
			normals[colEnd + 1] = tmp1.normal.y;
			normals[colEnd + 2] = tmp1.normal.z;
		}
		
	}
	
	 /**
	  * Computes all the map normals from the current terrain data map and sets them to the terrain.  
	  * Returns the terrain.  
	  */
	inline public function computeNormalsFromMap():DynamicTerrain {
		DynamicTerrain.ComputeNormalsFromMapToRef(this._mapData, this._mapSubX, this._mapSubZ, this._mapNormals);
		return this;
	}

	/**
	 * Returns true if the World coordinates (x, z) are in the current terrain.
	 * @param x 
	 * @param z 
	 */
	public function contains(x:Float, z:Float):Bool {
		if (x < this._positions[0] + this.mesh.position.x || x > this._positions[3 * this._terrainIdx] + this.mesh.position.x) {
			return false;
		}
		if (z < this._positions[2] + this.mesh.position.z || z > this._positions[3 * this._terrainIdx * this._terrainIdx + 2] + this.mesh.position.z) {
			return false;
		}
		return true;
	}

	/**
	 * Static : Returns a new data map from the passed heightmap image file.  
	 The parameters `width` and `height` (positive floats, default 300) set the map width and height sizes.     
	 * `subX` is the wanted number of points along the map width (default 100).  
	 * `subZ` is the wanted number of points along the map height (default 100).  
	 * The parameter `minHeight` (float, default 0) is the minimum altitude of the map.     
	 * The parameter `maxHeight` (float, default 1) is the maximum altitude of the map.   
	 * The parameter `colorFilter` (optional Color3, default (0.3, 0.59, 0.11) ) is the filter to apply to the image pixel colors to compute the height.
	 * `onReady` is an optional callback function, called once the map is computed. It's passed the computed map.  
	 * `scene` is the Scene object whose database will store the downloaded image.  
	 */
	public static function CreateMapFromHeightMap(heightmapURL:String, options:Dynamic, scene:Scene):Float32Array {
		var subX = options.subX != null ? options.subX : 100;
		var subZ = options.subZ != null ? options.subZ : 100;
		var data = new Float32Array(subX * subZ * 3);
		DynamicTerrain.CreateMapFromHeightMapToRef(heightmapURL, options, data, scene);
		return data;
	}

	/**
	 * Static : Updates the passed array or Float32Array with a data map computed from the passed heightmap image file.  
	 *  The parameters `width` and `height` (positive floats, default 300) set the map width and height sizes.     
	 * `subX` is the wanted number of points along the map width (default 100).  
	 * `subZ` is the wanted number of points along the map height (default 100). 
	 * The parameter `minHeight` (float, default 0) is the minimum altitude of the map.     
	 * The parameter `maxHeight` (float, default 1) is the maximum altitude of the map.   
	 * The parameter `colorFilter` (optional Color3, default (0.3, 0.59, 0.11) ) is the filter to apply to the image pixel colors to compute the height.
	 * `onReady` is an optional callback function, called once the map is computed. It's passed the computed map.         
	 * `scene` is the Scene object whose database will store the downloaded image.  
	 * The passed Float32Array must be the right size : 3 x subX x subZ.  
	 */
	public static function CreateMapFromHeightMapToRef(heightmapURL:String, options:Dynamic, data:Float32Array, scene:Scene) {
		var width = options.width != null ? options.width : 300;
		var height = options.height != null ? options.height : 300;
		var subX = options.subX != null ? options.subX : 100;
		var subZ = options.subZ != null ? options.subZ : 100;
		var minHeight = options.minHeight != null ? options.minHeight : 0.0;
		var maxHeight = options.maxHeight != null ? options.maxHeight : 10.0;
		var offsetX = options.offsetX != null ? options.offsetX : 0.0;
		var offsetZ = options.offsetZ != null ? options.offsetZ : 0.0;
		var filter = options.colorFilter != null ? options.colorFilter : new Color3(0.3, 0.59, 0.11);
		var onReady = options.onReady;
		
		var onload = function(img:Image) {
			var buffer = img.data;
			var x = 0.0;
			var y = 0.0;
			var z = 0.0;
			for (row in 0...subZ) {
				for (col in 0...subX) {
					x = col * width / subX - width * 0.5;
					z = row * height / subZ - height * 0.5;
					var heightmapX = ((x + width * 0.5) / width * (bufferWidth - 1)) | 0;
					var heightmapY = (bufferHeight - 1) - ((z + height * 0.5) / height * (bufferHeight - 1)) | 0;
					var pos = (heightmapX + heightmapY * bufferWidth) * 4;
					var gradient = (buffer[pos] * filter.r + buffer[pos + 1] * filter.g + buffer[pos + 2] * filter.b) / 255.0;
					y = minHeight + (maxHeight - minHeight) * gradient;
					var idx = (row * subX + col) * 3;
					data[idx] = x + offsetX;
					data[idx + 1] = y;
					data[idx + 2] = z + offsetZ;
				}
			}
			
			// callback function if any
			if (onReady != null) {
				onReady(data, subX, subZ);
			}
		}
		
		Tools.LoadImage(heightmapURL, onload)
	}
	
	/**
	 * Static : Updates the passed arrays with UVs values to fit the whole map with subX points along its width and subZ points along its height.  
	 * The passed array must be the right size : subX x subZ x 2.  
	 */
	public static function CreateUVMapToRef(subX:Int, subZ:Int, mapUVs:Float32Array) {
		for (h in 0...subZ) {
			for (w in 0...subX) {
				mapUVs[(h * subX + w) * 2] = w / subX;
				mapUVs[(h * subX + w) * 2 + 1] = h / subZ;
			}
		}
	}
	
	/**
	 * Static : Returns a new UV array with values to fit the whole map with subX points along its width and subZ points along its height.  
	 */
	public static function CreateUVMap(subX:Int, subZ:Int):Float32Array {
		var mapUVs = new Float32Array(subX * subZ * 2);
		DynamicTerrain.CreateUVMapToRef(subX, subZ, mapUVs);
		return mapUVs;
	}

	/**
	 * Computes and sets the terrain UV map with values to fit the whole map.  
	 * Returns the terrain.  
	 */
	public function createUVMap():DynamicTerrain {
		this.mapUVs = DynamicTerrain.CreateUVMap(this._mapSubX, this._mapSubZ);
		return this;
	}


	// Getters / Setters
	/**
	 * boolean : if the terrain must be recomputed every frame.
	 */
	public var refreshEveryFrame(get, set):Bool;
	inline private function get_refreshEveryFrame():Bool {
		return this._refreshEveryFrame;
	}
	inline private function set_refreshEveryFrame(val:Bool):Bool {
		this._refreshEveryFrame = val;
		return val;
	}
	
	/**
	 * Mesh : the logical terrain underlying mesh
	 */
	public var mesh(get, never):Mesh;
	inline private function get_mesh():Mesh {
		return this._terrain;
	}
	
	/**
	 * The camera the terrain is linked to
	 */
	public var camera(get, set):Camera;
	inline private function get_camera():Camera {
		return this._terrainCamera;
	}
	inline private function set_camera(val:Camera):Camera {
		this._terrainCamera = val;
		return val;
	}
	
	/**
	 * Number of cells flought over by the cam on the X axis before the terrain is updated.
	 * Integer greater or equal to 1.
	 */
	public var subToleranceX(get, set):Int;
	inline private function get_subToleranceX():Int {
		return this._subToleranceX;
	}
	inline private function set_subToleranceX(val:Int):Int {
		this._subToleranceX = (val > 0) ? val : 1;
		return val;
	}
	/**
	 * Number of cells flought over by the cam on the Z axis before the terrain is updated.
	 * Integer greater or equal to 1. Default 1.
	 */
	public get subToleranceZ(): number {
		return this._subToleranceZ;
	}
	public set subToleranceZ(val: number) {
		this._subToleranceZ = (val > 0) ? val : 1;
	}
	/**
	 * Initial LOD factor value.
	 * Integer greater or equal to 1. Default 1.
	 */
	public get initialLOD(): number {
		return this._initialLOD;
	}
	public set initialLOD(val: number) {
		this._initialLOD = (val > 0) ? val : 1;
	}
	/**
	* Current LOD factor value : the lower factor in the terrain.  
	* The LOD value is the sum of the initialLOD and the current cameraLODCorrection.  
	* Integer greater or equal to 1. Default 1.  
	*/
	public get LODValue(): number {
		return this._LODValue;
	}
	/**
	 * Camera LOD correction : the factor to add to the initial LOD according to the camera position, movement, etc.
	 * Positive integer (default 0)  
	 */
	public get cameraLODCorrection(): number {
		return this._cameraLODCorrection;
	}
	public set cameraLODCorrection(val: number) {
		this._cameraLODCorrection = (val >= 0) ? val : 0;
	}
	/**
	 * Average map and terrain subdivision size on X axis.  
	 * Returns a float.
	 */
	public get averageSubSizeX(): number {
		return this._averageSubSizeX;
	}
	/**
	 * Average map and terrain subdivision size on Z axis.  
	 * Returns a float.
	 */
	public get averageSubSizeZ(): number {
		return this._averageSubSizeZ;
	}
	/**
	 * Current terrain size on the X axis.  
	 * Returns a float.
	 */
	 public get terrainSizeX(): number {
		 return this._terrainSizeX;
	 }
	/**
	 * Current terrain half size on the X axis.  
	 * Returns a float.
	 */
	 public get terrainHalfSizeX(): number {
		 return this._terrainHalfSizeX;
	 }
	/**
	 * Current terrain size on the Z axis.  
	 * Returns a float.
	 */
	 public get terrainSizeZ(): number {
		 return this._terrainSizeZ;
	 }
	/**
	 * Current terrain half size on the Z axis.  
	 * Returns a float.
	 */
	 public get terrainHalfSizeZ(): number {
		 return this._terrainHalfSizeZ;
	 }
	/**
	 * Current position of terrain center in its local space.  
	 * Returns a Vector3. 
	 */
	public get centerLocal(): Vector3 {
		return this._centerLocal;
	}
	/**
	 * Current position of terrain center in the World space.  
	 * Returns a Vector3. 
	 */
	public get centerWorld(): Vector3 {
		return this._centerWorld;
	}
	/**
	 * The array of the limit values to change the LOD factor.  
	 * Returns an array of integers or an empty array. 
	 * This array is always sorted in the descending order once set.   
	 */
	public get LODLimits(): number[] {
		return this._LODLimits;
	}
	public set LODLimits(ar: number[]) {
		ar.sort((a,b) => {
			return b - a;
		});
		this._LODLimits = ar;
	}
	/**
	 * The data of the map.
	 * A flat array (Float32Array recommeded) of successive 3D float coordinates (x, y, z).  
	 * This property can be set only if a mapData array was passed at construction time.  
	 */
	public get mapData(): Float32Array|number[] {
		return this._mapData;
	}
	public set mapData(val: Float32Array|number[]) {
		this._mapData = val;
		this._datamap = true;
		this._mapSizeX = Math.abs(this._mapData[(this._mapSubX - 1) * 3] - this._mapData[0]);
		this._mapSizeZ = Math.abs(this._mapData[(this._mapSubZ - 1) * this._mapSubX * 3 + 2] - this._mapData[2]);
		this._averageSubSizeX = this._mapSizeX / this._mapSubX;
		this._averageSubSizeZ = this._mapSizeZ / this._mapSubZ;
		if (this._precomputeNormalsFromMap) {
			this.computeNormalsFromMap();
		}
		this.update(true);
	}
	/**
	 * The number of points on the map width. 
	 * Positive Integer.  
	 */
	public get mapSubX(): number {
		return this._mapSubX;
	}
	public set mapSubX(val: number) {
		this._mapSubX = val;
	}
	/**
	 * The number of points on the map height . 
	 * Positive Integer.  
	 */
	public get mapSubZ(): number {
		return this._mapSubZ;
	}
	public set mapSubZ(val: number) {
		this._mapSubZ = val;
	}
	/**
	 * The map of colors.
	 * A flat array of successive floats between 0 and 1 as r,g,b values.  
	 * This property can be set only if a mapColors array was passed at construction time.  
	 */
	public get mapColors(): Float32Array|number[] {
		return this._mapColors;
	}
	public set mapColors(val: Float32Array|number[]) {
		this._colormap = true;
		this._mapColors = val;
	}
	/**
	 * The map of UVs.
	 * A flat array of successive floats between 0 and 1 as (u, v) values. 
	 * This property can be set only if a mapUVs array was passed at construction time.   
	 */
	public get mapUVs(): Float32Array|number[] {
		return this._mapUVs;
	}
	public set mapUVs(val: Float32Array|number[]) {
		this._uvmap = true;
		this._mapUVs = val;
	}
	/**
	 * The map of normals.
	 * A flat array of successive floats as normal vector coordinates (x, y, z) on each map point.  
	 */
	public get mapNormals(): Float32Array|number[] {
		return this._mapNormals;
	}
	public set mapNormals(val: Float32Array|number[]) {
		this._mapNormals = val;
	}
	/**
	 * Boolean : must the normals be recomputed on each terrain update (default : false).  
	 * By default, all the map normals are pre-computed on terrain creation.
	 */
	public get computeNormals():Bool {
		return this._computeNormals;
	}
	public set computeNormals(val:Bool) {
		this._computeNormals = val;
	}
	/**
	 * Boolean : will the custom function updateVertex() be called on each terrain update ?
	 * Default false
	 */
	public get useCustomVertexFunction():Bool {
		return this._useCustomVertexFunction;
	}
	public set useCustomVertexFunction(val:Bool) {
		this._useCustomVertexFunction = val;
	}
	/**
	 * Boolean : is the terrain always directly selected for rendering ?
	 */
	public get isAlwaysVisible():Bool {
		return this._isAlwaysVisible;
	}
	public set isAlwaysVisible(val) {
		this.mesh.alwaysSelectAsActiveMesh = val;
		this._isAlwaysVisible = val;
	}
	/**
	 * Boolean : when assigning a new data map to the existing, shall the normals be automatically precomputed once ?  
	 * Default false.  
	 */
	public get precomputeNormalsFromMap():Bool {
		return this._precomputeNormalsFromMap;
	}
	public set precomputeNormalsFromMap(val) {
		this._precomputeNormalsFromMap = val;
	}
	// ===============================================================
	// User custom functions.
	// These following can be overwritten bu the user to fit his needs.


	/**
	 * Custom function called for each terrain vertex and passed the :
	 * - current vertex {position: Vector3, uvs: Vector2, color: Color4, lodX: integer, lodZ: integer, worldPosition: Vector3, mapIndex: integer}
	 * - i : the vertex index on the terrain x axis
	 * - j : the vertex index on the terrain x axis
	 * This function is called only if the property useCustomVertexFunction is set to true.  
	 */
	public updateVertex(vertex, i, j) {
		return;
	}

	/**
	 * Custom function called each frame and passed the terrain camera reference.
	 * This should return a positive integer or zero.  
	 * Returns zero by default.  
	 */
	 public updateCameraLOD(terrainCamera: Camera): number {
		// LOD value increases with camera altitude
		var camLOD = 0;
		return camLOD;
	}
	/**
	 * Custom function called before each terrain update.
	 * The value of reference is passed.  
	 * Does nothing by default.  
	 */
	public beforeUpdate(refreshEveryFrame:Bool) {
		return;
	}
	/**
	 * Custom function called after each terrain update.
	 * The value of refreshEveryFrame is passed.  
	 * Does nothing by default.  
	 */
	public afterUpdate(refreshEveryFrame:Bool) {
		return;
	}

}
