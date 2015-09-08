package com.babylonhx.rendering;

import com.babylonhx.math.Vector3;
import com.babylonhx.materials.ShaderMaterial;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Matrix;
import com.babylonhx.mesh.WebGLBuffer;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.VertexBuffer;


/**
 * ...
 * @author Krtolica Vujadin
 */

class FaceAdjacencies {
	
	public var edges:Array<Int> = [];
	public var p0:Vector3;
	public var p1:Vector3;
	public var p2:Vector3;
	public var edgesConnectedCount:Int = 0;
	
	
	public function new() {
		//...
	}
	
}
 
class EdgesRenderer implements ISmartArrayCompatible {

	private var _source:AbstractMesh;
	private var _linesPositions:Array<Float> = [];
	private var _linesNormals:Array<Float> = [];
	private var _linesIndices:Array<Int> = [];
	private var _epsilon:Float;
	private var _indicesCount:Int;

	private var _lineShader:ShaderMaterial;
	private var _vb0:VertexBuffer;
	private var _vb1:VertexBuffer;
	private var _ib:WebGLBuffer;
	private var _buffers:Map<String, VertexBuffer> = new Map();
	
	public var __smartArrayFlags:Array<Int>;
	

	// Beware when you use this class with complex objects as the adjacencies computation can be really long
	public function new(source:AbstractMesh, epsilon:Float = 0.95) {
		this._source = source;
		
		this._epsilon = epsilon;
		
		this._prepareRessources();
		this._generateEdgesLines();
	}

	private function _prepareRessources() {
		if (this._lineShader != null) {
			return;
		}
		
		this._lineShader = new ShaderMaterial("lineShader", this._source.getScene(), "line",
			{
				attributes: ["position", "normal"],
				uniforms: ["worldViewProjection", "color", "width", "aspectRatio"]
			}
		);
			
		this._lineShader.disableDepthWrite = true;
		this._lineShader.backFaceCulling = false;
	}

	public function dispose() {
		this._vb0.dispose();
		this._vb1.dispose();
		this._source.getScene().getEngine()._releaseBuffer(this._ib);
		this._lineShader.dispose();
	}

	private function _processEdgeForAdjacencies(pa:Float, pb:Float, p0:Float, p1:Float, p2:Float):Int {
		if (pa == p0 && pb == p1 || pa == p1 && pb == p0) {
			return 0;
		}
		
		if (pa == p1 && pb == p2 || pa == p2 && pb == p1) {
			return 1;
		}
		
		if (pa == p2 && pb == p0 || pa == p0 && pb == p2) {
			return 2;
		}
		
		return -1;
	}

	private function _checkEdge(faceIndex:Int, edge:Int = -1, faceNormals:Array<Vector3>, p0:Vector3, p1:Vector3) {
		var needToCreateLine:Bool = false;
		
		if (edge == -1) {
			needToCreateLine = true;
		} 
		else {
			var dotProduct = Vector3.Dot(faceNormals[faceIndex], faceNormals[edge]);
			needToCreateLine = dotProduct < this._epsilon;
		}
		
		if (needToCreateLine) {
			var offset = Std.int(this._linesPositions.length / 3);
			var normal = p0.subtract(p1);
			normal.normalize();
			
			// Positions
			this._linesPositions.push(p0.x);
			this._linesPositions.push(p0.y);
			this._linesPositions.push(p0.z);
			
			this._linesPositions.push(p0.x);
			this._linesPositions.push(p0.y);
			this._linesPositions.push(p0.z);
			
			this._linesPositions.push(p1.x);
			this._linesPositions.push(p1.y);
			this._linesPositions.push(p1.z);
			
			this._linesPositions.push(p1.x);
			this._linesPositions.push(p1.y);
			this._linesPositions.push(p1.z);
			
			// Normals
			this._linesNormals.push(p1.x);
			this._linesNormals.push(p1.y);
			this._linesNormals.push(p1.z);
			this._linesNormals.push( -1);
			
			this._linesNormals.push(p1.x);
			this._linesNormals.push(p1.y);
			this._linesNormals.push(p1.z);
			this._linesNormals.push(1);
			
			this._linesNormals.push(p0.x);
			this._linesNormals.push(p0.y);
			this._linesNormals.push(p0.z);
			this._linesNormals.push( -1);
			
			this._linesNormals.push(p0.x);
			this._linesNormals.push(p0.y);
			this._linesNormals.push(p0.z);
			this._linesNormals.push(1);
			
			// Indices
			this._linesIndices.push(offset);
			this._linesIndices.push(offset + 1);
			this._linesIndices.push(offset + 2);
			this._linesIndices.push(offset);
			this._linesIndices.push(offset + 2);
			this._linesIndices.push(offset + 3);
		}
	}

	private function _generateEdgesLines() {
		var positions = this._source.getVerticesData(VertexBuffer.PositionKind);
		var indices = this._source.getIndices();
		
		// First let's find adjacencies
		var adjacencies = new Array<FaceAdjacencies>();
		var faceNormals = new Array<Vector3>();
		var faceAdjacencies:FaceAdjacencies;
		
		// Prepare faces
		var index:Int = 0;
		while (index < indices.length) {
			faceAdjacencies = new FaceAdjacencies();
			var p0Index = indices[index];
			var p1Index = indices[index + 1];
			var p2Index = indices[index + 2];
			
			faceAdjacencies.p0 = new Vector3(positions[p0Index * 3], positions[p0Index * 3 + 1], positions[p0Index * 3 + 2]);
			faceAdjacencies.p1 = new Vector3(positions[p1Index * 3], positions[p1Index * 3 + 1], positions[p1Index * 3 + 2]);
			faceAdjacencies.p2 = new Vector3(positions[p2Index * 3], positions[p2Index * 3 + 1], positions[p2Index * 3 + 2]);
			var faceNormal = Vector3.Cross(faceAdjacencies.p1.subtract(faceAdjacencies.p0), faceAdjacencies.p2.subtract(faceAdjacencies.p1));
			
			faceNormal.normalize();
			
			faceNormals.push(faceNormal);
			adjacencies.push(faceAdjacencies);
			
			index += 3;
		}
		
		// Scan
		for (index in 0...adjacencies.length) {
			faceAdjacencies = adjacencies[index];
			
			for (otherIndex in index + 1...adjacencies.length) {
				var otherFaceAdjacencies = adjacencies[otherIndex];
				
				if (faceAdjacencies.edgesConnectedCount == 3) { // Full
					break;
				}
				
				if (otherFaceAdjacencies.edgesConnectedCount == 3) { // Full
					continue;
				}
				
				var otherP0 = indices[otherIndex * 3];
				var otherP1 = indices[otherIndex * 3 + 1];
				var otherP2 = indices[otherIndex * 3 + 2];
				
				for (edgeIndex in 0...3) {
					var otherEdgeIndex:Int = 0;
					
					if (faceAdjacencies.edges.length < edgeIndex) {
						continue;
					}
					//if (faceAdjacencies.edges[edgeIndex] != null) {
						//continue;
					//}
					
					switch (edgeIndex) {
						case 0:
							otherEdgeIndex = this._processEdgeForAdjacencies(indices[index * 3], indices[index * 3 + 1], otherP0, otherP1, otherP2);
							
						case 1:
							otherEdgeIndex = this._processEdgeForAdjacencies(indices[index * 3 + 1], indices[index * 3 + 2], otherP0, otherP1, otherP2);
							
						case 2:
							otherEdgeIndex = this._processEdgeForAdjacencies(indices[index * 3 + 2], indices[index * 3], otherP0, otherP1, otherP2);
							
					}
					
					if (otherEdgeIndex == -1) {
						continue;
					}
					
					faceAdjacencies.edges[edgeIndex] = otherIndex;
					otherFaceAdjacencies.edges[otherEdgeIndex] = index;
					
					faceAdjacencies.edgesConnectedCount++;
					otherFaceAdjacencies.edgesConnectedCount++;
					
					if (faceAdjacencies.edgesConnectedCount == 3) {
						break;
					}
				}
			}
		}
		
		// Create lines
		for (index in 0...adjacencies.length) {
			// We need a line when a face has no adjacency on a specific edge or if all the adjacencies has an angle greater than epsilon
			var current = adjacencies[index];
			
			this._checkEdge(index, current.edges[0], faceNormals, current.p0, current.p1);
			this._checkEdge(index, current.edges[1], faceNormals, current.p1, current.p2);
			this._checkEdge(index, current.edges[2], faceNormals, current.p2, current.p0);
		}
		
		// Merge into a single mesh
		var engine = this._source.getScene().getEngine();
		this._vb0 = new VertexBuffer(engine, this._linesPositions, VertexBuffer.PositionKind, false);
		this._vb1 = new VertexBuffer(engine, this._linesNormals, VertexBuffer.NormalKind, false, false, 4);
		
		this._buffers[VertexBuffer.PositionKind] = this._vb0;
		this._buffers[VertexBuffer.NormalKind] = this._vb1;
		
		this._ib = engine.createIndexBuffer(this._linesIndices);
		
		this._indicesCount = this._linesIndices.length;
	}

	public function render() {
		if (!this._lineShader.isReady()) {
			return;
		}
		
		var scene = this._source.getScene();
		var engine = scene.getEngine();
		this._lineShader._preBind();
		
		// VBOs
		engine.bindMultiBuffers(this._buffers, this._ib, this._lineShader.getEffect());
		
		scene.resetCachedMaterial();
		this._lineShader.setColor4("color", this._source.edgesColor);
		this._lineShader.setFloat("width", this._source.edgesWidth / 50.0);
		this._lineShader.setFloat("aspectRatio", engine.getAspectRatio(scene.activeCamera));
		this._lineShader.bind(this._source.getWorldMatrix());
		
		// Draw order
		engine.draw(true, 0, this._indicesCount);
		this._lineShader.unbind();
		engine.setDepthWrite(true);
	}
	
}
