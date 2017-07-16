package com.babylonhx.audio;

import com.babylonhx.tools.Ts2Hx;
import com.babylonhx.audio.AudioEngine;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;

import lime.utils.ArrayBuffer;
import lime.utils.Float32Array;
import lime.utils.Int32Array;
import lime.utils.UInt8Array;

#if (js || purejs)
import js.html.audio.*;
import js.html.AudioElement;
import js.html.CanvasRenderingContext2D;
import js.html.CanvasElement;
import js.html.Document;
#end


@:expose('BABYLON.Analyser') class Analyser {
    public var SMOOTHING:Float = 0.75;
    public var FFT_SIZE:Int = 512;
    public var BARGRAPHAMPLITUDE:Int = 256;
    public var DEBUGCANVASPOS = {
        x: 20,
        y: 20
    };

    public var DEBUGCANVASSIZE = {
        width: 320,
        height: 200
    };

    private var _byteFreqs:UInt8Array;
    private var _byteTime:UInt8Array;
    private var _floatFreqs:Float32Array;
    private var _webAudioAnalyser:AnalyserNode;
    private var _debugCanvas:Dynamic;
    private var _debugCanvasContext:CanvasRenderingContext2D;
    private var _scene:Scene;
    private var _registerFunc:Dynamic;
    private var _audioEngine:AudioEngine;

    public function new(scene:Scene) {
        this._scene = scene;
        this._audioEngine = scene.getEngine().audioEngine;
        if (Ts2Hx.isTrue(this._audioEngine.canUseWebAudio)) {
            this._webAudioAnalyser = this._audioEngine.audioContext.createAnalyser();
            this._webAudioAnalyser.minDecibels = -140;
            this._webAudioAnalyser.maxDecibels = 0;
            this._byteFreqs = new UInt8Array(this._webAudioAnalyser.frequencyBinCount);
            this._byteTime = new UInt8Array(this._webAudioAnalyser.frequencyBinCount);
            this._floatFreqs = new Float32Array(this._webAudioAnalyser.frequencyBinCount);
        }
    }

    public function getFrequencyBinCount():Float {
        if (Ts2Hx.isTrue(this._audioEngine.canUseWebAudio)) {
            return this._webAudioAnalyser.frequencyBinCount;
        } else {
            return 0;
        }
    }

    public function getByteFrequencyData():UInt8Array {
        if (Ts2Hx.isTrue(this._audioEngine.canUseWebAudio)) {
            this._webAudioAnalyser.smoothingTimeConstant = this.SMOOTHING;
            this._webAudioAnalyser.fftSize = this.FFT_SIZE;
            this._webAudioAnalyser.getByteFrequencyData(this._byteFreqs);
        }
        return this._byteFreqs;
    }

    public function getByteTimeDomainData():UInt8Array {
        if (Ts2Hx.isTrue(this._audioEngine.canUseWebAudio)) {
            this._webAudioAnalyser.smoothingTimeConstant = this.SMOOTHING;
            this._webAudioAnalyser.fftSize = this.FFT_SIZE;
            this._webAudioAnalyser.getByteTimeDomainData(this._byteTime);
        }
        return this._byteTime;
    }

    public function getFloatFrequencyData():Float32Array {
        if (Ts2Hx.isTrue(this._audioEngine.canUseWebAudio)) {
            this._webAudioAnalyser.smoothingTimeConstant = this.SMOOTHING;
            this._webAudioAnalyser.fftSize = this.FFT_SIZE;
            this._webAudioAnalyser.getFloatFrequencyData(this._floatFreqs);
        }
        return this._floatFreqs;
    }

    public function drawDebugCanvas() {
        var __this = this;
        if (Ts2Hx.isTrue(this._audioEngine.canUseWebAudio)) {
            if (!Ts2Hx.isTrue(this._debugCanvas)) {
                this._debugCanvas = js.Browser.window.document.createElement("canvas");
                this._debugCanvas.width = this.DEBUGCANVASSIZE.width;
                this._debugCanvas.height = this.DEBUGCANVASSIZE.height;
                this._debugCanvas.style.position = "absolute";
                this._debugCanvas.style.top = this.DEBUGCANVASPOS.y + "px";
                this._debugCanvas.style.left = this.DEBUGCANVASPOS.x + "px";
                this._debugCanvasContext = this._debugCanvas.getContext("2d");
                js.Browser.window.document.body.appendChild(this._debugCanvas);
                this._registerFunc = function() {
                    __this.drawDebugCanvas();
                };
                this._scene.registerBeforeRender(this._registerFunc);
            }
            if (Ts2Hx.isTrue(this._registerFunc)) {
                var workingArray = this.getByteFrequencyData();
                this._debugCanvasContext.fillStyle = 'rgb(0, 0, 0)';
                this._debugCanvasContext.fillRect(0, 0, this.DEBUGCANVASSIZE.width, this.DEBUGCANVASSIZE.height);
                var i:Int = 0;
                while (i < this.getFrequencyBinCount()) {
                    var value = workingArray[i];
                    var percent = value / this.BARGRAPHAMPLITUDE;
                    var height = this.DEBUGCANVASSIZE.height * percent;
                    var offset = this.DEBUGCANVASSIZE.height - height - 1;
                    var barWidth = this.DEBUGCANVASSIZE.width / this.getFrequencyBinCount();
                    var hue = i / this.getFrequencyBinCount() * 360;
                    this._debugCanvasContext.fillStyle = 'hsl(' + hue + ', 100%, 50%)';
                    this._debugCanvasContext.fillRect(i * barWidth, offset, barWidth, height);
                    i++;
                }
            }
        }
    }

    public function stopDebugCanvas() {
        if (Ts2Hx.isTrue(this._debugCanvas)) {
            this._scene.unregisterBeforeRender(this._registerFunc);
            this._registerFunc = null;
            js.Browser.window.document.body.removeChild(this._debugCanvas);
            this._debugCanvas = null;
            this._debugCanvasContext = null;
        }
    }

    public function connectAudioNodes(inputAudioNode:AudioNode, outputAudioNode:AudioNode) {
        if (Ts2Hx.isTrue(this._audioEngine.canUseWebAudio)) {
            inputAudioNode.connect(this._webAudioAnalyser);
            this._webAudioAnalyser.connect(outputAudioNode);
        }
    }

    public function dispose() {
        if (Ts2Hx.isTrue(this._audioEngine.canUseWebAudio)) {
            this._webAudioAnalyser.disconnect();
        }
    }

}

