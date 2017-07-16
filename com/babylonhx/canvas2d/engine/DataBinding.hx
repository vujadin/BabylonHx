package com.babylonhx.canvas2d.engine;

import com.babylonhx.tools.IPropertyChanged;

/**
 * ...
 * @author Krtolica Vujadin
 */
class DataBinding {

	/**
	 * Use the mode specified in the SmartProperty declaration
	 */
	public static inline var MODE_DEFAULT:Int = 1;

	/**
	 * Update the binding target only once when the Smart Property's value is first accessed
	 */
	public static inline var MODE_ONETIME:Int = 2;

	/**
	 * Update the smart property when the source changes.
	 * The source won't be updated if the smart property value is set.
	 */
	public static inline var MODE_ONEWAY:Int = 3;

	/**
	 * Only update the source when the target's data is changing.
	 */
	public static inline var MODE_ONEWAYTOSOURCE:Int = 4;

	/**
	 * Update the bind target when the source changes and update the source when the Smart Property value is set.
	 */
	public static inline var MODE_TWOWAY:Int = 5;

	/**
	 * Use the Update Source Trigger defined in the SmartProperty declaration
	 */
	public static inline var UPDATESOURCETRIGGER_DEFAULT:Int = 1;

	/**
	 * Update the source as soon as the Smart Property has a value change
	 */
	public static inline var UPDATESOURCETRIGGER_PROPERTYCHANGED:Int = 2;

	/**
	 * Update the source when the binding target loses focus
	 */
	public static inline var UPDATESOURCETRIGGER_LOSTFOCUS:Int = 3;

	/**
	 * Update the source will be made by explicitly calling the UpdateFromDataSource method
	 */
	public static inline var UPDATESOURCETRIGGER_EXPLICIT:Int = 4;
	
	
	/**
	 * The PropInfo of the property the binding is bound to
	 */
	public var _boundTo:Prim2DPropInfo;

	public var _owner:SmartPropertyBase;

	private var _converter:Dynamic->Dynamic;
	private var _mode:Int;
	private var _uiElementId:String;
	private var _dataSource:IPropertyChanged;
	public var _currentDataSource:IPropertyChanged;
	private var _propertyPathName:String;
	private var _stringFormat:Dynamic->String;
	private var _updateSourceTrigger:Int;
	private var _updateCounter:Int;
	

	public function new() {
		this._converter = null;
		this._mode = DataBinding.MODE_DEFAULT;
		this._uiElementId = null;
		this._dataSource = null;
		this._currentDataSource = null;
		this._propertyPathName = null;
		this._stringFormat = null;
		this._updateSourceTrigger = DataBinding.UPDATESOURCETRIGGER_PROPERTYCHANGED;
		this._boundTo = null;
		this._owner = null;
		this._updateCounter = 0;
	}

	/**
	 * Provide a callback that will convert the value obtained by the Data Binding to the type of the SmartProperty it's bound to.
	 * If no value are set, then it's assumed that the sourceValue is of the same type as the SmartProperty's one.
	 * If the SmartProperty type is a basic data type (string, boolean or number) and no converter is specified but 
	 * the sourceValue is of a different type, the conversion will be implicitly made, if possible.
	 * @param sourceValue the source object retrieve by the Data Binding mechanism
	 * @returns the object of a compatible type with the SmartProperty it's bound to
	 */
	public var converter(get, set):Dynamic->Dynamic;
	private function get_converter():Dynamic->Dynamic {
		return this._converter;
	}
	private function set_converter(value:Dynamic->Dynamic):Dynamic->Dynamic {
		return this._converter = value;
	}

	/**
	 * Set the mode to use for the data flow in the binding. Set one of the MODE_xxx static member of this class. If not specified then MODE_DEFAULT will be used
	 */
	public var mode(get, set):Int;
	private function get_mode():Int {
		if (this._mode == DataBinding.MODE_DEFAULT) {
			return this._boundTo.bindingMode;
		}
		
		return this._mode;
	}
	private function set_mode(value:Int):Int {
		return this._mode = value;
	}

	/**
	 * You can override the Data Source object with this member which is the Id of a uiElement existing in the UI Logical tree.
	 * If not set and source no set too, then the dataSource property will be used.
	 */
	public var uiElementId(get, set):String;
	private function get_uiElementId():String {
		return this._uiElementId;
	}
	private function set_uiElementId(value:String):String {
		return this._uiElementId = value;
	}

	/**
	 * You can override the Data Source object with this member which is the source object to use directly.
	 * If not set and uiElement no set too, then the dataSource property of the SmartPropertyBase object will be used.
	 */
	public var dataSource(get, set):IPropertyChanged;
	private function get_dataSource():IPropertyChanged {
		return this._dataSource;
	}
	private function set_dataSource(value:IPropertyChanged):IPropertyChanged {
		return this._dataSource = value;
	}

	/**
	 * The path & name of the property to get from the source object.
	 * Once the Source object is evaluated (it's either the one got from uiElementId, source or dataSource) you can specify which property of this object is the value to bind to the smartProperty.
	 * If nothing is set then the source object will be used.
	 * You can specify an indirect property using the format "firstProperty.indirectProperty" like "address.postalCode" if the source is a Customer object which contains an address property and the Address class contains a postalCode property.
	 * If the property is an Array and you want to address a particular element then use the 'arrayProperty[index]' notation. For example "phoneNumbers[0]" to get the first element of the phoneNumber property which is an array.
	 */
	public var propertyPathName(get, set):String;
	private function get_propertyPathName():String {
		return this._propertyPathName;
	}
	private function set_propertyPathName(value:String):String {
		if (this._propertyPathName == value) {
			return value;
		}
		
		if (this._owner != null) {
			//BindingWatcher.unregisterBinding(this, null);
		}
		
		this._propertyPathName = value;
		
		if (this._owner != null) {
			//let watched = BindingWatcher._getDataSource(this._owner.dataSource, this);
			//BindingWatcher.refreshBinding(watched, this._owner, this, true, null, true);
		}
		
		return value;
	}

	/**
	 * If the Smart Property is of the string type, you can use the string interpolation notation to provide how the sourceValue will be formatted, reference to the source value must be made via the token: ${value}. For instance `Customer Name: ${value}`
	 */
	public var stringFormat(get, set):Dynamic->String;
	private function get_stringFormat():Dynamic->String {
		return this._stringFormat;
	}
	private function set_stringFormat(value:Dynamic->String):Dynamic->String {
		return this._stringFormat = value;
	}

	/**
	 * Specify how the source should be updated, use one of the UPDATESOURCETRIGGER_xxx member of this class, 
	 * if not specified then UPDATESOURCETRIGGER_DEFAULT will be used.
	 */
	public var updateSourceTrigger(get, set):Int;
	private function get_updateSourceTrigger():Int {
		return this._updateSourceTrigger;
	}
	private function set_updateSourceTrigger(value:Int):Int {
		return this._updateSourceTrigger = value;
	}

	public function canUpdateTarget(resetUpdateCounter:Bool):Bool {
		if (resetUpdateCounter) {
			this._updateCounter = 0;
		}
		
		if (mode == DataBinding.MODE_ONETIME) {
			return this._updateCounter == 0;
		}
		
		if (mode == DataBinding.MODE_ONEWAYTOSOURCE) {
			return false;
		}
		
		return true;
	}

	public function updateTarget() {
		var value = this._getActualDataSource();
		var properties = this.propertyPathName.split(".");
		for (propertyName in properties) {
			value = value[propertyName];
		}
		this._storeBoundValue(this._owner, value);
	}

	public function _storeBoundValue(watcher:SmartPropertyBase, value:Dynamic) {
		if ((++this._updateCounter > 1) && (this.mode == DataBinding.MODE_ONETIME)) {
			return;
		}
		
		var newValue = value;
		if (this._converter != null) {
			newValue = this._converter(value);
		}
		
		if (this._stringFormat != null) {
			newValue = this._stringFormat(newValue);
		}
		watcher[this._boundTo.name] = newValue;
	}

	private function _getActualDataSource():IPropertyChanged {
		if (this.dataSource != null) {
			return this.dataSource;
		}
		
		if (this.uiElementId != null) {
			// TODO Find UIElement
			return null;
		}
		
		return this._owner.dataSource;
	}

	public function _registerDataSource(updateTarget:Bool) {
		var ds = this._getActualDataSource();
		if (ds == this._currentDataSource) {
			return;
		}
		
		if (this._currentDataSource != null) {
			BindingHelper.unregisterDataSource(this._currentDataSource, this, 0);
		}
		
		if (ds != null) {
			BindingHelper.registerDataSource(ds, this);
			if (updateTarget && this.canUpdateTarget(true)) {
				this.updateTarget();
			}
		}
		
		this._currentDataSource = ds;
	}

	public function _unregisterDataSource() {
		var ds = this._getActualDataSource();
		if (ds != null) {
			BindingHelper.unregisterDataSource(ds, this, 0);
		}
	}
	
}
