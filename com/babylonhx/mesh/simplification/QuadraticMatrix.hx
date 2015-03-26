package com.babylonhx.mesh.simplification;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.QuadraticMatrix') class QuadraticMatrix {
	
	public var data:Array<Float>;

	
	public function new(?data:Array<Float>) {
		this.data = [];
		
		if(data != null) {
			for (i in 0...10) {
				if (i <= data.length) {
					this.data[i] = data[i];
				} else {
					this.data[i] = 0;
				}
			}
		}
	}

	public function det(a11:Int, a12:Int, a13:Int, a21:Int, a22:Int, a23:Int, a31:Int, a32:Int, a33:Int):Float {
		var det = this.data[a11] * this.data[a22] * this.data[a33] + this.data[a13] * this.data[a21] * this.data[a32] +
			this.data[a12] * this.data[a23] * this.data[a31] - this.data[a13] * this.data[a22] * this.data[a31] -
			this.data[a11] * this.data[a23] * this.data[a32] - this.data[a12] * this.data[a21] * this.data[a33];
			
		return det;
	}

	public function addInPlace(matrix:QuadraticMatrix) {
		for (i in 0...10) {
			this.data[i] += matrix.data[i];
		}
	}

	public function addArrayInPlace(data:Array<Float>) {
		for (i in 0...10) {
			this.data[i] += data[i];
		}
	}

	public function add(matrix:QuadraticMatrix):QuadraticMatrix {
		var m = new QuadraticMatrix();
		for (i in 0...10) {
			m.data[i] = this.data[i] + matrix.data[i];
		}
		
		return m;
	}

	public static function FromData(a:Float, b:Float, c:Float, d:Float):QuadraticMatrix {
		return new QuadraticMatrix(QuadraticMatrix.DataFromNumbers(a, b, c, d));
	}

	//returning an array to avoid garbage collection
	public static function DataFromNumbers(a:Float, b:Float, c:Float, d:Float):Array<Float> {
		return [a * a, a * b, a * c, a * d, b * b, b * c, b * d, c * c, c * d, d * d];
	}
	
}
	