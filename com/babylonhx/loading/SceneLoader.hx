package com.babylonhx.loading;

import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.tools.Tools;
import com.babylonhx.loading.plugins.BabylonFileLoader;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.SceneLoader') class SceneLoader {
	
	// Flags
	private static var _ForceFullSceneLoadingForIncremental:Bool = false;
	private static var _ShowLoadingScreen:Bool = true;

	public static var ForceFullSceneLoadingForIncremental(get, set):Bool;
	private static function get_ForceFullSceneLoadingForIncremental():Bool {
		return SceneLoader._ForceFullSceneLoadingForIncremental;
	}
	private static function set_ForceFullSceneLoadingForIncremental(val:Bool):Bool {
		SceneLoader._ForceFullSceneLoadingForIncremental = val;
		return val;
	}

	public static var ShowLoadingScreen(get, set):Bool;
	private static function get_ShowLoadingScreen():Bool {
		return SceneLoader._ShowLoadingScreen;
	}
	private static function set_ShowLoadingScreen(val:Bool):Bool {
		SceneLoader._ShowLoadingScreen = val;
		return val;
	}

	// Members
	private static var _registeredPlugins:Array<ISceneLoaderPlugin> = [];

	private static function _getPluginForFilename(sceneFilename:String):ISceneLoaderPlugin {
		var dotPosition = sceneFilename.lastIndexOf(".");
		
		var queryStringPosition = sceneFilename.indexOf("?");
		
		if (queryStringPosition == -1) {
            queryStringPosition = sceneFilename.length;
        }
		
		var extension = sceneFilename.substring(dotPosition, queryStringPosition).toLowerCase();
		
		for (index in 0...SceneLoader._registeredPlugins.length) {
			var plugin = SceneLoader._registeredPlugins[index];
			
			if (plugin.extensions.indexOf(extension) != -1) {
				return plugin;
			}
		}
		
		return SceneLoader._registeredPlugins[SceneLoader._registeredPlugins.length - 1];
	}

	// Public functions
	public static function RegisterPlugin(plugin:ISceneLoaderPlugin) {
		plugin.extensions = plugin.extensions.toLowerCase();
		SceneLoader._registeredPlugins.push(plugin);
	}

	public static function ImportMesh(meshesNames:String, rootUrl:String, sceneFilename:String, scene:Scene, ?onsuccess:Array<AbstractMesh>->Array<ParticleSystem>->Array<Skeleton>->Void, ?progressCallBack:Void->Void, ?onerror:Scene->Dynamic->Void) {
		var manifestChecked = function() {
			
			var plugin = SceneLoader._getPluginForFilename(sceneFilename);
			
			if (plugin == null) {
				var dotPosition = sceneFilename.lastIndexOf(".");
				var queryStringPosition = sceneFilename.indexOf("?");
				var extension = sceneFilename.substring(dotPosition, queryStringPosition).toLowerCase();
				trace("Error: " + "No plugin loaded for '" + extension + "' file type !");
				throw("No plugin loaded for '" + extension + "' file type !");
			}
			
			var importMeshFromData = function(data:Dynamic) {
				var meshes:Array<AbstractMesh> = [];
				var particleSystems:Array<ParticleSystem> = [];
				var skeletons:Array<Skeleton> = [];
				
				try {
					if (!plugin.importMesh(meshesNames, scene, data, rootUrl, meshes, particleSystems, skeletons)) {
						if (onerror != null) {
							onerror(scene, 'unable to load the scene');
						}
						
						return;
					}
				} catch (e:Dynamic) {
					trace(e);
					if (onerror != null) {
						onerror(scene, e);
					}
					
					return;
				}
				
				if (onsuccess != null) {
					scene.importedMeshesFiles.push(rootUrl + sceneFilename);
					onsuccess(meshes, particleSystems, skeletons);
				}
			};
			
			if (sceneFilename.substr(0, 5) == "data:") {
				// Direct load
				importMeshFromData(sceneFilename.substr(5));
				return;
			}
			
			Tools.LoadFile(rootUrl + sceneFilename, function(data:Dynamic) {
				importMeshFromData(data);
			});
		};
		
		manifestChecked();
	}

	/**
	* Load a scene
	* @param rootUrl a string that defines the root url for scene and resources
	* @param sceneFilename a string that defines the name of the scene file. can start with "data:" following by the stringified version of the scene
	* @param engine is the instance of BABYLON.Engine to use to create the scene
	*/
	public static function Load(rootUrl:String, sceneFilename:Dynamic, engine:Engine, ?onsuccess:Scene-> Void, ?progressCallBack:Dynamic, ?onerror:Scene-> Void) {
		SceneLoader.Append(rootUrl, sceneFilename, new Scene(engine), onsuccess, progressCallBack, onerror);
	}

	/**
	* Append a scene
	* @param rootUrl a string that defines the root url for scene and resources
	* @param sceneFilename a string that defines the name of the scene file. can start with "data:" following by the stringified version of the scene
	* @param scene is the instance of BABYLON.Scene to append to
	*/
	public static function Append(rootUrl:String, sceneFilename:Dynamic, scene:Scene, ?onsuccess:Scene->Void, ?progressCallBack:Dynamic, ?onerror:Scene->Void) {
		var plugin = SceneLoader._getPluginForFilename(sceneFilename.name != null ? sceneFilename.name : sceneFilename);
		
		var loadSceneFromData = function(data:Dynamic) {
			if (!plugin.load(scene, data, rootUrl)) {
				if (onerror != null) {
					onerror(scene);
				}
				
				return;
			}
			
			if (onsuccess != null) {
				onsuccess(scene);
			}              
		};
		
		Tools.LoadFile(rootUrl + sceneFilename, loadSceneFromData);
		
		if (sceneFilename.substr(0, 5) == "data:") {
			// Direct load
			loadSceneFromData(sceneFilename.substr(5));
			return;
		}
	}
	
}
