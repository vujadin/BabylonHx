package com.babylonhx.tools;

/**
 * @author Krtolica Vujadin
 */
interface IPropertyChanged {
	
	var propertyChanged(get, never):Observable<PropertyChangedInfo>;
  
}