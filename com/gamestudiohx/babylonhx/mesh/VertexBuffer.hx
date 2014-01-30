package com.gamestudiohx.babylonhx.mesh;

import com.gamestudiohx.babylonhx.Engine;
import com.gamestudiohx.babylonhx.mesh.Mesh.BabylonGLBuffer;
import openfl.utils.Float32Array;


/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class VertexBuffer {
	
	public static var PositionKind:String           = "position";
    public static var NormalKind:String             = "normal";
    public static var UVKind:String                 = "uv";
    public static var UV2Kind:String                = "uv2";
    public static var ColorKind:String              = "color";
    public static var MatricesIndicesKind:String    = "matricesIndices";
    public static var MatricesWeightsKind:String    = "matricesWeights";
	
	public var _mesh:Mesh;
	public var _engine:Engine;
	public var _updatable:Bool;
	
	public var _buffer:BabylonGLBuffer;	
	public var _data:Array<Float>;		
	public var _kind:String;
	
	public var _strideSize:Int;
	

	public function new(mesh:Mesh, data:Array<Float>, kind:String, updatable:Bool) {
		this._mesh = mesh;
        this._engine = mesh.getScene().getEngine();
        this._updatable = updatable;
        
        if (updatable) {
            this._buffer = this._engine.createDynamicVertexBuffer(data.length * 4);
            this._engine.updateDynamicVertexBuffer(this._buffer, data);
        } else {
            this._buffer = this._engine.createVertexBuffer(data);
        }

        this._data = data;
        this._kind = kind;

        switch (kind) {
            case VertexBuffer.PositionKind:
                this._strideSize = 3;
                this._mesh._resetPointsArrayCache();
            case VertexBuffer.NormalKind:
                this._strideSize = 3;
            case VertexBuffer.UVKind:
                this._strideSize = 2;
            case VertexBuffer.UV2Kind:
                this._strideSize = 2;
            case VertexBuffer.ColorKind:
                this._strideSize = 3;
            case VertexBuffer.MatricesIndicesKind:
                this._strideSize = 4;
            case VertexBuffer.MatricesWeightsKind:
                this._strideSize = 4;
			default:
				//
        }
	}
	
	public function isUpdatable():Bool {
        return this._updatable;
    }

    public function getData():Array<Float> {
        return this._data;
    }
    
    public function getStrideSize():Int {
        return this._strideSize;
    }
    
    public function update(data:Array<Float>) {
        this._engine.updateDynamicVertexBuffer(this._buffer, data);
        this._data = data;
        
        if (this._kind == PositionKind) {
            this._mesh._resetPointsArrayCache();
        }
    }

    public function dispose() {
        this._engine._releaseBuffer(this._buffer);
    }
	
}
