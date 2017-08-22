package com.babylonhx.math.coherentnoise.generation.voronoi;


/// <summary>
/// Base class for 2D Voronoi diagrams generators. Voronoi diagrams use a set of control points, that are somehow distributed, and for every point calculate distances to the closest control points.
/// These distances are then combined to obtain final noise value.
/// This generator distributes control points by randomly displacing points with integer coordinates. Thus, every unit-sized cube will have a single control point in it,
/// randomly placed.
/// 2D version is faster, but ignores Z coordinate.
/// </summary>
class VoronoiDiagramBase2D extends Generator {

	private var m_ControlPointSource:Array<LatticeNoise>;

	/// <summary>
	/// Create new Voronoi diagram using seed. Control points will be obtained using random displacment seeded by supplied value
	/// </summary>
	/// <param name="seed">Seed value</param>
	public function new(seed:Int) {
		super(0);
		
		Frequency = 1;
		m_ControlPointSource = [new LatticeNoise(seed), new LatticeNoise(seed + 1)];
	}

	/// <summary>
	/// Noise period. Used for repeating (seamless) noise.
	/// When Period &gt;0 resulting noise pattern repeats exactly every Period, for all coordinates.
	/// </summary>
	public var Period:Int;

	// #region Overrides of Noise

	/// <summary>
	///  Returns noise value at given point. 
	///  </summary>
	/// <param name="x">X coordinate</param>
	/// <param name="y">Y coordinate</param>
	/// <param name="z">Z coordinate</param>
	/// <returns>Noise value</returns>
	override public function GetValue(x:Float, y:Float, z:Float):Float {
		if (Period > 0) {
			// make periodic lattice. Repeat every Period cells
			x = x % Period; 
			if (x < 0) {
				x += Period;
			}
			
			y = y % Period; 
			if (y < 0) {
				y += Period;
			}
		}
		
		// stretch values to match desired frequency
		x *= Frequency;
		y *= Frequency;
		
		var min1 = Math.POSITIVE_INFINITY;
		var min2 = Math.POSITIVE_INFINITY;
		var min3 = Math.POSITIVE_INFINITY;
		
		var xc = Math.floor(x);
		var yc = Math.floor(y);
		
		var v = new Vector2(x, y);
		
		for (ii in xc - 1...xc + 2) {
			for (jj in yc - 1...yc + 2) {
				var displacement = new Vector2(m_ControlPointSource[0].GetValue(ii, jj, 0) * 0.5 + 0.5, m_ControlPointSource[1].GetValue(ii, jj, 0) * 0.5 + 0.5);
				
				var cp = (new Vector2(ii, jj)).add(displacement);
				var distance = (cp.addInPlace(v)).lengthSquared();
				
				if (distance < min1) {
					min3 = min2;
					min2 = min1;
					min1 = distance;
				}
				else if (distance < min2) {
					min3 = min2;
					min2 = distance;
				}
				else if (distance < min3) {
					min3 = distance;
				}
			}
		}
		
		return GetResult(Math.sqrt(min1), Math.sqrt(min2), Math.sqrt(min3));
	}

	/// <summary>
	/// Override this method to calculate final value using distances to closest control points.
	/// Note that distances that get passed to this function are adjusted for frequency (i.e. distances are scaled so that 
	/// control points are in unit sized cubes)
	/// </summary>
	/// <param name="min1">Distance to closest point</param>
	/// <param name="min2">Distance to second-closest point</param>
	/// <param name="min3">Distance to third-closest point</param>
	/// <returns></returns>
	public function GetResult(min1:Float, min2:Float, min3:Float):Float {
		return 0;
	}

	// #endregion

	/// <summary>
	/// Frequency of control points. This has the same effect as applying <see cref="Scale"/> transform to the generator, or placing control points closer together (for high frequency) or further apart (for low frequency)
	/// </summary>
	public var Frequency:Float;

}
