package com.babylonhx.math.coherentnoise.generation.patterns;


///<summary>
/// This generator does the opposite of texture generation. It takes a texture and returns its red channel as a noise value.
/// Use it to incorporate hand-created patterns in your generation.
///</summary>
class TexturePattern extends Generator {

	private var m_Colors:Array<RGBA>;
	private var m_Width:Int;
	private var m_Height:Int;
	private var m_WrapMode:TextureAddressing;

	///<summary>
	/// Create new texture generator
	///</summary>
	///<param name="texture">Texture to use. It must be readable. The texture is read in constructor, so any later changes to it will not affect this generator</param>
	///<param name="wrapMode">Wrapping mode</param>
	public function new(texture:Texture, wrapMode:TextureAddressing) {
		super();
		
		m_Colors = cast texture.img.lock().getData();
		m_Width = texture.width;
		m_Height = texture.height;

		m_WrapMode = wrapMode;
	}

	// #region Overrides of Noise

	/// <summary>
	///  Returns noise value at given point. 
	///  </summary>
	/// <param name="x">X coordinate</param>
	/// <param name="y">Y coordinate</param>
	/// <param name="z">Z coordinate</param><returns>Noise value</returns>
	override public function GetValue(x:Float, y:Float, z:Float):Float {
		var ix = Math.floor(x * m_Width);
		var iy = Math.floor(y * m_Height);
		ix = Wrap(ix, m_Width);
		iy = Wrap(iy, m_Height);
		var c = m_Colors[iy * m_Width + ix];
		
		return c.Rb * 2 - 1;
	}

	private function Wrap(i:Int, size:Int):Int {
		switch (m_WrapMode) {
			case TextureAddressing.Repeat:
				return i >= 0 ? i % size : (i % size + size);
				
			case TextureAddressing.Clamp:
				return i < 0 ? 0 : i > size ? size - 1 : i;
				
			default:
				throw 'invalid wrap mode';
		}
	}

	// #endregion

}
