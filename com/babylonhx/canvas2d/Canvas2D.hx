package com.babylonhx.canvas2d;

import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Size;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.tools.Observer;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Canvas2D extends Group2D {

	/**
	 * In this strategy only the direct children groups of the Canvas will be cached, their whole content (whatever the sub groups they have) into a single bitmap.
	 * This strategy doesn't allow primitives added directly as children of the Canvas.
	 * You typically want to use this strategy of a screenSpace fullscreen canvas: you don't want a bitmap cache taking the whole screen resolution but still want the main contents (say UI in the topLeft and rightBottom for instance) to be efficiently cached.
	 */
	public static inline var CACHESTRATEGY_TOPLEVELGROUPS:Int = 1;

	/**
	 * In this strategy each group will have its own cache bitmap (except if a given group explicitly defines the DONTCACHEOVERRIDE or CACHEINPARENTGROUP behaviors).
	 * This strategy is typically used if the canvas has some groups that are frequently animated. Unchanged ones will have a steady cache and the others will be refreshed when they change, reducing the redraw operation count to their content only.
	 * When using this strategy, group instances can rely on the DONTCACHEOVERRIDE or CACHEINPARENTGROUP behaviors to minize the amount of cached bitmaps.
	 */
	public static inline var CACHESTRATEGY_ALLGROUPS:Int = 2;

	/**
	 * In this strategy the whole canvas is cached into a single bitmap containing every primitives it owns, 
	 * at the exception of the ones that are owned by a group having the DONTCACHEOVERRIDE behavior 
	 * (these primitives will be directly drawn to the viewport at each render for screenSpace Canvas or be 
	 * part of the Canvas cache bitmap for worldSpace Canvas).
	 */
	public static inline var CACHESTRATEGY_CANVAS:Int = 3;

	/**
	 * This strategy is used to recompose/redraw the canvas entierely at each viewport render.
	 * Use this strategy if memory is a concern above rendering performances and/or if the canvas is frequently animated (hence reducing the benefits of caching).
	 * Note that you can't use this strategy for WorldSpace Canvas, they need at least a top level group caching.
	 */
	public static inline var CACHESTRATEGY_DONTCACHE:Int = 4;
	
	/**
	 * Define the default size used for both the width and height of a MapTexture to allocate.
	 * Note that some MapTexture might be bigger than this size if the first node to allocate is bigger in width or height
	 */
	private static inline var _groupTextureCacheSize:Int = 1024;
	
	private static var _solidColorBrushes:Map<String, IBrush2D> = new Map<String, IBrush2D>();
	private static var _gradientColorBrushes:Map<String, IBrush2D> = new Map<String, IBrush2D>();
	
	private var _engineData:Canvas2DEngineBoundData;
	private var _mapCounter:Int = 0;
	private var _background:Rectangle2D;
	private var _scene:Scene;
	private var _engine:Engine;
	private var _isScreeSpace:Bool;
	private var _cachingStrategy:Int;
	private var _hierarchyMaxDepth:Int;
	private var _hierarchyLevelZFactor:Float;
	private var _hierarchyLevelMaxSiblingCount:Int;
	private var _hierarchySiblingZDelta:Float;
	private var _groupCacheMaps:Array<MapTexture>;
	private var _beforeRenderObserver:Observer<Scene>;
	private var _afterRenderObserver:Observer<Scene>;
	private var _supprtInstancedArray:Bool;

	public var _renderingSize:Size;

	/**
	 * Create a new 2D ScreenSpace Rendering Canvas, it is a 2D rectangle that has a size (width/height) and a position relative to the top/left corner of the screen.
	 * ScreenSpace Canvas will be drawn in the Viewport as a 2D Layer lying to the top of the 3D Scene. Typically used for traditional UI.
	 * All caching strategies will be available.
	 * @param engine
	 * @param name
	 * @param pos
	 * @param size
	 * @param cachingStrategy
	 */
	static function CreateScreenSpace(scene:Scene, name:String, pos:Vector2, size:Size, cachingStrategy:Int = Canvas2D.CACHESTRATEGY_TOPLEVELGROUPS): Canvas2D {
		var c = new Canvas2D();
		c.setupCanvas(scene, name, size, true, cachingStrategy);
		c.position = pos;
		
		return c;
	}

	/**
	 * Create a new 2D WorldSpace Rendering Canvas, it is a 2D rectangle that has a size (width/height) and a world transformation matrix to place it in the world space.
	 * This kind of canvas can't have its Primitives directly drawn in the Viewport, they need to be cached in a bitmap at some point, as a consequence the DONT_CACHE strategy is unavailable. All remaining strategies are supported.
	 */
	static function CreateWorldSpace(scene:Scene, name:String, position:Vector3, rotation:Quaternion, size:Size, renderScaleFactor:Float = 1, sideOrientation:Int, cachingStrategy:Int = Canvas2D.CACHESTRATEGY_TOPLEVELGROUPS):Canvas2D {
		if (cachingStrategy !== Canvas2D.CACHESTRATEGY_CANVAS) {
			throw "Right now only the CACHESTRATEGY_CANVAS cache Strategy is supported for WorldSpace Canvas. More will come soon!";
		}
		
		//if (cachingStrategy === Canvas2D.CACHESTRATEGY_DONTCACHE) {
		//    throw new Error("CACHESTRATEGY_DONTCACHE cache Strategy can't be used for WorldSpace Canvas");
		//}
		
		var c = new Canvas2D();
		c.setupCanvas(scene, name, new Size(size.width * renderScaleFactor, size.height * renderScaleFactor), false, cachingStrategy);
		
		var plane = new WorldSpaceCanvas2d(name, scene, c);
		var vertexData = VertexData.CreatePlane({ width: size.width / 2, height: size.height / 2, sideOrientation: sideOrientation });
		var mtl = new StandardMaterial(name + "_Material", scene);
		
		c.applyCachedTexture(vertexData, mtl);
		vertexData.applyToMesh(plane, false);
		
		mtl.specularColor = new Color3(0, 0, 0);
		mtl.disableLighting =true;
		mtl.useAlphaFromDiffuseTexture = true;
		plane.position = position;
		plane.rotationQuaternion = rotation;
		plane.material = mtl;
		
		return c;
	}

	private function setupCanvas(scene:Scene, name:String, size:Size, isScreenSpace:Bool = true, cachingstrategy:Int = Canvas2D.CACHESTRATEGY_TOPLEVELGROUPS) {
		//this._engineData = scene.getEngine().getOrAddExternalDataWithFactory("__BJSCANVAS2D__", k => new Canvas2DEngineBoundData());
		this._cachingStrategy = cachingstrategy;
		this._depthLevel = 0;
		this._hierarchyMaxDepth = 100;
		this._hierarchyLevelZFactor = 1 / this._hierarchyMaxDepth;
		this._hierarchyLevelMaxSiblingCount = 1000;
		this._hierarchySiblingZDelta = this._hierarchyLevelZFactor / this._hierarchyLevelMaxSiblingCount;
		
		this.setupGroup2D(this, null, name, Vector2.Zero(), size);
		
		this._scene = scene;
		this._engine = scene.getEngine();
		this._renderingSize = new Size(0, 0);
		
		// Register scene dispose to also dispose the canvas when it'll happens
		scene.onDisposeObservable.add(function(d, s) {
			this.dispose();
		});
		
		if (cachingstrategy != Canvas2D.CACHESTRATEGY_TOPLEVELGROUPS) {
			this._background = Rectangle2D.Create(this, "###CANVAS BACKGROUND###", 0, 0, size.width, size.height);
			this._background.origin = Vector2.Zero();
			this._background.levelVisible = false;
		}
		this._isScreeSpace = isScreenSpace;
		
		if (this._isScreeSpace) {
			this._afterRenderObserver = this._scene.onAfterRenderObservable.add(function(d, s) {
				this._engine.clear(null, false, true);
				this.render();
			});
		} 
		else {
			this._beforeRenderObserver = this._scene.onBeforeRenderObservable.add(function(d, s) {
				this.render();
			});
		}
		
		this._supprtInstancedArray = this._engine.getCaps().instancedArrays != null;
//            this._supprtInstancedArray = false; // TODO REMOVE!!!
	}

	public function dispose():Bool {
		if (!super.dispose()) {
			return false;
		}
		
		if (this._beforeRenderObserver != null) {
			this._scene.onBeforeRenderObservable.remove(this._beforeRenderObserver);
			this._beforeRenderObserver = null;
		}
		
		if (this._afterRenderObserver != null) {
			this._scene.onAfterRenderObservable.remove(this._afterRenderObserver);
			this._afterRenderObserver = null;
		}
		
		if (this._groupCacheMaps != null) {
			for (m in this._groupCacheMaps) {
				m.dispose();
			}
			this._groupCacheMaps = null;
		}
	}

	/**
	 * Accessor to the Scene that owns the Canvas
	 * @returns The instance of the Scene object
	 */
	private function get_scene():Scene {
		return this._scene;
	}

	/**
	 * Accessor to the Engine that drives the Scene used by this Canvas
	 * @returns The instance of the Engine object
	 */
	private function get_engine():Engine {
		return this._engine;
	}

	/**
	 * Accessor of the Caching Strategy used by this Canvas.
	 * See Canvas2D.CACHESTRATEGY_xxxx static members for more information
	 * @returns the value corresponding to the used strategy.
	 */
	private function get_cachingStrategy():Int {
		return this._cachingStrategy;
	}

	private function get_supportInstancedArray():Bool {
		return this._supprtInstancedArray;
	}

	/**
	 * Property that defines the fill object used to draw the background of the Canvas.
	 * Note that Canvas with a Caching Strategy of
	 * @returns If the background is not set, null will be returned, otherwise a valid fill object is returned.
	 */
	private function get_backgroundFill():IBrush2D {
		if (this._background == null || !this._background.isVisible) {
			return null;
		}
		
		return this._background.fill;
	}

	private function set_backgroundFill(value:IBrush2D):IBrush2D {
		this.checkBackgroundAvailability();
		
		if (value == this._background.fill) {
			return null;
		}
		
		this._background.fill = value;
		this._background.isVisible = true;
		
		return value;
	}

	/**
	 * Property that defines the border object used to draw the background of the Canvas.
	 * @returns If the background is not set, null will be returned, otherwise a valid border object is returned.
	 */
	private function get_backgroundBorder():IBrush2D {
		if (this._background == null || !this._background.isVisible) {
			return null;
		}
		
		return this._background.border;
	}

	private function set_backgroundBorder(value:IBrush2D):IBrush2D {
		this.checkBackgroundAvailability();
		
		if (value == this._background.border) {
			return null;
		}
		
		this._background.border = value;
		this._background.isVisible = true;
		
		return value;
	}

	private function get_backgroundRoundRadius():Float {
		if (this._background == null || !this._background.isVisible) {
			return null;
		}
		
		return this._background.roundRadius;
	}

	private function set_backgroundRoundRadius(value:Float):Float {
		this.checkBackgroundAvailability();
		
		if (value == this._background.roundRadius) {
			return 0;
		}
		
		this._background.roundRadius = value;
		this._background.isVisible = true;
		
		return value;
	}

	private function get_engineData():Canvas2DEngineBoundData {
		return this._engineData;
	}

	private function checkBackgroundAvailability() {
		if (this._cachingStrategy == Canvas2D.CACHESTRATEGY_TOPLEVELGROUPS) {
			throw "Can't use Canvas Background with the caching strategy TOPLEVELGROUPS";
		}
	}

	/**
	 * Read-only property that return the Z delta to apply for each sibling primitives inside of a given one.
	 * Sibling Primitives are defined in a specific order, the first ones will be draw below the next ones.
	 * This property define the Z value to apply between each sibling Primitive. Current implementation allows 1000 Siblings Primitives per level.
	 * @returns The Z Delta
	 */
	private function get_hierarchySiblingZDelta():Float {
		return this._hierarchySiblingZDelta;
	}

	private function get_hierarchyLevelZFactor():Float {
		return this._hierarchyLevelZFactor;
	}	

	/**
	 * Method that renders the Canvas
	 * @param camera the current camera.
	 */
	public function render() {
		this._renderingSize.width = this.engine.getRenderWidth();
		this._renderingSize.height = this.engine.getRenderHeight();
		
		var context = new Render2DContext();
		context.forceRefreshPrimitive = false;
		
		++this._globalTransformProcessStep;
		this.updateGlobalTransVis(false);
		
		this._prepareGroupRender(context);
		this._groupRender(context);
	}

	/**
	 * Internal method that alloc a cache for the given group.
	 * Caching is made using a collection of MapTexture where many groups have their bitmapt cache stored inside.
	 * @param group The group to allocate the cache of.
	 * @return custom type with the PackedRect instance giving information about the cache location into the texture and also the MapTexture instance that stores the cache.
	 */
	public function _allocateGroupCache(group:Group2D):Dynamic/*{ node: PackedRect, texture: MapTexture, sprite: Sprite2D }*/ {
		// Determine size
		var size = group.actualSize;
		size = new Size(Math.ceil(size.width), Math.ceil(size.height));
		if (this._groupCacheMaps == null) {
			this._groupCacheMaps = [];
		}
		
		// Try to find a spot in one of the cached texture
		var res:Dynamic = null;
		for (map in this._groupCacheMaps) {
			var node = map.allocateRect(size);
			if (node != null) {
				res = { node: node, texture: map }
				break;
			}
		}
		
		// Couldn't find a map that could fit the rect, create a new map for it
		if (res == null) {
			var mapSize:Size = new Size(Canvas2D._groupTextureCacheSize, Canvas2D._groupTextureCacheSize);
			
			// Check if the predefined size would fit, other create a custom size using the nearest bigger power of 2
			if (size.width > mapSize.width || size.height > mapSize.height) {
				mapSize.width = Math.pow(2, Math.ceil(Math.log(size.width) / Math.log(2)));
				mapSize.height = Math.pow(2, Math.ceil(Math.log(size.height) / Math.log(2)));
			}
			
			var id = "groupsMapChache $this._mapCounter forCanvas$this.id";
			map = new MapTexture(id, this._scene, mapSize);
			this._groupCacheMaps.push(map);
			
			var node = map.allocateRect(size);
			res = { node: node, texture: map }
		}
		
		// Create a Sprite that will be used to render this cache, the "__cachedSpriteOfGroup__" starting id is a hack to bypass exception throwing in case of the Canvas doesn't normally allows direct primitives
		// Don't do it in case of the group being a worldspace canvas (because its texture is bound to a WorldSpaceCanvas node)
		if (group != this || this._isScreeSpace) {
			var node:PackedRect = res.node;
			var sprite = Sprite2D.Create(this, "__cachedSpriteOfGroup__$group.id", group.position.x, group.position.y, map, node.contentSize, node.pos, false);
			sprite.origin = Vector2.Zero();
			res.sprite = sprite;
		}
		
		return res;
	}

	/**
	 * Get a Solid Color Brush instance matching the given color.
	 * @param color The color to retrieve
	 * @return A shared instance of the SolidColorBrush2D class that use the given color
	 */
	public static function GetSolidColorBrush(color:Color4):IBrush2D {
		return Canvas2D._solidColorBrushes.getOrAddWithFactory(color.toHexString(), () => new SolidColorBrush2D(color.clone(), true));
	}

	/**
	 * Get a Solid Color Brush instance matching the given color expressed as a CSS formatted hexadecimal value.
	 * @param color The color to retrieve
	 * @return A shared instance of the SolidColorBrush2D class that uses the given color
	 */
	public static GetSolidColorBrushFromHex(hexValue: string): IBrush2D {
		return Canvas2D._solidColorBrushes.getOrAddWithFactory(hexValue, () => new SolidColorBrush2D(Color4.FromHexString(hexValue), true));
	}

	public static GetGradientColorBrush(color1: Color4, color2: Color4, translation: Vector2 = Vector2.Zero(), rotation: number = 0, scale: number = 1): IBrush2D {
		return Canvas2D._gradientColorBrushes.getOrAddWithFactory(GradientColorBrush2D.BuildKey(color1, color2, translation, rotation, scale), () => new GradientColorBrush2D(color1, color2, translation, rotation, scale, true));
	}
	
}
