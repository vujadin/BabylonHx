package com.babylonhx.canvas2d.engine;

import com.babylonhx.math.Vector4;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Quaternion;
import com.babylonhx.tools.Observable;
import mario.engine.Constants.SizeState;


/**
 * ...
 * @author Krtolica Vujadin
 */

typedef Prim2DBaseSettings = { 
	parent                  :Null<Prim2DBase>,
	id                      :Null<String>,
	children                :Null<Array<Prim2DBase>>,
	position                :Null<Vector2>,
	x                       :Null<Float>,
	y                       :Null<Float>,
	rotation                :Null<Float>,
	scale                   :Null<Float>,
	scaleX                  :Null<Float>,
	scaleY                  :Null<Float>,
	dontInheritParentScale  :Null<Bool>,
	opacity                 :Null<Float>,
	zOrder                  :Null<Int>, 
	origin                  :Null<Vector2>,
	layoutEngine            :Null<Dynamic>, //LayoutEngineBase | string,
	isVisible               :Null<Bool>,
	isPickable              :Null<Bool>,
	isContainer             :Null<Bool>,
	childrenFlatZOrder      :Null<Bool>,
	marginTop               :Null<Dynamic>, //number | string,
	marginLeft              :Null<Dynamic>, //number | string,
	marginRight             :Null<Dynamic>, //number | string,
	marginBottom            :Null<Dynamic>, //number | string,
	margin                  :Null<Dynamic>, //number | string,
	marginHAlignment        :Null<Int>,
	marginVAlignment        :Null<Int>,
	marginAlignment         :Null<String>,
	paddingTop              :Null<Dynamic>, //number | string,
	paddingLeft             :Null<Dynamic>, //number | string,
	paddingRight            :Null<Dynamic>, //number | string,
	paddingBottom           :Null<Dynamic>, //number | string,
	padding                 :Null<String>
}

/**
 * Base class for a Primitive of the Canvas2D feature
 */
class Prim2DBase extends SmartProperyPrim {

	public static inline var PRIM2DBASE_PROPCOUNT:Int = 16;
	public static inline var _bigInt:Int = Std.int(Math.pow(2, 30));

	
	public function new(settings:Dynamic/*Prim2DBaseSettings*/) {
		// Avoid checking every time if the object exists
		if (settings == null) {
			settings = { };
		}
		
		// BASE CLASS CALL
		super();
		
		// Fetch the owner, parent. There're many ways to do it and we can end up with nothing for both
		var owner:Canvas2D;
		var parent:Prim2DBase;
		if (Prim2DBase._isCanvasInit) {
			owner = cast this;
			parent = null;
			this._canvasPreInit(settings);
		} 
		else {
			if (settings.parent != null) {
				parent = settings.parent;
				owner = settings.parent.owner;
				if (owner == null) {
					throw "Parent ${parent.id} of ${settings.id} doesn't have a valid owner!";
				}
				
				if (!Std.is(this, Group2D) && !(Std.is(this, Sprite2D) && settings.id != null && settings.id.indexOf("__cachedSpriteOfGroup__") == 0) && (owner.cachingStrategy == Canvas2D.CACHESTRATEGY_TOPLEVELGROUPS) && (parent == owner)) {
					throw new Error("Can't create a primitive with the canvas as direct parent when the caching strategy is TOPLEVELGROUPS. You need to create a Group below the canvas and use it as the parent for the primitive");
				}
			}
		}
		
		// Fields initialization
		this._layoutEngine = CanvasLayoutEngine.Singleton;
		this._size = null; //Size.Zero();
		this._scale = new Vector2(1, 1);
		this._actualSize = null;
		this._boundingSize = Size.Zero();
		this._layoutArea = Size.Zero();
		this._layoutAreaPos = Vector2.Zero();
		this._marginOffset = Vector4.Zero();
		this._paddingOffset = Vector4.Zero();
		this._parentPaddingOffset = Vector2.Zero();
		this._parentContentArea = Size.Zero();
		this._lastAutoSizeArea = Size.Zero();
		this._contentArea = new Size(null, null);
		this._pointerEventObservable = new Observable<PrimitivePointerInfo>();
		this._boundingInfo = new BoundingInfo2D();
		this._owner = owner;
		this._parent = null;
		this._margin = null;
		this._padding = null;
		this._marginAlignment = null;
		this._id = settings.id;
		this.propertyChanged = new Observable<PropertyChangedInfo>();
		this._children = new Array<Prim2DBase>();
		this._localTransform = new Matrix();
		this._globalTransform = null;
		this._invGlobalTransform = null;
		this._globalTransformProcessStep = 0;
		this._globalTransformStep = 0;
		this._renderGroup = null;
		this._primLinearPosition = 0;
		this._manualZOrder = null;
		this._zOrder = 0;
		this._zMax = 0;
		this._firstZDirtyIndex = Prim2DBase._bigInt;
		this._actualOpacity = 0;
		this._actualScale = Vector2.Zero();
		var isPickable = true;
		var isContainer = true;
		if (settings.isPickable != null) {
			isPickable = settings.isPickable;
		}
		if (settings.isContainer != null) {
			isContainer = settings.isContainer;
		}
		if (settings.dontInheritParentScale) {
			this._setFlags(SmartPropertyPrim.flagDontInheritParentScale);
		}
		this._setFlags((isPickable ? SmartPropertyPrim.flagIsPickable : 0) | SmartPropertyPrim.flagBoundingInfoDirty | SmartPropertyPrim.flagActualOpacityDirty | (isContainer ? SmartPropertyPrim.flagIsContainer : 0) | SmartPropertyPrim.flagActualScaleDirty);
		
		if (settings.opacity != null) {
			this._opacity = settings.opacity;
		} 
		else {
			this._opacity = 1;
		}
		
		this._updateRenderMode();
		
		if (settings.childrenFlatZOrder != null) {
			this._setFlags(SmartPropertyPrim.flagChildrenFlatZOrder);
		}
		
		// If the parent is given, initialize the hierarchy/owner related data
		if (parent != null) {
			parent.addChild(this);
			this._hierarchyDepth = parent._hierarchyDepth + 1;
			this._patchHierarchy(parent.owner);
		}
		
		// If it's a group, detect its own states
		if (this.owner != null && Std.is(this, Group2D)) {
			this.detectGroupStates();
		}
		
		// Time to insert children if some are specified
		if (settings.children != null) {
			for (child in settings.children) {
				this.addChild(child);
				
				// Good time to patch the hierarchy, it won't go very far if there's no need to
				if (this.owner != null) {
					child._patchHierarchy(this.owner);
				}
			}
		}
		
		if (settings.zOrder != null) {
			this.zOrder = settings.zOrder;
		}
		
		// Set the model related properties
		if (settings.position != null) {
			this.position = settings.position;
		}
		else if (settings.x != null || settings.y != null) {
			this.position = new Vector2(settings.x || 0, settings.y || 0);
		} 
		else {
			this._position = null;
		}
		this.rotation = (settings.rotation == null) ? 0 : settings.rotation;
		
		if (settings.scale != null) {
			this.scale = settings.scale;
		} 
		else {
			if (settings.scaleX != null) {
				this.scaleX = settings.scaleX;
			}
			if (settings.scaleY != null) {
				this.scaleY = settings.scaleY;
			}
		}
		this.levelVisible = (settings.isVisible == null) ? true : settings.isVisible;
		this.origin = settings.origin || new Vector2(0.5, 0.5);
		
		// Layout Engine
		if (settings.layoutEngine != null) {
			if (Std.is(settings.layoutEngine, String)) {
				var name = StringTools.trim(cast(settings.layoutEngine, String).toLowerCase());
				if (name == "canvas" || name == "canvaslayoutengine") {
					this.layoutEngine = CanvasLayoutEngine.Singleton;
				} 
				else if (name.indexOf("stackpanel") == 0 || name.indexOf("horizontalstackpanel") == 0) {
					this.layoutEngine = StackPanelLayoutEngine.Horizontal;
				} 
				else if (name.indexOf("verticalstackpanel") == 0) {
					this.layoutEngine = StackPanelLayoutEngine.Vertical;
				}
			} 
			else if (Std.is(settings.layoutEngine, LayoutEngineBase)) {
				this.layoutEngine = cast settings.layoutEngine;
			}
		}
		
		// Set the layout/margin stuffs
		if (settings.marginTop != null) {
			this.margin.setTop(settings.marginTop);
		}
		if (settings.marginLeft != null) {
			this.margin.setLeft(settings.marginLeft);
		}
		if (settings.marginRight != null) {
			this.margin.setRight(settings.marginRight);
		}
		if (settings.marginBottom != null) {
			this.margin.setBottom(settings.marginBottom);
		}
		
		if (settings.margin != null) {
			if (Std.is(settings.margin, String)) {
				this.margin.fromString(cast settings.margin);
			} 
			else {
				this.margin.fromUniformPixels(cast settings.margin);
			}
		}
		
		if (settings.marginHAlignment != null) {
			this.marginAlignment.horizontal = settings.marginHAlignment;
		}
		
		if (settings.marginVAlignment != null) {
			this.marginAlignment.vertical = settings.marginVAlignment;
		}
		
		if (settings.marginAlignment != null) {
			this.marginAlignment.fromString(settings.marginAlignment);
		}
		
		if (settings.paddingTop != null) {
			this.padding.setTop(settings.paddingTop);
		}
		if (settings.paddingLeft != null) {
			this.padding.setLeft(settings.paddingLeft);
		}
		if (settings.paddingRight != null) {
			this.padding.setRight(settings.paddingRight);
		}
		if (settings.paddingBottom != null) {
			this.padding.setBottom(settings.paddingBottom);
		}
		
		if (settings.padding != null) {
			this.padding.fromString(settings.padding);
		}
		
		// Dirty layout and positioning
		this._parentLayoutDirty();
		this._positioningDirty();
	}

	public var actionManager(get, never):ActionManager;
	private function get_actionManager():ActionManager {
		if (this._actionManager == null) {
			this._actionManager = new ActionManager(this.owner.scene);
		}
		
		return this._actionManager;
	}

	/**
	 * From 'this' primitive, traverse up (from parent to parent) until the given predicate is true
	 * @param predicate the predicate to test on each parent
	 * @return the first primitive where the predicate was successful
	 */
	public function traverseUp(predicate:Prim2DBase->Bool):Prim2DBase {
		var p:Prim2DBase = this;
		while (p != null) {
			if (predicate(p)) {
				return p;
			}
			p = p._parent;
		}
		
		return null;
	}

	/**
	 * Retrieve the owner Canvas2D
	 */
	public var owner(get, never):Canvas2D;
	private function get_owner():Canvas2D {
		return this._owner;
	}

	/**
	 * Get the parent primitive (can be the Canvas, only the Canvas has no parent)
	 */
	public var parent(get, never):Prim2DBase;
	private function get_parent():Prim2DBase {
		return this._parent;
	}

	/**
	 * The array of direct children primitives
	 */
	public var children(get, never):Array<Prim2DBase>;
	private function get_children():Array<Prim2DBase> {
		return this._children;
	}

	/**
	 * The identifier of this primitive, may not be unique, it's for information purpose only
	 */
	public var id(get, never):String;
	private function get_id():String {
		return this._id;
	}

	/**
	 * Metadata of the position property
	 */
	public static var positionProperty:Prim2DPropInfo;

	/**
	 * Metadata of the actualPosition property
	 */
	public static var actualPositionProperty:Prim2DPropInfo;

	/**
	 * Metadata of the size property
	 */
	public static var sizeProperty:Prim2DPropInfo;

	/**
	 * Metadata of the rotation property
	 */
	public static var rotationProperty:Prim2DPropInfo;

	/**
	 * Metadata of the scale property
	 */
	public static var scaleProperty:Prim2DPropInfo;

	/**
	 * Metadata of the origin property
	 */
	public static var originProperty:Prim2DPropInfo;

	/**
	 * Metadata of the levelVisible property
	 */
	public static var levelVisibleProperty:Prim2DPropInfo;

	/**
	 * Metadata of the isVisible property
	 */
	public static var isVisibleProperty:Prim2DPropInfo;

	/**
	 * Metadata of the zOrder property
	 */
	public static var zOrderProperty:Prim2DPropInfo;

	/**
	 * Metadata of the margin property
	 */
	public static var marginProperty:Prim2DPropInfo;

	/**
	 * Metadata of the margin property
	 */
	public static var paddingProperty:Prim2DPropInfo;

	/**
	 * Metadata of the hAlignment property
	 */
	public static var marginAlignmentProperty:Prim2DPropInfo;

	/**
	 * Metadata of the opacity property
	 */
	public static var opacityProperty:Prim2DPropInfo;


	/**
	 * Metadata of the scaleX property
	 */
	public static var scaleXProperty:Prim2DPropInfo;

	/**
	 * Metadata of the scaleY property
	 */
	public static var scaleYProperty:Prim2DPropInfo;

	//@instanceLevelProperty(1, pi => Prim2DBase.actualPositionProperty = pi, false, false, true)
	/**
	 * Return the position where the primitive is rendered in the Canvas, this position may be different than the one returned by the position property due to layout/alignment/margin/padding computing
	 */
	public var actualPosition(get, set):Vector2;
	private function get_actualPosition():Vector2 {
		if (this._actualPosition != null) {
			return this._actualPosition;
		}
		if (this._position != null) {
			return this._position;
		}
		
		// At least return 0,0, we can't return null on actualPosition
		return Prim2DBase._nullPosition;
	}
	private static var _nullPosition = Vector2.Zero();

	/**
	 * DO NOT INVOKE for internal purpose only
	 */
	private function set_actualPosition(val:Vector2):Vector2 {
		return this._actualPosition = val;
	}

	/**
	 * Shortcut to actualPosition.x
	 */
	public var actualX(get, never):Float;
	private function get_actualX():Float {
		return this.actualPosition.x;
	}

	/**
	 * Shortcut to actualPosition.y
	 */
	public var actualY(get, never):Float;
	private function get_actualY():Float {
		return this.actualPosition.y;
	}

	/**
	 * Position of the primitive, relative to its parent.
	 * BEWARE: if you change only position.x or y it won't trigger a property change and you won't have the expected behavior.
	 * Use this property to set a new Vector2 object, otherwise to change only the x/y use Prim2DBase.x or y properties.
	 * Setting this property may have no effect is specific alignment are in effect.
	 */
	//@dynamicLevelProperty(2, pi => Prim2DBase.positionProperty = pi, false, false, true)
	public var position(get, set):Vector2;
	private function get_position():Vector2 {
		return this._position != null this._position : Prim2DBase._nullPosition;
	}
	private function set_position(value:Vector2):Vector2 {
		if (!this._checkPositionChange()) {
			return;
		}
		this._position = value;
		this._triggerPropertyChanged(Prim2DBase.actualPositionProperty, value);
	}

	/**
	 * Direct access to the position.x value of the primitive
	 * Use this property when you only want to change one component of the position property
	 */
	public var x(get, set):Float;
	private function get_x():Float {
		if (this._position == null) {
			return null;
		}
		
		return this._position.x;
	}
	private function set_x(value:Float):Float {
		if (!this._checkPositionChange()) {
			return value;
		}
		if (this._position == null) {
			this._position = Vector2.Zero();
		}
		
		if (this._position.x == value) {
			return value;
		}
		
		this._position.x = value;
		this._triggerPropertyChanged(Prim2DBase.positionProperty, value);
		this._triggerPropertyChanged(Prim2DBase.actualPositionProperty, value);
		
		return value;
	}

	/**
	 * Direct access to the position.y value of the primitive
	 * Use this property when you only want to change one component of the position property
	 */
	public var y(get, set):Float;
	private function get_y():Float {
		if (this._position == null) {
			return null;
		}
		
		return this._position.y;
	}
	private function set_y(value:Float):Float {
		if (!this._checkPositionChange()) {
			return value;
		}
		if (this._position == null) {
			this._position = Vector2.Zero();
		}
		
		if (this._position.y == value) {
			return value;
		}
		
		this._position.y = value;
		this._triggerPropertyChanged(Prim2DBase.positionProperty, value);
		this._triggerPropertyChanged(Prim2DBase.actualPositionProperty, value);
		
		return value;
	}

	private static var boundinbBoxReentrency:Bool = false;
	private static var nullSize = Size.Zero();

	/**
	 * Size of the primitive or its bounding area
	 * BEWARE: if you change only size.width or height it won't trigger a property change and you won't have the expected behavior.
	 * Use this property to set a new Size object, otherwise to change only the width/height use Prim2DBase.width or height properties.
	 */
	//@dynamicLevelProperty(3, pi => Prim2DBase.sizeProperty = pi, false, true)
	public var size(get, set):Size;
	private function get_size():Size {
		if (this._size == null || this._size.width == null || this._size.height == null) {
			if (Prim2DBase.boundinbBoxReentrency) {
				return Prim2DBase.nullSize;
			}
			
			if (!this._isFlagSet(SmartPropertyPrim.flagBoundingInfoDirty)) {
				return this._boundingSize;
			}
			
			Prim2DBase.boundinbBoxReentrency = true;
			var b = this.boundingInfo;
			Prim2DBase.boundinbBoxReentrency = false;
			
			return this._boundingSize;
		}
		
		return this._size;
	}
	private function set_size(value:Size):Size {
		return this._size = value;
	}

	/**
	 * Direct access to the size.width value of the primitive
	 * Use this property when you only want to change one component of the size property
	 */
	public var width(get, set):Float;
	private function get_width():Float {
		if (this.size == null) {
			return null;
		}
		
		return this.size.width;
	}
	private function set_width(value:Float):Float {
		if (this.size == null) {
			this.size = new Size(value, 0);
			return value;
		}
		
		if (this.size.width == value) {
			return value;
		}
		
		this.size.width = value;
		this._triggerPropertyChanged(Prim2DBase.sizeProperty, value);
		this._positioningDirty();
		
		return value;
	}

	/**
	 * Direct access to the size.height value of the primitive
	 * Use this property when you only want to change one component of the size property
	 */
	public var height(get, set):Float;
	private function get_height():Float {
		if (this.size == null) {
			return null;
		}
		
		return this.size.height;
	}
	private function set_height(value:Float):Float {
		if (this.size == null) {
			this.size = new Size(0, value);
			return value;
		}
		
		if (this.size.height == value) {
			return value;
		}
		
		this.size.height = value;
		this._triggerPropertyChanged(Prim2DBase.sizeProperty, value);
		this._positioningDirty();
		
		return value;
	}

	//@instanceLevelProperty(4, pi => Prim2DBase.rotationProperty = pi, false, true)
	/**
	 * Rotation of the primitive, in radian, along the Z axis
	 */
	public var rotation(get, set):Float;
	private function get_rotation():Float {
		return this._rotation;
	}
	private function set_rotation(value:Float):Float {
		return this._rotation = value;
	}

	//@instanceLevelProperty(5, pi => Prim2DBase.scaleProperty = pi, false, true)
	/**
	 * Uniform scale applied on the primitive. If a non-uniform scale is applied through scaleX/scaleY property the getter of this property will return scaleX.
	 */
	public var scale(get, set):Float;
	private function set_scale(value:Float):Float {
		this._scale.x = this._scale.y = value;
		this._setFlags(SmartPropertyPrim.flagActualScaleDirty);
		this._spreadActualScaleDirty();
		
		return value;
	}
	private function get_scale():Float {
		return this._scale.x;
	}

	/**
	 * Return the size of the primitive as it's being rendered into the target.
	 * This value may be different of the size property when layout/alignment is used 
	 * or specific primitive types can implement a custom logic through this property.
	 * BEWARE: don't use the setter, it's for internal purpose only
	 * Note to implementers: you have to override this property and declare if necessary a @xxxxInstanceLevel decorator
	 */
	public var actualSize(get, set):Size;
	private function get_actualSize():Size {
		if (this._actualSize != null) {
			return this._actualSize;
		}
		
		return this._size;
	}
	private function set_actualSize(value:Size):Size {
		if (this._actualSize.equals(value)) {
			return value;
		}
		
		return this._actualSize = value;
	}

	public var actualZOffset(get, never):Int;
	private function get_actualZOffset():Float {
		if (this._manualZOrder != null) {
			return this._manualZOrder;
		}
		
		if (this._isFlagSet(SmartPropertyPrim.flagZOrderDirty)) {
			this._updateZOrder();
		}
		return (1 - this._zOrder);
	}

	/**
	 * Get or set the minimal size the Layout Engine should respect when computing the primitive's actualSize.
	 * The Primitive's size won't be less than specified.
	 * The default value depends of the Primitive type
	 */
	public var minSize(get, set):Size;
	private function get_minSize(): Size {
		return this._minSize;
	}
	private function set_minSize(value:Size):Size {
		if (this._minSize != null && value != null && this._minSize.equals(value)) {
			return value;
		}
		
		this._minSize = value;
		this._parentLayoutDirty();
		
		return value;
	}

	/**
	 * Get or set the maximal size the Layout Engine should respect when computing the primitive's actualSize.
	 * The Primitive's size won't be more than specified.
	 * The default value depends of the Primitive type
	 */
	public var maxSize(get, set):Size;
	private function get_maxSize():Size {
		return this._maxSize;
	}
	private function set_maxSize(value:Size):Size {
		if (this._maxSize != null && value != null && this._maxSize.equals(value)) {
			return value;
		}
		
		this._maxSize = value;
		this._parentLayoutDirty();
		
		return value;
	}

	/**
	 * The origin defines the normalized coordinate of the center of the primitive, from the bottom/left corner.
	 * The origin is used only to compute transformation of the primitive, it has no meaning in the primitive local frame of reference
	 * For instance:
	 * 0,0 means the center is bottom/left. Which is the default for Canvas2D instances
	 * 0.5,0.5 means the center is at the center of the primitive, which is default of all types of Primitives
	 * 0,1 means the center is top/left
	 * @returns The normalized center.
	 */
	//@dynamicLevelProperty(6, pi => Prim2DBase.originProperty = pi, false, true)
	public var origin(get, set):Vector2;
	private function get_origin(): Vector2 {
		return this._origin;
	}
	private function set_origin(value:Vector2):Vector2 {
		return this._origin = value;
	}

	/**
	 * Let the user defines if the Primitive is hidden or not at its level. 
	 * As Primitives inherit the hidden status from their parent, only the isVisible property give properly the real visible state.
	 * Default is true, setting to false will hide this primitive and its children.
	 */
	public var levelVisible(get, set):Bool;
	private function get_levelVisible():Bool {
		return this._isFlagSet(SmartPropertyPrim.flagLevelVisible);
	}
	private function set_levelVisible(value:Bool):Bool {
		this._changeFlags(SmartPropertyPrim.flagLevelVisible, value);
		
		return value;
	}

	/**
	 * Use ONLY THE GETTER to determine if the primitive is visible or not.
	 * The Setter is for internal purpose only!
	 */
	public var isVisible(get, set):Bool;
	private function get_isVisible():Bool {
		return this._isFlagSet(SmartPropertyPrim.flagIsVisible);
	}
	private function set_isVisible(value:Bool):Bool {
		this._changeFlags(SmartPropertyPrim.flagIsVisible, value);
		
		return value;
	}

	/**
	 * You can override the default Z Order through this property, but most of the time the default behavior is acceptable
	 */
	public var zOrder(get, set):Int;
	private function get_zOrder():Int {
		return this._manualZOrder;
	}
	private function set_zOrder(value:Int):Int {
		if (this._manualZOrder == value) {
			return;
		}
		
		this._manualZOrder = value;
		this.onZOrderChanged();
		if (this._actualZOrderChangedObservable != null && this._actualZOrderChangedObservable.hasObservers()) {
			this._actualZOrderChangedObservable.notifyObservers(value);
		}
		
		return value;
	}

	public var isManualZOrder(get, never):Bool;
	private function get_isManualZOrder():Bool {
		return this._manualZOrder != null;
	}

	/**
	 * You can get/set a margin on the primitive through this property
	 * @returns the margin object, if there was none, a default one is created and returned
	 */
	public var margin(get, never):PrimitiveThickness;
	private function get_margin():PrimitiveThickness {
		if (this._margin == null) {
			this._margin = new PrimitiveThickness(function() {
				if (this.parent == null) {
					return null;
				}
				return this.parent.margin;
			}, function() { this._positioningDirty(); });
		}
		
		return this._margin;
	}
	/*private function set_margin(value:PrimitiveThickness):PrimitiveThickness {
		return this._margin = value;
	}*/
	
	public var _hasMargin(get, never):Bool;
	private function get__hasMargin():Bool {
		return (this._margin != null) || (this._marginAlignment != null);
	}

	/**
	 * You can get/set a padding on the primitive through this property
	 * @returns the padding object, if there was none, a default one is created and returned
	 */
	public var padding(get, never):PrimitiveThickness;
	private function get_padding():PrimitiveThickness {
		if (this._padding == null) {
			this._padding = new PrimitiveThickness(function() {
				if (this.parent == null) {
					return null;
				}
				return this.parent.padding;
			}, function() { this._positioningDirty(); });
		}
		
		return this._padding;
	}

	private var _hasPadding(get, never):Bool;
	private function get__hasPadding():Bool {
		return this._padding != null;
	}

	/**
	 * You can get/set the margin alignment through this property
	 */
	public var marginAlignment(get, never):PrimitiveAlignment;
	private function get_marginAlignment():PrimitiveAlignment {
		if (this._marginAlignment == null) {
			this._marginAlignment = new PrimitiveAlignment(function() { this._positioningDirty(); });
		}
		
		return this._marginAlignment;
	}

	/**
	 * Get/set the opacity of the whole primitive
	 */
	public var opacity(get, set):Float;
	private function get_opacity():Float {
		return this._opacity;
	}
	private function set_opacity(value:Float):Float {
		if (value < 0) {
			value = 0;
		} 
		else if (value > 1) {
			value = 1;
		}
		
		if (this._opacity == value) {
			return value;
		}
		
		this._opacity = value;
		this._updateRenderMode();
		this._setFlags(SmartPropertyPrim.flagActualOpacityDirty);
		this._spreadActualOpacityChanged();
		
		return value;
	}

	/**
	 * Scale applied on the X axis of the primitive
	 */
	public var scaleX(get, set):Float;
	private function set_scaleX(value:Float):Float {
		this._scale.x = value;
		this._setFlags(SmartPropertyPrim.flagActualScaleDirty);
		this._spreadActualScaleDirty();
		
		return value;
	}
	private function get_scaleX():Float {
		return this._scale.x;
	}

	/**
	 * Scale applied on the Y axis of the primitive
	 */
	public var scaleY(get, set):Float;
	private function set_scaleY(value:Float):Float {
		this._scale.y = value;
		this._setFlags(SmartPropertyPrim.flagActualScaleDirty);
		this._spreadActualScaleDirty();
		
		return value;
	}
	private function get_scaleY():Float {
		return this._scale.y;
	}

	private function _spreadActualScaleDirty() {
		for (child in this._children) {
			child._setFlags(SmartPropertyPrim.flagActualScaleDirty);
			child._spreadActualScaleDirty();
		}
	}

	/**
	 * Returns the actual scale of this Primitive, the value is computed from the scale property of this primitive, multiplied by the actualScale of its parent one (if any). The Vector2 object returned contains the scale for both X and Y axis
	 */
	public var actualScale(get, never):Vector2;
	private function get_actualScale():Vector2 {
		if (this._isFlagSet(SmartPropertyPrim.flagActualScaleDirty)) {
			var cur = this._isFlagSet(SmartPropertyPrim.flagDontInheritParentScale) ? null : this.parent;
			var sx = this.scaleX;
			var sy = this.scaleY;
			while (cur) {
				sx *= cur.scaleX;
				sy *= cur.scaleY;
				cur = cur._isFlagSet(SmartPropertyPrim.flagDontInheritParentScale) ? null : cur.parent;
			}
			
			this._actualScale.copyFromFloats(sx, sy);
			this._clearFlags(SmartPropertyPrim.flagActualScaleDirty);
		}
		
		return this._actualScale;
	}

	/**
	 * Get the actual Scale of the X axis, shortcut for this.actualScale.x
	 */
	public var actualScaleX(get, never):Float;
	private function get_actualScaleX():Float {
		return this.actualScale.x;
	}

	/**
	 * Get the actual Scale of the Y axis, shortcut for this.actualScale.y
	 */
	public var actualScaleY(get, never):Float;
	private function get_actualScaleY():Float {
		return this.actualScale.y;
	}

	/**
	 * Get the actual opacity level, this property is computed from the opacity property, multiplied by the actualOpacity of its parent (if any)
	 */
	public var actualOpacity(get, never):Float;
	private function get_actualOpacity():Float {
		if (this._isFlagSet(SmartPropertyPrim.flagActualOpacityDirty)) {
			var cur = this.parent;
			var op = this.opacity;
			while (cur != null) {
				op *= cur.opacity;
				cur = cur.parent;
			}
			
			this._actualOpacity = op;
			this._clearFlags(SmartPropertyPrim.flagActualOpacityDirty);
		}
		
		return this._actualOpacity;
	}

	/**
	 * Get/set the layout engine to use for this primitive.
	 * The default layout engine is the CanvasLayoutEngine.
	 */
	public var layoutEngine(get, set):LayoutEngineBase;
	private function get_layoutEngine():LayoutEngineBase {
		if (this._layoutEngine == null) {
			this._layoutEngine = CanvasLayoutEngine.Singleton;
		}
		
		return this._layoutEngine;
	}
	private function set_layoutEngine(value:LayoutEngineBase):LayoutEngineBase {
		if (this._layoutEngine == value) {
			return value;
		}
		
		this._changeLayoutEngine(value);
		
		return value;
	}

	/**
	 * Get/set the layout are of this primitive.
	 * The Layout area is the zone allocated by the Layout Engine for this particular primitive. Margins/Alignment will be computed based on this area.
	 * The setter should only be called by a Layout Engine class.
	 */
	public var layoutArea(get, set):Size;
	private function get_layoutArea():Size {
		return this._layoutArea;
	}
	private function set_layoutArea(val:Size):Size {
		if (this._layoutArea.equals(val)) {
			return val;
		}
		this._positioningDirty();
		this._layoutArea = val;
		
		return val;
	}

	/**
	 * Get/set the layout area position (relative to the parent primitive).
	 * The setter should only be called by a Layout Engine class.
	 */
	public var layoutAreaPos(get, set):Vector2;
	private function get_layoutAreaPos():Vector2 {
		return this._layoutAreaPos;
	}
	private function set_layoutAreaPos(val:Vector2):Vector2 {
		if (this._layoutAreaPos.equals(val)) {
			return val;
		}
		this._positioningDirty();
		this._layoutAreaPos = val;
		
		return val;
	}

	/**
	 * Define if the Primitive can be subject to intersection test or not (default is true)
	 */
	public var isPickable(get, set):Bool;
	private function get_isPickable():Bool {
		return this._isFlagSet(SmartPropertyPrim.flagIsPickable);
	}
	private function set_isPickable(value:Bool):Bool {
		this._changeFlags(SmartPropertyPrim.flagIsPickable, value);
		
		return value;
	}

	/**
	 * Define if the Primitive acts as a container or not
	 * A container will encapsulate its children for interaction event.
	 * If it's not a container events will be process down to children if the primitive is not pickable.
	 * Default value is true
	 */
	public var isContainer(get, set):Bool; 
	private function get_isContainer():Bool {
		return this._isFlagSet(SmartPropertyPrim.flagIsContainer);
	}
	private function set_isContainer(value:Bool):Bool {
		this._changeFlags(SmartPropertyPrim.flagIsContainer, value);
		
		return value;
	}

	/**
	 * Return the depth level of the Primitive into the Canvas' Graph. A Canvas will be 0, its direct children 1, and so on.
	 */
	public var hierarchyDepth(get, never):Int;
	private function get_hierarchyDepth():Int {
		return this._hierarchyDepth;
	}

	/**
	 * Retrieve the Group that is responsible to render this primitive
	 */
	public var renderGroup(get, never):Group2D;
	private function get_renderGroup():Group2D {
		return this._renderGroup;
	}

	/**
	 * Get the global transformation matrix of the primitive
	 */
	public var globalTransform(get, never):Matrix;
	private function get_globalTransform():Matrix {
		this._updateLocalTransform();
		
		return this._globalTransform;
	}

	/**
	 * return the global position of the primitive, relative to its canvas
	 */
	public function getGlobalPosition():Vector2 {
		var v = new Vector2(0, 0);
		this.getGlobalPositionByRef(v);
		
		return v;
	}

	/**
	 * return the global position of the primitive, relative to its canvas
	 * @param v the valid Vector2 object where the global position will be stored
	 */
	public function getGlobalPositionByRef(v:Vector2) {
		v.x = this.globalTransform.m[12];
		v.y = this.globalTransform.m[13];
	}

	/**
	 * Get invert of the global transformation matrix of the primitive
	 */
	public var invGlobalTransform(get, never):Matrix; 
	private function get_invGlobalTransform():Matrix {
		this._updateLocalTransform();
		
		return this._invGlobalTransform;
	}

	/**
	 * Get the local transformation of the primitive
	 */
	public var localTransform(get, never):Matrix;
	private function get_localTransform():Matrix {
		this._updateLocalTransform();
		
		return this._localTransform;
	}

	private static var _bMax:Vector2 = Vector2.Zero();

	/**
	 * Get the boundingInfo associated to the primitive and its children.
	 * The value is supposed to be always up to date
	 */
	public var boundingInfo(get, never):BoundingInfo2D;
	private function get_boundingInfo():BoundingInfo2D {
		if (this._isFlagSet(SmartPropertyPrim.flagBoundingInfoDirty)) {
			if (this.owner != null) {
				this.owner.boundingInfoRecomputeCounter.addCount(1, false);
			}
			if (this.isSizedByContent) {
				this._boundingInfo.clear();
			} 
			else {
				this._boundingInfo.copyFrom(this.levelBoundingInfo);
			}
			var bi = this._boundingInfo;
			
			var tps = new BoundingInfo2D();
			for (curChild in this._children) {
				curChild.boundingInfo.transformToRef(curChild.localTransform, tps);
				bi.unionToRef(tps, bi);
			}
			
			this._boundingInfo.maxToRef(Prim2DBase._bMax);
			this._boundingSize.copyFromFloats(
				(this._size == null || this._size.width == null) ? Math.ceil(Prim2DBase._bMax.x) : this._size.width,
				(this._size == null || this._size.height == null) ? Math.ceil(Prim2DBase._bMax.y) : this._size.height);
				
			this._clearFlags(SmartPropertyPrim.flagBoundingInfoDirty);
		}
		
		return this._boundingInfo;
	}

	/**
	 * Determine if the size is automatically computed or fixed because manually specified.
	 * Use the actualSize property to get the final/real size of the primitive
	 * @returns true if the size is automatically computed, false if it were manually specified.
	 */
	public var isSizeAuto(get, never):Bool;
	private function get_isSizeAuto():Bool {
		return this._size == null;
	}

	/**
	 * Return true if this prim has an auto size which is set by the children's global bounding box
	 */
	public var isSizedByContent(get, never):Bool;
	private function get_isSizedByContent():Bool {
		return (this._size == null) && (this._children.length > 0);
	}

	/**
	 * Determine if the position is automatically computed or fixed because manually specified.
	 * Use the actualPosition property to get the final/real position of the primitive
	 * @returns true if the position is automatically computed, false if it were manually specified.
	 */
	public var isPositionAuto(get, never):Bool;
	private function get_isPositionAuto():Bool {
		return this._position == null;
	}

	/**
	 * Interaction with the primitive can be create using this Observable. See the PrimitivePointerInfo class for more information
	 */
	public var pointerEventObservable(get, never):Observable<PrimitivePointerInfo>;
	private function get_pointerEventObservable():Observable<PrimitivePointerInfo> {
		return this._pointerEventObservable;
	}

	public var zActualOrderChangedObservable(get, never):Observable<Int>;
	private function get_zActualOrderChangedObservable():Observable<Int> {
		if (this._actualZOrderChangedObservable == null) {
			this._actualZOrderChangedObservable = new Observable<Int>();
		}
		
		return this._actualZOrderChangedObservable;
	}

	public function findById(id:String):Prim2DBase {
		if (this._id == id) {
			return this;
		}
		
		for (child in this._children) {
			var r = child.findById(id);
			if (r != null) {
				return r;
			}
		}
	}

	private function onZOrderChanged() {

	}

	private function levelIntersect(intersectInfo:IntersectInfo2D):Bool {
		return false;
	}

	/**
	 * Capture all the Events of the given PointerId for this primitive.
	 * Don't forget to call releasePointerEventsCapture when done.
	 * @param pointerId the Id of the pointer to capture the events from.
	 */
	public function setPointerEventCapture(pointerId:Int):Bool {
		return this.owner._setPointerCapture(pointerId, this);
	}

	/**
	 * Release a captured pointer made with setPointerEventCapture.
	 * @param pointerId the Id of the pointer to release the capture from.
	 */
	public function releasePointerEventsCapture(pointerId:Int):Bool {
		return this.owner._releasePointerCapture(pointerId, this);
	}

	/**
	 * Make an intersection test with the primitive, all inputs/outputs are stored in the IntersectInfo2D class, see its documentation for more information.
	 * @param intersectInfo contains the settings of the intersection to perform, to setup before calling this method as well as the result, available after a call to this method.
	 */
	public function intersect(intersectInfo:IntersectInfo2D):Bool {
		if (intersectInfo == null) {
			return false;
		}
		
		// If this is null it means this method is call for the first level, initialize stuffs
		var firstLevel = intersectInfo._globalPickPosition == null;
		if (firstLevel) {
			// Compute the pickPosition in global space and use it to find the local position for each level down, always relative from the world to get the maximum accuracy (and speed). The other way would have been to compute in local every level down relative to its parent's local, which wouldn't be as accurate (even if javascript number is 80bits accurate).
			intersectInfo._globalPickPosition = Vector2.Zero();
			Vector2.TransformToRef(intersectInfo.pickPosition, this.globalTransform, intersectInfo._globalPickPosition);
			intersectInfo._localPickPosition = intersectInfo.pickPosition.clone();
			intersectInfo.intersectedPrimitives = new Array<PrimitiveIntersectedInfo>();
			intersectInfo.topMostIntersectedPrimitive = null;
		}
		
		if (!intersectInfo.intersectHidden && !this.isVisible) {
			return false;
		}
		
		var id = this.id;
		if (id != null && id.indexOf("__cachedSpriteOfGroup__") == 0) {
			var ownerGroup = this.getExternalData("__cachedGroup__");
			return ownerGroup.intersect(intersectInfo);
		}
		
		// If we're testing a cachedGroup, we must reject pointer outside its levelBoundingInfo because children primitives could be partially clipped outside so we must not accept them as intersected when it's the case (because they're not visually visible).
		var isIntersectionTest = false;
		if (Std.is(this, Group2D)) {
			var g:Group2D = cast this;
			isIntersectionTest = g.isCachedGroup;
		}
		if (isIntersectionTest && !this.levelBoundingInfo.doesIntersect(intersectInfo._localPickPosition)) {
			// Important to call this before each return to allow a good recursion next time this intersectInfo is reused
			intersectInfo._exit(firstLevel);
			return false;
		}
		
		// Fast rejection test with boundingInfo
		if (this.isPickable && !this.boundingInfo.doesIntersect(intersectInfo._localPickPosition)) {
			// Important to call this before each return to allow a good recursion next time this intersectInfo is reused
			intersectInfo._exit(firstLevel);
			return false;
		}
		
		// We hit the boundingInfo that bounds this primitive and its children, now we have to test on the primitive of this level
		var levelIntersectRes = false;
		if (this.isPickable) {
			levelIntersectRes = this.levelIntersect(intersectInfo);
			if (levelIntersectRes) {
				var pii = new PrimitiveIntersectedInfo(this, intersectInfo._localPickPosition.clone());
				intersectInfo.intersectedPrimitives.push(pii);
				if (intersectInfo.topMostIntersectedPrimitive == null || (intersectInfo.topMostIntersectedPrimitive.prim.actualZOffset > pii.prim.actualZOffset)) {
					intersectInfo.topMostIntersectedPrimitive = pii;
				}
				
				// If we must stop at the first intersection, we're done, quit!
				if (intersectInfo.findFirstOnly) {
					intersectInfo._exit(firstLevel);
					return true;
				}
			}
		}
		// Recurse to children if needed
		if (!levelIntersectRes || !intersectInfo.findFirstOnly) {
			for (curChild in this._children) {
				// Don't test primitive not pick able or if it's hidden and we don't test hidden ones
				if ((!curChild.isPickable && curChild.isContainer) || (!intersectInfo.intersectHidden && !curChild.isVisible)) {
					continue;
				}
				
				// Must compute the localPickLocation for the children level
				Vector2.TransformToRef(intersectInfo._globalPickPosition, curChild.invGlobalTransform, intersectInfo._localPickPosition);
				
				// If we got an intersection with the child and we only need to find the first one, quit!
				if (curChild.intersect(intersectInfo) && intersectInfo.findFirstOnly) {
					intersectInfo._exit(firstLevel);
					return true;
				}
			}
		}
		
		intersectInfo._exit(firstLevel);
		
		return intersectInfo.isIntersected;
	}

	/**
	 * Move a child object into a new position regarding its siblings to change its rendering order.
	 * You can also use the shortcut methods to move top/bottom: moveChildToTop, moveChildToBottom, moveToTop, moveToBottom.
	 * @param child the object to move
	 * @param previous the object which will be before "child", if child has to be the first among sibling, set "previous" to null.
	 */
	public function moveChild(child:Prim2DBase, previous:Prim2DBase):Bool {
		if (child.parent != this) {
			return false;
		}
		
		var childIndex = this._children.indexOf(child);
		var prevIndex = previous != null ? this._children.indexOf(previous) : -1;
		
		if (!this._isFlagSet(SmartPropertyPrim.flagChildrenFlatZOrder)) {
			this._setFlags(SmartPropertyPrim.flagZOrderDirty);
			this._firstZDirtyIndex = Math.min(this._firstZDirtyIndex, prevIndex + 1);
		}
		
		this._children.splice(prevIndex + 1, 0, this._children.splice(childIndex, 1)[0]);
		
		return true;
	}

	/**
	 * Move the given child so it's displayed on the top of all its siblings
	 * @param child the primitive to move to the top
	 */
	public function moveChildToTop(child:Prim2DBase):Bool {
		return this.moveChild(child, this._children[this._children.length - 1]);
	}

	/**
	 * Move the given child so it's displayed on the bottom of all its siblings
	 * @param child the primitive to move to the top
	 */
	public function moveChildToBottom(child:Prim2DBase):Bool {
		return this.moveChild(child, null);
	}

	/**
	 * Move this primitive to be at the top among all its sibling
	 */
	public function moveToTop():Bool {
		if (this.parent == null) {
			return false;
		}
		
		return this.parent.moveChildToTop(this);
	}

	/**
	 * Move this primitive to be at the bottom among all its sibling
	 */
	public function moveToBottom() {
		if (this.parent == null) {
			return false;
		}
		
		return this.parent.moveChildToBottom(this);
	}

	private function addChild(child:Prim2DBase) {
		child._parent = this;
		this._boundingBoxDirty();
		var flat = this._isFlagSet(SmartPropertyPrim.flagChildrenFlatZOrder);
		if (flat) {
			child._setFlags(SmartPropertyPrim.flagChildrenFlatZOrder);
			child._setZOrder(this._zOrder, true);
			child._zMax = this._zOrder;
		} 
		else {
			this._setFlags(SmartPropertyPrim.flagZOrderDirty);
		}
		
		var length = this._children.push(child);
		this._firstZDirtyIndex = Math.min(this._firstZDirtyIndex, length - 1);
	}

	/**
	 * Dispose the primitive, remove it from its parent.
	 */
	public function dispose():Bool {
		if (!super.dispose()) {
			return false;
		}
		
		if (this._actionManager != null) {
			this._actionManager.dispose();
			this._actionManager = null;
		}
		
		// If there's a parent, remove this object from its parent list
		if (this._parent != null) {
			if (Std.is(this, Group2D)) {
				var g:Group2D = cast this;
				if (g.isRenderableGroup) {
					var parentRenderable = this.parent.traverseUp(function(p) { return (Std.is(p, Group2D) && p.isRenderableGroup); } );
					if (parentRenderable != null) {
						var l = parentRenderable._renderableData._childrenRenderableGroups;
						var i = l.indexOf(g);
						if (i != -1) {
							l.splice(i, 1);
						}
					}
				}
			}
			
			var i = this._parent._children.indexOf(this);
			if (i != -1) {
				this._parent._children.splice(i, 1);
			}
			
			this._parent = null;
		}
		
		// Recurse dispose to children
		if (this._children != null) {
			while (this._children.length > 0) {
				this._children[this._children.length - 1].dispose();
			}
		}
		
		return true;
	}

	private function onPrimBecomesDirty() {
		if (this._renderGroup != null && !this._isFlagSet(SmartPropertyPrim.flagPrimInDirtyList)) {
			this._renderGroup._addPrimToDirtyList(this);
			this._setFlags(SmartPropertyPrim.flagPrimInDirtyList);
		}
	}

	public function _needPrepare():Bool {
		return this._areSomeFlagsSet(SmartPropertyPrim.flagVisibilityChanged | SmartPropertyPrim.flagModelDirty | SmartPropertyPrim.flagNeedRefresh) || (this._instanceDirtyFlags != 0) || (this._globalTransformProcessStep != this._globalTransformStep);
	}

	public function _prepareRender(context:PrepareRender2DContext) {
		this._prepareRenderPre(context);
		this._prepareRenderPost(context);
	}

	public function _prepareRenderPre(context:PrepareRender2DContext) {
	}

	public function _prepareRenderPost(context:PrepareRender2DContext) {
		// Don't recurse if it's a renderable group, the content will be processed by the group itself
		if (Std.is(this, Group2D)) {
			if (this.isRenderableGroup) {
				return;
			}
		}
		
		// Check if we need to recurse the prepare to children primitives
		//  - must have children
		//  - the global transform of this level have changed, or
		//  - the visible state of primitive has changed
		if (this._children.length > 0 && ((this._globalTransformProcessStep != this._globalTransformStep) ||
			this.checkPropertiesDirty(Prim2DBase.isVisibleProperty.flagId))) {
			for (c in this._children) {
				// As usual stop the recursion if we meet a renderable group
				if (!(Std.is(c, Group2D) && c.isRenderableGroup)) {
					c._prepareRender(context);
				}
			}
		}
		
		// Finally reset the dirty flags as we've processed everything
		this._clearFlags(SmartPropertyPrim.flagModelDirty);
		this._instanceDirtyFlags = 0;
	}

	private function _canvasPreInit(settings:Dynamic) {

	}

	private static var _isCanvasInit:Bool = false;
	private static var CheckParent(parent:Prim2DBase) {  // TODO remove
		//if (!Prim2DBase._isCanvasInit && !parent) {
		//    throw new Error("A Primitive needs a valid Parent, it can be any kind of Primitives based types, even the Canvas (with the exception that only Group2D can be direct child of a Canvas if the cache strategy used is TOPLEVELGROUPS)");
		//}
	}

	private function updateCachedStatesOf(list:Array<Prim2DBase>, recurse:Bool) {
		for (cur in list) {
			cur.updateCachedStates(recurse);
		}
	}

	private function _parentLayoutDirty() {
		if (this._parent == null || this._parent.isDisposed) {
			return;
		}
		
		this._parent._setLayoutDirty();
	}

	private function _setLayoutDirty() {
		this.onPrimBecomesDirty();
		this._setFlags(SmartPropertyPrim.flagLayoutDirty);
	}

	private function _checkPositionChange():Bool {
		if (this.parent != null && this.parent.layoutEngine.isChildPositionAllowed == false) {
			trace("Can't manually set the position of ${this.id}, the Layout Engine of its parent doesn't allow it");
			return false;
		}
		
		return true;
	}

	private function _positioningDirty() {
		this.onPrimBecomesDirty();
		this._setFlags(SmartPropertyPrim.flagPositioningDirty);
	}

	private function _spreadActualOpacityChanged() {
		for (child in this._children) {
			child._setFlags(SmartPropertyPrim.flagActualOpacityDirty);
			child._updateRenderMode();
			child.onPrimBecomesDirty();
			child._spreadActualOpacityChanged();
		}
	}

	private function _changeLayoutEngine(engine:LayoutEngineBase) {
		this._layoutEngine = engine;
	}

	private static var _t0:Matrix = new Matrix();
	private static var _t1:Matrix = new Matrix();
	private static var _t2:Matrix = new Matrix();
	private static var _v0:Vector2 = Vector2.Zero();   // Must stay with the value 0,0

	private function _updateLocalTransform():Bool {
		var tflags = Prim2DBase.actualPositionProperty.flagId | Prim2DBase.rotationProperty.flagId | Prim2DBase.scaleProperty.flagId | Prim2DBase.scaleXProperty.flagId | Prim2DBase.scaleYProperty.flagId | Prim2DBase.originProperty.flagId;
		if (this.checkPropertiesDirty(tflags)) {
			if (this.owner != null) {
				this.owner.addupdateLocalTransformCounter(1);
			}
			
			var rot = Quaternion.RotationAxis(new Vector3(0, 0, 1), this._rotation);
			var local:Matrix = null;
			var pos = this.position;
			
			if (this._origin.x == 0 && this._origin.y == 0) {
				local = Matrix.Compose(new Vector3(this._scale.x, this._scale.y, 1), rot, new Vector3(pos.x, pos.y, 0));
				this._localTransform = local;
			} 
			else {
				// -Origin offset
				var as = this.actualSize;
				Matrix.TranslationToRef(( -as.width * this._origin.x), ( -as.height * this._origin.y), 0, Prim2DBase._t0);
				
				// -Origin * rotation
				rot.toRotationMatrix(Prim2DBase._t1);
				Prim2DBase._t0.multiplyToRef(Prim2DBase._t1, Prim2DBase._t2);
				
				// -Origin * rotation * scale
				Matrix.ScalingToRef(this._scale.x, this._scale.y, 1, Prim2DBase._t0);
				Prim2DBase._t2.multiplyToRef(Prim2DBase._t0, Prim2DBase._t1);
				
				// -Origin * rotation * scale * (Origin + Position)
				Matrix.TranslationToRef((as.width * this._origin.x) + pos.x, (as.height * this._origin.y) + pos.y, 0, Prim2DBase._t2);
				Prim2DBase._t1.multiplyToRef(Prim2DBase._t2, this._localTransform);
			}
			
			this.clearPropertiesDirty(tflags);
			this._setFlags(SmartPropertyPrim.flagGlobalTransformDirty);
			
			return true;
		}
		
		return false;
	}

	private static var _transMtx:Matrix = Matrix.Zero();

	private function updateCachedStates(recurse:Bool) {
		if (this.isDisposed) {
			return;
		}
		
		this.owner.addCachedGroupRenderCounter(1);
		
		// Check if the parent is synced
		if (this._parent != null && ((this._parent._globalTransformProcessStep != this.owner._globalTransformProcessStep) || this._parent._areSomeFlagsSet(SmartPropertyPrim.flagLayoutDirty | SmartPropertyPrim.flagPositioningDirty | SmartPropertyPrim.flagZOrderDirty))) {
			this._parent.updateCachedStates(false);
		}
		
		// Update Z-Order if needed
		if (this._isFlagSet(SmartPropertyPrim.flagZOrderDirty)) {
			this._updateZOrder();
		}
		
		// Update actualSize only if there' not positioning to recompute and the size changed
		// Otherwise positioning will take care of it.
		var sizeDirty = this.checkPropertiesDirty(Prim2DBase.sizeProperty.flagId);
		if (!this._isFlagSet(SmartPropertyPrim.flagLayoutDirty) && !this._isFlagSet(SmartPropertyPrim.flagPositioningDirty) && sizeDirty) {
			var size = this.size;
			if (size != null) {
				if (this.size.width != null) {
					this.actualSize.width = this.size.width;
				}
				if (this.size.height != null) {
					this.actualSize.height = this.size.height;
				}
				this.clearPropertiesDirty(Prim2DBase.sizeProperty.flagId);
			}
		}
		
		// Check for layout update
		var positioningDirty = this._isFlagSet(SmartPropertyPrim.flagPositioningDirty);
		if (this._isFlagSet(SmartPropertyPrim.flagLayoutDirty)) {
			this.owner.addUpdateLayoutCounter(1);
			this._layoutEngine.updateLayout(this);
			
			this._clearFlags(SmartPropertyPrim.flagLayoutDirty);
		}
		
		var positioningComputed = positioningDirty && !this._isFlagSet(SmartPropertyPrim.flagPositioningDirty);
		var autoContentChanged = false;
		if (this.isSizeAuto) {
			if (this._lastAutoSizeArea == null) {
				autoContentChanged = this.size != null;
			} 
			else {
				autoContentChanged = (!this._lastAutoSizeArea.equals(this.size));
			}
		}
		
		// Check for positioning update
		if (!positioningComputed && (autoContentChanged || sizeDirty || this._isFlagSet(SmartPropertyPrim.flagPositioningDirty) || (this._parent != null && !this._parent.contentArea.equals(this._parentContentArea)))) {
			this._updatePositioning();
			
			this._clearFlags(SmartPropertyPrim.flagPositioningDirty);
			if (sizeDirty) {
				this.clearPropertiesDirty(Prim2DBase.sizeProperty.flagId);
			}
			positioningComputed = true;
		}
		
		if (positioningComputed && this._parent != null) {
			this._parentContentArea.copyFrom(this._parent.contentArea);
		}
		
		// Check if we must update this prim
		if (this == this.owner || this._globalTransformProcessStep != this.owner._globalTransformProcessStep) {
			this.owner.addUpdateGlobalTransformCounter(1);
			
			var curVisibleState = this.isVisible;
			this.isVisible = (!this._parent || this._parent.isVisible) && this.levelVisible;
			
			// Detect a change of visibility
			this._changeFlags(SmartPropertyPrim.flagVisibilityChanged, curVisibleState != this.isVisible);
			
			// Get/compute the localTransform
			var localDirty = this._updateLocalTransform();
			
			var parentPaddingChanged = false;
			var parentPaddingOffset:Vector2 = Prim2DBase._v0;
			if (this._parent != null) {
				parentPaddingOffset = new Vector2(this._parent._paddingOffset.x, this._parent._paddingOffset.y);
				parentPaddingChanged = !parentPaddingOffset.equals(this._parentPaddingOffset);
			}
			
			// Check if there are changes in the parent that will force us to update the global matrix
			var parentDirty = (this._parent != null) ? (this._parent._globalTransformStep != this._parentTransformStep) : false;
			
			// Check if we have to update the globalTransform
			if (this._globalTransform == null || localDirty || parentDirty || parentPaddingChanged || this._areSomeFlagsSet(SmartPropertyPrim.flagGlobalTransformDirty)) {
				var globalTransform = this._parent != null ? this._parent._globalTransform : null;
				
				var localTransform:Matrix;
				Prim2DBase._transMtx.copyFrom(this._localTransform);
				Prim2DBase._transMtx.m[12] += this._layoutAreaPos.x + this._marginOffset.x + parentPaddingOffset.x;
				Prim2DBase._transMtx.m[13] += this._layoutAreaPos.y + this._marginOffset.y + parentPaddingOffset.y;
				localTransform = Prim2DBase._transMtx;
				
				this._globalTransform = this._parent != null ? localTransform.multiply(globalTransform) : localTransform.clone();
				
				this._invGlobalTransform = Matrix.Invert(this._globalTransform);
				
				this._globalTransformStep = this.owner._globalTransformProcessStep + 1;
				this._parentTransformStep = this._parent != null ? this._parent._globalTransformStep : 0;
				this._clearFlags(SmartPropertyPrim.flagGlobalTransformDirty);
			}
			
			this._globalTransformProcessStep = this.owner._globalTransformProcessStep;
		}
		
		if (recurse) {
			for (child in this._children) {
				// Stop the recursion if we meet a renderable group
				child.updateCachedStates(!(Std.is(child, Group2D) && child.isRenderableGroup));
			}
		}
	}

	private static var _icPos:Vector2 = Vector2.Zero();
	private static var _icZone:Vector4 = Vector4.Zero();
	private static var _icArea:Size = Size.Zero();
	private static var _size:Size = Size.Zero();

	private function _updatePositioning() {
		if (this.owner != null) {
			this.owner.addUpdatePositioningCounter(1);
		}
		
		// From this point we assume that the primitive layoutArea is computed and up to date.
		// We know have to :
		//  1. Determine the PaddingArea and the ActualPosition based on the margin/marginAlignment properties, which will also set the size property of the primitive
		//  2. Determine the contentArea based on the padding property.

		// Auto Create PaddingArea if there's no actualSize on width&|height to allocate the whole content available to the paddingArea where the actualSize is null
		if (!this._hasMargin && (this.isSizeAuto || (this.actualSize.width == null || this.actualSize.height == null))) {
			if (this.isSizeAuto || this.actualSize.width == null) {
				this.marginAlignment.horizontal = PrimitiveAlignment.AlignStretch;
			}
			
			if (this.isSizeAuto || this.actualSize.height == null) {
				this.marginAlignment.vertical = PrimitiveAlignment.AlignStretch;
			}
		}
		
		// Apply margin
		if (this._hasMargin) {
			this.margin.computeWithAlignment(this.layoutArea, this.size, this.marginAlignment, this._marginOffset, Prim2DBase._size);
			this.actualSize = Prim2DBase._size.clone();
		}
		
		var po = new Vector2(this._paddingOffset.x, this._paddingOffset.y);
		if (this._hasPadding) {
			// Two cases from here: the size of the Primitive is Auto, its content can't be shrink, so me resize the primitive itself
			if (isSizeAuto) {
				var content = this.size.clone();
				this._getActualSizeFromContentToRef(content, Prim2DBase._icArea);
				this.padding.enlarge(Prim2DBase._icArea, po, Prim2DBase._size);
				this._contentArea.copyFrom(content);
				this.actualSize = Prim2DBase._size.clone();
				
				// Changing the padding has resize the prim, which forces us to recompute margin again
				if (this._hasMargin) {
					this.margin.computeWithAlignment(this.layoutArea, Prim2DBase._size, this.marginAlignment, this._marginOffset, Prim2DBase._size);
				}
			} 
			else {
				this._getInitialContentAreaToRef(this.actualSize, Prim2DBase._icZone, Prim2DBase._icArea);
				Prim2DBase._icArea.width = Math.max(0, Prim2DBase._icArea.width);
				Prim2DBase._icArea.height = Math.max(0, Prim2DBase._icArea.height);
				this.padding.compute(Prim2DBase._icArea, po, Prim2DBase._size);
                this._paddingOffset.x = po.x;
                this._paddingOffset.y = po.y;
                this._paddingOffset.x += Prim2DBase._icZone.x;
                this._paddingOffset.y += Prim2DBase._icZone.y;
                this._paddingOffset.z -= Prim2DBase._icZone.z;
                this._paddingOffset.w -= Prim2DBase._icZone.w;
				this._contentArea.copyFrom(Prim2DBase._size);
			}
		} 
		else {
			this._getInitialContentAreaToRef(this.actualSize, Prim2DBase._icZone, Prim2DBase._icArea);
			Prim2DBase._icArea.width = Math.max(0, Prim2DBase._icArea.width);
			Prim2DBase._icArea.height = Math.max(0, Prim2DBase._icArea.height);
			this._paddingOffset.x = Prim2DBase._icZone.x;
            this._paddingOffset.y = Prim2DBase._icZone.y;
            this._paddingOffset.z = Prim2DBase._icZone.z;
            this._paddingOffset.w = Prim2DBase._icZone.z;
			this._contentArea.copyFrom(Prim2DBase._icArea);
		}
		
		if (this._position == null) {
			var aPos = new Vector2(this._layoutAreaPos.x + this._marginOffset.x, this._layoutAreaPos.y + this._marginOffset.y);
			this.actualPosition = aPos;
		}
		if (isSizeAuto) {
			this._lastAutoSizeArea = this.size;                
		}
	}

	/**
	 * Get the content are of this primitive, this area is computed using the padding property and also possibly the primitive type itself.
	 * Children of this primitive will be positioned relative to the bottom/left corner of this area.
	 */
	public var contentArea(get, never):Size;
	private function get_contentArea():Size {
		// Check for positioning update
		if (this._isFlagSet(SmartPropertyPrim.flagPositioningDirty)) {
			this._updatePositioning();
			
			this._clearFlags(SmartPropertyPrim.flagPositioningDirty);
		}
		
		return this._contentArea;
	}

	public function _patchHierarchy(owner:Canvas2D) {
		this._owner = owner;
		
		// The only place we initialize the _renderGroup is this method, if it's set, we already been there, no need to execute more
		if (this._renderGroup != null) {
			return;
		}
		
		if (Std.is(this, Group2D)) {
			var group = this;
			group.detectGroupStates();
			if (group._trackedNode && !group._isFlagSet(SmartPropertyPrim.flagTrackedGroup)) {
				group.owner._registerTrackedNode(this);
			}
		}
		
		this._renderGroup = cast this.traverseUp(function(p:Prim2DBase):Bool { return (Std.is(p, Group2D) && p.isRenderableGroup)); });
		if (this._parent != null) {
			this._parentLayoutDirty();
		}
		
		// Make sure the prim is in the dirtyList if it should be
		if (this._renderGroup && this.isDirty) {
			var list = this._renderGroup._renderableData._primDirtyList;
			var i = list.indexOf(this);
			if (i == -1) {
				list.push(this);
			}
		}
		
		// Recurse
		for (child in this._children) {
			child._hierarchyDepth = this._hierarchyDepth + 1;
			child._patchHierarchy(owner);
		}
	}
	
	private static var _zOrderChangedNotifList:Array<Prim2DBase> = [];
	private static var _zRebuildReentrency:Bool = false;

	private function _updateZOrder() {
		var prevLinPos = this._primLinearPosition;
		var startI = 0;
		var startZ = this._zOrder;
		
		// We must start rebuilding Z-Order from the Prim before the first one that changed, because we know its Z-Order is correct, so are its children, but it's better to recompute everything from this point instead of finding the last valid children
		var childrenCount = this._children.length;
		if (this._firstZDirtyIndex > 0) {
			if ((this._firstZDirtyIndex - 1) < childrenCount) {
				var prevPrim = this._children[this._firstZDirtyIndex - 1];
				prevLinPos = prevPrim._primLinearPosition;
				startI = this._firstZDirtyIndex - 1;
				startZ = prevPrim._zOrder;
			}
		}
		
		var startPos = prevLinPos;
		
		// Update the linear position of the primitive from the first one to the last inside this primitive, compute the total number of prim traversed
		Prim2DBase._totalCount = 0;
		for (i in startI...childrenCount) {
			let child = this._children[i];
			prevLinPos = child._updatePrimitiveLinearPosition(prevLinPos);
		}
		
		// Compute the new Z-Order for all the primitives
		// Add 20% to the current total count to reserve space for future insertions, except if we're rebuilding due to a zMinDelta reached
		var zDelta = (this._zMax - startZ) / (Prim2DBase._totalCount * (Prim2DBase._zRebuildReentrency ? 1 : 1.2));

		// If the computed delta is less than the smallest allowed by the depth buffer, we rebuild the Z-Order from the very beginning of the primitive's children (that is, the first) to redistribute uniformly the Z.
		if (zDelta < Canvas2D._zMinDelta) {
			// Check for re-entrance, if the flag is true we already attempted a rebuild but couldn't get a better zDelta, go up in the hierarchy to rebuilt one level up, hoping to get this time a decent delta, otherwise, recurse until we got it or when no parent is reached, which would mean the canvas would have more than 16 millions of primitives...
			if (Prim2DBase._zRebuildReentrency) {
				var p = this._parent;
				if (p == null) {
					// Can't find a good Z delta and we're in the canvas, which mean we're dealing with too many objects (which should never happen, but well...)
					trace("Can't compute Z-Order for ${this.id}'s children, zDelta is too small, Z-Order is now in an unstable state");
					Prim2DBase._zRebuildReentrency = false;
					
					return;
				}
				p._firstZDirtyIndex = 0;
				
				return p._updateZOrder();
			}
			
			Prim2DBase._zRebuildReentrency = true;
			this._firstZDirtyIndex = 0;
			this._updateZOrder();
			Prim2DBase._zRebuildReentrency = false;
		}
		
		for (i in startI...childrenCount) {
			var child = this._children[i];
			child._updatePrimitiveZOrder(startPos, startZ, zDelta);
		}
		
		// Notify the Observers that we found during the Z change (we do it after to avoid any kind of re-entrance)
		for (p in Prim2DBase._zOrderChangedNotifList) {
			p._actualZOrderChangedObservable.notifyObservers(p.actualZOffset);
		}
		Prim2DBase._zOrderChangedNotifList.splice(0);
		
		this._firstZDirtyIndex = Prim2DBase._bigInt;
		this._clearFlags(SmartPropertyPrim.flagZOrderDirty);
	}

	private static var _totalCount:Int = 0;

	private function _updatePrimitiveLinearPosition(prevLinPos:Int):Int {
		if (this.isManualZOrder) {
			return prevLinPos;
		}
		
		this._primLinearPosition = ++prevLinPos;
		Prim2DBase._totalCount++;
		
		// Check for the FlatZOrder, which means the children won't have a dedicated Z-Order but will all share the same (unique) one.
		if (!this._isFlagSet(SmartPropertyPrim.flagChildrenFlatZOrder)) {
			for (child in this._children) {
				prevLinPos = child._updatePrimitiveLinearPosition(prevLinPos);
			}
		}
		
		return prevLinPos;
	}

	private function _updatePrimitiveZOrder(startPos:Int, startZ:Int, deltaZ:Int):Int {
		if (this.isManualZOrder) {
			return null;
		}
		
		var newZ = startZ + ((this._primLinearPosition - startPos) * deltaZ);
		var isFlat = this._isFlagSet(SmartPropertyPrim.flagChildrenFlatZOrder);
		this._setZOrder(newZ, false);
		
		if (this._isFlagSet(SmartPropertyPrim.flagZOrderDirty)) {
			this._firstZDirtyIndex = Prim2DBase._bigInt;
			this._clearFlags(SmartPropertyPrim.flagZOrderDirty);
		}
		
		var curZ:Int = newZ;
		
		// Check for the FlatZOrder, which means the children won't have a dedicated Z-Order but will all share the same (unique) one.
		if (isFlat) {
			if (this._children.length > 0) {
				//let childrenZOrder = startZ + ((this._children[0]._primLinearPosition - startPos) * deltaZ);
				for (child in this._children) {
					child._updatePrimitiveFlatZOrder(this._zOrder);
				}
			}
		} 
		else {
			for (child in this._children) {
				var r = child._updatePrimitiveZOrder(startPos, startZ, deltaZ);
				if (r != null) {
					curZ = r;
				}
			}
		}
		
		this._zMax = isFlat ? newZ : (curZ + deltaZ);
		
		return curZ;
	}

	private function _updatePrimitiveFlatZOrder(newZ:Int) {
		if (this.isManualZOrder) {
			return;
		}

		this._setZOrder(newZ, false);
		this._zMax = newZ;

		if (this._isFlagSet(SmartPropertyPrim.flagZOrderDirty)) {
			this._firstZDirtyIndex = Prim2DBase._bigInt;
			this._clearFlags(SmartPropertyPrim.flagZOrderDirty);
		}

		for (child in this._children) {
			child._updatePrimitiveFlatZOrder(newZ);
		}

	}

	private function _setZOrder(newZ:Int, directEmit:Bool) {
		if (newZ != this._zOrder) {
			this._zOrder = newZ;
			this.onPrimBecomesDirty();
			this.onZOrderChanged();
			if (this._actualZOrderChangedObservable != null && this._actualZOrderChangedObservable.hasObservers()) {
				if (directEmit) {
					this._actualZOrderChangedObservable.notifyObservers(newZ);
				} 
				else {
					Prim2DBase._zOrderChangedNotifList.push(this);
				}
			}
		}
	}

	private function _updateRenderMode() {
		
	}

	/**
	 * This method is used to alter the contentArea of the Primitive before margin is applied.
	 * In most of the case you won't need to override this method, but it can prove some usefulness, check the Rectangle2D class for a concrete application.
	 * @param primSize the current size of the primitive
	 * @param initialContentPosition the position of the initial content area to compute, a valid object is passed, you have to set its properties. PLEASE ROUND the values, we're talking about pixels and fraction of them is not a good thing! x, y, z, w area left, bottom, right, top
	 * @param initialContentArea the size of the initial content area to compute, a valid object is passed, you have to set its properties. PLEASE ROUND the values, we're talking about pixels and fraction of them is not a good thing!
	 */
	private function _getInitialContentAreaToRef(primSize:Size, initialContentPosition:Vector4, initialContentArea:Size) {
		initialContentArea.copyFrom(primSize);
		initialContentPosition.x = initialContentPosition.y = initialContentPosition.z = initialContentPosition.w = 0;
	}

	/**
	 * This method is used to calculate the new size of the primitive based on the content which must stay the same
	 * Check the Rectangle2D implementation for a concrete application.
	 * @param primSize the current size of the primitive
	 * @param newPrimSize the new size of the primitive. PLEASE ROUND THE values, we're talking about pixels and fraction of them are not our friends!
	 */
	private function _getActualSizeFromContentToRef(primSize:Size, newPrimSize:Size) {
		newPrimSize.copyFrom(primSize);
	}

	private var _owner: Canvas2D;
	private var _parent: Prim2DBase;
	private var _actionManager:ActionManager;
	private var _children:Array<Prim2DBase>;
	private var _renderGroup:Group2D;
	private var _hierarchyDepth:Int;
	private var _zOrder:Int;
	private var _manualZOrder:Int;
	private var _zMax:Int;
	private var _firstZDirtyIndex:Int;
	private var _primLinearPosition:Int;
	private var _margin:PrimitiveThickness;
	private var _padding:PrimitiveThickness;
	private var _marginAlignment:PrimitiveAlignment;
	public var _pointerEventObservable:Observable<PrimitivePointerInfo>;
	private var _actualZOrderChangedObservable:Observable<Int>;
	private var _id:String;
	private var _position:Vector2;
	private var _actualPosition:Vector2;
	private var _size:Size;
	private var _actualSize:Size;
	public var _boundingSize:Size;
	private var _minSize:Size;
	private var _maxSize:Size;
	private var _desiredSize:Size;
	private var _layoutEngine:LayoutEngineBase;
	private var _marginOffset:Vector2;
	private var _paddingOffset:Vector2;
	private var _parentPaddingOffset:Vector2;
	private var _parentContentArea:Size;
	private var _lastAutoSizeArea:Size;
	private var _layoutAreaPos:Vector2;
	private var _layoutArea:Size;
	private var _contentArea:Size;
	private var _rotation:Float;
	private var _scale:Vector2;
	private var _origin:Vector2;
	private var _opacity:Float;
	private var _actualOpacity:Float;
	private var _actualScale:Vector2;

	// Stores the step of the parent for which the current global transform was computed
	// If the parent has a new step, it means this prim's global transform must be updated
	private var _parentTransformStep:Float;

	// Stores the step corresponding of the global transform for this prim
	// If a child prim has an older _parentTransformStep it means the child's transform should be updated
	private var _globalTransformStep:Float;

	// Stores the previous 
	private var _globalTransformProcessStep:Float;
	private var _localTransform:Matrix;
	private var _globalTransform:Matrix;
	private var _invGlobalTransform:Matrix;
	
}
