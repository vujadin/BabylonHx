package com.babylonhx.math.coherentnoise.generation.voronoi;


/// <summary>
/// Voronoi cell diagram uses a set of control points to partition space into cells. Each point in space belongs to a cell that corresponds to closest control point.
/// This generator distributes control points using a vector noise source, that displaces points with integer coordinates. Thus, every unit-sized cube will have a single control point in it,
/// randomly placed. A user-supplied function is then used to obtain cell value for a given point.
/// </summary>
class VoronoiCells extends Generator {

	private var m_CellValueSource:Int->Int->Int->Float;
	private var m_ControlPointSource:Array<LatticeNoise>;

	/// <summary>
	/// Create new Voronoi diagram using seed. Control points will be obtained using random displacment seeded by supplied value
	/// </summary>
	/// <param name="seed">Seed value</param>
	/// <param name="cellValueSource">Function that returns cell's value</param>
	public function new(seed:Int, cellValueSource:Int->Int->Int->Float) {
		super(0);
		
		Frequency = 1;
		m_ControlPointSource = [new LatticeNoise(seed), new LatticeNoise(seed + 1), new LatticeNoise(seed + 2)];
		m_CellValueSource = cellValueSource;
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
	/// <param name="z">Z coordinate</param><returns>Noise value</returns>
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
			
			z = z % Period; 
			if (z < 0) {
				z += Period;
			}
		}
		
		x *= Frequency;
		y *= Frequency;
		z *= Frequency;
		var min:Float = Math.POSITIVE_INFINITY;
		var ix = 0;
		var iy = 0;
		var iz = 0;
		
		var xc = Math.floor(x);
		var yc = Math.floor(y);
		var zc = Math.floor(z);
		
		var v = new Vector3(x, y, z);
		
		for (ii in xc - 1...xc + 2) {
			for (jj in yc - 1...yc + 2) {
				for (kk in zc - 1...zc + 2) {
					var displacement = new Vector3(
						m_ControlPointSource[0].GetValue(ii, jj, kk) * 0.5 + 0.5,
						m_ControlPointSource[1].GetValue(ii, jj, kk) * 0.5 + 0.5,
						m_ControlPointSource[2].GetValue(ii, jj, kk) * 0.5 + 0.5
					);
					
					var cp:Vector3 = new Vector3(ii, jj, kk).add(displacement);
					var distance = (cp.subtract(v)).lengthSquared();
					
					if (distance < min) {
						min = distance;
						ix = ii;
						iy = jj;
						iz = kk;
					}
				}
			}
		}
		
		return m_CellValueSource(ix, iy, iz);
	}

	// #endregion;

	/// <summary>
	/// Frequency of control points. This has the same effect as applying <see cref="Scale"/> transform to the generator, or placing control points closer together (for high frequency) or further apart (for low frequency)
	/// </summary>
	public var Frequency:Float;

}
