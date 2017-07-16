package com.babylonhx.canvas2d;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Render2DContext {

	/**
	 * If true hardware instancing is supported and must be used for the rendering. The groupInfoPartData._partBuffer must be used.
	 * If false rendering on a per primitive basis must be made. The following properties must be used
	 *  - groupInfoPartData._partData: contains the primitive instances data to render
	 *  - partDataStartIndex: the index into instanceArrayData of the first instance to render.
	 *  - partDataCount: the number of primitive to render
	 */
	public var useInstancing:Bool;

	/**
	 * If specified, must take precedence from the groupInfoPartData. partIndex is the same as groupInfoPardData
	 */
	public var instancedBuffers:Array<WebGLBuffer>;

	/**
	 * To use when instancedBuffers is specified, gives the count of instances to draw
	 */
	public var instancesCount:Int;

	/**
	 * Contains the data related to the primitives instances to render
	 */
	public var groupInfoPartData:Array<GroupInfoPartData>;

	/**
	 * The index into groupInfoPartData._partData of the first primitive to render. 
	 * This is an index, not an offset: it represent the nth primitive which is the first to render.
	 */
	public var partDataStartIndex:Int;

	/**
	 * The exclusive end index, you have to render the primitive instances until you reach this one, but don't render this one!
	 */
	public var partDataEndIndex:Int;

	/**
	 * The set of primitives to render is opaque.
	 * This is the first rendering pass. All Opaque primitives are rendered. Depth Compare and Write are both enabled.
	 */
	public static var RenderModeOpaque:Int = Render2DContext._renderModeOpaque;

	/**
	 * The set of primitives to render is using Alpha Test (aka masking).
	 * Alpha Blend is enabled, the AlphaMode must be manually set, the render occurs after the RenderModeOpaque and is depth independent 
	 * (i.e. primitives are not sorted by depth). Depth Compare and Write are both enabled.
	 */
	public static var RenderModeAlphaTest:Int = Render2DContext._renderModeAlphaTest;

	/**
	 * The set of primitives to render is transparent.
	 * Alpha Blend is enabled, the AlphaMode must be manually set, the render occurs after the RenderModeAlphaTest and is depth dependent (i.e. primitives are stored by depth and rendered back to front). Depth Compare is on, but Depth write is Off.
	 */
	public static var RenderModeTransparent:Int = Render2DContext._renderModeTransparent;

	private static var _renderModeOpaque:Int = 1;
	private static var _renderModeAlphaTest:Int = 2;
	private static var _renderModeTransparent:Int = 3;

	/**
	 * Define which render Mode should be used to render the primitive: one of Render2DContext.RenderModeXxxx property
	 */
	private var _renderMode:Int;
	public var renderMode(get, never):Int;
	private function get_renderMode():Int {
		return this._renderMode;
	}
	

	public function new(renderMode:Int) {
		this._renderMode = renderMode;
		this.useInstancing = false;
		this.groupInfoPartData = null;
		this.partDataStartIndex = this.partDataEndIndex = null;
		this.instancedBuffers = null;
	}
	
}
