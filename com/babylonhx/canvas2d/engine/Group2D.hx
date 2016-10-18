package com.babylonhx.canvas2d.engine;

import com.babylonhx.math.Viewport;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Color3;
import com.babylonhx.mesh.VertexData;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.tools.Observable;
import com.babylonhx.Node;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * A non renderable primitive that defines a logical group.
 * Can also serve the purpose of caching its content into a bitmap to reduce rendering overhead
 */
class Group2D extends Prim2DBase {

	public static var GROUP2D_PROPCOUNT:Int = Prim2DBase.PRIM2DBASE_PROPCOUNT + 5;

	public static var sizeProperty:Prim2DPropInfo;
	public static var actualSizeProperty:Prim2DPropInfo;

	/**
	 * Default behavior, the group will use the caching strategy defined at the Canvas Level
	 */
	public static inline var GROUPCACHEBEHAVIOR_FOLLOWCACHESTRATEGY:Int = 0;

	/**
	 * When used, this group's content won't be cached, no matter which strategy used.
	 * If the group is part of a WorldSpace Canvas, its content will be drawn in the Canvas cache bitmap.
	 */
	public static inline var GROUPCACHEBEHAVIOR_DONTCACHEOVERRIDE:Int = 1;

	/**
	 * When used, the group's content will be cached in the nearest cached parent group/canvas
	 */
	public static inline var GROUPCACHEBEHAVIOR_CACHEINPARENTGROUP:Int = 2;

	/**
	 * You can specify this behavior to any cached Group2D to indicate that you don't want the cached content to be resized 
	 * when the Group's actualScale is changing. It will draw the content stretched or shrink which is faster than a resize. 
	 * This setting is obviously for performance consideration, don't use it if you want the best rendering quality
	 */
	public static inline var GROUPCACHEBEHAVIOR_NORESIZEONSCALE:Int = 0x100;

	private static inline var GROUPCACHEBEHAVIOR_OPTIONMASK:Int = 0xFF;
	
	
	private var _trackedNode:Node;
	private var _isRenderableGroup:Bool;
	private var _isCachedGroup:Bool;
	private var _cacheGroupDirty:Bool;
	private var _cacheBehavior:Int;
	private var _viewportPosition:Vector2;
	private var _viewportSize:Size;

	public var _renderableData:RenderableGroupData;

	/**
	 * Create an Logical or Renderable Group.
	 * @param settings a combination of settings, possible ones are
	 * - parent: the parent primitive/canvas, must be specified if the primitive is not constructed as a child of another one (i.e. as part of the children array setting)
	 * - children: an array of direct children
	 * - id a text identifier, for information purpose
	 * - position: the X & Y positions relative to its parent. Alternatively the x and y properties can be set. Default is [0;0]
	 * - rotation: the initial rotation (in radian) of the primitive. default is 0
	 * - scale: the initial scale of the primitive. default is 1. You can alternatively use scaleX &| scaleY to apply non uniform scale
	 * - dontInheritParentScale: if set the parent's scale won't be taken into consideration to compute the actualScale property
	 * - opacity: set the overall opacity of the primitive, 1 to be opaque (default), less than 1 to be transparent.
	 * - zOrder: override the zOrder with the specified value
	 * - origin: define the normalized origin point location, default [0.5;0.5]
	 * - size: the size of the group. Alternatively the width and height properties can be set. If null the size will be computed from its content, default is null.
	 *  - cacheBehavior: Define how the group should behave regarding the Canvas's cache strategy, default is Group2D.GROUPCACHEBEHAVIOR_FOLLOWCACHESTRATEGY
	 * - layoutEngine: either an instance of a layout engine based class (StackPanel.Vertical, StackPanel.Horizontal) or a string ('canvas' for Canvas layout, 'StackPanel' or 'HorizontalStackPanel' for horizontal Stack Panel layout, 'VerticalStackPanel' for vertical Stack Panel layout).
	 * - isVisible: true if the group must be visible, false for hidden. Default is true.
	 * - isPickable: if true the Primitive can be used with interaction mode and will issue Pointer Event. If false it will be ignored for interaction/intersection test. Default value is true.
	 * - isContainer: if true the Primitive acts as a container for interaction, if the primitive is not pickable or doesn't intersection, no further test will be perform on its children. If set to false, children will always be considered for intersection/interaction. Default value is true.
	 * - childrenFlatZOrder: if true all the children (direct and indirect) will share the same Z-Order. Use this when there's a lot of children which don't overlap. The drawing order IS NOT GUARANTED!
	 * - marginTop: top margin, can be a number (will be pixels) or a string (see PrimitiveThickness.fromString)
	 * - marginLeft: left margin, can be a number (will be pixels) or a string (see PrimitiveThickness.fromString)
	 * - marginRight: right margin, can be a number (will be pixels) or a string (see PrimitiveThickness.fromString)
	 * - marginBottom: bottom margin, can be a number (will be pixels) or a string (see PrimitiveThickness.fromString)
	 * - margin: top, left, right and bottom margin formatted as a single string (see PrimitiveThickness.fromString)
	 * - marginHAlignment: one value of the PrimitiveAlignment type's static properties
	 * - marginVAlignment: one value of the PrimitiveAlignment type's static properties
	 * - marginAlignment: a string defining the alignment, see PrimitiveAlignment.fromString
	 * - paddingTop: top padding, can be a number (will be pixels) or a string (see PrimitiveThickness.fromString)
	 * - paddingLeft: left padding, can be a number (will be pixels) or a string (see PrimitiveThickness.fromString)
	 * - paddingRight: right padding, can be a number (will be pixels) or a string (see PrimitiveThickness.fromString)
	 * - paddingBottom: bottom padding, can be a number (will be pixels) or a string (see PrimitiveThickness.fromString)
	 * - padding: top, left, right and bottom padding formatted as a single string (see PrimitiveThickness.fromString)
	 */
	public function new(?settings:Dynamic/*Prim2DBaseSettings*/) {
		if (settings == null) {
			settings = {};
		}
		if (settings.origin == null) {
			settings.origin = new Vector2(0, 0);
		}
		super(settings);
		
		var size = (settings.size == null && settings.width == null && settings.height == null) ? null : (settings.size != null || (new Size(settings.width != null ? settings.width : 0, settings.height != null ? settings.height : 0)));
		
		this._trackedNode = (settings.trackNode == null) ? null : settings.trackNode;
		if (this._trackedNode != null && this.owner != null) {
			this.owner._registerTrackedNode(this);
		}
		
		this._cacheBehavior = (settings.cacheBehavior == null) ? Group2D.GROUPCACHEBEHAVIOR_FOLLOWCACHESTRATEGY : settings.cacheBehavior;
		var rd = this._renderableData;
		if (rd != null) {
			rd._noResizeOnScale = (this.cacheBehavior & Group2D.GROUPCACHEBEHAVIOR_NORESIZEONSCALE) != 0;                
		}
		this.size = size;
		this._viewportPosition = Vector2.Zero();
		this._viewportSize = Size.Zero();
	}

	static function _createCachedCanvasGroup(owner:Canvas2D):Group2D {
		var g = new Group2D({ parent: owner, id: "__cachedCanvasGroup__", position: Vector2.Zero(), origin: Vector2.Zero(), size: null, isVisible: true, isPickable: false, dontInheritParentScale: true });
		
		return g;
	}

	public function applyCachedTexture(vertexData:VertexData, material:StandardMaterial) {
		this._bindCacheTarget();
		
		if (vertexData != null) {
			var uv = vertexData.uvs;
			var nodeuv = this._renderableData._cacheNodeUVs;
			for (i in 0...4) {
				uv[i * 2 + 0] = nodeuv[i].x;
				uv[i * 2 + 1] = nodeuv[i].y;
			}
		}
		if (material != null) {
			material.diffuseTexture = this._renderableData._cacheTexture;
			material.emissiveColor = new Color3(1, 1, 1);
		}
		
		this._renderableData._cacheTexture.hasAlpha = true;
		this._unbindCacheTarget();
	}

	/**
	 * Allow you to access the information regarding the cached rectangle of the Group2D into the MapTexture.
	 * If the `noWorldSpaceNode` options was used at the creation of a WorldSpaceCanvas, the rendering of the canvas must be made by the caller, so typically you want to bind the cacheTexture property to some material/mesh and you MUST use the Group2D.cachedUVs property to get the UV coordinates to use for your quad that will display the Canvas and NOT the PackedRect.UVs property which are incorrect because the allocated surface may be bigger (due to over-provisioning or shrinking without deallocating) than what the Group is actually using.
	 */
	public var cachedRect(get, never):PackedRect;
	private function get_cachedRect():PackedRect {
		if (this._renderableData == null) {
			return null;
		}
		
		return this._renderableData._cacheNode;
	}

	/**
	 * The UVs into the MapTexture that map the cached group
	 */
	public var cachedUVs(get, never):Array<Vector2>;
	private function get_cachedUVs():Array<Vector2> {
		if (this._renderableData == null) {
			return null;
		}
		
		return this._renderableData._cacheNodeUVs;
	}

	public var cachedUVsChanged(get, never):Observable<Array<Vector2>>;
	private function get_cachedUVsChanged():Observable<Array<Vector2>> {
		if (this._renderableData == null) {
			return null;
		}
		
		if (this._renderableData._cacheNodeUVsChangedObservable == null) {
			this._renderableData._cacheNodeUVsChangedObservable = new Observable<Array<Vector2>>();
		}
		
		return this._renderableData._cacheNodeUVsChangedObservable;
	}

	/**
	 * Access the texture that maintains a cached version of the Group2D.
	 * This is useful only if you're not using a WorldSpaceNode for your WorldSpace Canvas and therefore need to perform the rendering yourself.
	 */
	public var cacheTexture(get, never):MapTexture;
	private function get_cacheTexture():MapTexture {
		if (this._renderableData == null) {
			return null;
		}
		
		return this._renderableData._cacheTexture;
	}

	/**
	 * Call this method to remove this Group and its children from the Canvas
	 */
	public function dispose():Bool {
		if (!super.dispose()) {
			return false;
		}
		
		if (this._trackedNode != null) {
			this.owner._unregisterTrackedNode(this);
			this._trackedNode = null;
		}
		
		if (this._renderableData != null) {
			this._renderableData.dispose(this.owner);
			this._renderableData = null;
		}
		
		return true;
	}

	/**
	 * @returns Returns true if the Group render content, false if it's a logical group only
	 */
	public var isRenderableGroup(get, never):Bool;
	private function get_isRenderableGroup():Bool {
		return this._isRenderableGroup;
	}

	/**
	 * @returns only meaningful for isRenderableGroup, will be true if the content of the Group is cached into a texture, false if it's rendered every time
	 */
	public var isCachedGroup(get, never):Bool;
	private function get_isCachedGroup():Bool {
		return this._isCachedGroup;
	}

	/**
	 * Get/Set the size of the group. If null the size of the group will be determine from its content.
	 * BEWARE: if the Group is a RenderableGroup and its content is cache the texture will be resized each time the group is getting bigger. 
	 * For performance reason the opposite won't be true: the texture won't shrink if the group does.
	 */
	public var size(get, set):Size;
	private function get_size():Size {
		return this._size;
	}
	private function set_size(val:Size):Size {
		return this._size = val;
	}

	public var viewportSize(get, never):ISize;
	private function get_viewportSize():ISize {
		return this._viewportSize;
	}

	/**
	 * Get the actual size of the group, if the size property is not null, this value will be the same, but if size is null, actualSize will return the size computed from the group's bounding content.
	 */
	public var actualSize(get, set):Size;
	private function get_actualSize():Size {		
		// Return the actualSize if set
		if (this._actualSize != null) {
			return this._actualSize;
		}
		
		// The computed size will be floor on both width and height
		var actualSize:Size = null;
		
		// Return the size if set by the user
		if (this._size != null) {
			actualSize = new Size(Math.ceil(this._size.width), Math.ceil(this._size.height));
		}
		// Otherwise the size is computed based on the boundingInfo of the layout (or bounding info) content
		else {
			var m = this.layoutBoundingInfo.max();
			actualSize = new Size(Math.ceil(m.x), Math.ceil(m.y));
		}
		
		// Compare the size with the one we previously had, if it differs we set the property dirty and trigger a GroupChanged to synchronize a displaySprite (if any)
		if (!actualSize.equals(this._actualSize)) {
			this.onPrimitivePropertyDirty(Group2D.actualSizeProperty.flagId);
			this._actualSize = actualSize;
			this.handleGroupChanged(Group2D.actualSizeProperty);
		}
		
		return actualSize;
	}
	private function set_actualSize(value:Size):Size {
		return this._actualSize = value;
	}

	/**
	 * Get/set the Cache Behavior, used in case the Canvas Cache Strategy is set to CACHESTRATEGY_ALLGROUPS. Can be either GROUPCACHEBEHAVIOR_CACHEINPARENTGROUP, GROUPCACHEBEHAVIOR_DONTCACHEOVERRIDE or GROUPCACHEBEHAVIOR_FOLLOWCACHESTRATEGY. See their documentation for more information.
	 * GROUPCACHEBEHAVIOR_NORESIZEONSCALE can also be set if you set it at creation time.
	 * It is critical to understand than you HAVE TO play with this behavior in order to achieve a good performance/memory ratio. Caching all groups would certainly be the worst strategy of all.
	 */
	public var cacheBehavior(get, never):Int;
	private function get_cacheBehavior():Int {
		return this._cacheBehavior;
	}

	public function _addPrimToDirtyList(prim:Prim2DBase) {
		this._renderableData._primDirtyList.push(prim);
	}

	public function _renderCachedCanvas() {
		this.owner._addGroupRenderCount(1);
		this.updateCachedStates(true);
		var context = new PrepareRender2DContext();
		this._prepareGroupRender(context);
		this._groupRender();
	}

	/**
	 * Get/set the Scene's Node that should be tracked, the group's position will follow the projected position of the Node.
	 */
	public var trackedNode(get, set):Node;
	private function get_trackedNode():Node {
		return this._trackedNode;
	}
	private function set_trackedNode(val:Node):Node {
		if (val != null) {
			if (!this._isFlagSet(SmartPropertyPrim.flagTrackedGroup)) {
				this.owner._registerTrackedNode(this);
			}
			this._trackedNode = val;
		} 
		else {
			if (this._isFlagSet(SmartPropertyPrim.flagTrackedGroup)) {
				this.owner._unregisterTrackedNode(this);
			}
			this._trackedNode = null;
		}
	}

	public function levelIntersect(intersectInfo:IntersectInfo2D):Bool {
		// If we've made it so far it means the boundingInfo intersection test succeed, the Group2D is shaped the same, so we always return true
		return true;
	}

	public function updateLevelBoundingInfo() {
		var size:Size == null;
		
		// If the size is set by the user, the boundingInfo is computed from this value
		if (this.size != null) {
			size = this.size;
		}
		// Otherwise the group's level bounding info is "collapsed"
		else {
			size = new Size(0, 0);
		}
		
		BoundingInfo2D.CreateFromSizeToRef(size, this._levelBoundingInfo);
	}

	// Method called only on renderable groups to prepare the rendering
	public function _prepareGroupRender(context:PrepareRender2DContext) {
		var sortedDirtyList:Array<Prim2DBase> = null;
		
		// Update the Global Transformation and visibility status of the changed primitives
		var rd = this._renderableData;
		if ((rd._primDirtyList.length > 0) || context.forceRefreshPrimitive) {
			sortedDirtyList = rd._primDirtyList.sort(function(a:Prim2DBase, b:Prim2DBase) { return a.hierarchyDepth - b.hierarchyDepth; } );
			this.updateCachedStatesOf(sortedDirtyList, true);
		}
		
		var s = this.actualSize;
		var a = this.actualScale;
		var sw = Math.ceil(s.width * a.x);
		var sh = Math.ceil(s.height * a.y);
		
		// The dimension must be overridden when using the designSize feature, the ratio is maintain to compute a uniform scale, which is mandatory but if the designSize's ratio is different from the rendering surface's ratio, content will be clipped in some cases.
		// So we set the width/height to the rendering's one because that's what we want for the viewport!
		if (Std.is(this, Canvas2D)) {
			var c:Canvas2D = cast this;
			if (c.designSize != null) {
				sw = this.owner.engine.getRenderWidth();
				sh = this.owner.engine.getRenderHeight();
			}
		}
		
		// Setup the size of the rendering viewport
		// In non cache mode, we're rendering directly to the rendering canvas, in this case we have to detect if the canvas size changed since the previous iteration, if it's the case all primitives must be prepared again because their transformation must be recompute
		if (!this._isCachedGroup) {
			// Compute the WebGL viewport's location/size
			var t = this._globalTransform.getTranslation();
			var rs = this.owner._renderingSize;
			sh = Math.min(sh, rs.height - t.y);
			sw = Math.min(sw, rs.width - t.x);
			var x = t.x;
			var y = t.y;
			
			// The viewport where we're rendering must be the size of the canvas if this one fit in the rendering screen or clipped to the screen dimensions if needed
			this._viewportPosition.x = x;
			this._viewportPosition.y = y;
		}
		
		// For a cachedGroup we also check of the group's actualSize is changing, if it's the case then the rendering zone will be change so we also have to dirty all primitives to prepare them again.
		if (this._viewportSize.width != sw || this._viewportSize.height != sh) {
			context.forceRefreshPrimitive = true;
			this._viewportSize.width = sw;
			this._viewportSize.height = sh;
		}
		
		if ((rd._primDirtyList.length > 0) || context.forceRefreshPrimitive) {
			// If the group is cached, set the dirty flag to true because of the incoming changes
			this._cacheGroupDirty = this._isCachedGroup;
			
			rd._primNewDirtyList.splice(0);
			
			// If it's a force refresh, prepare all the children
			if (context.forceRefreshPrimitive) {
				for (p in this._children) {
					p._prepareRender(context);
				}
			} 
			else {
				// Each primitive that changed at least once was added into the primDirtyList, we have to sort this level using
				//  the hierarchyDepth in order to prepare primitives from top to bottom
				if (sortedDirtyList == null) {
					sortedDirtyList = rd._primDirtyList.sort(function(a:Prim2DBase, b:Prim2DBase) { return a.hierarchyDepth - b.hierarchyDepth; } );
				}
				
				for (p in sortedDirtyList) {
					// We need to check if prepare is needed because even if the primitive is in the dirtyList, its parent primitive may also have been modified, then prepared, then recurse on its children primitives (this one for instance) if the changes where impacting them.
					// For instance: a Rect's position change, the position of its children primitives will also change so a prepare will be call on them. If a child was in the dirtyList we will avoid a second prepare by making this check.
					if (!p.isDisposed && p._needPrepare()) {
						p._prepareRender(context);
					}
				}
			}
			
			// Everything is updated, clear the dirty list
			for (p in rd._primDirtyList) {
				if (rd._primNewDirtyList.indexOf(p) == -1) {
					p._resetPropertiesDirty();
				} 
				else {
					p._setFlags(SmartPropertyPrim.flagNeedRefresh);
				}
			}
			rd._primDirtyList.splice(0);
			rd._primDirtyList = rd._primDirtyList.concat(rd._primNewDirtyList);
		}
		
		// A renderable group has a list of direct children that are also renderable groups, we recurse on them to also prepare them
		for (g in rd._childrenRenderableGroups) {
			g._prepareGroupRender(context);
		}
	}

	public function _groupRender() {
		var engine = this.owner.engine;
		var failedCount = 0;
		
		// First recurse to children render group to render them (in their cache or on screen)
		for (childGroup in this._renderableData._childrenRenderableGroups) {
			childGroup._groupRender();
		}
		
		// Render the primitives if needed: either if we don't cache the content or if the content is cached but has changed
		if (!this.isCachedGroup || this._cacheGroupDirty) {
			this.owner._addGroupRenderCount(1);
			
			var curVP:Viewport = null;
			
			if (this.isCachedGroup) {
				this._bindCacheTarget();
			} 
			else {
				curVP = engine.setDirectViewport(this._viewportPosition.x, this._viewportPosition.y, this._viewportSize.width, this._viewportSize.height);
			}
			
			var curAlphaTest = engine.getAlphaTesting() == true;
			var curDepthWrite = engine.getDepthWrite() == true;
			
			// ===================================================================
			// First pass, update the InstancedArray and render Opaque primitives
			
			// Disable Alpha Testing, Enable Depth Write
			engine.setAlphaTesting(false);
			engine.setDepthWrite(true);
			
			// For each different model of primitive to render
			var context = new Render2DContext(Render2DContext.RenderModeOpaque);
			for (v in this._renderableData._renderGroupInstancesInfo) {
				// Prepare the context object, update the WebGL Instanced Array buffer if needed
				var renderCount = this._prepareContext(engine, context, v);
				
				// If null is returned, there's no opaque data to render
				if (renderCount == null) {
					return;
				}
				
				// Submit render only if we have something to render (everything may be hidden and the floatarray empty)
				if (!this.owner.supportInstancedArray || renderCount > 0) {
					// render all the instances of this model, if the render method returns true then our instances are no longer dirty
					var renderFailed = !v.modelRenderCache.render(v, context);
					
					// Update dirty flag/related
					v.opaqueDirty = renderFailed;
					failedCount += renderFailed ? 1 : 0;
				}
			}
			
			// =======================================================================
			// Second pass, update the InstancedArray and render AlphaTest primitives
			
			// Enable Alpha Testing, Enable Depth Write
			engine.setAlphaTesting(true);
			engine.setDepthWrite(true);
			
			// For each different model of primitive to render
			context = new Render2DContext(Render2DContext.RenderModeAlphaTest);
			for (v in this._renderableData._renderGroupInstancesInfo) {
				// Prepare the context object, update the WebGL Instanced Array buffer if needed
				var renderCount = this._prepareContext(engine, context, v);
				
				// If null is returned, there's no opaque data to render
				if (renderCount == null) {
					return;
				}
				
				// Submit render only if we have something to render (everything may be hidden and the floatarray empty)
				if (!this.owner.supportInstancedArray || renderCount > 0) {
					// render all the instances of this model, if the render method returns true then our instances are no longer dirty
					var renderFailed = !v.modelRenderCache.render(v, context);
					
					// Update dirty flag/related
					v.opaqueDirty = renderFailed;
					failedCount += renderFailed ? 1 : 0;
				}
			}
			
			// =======================================================================
			// Third pass, transparent primitive rendering
			
			// Enable Alpha Testing, Disable Depth Write
			engine.setAlphaTesting(true);
			engine.setDepthWrite(false);
			
			// First Check if the transparent List change so we can update the TransparentSegment and PartData (sort if needed)
			if (this._renderableData._transparentListChanged) {
				this._updateTransparentData();
			}
			
			// From this point on we have up to date data to render, so let's go
			failedCount += this._renderTransparentData();
			
			// =======================================================================
			//  Unbind target/restore viewport setting, clear dirty flag, and quit
			// The group's content is no longer dirty
			this._cacheGroupDirty = failedCount != 0;
			
			if (this.isCachedGroup) {
				this._unbindCacheTarget();
			} 
			else {
				if (curVP != null) {
					engine.setViewport(curVP);
				}
			}
			
			// Restore saved states
			engine.setAlphaTesting(curAlphaTest);
			engine.setDepthWrite(curDepthWrite);
		}
	}

	public function _setCacheGroupDirty() {
		this._cacheGroupDirty = true;
	}

	private function _updateTransparentData() {
		this.owner._addUpdateTransparentDataCount(1);
		
		var rd = this._renderableData;
		
		// Sort all the primitive from their depth, max (bottom) to min (top)
		rd._transparentPrimitives.sort(function(a:TransparentPrimitiveInfo, b:TransparentPrimitiveInfo) { return b._primitive.actualZOffset - a._primitive.actualZOffset; } );
		
		var checkAndAddPrimInSegment = function(seg:TransparentSegment, tpiI:Int):Bool {
			var tpi = rd._transparentPrimitives[tpiI];
			
			// Fast rejection: if gii are different
			if (seg.groupInsanceInfo != tpi._groupInstanceInfo) {
				return false;
			}
			
			//let tpiZ = tpi._primitive.actualZOffset;
			
			// We've made it so far, the tpi can be part of the segment, add it
			tpi._transparentSegment = seg;
			tpi._primitive._updateTransparentSegmentIndices(seg);
			
			return true;
		}
		
		// Free the existing TransparentSegments
		for (ts in rd._transparentSegments) {
			ts.dispose(this.owner.engine);
		}
		rd._transparentSegments.splice(0);
		
		var prevSeg:TransparentPrimitiveInfo = null;
		
		for (tpiI in 0...rd._transparentPrimitives.length) {
			var tpi = rd._transparentPrimitives[tpiI];
			
			// Check if the Data in which the primitive is stored is not sorted properly
			if (tpi._groupInstanceInfo.transparentOrderDirty) {
				tpi._groupInstanceInfo.sortTransparentData();
			}
			
			// Reset the segment, we have to create/rebuild it
			tpi._transparentSegment = null;
			
			// If there's a previous valid segment, check if this prim can be part of it
			if (prevSeg != null) {
				checkAndAddPrimInSegment(prevSeg, tpiI);
			}
			
			// If we couldn't insert in the adjacent segments, he have to create one
			if (tpi._transparentSegment == null) {
				var ts = new TransparentSegment();
				ts.groupInsanceInfo = tpi._groupInstanceInfo;
				var prim = tpi._primitive;
				ts.startZ = prim.actualZOffset;
				prim._updateTransparentSegmentIndices(ts);
				ts.endZ = ts.startZ;
				tpi._transparentSegment = ts;
				rd._transparentSegments.push(ts);
			}
			// Update prevSeg
			prevSeg = tpi._transparentSegment;
		}
		
		//rd._firstChangedPrim = null;
		rd._transparentListChanged = false;
	}

	private function _renderTransparentData():Int {
		var failedCount = 0;
		var context = new Render2DContext(Render2DContext.RenderModeTransparent);
		var rd = this._renderableData;
		
		var useInstanced = this.owner.supportInstancedArray;
		
		var length = rd._transparentSegments.length;
		for (i in 0...length) {
			context.instancedBuffers = null;
			
			var ts = rd._transparentSegments[i];
			var gii = ts.groupInsanceInfo;
			var mrc = gii.modelRenderCache;
			var engine = this.owner.engine;
			var count = ts.endDataIndex - ts.startDataIndex;
			
			// Use Instanced Array if it's supported and if there's at least 5 prims to draw.
			// We don't want to create an Instanced Buffer for less that 5 prims
			if (useInstanced && count >= 5) {

				if (!ts.partBuffers) {
					let buffers = new Array<WebGLBuffer>();

					for (let j = 0; j < gii.transparentData.length; j++) {
						let gitd = gii.transparentData[j];
						let dfa = gitd._partData;
						let data = dfa.pack();
						let stride = dfa.stride;
						let neededSize = count * stride * 4;

						let buffer = engine.createInstancesBuffer(neededSize); // Create + bind
						let segData = data.subarray(ts.startDataIndex * stride, ts.endDataIndex * stride);
						engine.updateArrayBuffer(segData);
						buffers.push(buffer);
					}

					ts.partBuffers = buffers;
				} else if (gii.transparentDirty) {
					for (let j = 0; j < gii.transparentData.length; j++) {
						let gitd = gii.transparentData[j];
						let dfa = gitd._partData;
						let data = dfa.pack();
						let stride = dfa.stride;

						let buffer = ts.partBuffers[j];
						let segData = data.subarray(ts.startDataIndex * stride, ts.endDataIndex * stride);
						engine.bindArrayBuffer(buffer);
						engine.updateArrayBuffer(segData);
					}
				}

				context.useInstancing = true;
				context.instancesCount = count;
				context.instancedBuffers = ts.partBuffers;
				context.groupInfoPartData = gii.transparentData;

				let renderFailed = !mrc.render(gii, context);
				failedCount += renderFailed ? 1 : 0;
			} else {
				context.useInstancing = false;
				context.partDataStartIndex = ts.startDataIndex;
				context.partDataEndIndex = ts.endDataIndex;
				context.groupInfoPartData = gii.transparentData;

				let renderFailed = !mrc.render(gii, context);
				failedCount += renderFailed ? 1 : 0;
			}
		}

		return failedCount;
	}

	private _prepareContext(engine: Engine, context: Render2DContext, gii: GroupInstanceInfo): number {
		let gipd: GroupInfoPartData[] = null;
		let setDirty: (dirty: boolean) => void;
		let getDirty: () => boolean;

		// Render Mode specifics
		switch (context.renderMode) {
			case Render2DContext.RenderModeOpaque:
				{
					if (!gii.hasOpaqueData) {
						return null;
					}
					setDirty = (dirty: boolean) => { gii.opaqueDirty = dirty; };
					getDirty = () => gii.opaqueDirty;
					context.groupInfoPartData = gii.opaqueData;
					gipd = gii.opaqueData;
					break;
				}
			case Render2DContext.RenderModeAlphaTest:
				{
					if (!gii.hasAlphaTestData) {
						return null;
					}
					setDirty = (dirty: boolean) => { gii.alphaTestDirty = dirty; };
					getDirty = () => gii.alphaTestDirty;
					context.groupInfoPartData = gii.alphaTestData;
					gipd = gii.alphaTestData;
					break;
				}
			default:
				throw new Error("_prepareContext is only for opaque or alphaTest");
		}


		let renderCount = 0;

		// This part will pack the dynamicfloatarray and update the instanced array WebGLBufffer
		// Skip it if instanced arrays are not supported
		if (this.owner.supportInstancedArray) {

			// Flag for instancing
			context.useInstancing = true;

			// Make sure all the WebGLBuffers of the Instanced Array are created/up to date for the parts to render.
			for (let i = 0; i < gipd.length; i++) {
				let pid = gipd[i];

				// If the instances of the model was changed, pack the data
				let array = pid._partData;
				let instanceData = array.pack();
				renderCount += array.usedElementCount;

				// Compute the size the instance buffer should have
				let neededSize = array.usedElementCount * array.stride * 4;

				// Check if we have to (re)create the instancesBuffer because there's none or the size is too small
				if (!pid._partBuffer || (pid._partBufferSize < neededSize)) {
					if (pid._partBuffer) {
						engine.deleteInstancesBuffer(pid._partBuffer);
					}
					pid._partBuffer = engine.createInstancesBuffer(neededSize); // Create + bind
					pid._partBufferSize = neededSize;
					setDirty(false);

					// Update the WebGL buffer to match the new content of the instances data
					engine.updateArrayBuffer(instanceData);
				} else if (getDirty()) {
					// Update the WebGL buffer to match the new content of the instances data
					engine.bindArrayBuffer(pid._partBuffer);
					engine.updateArrayBuffer(instanceData);

				}
			}
			setDirty(false);
		}


		// Can't rely on hardware instancing, use the DynamicFloatArray instance, render its whole content
		else {
			context.partDataStartIndex = 0;

			// Find the first valid object to get the count
			if (context.groupInfoPartData.length > 0) {
				let i = 0;
				while (!context.groupInfoPartData[i]) {
					i++;
				}
				context.partDataEndIndex = context.groupInfoPartData[i]._partData.usedElementCount;
			}
		}

		return renderCount;
	}

	protected _setRenderingScale(scale: number) {
		if (this._renderableData._renderingScale === scale) {
			return;
		}
		this._renderableData._renderingScale = scale;
	}

	private static _uV = new Vector2(1, 1);
	private static _s = Size.Zero();
	private _bindCacheTarget() {
		let curWidth: number;
		let curHeight: number;
		let rd = this._renderableData;
		let rs = rd._renderingScale;

		let noResizeScale = rd._noResizeOnScale;
		let isCanvas = this.parent == null;
		let scale: Vector2;
		if (noResizeScale) {
			scale = isCanvas ? Group2D._uV: this.parent.actualScale;
		} else {
			scale = this.actualScale;
		}

		Group2D._s.width  = Math.ceil(this.actualSize.width * scale.x * rs);
		Group2D._s.height = Math.ceil(this.actualSize.height * scale.y * rs);

		let sizeChanged = !Group2D._s.equals(rd._cacheSize);

		if (rd._cacheNode) {
			let size = rd._cacheNode.contentSize;

			// Check if we have to deallocate because the size is too small
			if ((size.width < Group2D._s.width) || (size.height < Group2D._s.height)) {
				// For Screen space: over-provisioning of 7% more to avoid frequent resizing for few pixels...
				// For World space: no over-provisioning
				let overprovisioning = this.owner.isScreenSpace ? 1.07 : 1; 
				curWidth  = Math.floor(Group2D._s.width  * overprovisioning);    
				curHeight = Math.floor(Group2D._s.height * overprovisioning);
				//console.log(`[${this._globalTransformProcessStep}] Resize group ${this.id}, width: ${curWidth}, height: ${curHeight}`);
				rd._cacheTexture.freeRect(rd._cacheNode);
				rd._cacheNode = null;
			}
		}

		if (!rd._cacheNode) {
			// Check if we have to allocate a rendering zone in the global cache texture
			var res = this.owner._allocateGroupCache(this, this.parent && this.parent.renderGroup, curWidth ? new Size(curWidth, curHeight) : null, rd._useMipMap, rd._anisotropicLevel);
			rd._cacheNode = res.node;
			rd._cacheTexture = res.texture;
			rd._cacheRenderSprite = res.sprite;
			sizeChanged = true;
		}

		if (sizeChanged) {
			rd._cacheSize.copyFrom(Group2D._s);
			rd._cacheNodeUVs = rd._cacheNode.getUVsForCustomSize(rd._cacheSize);

			if (rd._cacheNodeUVsChangedObservable && rd._cacheNodeUVsChangedObservable.hasObservers()) {
				rd._cacheNodeUVsChangedObservable.notifyObservers(rd._cacheNodeUVs);
			}
			this._setFlags(SmartPropertyPrim.flagWorldCacheChanged);
		}

		let n = rd._cacheNode;
		rd._cacheTexture.bindTextureForPosSize(n.pos, Group2D._s, true);
	}

	private _unbindCacheTarget() {
		if (this._renderableData._cacheTexture) {
			this._renderableData._cacheTexture.unbindTexture();
		}
	}

	protected handleGroupChanged(prop: Prim2DPropInfo) {
		// This method is only for cachedGroup
		let rd = this._renderableData;
		if (!rd) {
			return;
		}

		let cachedSprite = rd._cacheRenderSprite;
		if (!this.isCachedGroup || !cachedSprite) {
			return;
		}

		// For now we only support these property changes
		// TODO: add more! :)
		if (prop.id === Prim2DBase.actualPositionProperty.id) {
			cachedSprite.actualPosition = this.actualPosition.clone();
			if (cachedSprite.position != null) {
				cachedSprite.position = cachedSprite.actualPosition.clone();
			}
		} else if (prop.id === Prim2DBase.rotationProperty.id) {
			cachedSprite.rotation = this.rotation;
		} else if (prop.id === Prim2DBase.scaleProperty.id) {
			cachedSprite.scale = this.scale;
		} else if (prop.id === Prim2DBase.originProperty.id) {
			cachedSprite.origin = this.origin.clone();
		} else if (prop.id === Group2D.actualSizeProperty.id) {
			cachedSprite.size = this.actualSize.clone();
			//console.log(`[${this._globalTransformProcessStep}] Sync Sprite ${this.id}, width: ${this.actualSize.width}, height: ${this.actualSize.height}`);
		}
	}

	private detectGroupStates() {
		var isCanvas = this instanceof Canvas2D;
		var canvasStrat = this.owner.cachingStrategy;

		// In Don't Cache mode, only the canvas is renderable, all the other groups are logical. There are not a single cached group.
		if (canvasStrat === Canvas2D.CACHESTRATEGY_DONTCACHE) {
			this._isRenderableGroup = isCanvas;
			this._isCachedGroup = false;
		}

		// In Canvas cached only mode, only the Canvas is cached and renderable, all other groups are logicals
		else if (canvasStrat === Canvas2D.CACHESTRATEGY_CANVAS) {
			if (isCanvas) {
				this._isRenderableGroup = true;
				this._isCachedGroup = true;
			} else {
				this._isRenderableGroup = this.id === "__cachedCanvasGroup__";
				this._isCachedGroup = false;
			}
		}

		// Top Level Groups cached only mode, the canvas is a renderable/not cached, its direct Groups are cached/renderable, all other group are logicals
		else if (canvasStrat === Canvas2D.CACHESTRATEGY_TOPLEVELGROUPS) {
			if (isCanvas) {
				this._isRenderableGroup = true;
				this._isCachedGroup = false;
			} else {
				if (this.hierarchyDepth === 1) {
					this._isRenderableGroup = true;
					this._isCachedGroup = true;
				} else {
					this._isRenderableGroup = false;
					this._isCachedGroup = false;
				}
			}
		}

		// All Group cached mode, all groups are renderable/cached, including the Canvas, groups with the behavior DONTCACHE are renderable/not cached, groups with CACHEINPARENT are logical ones
		else if (canvasStrat === Canvas2D.CACHESTRATEGY_ALLGROUPS) {
			var gcb = this.cacheBehavior & Group2D.GROUPCACHEBEHAVIOR_OPTIONMASK;
			if ((gcb === Group2D.GROUPCACHEBEHAVIOR_DONTCACHEOVERRIDE) || (gcb === Group2D.GROUPCACHEBEHAVIOR_CACHEINPARENTGROUP)) {
				this._isRenderableGroup = gcb === Group2D.GROUPCACHEBEHAVIOR_DONTCACHEOVERRIDE;
				this._isCachedGroup = false;
			}

			if (gcb === Group2D.GROUPCACHEBEHAVIOR_FOLLOWCACHESTRATEGY) {
				this._isRenderableGroup = true;
				this._isCachedGroup = true;
			}
		}


		if (this._isRenderableGroup) {
			// Yes, we do need that check, trust me, unfortunately we can call _detectGroupStates many time on the same object...
			if (!this._renderableData) {
				this._renderableData = new RenderableGroupData();
			}
		}

		// If the group is tagged as renderable we add it to the renderable tree
		if (this._isCachedGroup) {
			this._renderableData._noResizeOnScale = (this.cacheBehavior & Group2D.GROUPCACHEBEHAVIOR_NORESIZEONSCALE) !== 0;
			let cur = this.parent;
			while (cur) {
				if (cur instanceof Group2D && cur._isRenderableGroup) {
					if (cur._renderableData._childrenRenderableGroups.indexOf(this) === -1) {
						cur._renderableData._childrenRenderableGroups.push(this);
					}
					break;
				}
				cur = cur.parent;
			}
		}
	}
	
}
