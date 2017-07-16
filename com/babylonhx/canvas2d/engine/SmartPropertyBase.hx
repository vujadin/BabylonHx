package com.babylonhx.canvas2d.engine;

import com.babylonhx.tools.IPropertyChanged;
import com.babylonhx.tools.Observable;
import com.babylonhx.tools.Observer;
import com.babylonhx.tools.PropertyChangedBase;
import com.babylonhx.tools.PropertyChangedInfo;
import com.babylonhx.tools.StringDictionary;

/**
 * ...
 * @author Krtolica Vujadin
 */
class SmartPropertyBase extends PropertyChangedBase {
    
	private var _dataSource:IPropertyChanged;
	private var _dataSourceObserver:Observer<PropertyChangedInfo>;
	private var _isDisposed:Bool;
	private var _externalData:StringDictionary<Dynamic>;
	public var _instanceDirtyFlags:Int;
	private var _propInfo:StringDictionary<Prim2DPropInfo>;
	public var _bindings:Array<DataBinding>;
	private var _hasBinding:Int;
	private var _bindingSourceChanged:Int;
	private var _disposeObservable:Observable<SmartPropertyBase>;
	
	
	public function new() {
		super();
		this._dataSource = null;
		this._dataSourceObserver = null;
		this._instanceDirtyFlags = 0;
		this._isDisposed = false;
		this._bindings = null;
		this._hasBinding = 0;
		this._bindingSourceChanged = 0;
		this._disposeObservable = null;
	}

	public var disposeObservable(get, never):Observable<SmartPropertyBase>;
	private function get_disposeObservable():Observable<SmartPropertyBase> {
		if (this._disposeObservable == null) {
			this._disposeObservable = new Observable<SmartPropertyBase>();
		}
		
		return this._disposeObservable;
	}

	/**
	 * Check if the object is disposed or not.
	 * @returns true if the object is dispose, false otherwise.
	 */
	public var isDisposed(get, never):Bool;
	private function get_isDisposed():Bool {
		return this._isDisposed;
	}

	/**
	 * Disposable pattern, this method must be overloaded by derived types in order to clean up hardware related resources.
	 * @returns false if the object is already dispose, true otherwise. Your implementation must call super.dispose() and check for a false return and return immediately if it's the case.
	 */
	public function dispose():Bool {
		if (this.isDisposed) {
			return false;
		}
		if (this._disposeObservable != null && this._disposeObservable.hasObservers()) {
			this._disposeObservable.notifyObservers(this);
		}
		this._isDisposed = true;
		
		return true;
	}

	/**
	 * Check if a given set of properties are dirty or not.
	 * @param flags a ORed combination of Prim2DPropInfo.flagId values
	 * @return true if at least one property is dirty, false if none of them are.
	 */
	public function checkPropertiesDirty(flags:Int):Bool {
		return (this._instanceDirtyFlags & flags) != 0;
	}

	/**
	 * Clear a given set of properties.
	 * @param flags a ORed combination of Prim2DPropInfo.flagId values
	 * @return the new set of property still marked as dirty
	 */
	public function clearPropertiesDirty(flags:Int):Int {
		this._instanceDirtyFlags &= ~flags;
		
		return this._instanceDirtyFlags;
	}

	public function _resetPropertiesDirty() {
		this._instanceDirtyFlags = 0;
	}

	/**
	 * Add an externally attached data from its key.
	 * This method call will fail and return false, if such key already exists.
	 * If you don't care and just want to get the data no matter what, use the more convenient getOrAddExternalDataWithFactory() method.
	 * @param key the unique key that identifies the data
	 * @param data the data object to associate to the key for this Engine instance
	 * @return true if no such key were already present and the data was added successfully, false otherwise
	 */
	public function addExternalData<T>(key:String, data:T):Bool {
		if (this._externalData == null) {
			this._externalData = new Map<String, Object>();
		}
		
		return this._externalData.add(key, data);
	}

	/**
	 * Get an externally attached data from its key
	 * @param key the unique key that identifies the data
	 * @return the associated data, if present (can be null), or undefined if not present
	 */
	public function getExternalData<T>(key:String):T {
		if (this._externalData == null) {
			return null;
		}
		
		return this._externalData.get(key);
	}

	/**
	 * Get an externally attached data from its key, create it using a factory if it's not already present
	 * @param key the unique key that identifies the data
	 * @param factory the factory that will be called to create the instance if and only if it doesn't exists
	 * @return the associated data, can be null if the factory returned null.
	 */
	public function getOrAddExternalDataWithFactory<T>(key:String, factory:String->T):T {
		if (this._externalData == null) {
			this._externalData = new Map<String, Object>();
		}
		
		return this._externalData.getOrAddWithFactory(key, factory);
	}

	/**
	 * Remove an externally attached data from the Engine instance
	 * @param key the unique key that identifies the data
	 * @return true if the data was successfully removed, false if it doesn't exist
	 */
	public function removeExternalData(key:String):Bool {
		if (this._externalData == null) {
			return false;
		}
		
		return this._externalData.remove(key);
	}

	static public function _hookProperty<T>(propId:Int, piStore:Prim2DPropInfo->Void, kind:Int, ?settings:Dynamic):Dynamic->Dynamic->Dynamic {
		return function(target:Dynamic, propName:Dynamic, descriptor:Dynamic) {
			if (settings == null) {
				settings = { };
			}
			
			var propInfo = SmartPropertyBase._createPropInfo(target, Std.string(propName), propId, kind, settings);
			if (piStore != null) {
				piStore(propInfo);
			}
			var getter = descriptor.get;
			var setter = descriptor.set;
			
			var typeLevelCompare = (settings.typeLevelCompare != null) ? settings.typeLevelCompare : false;
			
			// Overload the property setter implementation to add our own logic
			descriptor.set = function (val) {
				if (setter == null) {
					throw ("Property ${propInfo.name} of type ${Tools.getFullClassName(this)} has no setter defined but was invoked as if it had one.");
				}
				
				// check for disposed first, do nothing
				if (this.isDisposed) {
					return;
				}
				
				var curVal = getter.call(this);
				
				if (SmartPropertyBase._checkUnchanged(curVal, val)) {
					return;
				}
				
				// Change the value
				setter.call(this, val);
				
				// Notify change, dirty flags update
				prim._handlePropChanged(curVal, val, Std.string(propName), propInfo, typeLevelCompare);
			}
		}
	}

	private static function _createPropInfo(target:Dynamic, propName:String, propId:Int, kind:Int, ?settings:Dynamic):Prim2DPropInfo {
		var dic = ClassTreeInfo.getOrRegister<Prim2DClassInfo, Prim2DPropInfo>(target, function() { return new Prim2DClassInfo(); } );
		var node = dic.getLevelOf(target);
		
		var propInfo = node.levelContent.get(propId.toString());
		if (propInfo != null) {
			throw ("The ID ${propId} is already taken by another property declaration named: ${propInfo.name}");
		}
		
		// Create, setup and add the PropInfo object to our prop dictionary
		propInfo = new Prim2DPropInfo();
		propInfo.id = propId;
		propInfo.flagId = Std.int(Math.pow(2, propId));
		propInfo.kind = kind;
		propInfo.name = propName;
		propInfo.bindingMode = (settings.bindingMode != null) ? settings.bindingMode : DataBinding.MODE_TWOWAY;
		propInfo.bindingUpdateSourceTrigger = (settings.bindingUpdateSourceTrigger != null) ? settings.bindingUpdateSourceTrigger : DataBinding.UPDATESOURCETRIGGER_PROPERTYCHANGED;
		propInfo.dirtyBoundingInfo = (settings.dirtyBoundingInfo != null) ? settings.dirtyBoundingInfo : false;
		propInfo.dirtyParentBoundingInfo = (settings.dirtyParentBoundingBox != null) ? settings.dirtyParentBoundingBox : false;
		propInfo.typeLevelCompare = (settings.typeLevelCompare != null) ? settings.typeLevelCompare : false;
		node.levelContent.add(propName, propInfo);
		
		return propInfo;
	}

	/**
	 * Access the dictionary of properties metadata. Only properties decorated with XXXXLevelProperty are concerned
	 * @returns the dictionary, the key is the property name as declared in Javascript, the value is the metadata object
	 */
	public var propDic(get, never):StringDictionary<Prim2DPropInfo>;
	private function get_propDic():StringDictionary<Prim2DPropInfo> {
		if (this._propInfo == null) {
			var cti = ClassTreeInfo.get<Prim2DClassInfo, Prim2DPropInfo>(Object.getPrototypeOf(this));
			if (!cti) {
				throw ("Can't access the propDic member in class definition, is this class SmartPropertyPrim based?");
			}
			this._propInfo = cti.fullContent;
		}
		
		return this._propInfo;
	}

	private static function _checkUnchanged(curValue, newValue):Bool {
		// Nothing to nothing: nothing to do!
		if (curValue == null && newValue == null) {
			return true;
		}
		
		// Check value unchanged
		if ((curValue != null) && (newValue != null)) {
			if (typeof (curValue.equals) == "function") {
				if (curValue.equals(newValue)) {
					return true;
				}
			} 
			else {
				if (curValue == newValue) {
					return true;
				}
			}
		}
		
		return false;
	}

	private static var propChangedInfo:PropertyChangedInfo = new PropertyChangedInfo();
	private static var propChangeGuarding:Bool = false;

	public function _handlePropChanged<T>(curValue:T, newValue:T, propName:String, propInfo:Prim2DPropInfo, typeLevelCompare:Bool) {
		// Trigger property changed
		var info = SmartPropertyBase.propChangeGuarding ? new PropertyChangedInfo() : SmartPropertyBase.propChangedInfo;
		info.oldValue = curValue;
		info.newValue = newValue;
		info.propertyName = propName;
		var propMask = propInfo != null ? propInfo.flagId : -1;
		try {
			SmartPropertyBase.propChangeGuarding = true;
			this.propertyChanged.notifyObservers(info, propMask);		 
			SmartPropertyBase.propChangeGuarding = false;
		} 
		catch (err:Dynamic) {
			trace(err);
		}
	}

	public function _triggerPropertyChanged(propInfo:Prim2DPropInfo, newValue:Dynamic) {
		if (this.isDisposed) {
			return;
		}
		
		if (propInfo == null) {
			return;
		}
		
		this._handlePropChanged(null, newValue, propInfo.name, propInfo, propInfo.typeLevelCompare);
	}

	/**
	 * Set the object from which Smart Properties using Binding will take/update their data from/to.
	 * When the object is part of a graph (with parent/children relationship) if the dataSource of a given instance is not specified, then the parent's one is used.
	 */
	public var dataSource(get, set):IPropertyChanged;
	private function get_dataSource():IPropertyChanged {
		// Don't access to _dataSource directly but via a call to the _getDataSource method which can be overloaded in inherited classes
		return this._getDataSource();
	}
	private function set_dataSource(value:IPropertyChanged):IPropertyChanged {
		if (this._dataSource == value) {
			return;
		}
		
		var oldValue = this._dataSource;
		this._dataSource = value;
		
		if (this._bindings != null && value != null) {
			// Register the bindings
			for (binding in this._bindings) {
				if (binding != null) {
					binding._registerDataSource(true);
				}
			}
		}
		
		this.onPropertyChanged("dataSource", oldValue, value);
	}

	// Inheriting classes can overload this method to provides additional logic for dataSource access
	public function _getDataSource():IPropertyChanged {
		return this._dataSource;
	}

	public function createSimpleDataBinding(propInfo:Prim2DPropInfo, propertyPathName:String, mode:Int = DataBinding.MODE_DEFAULT):DataBinding {
		var binding = new DataBinding();
		binding.propertyPathName = propertyPathName;
		binding.mode = mode;
		
		return this.createDataBinding(propInfo, binding);
	}

	public function createDataBinding(propInfo:Prim2DPropInfo, binding:DataBinding):DataBinding {
		if (this._bindings == null) {
			this._bindings = new Array<DataBinding>();
		}
		
		if (binding == null || binding._owner != null) {
			throw ("A valid/unused Binding must be passed.");
		}
		
		// Unregister a potentially existing binding for this property
		this.removeDataBinding(propInfo);
		
		// register the binding
		binding._owner = this;
		binding._boundTo = propInfo;
		this._bindings[propInfo.id] = binding;
		this._hasBinding |= propInfo.flagId;
		
		binding._registerDataSource(true);
		
		return binding;
	}

	public function removeDataBinding(propInfo:Prim2DPropInfo):Bool {
		if ((this._hasBinding & propInfo.flagId) == 0) {
			return false;
		}
		
		var curBinding = this._bindings[propInfo.id];
		curBinding._unregisterDataSource();
		
		this._bindings[propInfo.id] = null;
		this._hasBinding &= ~propInfo.flagId;
		
		return true;
	}

	public function updateFromDataSource() {
		for (binding in this._bindings) {
			if (binding != null) {
				//BindingWatcher.updateFromDataSource(this, binding, false);
			}
		}
	}	
	
}
