package com.babylonhx.lights;

import com.babylonhx.lights.shadows.IShadowGenerator;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.UniformBuffer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.tools.Tags;
import com.babylonhx.animations.Animation;
import com.babylonhx.tools.serialization.SerializationHelper;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Light') class Light extends Node {
	
	// lightmapMode Consts
	/**
     * If every light affecting the material is in this lightmapMode,
     * material.lightmapTexture adds or multiplies
     * (depends on material.useLightmapAsShadowmap)
     * after every other light calculations.
     */
    public static inline var LIGHTMAP_DEFAULT:Int = 0;
	/**
     * material.lightmapTexture as only diffuse lighting from this light
     * adds pnly specular lighting from this light
     * adds dynamic shadows
     */
    public static inline var LIGHTMAP_SPECULAR:Int = 1;
	/**
     * material.lightmapTexture as only lighting
     * no light calculation from this light
     * only adds dynamic shadows from this light
     */
    public static inline var LIGHTMAP_SHADOWSONLY:Int = 2;
	
	// Intensity Mode Consts
	/**
	 * Each light type uses the default quantity according to its type:
	 *      point/spot lights use luminous intensity
	 *      directional lights use illuminance
	 */
	public static inline var INTENSITYMODE_AUTOMATIC:Int = 0;
	/**
	 * lumen (lm)
	 */
	public static inline var INTENSITYMODE_LUMINOUSPOWER:Int = 1;
	/**
	 * candela (lm/sr)
	 */
	public static inline var INTENSITYMODE_LUMINOUSINTENSITY:Int = 2;
	/**
	 * lux (lm/m^2)
	 */
	public static inline var INTENSITYMODE_ILLUMINANCE:Int = 3;
	/**
	 * nit (cd/m^2)
	 */
	public static inline var INTENSITYMODE_LUMINANCE:Int = 4;
	
	// Light types ids const.
	public static inline var LIGHTTYPEID_POINTLIGHT:Int = 0;
	public static inline var LIGHTTYPEID_DIRECTIONALLIGHT:Int = 1;
	public static inline var LIGHTTYPEID_SPOTLIGHT:Int = 2;
	public static inline var LIGHTTYPEID_HEMISPHERICLIGHT:Int = 3;
	

	@serializeAsColor3()
	public var diffuse:Color3 = new Color3(1.0, 1.0, 1.0);

	@serializeAsColor3()
	public var specular:Color3 = new Color3(1.0, 1.0, 1.0);

	@serialize()
	public var intensity:Float = 1.0;

	@serialize()
	public var range:Float = Math.POSITIVE_INFINITY;

	/**
	 * Cached photometric scale default to 1.0 as the automatic intensity mode defaults to 1.0 for every type
	 * of light.
	 */
	private var _photometricScale:Float = 1.0;

	private var _intensityMode:Int = Light.INTENSITYMODE_AUTOMATIC;
	/**
	 * Gets the photometric scale used to interpret the intensity.
	 * This is only relevant with PBR Materials where the light intensity can be defined in a physical way.
	 */
	@serialize()
	public var intensityMode(get, set):Int;
	private function get_intensityMode():Int {
		return this._intensityMode;
	}
	/**
	 * Sets the photometric scale used to interpret the intensity.
	 * This is only relevant with PBR Materials where the light intensity can be defined in a physical way.
	 */
	private function set_intensityMode(value:Int):Int {
		this._intensityMode = value;
		this._computePhotometricScale();
		return value;
	}

	private var _radius:Float = 0.00001;
	/**
	 * Gets the light radius used by PBR Materials to simulate soft area lights.
	 */
	@serialize()
	public var radius(get, set):Float;
	private function get_radius():Float {
		return this._radius;
	}
	/**
	 * sets the light radius used by PBR Materials to simulate soft area lights.
	 */
	private function set_radius(value:Float):Float {
		this._radius = value;
		this._computePhotometricScale();
		return value;
	}

	/**
	 * Defines the rendering priority of the lights. It can help in case of fallback or number of lights
	 * exceeding the number allowed by the materials.
	 */
	@serialize()
	private var _renderPriority:Int;
	@expandToProperty("_reorderLightsInScene")
	public var renderPriority:Int = 0;

	/**
	 * Defines wether or not the shadows are enabled for this light. This can help turning off/on shadow without detaching
	 * the current shadow generator.
	 */
	@serialize()
	public var shadowEnabled:Bool = true;

	private var _includedOnlyMeshes:Array<AbstractMesh>;
	public var includedOnlyMeshes(get, set):Array<AbstractMesh>;
	private function get_includedOnlyMeshes():Array<AbstractMesh> {
		return this._includedOnlyMeshes;
	}
	private function set_includedOnlyMeshes(value:Array<AbstractMesh>):Array<AbstractMesh> {
		this._includedOnlyMeshes = value;
		this._hookArrayForIncludedOnly(value);
		return value;
	}

	private var _excludedMeshes:Array<AbstractMesh>;
	public var excludedMeshes(get, set):Array<AbstractMesh>;
	private function get_excludedMeshes():Array<AbstractMesh> {
		return this._excludedMeshes;
	}
	private function set_excludedMeshes(value:Array<AbstractMesh>):Array<AbstractMesh> {
		this._excludedMeshes = value;
		this._hookArrayForExcluded(value);
		return value;
	}

	@serialize("excludeWithLayerMask")
	private var _excludeWithLayerMask:Int = 0;
	public var excludeWithLayerMask(get, set):Int;
	private function get_excludeWithLayerMask():Int {
		return this._excludeWithLayerMask;
	}
	private function set_excludeWithLayerMask(value:Int):Int {
		this._excludeWithLayerMask = value;
		this._resyncMeshes();
		return value;
	}

	@serialize("includeOnlyWithLayerMask")
	private var _includeOnlyWithLayerMask:Int = 0;
	public var includeOnlyWithLayerMask(get, set):Int;
	private function get_includeOnlyWithLayerMask():Int {
		return this._includeOnlyWithLayerMask;
	}
	private function set_includeOnlyWithLayerMask(value:Int):Int {
		this._includeOnlyWithLayerMask = value;
		this._resyncMeshes();
		return value;
	}

	@serialize("lightmapMode")
	private var _lightmapMode = 0;
	public var lightmapMode(get, set):Int;
	private function get_lightmapMode():Int {
		return this._lightmapMode;
	}
	private function set_lightmapMode(value:Int):Int {
		if (this._lightmapMode == value) {
			return value;
		}
		
		this._lightmapMode = value;
		this._markMeshesAsLightDirty();
		return value;
	}

	private var _parentedWorldMatrix:Matrix;
	public var _shadowGenerator:IShadowGenerator;
	public var _excludedMeshesIds:Array<String> = [];
	public var _includedOnlyMeshesIds:Array<String> = [];

	// Light uniform buffer
	public var _uniformBuffer:UniformBuffer;
	

	/**
	 * Creates a Light object in the scene.  
	 * Documentation : http://doc.babylonjs.com/tutorials/lights  
	 */
	public function new(name:String, scene:Scene) {
		super(name, scene);
		this.getScene().addLight(this);
		this._uniformBuffer = new UniformBuffer(this.getScene().getEngine());
		this._buildUniformLayout();
		
		this.includedOnlyMeshes = new Array<AbstractMesh>();
		this.excludedMeshes = new Array<AbstractMesh>();
		
		this._resyncMeshes();
	}

	public function _buildUniformLayout() {
		// Overridden
	}

	/**
	 * Returns the string "Light".  
	 */
	override public function getClassName():String {
		return "Light";
	}

	/**
	 * @param {boolean} fullDetails - support for multiple levels of logging within scene loading
	 */
	public function toString(fullDetails:Bool = false):String {
		var ret = "Name: " + this.name;
		ret += ", type: " + (["Point", "Directional", "Spot", "Hemispheric"])[this.getTypeID()];
		if (this.animations != null) {
			for (i in 0...this.animations.length) {
				ret += ", animation[0]: " + this.animations[i].toString(fullDetails);
			}
		}
		if (fullDetails) {
		}
		return ret;
	}

	/**
	 * Set the enabled state of this node.
	 * @param {boolean} value - the new enabled state
	 * @see isEnabled
	 */
	override public function setEnabled(value:Bool) {
		super.setEnabled(value);
		
		this._resyncMeshes();
	}

	/**
	 * Returns the Light associated shadow generator.  
	 */
	public function getShadowGenerator():IShadowGenerator {
		return this._shadowGenerator;
	}

	/**
	 * Returns a Vector3, the absolute light position in the World.  
	 */
	public function getAbsolutePosition():Vector3 {
		return Vector3.Zero();
	}

	public function transferToEffect(effect:Effect, lightIndex:String):Light { return this; }

	public function _getWorldMatrix():Matrix {
		return Matrix.Identity();
	}

	/**
	 * Boolean : True if the light will affect the passed mesh.  
	 */
	public function canAffectMesh(mesh:AbstractMesh):Bool {
		if (mesh == null) {
			return true;
		}
		
		if (this.includedOnlyMeshes != null && this.includedOnlyMeshes.length > 0 && this.includedOnlyMeshes.indexOf(mesh) == -1) {
			return false;
		}
		
		if (this.excludedMeshes != null && this.excludedMeshes.length > 0 && this.excludedMeshes.indexOf(mesh) != -1) {
			return false;
		}
		
		if (this.includeOnlyWithLayerMask != 0 && (this.includeOnlyWithLayerMask & mesh.layerMask) == 0) {
			return false;
		}
		
		if (this.excludeWithLayerMask != 0 && (this.excludeWithLayerMask & mesh.layerMask) != 0) {
			return false;
		}
		
		return true;
	}

	/**
	 * Returns the light World matrix.  
	 */
	override public function getWorldMatrix():Matrix {
		this._currentRenderId = this.getScene().getRenderId();
		
		var worldMatrix = this._getWorldMatrix();
		
		if (this.parent != null && this.parent.getWorldMatrix() != null) {
			if (this._parentedWorldMatrix == null) {
				this._parentedWorldMatrix = Matrix.Identity();
			}
			
			worldMatrix.multiplyToRef(this.parent.getWorldMatrix(), this._parentedWorldMatrix);
			
			this._markSyncedWithParent();
			
			return this._parentedWorldMatrix;
		}
		
		return worldMatrix;
	}

	/**
	 * Sort function to order lights for rendering.
	 * @param a First Light object to compare to second.
	 * @param b Second Light object to compare first.
	 * @return -1 to reduce's a's index relative to be, 0 for no change, 1 to increase a's index relative to b.
	 */
	public static function compareLightsPriority(a:Light, b:Light):Int {
		//shadow-casting lights have priority over non-shadow-casting lights
		//the renderPrioirty is a secondary sort criterion
		if (a.shadowEnabled != b.shadowEnabled) {
			return (b.shadowEnabled ? 1 : 0) - (a.shadowEnabled ? 1 : 0);
		}
		return b.renderPriority - a.renderPriority;
	}

	/**
	 * Disposes the light.  
	 */
	override public function dispose(_:Bool = false) {
		if (this._shadowGenerator != null) {
			this._shadowGenerator.dispose();
			this._shadowGenerator = null;
		}
		
		// Animations
		this.getScene().stopAnimation(this);
		
		// Remove from meshes
		for (mesh in this.getScene().meshes) {
			mesh._removeLightSource(this);
		}
		
		this._uniformBuffer.dispose();
		
		// Remove from scene
		this.getScene().removeLight(this);
		super.dispose();
	}

	/**
	 * Returns the light type ID (integer).  
	 */
	public function getTypeID():Int {
		return 0;
	}

	/**
	 * Returns the intensity scaled by the Photometric Scale according to the light type and intensity mode.
	 */
	public function getScaledIntensity():Float {
		return this._photometricScale * this.intensity;
	}

	/**
	 * Returns a new Light object, named "name", from the current one.  
	 */
	public function clone(name:String):Light {
		// VK TODO:
		//return SerializationHelper.Clone(Light.GetConstructorFromName(this.getTypeID(), name, this.getScene()), this);
		return null;
	}
	
	/**
	 * Serializes the current light into a Serialization object.  
	 * Returns the serialized object.  
	 */
	public function serialize():Dynamic {
		// VK TODO:
		//var serializationObject = SerializationHelper.Serialize(this);
		var serializationObject:Dynamic = { };
		
		// Type
		serializationObject.type = this.getTypeID();
		
		// Parent
		if (this.parent != null) {
			serializationObject.parentId = this.parent.id;
		}
		
		// Inclusion / exclusions
		if (this.excludedMeshes.length > 0) {
			serializationObject.excludedMeshesIds = [];
			for (mesh in this.excludedMeshes) {
				serializationObject.excludedMeshesIds.push(mesh.id);
			}
		}
		
		if (this.includedOnlyMeshes.length > 0) {
			serializationObject.includedOnlyMeshesIds = [];
			for (mesh in this.includedOnlyMeshes) {
				serializationObject.includedOnlyMeshesIds.push(mesh.id);
			}
		}
		
		// Animations  
		// VK TODO
		//Animation.AppendSerializedAnimations(this, serializationObject);
		serializationObject.ranges = this.serializeAnimationRanges();
		
		return serializationObject;
	}

	/**
	 * Creates a new typed light from the passed type (integer) : point light = 0, directional light = 1, spot light = 2, hemispheric light = 3.  
	 * This new light is named "name" and added to the passed scene.  
	 */
	static public function GetConstructorFromName(type:Int, name:String, scene:Scene):Void->Light {
		switch (type) {
			case 0:
				return function() { return new PointLight(name, Vector3.Zero(), scene); };
				
			case 1:
				return function() { return new DirectionalLight(name, Vector3.Zero(), scene); };
				
			case 2:
				return function() { return new SpotLight(name, Vector3.Zero(), Vector3.Zero(), 0, 0, scene); };
				
			case 3:
				return function() { return new HemisphericLight(name, Vector3.Zero(), scene); };
				
		}
		return null;
	}

	/**
	 * Parses the passed "parsedLight" and returns a new instanced Light from this parsing.  
	 */
	public static function Parse(parsedLight:Dynamic, scene:Scene):Light {
		var light = SerializationHelper.Parse(Light.GetConstructorFromName(parsedLight.type, parsedLight.name, scene), parsedLight, scene);
		
		// Inclusion / exclusions
		if (parsedLight.excludedMeshesIds != null) {
			light._excludedMeshesIds = parsedLight.excludedMeshesIds;
		}
		
		if (parsedLight.includedOnlyMeshesIds != null) {
			light._includedOnlyMeshesIds = parsedLight.includedOnlyMeshesIds;
		}
		
		// Parent
		if (parsedLight.parentId != null) {
			light._waitingParentId = parsedLight.parentId;
		}
		
		// Animations
		if (parsedLight.animations != null) {
			for (animationIndex in 0...parsedLight.animations.length) {
				var parsedAnimation = parsedLight.animations[animationIndex];
				
				light.animations.push(Animation.Parse(parsedAnimation));
			}
			Node.ParseAnimationRanges(light, parsedLight, scene);
		}
		
		if (parsedLight.autoAnimate == true) {
			scene.beginAnimation(light, parsedLight.autoAnimateFrom, parsedLight.autoAnimateTo, parsedLight.autoAnimateLoop, parsedLight.autoAnimateSpeed != null ? parsedLight.autoAnimateSpeed : 1.0);
		}
		
		return light;
	}

	private function _hookArrayForExcluded(array:Array<AbstractMesh>) {
		// VK TODO:
		/*var oldPush = array.push;
		array.push = (...items: AbstractMesh[]) => {
			var result = oldPush.apply(array, items);

			for (var item of items) {
				item._resyncLighSource(this);
			}

			return result;
		}

		var oldSplice = array.splice;
		array.splice = (index: number, deleteCount?: number) => {
			var deleted = oldSplice.apply(array, [index, deleteCount]);

			for (var item of deleted) {
				item._resyncLighSource(this);
			}

			return deleted;
		}*/
		
		for (item in array) {
			item._resyncLighSource(this);
		}
	}

	private function _hookArrayForIncludedOnly(array:Array<AbstractMesh>) {
		// VK TODO:
		/*var oldPush = array.push;
		array.push = (...items: AbstractMesh[]) => {
			var result = oldPush.apply(array, items);

			this._resyncMeshes();

			return result;
		}

		var oldSplice = array.splice;
		array.splice = (index: number, deleteCount?: number) => {
			var deleted = oldSplice.apply(array, [index, deleteCount]);

			this._resyncMeshes();

			return deleted;
		}*/
		
		this._resyncMeshes();
	}

	private function _resyncMeshes() {
		for (mesh in this.getScene().meshes) {
			mesh._resyncLighSource(this);
		}
	}

	public function _markMeshesAsLightDirty() {
		for (mesh in this.getScene().meshes) {
			if (mesh._lightSources.indexOf(this) != -1) {
				mesh._markSubMeshesAsLightDirty();
			}
		}
	}

	/**
	 * Recomputes the cached photometric scale if needed.
	 */
	private function _computePhotometricScale() {
		this._photometricScale = this._getPhotometricScale();
		this.getScene().resetCachedMaterial();
	}

	/**
	 * Returns the Photometric Scale according to the light type and intensity mode.
	 */
	private function _getPhotometricScale() {
		var photometricScale = 0.0;
		var lightTypeID = this.getTypeID();
		
		//get photometric mode
		var photometricMode = this.intensityMode;
		if (photometricMode == Light.INTENSITYMODE_AUTOMATIC) {
			if (lightTypeID == Light.LIGHTTYPEID_DIRECTIONALLIGHT) {
				photometricMode = Light.INTENSITYMODE_ILLUMINANCE;
			} 
			else {
				photometricMode = Light.INTENSITYMODE_LUMINOUSINTENSITY;
			}
		}
		
		//compute photometric scale
		switch (lightTypeID) {
			case Light.LIGHTTYPEID_POINTLIGHT, Light.LIGHTTYPEID_SPOTLIGHT:
				switch (photometricMode) {
					case Light.INTENSITYMODE_LUMINOUSPOWER:
						photometricScale = 1.0 / (4.0 * Math.PI);
						
					case Light.INTENSITYMODE_LUMINOUSINTENSITY:
						photometricScale = 1.0;
						
					case Light.INTENSITYMODE_LUMINANCE:
						photometricScale = this.radius * this.radius;
						
				}
				
			case Light.LIGHTTYPEID_DIRECTIONALLIGHT:
				switch (photometricMode) {
					case Light.INTENSITYMODE_ILLUMINANCE:
						photometricScale = 1.0;
						
					case Light.INTENSITYMODE_LUMINANCE:
						// When radius (and therefore solid angle) is non-zero a directional lights brightness can be specified via central (peak) luminance.
						// For a directional light the 'radius' defines the angular radius (in radians) rather than world-space radius (e.g. in metres).
						var apexAngleRadians = this.radius;
						// Impose a minimum light angular size to avoid the light becoming an infinitely small angular light source (i.e. a dirac delta function).
						apexAngleRadians = Math.max(apexAngleRadians, 0.001);
						var solidAngle = 2.0 * Math.PI * (1.0 - Math.cos(apexAngleRadians));
						photometricScale = solidAngle;
						
				}
				
			case Light.LIGHTTYPEID_HEMISPHERICLIGHT:
				// No fall off in hemisperic light.
				photometricScale = 1.0;
		}
		
		return photometricScale;
	}

	private function _reorderLightsInScene() {
		var scene = this.getScene();
		if (this.renderPriority != 0) {
			scene.requireLightSorting = true;
		}
		this.getScene().sortLightsByPriority();
	}
	
}
