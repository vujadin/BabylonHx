package com.babylonhx.audio;

import com.babylonhx.audio.AudioEngine;
import com.babylonhx.tools.Ts2Hx;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.audio.Analyser;

#if (js || purejs)
import js.html.audio.*;
import js.html.AudioElement;
#end


@:expose('BABYLON.SoundTrack') class SoundTrack {
    private var _outputAudioNode:GainNode;
    private var _inputAudioNode:AudioNode;
    private var _trackConvolver:ConvolverNode;
    private var _scene:Scene;
    public var id:Float = -1;
    public var soundCollection:Array<Sound>;
    private var _isMainTrack:Bool = false;
    private var _connectedAnalyser:Analyser;
    private var _options:Dynamic;
    private var _isInitialized:Bool = false;

    public function new(scene:Scene, ?options:Dynamic) {
        this._scene = scene;
        this.soundCollection = new Array();
        this._options = options;
        if (!Ts2Hx.isTrue(this._isMainTrack)) {
            this._scene.soundTracks.push(this);
            this.id = this._scene.soundTracks.length - 1;
        }
    }

    private function _initializeSoundTrackAudioGraph() {
        if (Ts2Hx.isTrue(this._scene.getEngine().audioEngine.canUseWebAudio)) {
            this._outputAudioNode = this._scene.getEngine().audioEngine.audioContext.createGain();
            this._outputAudioNode.connect(this._scene.getEngine().audioEngine.masterGain);
            if (Ts2Hx.isTrue(this._options)) {
                if (Ts2Hx.isTrue(this._options.volume)) {
                    this._outputAudioNode.gain.value = this._options.volume;
                }
                if (Ts2Hx.isTrue(this._options.mainTrack)) {
                    this._isMainTrack = this._options.mainTrack;
                }
            }
            this._isInitialized = true;
        }
    }

    public function dispose() {
        if (Ts2Hx.isTrue(this._scene.getEngine().audioEngine.canUseWebAudio)) {
            if (Ts2Hx.isTrue(this._connectedAnalyser)) {
                this._connectedAnalyser.stopDebugCanvas();
            }
            while (Ts2Hx.isTrue(this.soundCollection.length)) {
                this.soundCollection[0].dispose();
            }
            if (Ts2Hx.isTrue(this._outputAudioNode)) {
                this._outputAudioNode.disconnect();
            }
            this._outputAudioNode = null;
        }
    }

    public function AddSound(sound:Sound) {
        if (!Ts2Hx.isTrue(this._isInitialized)) {
            this._initializeSoundTrackAudioGraph();
        }
        if (Ts2Hx.isTrue(this._scene.getEngine().audioEngine.canUseWebAudio)) {
            sound.connectToSoundTrackAudioNode(this._outputAudioNode);
        }
        if (Ts2Hx.isTrue(sound.soundTrackId)) {
            if (sound.soundTrackId == -1) {
                this._scene.mainSoundTrack.RemoveSound(sound);
            } else {
                Ts2Hx.getValue(this._scene.soundTracks, sound.soundTrackId).RemoveSound(sound);
            }
        }
        this.soundCollection.push(sound);
        sound.soundTrackId = this.id;
    }

    public function RemoveSound(sound:Sound) {
        var index = this.soundCollection.indexOf(sound);
        if (index != -1) {
            this.soundCollection.splice(index, 1);
        }
    }

    public function setVolume(newVolume:Float) {
        if (Ts2Hx.isTrue(this._scene.getEngine().audioEngine.canUseWebAudio)) {
            this._outputAudioNode.gain.value = newVolume;
        }
    }

    public function switchPanningModelToHRTF() {
        if (Ts2Hx.isTrue(this._scene.getEngine().audioEngine.canUseWebAudio)) {
            var i:Int = 0;
            while (i < this.soundCollection.length) {
                this.soundCollection[i].switchPanningModelToHRTF();
                i++;
            }
        }
    }

    public function switchPanningModelToEqualPower() {
        if (Ts2Hx.isTrue(this._scene.getEngine().audioEngine.canUseWebAudio)) {
            var i:Int = 0;
            while (i < this.soundCollection.length) {
                this.soundCollection[i].switchPanningModelToEqualPower();
                i++;
            }
        }
    }

    public function connectToAnalyser(analyser:Analyser) {
        if (Ts2Hx.isTrue(this._connectedAnalyser)) {
            this._connectedAnalyser.stopDebugCanvas();
        }
        this._connectedAnalyser = analyser;
        if (Ts2Hx.isTrue(this._scene.getEngine().audioEngine.canUseWebAudio)) {
            this._outputAudioNode.disconnect();
            this._connectedAnalyser.connectAudioNodes(this._outputAudioNode, this._scene.getEngine().audioEngine.masterGain);
        }
    }

}
