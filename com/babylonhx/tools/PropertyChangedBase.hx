package com.babylonhx.tools;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * The purpose of this class is to provide a base implementation of the IPropertyChanged interface for the user to avoid rewriting a code needlessly.
 * Typical use of this class is to check for equality in a property set(), then call the onPropertyChanged method if values are different after the new value is set. The protected method will notify observers of the change.
 * Remark: onPropertyChanged detects reentrant code and acts in a way to make sure everything is fine, fast and allocation friendly (when there no reentrant code which should be 99% of the time)
 */
class PropertyChangedBase implements IPropertyChanged {
	
	private static var pci:PropertyChangedInfo = new PropertyChangedInfo();
	private static var calling:Bool = false;
	
	public var _propertyChanged:Observable<PropertyChangedInfo> = null;
	
	
	public function new() {
		// ...
	}

	/**
	 * Protected method to call when there's a change of value in a property set
	 * @param propName the name of the concerned property
	 * @param oldValue its old value
	 * @param newValue its new value
	 * @param mask an optional observable mask
	 */
	public function onPropertyChanged<T>(propName:String, oldValue:T, newValue:T, ?mask:Int) {
		if (this.propertyChanged.hasObservers()) {
			var pci = PropertyChangedBase.calling ? new PropertyChangedInfo() : PropertyChangedBase.pci;
			
			pci.oldValue = oldValue;
			pci.newValue = newValue;
			pci.propertyName = propName;
			
			try {
				PropertyChangedBase.calling = true;
				this.propertyChanged.notifyObservers(pci, mask);
			 
				PropertyChangedBase.calling = false;
			} 
			catch (err:Dynamic) {
				trace(err);
			}
		}
	}

	/**
	 * An observable that is triggered when a property (using of the XXXXLevelProperty decorator) has its value changing.
	 * You can add an observer that will be triggered only for a given set of Properties using the Mask feature of the Observable and the corresponding Prim2DPropInfo.flagid value (e.g. Prim2DBase.positionProperty.flagid|Prim2DBase.rotationProperty.flagid to be notified only about position or rotation change)
	 */
	public var propertyChanged(get, never):Observable<PropertyChangedInfo>;
	private function get_propertyChanged():Observable<PropertyChangedInfo> {
		if (this._propertyChanged == null) {
			this._propertyChanged = new Observable<PropertyChangedInfo>();
		}
		
		return this._propertyChanged;
	}
	
}
