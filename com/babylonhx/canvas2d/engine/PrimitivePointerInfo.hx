package com.babylonhx.canvas2d.engine;

import com.babylonhx.math.Vector2;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * This class store information for the pointerEventObservable Observable.
 * The Observable is divided into many sub events (using the Mask feature of the Observable pattern): PointerOver, PointerEnter, PointerDown,
 * PointerMouseWheel, PointerMove, PointerUp, PointerDown, PointerLeave, PointerGotCapture and PointerLostCapture.
 */
class PrimitivePointerInfo {

	// The behavior is based on the HTML specifications of the Pointer Events (https://www.w3.org/TR/pointerevents/#list-of-pointer-events). This is not 100% compliant and not meant to be, but still, it's based on these specs for most use cases to be programmed the same way (as closest as possible) as it would have been in HTML.

	/**
	 * This event type is raised when a pointing device is moved into the hit test boundaries of a primitive.
	 * Bubbles: yes
	 */
	public static inline var pointerOver:Int = 0x0001;
	/**
	 * This event type is raised when a pointing device is moved into the hit test boundaries of a primitive or one of its descendants.
	 * Bubbles: no
	 */
	public static inline var pointerEnter:Int = 0x0002;
	/**
	 * This event type is raised when a pointer enters the active button state (non-zero value in the buttons property). 
	 * For mouse it's when the device transitions from no buttons depressed to at least one button depressed. 
	 * For touch/pen this is when a physical contact is made.
	 * Bubbles: yes
	 */
	public static inline var pointerDown:Int = 0x0004;
	/**
	 * This event type is raised when the pointer is a mouse and it's wheel is rolling
	 * Bubbles: yes
	 */
	public static inline var pointerMouseWheel:Int = 0x0008;
	/**
	 * This event type is raised when a pointer change coordinates or when a pointer changes button state, pressure, tilt, 
	 * or contact geometry and the circumstances produce no other pointers events.
	 * Bubbles: yes
	 */
	public static inline var pointerMove:Int = 0x0010;
	/**
	 * This event type is raised when the pointer leaves the active buttons states (zero value in the buttons property). 
	 * For mouse, this is when the device transitions from at least one button depressed to no buttons depressed. 
	 * For touch/pen, this is when physical contact is removed.
	 * Bubbles: yes
	 */
	public static inline var pointerUp:Int = 0x0020;
	/**
	 * This event type is raised when a pointing device is moved out of the hit test the boundaries of a primitive.
	 * Bubbles: yes
	 */
	public static inline var pointerOut:Int = 0x0040;
	/**
	 * This event type is raised when a pointing device is moved out of the hit test boundaries of a primitive and all its descendants.
	 * Bubbles: no
	 */
	public static inline var pointerLeave:Int = 0x0080;
	/**
	 * This event type is raised when a primitive receives the pointer capture. 
	 * This event is fired at the element that is receiving pointer capture. Subsequent events for that pointer will be fired at this element.
	 * Bubbles: yes
	 */
	public static inline var pointerGotCapture:Int = 0x0100;
	/**
	 * This event type is raised after pointer capture is released for a pointer.
	 * Bubbles: yes
	 */
	public static inline var pointerLostCapture:Int = 0x0200;

	public static inline var mouseWheelPrecision:Int = 3.0;

	/**
	 * Event Type, one of the static PointerXXXX property defined above (PrimitivePointerInfo.PointerOver to PrimitivePointerInfo.PointerLostCapture)
	 */
	public var eventType:Int;

	/**
	 * Position of the pointer relative to the bottom/left of the Canvas
	 */
	public var canvasPointerPos:Vector2;

	/**
	 * Position of the pointer relative to the bottom/left of the primitive that registered the Observer
	 */
	public var primitivePointerPos:Vector2;

	/**
	 * The primitive where the event was initiated first (in case of bubbling)
	 */
	public var relatedTarget:Prim2DBase;

	/**
	 * Position of the pointer relative to the bottom/left of the relatedTarget
	 */
	public var relatedTargetPointerPos:Vector2;

	/**
	 * An observable can set this property to true to stop bubbling on the upper levels
	 */
	public var cancelBubble:Bool;

	/**
	 * True if the Control keyboard key is down
	 */
	public var ctrlKey:Bool;

	/**
	 * true if the Shift keyboard key is down
	 */
	public var shiftKey:Bool;

	/**
	 * true if the Alt keyboard key is down
	 */
	public var altKey:Bool;

	/**
	 * true if the Meta keyboard key is down
	 */
	public var metaKey:Bool;

	/**
	 * For button, buttons, refer to https://www.w3.org/TR/pointerevents/#button-states
	 */
	public var button:Int;
	/**
	 * For button, buttons, refer to https://www.w3.org/TR/pointerevents/#button-states
	 */
	public var buttons:Int;

	/**
	 * The amount of mouse wheel rolled
	 */
	public var mouseWheelDelta:Float;

	/**
	 * Id of the Pointer involved in the event
	 */
	public var pointerId:Int;
	public var width:Int;
	public var height:Int;
	public var presssure:Float;
	public var tilt:Vector2;

	/**
	 * true if the involved pointer is captured for a particular primitive, false otherwise.
	 */
	public var isCaptured:Bool;
	

	public function new() {
		this.primitivePointerPos = Vector2.Zero();
		this.tilt = Vector2.Zero();
		this.cancelBubble = false;
	}

	public function updateRelatedTarget(prim:Prim2DBase, primPointerPos:Vector2) {
		this.relatedTarget = prim;
		this.relatedTargetPointerPos = primPointerPos;
	}

	public static function getEventTypeName(mask:Int):String {
		switch (mask) {
			case PrimitivePointerInfo.PointerOver: return "PointerOver";
			case PrimitivePointerInfo.PointerEnter: return "PointerEnter";
			case PrimitivePointerInfo.PointerDown: return "PointerDown";
			case PrimitivePointerInfo.PointerMouseWheel: return "PointerMouseWheel";
			case PrimitivePointerInfo.PointerMove: return "PointerMove";
			case PrimitivePointerInfo.PointerUp: return "PointerUp";
			case PrimitivePointerInfo.PointerOut: return "PointerOut";
			case PrimitivePointerInfo.PointerLeave: return "PointerLeave";
			case PrimitivePointerInfo.PointerGotCapture: return "PointerGotCapture";
			case PrimitivePointerInfo.PointerLostCapture: return "PointerLostCapture";
		}
	}
	
}
