package com.babylonhx.materials.textures;

import com.babylonhx.engine.Engine;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;
import com.babylonhx.tools.Tools;
import com.babylonhx.animations.Animation;
import com.babylonhx.tools.serialization.SerializationHelper;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.CubeTexture') class CubeTexture extends BaseTexture {
	
	public var url:String;
	
	/**
     * Gets or sets the center of the bounding box associated with the texture (when in cube mode)
     * It must define where the camera used to render the texture is set
     */
    public var boundingBoxPosition:Vector3 = Vector3.Zero();

    private var _boundingBoxSize:Vector3;

    /**
     * Gets or sets the size of the bounding box associated with the texture (when in cube mode)
     * When defined, the cubemap will switch to local mode
     * @see https://community.arm.com/graphics/b/blog/posts/reflections-based-on-local-cubemaps-in-unity
     * @example https://www.babylonjs-playground.com/#RNASML
     */        
	public var boundingBoxSize(get, set):Vector3;
    function set_boundingBoxSize(value:Vector3):Vector3 {
        if (this._boundingBoxSize != null && this._boundingBoxSize.equals(value)) {
            return value;
        }
        this._boundingBoxSize = value;
        var scene = this.getScene();
        if (scene != null) {
            scene.markAllMaterialsAsDirty(Material.TextureDirtyFlag);
        }
		return value;
    }
    inline function get_boundingBoxSize():Vector3 {
        return this._boundingBoxSize;
    }
	
	private var _noMipmap:Bool;
	private var _files:Array<String>;
	private var _extensions:Array<String>;
	private var _textureMatrix:Matrix;
	private var _format:Int;
	private var _prefiltered:Bool;
	
	
	public static function CreateFromImages(files:Array<String>, scene:Scene, noMipmap:Bool = false) {
		return new CubeTexture("", scene, null, noMipmap, files);
	}
	
	public static function CreateFromPrefilteredData(url:String, scene:Scene, forcedExtension = null) {
		return new CubeTexture(url, scene, null, false, null, null, null, Engine.TEXTUREFORMAT_RGBA, true);
	}

	
	public function new(rootUrl:String, scene:Scene, ?extensions:Array<String>, noMipmap:Bool = false, ?files:Array<String>, onLoad:InternalTexture->Void = null, onError:Void->Void = null, format:Int = Engine.TEXTUREFORMAT_RGBA, prefiltered:Bool = false, forcedExtension = null) {
		super(scene);
		
		this.coordinatesMode = Texture.CUBIC_MODE;
		
		this.name = rootUrl;
		this.url = rootUrl;
		this._noMipmap = noMipmap;
		this.hasAlpha = false;
		this._format = format;
		this._prefiltered = prefiltered;
		this.isCube = true;		
		this._textureMatrix = Matrix.Identity();		
		if (prefiltered) {
            this.gammaSpace = false;
        }
		
		if ((rootUrl == null || rootUrl == "") && files == null) {
			return;
		}
		
		this._texture = this._getFromCache(rootUrl, noMipmap);
		
		if (files == null) {
			if (extensions == null) {
				extensions = ["_px.jpg", "_py.jpg", "_pz.jpg", "_nx.jpg", "_ny.jpg", "_nz.jpg"];
			}
			
			files = [];
			
			for (index in 0...extensions.length) {
				files.push(rootUrl + extensions[index]);
			}
			
			this._extensions = extensions;
		}
		
		this._files = files;
		
		if (this._texture == null) {
			if (!scene.useDelayedTextureLoading) {
				if (prefiltered) {
					this._texture = scene.getEngine().createPrefilteredCubeTexture(rootUrl, scene, this.lodGenerationScale, this.lodGenerationOffset, onLoad, onError, format, forcedExtension);
				}
				else {
					this._texture = scene.getEngine().createCubeTexture(rootUrl, scene, files, noMipmap, onLoad, onError, this._format, forcedExtension);
				}
			} 
			else {
				this.delayLoadState = Engine.DELAYLOADSTATE_NOTLOADED;
			}
		}
		else if (onLoad != null) {
			if (this._texture.isReady) {
				Tools.SetImmediate(onLoad);
			} 
			else {
				this._texture.onLoadedObservable.add(cast onLoad);
			}
		}
	}

	// Methods
	override public function delayLoad() {
		if (this.delayLoadState != Engine.DELAYLOADSTATE_NOTLOADED) {
			return;
		}
		
		var scene = this.getScene();
		
        if (scene == null) {
            return;
        }
		
		this.delayLoadState = Engine.DELAYLOADSTATE_LOADED;
		this._texture = this._getFromCache(this.url, this._noMipmap);
		
		if (this._texture == null) {
			if (this._prefiltered) {
				this._texture = scene.getEngine().createPrefilteredCubeTexture(this.url, scene, this.lodGenerationScale, this.lodGenerationOffset, null, null, this._format);
			}
			else {
				this._texture = scene.getEngine().createCubeTexture(this.url, scene, this._files, this._noMipmap, null, null, this._format);
			}
		}
	}

	override public function getReflectionTextureMatrix():Matrix {
		return this._textureMatrix;
	}
	
	public function setReflectionTextureMatrix(value:Matrix) {
		this._textureMatrix = value;
	}
	
	public static function Parse(parsedTexture:Dynamic, scene:Scene, rootUrl:String):CubeTexture {
		var texture = SerializationHelper.Parse(function() {
			return new CubeTexture(rootUrl + parsedTexture.name, scene, parsedTexture.extensions);
		}, parsedTexture, scene);
		
		// Local Cubemaps
		if (parsedTexture.boundingBoxPosition != null) {
			texture.boundingBoxPosition = Vector3.FromArray(parsedTexture.boundingBoxPosition);
		}
		if (parsedTexture.boundingBoxSize != null) {
			texture.boundingBoxSize = Vector3.FromArray(parsedTexture.boundingBoxSize);
		}
		
		// Animations
		if (parsedTexture.animations != null) {
			for (animationIndex in 0...parsedTexture.animations.length) {
				var parsedAnimation = parsedTexture.animations[animationIndex];
				
				texture.animations.push(Animation.Parse(parsedAnimation));
			}
		}
		
		return texture;
	}
	
	override public function clone():CubeTexture {
		//return SerializationHelper.Clone(function() {
			var scene = this.getScene();
			
			if (scene == null) {
				return this;
			}
			
			return new CubeTexture(this.url, this.getScene(), this._extensions, this._noMipmap, this._files);
		//}, this);
	}
	
}
