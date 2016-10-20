package com.babylonhx.tools;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PropertyChangedInfo<T> {
	
	/**
	 * Previous value of the property
	 */
	public var oldValue:T;
	/**
	 * New value of the property
	 */
	public var newValue:T;

	/**
	 * Name of the property that changed its value
	 */
	public var propertyName:String;
	

	public function new() {
		
	}
	
}
