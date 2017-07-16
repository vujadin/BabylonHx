package com.babylonhx.audio;

import com.babylonhx.tools.Tools;
import com.babylonhx.tools.Ts2Hx;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.mesh.AbstractMesh;
import lime.utils.ArrayBuffer;
#if (js || purejs)
import js.html.audio.*;
import js.html.AudioElement;
#end


@:expose('BABYLON.Sound') class Sound {

    public var name:String;
    public var autoplay:Bool = false;
    public var loop:Bool = false;
    public var useCustomAttenuation:Bool = false;
    public var soundTrackId:Float;
    public var spatialSound:Bool = false;
    public var refDistance:Float = 1;
    public var rolloffFactor:Float = 1;
    public var maxDistance:Float = 100;
    public var distanceModel:js.html.audio.DistanceModelType = js.html.audio.DistanceModelType.LINEAR;

    private var _panningModel:js.html.audio.PanningModelType = js.html.audio.PanningModelType.EQUALPOWER;
    public var onended:Dynamic;
    private var _playbackRate:Float = 1;
    private var _streaming:Bool = false;
    private var _startTime:Float = 0;
    private var _startOffset:Float = 0;
    private var _position:Vector3 = Vector3.Zero();
    private var _localDirection:Vector3 = new Vector3(1, 0, 0);
    private var _volume:Float = 1;
    private var _isLoaded:Bool = false;
    private var _isReadyToPlay:Bool = false;
    public var isPlaying:Bool = false;
    public var isPaused:Bool = false;
    private var _isDirectional:Bool = false;
    private var _readyToPlayCallback:Dynamic;
    private var _audioBuffer:AudioBuffer;
    private var _soundSource:AudioBufferSourceNode;
    private var _streamingSource:MediaElementAudioSourceNode;
    private var _soundPanner:PannerNode;
    private var _soundGain:GainNode;
    private var _inputAudioNode:AudioNode;
    private var _ouputAudioNode:AudioNode;
    private var _coneInnerAngle:Float = 360;
    private var _coneOuterAngle:Float = 360;
    private var _coneOuterGain:Float = 0;
    private var _scene:Scene;
    private var _connectedMesh:AbstractMesh;
    private var _customAttenuationFunction:Dynamic;
    private var _registerFunc:Dynamic;
    private var _isOutputConnected:Bool = false;
    private var _htmlAudioElement:AudioElement;
    public function new(name:String, urlOrArrayBuffer:Dynamic, scene:Scene, ?readyToPlayCallback:Dynamic, ?options:Dynamic) {
        var __this = this;
        this.name = name;
        this._scene = scene;
        this._readyToPlayCallback = readyToPlayCallback;
        this._customAttenuationFunction = function(currentVolume:Float, currentDistance:Float, maxDistance:Float, refDistance:Float, rolloffFactor:Float) {
            if (currentDistance < maxDistance) {
                return currentVolume * (1 - currentDistance / maxDistance);
            } else {
                return 0;
            }
        };
        if (Ts2Hx.isTrue(options)) {

            this.autoplay = Reflect.hasField(options, "autoplay") ? options.autoplay : false;
            this.loop = Reflect.hasField(options, "loop") ? options.loop : false;
            if (options.volume != null) {
                this._volume = options.volume;
            }

            this.spatialSound = Reflect.hasField(options, "spatialSound") ? options.spatialSound : false;
            this.maxDistance = Reflect.hasField(options, "maxDistance") ? options.maxDistance : 100;
            this.useCustomAttenuation = Reflect.hasField(options, "useCustomAttenuation") ? options.useCustomAttenuation : false;

            

            this.rolloffFactor = Reflect.hasField(options, "rolloffFactor") ? options.rolloffFactor : 1;
            this.refDistance = Reflect.hasField(options, "refDistance") ? options.refDistance : 1;
            this.distanceModel = Reflect.hasField(options, "distanceModel") ? options.distanceModel : js.html.audio.DistanceModelType.LINEAR;
            this._playbackRate = Reflect.hasField(options, "playbackRate") ? options.playbackRate : 1;
            this._streaming = Reflect.hasField(options, "streaming") ? options.streaming : false;
        }
        if (Ts2Hx.isTrue(this._scene.getEngine().audioEngine.canUseWebAudio)) {
            this._soundGain = this._scene.getEngine().audioEngine.audioContext.createGain();
            this._soundGain.gain.value = this._volume;
            this._inputAudioNode = this._soundGain;
            this._ouputAudioNode = this._soundGain;
            if (this.spatialSound) {
                this._createSpatialParameters();
            }
            this._scene.mainSoundTrack.AddSound(this);
            if (Ts2Hx.isTrue(urlOrArrayBuffer)) {
                if (Std.is(urlOrArrayBuffer, String)) {
                    if (!Ts2Hx.isTrue(this._streaming)) {
                        Tools.LoadFile(urlOrArrayBuffer, function(data) {
                            __this._soundLoaded(data);
                        });
                    } else {
                        this._htmlAudioElement = new  js.html.Audio(urlOrArrayBuffer);
                        this._htmlAudioElement.controls = false;
                        this._htmlAudioElement.loop = this.loop;
                        this._htmlAudioElement.crossOrigin = "anonymous";
                        this._htmlAudioElement.preload = "auto";
                        this._htmlAudioElement.addEventListener("canplaythrough", function() {
                            __this._isReadyToPlay = true;
                            if (Ts2Hx.isTrue(__this.autoplay)) {
                                __this.play();
                            }
                            if (Ts2Hx.isTrue(__this._readyToPlayCallback)) {
                                __this._readyToPlayCallback();
                            }
                        });
                        js.Browser.window.document.body.appendChild(this._htmlAudioElement);
                    }
                } else {
                    if (Std.is(urlOrArrayBuffer, ArrayBuffer)) {
                        if ((cast(urlOrArrayBuffer, ArrayBuffer)).byteLength > 0) {
                            this._soundLoaded(urlOrArrayBuffer);
                        }
                    } else {
                        trace("Parameter must be a URL to the sound or an ArrayBuffer of the sound.");
                    }
                }
            }
        } else {
            this._scene.mainSoundTrack.AddSound(this);
            if (!Ts2Hx.isTrue(this._scene.getEngine().audioEngine.WarnedWebAudioUnsupported)) {
                trace("Web Audio is not supported by your browser.");
                this._scene.getEngine().audioEngine.WarnedWebAudioUnsupported = true;
            }
            if (Ts2Hx.isTrue(this._readyToPlayCallback)) {
                untyped window.setTimeout(function() {
                    __this._readyToPlayCallback();
                }, 1000);
            }
        }
    }

    public function dispose() {
        if (this._scene.getEngine().audioEngine.canUseWebAudio && this._isReadyToPlay) {
            if (this.isPlaying) {
                this.stop();
            }
            this._isReadyToPlay = false;
            if (this.soundTrackId == -1) {
                this._scene.mainSoundTrack.RemoveSound(this);
            } else {
                this._scene.soundTracks[cast(this.soundTrackId, Int)].RemoveSound(this);
            }
            if (Ts2Hx.isTrue(this._soundGain)) {
                this._soundGain.disconnect();
                this._soundGain = null;
            }
            if (Ts2Hx.isTrue(this._soundPanner)) {
                this._soundPanner.disconnect();
                this._soundPanner = null;
            }
            if (Ts2Hx.isTrue(this._soundSource)) {
                this._soundSource.disconnect();
                this._soundSource = null;
            }
            this._audioBuffer = null;
            if (Ts2Hx.isTrue(this._htmlAudioElement)) {
                this._htmlAudioElement.pause();
                this._htmlAudioElement.src = "";
                js.Browser.window.document.body.removeChild(this._htmlAudioElement);
            }
            if (Ts2Hx.isTrue(this._connectedMesh)) {
                this._connectedMesh.unregisterAfterWorldMatrixUpdate(this._registerFunc);
                this._connectedMesh = null;
            }
        }
    }

    private function _soundLoaded(audioData:ArrayBuffer) {
        var __this = this;
        this._isLoaded = true;
        this._scene.getEngine().audioEngine.audioContext.decodeAudioData(audioData, function(buffer) {
            __this._audioBuffer = buffer;
            __this._isReadyToPlay = true;
            if (Ts2Hx.isTrue(__this.autoplay)) {
                __this.play();
            }
            if (Ts2Hx.isTrue(__this._readyToPlayCallback)) {
                __this._readyToPlayCallback();
            }
        }, function() {
            trace("Error while decoding audio data for: " + __this.name);
        });
    }

    public function setAudioBuffer(audioBuffer:AudioBuffer):Void {
        if (Ts2Hx.isTrue(this._scene.getEngine().audioEngine.canUseWebAudio)) {
            this._audioBuffer = audioBuffer;
            this._isReadyToPlay = true;
        }
    }

    public function updateOptions(options) {
        if (Ts2Hx.isTrue(options)) {
            this.loop = Reflect.hasField(options, "loop") ? options.loop : this.loop;
            this.maxDistance =  Reflect.hasField(options, "maxDistance") ? options.maxDistance : this.maxDistance;
            this.useCustomAttenuation = Reflect.hasField(options, "useCustomAttenuation") ? options.useCustomAttenuation : this.useCustomAttenuation;
            this.rolloffFactor = Reflect.hasField(options, "rolloffFactor") ? options.rolloffFactor : this.rolloffFactor;
            this.refDistance = Reflect.hasField(options, "refDistance") ? options.refDistance : this.refDistance;
            this.distanceModel = Reflect.hasField(options, "distanceModel") ? options.distanceModel : this.distanceModel;
            this._playbackRate = Reflect.hasField(options, "playbackRate") ? options.playbackRate : this._playbackRate;
            this._updateSpatialParameters();
            if (this.isPlaying) {
                if (Ts2Hx.isTrue(this._streaming)) {
                    this._htmlAudioElement.playbackRate = this._playbackRate;
                } else {
                    this._soundSource.playbackRate.value = this._playbackRate;
                }
            }
        }
    }

    private function _createSpatialParameters() {
        if (Ts2Hx.isTrue(this._scene.getEngine().audioEngine.canUseWebAudio)) {
            if (Ts2Hx.isTrue(this._scene.get_headphone())) {
                this._panningModel = js.html.audio.PanningModelType.HRTF;
            }
            this._soundPanner = this._scene.getEngine().audioEngine.audioContext.createPanner();
            this._updateSpatialParameters();
            this._soundPanner.connect(this._ouputAudioNode);
            this._inputAudioNode = this._soundPanner;
        }
    }

    private function _updateSpatialParameters() {
        if (this.spatialSound) {
            if (this.useCustomAttenuation) {
                this._soundPanner.distanceModel = js.html.audio.DistanceModelType.LINEAR;
                this._soundPanner.maxDistance = untyped Number.MAX_VALUE;
                this._soundPanner.refDistance = 1;
                this._soundPanner.rolloffFactor = 1;

                this._soundPanner.panningModel = this._panningModel;
            } else {
                this._soundPanner.distanceModel = this.distanceModel;
                this._soundPanner.maxDistance = this.maxDistance;
                this._soundPanner.refDistance = this.refDistance;
                this._soundPanner.rolloffFactor = this.rolloffFactor;
                this._soundPanner.panningModel = this._panningModel;
            }
        }
    }

    public function switchPanningModelToHRTF() {
        this._panningModel = js.html.audio.PanningModelType.HRTF;
        this._switchPanningModel();
    }

    public function switchPanningModelToEqualPower() {
        this._panningModel = js.html.audio.PanningModelType.EQUALPOWER;
        this._switchPanningModel();
    }

    private function _switchPanningModel() {
        if (this._scene.getEngine().audioEngine.canUseWebAudio && this.spatialSound) {
            this._soundPanner.panningModel = this._panningModel;
        }
    }

    public function connectToSoundTrackAudioNode(soundTrackAudioNode:AudioNode) {
        if (Ts2Hx.isTrue(this._scene.getEngine().audioEngine.canUseWebAudio)) {
            if (Ts2Hx.isTrue(this._isOutputConnected)) {
                this._ouputAudioNode.disconnect();
            }
            this._ouputAudioNode.connect(soundTrackAudioNode);
            this._isOutputConnected = true;
        }
    }

    public function setDirectionalCone(coneInnerAngle:Float, coneOuterAngle:Float, coneOuterGain:Float) {
        if (coneOuterAngle < coneInnerAngle) {
            trace("setDirectionalCone(): outer angle of the cone must be superior or equal to the inner angle.");
            return ;
        }
        this._coneInnerAngle = coneInnerAngle;
        this._coneOuterAngle = coneOuterAngle;
        this._coneOuterGain = coneOuterGain;
        this._isDirectional = true;
        if (this.isPlaying && this.loop) {
            this.stop();
            this.play();
        }
    }

    public function setPosition(newPosition:Vector3) {
        this._position = newPosition;
        if (this._scene.getEngine().audioEngine.canUseWebAudio && this.spatialSound) {
            this._soundPanner.setPosition(this._position.x, this._position.y, this._position.z);
        }
    }

    public function setLocalDirectionToMesh(newLocalDirection:Vector3) {
        this._localDirection = newLocalDirection;
        if (this._scene.getEngine().audioEngine.canUseWebAudio && this._connectedMesh != null && this.isPlaying) {
            this._updateDirection();
        }
    }

    private function _updateDirection() {
        var mat = this._connectedMesh.getWorldMatrix();
        var direction = Vector3.TransformNormal(this._localDirection, mat);
        direction.normalize();
        this._soundPanner.setOrientation(direction.x, direction.y, direction.z);
    }

    public function updateDistanceFromListener() {
        if (this._scene.getEngine().audioEngine.canUseWebAudio && this._connectedMesh != null && this.useCustomAttenuation) {
            var distance = this._connectedMesh.getDistanceToCamera(this._scene.activeCamera);
            this._soundGain.gain.value = this._customAttenuationFunction(this._volume, distance, this.maxDistance, this.refDistance, this.rolloffFactor);
        }
    }

    public function setAttenuationFunction(callback:Dynamic) {
        this._customAttenuationFunction = callback;
    }

    public function play(?time:Float) {
        var __this = this;
        if (this._isReadyToPlay && this._scene.get_audioEnabled()) {
            try {
                var startTime = Ts2Hx.isTrue(time) ? this._scene.getEngine().audioEngine.audioContext.currentTime + time : this._scene.getEngine().audioEngine.audioContext.currentTime;
                if (this._soundSource != null || this._streamingSource != null) {
                    if (this.spatialSound) {
                        this._soundPanner.setPosition(this._position.x, this._position.y, this._position.z);
                        if (Ts2Hx.isTrue(this._isDirectional)) {
                            this._soundPanner.coneInnerAngle = this._coneInnerAngle;
                            this._soundPanner.coneOuterAngle = this._coneOuterAngle;
                            this._soundPanner.coneOuterGain = this._coneOuterGain;
                            if (Ts2Hx.isTrue(this._connectedMesh)) {
                                this._updateDirection();
                            } else {
                                this._soundPanner.setOrientation(this._localDirection.x, this._localDirection.y, this._localDirection.z);
                            }
                        }
                    }
                }
                if (Ts2Hx.isTrue(this._streaming)) {
                    if (!Ts2Hx.isTrue(this._streamingSource)) {
                        this._streamingSource = this._scene.getEngine().audioEngine.audioContext.createMediaElementSource(this._htmlAudioElement);
                        this._htmlAudioElement.onended = function() {
                            __this._onended();
                        };
                        this._htmlAudioElement.playbackRate = this._playbackRate;
                    }
                    this._streamingSource.disconnect();
                    this._streamingSource.connect(this._inputAudioNode);
                    this._htmlAudioElement.play();
                } else {
                    this._soundSource = this._scene.getEngine().audioEngine.audioContext.createBufferSource();
                    this._soundSource.buffer = this._audioBuffer;
                    this._soundSource.connect(this._inputAudioNode);
                    this._soundSource.loop = this.loop;
                    this._soundSource.playbackRate.value = this._playbackRate;
                    this._soundSource.onended = function() {
                        __this._onended();
                    };
                    if (!this.isPaused) {
                        this._soundSource.start(startTime);
                    } else {
                        this._soundSource.start(0, this.isPaused ? this._startOffset % this._soundSource.buffer.duration : 0);
                    }
                }
                this._startTime = startTime;
                this.isPlaying = true;
                this.isPaused = false;
            } catch (ex:Dynamic) {
                trace("Error while trying to play audio: " + this.name + ", " + ex.message);
            }
        }
    }

    private function _onended() {
        this.isPlaying = false;
        if (Ts2Hx.isTrue(this.onended)) {
            this.onended();
        }
    }

    public function stop(?time:Float) {
        if (this.isPlaying) {
            if (Ts2Hx.isTrue(this._streaming)) {
                this._htmlAudioElement.pause();
                if (this._htmlAudioElement.currentTime > 0) {
                    this._htmlAudioElement.currentTime = 0;
                }
            } else {
                var stopTime = Ts2Hx.isTrue(time) ? this._scene.getEngine().audioEngine.audioContext.currentTime + time : this._scene.getEngine().audioEngine.audioContext.currentTime;
                this._soundSource.stop(stopTime);
                if (!this.isPaused) {
                    this._startOffset = 0;
                }
            }
            this.isPlaying = false;
        }
    }

    public function pause() {
        if (this.isPlaying) {
            this.isPaused = true;
            if (Ts2Hx.isTrue(this._streaming)) {
                this._htmlAudioElement.pause();
            } else {
                this.stop(0);
                this._startOffset += this._scene.getEngine().audioEngine.audioContext.currentTime - this._startTime;
            }
        }
    }

    public function setVolume(newVolume:Float, ?time:Float) {
        if (Ts2Hx.isTrue(this._scene.getEngine().audioEngine.canUseWebAudio)) {
            if (Ts2Hx.isTrue(time)) {
                this._soundGain.gain.cancelScheduledValues(this._scene.getEngine().audioEngine.audioContext.currentTime);
                this._soundGain.gain.setValueAtTime(this._soundGain.gain.value, this._scene.getEngine().audioEngine.audioContext.currentTime);
                this._soundGain.gain.linearRampToValueAtTime(newVolume, this._scene.getEngine().audioEngine.audioContext.currentTime + time);
            } else {
                this._soundGain.gain.value = newVolume;
            }
        }
        this._volume = newVolume;
    }

    public function setPlaybackRate(newPlaybackRate:Float) {
        this._playbackRate = newPlaybackRate;
        if (this.isPlaying) {
            if (Ts2Hx.isTrue(this._streaming)) {
                this._htmlAudioElement.playbackRate = this._playbackRate;
            } else {
                this._soundSource.playbackRate.value = this._playbackRate;
            }
        }
    }

    public function getVolume():Float {
        return this._volume;
    }

    public function attachToMesh(meshToConnectTo:AbstractMesh) {
        var __this = this;
        if (Ts2Hx.isTrue(this._connectedMesh)) {
            this._connectedMesh.unregisterAfterWorldMatrixUpdate(this._registerFunc);
            this._registerFunc = null;
        }
        this._connectedMesh = meshToConnectTo;
        if (!this.spatialSound) {
            this.spatialSound = true;
            this._createSpatialParameters();
            if (this.isPlaying && this.loop) {
                this.stop();
                this.play();
            }
        }
        this._onRegisterAfterWorldMatrixUpdate(this._connectedMesh);
        this._registerFunc = function(connectedMesh:AbstractMesh) this._onRegisterAfterWorldMatrixUpdate(connectedMesh);
        meshToConnectTo.registerAfterWorldMatrixUpdate(this._registerFunc);
    }

    private function _onRegisterAfterWorldMatrixUpdate(connectedMesh:AbstractMesh) {
        this.setPosition(connectedMesh.getBoundingInfo().boundingSphere.centerWorld);
        if (this._scene.getEngine().audioEngine.canUseWebAudio && this._isDirectional && this.isPlaying) {
            this._updateDirection();
        }
    }

    public function clone():Sound {
        var __this = this;
        var clonedSound:Dynamic = {};
        if (!Ts2Hx.isTrue(this._streaming)) {
            var setBufferAndRun = function() {
                if (Ts2Hx.isTrue(__this._isReadyToPlay)) {
                    clonedSound._audioBuffer = __this.getAudioBuffer();
                    clonedSound._isReadyToPlay = true;
                    if (Ts2Hx.isTrue(clonedSound.autoplay)) {
                        clonedSound.play();
                    }
                } else {
                    untyped window.setTimeout(setBufferAndRun, 300);
                }
            };
            var currentOptions:Dynamic = {
                autoplay: this.autoplay,
                loop: this.loop,
                volume: this._volume,
                spatialSound: this.spatialSound,
                maxDistance: this.maxDistance,
                useCustomAttenuation: this.useCustomAttenuation,
                rolloffFactor: this.rolloffFactor,
                refDistance: this.refDistance,
                distanceModel: this.distanceModel
            };
            var clonedSound = new Sound(this.name + "_cloned", new ArrayBuffer(0), this._scene, null, currentOptions);
            if (this.useCustomAttenuation) {
                clonedSound.setAttenuationFunction(this._customAttenuationFunction);
            }
            clonedSound.setPosition(this._position);
            clonedSound.setPlaybackRate(this._playbackRate);
            setBufferAndRun();
            return clonedSound;
        } else {
            return null;
        }
    }

    public function getAudioBuffer() {
        return this._audioBuffer;
    }

    static public function Parse(parsedSound:Dynamic, scene:Scene, rootUrl:String, ?sourceSound:Sound):Sound {
        //var __this = this;
        var soundName = parsedSound.name;
        var soundUrl;
        if (Ts2Hx.isTrue(parsedSound.url)) {
            soundUrl = rootUrl + parsedSound.url;
        } else {
            soundUrl = rootUrl + soundName;
        }
        var options:Dynamic = {
            autoplay: parsedSound.autoplay,
            loop: parsedSound.loop,
            volume: parsedSound.volume,
            spatialSound: parsedSound.spatialSound,
            maxDistance: parsedSound.maxDistance,
            rolloffFactor: parsedSound.rolloffFactor,
            refDistance: parsedSound.refDistance,
            distanceModel: parsedSound.distanceModel,
            playbackRate: parsedSound.playbackRate
        };
        var newSound:Sound;
        if (!Ts2Hx.isTrue(sourceSound)) {
            untyped window.newSound = new Sound(soundName, soundUrl, scene, function() {
                scene._removePendingData(window.newSound);
            }, options);
            scene._addPendingData( untyped window.newSound );
        } else {
            var setBufferAndRun = function() {
                if (Ts2Hx.isTrue( untyped window.newSound._isReadyToPlay)) {
                     untyped window.newSound ._audioBuffer = sourceSound.getAudioBuffer();
                     untyped window.newSound ._isReadyToPlay = true;
                    if (Ts2Hx.isTrue( untyped window.newSound .autoplay)) {
                         untyped window.newSound .play();
                    }
                } else {
                    untyped window.setTimeout(setBufferAndRun, 300);
                }
            }
            newSound = new Sound(soundName, new ArrayBuffer(0), scene, null, options);
            setBufferAndRun();
        }
        if (Ts2Hx.isTrue(parsedSound.position)) {
            var soundPosition = Vector3.FromArray(parsedSound.position);
             untyped window.newSound.setPosition(soundPosition);
        }
        if (Ts2Hx.isTrue(parsedSound.isDirectional)) {
            
            

             untyped window.newSound .setDirectionalCone(Reflect.hasField(parsedSound, "coneInnerAngle") ? parsedSound.coneInnerAngle : 360, Reflect.hasField(parsedSound, "coneOuterAngle") ? parsedSound.coneOuterAngle : 360, Reflect.hasField(parsedSound, "coneOuterGain") ? parsedSound.coneOuterGain : 0);
            if (Ts2Hx.isTrue(parsedSound.localDirectionToMesh)) {
                var localDirectionToMesh = Vector3.FromArray(parsedSound.localDirectionToMesh);
                 untyped window.newSound .setLocalDirectionToMesh(localDirectionToMesh);
            }
        }
        if (Ts2Hx.isTrue(parsedSound.connectedMeshId)) {
            var connectedMesh = scene.getMeshByID(parsedSound.connectedMeshId);
            if (Ts2Hx.isTrue(connectedMesh)) {
                 untyped window.newSound .attachToMesh(connectedMesh);
            }
        }
        return  untyped window.newSound;
    }

}

