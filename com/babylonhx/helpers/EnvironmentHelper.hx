package com.babylonhx.helpers;

import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Plane;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.engine.Engine;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.materials.BackgroundMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.materials.textures.MirrorTexture;
import com.babylonhx.materials.textures.CubeTexture;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * The Environment helper class can be used to add a fully featuread none expensive background to your scene.
 * It includes by default a skybox and a ground relying on the BackgroundMaterial.
 * It also helps with the default setup of your imageProcessing configuration.
 */
class EnvironmentHelper {

	/**
	 * Default ground texture URL.
	 */
	private static var _groundTextureUrl:String = "assets/environments/backgroundGround.png";

	/**
	 * Default skybox texture URL.
	 */
	private static var _skyboxTextureUrl:String = "assets/environments/backgroundSkybox.dds";

	/**
	 * Default environment texture URL.
	 */
	private static var _environmentTextureUrl:String = "assets/environments/environmentSpecular.dds";

	/**
	 * Creates the default options for the helper.
	 */
	private static function _getDefaultOptions():IEnvironmentHelperOptions {
		return {
			createGround: true,
			groundSize: 15,
			groundTexture: _groundTextureUrl,
			groundColor: new Color3(0.2, 0.2, 0.3).toLinearSpace().scale(3),
			groundOpacity: 0.9,
			enableGroundShadow: true,
			groundShadowLevel: 0.5,
			
			enableGroundMirror: false,
			groundMirrorSizeRatio: 0.3,
			groundMirrorBlurKernel: 64,
			groundMirrorAmount: 1,
			groundMirrorFresnelWeight: 1,
			groundMirrorFallOffDistance: 0,
			groundMirrorTextureType: Engine.TEXTURETYPE_UNSIGNED_INT,
			
			groundYBias: 0.0001,
			
			createSkybox: true,
			skyboxSize: 20,
			skyboxTexture: _skyboxTextureUrl,
			skyboxColor: new Color3(0.2, 0.2, 0.3).toLinearSpace().scale(3),
			
			backgroundYRotation: 0,
			sizeAuto: true,
			rootPosition: Vector3.Zero(),
			
			setupImageProcessing: true,
			environmentTexture: _environmentTextureUrl,
			cameraExposure: 0.8,
			cameraContrast: 1.2,
			toneMappingEnabled: true
		};
	}

	private var _rootMesh:Mesh;
	/**
	 * Gets the root mesh created by the helper.
	 */
	public var rootMesh(get, never):Mesh;
	private inline function get_rootMesh():Mesh {
		return this._rootMesh;
	}

	private var _skybox:Mesh;
	/**
	 * Gets the skybox created by the helper.
	 */
	public var skybox(get, never):Mesh;
	private inline function get_skybox():Mesh {
		return this._skybox;
	}

	private var _skyboxTexture:BaseTexture;
	/**
	 * Gets the skybox texture created by the helper.
	 */
	public var skyboxTexture(get, never):BaseTexture;
	inline private function get_skyboxTexture():BaseTexture {
		return this._skyboxTexture;
	}

	private var _skyboxMaterial:BackgroundMaterial;
	/**
	 * Gets the skybox material created by the helper.
	 */
	public var skyboxMaterial(get, never):BackgroundMaterial;
	inline private function get_skyboxMaterial():BackgroundMaterial {
		return this._skyboxMaterial;
	}

	private var _ground:Mesh;
	/**
	 * Gets the ground mesh created by the helper.
	 */
	public var ground(get, never):Mesh;
	inline private function get_ground():Mesh {
		return this._ground;
	}
	
	private var _groundTexture:BaseTexture;
	/**
	 * Gets the ground texture created by the helper.
	 */
	public var groundTexture(get, never):BaseTexture;
	private inline function get_groundTexture():BaseTexture {
		return this._groundTexture;
	}
	
	private var _groundMirror:MirrorTexture;
	/**
	 * Gets the ground mirror created by the helper.
	 */
	public var groundMirror(get, never):MirrorTexture;
	private inline function get_groundMirror():MirrorTexture {
		return this._groundMirror;
	}

	/**
	 * Gets the ground mirror render list to helps pushing the meshes 
	 * you wish in the ground reflection.
	 */
	public var groundMirrorRenderList(get, never):Array<AbstractMesh>;
	private function get_groundMirrorRenderList():Array<AbstractMesh> {
		if (this._groundMirror != null) {
			return this._groundMirror.renderList;
		}
		return null;
	}

	private var _groundMaterial:BackgroundMaterial;
	/**
	 * Gets the ground material created by the helper.
	 */
	public var groundMaterial(get, never):BackgroundMaterial;
	inline private function get_groundMaterial():BackgroundMaterial {
		return this._groundMaterial;
	}

	/**
	 * Stores the creation options.
	 */
	private var _scene:Scene;
	private var _options:IEnvironmentHelperOptions;
	

	/**
	 * constructor
	 * @param options 
	 * @param scene The scene to add the material to
	 */
	public function new(options:IEnvironmentHelperOptions, scene:Scene) {
		this._options = EnvironmentHelper._getDefaultOptions();
		if (options != null) {
			this._options = mergeOptions(options, this._options);
		}
		this._scene = scene;
		
		this._setupBackground();
		this._setupImageProcessing();
	}
	
	private function mergeOptions(source:IEnvironmentHelperOptions, target:IEnvironmentHelperOptions):IEnvironmentHelperOptions {
		var newOptions:IEnvironmentHelperOptions = {
			createGround: target.createGround,
			groundSize: target.groundSize,
			groundTexture: target.groundTexture,
			groundColor: target.groundColor,
			groundOpacity: target.groundOpacity,
			enableGroundShadow: target.enableGroundShadow,
			groundShadowLevel: target.groundShadowLevel,
			
			enableGroundMirror: target.enableGroundMirror,
			groundMirrorSizeRatio: target.groundMirrorSizeRatio,
			groundMirrorBlurKernel: target.groundMirrorBlurKernel,
			groundMirrorAmount: target.groundMirrorAmount,
			groundMirrorFresnelWeight: target.groundMirrorFresnelWeight,
			groundMirrorFallOffDistance: target.groundMirrorFallOffDistance,
			groundMirrorTextureType: target.groundMirrorTextureType,
			
			createSkybox: target.createSkybox,
			skyboxSize: target.skyboxSize,
			skyboxTexture: target.skyboxTexture,
			skyboxColor: target.skyboxColor,
			
			backgroundYRotation: target.backgroundYRotation,
			sizeAuto: target.sizeAuto,
			rootPosition: target.rootPosition,
			
			setupImageProcessing: target.setupImageProcessing,
			environmentTexture: target.environmentTexture,
			cameraExposure: target.cameraExposure,
			cameraContrast: target.cameraContrast,
			toneMappingEnabled: target.toneMappingEnabled
		};
		
		if (source.createGround != null) {
			newOptions.createGround = source.createGround;
		}
		if (source.groundSize != null) {
			newOptions.groundSize = source.groundSize;
		}
		if (source.groundTexture != null) {
			newOptions.groundTexture = source.groundTexture;
		}
		if (source.groundColor != null) {
			newOptions.groundColor = source.groundColor;
		}
		if (source.groundOpacity != null) {
			newOptions.groundOpacity = source.groundOpacity;
		}
		if (source.enableGroundShadow != null) {
			newOptions.enableGroundShadow = source.enableGroundShadow;
		}
		if (source.groundShadowLevel != null) {
			newOptions.groundShadowLevel = source.groundShadowLevel;
		}
		
		if (source.enableGroundMirror != null) {
			newOptions.enableGroundMirror = source.enableGroundMirror;
		}
		if (source.groundMirrorSizeRatio != null) {
			newOptions.groundMirrorSizeRatio = source.groundMirrorSizeRatio;
		}
		if (source.groundMirrorBlurKernel != null) {
			newOptions.groundMirrorBlurKernel = source.groundMirrorBlurKernel;
		}
		if (source.groundMirrorAmount != null) {
			newOptions.groundMirrorAmount = source.groundMirrorAmount;
		}
		if (source.groundMirrorFresnelWeight != null) {
			newOptions.groundMirrorFresnelWeight = source.groundMirrorFresnelWeight;
		}
		if (source.groundMirrorFallOffDistance != null) {
			newOptions.groundMirrorFallOffDistance = source.groundMirrorFallOffDistance;
		}
		if (source.groundMirrorTextureType != null) {
			newOptions.groundMirrorTextureType = source.groundMirrorTextureType;
		}
		
		if (source.createSkybox != null) {
			newOptions.createSkybox = source.createSkybox;
		}
		if (source.skyboxSize != null) {
			newOptions.skyboxSize = source.skyboxSize;
		}
		if (source.skyboxTexture != null) {
			newOptions.skyboxTexture = source.skyboxTexture;
		}
		if (source.skyboxColor != null) {
			newOptions.skyboxColor = source.skyboxColor;
		}
		
		if (source.backgroundYRotation != null) {
			newOptions.backgroundYRotation = source.backgroundYRotation;
		}
		if (source.sizeAuto != null) {
			newOptions.sizeAuto = source.sizeAuto;
		}
		if (source.rootPosition != null) {
			newOptions.rootPosition = source.rootPosition;
		}
		
		if (source.setupImageProcessing != null) {
			newOptions.setupImageProcessing = source.setupImageProcessing;
		}
		if (source.environmentTexture != null) {
			newOptions.environmentTexture = source.environmentTexture;
		}
		if (source.cameraExposure != null) {
			newOptions.cameraExposure = source.cameraExposure;
		}
		if (source.cameraContrast != null) {
			newOptions.cameraContrast = source.cameraContrast;
		}
		if (source.toneMappingEnabled != null) {
			newOptions.toneMappingEnabled = source.toneMappingEnabled;
		}
		
		return newOptions;
	}

	/**
	 * Updates the background according to the new options
	 * @param options 
	 */
	public function updateOptions(options:IEnvironmentHelperOptions) {
		var newOptions = mergeOptions(options, this._options);
		
		if (this._ground != null && !newOptions.createGround) {
			this._ground.dispose();
			this._ground = null;
		}
		
		if (this._groundMaterial != null && !newOptions.createGround) {
			this._groundMaterial.dispose();
			this._groundMaterial = null;
		}
		
		if (this._groundTexture != null) {
			if (this._options.groundTexture != null && newOptions.groundTexture == null) {
				this._groundTexture.dispose();
				this._groundTexture = null;
			}
		}
		
		if (this._skybox != null && !newOptions.createSkybox) {
			this._skybox.dispose();
			this._skybox = null;
		}
		
		if (this._skyboxMaterial != null && !newOptions.createSkybox) {
			this._skyboxMaterial.dispose();
			this._skyboxMaterial = null;
		}
		
		if (this._skyboxTexture != null) {
			if (this._options.skyboxTexture != null && newOptions.skyboxTexture == null) {
				this._skyboxTexture.dispose();
				this._skyboxTexture = null;
			}
		}
		
		if (this._groundMirror != null && !newOptions.enableGroundMirror) {
			this._groundMirror.dispose();
			this._groundMirror = null;
		}
		
		if (this._scene.environmentTexture != null) {
			if (this._options.environmentTexture != null && newOptions.environmentTexture == null) {
				this._scene.environmentTexture.dispose();
			}
		}
		
		this._options = newOptions;
		
		this._setupBackground();
		this._setupImageProcessing();
	}

	/**
	 * Sets the primary color of all the available elements.
	 * @param color 
	 */
	public function setMainColor(color:Color3) {
		if (this.groundMaterial != null) {
			this.groundMaterial.primaryColor = color;
		}
		
		if (this.skyboxMaterial != null) {
			this.skyboxMaterial.primaryColor = color;
		}
		
		if (this.groundMirror != null) {
			this.groundMirror.clearColor = new Color4(color.r, color.g, color.b, 1.0);
		}
	}

	/**
	 * Setup the image processing according to the specified options.
	 */
	private function _setupImageProcessing() {
		if (this._options.setupImageProcessing) {
			this._scene.imageProcessingConfiguration.contrast = this._options.cameraContrast;
			this._scene.imageProcessingConfiguration.exposure = this._options.cameraExposure;
			this._scene.imageProcessingConfiguration.toneMappingEnabled = this._options.toneMappingEnabled;                
			this._setupEnvironmentTexture();
		}
	}

	/**
	 * Setup the environment texture according to the specified options.
	 */
	private function _setupEnvironmentTexture() {
		if (this._scene.environmentTexture != null) {
			return;
		}
		
		if (Std.is(this._options.environmentTexture, BaseTexture)) {
			this._scene.environmentTexture = this._options.environmentTexture;
			return;
		}
		
		var environmentTexture = CubeTexture.CreateFromPrefilteredData(this._options.environmentTexture, this._scene);
		this._scene.environmentTexture = environmentTexture;
	}

	/**
	 * Setup the background according to the specified options.
	 */
	private function _setupBackground() {
		if (this._rootMesh == null) {
			this._rootMesh = new Mesh("BackgroundHelper", this._scene);
		}
		this._rootMesh.rotation.y = this._options.backgroundYRotation;
		
		var sceneSize = this._getSceneSize();
		if (this._options.createGround) {
			this._setupGround(sceneSize);
			this._setupGroundMaterial();
			this._setupGroundDiffuseTexture();
			
			if (this._options.enableGroundMirror) {
				this._setupGroundMirrorTexture(sceneSize);
			}
			this._setupMirrorInGroundMaterial();
		}
		
		if (this._options.createSkybox) {
			this._setupSkybox(sceneSize);
			this._setupSkyboxMaterial();
			this._setupSkyboxReflectionTexture();
		}
		
		this._rootMesh.position.x = sceneSize.rootPosition.x;
		this._rootMesh.position.z = sceneSize.rootPosition.z;
		this._rootMesh.position.y = sceneSize.rootPosition.y;
	}

	/**
	 * Get the scene sizes according to the setup.
	 */
	private function _getSceneSize():ISceneSize {
		var groundSize:Float = this._options.groundSize;
		var skyboxSize:Float = this._options.skyboxSize;
		var rootPosition = this._options.rootPosition;
		if (this._scene.meshes == null || this._scene.meshes.length == 1) { // 1 only means the root of the helper.
            return { groundSize: groundSize, skyboxSize: skyboxSize, rootPosition: rootPosition };
        }
		
		var sceneExtends = this._scene.getWorldExtends();
		var sceneDiagonal = sceneExtends.max.subtract(sceneExtends.min);
		
		if (this._options.sizeAuto) {
			if (Std.is(this._scene.activeCamera, ArcRotateCamera) && untyped this._scene.activeCamera.upperRadiusLimit != 0) {
				groundSize = untyped this._scene.activeCamera.upperRadiusLimit * 2;
				skyboxSize = groundSize;
			}
			
			var sceneDiagonalLenght = sceneDiagonal.length();
			if (sceneDiagonalLenght > groundSize) {
				groundSize = sceneDiagonalLenght * 2;
				skyboxSize = groundSize;
			}
			
			// 10 % bigger.
			groundSize *= 1.1;
			skyboxSize *= 1.5;
			rootPosition = sceneExtends.min.add(sceneDiagonal.scale(0.5));
			rootPosition.y = sceneExtends.min.y - this._options.groundYBias;
		}
		
		return { groundSize: groundSize, skyboxSize: skyboxSize, rootPosition: rootPosition };
	}

	/**
	 * Setup the ground according to the specified options.
	 */
	private function _setupGround(sceneSize:ISceneSize) {
		if (this._ground == null) {
			this._ground = Mesh.CreatePlane("BackgroundPlane", sceneSize.groundSize, this._scene);
			this._ground.rotation.x = Math.PI / 2; // Face up by default.
			this._ground.parent = this._rootMesh;
			this._ground.onDisposeObservable.add(function(_, _) { this._ground = null; });
		}
		
		this._ground.receiveShadows = this._options.enableGroundShadow;
	}

	/**
	 * Setup the ground material according to the specified options.
	 */
	private function _setupGroundMaterial() {
		if (this._groundMaterial == null) {
			this._groundMaterial = new BackgroundMaterial("BackgroundPlaneMaterial", this._scene);
		}
		this._groundMaterial.alpha = this._options.groundOpacity;
		this._groundMaterial.alphaMode = Engine.ALPHA_PREMULTIPLIED_PORTERDUFF;
		this._groundMaterial.shadowLevel = this._options.groundShadowLevel;
		this._groundMaterial.primaryLevel = 1;
		this._groundMaterial.primaryColor = this._options.groundColor;
		this._groundMaterial.secondaryLevel = 0;
		this._groundMaterial.tertiaryLevel = 0;
		this._groundMaterial.useRGBColor = false;
		this._groundMaterial.enableNoise = true;
		
		if (this._ground != null) {
			this._ground.material = this._groundMaterial;
		}
	}

	/**
	 * Setup the ground diffuse texture according to the specified options.
	 */
	private function _setupGroundDiffuseTexture() {
		if (this._groundMaterial == null) {
			return;
		}
		
		if (this._groundTexture != null) {
			return;
		}
		
		if (Std.is(this._options.groundTexture, BaseTexture)) {
			this._groundMaterial.diffuseTexture = this._options.groundTexture;
			return;
		}
		
		var diffuseTexture = new Texture(this._options.groundTexture, this._scene);
		diffuseTexture.gammaSpace = false;
		diffuseTexture.hasAlpha = true;
		this._groundMaterial.diffuseTexture = diffuseTexture;
	}

	/**
	 * Setup the ground mirror texture according to the specified options.
	 */
	private function _setupGroundMirrorTexture(sceneSize:ISceneSize) {
		var wrapping = Texture.CLAMP_ADDRESSMODE;
		if (this._groundMirror == null) {
			this._groundMirror = new MirrorTexture("BackgroundPlaneMirrorTexture", 
				{ ratio: this._options.groundMirrorSizeRatio },
				this._scene,
				false,
				this._options.groundMirrorTextureType,
				Texture.BILINEAR_SAMPLINGMODE,
				true);
			this._groundMirror.mirrorPlane = new Plane(0, -1, 0, sceneSize.rootPosition.y);
			this._groundMirror.anisotropicFilteringLevel = 1;
			this._groundMirror.wrapU = wrapping;
			this._groundMirror.wrapV = wrapping;
			this._groundMirror.gammaSpace = false;
			
			if (this._groundMirror.renderList != null) {
				for (i in 0...this._scene.meshes.length) {
					var mesh = this._scene.meshes[i];
					if (mesh != this._ground && 
						mesh != this._skybox &&
						mesh != this._rootMesh) {
						this._groundMirror.renderList.push(mesh);
					}
				}
			}
		}
		
		this._groundMirror.clearColor = new Color4(
			this._options.groundColor.r,
			this._options.groundColor.g,
			this._options.groundColor.b,
			1);
		this._groundMirror.adaptiveBlurKernel = this._options.groundMirrorBlurKernel;
	}

	/**
	 * Setup the ground to receive the mirror texture.
	 */
	private function _setupMirrorInGroundMaterial() {
		if (this._groundMaterial != null) {
			this._groundMaterial.reflectionTexture = this._groundMirror;
			this._groundMaterial.reflectionFresnel = true;
			this._groundMaterial.reflectionAmount = this._options.groundMirrorAmount;
			this._groundMaterial.reflectionStandardFresnelWeight = this._options.groundMirrorFresnelWeight;
			this._groundMaterial.reflectionFalloffDistance = this._options.groundMirrorFallOffDistance;
		}
	}

	/**
	 * Setup the skybox according to the specified options.
	 */
	private function _setupSkybox(sceneSize:ISceneSize) {
		if (this._skybox == null) {
			this._skybox = Mesh.CreateBox("BackgroundSkybox", sceneSize.skyboxSize, this._scene, false, Mesh.BACKSIDE);                
			this._skybox.onDisposeObservable.add(function(_, _) { this._skybox = null; });
		}
		this._skybox.parent = this._rootMesh;
	}

	/**
	 * Setup the skybox material according to the specified options.
	 */
	private function _setupSkyboxMaterial() {
		if (this._skybox == null) {
			return;
		}
		
		if (this._skyboxMaterial == null) {
			this._skyboxMaterial = new BackgroundMaterial("BackgroundSkyboxMaterial", this._scene);
		}
		this._skyboxMaterial.useRGBColor = false;
		this._skyboxMaterial.primaryLevel = 1;
		this._skyboxMaterial.primaryColor = this._options.skyboxColor;
		this._skyboxMaterial.secondaryLevel = 0;
		this._skyboxMaterial.tertiaryLevel = 0;
		this._skyboxMaterial.enableNoise = true;
		
		this._skybox.material = this._skyboxMaterial;
	}

	/**
	 * Setup the skybox reflection texture according to the specified options.
	 */
	private function _setupSkyboxReflectionTexture() {
		if (this._skyboxMaterial == null) {
			return;
		}
		
		if (this._skyboxTexture == null) {
			return;
		}
		
		if (Std.is(this._options.skyboxTexture, BaseTexture)) {
			this._skyboxMaterial.reflectionTexture = this._skyboxTexture;
			return;
		}
		
		this._skyboxTexture = new CubeTexture(this._options.skyboxTexture, this._scene);
		this._skyboxTexture.coordinatesMode = Texture.SKYBOX_MODE;
		this._skyboxTexture.gammaSpace = false;
		this._skyboxMaterial.reflectionTexture = this._skyboxTexture;
	}

	/**
	 * Dispose all the elements created by the Helper.
	 */
	public function dispose() {
		if (this._groundMaterial != null) {
			this._groundMaterial.dispose(true, true);
		}
		if (this._skyboxMaterial != null) {
			this._skyboxMaterial.dispose(true, true);
		}
		this._rootMesh.dispose(false);
	}
	
}
