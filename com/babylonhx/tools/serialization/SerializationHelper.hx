package com.babylonhx.tools.serialization;

import haxe.rtti.Meta;

/**
 * ...
 * @author Krtolica Vujadin
 */
class SerializationHelper {
	
	static public function Serialize(className:Dynamic, obj:Dynamic, serializedObject:Dynamic = null):Dynamic {
		if (serializedObject == null) {
			serializedObject = { };
		}
		
		var fs:Dynamic<Dynamic<Array<Dynamic>>> = Meta.getFields(className);
      
		for (f in Reflect.fields(fs)) {
            var metaTags = Reflect.fields(Reflect.getProperty(fs, f));
            if (metaTags != null && metaTags.length > 0) {
                switch(metaTags[0]) {
                    case "serialize":
						var pName:String = Reflect.getProperty(fs, f).serialize;
						if (pName == null) {
							pName = f;
						}
						else {
							pName = stripBrackets(pName);
						}
						
						var prop = Reflect.getProperty(obj, f);
						if (prop != null) {
							Reflect.setField(serializedObject, pName, Reflect.getProperty(obj, f));
						}
						
                    case "serializeAsTexture":
						var pName:String = Reflect.getProperty(fs, f).serializeAsTexture;
						if (pName == null) {
							pName = f;
						}
						else {
							pName = stripBrackets(pName);
						}
						
						var prop = Reflect.getProperty(obj, f);
						if (prop != null) {
							Reflect.setField(serializedObject, pName, prop.serialize());
						}
						
					case "serializeAsColor3":
						var pName:String = Reflect.getProperty(fs, f).serializeAsColor3;
						if (pName == null) {
							pName = f;
						}
						else {
							pName = stripBrackets(pName);
						}
						
						var prop = Reflect.getProperty(obj, f);
						if (prop != null) {
							Reflect.setField(serializedObject, pName, prop.asArray());
						}
						
					case "serializeAsVector3":
						var pName:String = Reflect.getProperty(fs, f).serializeAsVector3;
						if (pName == null) {
							pName = f;
						}
						else {
							pName = stripBrackets(pName);
						}
						
						var prop = Reflect.getProperty(obj, f);
						if (prop != null) {
							Reflect.setField(serializedObject, pName, prop.asArray());
						}
						
					case "serializeAsVector2":
						var pName:String = Reflect.getProperty(fs, f).serializeAsVector2;
						if (pName == null) {
							pName = f;
						}
						else {
							pName = stripBrackets(pName);
						}
						
						var prop = Reflect.getProperty(obj, f);
						if (prop != null) {
							Reflect.setField(serializedObject, pName, prop.asArray());
						}
						
					case "serializeAsFresnelParameters":
						var pName:String = Reflect.getProperty(fs, f).serializeAsFresnelParameters;
						if (pName == null) {
							pName = f;
						}
						else {
							pName = stripBrackets(pName);
						}
						
						var prop = Reflect.getProperty(obj, f);
						if (prop != null) {
							Reflect.setField(serializedObject, pName, prop.serialize());
						}
						
					case "serializeAsMeshReference":
						var pName:String = Reflect.getProperty(fs, f).serializeAsMeshReference;
						if (pName == null) {
							pName = f;
						}
						else {
							pName = stripBrackets(pName);
						}
						
						var prop = Reflect.getProperty(obj, f);
						if (prop != null) {
							Reflect.setField(serializedObject, pName, prop.serialize());
						}
                }
            }
        }
		
		return serializedObject;
	}
	
	// cpp build adds brackets to property name (when defined in metadata...)
	static function stripBrackets(str:String):String {
		str = StringTools.replace(str, "[", "");
		str = StringTools.replace(str, "]", "");
		
		return str;
	}
	
}
