package com.babylonhx.loading.plugins.ctmfileloader.compression;

import haxe.ds.Vector;

/**
 * ...
 * @author Krtolica Vujadin
 */ 
class CommonAlgorithms {

	/**
     * Calculate inverse derivatives of the vertices.
     */
    public static function restoreVertices(intVertices:Array<Int>, gridIndices:Array<Int>, grid:Grid, vertexPrecision:Float):Array<Float> {
        var ve:Int = CTM_POSITION_ELEMENT_COUNT;
        var vc:Int = Std.int(intVertices.length / ve);
		
        var prevGridIndex:Int = 0x7fffffff;
        var prevDeltaX:Int = 0;
        var vertices:Vector<Float> = new Vector<Float>(vc * ve);
        for (i in 0...vc) {
            // Get grid box origin
            var gridIdx:Int = gridIndices[i];
            var gridOrigin:Array<Float> = gridIdxToPoint(grid, gridIdx);
			
            // Restore original point
            var deltaX = intVertices[i * ve];
            if (gridIdx == prevGridIndex) {
                deltaX += prevDeltaX;
            }
            vertices[i * ve] = vertexPrecision * deltaX + gridOrigin[0];
            vertices[i * ve + 1] = vertexPrecision * intVertices[Std.int(i * ve + 1)] + gridOrigin[1];
            vertices[i * ve + 2] = vertexPrecision * intVertices[Std.int(i * ve + 2)] + gridOrigin[2];
			
            prevGridIndex = gridIdx;
            prevDeltaX = deltaX;
        }
		
        return vertices;
    }

    /**
     * Convert a grid index to a point (the min x/y/z for the given grid box).
     */
    public static var gridIdxToPoint(grid:Grid, idx:Int):Array<Float> {
        var gridIdx:Vector<Int> = new Vector<Int>(3);
		
        var ydiv:Int = grid.getDivision()[0];
        var zdiv:Int = ydiv * grid.getDivision()[1];
		
        gridIdx[2] = idx / zdiv;
        idx -= gridIdx[2] * zdiv;
        gridIdx[1] = idx / ydiv;
        idx -= gridIdx[1] * ydiv;
        gridIdx[0] = idx;
		
        var size:Array<Float> = grid.getSize();
        var point:Vector<Float> = new Vector<Float>(3);
        for (i in 0...3) {
            point[i] = gridIdx[i] * size[i] + grid.getMin()[i];
        }
		
        return point;
    }

    /**
     * Calculate the smooth normals for a given mesh. These are used as the
     * nominal normals for normal deltas & reconstruction.
     */
    public static function calcSmoothNormals(vertices:Array<Float>, indices:Array<Int>):Array<Float> {
        var vc:Int = Std.int(vertices.length / CTM_POSITION_ELEMENT_COUNT);
        var tc:Int = Std.int(indices.length / 3);
        var smoothNormals:Vector<Float> = new Vector<Float>(Std.int(vc * CTM_NORMAL_ELEMENT_COUNT));//no setting to 0 needed in Java compared to C
		
        // Calculate sums of all neighboring triangle normals for each vertex
        for (i in 0...tc) {
            // Get triangle corner indices
            var tri:Array<Int> = indices.slice(Std.int(i * 3), Std.int(i * 3 + 3));
			
            // Calculate the normalized cross product of two triangle edges (i.e. the
            // flat triangle normal)
            var v1:Vector<Float> = new Vector<Float>(3);
            var v2:Vector<Float> = new Vector<Float>(3);
            for (j in 0...3) {
                v1[j] = vertices[tri[1] * 3 + j] - vertices[tri[0] * 3 + j];
                v2[j] = vertices[tri[2] * 3 + j] - vertices[tri[0] * 3 + j];
            }
            
			var n:Vector<Float> = new Vector<Float>(3);
            n[0] = v1[1] * v2[2] - v1[2] * v2[1];
            n[1] = v1[2] * v2[0] - v1[0] * v2[2];
            n[2] = v1[0] * v2[1] - v1[1] * v2[0];
            var len:Float = Math.sqrt(n[0] * n[0] + n[1] * n[1] + n[2] * n[2]);
            if (len > 1e-10f) {
                len = 1.0f / len;
            } 
			else {
                len = 1.0f;
            }
            for (j in 0...3) {
                n[j] *= len;
            }
			
            // Add the flat normal to all three triangle vertices
            for (k in 0...3) {
                for (j in 0...3) {
                    smoothNormals[tri[k] * 3 + j] += n[j];
                }
            }
        }
		
        // Normalize the normal sums, which gives the unit length smooth normals
        for (i in 0...vc) {
            var len:Float = Math.sqrt(smoothNormals[i * 3] * smoothNormals[i * 3]
                                     + smoothNormals[i * 3 + 1] * smoothNormals[i * 3 + 1]
                                     + smoothNormals[i * 3 + 2] * smoothNormals[i * 3 + 2]);
            if (len > 1e-10f) {
                len = 1.0f / len;
            } 
			else {
                len = 1.0f;
            }
            for (j in 0...3) {
                smoothNormals[i * 3 + j] *= len;
            }
        }
		
        return smoothNormals;
    }

    /**
     * Create an ortho-normalized coordinate system where the Z-axis is aligned
     * with the given normal. Note 1: This function is central to how the
     * compressed normal data is interpreted, and it can not be changed
     * (mathematically) without making the coder/decoder incompatible with other
     * versions of the library! Note 2: Since we do this for every single
     * normal, this routine needs to be fast. The current implementation uses:
     * 12 MUL, 1 DIV, 1 SQRT, ~6 ADD.
     */
    public static function makeNormalCoordSys(normals:Array<Float>, offset:Int):Array<Float> {
        var m:Vector<Float> = new Vector<Float>(9);
        m[6] = normals[offset];
        m[7] = normals[offset + 1];
        m[8] = normals[offset + 2];
		
        // Calculate a vector that is guaranteed to be orthogonal to the normal, non-
        // zero, and a continuous function of the normal (no discrete jumps):
        // X = (0,0,1) x normal + (1,0,0) x normal
        m[0] = -normals[offset + 1];
        m[1] = normals[offset] - normals[offset + 2];
        m[2] = normals[offset + 1];
		
        // Normalize the new X axis (note: |x[2]| = |x[0]|)
        var len:Float = Math.sqrt(2.0 * m[0] * m[0] + m[1] * m[1]);
        if (len > 1.0e-20f) {
            len = 1.0f / len;
            m[0] *= len;
            m[1] *= len;
            m[2] *= len;
        }
		
        // Let Y = Z x X  (no normalization needed, since |Z| = |X| = 1)
        m[3 + 0] = m[6 + 1] * m[2] - m[6 + 2] * m[1];
        m[3 + 1] = m[6 + 2] * m[0] - m[6 + 0] * m[2];
        m[3 + 2] = m[6 + 0] * m[1] - m[6 + 1] * m[0];
		
        return m;
    }
	
}
