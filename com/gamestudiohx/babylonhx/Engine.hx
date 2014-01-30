package com.gamestudiohx.babylonhx;

import com.gamestudiohx.babylonhx.cameras.Camera;
import com.gamestudiohx.babylonhx.Engine.BabylonCaps;
import com.gamestudiohx.babylonhx.materials.Effect;
import com.gamestudiohx.babylonhx.mesh.VertexBuffer;
import com.gamestudiohx.babylonhx.mesh.Mesh.BabylonGLBuffer;
import com.gamestudiohx.babylonhx.postprocess.PostProcess;
import com.gamestudiohx.babylonhx.tools.math.Color3;
import com.gamestudiohx.babylonhx.tools.math.Color4;
import com.gamestudiohx.babylonhx.tools.math.Matrix;
import com.gamestudiohx.babylonhx.tools.math.Plane;
import com.gamestudiohx.babylonhx.tools.Tools;
import com.gamestudiohx.babylonhx.materials.textures.Texture;
import com.gamestudiohx.babylonhx.materials.textures.CubeTexture;
import com.gamestudiohx.babylonhx.tools.math.Viewport;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Rectangle;
import flash.Lib;
import flash.system.Capabilities;
import flash.utils.ByteArray;
import openfl.Assets;
import openfl.display.OpenGLView;
import openfl.gl.GL;
import openfl.gl.GLBuffer;
import openfl.gl.GLFramebuffer;
import openfl.gl.GLProgram;
import openfl.gl.GLRenderbuffer;
import openfl.gl.GLShader;
import openfl.gl.GLUniformLocation;
import openfl.utils.ArrayBufferView;
import openfl.utils.Float32Array;
import openfl.utils.Int16Array;
import openfl.utils.Int32Array;
import openfl.utils.UInt8Array;
#if cpp
import sys.io.File;
#end

/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

typedef BabylonState = {
	culling: Null<Dynamic>
}

typedef BabylonCaps = {
	maxTexturesImageUnits: Null<Dynamic>,
	maxTextureSize: Null<Dynamic>,
	maxCubemapTextureSize: Null<Dynamic>,
	maxRenderTextureSize: Null<Dynamic>,
	standardDerivatives: Null<Dynamic>,
	textureFloat: Null<Dynamic>,
	textureAnisotropicFilterExtension: Null<Dynamic>,
	maxAnisotropy: Null<Dynamic>	
}
 
class Engine {
	
	// GLOBAL var ...
	public static var clipPlane:Plane = null;
	
	// Statics
    public static var ShadersRepository:String = "assets/shaders/";

    public static var ALPHA_DISABLE:Int = 0;
    public static var ALPHA_ADD:Int = 1;
    public static var ALPHA_COMBINE:Int = 2;
    
    public static var DELAYLOADSTATE_NONE:Int = 0;
    public static var DELAYLOADSTATE_LOADED:Int = 1;
    public static var DELAYLOADSTATE_LOADING:Int = 2;
    public static var DELAYLOADSTATE_NOTLOADED:Int = 4;

    public static var epsilon:Float = 0.001;
    public static var collisionsEpsilon:Float = 0.001;
	
	public var forceWireframe:Bool;
	public var cullBackFaces:Bool;
	
	public var scenes:Array<Scene>;
	
	public var _hardwareScalingLevel:Int;
	public var _aspectRatio:Float;
	public var _cachedViewport:Viewport;
	
	public var _caps:BabylonCaps;
	
	public var _alphaTest:Bool;
	
	public var _runningLoop:Bool;
	
	public var _loadedTexturesCache:Array<BabylonTexture>;
	public var _activeTexturesCache:Array<Texture>;
	
	public var _currentEffect:Effect;
	public var _currentState:BabylonState;
	public var _compiledEffects:Map<String, Effect>;
	public var _cachedEffectForVertexBuffers:Effect;
	public var _cachedVertexBuffers:Dynamic;  
	public var _cachedIndexBuffer:BabylonGLBuffer;
	
	public var _renderingCanvas:Sprite;
	
	public var isFullscreen:Bool;
	public var isPointerLock:Bool;
	
	public var _renderFunction:Rectangle->Void;
	public var _workingCanvas:BitmapData;
	public var _workingContext:OpenGLView;
		

	public function new(canvas:Sprite, antialias:Bool) {
		this._renderingCanvas = canvas;
		
		if (!OpenGLView.isSupported) {
			throw("GL not supported");
		}

        // Options
        this.forceWireframe = false;
        this.cullBackFaces = true;

        // Scenes
        this.scenes = [];
		
		this._runningLoop = false;

        // Textures
        this._workingContext = new OpenGLView();
		canvas.addChild(this._workingContext);
		
        // Viewport
        this._hardwareScalingLevel = Std.int(1.0 / (Capabilities.pixelAspectRatio));
        this.resize();

        // Caps
        this._caps = {
			maxTexturesImageUnits: null,
			maxTextureSize: null,
			maxCubemapTextureSize: null,
			maxRenderTextureSize: null,
			standardDerivatives: null,
			textureFloat: null,
			textureAnisotropicFilterExtension: null,
			maxAnisotropy: null
		};
        this._caps.maxTexturesImageUnits = GL.getParameter(GL.MAX_TEXTURE_IMAGE_UNITS);
		
        this._caps.maxTextureSize = GL.getParameter(GL.MAX_TEXTURE_SIZE);
		
        this._caps.maxCubemapTextureSize = GL.getParameter(GL.MAX_CUBE_MAP_TEXTURE_SIZE);
		
		// TODO - this fails on desktops
        this._caps.maxRenderTextureSize = 8192;// GL.getParameter(GL.MAX_RENDERBUFFER_SIZE);
		

        // Extensions
        this._caps.standardDerivatives = GL.getExtension('OES_standard_derivatives') != null;		
        this._caps.textureFloat = GL.getExtension('OES_texture_float') != null;  
		
		// TODO - this fails on desktops
		function get_EXT_texture_filter_anisotropic():Dynamic {				
			if (GL.getExtension('EXT_texture_filter_anisotropic') != null) {
				return GL.getExtension('EXT_texture_filter_anisotropic');
			}
			if (GL.getExtension('GL_EXT_texture_filter_anisotropic') != null) {
				return GL.getExtension('GL_EXT_texture_filter_anisotropic');
			}
			if (GL.getExtension('WEBKIT_EXT_texture_filter_anisotropic') != null) {
				return GL.getExtension('WEBKIT_EXT_texture_filter_anisotropic');
			}
			if (GL.getExtension('MOZ_EXT_texture_filter_anisotropic') != null) {
				return GL.getExtension('MOZ_EXT_texture_filter_anisotropic');
			}	
			return null;
		}		
		
		this._caps.textureAnisotropicFilterExtension = get_EXT_texture_filter_anisotropic();
		
        this._caps.maxAnisotropy = this._caps.textureAnisotropicFilterExtension != null ? GL.getParameter(this._caps.textureAnisotropicFilterExtension.MAX_TEXTURE_MAX_ANISOTROPY_EXT) : 1;
				
        // Cache
        this._loadedTexturesCache = [];
        this._activeTexturesCache = [];
        this._currentEffect = null;
        this._currentState = {
            culling: null
        };

        this._compiledEffects = new Map();

		GL.enable(GL.DEPTH_TEST);
        GL.depthFunc(GL.LEQUAL);
		
        // Fullscreen
        this.isFullscreen = false;
        
		// TODO - remove
        /*var onFullscreenChange = function () {
            if (document.fullscreen !== undefined) {
                that.isFullscreen = document.fullscreen;
            } else if (document.mozFullScreen !== undefined) {
                that.isFullscreen = document.mozFullScreen;
            } else if (document.webkitIsFullScreen !== undefined) {
                that.isFullscreen = document.webkitIsFullScreen;
            } else if (document.msIsFullScreen !== undefined) {
                that.isFullscreen = document.msIsFullScreen;
            }

            // Pointer lock
            if (that.isFullscreen && that._pointerLockRequested) {
                canvas.requestPointerLock = canvas.requestPointerLock ||
                                            canvas.msRequestPointerLock ||
                                            canvas.mozRequestPointerLock ||
                                            canvas.webkitRequestPointerLock;

                if (canvas.requestPointerLock) {
                    canvas.requestPointerLock();
                }
            }
        };

        document.addEventListener("fullscreenchange", onFullscreenChange, false);
        document.addEventListener("mozfullscreenchange", onFullscreenChange, false);
        document.addEventListener("webkitfullscreenchange", onFullscreenChange, false);
        document.addEventListener("msfullscreenchange", onFullscreenChange, false);*/

        // Pointer lock
        this.isPointerLock = false;

		// TODO - remove this
        /*var onPointerLockChange = function () {
            that.isPointerLock = (document.mozPointerLockElement === canvas ||
                                  document.webkitPointerLockElement === canvas ||
                                  document.msPointerLockElement === canvas ||
                                  document.pointerLockElement === canvas
            );
        };

        document.addEventListener("pointerlockchange", onPointerLockChange, false);
        document.addEventListener("mspointerlockchange", onPointerLockChange, false);
        document.addEventListener("mozpointerlockchange", onPointerLockChange, false);
        document.addEventListener("webkitpointerlockchange", onPointerLockChange, false);*/
	}
	
	// Properties
    public function getAspectRatio(camera:Camera):Float {
        return this._aspectRatio;
		// TODO - what is this ??
		//var viewport = camera.viewport;
        //return (this.getRenderWidth() * viewport.width) / (this.getRenderWidth() * viewport.height);
    }

    public function getRenderWidth():Int {
        //return this._renderingCanvas.width;
		return cast Lib.current.stage.stageWidth;
    }

    public function getRenderHeight():Int {
        //return this._renderingCanvas.height;
		return cast Lib.current.stage.stageHeight;
    }

    public function getRenderingCanvas():Sprite {
        return this._renderingCanvas;
    }

    public function setHardwareScalingLevel(level:Int) {
        this._hardwareScalingLevel = level;
        this.resize();
    }

    public function getHardwareScalingLevel():Int {
        return this._hardwareScalingLevel;
    }

    public function getLoadedTexturesCache():Array<BabylonTexture> {
        return this._loadedTexturesCache;
    }

    public function getCaps():BabylonCaps {
        return this._caps;
    }
	
	
	// Methods
    public function stopRenderLoop() {
        this._renderFunction = null;
        this._runningLoop = false;
    }

    public function _renderLoop(rect:Rectangle = null) {
        // Start new frame
        this.beginFrame();

        if (this._renderFunction != null) {
            this._renderFunction(new Rectangle());			
        }

        // Present
        this.endFrame();
    }

    public function runRenderLoop(renderFunction:Rectangle->Void) {
        this._runningLoop = true;
        this._renderFunction = renderFunction;		
		this._workingContext.render = this._renderLoop;
    }

    public function switchFullscreen(requestPointerLock) {
		// TODO
        /*if (this.isFullscreen) {
            BABYLON.Tools.ExitFullscreen();
        } else {
            this._pointerLockRequested = requestPointerLock;
            BABYLON.Tools.RequestFullscreen(this._renderingCanvas);
        }*/
    }

	// color can be Color4 or Color3
    public function clear(color:Dynamic, backBuffer:Bool, depthStencil:Bool) {
		if(Std.is(color, Color4)) {
			GL.clearColor(color.r, color.g, color.b, color.a);
		} else {
			GL.clearColor(color.r, color.g, color.b, 1.0);
		}
        GL.clearDepth(1.0);
        var mode:Int = 0;

        if (backBuffer)
            mode |= GL.COLOR_BUFFER_BIT;

        if (depthStencil)
            mode |= GL.DEPTH_BUFFER_BIT;

        GL.clear(mode);
    }
    
    public function setViewport(viewport:Viewport, requiredWidth:Float = 0, requiredHeight:Float = 0) {
        var width = requiredWidth == 0 ? getRenderWidth() : requiredWidth;
        var height = requiredHeight == 0 ? getRenderHeight() : requiredHeight;
		
        var x = viewport.x;
        var y = viewport.y;
        
        this._cachedViewport = viewport;
		
        GL.viewport(Std.int(x * width), Std.int(y * height), Std.int(width * viewport.width), Std.int(height * viewport.height));
        this._aspectRatio = (width * viewport.width) / (height * viewport.height);
    }
    
    public function setDirectViewport(x:Float, y:Float, width:Float, height:Float) {
        this._cachedViewport = null;

        GL.viewport(cast x, cast y, cast width, cast height);
        this._aspectRatio = width / height;
    }

    public function beginFrame() {
		Tools._MeasureFps();
    }

    public function endFrame() {
        this.flushFramebuffer();
    }

    public function resize() {
		// This is handled by OpenFL
        //this._renderingCanvas.width = this._renderingCanvas.clientWidth / this._hardwareScalingLevel;
        //this._renderingCanvas.height = this._renderingCanvas.clientHeight / this._hardwareScalingLevel;        
    }

    public function bindFramebuffer(texture:BabylonTexture) {
        GL.bindFramebuffer(GL.FRAMEBUFFER, texture._framebuffer);
        GL.viewport(0, 0, Std.int(texture._width), Std.int(texture._height));
        this._aspectRatio = texture._width / texture._height;

        this.wipeCaches();
    }

    public function unBindFramebuffer(texture:BabylonTexture) {
        if (texture.generateMipMaps) {
            GL.bindTexture(GL.TEXTURE_2D, texture.data);
            GL.generateMipmap(GL.TEXTURE_2D);
            GL.bindTexture(GL.TEXTURE_2D, null);
        }
    }

    inline public function flushFramebuffer() {
        GL.flush();
    }

    public function restoreDefaultFramebuffer() {
        GL.bindFramebuffer(GL.FRAMEBUFFER, null);
        this.setViewport(this._cachedViewport);
        this.wipeCaches();
    }
	
	// VBOs
    public function createVertexBuffer(vertices:Array<Float>):BabylonGLBuffer {
        var vbo = GL.createBuffer();
        GL.bindBuffer(GL.ARRAY_BUFFER, vbo);
        GL.bufferData(GL.ARRAY_BUFFER, new Float32Array(vertices), GL.STATIC_DRAW);
        GL.bindBuffer(GL.ARRAY_BUFFER, null);
        return new BabylonGLBuffer(vbo);
    }

    public function createDynamicVertexBuffer(capacity:Int):BabylonGLBuffer {
        var vbo = GL.createBuffer();
        GL.bindBuffer(GL.ARRAY_BUFFER, vbo);
        GL.bufferData(GL.ARRAY_BUFFER, new Float32Array(capacity), GL.DYNAMIC_DRAW);
        GL.bindBuffer(GL.ARRAY_BUFFER, null);
        return new BabylonGLBuffer(vbo);
    }

    inline public function updateDynamicVertexBuffer(vertexBuffer:BabylonGLBuffer, vertices:Dynamic, length:Int = 0) {
        GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer.buffer);
        // Should be (vertices instanceof Float32Array ? vertices : new Float32Array(vertices)) but Chrome raises an Exception in this case :(
        if (length != 0) {
            GL.bufferSubData(GL.ARRAY_BUFFER, 0, new Float32Array(cast vertices, 0, length));
        } else {
            GL.bufferSubData(GL.ARRAY_BUFFER, 0, new Float32Array(vertices));
        }
        
        GL.bindBuffer(GL.ARRAY_BUFFER, null);
    }

    public function createIndexBuffer(indices:Array<Int>):BabylonGLBuffer {
        var vbo = GL.createBuffer();
        GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, vbo);
        GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, new Int16Array(indices), GL.STATIC_DRAW);
        GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, null);
        return new BabylonGLBuffer(vbo);
    }

    public function bindBuffers(vertexBuffer:BabylonGLBuffer, indexBuffer:BabylonGLBuffer, vertexDeclaration:Array<Int>, vertexStrideSize:Int, effect:Effect) {
        if (this._cachedVertexBuffers != vertexBuffer || this._cachedEffectForVertexBuffers != effect) {
            this._cachedVertexBuffers = vertexBuffer;
            this._cachedEffectForVertexBuffers = effect;
			
            GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer.buffer);
			
            var offset:Int = 0;
            for (index in 0...vertexDeclaration.length) {
                var order:Int = effect.getAttribute(index);

                if (order >= 0) {
                    GL.vertexAttribPointer(order, vertexDeclaration[index], GL.FLOAT, false, vertexStrideSize, offset);
                }
                offset += vertexDeclaration[index] * 4;
            }
        }

        if (this._cachedIndexBuffer != indexBuffer) {
            this._cachedIndexBuffer = indexBuffer;
            GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexBuffer.buffer);
        }
    }

    public function bindMultiBuffers(vertexBuffers:Map<String, VertexBuffer>, indexBuffer:BabylonGLBuffer, effect:Effect) {
        if (this._cachedVertexBuffers != vertexBuffers || this._cachedEffectForVertexBuffers != effect) {
            this._cachedVertexBuffers = vertexBuffers;
            this._cachedEffectForVertexBuffers = effect;

            var attributes:Array<String> = effect.getAttributesNames();
			
            for (index in 0...attributes.length) {
                var order:Int = effect.getAttribute(index);

                if (order >= 0) {
                    var vertexBuffer:VertexBuffer = vertexBuffers.get(attributes[index]);
                    var stride:Int = vertexBuffer.getStrideSize();
                    GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer._buffer.buffer);					
                    GL.vertexAttribPointer(order, stride, GL.FLOAT, false, stride * 4, 0);
                }
            }
        }

        if (this._cachedIndexBuffer != indexBuffer) {
            this._cachedIndexBuffer = indexBuffer;
            GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexBuffer.buffer);
        }
    }

    public function _releaseBuffer(buffer:BabylonGLBuffer) {
        buffer.references--;

        if (buffer.references == 0) {
            GL.deleteBuffer(buffer.buffer);
        }
    }

    public function draw(useTriangles:Bool, indexStart:Int, indexCount:Int) {
        GL.drawElements(useTriangles ? GL.TRIANGLES : GL.LINES, indexCount, GL.UNSIGNED_SHORT, indexStart * 2);
    }
	
	
	// Shaders
    public function createEffect(baseName:Dynamic, attributesNames:Array<String>, uniformsNames:Array<String>, samplers:Array<String>, defines:String, optionalDefines:Array<String> = null):Effect {
        var vertex = Reflect.field(baseName, "vertex") != null ? baseName.vertex : baseName;
        var fragment = Reflect.field(baseName, "fragment") != null ? baseName.fragment : baseName;
		        
        var name = vertex + "+" + fragment + "@" + defines;
        if (this._compiledEffects.exists(name)) {
            return this._compiledEffects.get(name);
        }

        var effect = new Effect(baseName, attributesNames, uniformsNames, samplers, this, defines, optionalDefines);
        this._compiledEffects.set(name, effect);

        return effect;
    }

    public function compileShader(source:String, type:String, ?defines:String):GLShader {
        var shader:GLShader = GL.createShader(type == "vertex" ? GL.VERTEX_SHADER : GL.FRAGMENT_SHADER);
		
        GL.shaderSource(shader, (defines != null ? defines + "\n" : "") + source);
        GL.compileShader(shader);

        if (GL.getShaderParameter(shader, GL.COMPILE_STATUS) == 0) {
            throw(GL.getShaderInfoLog(shader));
        }
        return shader;
    }

    public function createShaderProgram(vertexCode:String, fragmentCode:String, defines:String):GLProgram {					
        var vertexShader = compileShader(vertexCode, "vertex", defines);
        var fragmentShader = compileShader(fragmentCode, "fragment", defines);

        var shaderProgram = GL.createProgram();
        GL.attachShader(shaderProgram, vertexShader);
        GL.attachShader(shaderProgram, fragmentShader);

        GL.linkProgram(shaderProgram);

        var error:String = GL.getProgramInfoLog(shaderProgram);
        if (error != "") {
            throw(error);
        }

        GL.deleteShader(vertexShader);
        GL.deleteShader(fragmentShader);

        return shaderProgram;
    }

    public function getUniforms(shaderProgram:GLProgram, uniformsNames:Array<String>):Array<GLUniformLocation> {
        var results:Array<GLUniformLocation> = [];

        for (index in 0...uniformsNames.length) {
            results.push(GL.getUniformLocation(shaderProgram, uniformsNames[index]));
        }

        return results;
    }

    public function getAttributes(shaderProgram:GLProgram, attributesNames:Array<String>):Array<Int> {
        var results:Array<Int> = [];

        for (index in 0...attributesNames.length) {
            try {
				results.push(GL.getAttribLocation(shaderProgram, attributesNames[index]));
            } catch (e:Dynamic) {
				trace("getAttributes() -> ERROR: " + e);
                results.push(-1);
            }
        }

        return results;
    }

    public function enableEffect(effect:Effect) {
		
        if (effect == null || effect.getAttributesCount() == 0 || this._currentEffect == effect) {
            return;
        }
		
        // Use program
        GL.useProgram(effect.getProgram());
		
        for (index in 0...effect.getAttributesCount()) {
            // Attributes
            var order:Int = effect.getAttribute(index);
            if (order >= 0) {
                GL.enableVertexAttribArray(effect.getAttribute(index));
            }
        }

        this._currentEffect = effect;
    }

    inline public function setMatrices(uniform:GLUniformLocation = null, matrices:Array<Float> /*Float32Array*/) {
        if (uniform != null) {
			GL.uniformMatrix4fv(uniform, false, new Float32Array(matrices));
		}
    }

    inline public function setMatrix(uniform:GLUniformLocation = null, matrix:Matrix) {
        if (uniform != null) {
			GL.uniformMatrix4fv(uniform, false, new Float32Array(matrix.toArray()));
		}
    }
    
    inline public function setFloat(uniform:GLUniformLocation = null, value:Float) {
        if (uniform != null) {
			GL.uniform1f(uniform, value);
		}
    }

    inline public function setFloat2(uniform:GLUniformLocation = null, x:Float, y:Float) {
        if (uniform != null) {
			GL.uniform2f(uniform, x, y);
		}
    }

    inline public function setFloat3(uniform:GLUniformLocation = null, x:Float, y:Float, z:Float) {
        if (uniform != null) {
			GL.uniform3f(uniform, x, y, z);
		}
    }
    
    inline public function setBool(uniform:GLUniformLocation = null, bool:Bool) {
        if (uniform != null) {
			GL.uniform1i(uniform, bool ? 1 : 0);
		}
    }

    inline public function setFloat4(uniform:GLUniformLocation = null, x:Float, y:Float, z:Float, w:Float) {
        if (uniform != null) {
			GL.uniform4f(uniform, x, y, z, w);
		}
    }

    inline public function setColor3(uniform:GLUniformLocation = null, color3:Color3) {
        if (uniform != null) {
			GL.uniform3f(uniform, color3.r, color3.g, color3.b);
		}
    }

    inline public function setColor4(uniform:GLUniformLocation = null, color3:Color3, alpha:Float) {
        if (uniform != null) {
			GL.uniform4f(uniform, color3.r, color3.g, color3.b, alpha);
		}
    }
	
	
	// States
    public function setState(culling:Bool) {
        // Culling 
        if (this._currentState.culling != culling) {
            if (culling) {
                GL.cullFace(this.cullBackFaces ? GL.BACK : GL.FRONT);
				GL.enable(GL.CULL_FACE);
            } else {
				GL.disable(GL.CULL_FACE);
            }

            this._currentState.culling = culling;
        }
    }

    public function setDepthBuffer(enable:Bool) {
        if (enable) {
			GL.enable(GL.DEPTH_TEST);
        } else {
			GL.disable(GL.DEPTH_TEST);
        }
    }

    public function setDepthWrite(enable:Bool) {
        GL.depthMask(enable);
    }

    public function setColorWrite(enable:Bool) {
        GL.colorMask(enable, enable, enable, enable);
    }

    public function setAlphaMode(mode:Int) {
        switch (mode) {
            case Engine.ALPHA_DISABLE:
                this.setDepthWrite(true);
                GL.disable(GL.BLEND);
				
            case Engine.ALPHA_COMBINE:
                this.setDepthWrite(false);
                GL.blendFuncSeparate(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA, GL.ZERO, GL.ONE);
				GL.enable(GL.BLEND);
                
            case Engine.ALPHA_ADD:
                this.setDepthWrite(false);
                GL.blendFuncSeparate(GL.ONE, GL.ONE, GL.ZERO, GL.ONE);
				GL.enable(GL.BLEND);
                
        }
    }

    public function setAlphaTesting(enable:Bool) {
        this._alphaTest = enable;
    }

    public function getAlphaTesting():Bool {
        return this._alphaTest;
    }

    // Textures
    public function wipeCaches() {
        this._activeTexturesCache = [];
        this._currentEffect = null;
        this._currentState = {
            culling: null
        };

        this._cachedVertexBuffers = null;
        this._cachedEffectForVertexBuffers = null;
    }

	function getExponantOfTwo(value:Int, max:Int):Int {
        var count:Int = 1;

        do {
            count *= 2;
        } while (count < value);

        if (count > max)
            count = max;

        return count;
    }
	
	function getScaled(source:BitmapData, newWidth:Int, newHeight:Int):BitmapData {
		var m:flash.geom.Matrix = new flash.geom.Matrix();
		m.scale(newWidth / source.width, newHeight / source.height);
		var bmp:BitmapData = new BitmapData(newWidth, newHeight, true);
		bmp.draw(source, m);
		return bmp;
	}

    public function createTexture(url:String, ?noMipmap:Bool, ?invertY:Int, scene:Scene = null):BabylonTexture {		
        var texture:BabylonTexture = new BabylonTexture(url, GL.createTexture());
		            
        function onload(img:BitmapData) {
            var potWidth = getExponantOfTwo(img.width, this._caps.maxTextureSize);
            var potHeight = getExponantOfTwo(img.height, this._caps.maxTextureSize);
            var isPot = (img.width == potWidth && img.height == potHeight);
			this._workingCanvas = img;

            if (!isPot) {
                this._workingCanvas = getScaled(img, Std.int(potWidth/2), Std.int(potHeight/2));
            }
												
			#if html5
			var pixelData = this._workingCanvas.getPixels(this._workingCanvas.rect).byteView;
			#else
			var pixelData = new UInt8Array(BitmapData.getRGBAPixels(this._workingCanvas));
			#end
			
						
            GL.bindTexture(GL.TEXTURE_2D, texture.data);
			
			// IMAGE FLIPPING IS DISABLED AS IT IS ONLY SUPPORTED IN WebGL
			/*#if html5
            GL.pixelStorei(GL.UNPACK_FLIP_Y_WEBGL, invertY != null ? 1 : 0);
			#end*/
						
			GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, this._workingCanvas.width, this._workingCanvas.height, 0, GL.RGBA, GL.UNSIGNED_BYTE, pixelData);
            GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);

            if (noMipmap != null && noMipmap == true) {
                GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
            } else {
                GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR_MIPMAP_LINEAR);
                GL.generateMipmap(GL.TEXTURE_2D);
            }
            GL.bindTexture(GL.TEXTURE_2D, null);
			
            this._activeTexturesCache = [];
            texture._baseWidth = img.width;
            texture._baseHeight = img.height;
            texture._width = potWidth;
            texture._height = potHeight;
            texture.isReady = true;
            scene._removePendingData(texture);
        }

        scene._addPendingData(texture);
        Tools.LoadImage(url, onload);

        texture.url = url;
        texture.noMipmap = noMipmap;
        texture.references = 1;
        this._loadedTexturesCache.push(texture);

        return texture;
    }

    public function createDynamicTexture(width:Float, height:Float, generateMipMaps:Bool):BabylonTexture {
        var texture:BabylonTexture = new BabylonTexture("", GL.createTexture());

        width = getExponantOfTwo(Std.int(width), this._caps.maxTextureSize);
        height = getExponantOfTwo(Std.int(height), this._caps.maxTextureSize);

        GL.bindTexture(GL.TEXTURE_2D, texture.data);
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);

        if (!generateMipMaps) {
            GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
        } else {
            GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR_MIPMAP_LINEAR);
        }
        GL.bindTexture(GL.TEXTURE_2D, null);

        this._activeTexturesCache = [];
        texture._baseWidth = Std.int(width);
        texture._baseHeight = Std.int(height);
        texture._width = width;
        texture._height = height;
        texture.isReady = false;
        texture.generateMipMaps = generateMipMaps;
        texture.references = 1;

        this._loadedTexturesCache.push(texture);

        return texture;
    }

    public function updateDynamicTexture(texture:BabylonTexture, canvas:BitmapData, invertY:Int) {
        GL.bindTexture(GL.TEXTURE_2D, texture.data);
		/*#if html5
        GL.pixelStorei(GL.UNPACK_FLIP_Y_WEBGL, invertY);
		#end*/
		
		#if html5
		var pixelData = canvas.getPixels(canvas.rect).byteView;
		#else
		var pixelData = new UInt8Array(BitmapData.getRGBAPixels(canvas));
		#end
		
		GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, canvas.width, canvas.height, 0, GL.RGBA, GL.UNSIGNED_BYTE, cast pixelData);
        if (texture.generateMipMaps) {
            GL.generateMipmap(GL.TEXTURE_2D);
        }
        GL.bindTexture(GL.TEXTURE_2D, null);
        this._activeTexturesCache = [];
        texture.isReady = true;
    }

    public function updateVideoTexture(texture:BabylonTexture, video:Dynamic) {
		// TODO
        /*GL.bindTexture(GL.TEXTURE_2D, texture.data);
        GL.pixelStorei(GL.UNPACK_FLIP_Y_WEBGL, false);

        // Scale the video if it is a NPOT
        if (video.videoWidth !== texture._width || video.videoHeight !== texture._height) {
            if (!texture._workingCanvas) {
                texture._workingCanvas = document.createElement("canvas");
                texture._workingContext = texture._workingCanvas.getContext("2d");
                texture._workingCanvas.width = texture._width;
                texture._workingCanvas.height = texture._height;
            }

            texture._workingContext.drawImage(video, 0, 0, video.videoWidth, video.videoHeight, 0, 0, texture._width, texture._height);

            GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, GL.RGBA, GL.UNSIGNED_BYTE, texture._workingCanvas);
        } else {
            GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, GL.RGBA, GL.UNSIGNED_BYTE, video);
        }

        if (texture.generateMipMaps) {
            GL.generateMipmap(GL.TEXTURE_2D);
        }

        GL.bindTexture(GL.TEXTURE_2D, null);
        this._activeTexturesCache = [];
        texture.isReady = true;*/
    }

    public function createRenderTargetTexture(size:Dynamic, options:Dynamic):BabylonTexture {
        // old version had a "generateMipMaps" arg instead of options.
        // if options.generateMipMaps is undefined, consider that options itself if the generateMipmaps value
        // in the same way, generateDepthBuffer is defaulted to true
        var generateMipMaps = false;
        var generateDepthBuffer = true;
        var samplingMode = Texture.TRILINEAR_SAMPLINGMODE;
        if (options != null) {
            generateMipMaps = Reflect.field(options, "generateMipMaps") != null ? options.generateMipmaps : options;
            generateDepthBuffer = Reflect.field(options, "generateDepthBuffer") != null ? options.generateDepthBuffer : true;
            if (Reflect.field(options, "samplingMode") != null) {
                samplingMode = options.samplingMode;
            }
        }
		
        var texture:BabylonTexture = new BabylonTexture("", GL.createTexture());
        GL.bindTexture(GL.TEXTURE_2D, texture.data);

        var width:Int = Reflect.field(size, "width") != null ? size.width : size;
        var height:Int = Reflect.field(size, "height") != null ? size.height : size;
        var magFilter = GL.NEAREST;
        var minFilter = GL.NEAREST;
        if (samplingMode == Texture.BILINEAR_SAMPLINGMODE) {
            magFilter = GL.LINEAR;
            if (generateMipMaps) {
                minFilter = GL.LINEAR_MIPMAP_NEAREST;
            } else {
                minFilter = GL.LINEAR;
            }
        } else if (samplingMode == Texture.TRILINEAR_SAMPLINGMODE) {
            magFilter = GL.LINEAR;
            if (generateMipMaps) {
                minFilter = GL.LINEAR_MIPMAP_LINEAR;
            } else {
                minFilter = GL.LINEAR;
            }
        }
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, magFilter);
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, minFilter);
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
        GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, width, height, 0, GL.RGBA, GL.UNSIGNED_BYTE, null);

        var depthBuffer:GLRenderbuffer = null;
        // Create the depth buffer
        if (generateDepthBuffer) {
            depthBuffer = GL.createRenderbuffer();
            GL.bindRenderbuffer(GL.RENDERBUFFER, depthBuffer);
            GL.renderbufferStorage(GL.RENDERBUFFER, GL.DEPTH_COMPONENT16, width, height);
        }
        // Create the framebuffer
        var framebuffer:GLFramebuffer = GL.createFramebuffer();
        GL.bindFramebuffer(GL.FRAMEBUFFER, framebuffer);
        GL.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, texture.data, 0);
        if (generateDepthBuffer) {
            GL.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT, GL.RENDERBUFFER, depthBuffer);
        }

        // Unbind
        GL.bindTexture(GL.TEXTURE_2D, null);
        GL.bindRenderbuffer(GL.RENDERBUFFER, null);
        GL.bindFramebuffer(GL.FRAMEBUFFER, null);

        texture._framebuffer = framebuffer;
        if (generateDepthBuffer) {
            texture._depthBuffer = depthBuffer;
        }
        texture._width = width;
        texture._height = height;
        texture.isReady = true;
        texture.generateMipMaps = generateMipMaps;
        texture.references = 1;
        this._activeTexturesCache = [];

        this._loadedTexturesCache.push(texture);

        return texture;
    }
	
	public function createCubeTexture(rootUrl:String, scene:Scene, extensions:Array<String> = null):BabylonTexture {	
		if (extensions == null) {
			extensions = ["_px.jpg", "_py.jpg", "_pz.jpg", "_nx.jpg", "_ny.jpg", "_nz.jpg"];
		}
		/*var extensions:Array<String> = ["_px." + imageType, "_py." + imageType, "_pz." + imageType, "_nx." + imageType, "_ny." + imageType, "_nz." + imageType];
		var extensions2:Array<String> = ["_ft." + imageType, "_up." + imageType, "_rt." + imageType, "_bk." + imageType, "_dn." + imageType, "_lf." + imageType];*/
		
		var texture = new BabylonTexture(rootUrl, GL.createTexture());
        texture.isCube = true;
        texture.url = rootUrl;
        texture.references = 1;        
		
		var faces = [
                GL.TEXTURE_CUBE_MAP_POSITIVE_X, GL.TEXTURE_CUBE_MAP_POSITIVE_Y, GL.TEXTURE_CUBE_MAP_POSITIVE_Z,
                GL.TEXTURE_CUBE_MAP_NEGATIVE_X, GL.TEXTURE_CUBE_MAP_NEGATIVE_Y, GL.TEXTURE_CUBE_MAP_NEGATIVE_Z
            ];
		
		function _setTex(imagePath:String, index:Int) {
			var img:BitmapData = Assets.getBitmapData(imagePath);				
				
			var potWidth = getExponantOfTwo(img.width, this._caps.maxTextureSize);
			var potHeight = getExponantOfTwo(img.height, this._caps.maxTextureSize);
			var isPot = (img.width == potWidth && img.height == potHeight);
			this._workingCanvas = img;
			
			if (!isPot) {
				this._workingCanvas = getScaled(img, Std.int(potWidth/2), Std.int(potHeight/2));
			}
					
			#if html5
			var pixelData = this._workingCanvas.getPixels(this._workingCanvas.rect).byteView;
			#else
			var pixelData = new UInt8Array(BitmapData.getRGBAPixels(this._workingCanvas));
			#end
							
			GL.texImage2D(faces[index], 0, GL.RGBA, this._workingCanvas.width, this._workingCanvas.height, 0, GL.RGBA, GL.UNSIGNED_BYTE, cast pixelData);
		}
		
		GL.bindTexture(GL.TEXTURE_CUBE_MAP, texture.data);	
		
		GL.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		GL.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
		
		for (i in 0...extensions.length) {
			if (Assets.exists(rootUrl + extensions[i])) {	
				_setTex(rootUrl + extensions[i], i);
			} else {
				trace("Image '" + rootUrl + extensions[i] + "' doesn't exist !");
			}
		}		
		
		GL.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
		GL.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MIN_FILTER, GL.LINEAR_MIPMAP_LINEAR);
		
		GL.generateMipmap(GL.TEXTURE_CUBE_MAP);
		GL.bindTexture(GL.TEXTURE_CUBE_MAP, null);

		this._activeTexturesCache = [];
		
		texture.isReady = true;
		
		this._loadedTexturesCache.push(texture);
		
		return texture;
	}   

    public function _releaseTexture(texture:BabylonTexture) {
        if (texture._framebuffer != null) {
            GL.deleteFramebuffer(texture._framebuffer);
        }

        if (texture._depthBuffer != null) {
            GL.deleteRenderbuffer(texture._depthBuffer);
        }

        GL.deleteTexture(texture.data);

        // Unbind channels
        for (channel in 0...this._caps.maxTexturesImageUnits) {
			GL.activeTexture(getGLTexture(channel));
            GL.bindTexture(GL.TEXTURE_2D, null);
            GL.bindTexture(GL.TEXTURE_CUBE_MAP, null);
            this._activeTexturesCache[channel] = null;
        }

        var index:Int = Lambda.indexOf(this._loadedTexturesCache, texture);
        if (index != -1) {
            this._loadedTexturesCache.splice(index, 1);
        }
    }

    public function bindSamplers(effect:Effect) {
        GL.useProgram(effect.getProgram());
        var samplers:Array<String> = effect.getSamplers();
        for (index in 0...samplers.length) {
            var uniform = effect.getUniform(samplers[index]);
            GL.uniform1i(uniform, index);
        }
        this._currentEffect = null;
    }


    public function _bindTexture(channel:Int, texture:BabylonTexture) {
		GL.activeTexture(getGLTexture(channel));
        GL.bindTexture(GL.TEXTURE_2D, texture.data);	        
        this._activeTexturesCache[channel] = null;
    }

    public function setTextureFromPostProcess(channel:Int, postProcess:PostProcess) {
        this._bindTexture(channel, postProcess._textures.data[postProcess._currentRenderTextureInd]);
    }
	
	function getGLTexture(channel:Int):Int {
		return GL.TEXTURE0 + channel;
	}

    public function setTexture(channel:Int, texture:Texture) {
        if (channel < 0) {
            return;
        }
		
        // Not ready?
        if (texture == null || !texture.isReady()) {
            if (this._activeTexturesCache[channel] != null) {					
				GL.activeTexture(getGLTexture(channel));
                GL.bindTexture(GL.TEXTURE_2D, null);
                GL.bindTexture(GL.TEXTURE_CUBE_MAP, null);
                this._activeTexturesCache[channel] = null;
            }
            return;
        }

        // Video
		// TODO
        /*if (texture instanceof BABYLON.VideoTexture) {
            if (texture._update()) {
                this._activeTexturesCache[channel] = null;
            }
        } else if (texture.delayLoadState == BABYLON.Engine.DELAYLOADSTATE_NOTLOADED) { // Delay loading
            texture.delayLoad();
            return;
        }*/

        if (this._activeTexturesCache[channel] == texture) {
            return;
        }
        this._activeTexturesCache[channel] = texture;

        var internalTexture:BabylonTexture = texture.getInternalTexture();
		GL.activeTexture(getGLTexture(channel));
		
        if (internalTexture.isCube) {
            GL.bindTexture(GL.TEXTURE_CUBE_MAP, internalTexture.data);		
			// TODO !!!!!!!!
            /*if (internalTexture._cachedCoordinatesMode != texture.coordinatesMode) {
                internalTexture._cachedCoordinatesMode = texture.coordinatesMode;*/
			/*if (texture._cachedCoordinatesMode != texture.coordinatesMode) {
                texture._cachedCoordinatesMode = texture.coordinatesMode;
                GL.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_S, texture.coordinatesMode != Texture.CUBIC_MODE ? GL.REPEAT : GL.CLAMP_TO_EDGE);
                GL.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_T, texture.coordinatesMode != Texture.CUBIC_MODE ? GL.REPEAT : GL.CLAMP_TO_EDGE);
            }*/
			GL.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
			GL.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);

            this._setAnisotropicLevel(GL.TEXTURE_CUBE_MAP, texture);
        } else {
            GL.bindTexture(GL.TEXTURE_2D, internalTexture.data);

            if (internalTexture._cachedWrapU != texture.wrapU) {
                internalTexture._cachedWrapU = texture.wrapU;
                switch (texture.wrapU) {
                    case Texture.WRAP_ADDRESSMODE:
                        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.REPEAT);
						
                    case Texture.CLAMP_ADDRESSMODE:
                        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
						
                    case Texture.MIRROR_ADDRESSMODE:
                        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.MIRRORED_REPEAT);
						
                }
            }

            if (internalTexture._cachedWrapV != texture.wrapV) {
                internalTexture._cachedWrapV = texture.wrapV;
                switch (texture.wrapV) {
                    case Texture.WRAP_ADDRESSMODE:
                        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.REPEAT);
                        
                    case Texture.CLAMP_ADDRESSMODE:
                        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
                        
                    case Texture.MIRROR_ADDRESSMODE:
                        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.MIRRORED_REPEAT);
                        
                }
            }

            this._setAnisotropicLevel(GL.TEXTURE_2D, texture);
        }
    }

    public function _setAnisotropicLevel(key:Int, texture:Texture) {
        var anisotropicFilterExtension = this._caps.textureAnisotropicFilterExtension;		
        if (anisotropicFilterExtension != null && texture._cachedAnisotropicFilteringLevel != texture.anisotropicFilteringLevel) {
            GL.texParameterf(key, anisotropicFilterExtension.TEXTURE_MAX_ANISOTROPY_EXT, Math.min(texture.anisotropicFilteringLevel, this._caps.maxAnisotropy));
            texture._cachedAnisotropicFilteringLevel = texture.anisotropicFilteringLevel;
        }
    }

    // Dispose
    public function dispose() {
        // Release scenes
        while (this.scenes.length > 0) {
            this.scenes[0].dispose();
			this.scenes.shift();
        }

        // Release effects
        for (name in this._compiledEffects.keys()) {
            GL.deleteProgram(this._compiledEffects.get(name)._program);
        }
    }
	
}
