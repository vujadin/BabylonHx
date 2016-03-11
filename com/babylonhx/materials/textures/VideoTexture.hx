package com.babylonhx.materials.textures;

import com.babylonhx.tools.Tools;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.VideoTexture') class VideoTexture extends Texture {

    #if (html5 && js)

    public var video:js.html.VideoElement;

    private var _autoLaunch:Bool = true;
    private var _lastUpdate:Float;

    public function new(name:String, urls:Array<String>, scene:Scene, generateMipMaps:Bool=false, invertY:Bool=false, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE) {
        super(null, scene, !generateMipMaps, invertY);

        this.name = name;

        video = cast(js.Browser.document.createElement("video"), js.html.VideoElement);
        video.autoplay = false;
        video.loop = true;

        this.video.oncanplaythrough = function() {
            if(Tools.IsExponentOfTwo(video.videoWidth) && Tools.IsExponentOfTwo(video.videoHeight)) {
                wrapU = Texture.WRAP_ADDRESSMODE;
                wrapV = Texture.WRAP_ADDRESSMODE;
            }
            else {
                wrapU = Texture.CLAMP_ADDRESSMODE;
                wrapV = Texture.CLAMP_ADDRESSMODE;
                generateMipMaps = false;
            }

            _texture = scene.getEngine().createDynamicTexture(video.videoWidth, video.videoHeight, generateMipMaps, samplingMode, false);
            _texture.isReady = true;
        };

        for(url in urls){
            var source = cast(js.Browser.document.createElement("source"), js.html.SourceElement);
            source.src = url;
            video.appendChild(source);
        }

        this._lastUpdate = Tools.Now();
    }

    public function update():Bool {
        if(_autoLaunch) {
            _autoLaunch = false;
            video.play();
        }

        var now = Tools.Now();

        if(now - _lastUpdate < 15 || video.readyState != 4) {   // 4 -> HAVE_ENOUGH_DATA
            return false;
        }

        _lastUpdate = now;
        getScene().getEngine().updateVideoTexture(_texture, video, _invertY);

        return true;
    }

    #else

    //TODO
    public function new(name:String, urls:Array<String>, scene:Scene, generateMipMaps:Bool=false, invertY:Bool=false, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE) {
        super(null, scene, !generateMipMaps, invertY);
	}

    public function update():Bool {
        return false;
    }

	#end
}