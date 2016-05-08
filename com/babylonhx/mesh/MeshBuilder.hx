package com.babylonhx.mesh;

import com.babylonhx.math.Tmp;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector4;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Path3D;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.PositionNormalTextureVertex;
import com.babylonhx.math.PositionNormalVertex;
import com.babylonhx.tools.Tools;
import com.babylonhx.utils.Image;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */

typedef SphereOptions = {
	?segments:Int,
	?diameterX:Float,
	?diameterY:Float,
	?diameterZ:Float,
	?sideOrientation:Int,
	?updatable:Bool
}

typedef BoxOptions = {	
	width:Float,
	height:Float,
	depth:Float,
	?sideOrientation:Int,
	?updatable:Bool
}

typedef CylinderOptions = {
	?height:Float,
	?arc:Float,
	?diameterTop:Float,
	?diameterBottom:Float,
	?tessellation:Int,
	?subdivisions:Int,
	?faceColors:Array<Color4>,
	?faceUV:Array<Vector4>,
	?hasRings:Bool,
	?sideOrientation:Int,
	?enclose:Bool,
	?updatable:Bool
}

typedef DiscOptions = {
	?radius:Float,
	?tessellation:Float,
	?sideOrientation:Int,
	?updatable:Bool
}

typedef RibbonOptions = {
	pathArray:Array<Array<Vector3>>, 
	?closeArray:Bool, 
	?closePath:Bool, 
	?offset:Int,
	?instance:Mesh,
	?sideOrientation:Int,
	?updatable:Bool
}

typedef TorusOptions = {
	diameter:Float,
	thickness:Float, 
	tessellation:Int,
	?sideOrientation:Int,
	?updatable:Bool
}

typedef TorusKnotOptions = {
	radius:Float, 
	tube:Float, 
	radialSegments:Int, 
	tubularSegments:Int, 
	p:Float, 
	q:Float,
	?sideOrientation:Int,
	?updatable:Bool
}

typedef LinesOptions = {
	points:Array<Vector3>,
	?updatable:Bool,
	?instance:LinesMesh
}

typedef DashedLinesOptions = {
	points:Array<Vector3>, 
	?dashSize:Float, 
	?gapSize:Float, 
	?dashNb:Float,
	?updatable:Bool,
	?instance:LinesMesh 
}

typedef PlaneOptions = {
	width:Float, 
	height:Float,
	?sideOrientation:Int,
	?updatable:Bool
}

typedef GroundOptions = {
	width:Float, 
	height:Float, 
	subdivision:Int,
	?updatable:Bool
}

typedef TiledGroundOptions = {
	xmin:Float, 
	zmin:Float, 
	xmax:Float, 
	zmax:Float, 
	subdivisions:Int, 
	precision:Int,
	?updatable:Bool
}

typedef GroundFromHeightmapOptions = {
	width:Float, 
	height:Float, 
	subdivisions:Int, 
	minHeight:Float, 
	maxHeight:Float, 
	?updatable:Bool, 
	?onReady:GroundMesh->Void
}

typedef TubeOptions = {
	path:Array<Vector3>, 
	radius:Float, 
	tessellation:Int, 
	radiusFunction:Int->Float->Float, 
	cap:Int, 
	?arc:Int,
	?updatable:Bool, 
	?sideOrientation:Int, 
	?instance:Mesh
}

typedef PolyhedronOptions = {
	?type:Int, 
	?size:Float, 
	?sizeX:Float, 
	?sizeY:Float, 
	?sizeZ:Float, 
	?custom:Dynamic, 
	?faceUV:Array<Vector4>, 
	?faceColors:Array<Color4>, 
	?updatable:Bool, 
	?sideOrientation:Int
}

typedef IcoSphereOptions = {
	?radius:Float, 
	?radiusX:Float, 
	?radiusY:Float, 
	?radiusZ:Float, 
	?flat:Bool, 
	?updatable:Bool,
	?subdivisions:Int, 
	?sideOrientation:Int
}

typedef LatheOptions = {
	shape:Array<Vector3>,
	?radius:Float,
	?tesselation:Int,
	?sideOrientation:Int,
	?updatable:Bool,
	?closed:Bool,
	?arc:Float,
	?cap:Int
}
 
class MeshBuilder {
	
	public static function CreateBox(name:String, options:Dynamic, scene:Scene):Mesh {
		var box = new Mesh(name, scene);
		var vertexData = VertexData.CreateBox(options);
		
		if (scene.isPhysicsEnabled()) {
			box.physicsDim = { };
			box.physicsDim.size = options;
		}
		
		vertexData.applyToMesh(box, options.updatable);
		
		return box;
	}
	
	public static function CreateSphere(name:String, options:SphereOptions, scene:Scene):Mesh {		
		var sphere = new Mesh(name, scene);
		var vertexData = VertexData.CreateSphere(options);
		
		vertexData.applyToMesh(sphere, options.updatable);
		
		if (scene.isPhysicsEnabled()) {
			sphere.physicsDim = { };
			sphere.physicsDim.diameter = options.diameterX / 2;
		}
		
		return sphere;		
	}
	
	public static function CreateIcoSphere(name:String, options:IcoSphereOptions, scene:Scene):Mesh {
		var sphere = new Mesh(name, scene);
		
		if (options.sideOrientation == null) {
			options.sideOrientation = Mesh.DEFAULTSIDE;
		}
		
		if (options.updatable == null) {
			options.updatable = false;
		}
			
		var vertexData = VertexData.CreateIcoSphere(options);
		
		vertexData.applyToMesh(sphere, options.updatable);
		
		return sphere;
	}
	
	public static function CreateDisc(name:String, options:Dynamic, scene:Scene):Mesh {
        var disc = new Mesh(name, scene);
        var vertexData = VertexData.CreateDisc(options);
		
        vertexData.applyToMesh(disc, options.updatable);
		
        return disc;
    }
	
	public static function CreateRibbon(?name:String, options:Dynamic, scene:Scene):Mesh {		
		var pathArray:Array<Array<Vector3>> = options.pathArray ;
		var closeArray:Bool = options.closeArray;
		var closePath:Bool = options.closePath;
		var offset:Int = options.offset;
		var updatable:Bool = options.updatable;
		var sideOrientation:Int = options.sideOrientation;
		var ribbonInstance:Mesh = options.instance;			
		
		if (ribbonInstance != null) {   // existing ribbon instance update
			// positionFunction : ribbon case
			// only pathArray and sideOrientation parameters are taken into account for positions update
			var positionFunction = function (positions:Array<Float>) {
				var minlg = pathArray[0].length;
				var i:Int = 0;
				var ns = (ribbonInstance.sideOrientation == Mesh.DOUBLESIDE) ? 2 : 1;
				for (si in 1...ns + 1) {
					for (p in 0...pathArray.length) {
						var path = pathArray[p];
						var l = path.length;
						minlg = (minlg < l) ? minlg : l;
						var j:Int = 0;
						while (j < minlg) {
							positions[i] = path[j].x;
							positions[i + 1] = path[j].y;
							positions[i + 2] = path[j].z;
							j++;
							i += 3;
						}
						if (ribbonInstance._closePath) {
                            positions[i] = path[0].x;
                            positions[i + 1] = path[0].y;
                            positions[i + 2] = path[0].z;
                            i += 3;
                        }
					}
				}
			};
			
			var positions = ribbonInstance.getVerticesData(VertexBuffer.PositionKind);
			positionFunction(positions);
			ribbonInstance.updateVerticesData(VertexBuffer.PositionKind, positions, true, false);
			if (!ribbonInstance.areNormalsFrozen) {
				var indices = ribbonInstance.getIndices();
				var normals = ribbonInstance.getVerticesData(VertexBuffer.NormalKind);
				VertexData.ComputeNormals(positions, indices, normals);
				
				if (ribbonInstance._closePath) {
					var indexFirst:Int = 0;
					var indexLast:Int = 0;
					for (p in 0...pathArray.length) {
						indexFirst = ribbonInstance._idx[p] * 3;
						if (p + 1 < pathArray.length) {
							indexLast = (ribbonInstance._idx[p + 1] - 1) * 3;
						}
						else {
							indexLast = normals.length - 3;
						}
						normals[indexFirst] = (normals[indexFirst] + normals[indexLast]) * 0.5;
						normals[indexFirst + 1] = (normals[indexFirst + 1] + normals[indexLast + 1]) * 0.5;
						normals[indexFirst + 2] = (normals[indexFirst + 2] + normals[indexLast + 2]) * 0.5;
						normals[indexLast] = normals[indexFirst];
						normals[indexLast + 1] = normals[indexFirst + 1];
						normals[indexLast + 2] = normals[indexFirst + 2];
					}
				}
				
				ribbonInstance.updateVerticesData(VertexBuffer.NormalKind, normals, true, false);
			}
			
			return ribbonInstance;
		}
		else {  // new ribbon creation
			var ribbon = new Mesh(name, scene);
			ribbon.sideOrientation = sideOrientation;
			
			var vertexData = VertexData.CreateRibbon({ pathArray: pathArray, closeArray: closeArray, closePath: closePath, offset: offset, sideOrientation: sideOrientation });
			
			if (closePath) {
				ribbon._idx = vertexData._idx;
			}
			ribbon._closePath = closePath;
			ribbon._closeArray = closeArray;
			
			vertexData.applyToMesh(ribbon, updatable);
				
			return ribbon;
		}
	}	

	// Cylinder and cone (Code inspired by SharpDX.org)
	public static function CreateCylinder(name:String, options:CylinderOptions, scene:Scene):Mesh {		
		var cylinder = new Mesh(name, scene);
		var vertexData = VertexData.CreateCylinder(options);
		
		if (scene.isPhysicsEnabled()) {
			cylinder.physicsDim = { };
			cylinder.physicsDim.height = options.height;
			cylinder.physicsDim.diameter = options.diameterBottom > options.diameterTop ? options.diameterBottom : options.diameterTop;
		}
		
		vertexData.applyToMesh(cylinder, options.updatable);
		
		return cylinder;
	}
	
	public static function CreateTorus(name:String, options:Dynamic, scene:Scene):Mesh {
		var torus = new Mesh(name, scene);
		var vertexData = VertexData.CreateTorus(options);
		
		vertexData.applyToMesh(torus, options.updatable);
		
		return torus;
	}

	public static function CreateTorusKnot(name:String, options:Dynamic, scene:Scene):Mesh {
		var torusKnot = new Mesh(name, scene);
		var vertexData = VertexData.CreateTorusKnot(options);
		
		vertexData.applyToMesh(torusKnot, options.updatable);
		
		return torusKnot;
	}
	
	// options: { lines: Array<Array<Vector3>>, updatable:Bool, ?instance:LinesMesh }
	public static function CreateLineSystem(name:String, options:Dynamic, scene:Scene):LinesMesh {
		var instance:LinesMesh = options.instance;
		var lines:Array<Array<Vector3>> = options.lines;
		
		if (instance != null) { // lines update
			var positionFunction = function(positions:Array<Float>) {
				var i = 0;
				for (l in 0...lines.length) {
					var points = lines[l];
					for (p in 0...points.length) {
						positions[i] = points[p].x;
						positions[i + 1] = points[p].y;
						positions[i + 2] = points[p].z;
						i += 3;
					}
				}
			};
			
			instance.updateMeshPositions(positionFunction, false);
			
			return instance;
		}
		
		// line system creation
		var lineSystem = new LinesMesh(name, scene);
		var vertexData = VertexData.CreateLineSystem(options);
		vertexData.applyToMesh(lineSystem, options.updatable);
		
		return lineSystem;
	}
	
	public static function CreateLines(name:String, options:Dynamic, scene:Scene):LinesMesh {
		var lines = MeshBuilder.CreateLineSystem(name, { lines: [options.points], updatable: options.updatable, instance: options.instance }, scene);
		
		return lines;
	}
	
	public static function CreateDashedLines(name:String, options:Dynamic, scene:Scene):LinesMesh {
		var points:Array<Vector3> = options.points;
		var linesInstance:LinesMesh = options.instance;
		var gapSize:Float = options.gapSize;
		var dashNb:Float = options.dashNb;
		var dashSize:Float = options.dashSize;
		
		if (linesInstance != null) {  //  dashed lines update
			var positionFunction = function(positions:Array<Float>) {
				var curvect:Vector3 = Vector3.Zero();
				var nbSeg:Float = positions.length / 6;
				var lg:Float = 0;
				var nb:Int = 0;
				var shft:Float = 0;
				var dashshft:Float = 0;
				var curshft:Float = 0;
				var p:Int = 0;
				var i:Int = 0;
				var j:Int = 0;
				for (i in 0...points.length - 1) {
					points[i + 1].subtractToRef(points[i], curvect);
					lg += curvect.length();
				}
				shft = lg / nbSeg;
				dashshft = linesInstance.dashSize * shft / (linesInstance.dashSize + linesInstance.gapSize);
				while (i < points.length - 1) {
					points[i + 1].subtractToRef(points[i], curvect);
					nb = Math.floor(curvect.length() / shft);
					curvect.normalize();
					j = 0;
					while (j < nb && p < positions.length) {
						curshft = shft * j;
						positions[p] = points[i].x + curshft * curvect.x;
						positions[p + 1] = points[i].y + curshft * curvect.y;
						positions[p + 2] = points[i].z + curshft * curvect.z;
						positions[p + 3] = points[i].x + (curshft + dashshft) * curvect.x;
						positions[p + 4] = points[i].y + (curshft + dashshft) * curvect.y;
						positions[p + 5] = points[i].z + (curshft + dashshft) * curvect.z;
						p += 6;
						j++;
					}
					++i;
				}
				while (p < positions.length) {
					positions[p] = points[i].x;
					positions[p + 1] = points[i].y;
					positions[p + 2] = points[i].z;
					p += 3;
				}
			};
			linesInstance.updateMeshPositions(positionFunction, false);
			
			return linesInstance;
		}
		
		// dashed lines creation
		var dashedLines = new LinesMesh(name, scene);
		var vertexData = VertexData.CreateDashedLines(options);
		vertexData.applyToMesh(dashedLines, options.updatable);
		dashedLines.dashSize = dashSize;
		dashedLines.gapSize = gapSize;
		
		return dashedLines;
	}
	
	public static function ExtrudeShape(name:String, options:Dynamic, scene:Scene):Mesh {		
		var path:Array<Vector3> = options.path;
		var shape:Array<Vector3> = options.shape;
		var scale:Float = options.scale != null ? options.scale : 1;
		var rotation:Float = options.rotation != null ? options.rotation : 0;
		var cap:Int = options.cap != null ? options.cap : Mesh.NO_CAP;
		var updatable:Bool = options.updatable;
		var sideOrientation:Int = options.sideOrientation != null ? options.sideOrientation : Mesh.DEFAULTSIDE;
		var extrudedInstance:Mesh = options.extrudedInstance;
		
		return MeshBuilder._ExtrudeShapeGeneric(name, shape, path, scale, rotation, null, null, false, false, cap, false, scene, updatable, sideOrientation, extrudedInstance);
	}
	
	public static function ExtrudeShapeCustom(name:String, options:Dynamic, scene:Scene):Mesh {
		var path:Array<Vector3> = options.path;
		var shape:Array<Vector3> = options.shape;
		var scaleFunction:Float->Float->Float = options.scaleFunction != null ? options.scaleFunction : function(dummy1:Float = 0, dummy2:Float = 0):Float { return 1; };
		var rotationFunction:Float->Float->Float = options.rotationFunction != null ? options.rotationFunction : function(dummy1:Float = 0, dummy2:Float = 0):Float { return 0; };
		var ribbonCloseArray:Bool = options.ribbonCloseArray != null ? options.ribbonCloseArray : false;
		var ribbonClosePath:Bool = options.ribbonClosePath != null ? options.ribbonClosePath : false;
		var cap:Int = options.cap != null ? options.cap : Mesh.NO_CAP;
		var updatable:Bool = options.updatable;
		var sideOrientation:Int = options.sideOrientation != null ? options.sideOrientation : Mesh.DEFAULTSIDE;
		var extrudedInstance:Mesh = options.extrudedInstance;
		
		return MeshBuilder._ExtrudeShapeGeneric(name, shape, path, null, null, scaleFunction, rotationFunction, ribbonCloseArray, ribbonClosePath, cap, true, scene, updatable, sideOrientation, extrudedInstance);
	}
	
	public static function CreateLathe(name:String, options:Dynamic, scene:Scene):Mesh {
		var arc:Float = options.arc != null ? options.arc : 1.0;
		if (arc <= 0) {
			arc = 1.0;
		}
		var closed:Bool = options.closed == null ? true : options.closed;
		var shape:Array<Vector3> = options.shape;
		var radius:Float = options.radius != null ? options.radius : 1;
		var tessellation:Int = options.tessellation != null ? options.tessellation : 64;
		var updatable:Bool = options.updatable;
		var sideOrientation = options.sideOrientation != null ? options.sideOrientation : Mesh.DEFAULTSIDE;
		var cap:Int = options.cap != null ? options.cap : Mesh.NO_CAP;
		var pi2:Float = Math.PI * 2;
		var paths:Array<Array<Vector3>> = [];
		
		var step:Float = pi2 / tessellation * arc;
		var rotated:Vector3 = null;
		var path = new Array<Vector3>();
		for (i in 0...tessellation + 1) {
			var path:Array<Vector3> = [];
			
			if (cap == Mesh.CAP_START || cap == Mesh.CAP_ALL) {
                path.push(new Vector3(0, shape[0].y ,0));
                path.push(new Vector3(Math.cos(i * step) * shape[0].x * radius, shape[0].y, Math.sin(i * step) * shape[0].x * radius));
            }
			
			for (p in 0...shape.length) {
				rotated = new Vector3(Math.cos(i * step) * shape[p].x * radius, shape[p].y , Math.sin(i * step) * shape[p].x * radius);
				path.push(rotated);
			}
			
			if (cap == Mesh.CAP_END || cap == Mesh.CAP_ALL) {
                path.push(new Vector3(Math.cos(i * step) * shape[shape.length - 1].x * radius, shape[shape.length - 1].y, Math.sin(i * step) * shape[shape.length - 1].x * radius));
                path.push(new Vector3(0, shape[shape.length - 1].y ,0));
            }
			
			paths.push(path);
		}
		
		// lathe ribbon
		var lathe = MeshBuilder.CreateRibbon(name, { pathArray: paths, closeArray: closed, sideOrientation: sideOrientation, updatable: updatable }, scene);
		
		return lathe;
	}
	
	public static function CreatePlane(name:String, options:Dynamic, scene:Scene):Mesh {
		var plane = new Mesh(name, scene);		
		var vertexData = VertexData.CreatePlane(options);
		
		vertexData.applyToMesh(plane, options.updatable);
		
		return plane;
	}
	
	public static function CreateGround(name:String, options:Dynamic, scene:Scene):Mesh {
		var ground = new GroundMesh(name, scene);
		ground._setReady(false);
		ground._subdivisions = options.subdivision != null ? options.subdivision : 1;
		
		var vertexData = VertexData.CreateGround(options);
		vertexData.applyToMesh(ground, options.updatable);
		ground._setReady(true);
		
		return ground;
	}
	
	public static function CreateTiledGround(name:String, options:Dynamic, scene:Scene):Mesh {
		var tiledGround = new Mesh(name, scene);
		var vertexData = VertexData.CreateTiledGround(options);
		vertexData.applyToMesh(tiledGround, options.updatable);
		
		return tiledGround;
	}
	
	public static function CreateGroundFromHeightMap(name:String, url:String, options:Dynamic, scene:Scene):GroundMesh {
		var width:Float = options.width != null ? options.width : 10;
		var height:Float = options.height != null ? options.height : 10;
		var subdivisions:Int = options.subdivisions != null ? options.subdivisions : 1;
		var minHeight:Float = options.minHeight != null ? options.minHeight : 0;
		var maxHeight:Float = options.maxHeight != null ? options.maxHeight : 10;
		var updatable:Bool = options.updatable;
		var onReady:GroundMesh->Void = options.onReady;
		
		var ground = new GroundMesh(name, scene);
		ground._subdivisions = subdivisions;
		ground._setReady(false);
		
		var onload = function(img:Image) {
			options.buffer = img.data;
			options.bufferWidth = img.width;
			options.bufferHeight = img.height;
			var vertexData = VertexData.CreateGroundFromHeightMap(options);
			vertexData.applyToMesh(ground, updatable);
			
			ground._setReady(true);
			
			//execute ready callback, if set
			if (onReady != null) {
				onReady(ground);
			}
		}
		
		Tools.LoadImage(url, onload);
		
		return ground;
	}
	
	public static function CreateTube(name:String, options:Dynamic, scene:Scene):Mesh {
		var path:Array<Vector3> = options.path;
		var radius:Float = options.radius != null ? options.radius : 1;
		var tessellation:Int = options.tessellation != null ? options.tessellation : 64;
		var radiusFunction:Int->Float->Float = options.radiusFunction;
		var cap:Int = options.cap != null ? options.cap : Mesh.NO_CAP;
		var updatable:Bool = options.updatable;
		var sideOrientation:Int = options.sideOrientation != null ? options.sideOrientation : Mesh.DEFAULTSIDE;
		var tubeInstance:Mesh = options.instance;
		
		// tube geometry
		var tubePathArray = function (path:Array<Vector3>, path3D:Path3D, circlePaths:Array<Array<Vector3>>, radius:Float, tessellation:Int, ?radiusFunction:Int->Float->Float, cap:Int, arc:Float = 1) {
			var tangents = path3D.getTangents();
			var normals = path3D.getNormals();
			var distances = path3D.getDistances();
			var pi2 = Math.PI * 2;
			var step = pi2 / tessellation;
			var returnRadius:Int->Float->Float = function(i:Int, distance:Float):Float { return radius; };
			var radiusFunctionFinal:Int->Float->Float = radiusFunction != null ? radiusFunction : returnRadius;
			
			var circlePath:Array<Vector3> = [];
			var rad:Float = 0;
			var normal:Vector3 = Vector3.Zero();
			var rotated:Vector3 = Vector3.Zero();
			var rotationMatrix:Matrix = Tmp.matrix[0];
			var index:Int = (cap == Mesh.NO_CAP || cap == Mesh.CAP_END) ? 2 : 0;
			for (i in 0...path.length) {
				rad = radiusFunctionFinal(i, distances[i]); // current radius
				circlePath = [];              				// current circle array
				normal = normals[i];          				// current normal  
				for (t in 0...tessellation) {
					Matrix.RotationAxisToRef(tangents[i], step * t, rotationMatrix);
					rotated = circlePath[t] != null ? circlePath[t] : Vector3.Zero();
					Vector3.TransformCoordinatesToRef(normal, rotationMatrix, rotated);
					rotated.scaleInPlace(rad).addInPlace(path[i]);
					circlePath[t] = rotated;
				}
				circlePaths[index] = circlePath;
				index++;
			}
			
			// cap
            var capPath = function(nbPoints:Int, pathIndex:Int):Array<Vector3> {
                var pointCap:Array<Vector3> = [];
                for(i in 0...nbPoints) {
                    pointCap.push(path[pathIndex]); 
                }
                return pointCap;
            };
			
            switch (cap) {
                case Mesh.NO_CAP:
                   
                case Mesh.CAP_START:
                    circlePaths.unshift(capPath(tessellation + 1, 0));
                    
                case Mesh.CAP_END:
                    circlePaths.push(capPath(tessellation + 1, path.length - 1));
                    
                case Mesh.CAP_ALL:
                    circlePaths.unshift(capPath(tessellation + 1, 0));
                    circlePaths.push(capPath(tessellation + 1, path.length - 1));
                    
                default:
                    //                   
            }
			
			return circlePaths;
		};
		
		if (tubeInstance != null) { // tube update
			var path3D = tubeInstance.path3D.update(path);
			var pathArray = tubePathArray(path, path3D, tubeInstance.pathArray, radius, tubeInstance.tessellation, radiusFunction, tubeInstance.cap);
			tubeInstance = MeshBuilder.CreateRibbon(null, { pathArray: pathArray, instance: tubeInstance }, scene);
			
			return tubeInstance;
		}
		
		// tube creation
		var path3D:Path3D = new Path3D(path);
		var newPathArray:Array<Array<Vector3>> = [];
		cap = (cap < 0 || cap > 3) ? 0 : cap;
        var pathArray = tubePathArray(path, path3D, newPathArray, radius, tessellation, radiusFunction, cap);
		var tube = MeshBuilder.CreateRibbon(name, { pathArray: pathArray, closeArray: false, closePath: true, offset: 0, updatable: updatable, sideOrientation: sideOrientation }, scene);
		tube.pathArray = pathArray;
		tube.path3D = path3D;
		tube.tessellation = tessellation;
		tube.cap = cap;
		
		return tube;
	}
	
	public static function CreatePolyhedron(name:String, options:Dynamic, scene:Scene):Mesh {
		var polyhedron = new Mesh(name, scene);		
		var vertexData = VertexData.CreatePolyhedron(options);
		vertexData.applyToMesh(polyhedron, options.updatable);
		
		return polyhedron;
	}
	
	static var CreateDecal_target:Vector3 = new Vector3(0, 0, 1);
	static var CreateDecal_cameraWorldTarget:Vector3 = new Vector3(0, 0, 0);
	static var decalWorldMatrix:Matrix = new Matrix();
	static var inverseDecalWorldMatrix:Matrix = new Matrix();
	static var CreateDecal_indices:Array<Int> = [];
	static var CreateDecal_positions:Array<Float> = [];
	static var CreateDecal_normals:Array<Float> = [];
	static var CreateDecal_meshWorldMatrix:Matrix = new Matrix();
	static var CreateDecal_transformMatrix:Matrix = new Matrix();
	static var CreateDecal_vertexData:VertexData = new VertexData();
    public static function CreateDecal(name:String, sourceMesh:AbstractMesh, options:Dynamic) {
		var position:Vector3 = options.position != null ? options.position : Vector3.Zero();
		var normal:Vector3 = options.normal;// != null ? options.normal : Vector3.Up();
		var size:Vector3 = options.size != null ? options.size : new Vector3(1, 1, 1);
		var angle:Float = options.angle;
		
        CreateDecal_indices = sourceMesh.getIndices();
        CreateDecal_positions = sourceMesh.getVerticesData(VertexBuffer.PositionKind);
        CreateDecal_normals = sourceMesh.getVerticesData(VertexBuffer.NormalKind);
		
        // Getting correct rotation
        if (normal == null) {
            var camera = sourceMesh.getScene().activeCamera;
            CreateDecal_cameraWorldTarget = Vector3.TransformCoordinates(CreateDecal_target, camera.getWorldMatrix());
			
            normal = camera.globalPosition.subtract(CreateDecal_cameraWorldTarget);
        }
		
        var yaw:Float = -Math.atan2(normal.z, normal.x) - Math.PI / 2;
        var len:Float = Math.sqrt(normal.x * normal.x + normal.z * normal.z);
        var pitch:Float = Math.atan2(normal.y, len);
		
        // Matrix
        decalWorldMatrix = Matrix.RotationYawPitchRoll(yaw, pitch, angle).multiply(Matrix.Translation(position.x, position.y, position.z));
        inverseDecalWorldMatrix = Matrix.Invert(decalWorldMatrix);
        CreateDecal_meshWorldMatrix = sourceMesh.getWorldMatrix();
        CreateDecal_transformMatrix = CreateDecal_meshWorldMatrix.multiply(inverseDecalWorldMatrix);
		
        CreateDecal_vertexData.indices = [];
        CreateDecal_vertexData.positions = [];
        CreateDecal_vertexData.normals = [];
        CreateDecal_vertexData.uvs = [];
		
        var currentCreateDecal_vertexDataIndex:Int = 0;
		
        var extractDecalVector3 = function(indexId:Int):PositionNormalVertex {
            var vertexId:Int = CreateDecal_indices[indexId];
            var result:PositionNormalVertex = new PositionNormalVertex();
            result.position = new Vector3(CreateDecal_positions[vertexId * 3], CreateDecal_positions[vertexId * 3 + 1], CreateDecal_positions[vertexId * 3 + 2]);
			
            // Send vector to decal local world
            result.position = Vector3.TransformCoordinates(result.position, CreateDecal_transformMatrix);
			
            // Get normal
            result.normal = new Vector3(CreateDecal_normals[vertexId * 3], CreateDecal_normals[vertexId * 3 + 1], CreateDecal_normals[vertexId * 3 + 2]);
			
            return result;
        }
        
        // Inspired by https://github.com/mrdoob/three.js/blob/eee231960882f6f3b6113405f524956145148146/examples/js/geometries/DecalGeometry.js
        var clip = function(vertices:Array<PositionNormalVertex>, axis:Vector3):Array<PositionNormalVertex> {
            if (vertices.length == 0) {
                return vertices;
            }
			
            var clipSize = 0.5 * Math.abs(Vector3.Dot(size, axis));
			
            var clipVertices = function(v0:PositionNormalVertex, v1:PositionNormalVertex):PositionNormalVertex {
                var clipFactor = Vector3.GetClipFactor(v0.position, v1.position, axis, clipSize);
				
                return new PositionNormalVertex(
                    Vector3.Lerp(v0.position, v1.position, clipFactor),
                    Vector3.Lerp(v0.normal, v1.normal, clipFactor)
                );
            }
			
            var result:Array<PositionNormalVertex> = [];
			
			var v1Out:Bool = false;
			var v2Out:Bool = false;
			var v3Out:Bool = false;
			var total = 0;
			var nV1:PositionNormalVertex = null;
			var nV2:PositionNormalVertex = null;
			var nV3:PositionNormalVertex = null;
			var nV4:PositionNormalVertex = null;
			
			var d1:Float = 0.0;
			var d2:Float = 0.0;
			var d3:Float = 0.0;
			
			var index = 0;
			while(index < vertices.length) {				
                d1 = Vector3.Dot(vertices[index].position, axis) - clipSize;
                d2 = Vector3.Dot(vertices[index + 1].position, axis) - clipSize;
                d3 = Vector3.Dot(vertices[index + 2].position, axis) - clipSize;
				
                v1Out = d1 > 0;
                v2Out = d2 > 0;
                v3Out = d3 > 0;
				
                total = (v1Out ? 1 : 0) + (v2Out ? 1 : 0) + (v3Out ? 1 : 0);
				
                switch (total) {
                    case 0:
                        result.push(vertices[index]);
                        result.push(vertices[index + 1]);
                        result.push(vertices[index + 2]);
                        
                    case 1:
                        if (v1Out) {
                            nV1 = vertices[index + 1];
                            nV2 = vertices[index + 2];
                            nV3 = clipVertices(vertices[index], nV1);
                            nV4 = clipVertices(vertices[index], nV2);
                        }
						
                        if (v2Out) {
                            nV1 = vertices[index];
                            nV2 = vertices[index + 2];
                            nV3 = clipVertices(vertices[index + 1], nV1);
                            nV4 = clipVertices(vertices[index + 1], nV2);
							
                            result.push(nV3);
                            result.push(nV2.clone());
                            result.push(nV1.clone());
							
                            result.push(nV2.clone());
                            result.push(nV3.clone());
                            result.push(nV4);
                            //break;
                        } else {
							if (v3Out) {
								nV1 = vertices[index];
								nV2 = vertices[index + 1];
								nV3 = clipVertices(vertices[index + 2], nV1);
								nV4 = clipVertices(vertices[index + 2], nV2);
							}
							
							result.push(nV1.clone());
							result.push(nV2.clone());
							result.push(nV3);
							
							result.push(nV4);
							result.push(nV3.clone());
							result.push(nV2.clone());
						}
                        
                    case 2:
                        if (!v1Out) {
                            nV1 = vertices[index].clone();
                            nV2 = clipVertices(nV1, vertices[index + 1]);
                            nV3 = clipVertices(nV1, vertices[index + 2]);
                            result.push(nV1);
                            result.push(nV2);
                            result.push(nV3);
                        }
                        if (!v2Out) {
                            nV1 = vertices[index + 1].clone();
                            nV2 = clipVertices(nV1, vertices[index + 2]);
                            nV3 = clipVertices(nV1, vertices[index]);
                            result.push(nV1);
                            result.push(nV2);
                            result.push(nV3);
                        }
                        if (!v3Out) {
                            nV1 = vertices[index + 2].clone();
                            nV2 = clipVertices(nV1, vertices[index]);
                            nV3 = clipVertices(nV1, vertices[index + 1]);
                            result.push(nV1);
                            result.push(nV2);
                            result.push(nV3);
                        }
                        
                    case 3:
                        //
                }
				
				index += 3;
            }
			
            return result;
        }
		
		var faceVertices:Array<PositionNormalVertex> = [];
		var index = 0;
		while(index < CreateDecal_indices.length) {
            faceVertices = [];
			
            faceVertices.push(extractDecalVector3(index));
            faceVertices.push(extractDecalVector3(index + 1));
            faceVertices.push(extractDecalVector3(index + 2));
			
            // Clip
            faceVertices = clip(faceVertices, new Vector3(1, 0, 0));
            faceVertices = clip(faceVertices, new Vector3(-1, 0, 0));
            faceVertices = clip(faceVertices, new Vector3(0, 1, 0));
            faceVertices = clip(faceVertices, new Vector3(0, -1, 0));
            faceVertices = clip(faceVertices, new Vector3(0, 0, 1));
            faceVertices = clip(faceVertices, new Vector3(0, 0, -1));
			
            if (faceVertices.length == 0) {
				index += 3;
                continue;
            }
              
            // Add UVs and get back to world
			var localRotationMatrix = Matrix.RotationYawPitchRoll(yaw, pitch, angle);
			var vertex:PositionNormalVertex = null;
            for (vIndex in 0...faceVertices.length) {
                vertex = faceVertices[vIndex];
				
                CreateDecal_vertexData.indices.push(currentCreateDecal_vertexDataIndex);
                vertex.position.toArray(CreateDecal_vertexData.positions, currentCreateDecal_vertexDataIndex * 3);
                vertex.normal.toArray(CreateDecal_vertexData.normals, currentCreateDecal_vertexDataIndex * 3);
                CreateDecal_vertexData.uvs.push(0.5 + vertex.position.x / size.x);
                CreateDecal_vertexData.uvs.push(0.5 + vertex.position.y / size.y);
				
                currentCreateDecal_vertexDataIndex++;
            }
			
			index += 3;
        }
		
        // Return mesh
        var decal = new Mesh(name, sourceMesh.getScene());
        CreateDecal_vertexData.applyToMesh(decal);
		
		decal.position = position.clone();
		decal.rotation = new Vector3(pitch, yaw, angle);
		
        return decal;
    }
	
	
	// Privates
	public static function _ExtrudeShapeGeneric(name:String, shape:Array<Vector3>, curve:Array<Vector3>, ?scale:Float, ?rotation:Float, ?scaleFunction:Float->Float->Float, ?rotateFunction:Float->Float->Float, rbCA:Bool, rbCP:Bool, cap:Int, custom:Bool, scene:Scene, updtbl:Bool, side:Int, instance:Mesh = null):Mesh {
		
		// extrusion geometry
		var extrusionPathArray = function(shape:Array<Vector3>, curve:Array<Vector3>, path3D:Path3D, shapePaths:Array<Array<Vector3>>, scale:Float, rotation:Float, scaleFunction:Int->Float->Float, rotateFunction:Int->Float->Float, cap:Int, custom:Bool = false) {
			var tangents:Array<Vector3> = path3D.getTangents();
			var normals:Array<Vector3> = path3D.getNormals();
			var binormals:Array<Vector3> = path3D.getBinormals();
			var distances:Array<Float> = path3D.getDistances();
			
			var angle:Float = 0;
			var returnScale = function(i:Float, distance:Float):Float { 
				return scale; 
			};
			var returnRotation = function(i:Float, distance:Float):Float { 
				return rotation; 
			};
			var rotate = rotateFunction != null ? rotateFunction : returnRotation;
			var scl = scaleFunction != null ? scaleFunction : returnScale;
			var index:Int = (cap == Mesh.NO_CAP || cap == Mesh.CAP_END) ? 0 : 2;
			var rotationMatrix:Matrix = Tmp.matrix[0];
			
			for (i in 0...curve.length) {
				var shapePath = new Array<Vector3>();
				var angleStep = rotate(i, distances[i]);
				var scaleRatio = scl(i, distances[i]);
				for (p in 0...shape.length) {
					Matrix.RotationAxisToRef(tangents[i], angle, rotationMatrix);
					var planed = ((tangents[i].scale(shape[p].z)).add(normals[i].scale(shape[p].x)).add(binormals[i].scale(shape[p].y)));
					var rotated = shapePath[p] != null ? shapePath[p] : Vector3.Zero();
					Vector3.TransformCoordinatesToRef(planed, rotationMatrix, rotated);
					rotated.scaleInPlace(scaleRatio).addInPlace(curve[i]);
					shapePath[p] = rotated;
				}
				shapePaths[index] = shapePath;
				angle += angleStep;
				index++;
			}
			
			// cap
            var capPath = function(shapePath:Array<Vector3>):Array<Vector3> {
                var pointCap:Array<Vector3> = [];
                var barycenter = Vector3.Zero();
                for (i in 0...shapePath.length) {
                    barycenter.addInPlace(shapePath[i]);
                }
                barycenter.scaleInPlace(1 / shapePath.length);
                for (i in 0...shapePath.length) {
                    pointCap.push(barycenter);
                }
                return pointCap;
            }
			
            switch (cap) {
                case Mesh.NO_CAP:
                    // nothing here...
					
                case Mesh.CAP_START:
                    shapePaths[0] = capPath(shapePaths[2]);
					shapePaths[1] = shapePaths[2].slice(0);
                    
                case Mesh.CAP_END:
                    shapePaths[index] = shapePaths[index - 1];
					shapePaths[index + 1] = capPath(shapePaths[index - 1]);
                    
                case Mesh.CAP_ALL:
                    shapePaths[0] = capPath(shapePaths[2]);
					shapePaths[1] = shapePaths[2].slice(0);
					shapePaths[index] = shapePaths[index - 1];
					shapePaths[index + 1] = capPath(shapePaths[index - 1]);
                    
                default:
                    //...
            }
			
			return shapePaths;
		};
		
		if (instance != null) { // instance update			
			var path3D = instance.path3D.update(curve);
			var pathArray = extrusionPathArray(shape, curve, instance.path3D, instance.pathArray, scale, rotation, scaleFunction, rotateFunction, instance.cap, custom);
			
			instance = Mesh.CreateRibbon(null, pathArray, false, false, 0, null, false, Mesh.DEFAULTSIDE, instance);
			
			return instance;
		}
		
		// extruded shape creation		
		var path3D:Path3D = new Path3D(curve);
		var newShapePaths:Array<Array<Vector3>> = [];
		cap = (cap < 0 || cap > 3) ? 0 : cap;
		var pathArray = extrusionPathArray(shape, curve, path3D, newShapePaths, scale, rotation, scaleFunction, rotateFunction, cap, custom);
		
		var extrudedGeneric = Mesh.CreateRibbon(name, pathArray, rbCA, rbCP, 0, scene, updtbl, side);
		extrudedGeneric.pathArray = pathArray;
		extrudedGeneric.path3D = path3D;
		extrudedGeneric.cap = cap;
		
		return extrudedGeneric;
	}

}
