package com.babylonhx.tools.serialization;

import com.babylonhx.materials.FresnelParameters;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.ColorCurves;
import com.babylonhx.materials.ImageProcessingConfiguration;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import haxe.macro.Type;

import haxe.rtti.Meta;

/**
 * ...
 * @author Krtolica Vujadin
 */
class SerializationHelper {
	
	static var __decoratorInitialStore:Map<String, Map<String, Dynamic>> = new Map();
    static var __mergedStore:Map<String, Dynamic> = new Map();
	
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
						// TODO: 
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
	static inline function stripBrackets(str:String):String {
		if (str.indexOf("[") != -1) {
			str = StringTools.replace(str, "[", "");
			str = StringTools.replace(str, "]", "");
		}
		
		return str;
	}
	
	public static function Parse<T>(creationFunction:Void->T, source:Dynamic, scene:Scene, ?rootUrl:String):T {
		var destination:T = creationFunction();
		
		// Tags
		Tags.AddTagsTo(destination, untyped source.tags);
		
		var classStore = getMergedStore(destination);
		
		// Properties
		for (property in Reflect.fields(classStore)) {
			var propertyDescriptor = Reflect.getProperty(/*classStore*/destination, property);
			var sourceProperty = Reflect.getProperty(source, propertyDescriptor.sourceName != null ? propertyDescriptor.sourceName : property);
			var propertyType = propertyDescriptor.type;

			if (sourceProperty != null) {
				switch (propertyType) {
					case 0:     // Value
						Reflect.setProperty(destination, property, sourceProperty);
						
					case 1:     // Texture
						Reflect.setProperty(destination, property, Texture.Parse(sourceProperty, scene, rootUrl));
						
					case 2:     // Color3
						Reflect.setProperty(destination, property, Color3.FromArray(sourceProperty));
						
					case 3:     // FresnelParameters
						Reflect.setProperty(destination, property, FresnelParameters.Parse(sourceProperty));
						
					case 4:     // Vector2
						Reflect.setProperty(destination, property, Vector2.FromArray(sourceProperty));
						
					case 5:     // Vector3
						Reflect.setProperty(destination, property, Vector3.FromArray(sourceProperty));
						
					case 6:     // Mesh reference
						Reflect.setProperty(destination, property, scene.getLastMeshByID(cast sourceProperty));
						
					case 7:     // Color Curves
						Reflect.setProperty(destination, property, ColorCurves.Parse(sourceProperty));
						
					case 8:     // Color 4
						Reflect.setProperty(destination, property, Color4.FromArray(sourceProperty));
						
					case 9:     // Image Processing
						Reflect.setProperty(destination, property, ImageProcessingConfiguration.Parse(sourceProperty));						
				}
			}
		}
		
		return destination;
	}

	static public function Clone<T>(creationFunction:Void->T, source:T):T {
		var destination = creationFunction();
		
		// Tags
		Tags.AddTagsTo(destination, untyped source.tags);
		
		// Properties
		for (property in Reflect.fields(untyped destination.__serializableMembers)) {
			var propertyDescriptor = Reflect.getProperty(untyped destination.__serializableMembers, property);
			var sourceProperty = Reflect.getProperty(source, property);
			var propertyType = propertyDescriptor.type;
			
			if (sourceProperty != null && sourceProperty != null) {
				switch (propertyType) {
					case 0, 6:     // Value, Mesh reference
						Reflect.setProperty(destination, property, sourceProperty);
						
					case 1, 2, 3, 4, 5, 7:     // Texture, Color3, FresnelParameters, Vector2, Vector3, Color Curves
						Reflect.setProperty(destination, property, sourceProperty.clone());
						
				}
			}
		}
		
		return destination;
	}
	
	static function getDirectStore(target:Dynamic):Dynamic {
        var classKey = target.getClassName();
		
        if (__decoratorInitialStore[classKey] == null) {
            __decoratorInitialStore[classKey] = new Map();
        }
		
        return __decoratorInitialStore[classKey];
    }
	
	/**
     * Return the list of properties flagged as serializable
     * @param target: host object
     */
    static function getMergedStore(target:Dynamic):Dynamic {
        var classKey:String = target.getClassName();
		
        if (__mergedStore[classKey] != null) {
            return __mergedStore[classKey];
        }
		
        __mergedStore[classKey] = {};
		
        var store = __mergedStore[classKey];
        var currentTarget = target;
        var currentKey = classKey;
        while (currentKey != null) {
            var initialStore = __decoratorInitialStore[currentKey];
			
			if (initialStore != null) {
				for (property in initialStore.keys()) {
					Reflect.setProperty(store, property, initialStore[property]);                
				}
			}
			
            var parent:Dynamic = null;
            var done:Bool = true;
			
            do {
				#if js
                parent = untyped __js__('Object.getPrototypeOf(currentTarget)');
				#end
                if (parent.getClassName == null) {
                    done = true;
                    break;
                }
				
                if (parent.getClassName() != currentKey) {
                    break;
                }
				
                currentTarget = parent;
            }
            while (parent != null);
			
            if (done) {
                break;
            }
            
            currentKey = parent.getClassName();
            currentTarget = parent;
        }
		
        return store;
		//return null;
    }
	
	static public function generateSerializableMember(type:Int, ?sourceName:String) {
        return function(target:Dynamic, propertyKey:String) {
            if (target.__serializableMembers == null) {
                target.__serializableMembers = {};
            }
			
			if (Reflect.getProperty(target.__serializableMembers, propertyKey) == null) {
				Reflect.setProperty(target.__serializableMembers, propertyKey, { type: type, sourceName: sourceName });
			}
        };
    }

    static public function serialize(?sourceName:String) {
        return generateSerializableMember(0, sourceName); // value member
    }

    static public function serializeAsTexture(?sourceName:String) {
        return generateSerializableMember(1, sourceName);// texture member
    }

    static public function serializeAsColor3(?sourceName:String) {
        return generateSerializableMember(2, sourceName); // color3 member
    }

    static public function serializeAsFresnelParameters(?sourceName:String) {
        return generateSerializableMember(3, sourceName); // fresnel parameters member
    }

    static public function serializeAsVector2(?sourceName:String) {
        return generateSerializableMember(4, sourceName); // vector2 member
    }

    static public function serializeAsVector3(?sourceName:String) {
        return generateSerializableMember(5, sourceName); // vector3 member
    }

    static public function serializeAsMeshReference(?sourceName:String) {
        return generateSerializableMember(6, sourceName); // mesh reference member
    }
	
	static public function serializeAsColorCurves(?sourceName:String) {
        return generateSerializableMember(7, sourceName); // color curves
    }
	
}
