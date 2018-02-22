package com.babylonhx.postprocess;

import com.babylonhx.engine.Engine;
import com.babylonhx.cameras.Camera;
import com.babylonhx.math.Vector2;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.tools.EventState;
import com.babylonhx.math.Tools;

/**
 * ...
 * @author Krtolica Vujadin
 */
/**
 * The Blur Post Process which blurs an image based on a kernel and direction. 
 * Can be used twice in x and y directions to perform a guassian blur in two passes.
 */
@:expose('BABYLON.BlurPostProcess') class BlurPostProcess extends PostProcess {
	
	/** The direction in which to blur the image. */
	public var direction:Vector2;
	
	private var _kernel:Float;
	private var _idealKernel:Float;
	private var _packedFloat:Bool = false;
	private var _staticDefines:String = "";

	/**
	 * Sets the length in pixels of the blur sample region
	 */
	public var kernel(get, set):Float;
	private function set_kernel(v:Float):Float {
		if (this._idealKernel == v) {
			return v;
		}
		
		v = Math.max(v, 1);
		this._idealKernel = v;
		this._kernel = this._nearestBestKernel(v);
		this._updateParameters();
		return v;
	}
	/**
	 * Gets the length in pixels of the blur sample region
	 */
	inline private function get_kernel():Float {
		return this._idealKernel;
	}
	
	public var packedFloat(get, set):Bool;
	/**
	 * Sets wether or not the blur needs to unpack/repack floats
	 */
	private function set_packedFloat(v:Bool):Bool {
		if (this._packedFloat == v) {
			return v;
		}
		this._packedFloat = v;
		this._updateParameters();
		return v;
	}
	/**
	 * Gets wether or not the blur is unpacking/repacking floats
	 */
	private function get_packedFloat():Bool {
		return this._packedFloat;
	}

	
	/**
	 * Creates a new instance of @see BlurPostProcess
	 * @param name The name of the effect.
	 * @param direction The direction in which to blur the image.
	 * @param kernel The size of the kernel to be used when computing the blur. eg. Size of 3 will blur the center pixel by 2 pixels surrounding it.
	 * @param options The required width/height ratio to downsize to before computing the render pass. (Use 1.0 for full size)
	 * @param camera The camera to apply the render pass to.
	 * @param samplingMode The sampling mode to be used when computing the pass. (default: 0)
	 * @param engine The engine which the post process will be applied. (default: current engine)
	 * @param reusable If the post process can be reused on the same frame. (default: false)
	 * @param textureType Type of textures used when performing the post process. (default: 0)
	 */
	public function new(name:String, direction:Vector2, kernel:Float, options:Dynamic, camera:Camera = null, samplingMode:Int = Texture.BILINEAR_SAMPLINGMODE, ?engine:Engine, reusable:Bool = false, textureType:Int = Engine.TEXTURETYPE_UNSIGNED_INT, defines:String = "") {
		this.direction = direction;
		super(name, "kernelBlur", ["delta", "direction"], null, options, camera, samplingMode, engine, reusable, null, textureType, "kernelBlur", {varyingCount: 0, depCount: 0}, true);
		this._staticDefines = defines;
		this.onApplyObservable.add(function(effect:Effect, _) {
			effect.setFloat2('delta', (1 / this.width) * this.direction.x, (1 / this.height) * this.direction.y);
		});
		
		this.kernel = kernel;
	}

	public function _updateParameters() {
		// Generate sampling offsets and weights
		var N = Std.int(this._kernel);
		var centerIndex = Std.int((N - 1) / 2);
		
		// Generate Gaussian sampling weights over kernel
		var offsets:Array<Float> = [];
		var weights:Array<Float> = [];
		var totalWeight:Float = 0;
		for (i in 0...N) {
			var u = i / (N - 1);
			var w = this._gaussianWeight(u * 2.0 - 1);
			offsets[i] = (i - centerIndex);
			weights[i] = w;
			totalWeight += w;
		}
		
		// Normalize weights
		for (i in 0...weights.length) {
			weights[i] /= totalWeight;
		}
		
		// Optimize: combine samples to take advantage of hardware linear sampling
		// Walk from left to center, combining pairs (symmetrically)
		var linearSamplingWeights:Array<Float> = [];
		var linearSamplingOffsets:Array<Float> = [];
		
		var linearSamplingMap:Array<Dynamic> = [];
		
		var i:Int = 0;
		while (i <= centerIndex) {
			var j = Std.int(Math.min(i + 1, Math.floor(centerIndex)));
			
			var singleCenterSample = i == j;
			
			if (singleCenterSample) {
				linearSamplingMap.push({ o: offsets[i], w: weights[i] });
			} 
			else {
				var sharedCell = j == centerIndex;
				
				var weightLinear = (weights[i] + weights[j] * (sharedCell ? 0.5 : 1.0));
				var offsetLinear = offsets[i] + 1 / (1 + weights[i] / weights[j]);
				
				if (offsetLinear == 0) {
					linearSamplingMap.push({ o: offsets[i], w: weights[i] });
					linearSamplingMap.push({ o: offsets[i + 1], w: weights[i + 1] });
				} 
				else {
					linearSamplingMap.push({ o: offsetLinear, w: weightLinear });
					linearSamplingMap.push({ o: -offsetLinear, w: weightLinear });
				}
			}
			
			i += 2;
		}
		
		for (i in 0...linearSamplingMap.length) {
			linearSamplingOffsets[i] = linearSamplingMap[i].o;
			linearSamplingWeights[i] = linearSamplingMap[i].w;
		}
		
		// Replace with optimized
		offsets = linearSamplingOffsets;
		weights = linearSamplingWeights;
		
		// Generate shaders
		var maxVaryingRows = this.getEngine().getCaps().maxVaryingVectors;
		var freeVaryingVec2 = Std.int(Math.max(maxVaryingRows, 0.0)) - 1; // Because of sampleCenter
		
		var varyingCount = Math.floor(Math.min(offsets.length, freeVaryingVec2));
		
		var defines = "";
		defines += this._staticDefines;
		for (i in 0...varyingCount) {
			defines += '#define KERNEL_OFFSET${i} ${this._glslFloat(offsets[i])}\r\n';
			defines += '#define KERNEL_WEIGHT${i} ${this._glslFloat(weights[i])}\r\n';
		}
		
		var depCount = 0;
		for (i in freeVaryingVec2...offsets.length) {
			defines += '#define KERNEL_DEP_OFFSET${depCount} ${this._glslFloat(offsets[i])}\r\n';
			defines += '#define KERNEL_DEP_WEIGHT${depCount} ${this._glslFloat(weights[i])}\r\n';
			depCount++;
		}
		
		if (this.packedFloat) {
			defines += "#define PACKEDFLOAT 1";
		}
		
		this.updateEffect(defines, null, null, {
			varyingCount: varyingCount,
			depCount: depCount
		});
	}

	/**
	 * Best kernels are odd numbers that when divided by 2, their integer part is even, so 5, 9 or 13.
	 * Other odd kernels optimize correctly but require proportionally more samples, even kernels are
	 * possible but will produce minor visual artifacts. Since each new kernel requires a new shader we
	 * want to minimize kernel changes, having gaps between physical kernels is helpful in that regard.
	 * The gaps between physical kernels are compensated for in the weighting of the samples
	 * @param idealKernel Ideal blur kernel.
	 * @return Nearest best kernel.
	 */
	public function _nearestBestKernel(idealKernel:Float):Float {
		var v = Math.round(idealKernel);
		for (k in [v, v - 1, v + 1, v - 2, v + 2]) {
			if (((k % 2) != 0) && ((Math.floor(k / 2) % 2) == 0) && k > 0) {
				return Math.max(k, 3);
			}
		}
		return Math.max(v, 3);
	}

	/**
	 * Calculates the value of a Gaussian distribution with sigma 3 at a given point.
	 * @param x The point on the Gaussian distribution to sample.
	 * @return the value of the Gaussian function at x.
	 */
	public function _gaussianWeight(x:Float):Float {
		// reference: Engine/ImageProcessingBlur.cpp #dcc760
		// We are evaluating the Gaussian (normal) distribution over a kernel parameter space of [-1,1],
		// so we truncate at three standard deviations by setting stddev (sigma) to 1/3.
		// The choice of 3-sigma truncation is common but arbitrary, and means that the signal is
		// truncated at around 1.3% of peak strength.
		
		//the distribution is scaled to account for the difference between the actual kernel size and the requested kernel size
		var sigma = (1 / 3);
		var denominator = Math.sqrt(2.0 * Math.PI) * sigma;
		var exponent = -((x * x) / (2.0 * sigma * sigma));
		var weight = (1.0 / denominator) * Math.exp(exponent);
		return weight;
	}      

	/**
	 * Generates a string that can be used as a floating point number in GLSL.
	 * @param x Value to print.
	 * @param decimalFigures Number of decimal places to print the number to (excluding trailing 0s).
	 * @return GLSL float string.
	 */
	public function _glslFloat(x:Float, decimalFigures:Int = 8):String {
		var ereg:EReg = ~/0+$/;
		return ereg.replace(Tools.FloatToStringPrecision(x, decimalFigures) + '', '');
	} 

}
