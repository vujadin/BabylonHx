package com.babylonhx.audio;

import com.babylonhx.tools.Ts2Hx;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.audio.Analyser;

#if (js || purejs)
import js.html.audio.*;
import js.html.AudioElement;
#end


@:expose('BABYLON.AudioEngine') class AudioEngine {
    private var _audioContext:AudioContext = null;
    private var _audioContextInitialized:Bool = false;
    public var canUseWebAudio:Bool = false;
    public var masterGain:GainNode;
    private var _connectedAnalyser:Analyser;
    public var WarnedWebAudioUnsupported:Bool = false;
    public var unlocked:Bool = false;
    public var onAudioUnlocked:Dynamic;
    public var audioContext(get, never):AudioContext;

    public function get_audioContext():AudioContext {
        if (!Ts2Hx.isTrue(this._audioContextInitialized)) {
            this._initializeAudioContext();
        }
        return this._audioContext;
    }

    public function new() {
        if (untyped window.AudioContext != 'undefined' || untyped window.webkitAudioContext != 'undefined') {
            untyped window.AudioContext = window.AudioContext || untyped window.webkitAudioContext;
            this.canUseWebAudio = true;
        }

        if (untyped __js__("/iPad|iPhone|iPod/.test(navigator.platform)")) {
            this._unlockiOSaudio();
        } else {
            this.unlocked = true;
        }
      
    }

    private function _unlockiOSaudio() {
        var __this = this;
        var unlockaudio = function() {
            var buffer = __this.audioContext.createBuffer(1, 1, 22050);
            var source = __this.audioContext.createBufferSource();
            source.buffer = buffer;
            source.connect(__this.audioContext.destination);
            source.start(0);
            Ts2Hx.setTimeout(function() {
                if (Ts2Hx.isTrue((cast(source)).playbackState == (cast(source)).PLAYING_STATE || (cast(source)).playbackState == (cast(source)).FINISHED_STATE)) {
                    __this.unlocked = true;
                    untyped window.removeEventListener('touchend', untyped unlockaudio, false);
                    if (Ts2Hx.isTrue(__this.onAudioUnlocked)) {
                        __this.onAudioUnlocked();
                    }
                }
            }, 0);
        };
        untyped window.addEventListener('touchend', unlockaudio, false);
    }

    private function _initializeAudioContext() {
        try {
            if (this.canUseWebAudio) {
                this._audioContext = new AudioContext();
                this.masterGain = this._audioContext.createGain();
                this.masterGain.gain.value = 1;
                this.masterGain.connect(this._audioContext.destination);
                this._audioContextInitialized = true;
            }
        } catch (e:Dynamic) {
            this.canUseWebAudio = false;
            trace("Web Audio: " + e.message);
        }
    }

    public function dispose() {
        if (this.canUseWebAudio && this._audioContextInitialized) {
            if (Ts2Hx.isTrue(this._connectedAnalyser)) {
                this._connectedAnalyser.stopDebugCanvas();
                this._connectedAnalyser.dispose();
                this.masterGain.disconnect();
                this.masterGain.connect(this._audioContext.destination);
                this._connectedAnalyser = null;
            }
            this.masterGain.gain.value = 1;
        }
        this.WarnedWebAudioUnsupported = false;
    }

    public function getGlobalVolume():Float {
        if (this.canUseWebAudio && this._audioContextInitialized) {
            return this.masterGain.gain.value;
        } else {
            return -1;
        }
    }

    public function setGlobalVolume(newVolume:Float) {
        if (this.canUseWebAudio && this._audioContextInitialized) {
            this.masterGain.gain.value = newVolume;
        }
    }

    public function connectToAnalyser(analyser:Analyser) {
        if (Ts2Hx.isTrue(this._connectedAnalyser)) {
            this._connectedAnalyser.stopDebugCanvas();
        }
        if (this.canUseWebAudio && this._audioContextInitialized) {
            this._connectedAnalyser = analyser;
            this.masterGain.disconnect();
            this._connectedAnalyser.connectAudioNodes(this.masterGain, this._audioContext.destination);
        }
    }

}

