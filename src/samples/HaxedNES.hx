package samples;

import com.babylonhx.cameras.Camera;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.DynamicTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.InstancedMesh;
import com.babylonhx.Scene;
import com.babylonhx.engine.Engine;
import lime.graphics.opengl.GL;
import com.gamestudiohx.nes.NES;
import lime.utils.UInt8Array;
import com.babylonhx.loading.plugins.BabylonFileLoader;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.loading.obj.ObjLoader;
import com.babylonhx.materials.lib.water.WaterMaterial;
import com.babylonhx.lights.shadows.ShadowGenerator;

import haxe.io.Bytes;
import haxe.Utf8;

/*
import com.babylonhx.postprocess.BlurPostProcess;
import com.babylonhx.postprocess.PassPostProcess;
import com.babylonhx.postprocess.PostProcess;
import com.babylonhx.postprocess.ConvolutionPostProcess;
*/

#if openfl
import openfl.Assets;
#elseif lime
import lime.Assets;
#end


import haxe.Timer;

#if cpp
import sys.io.File;
//import dialogs.Dialogs;
#end

#if js
import js.Browser;
import js.html.Image;
import js.html.FileReader;
import js.html.compat.Uint8Array;
#end

/**
 * ...
 * @author Krtolica Vujadin
 */
class HaxedNES {
	
	public var nes:NES;
	var scene:Scene;
	var tex:DynamicTexture;
	
	var send:Mesh;
	var bottom:Mesh;
	
	var screenMesh:Mesh;
	var tvMesh:Mesh;
	
	var context:UInt8Array;
	
	var camera:ArcRotateCamera;
	var objLoader:ObjLoader;
	
	var shadowCasters:Array<Mesh> = [];
	var shadowGenerator:ShadowGenerator;
	
	//#if !js
	public var selectedGame:String = "";
	//#end
	

	public function new(scene:Scene) {
		this.scene = scene;
		
		camera = new ArcRotateCamera("Camera", 13.55, 1.36, 78.68, new Vector3(0, 4, 0), scene);
		camera.attachControl();
		camera.upperBetaLimit = 1.59;
		camera.lowerBetaLimit = 0.8;
		camera.lowerRadiusLimit = 10;
		camera.upperRadiusLimit = 80;
		
		//var light = new HemisphericLight("light1", new Vector3(0, 1, 0), scene);
		
		var light2 = new DirectionalLight("light2", new Vector3(3, -5, 5), scene);
		//light2.diffuse = Color3.FromInt(0x2e3a9b);
		light2.intensity = 1.5;
		
		// Shadows
        shadowGenerator = new ShadowGenerator(1024, light2);
		
		init();
	}
	
	//var ll:InstancedMesh;
	function init() {
		#if js
		createInfoMenu();
		#else
		/*this.scene.getEngine().mouseDown.push(function(x:Int, y:Int, button:Int) {
			if (button == 2) {
				var result =
				Dialogs.open('Load game',
					[
						{ ext:'nes', desc:'NES rom' }
					]);
					
				if (result != null && result != "") {
					selectedGame = result;
					startGameCPP();
				}
			}
		});*/
		#end
		
		var skybox = Mesh.CreateBox("skyBox", 5000.0, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/TropicalSunnyDay", scene);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		#if js
		skyboxMaterial.disableLighting = true;
		#end
		skybox.material = skyboxMaterial;
		skybox.infiniteDistance = true;
		
		objLoader = new ObjLoader(scene);
		objLoader.load("assets/models/", "log.obj", function(meshes:Array<Mesh>) {
			for (m in meshes) {
				untyped m.material.diffuseColor = new Color3(0.9, 0.9, 0.9);
				untyped m.material.emissiveColor = new Color3(0.2, 0.2, 0.2);
				m.receiveShadows = true;
				shadowCasters.push(m);
				var log2:InstancedMesh = m.createInstance("log2");
				log2.position.set(26.6, 22.8, -22.1);
				log2.rotation.set(-0.27, -0.91, -1.9);
			}
		});
		
		objLoader = new ObjLoader(scene);
		objLoader.load("assets/models/", "palms.obj", function(meshes:Array<Mesh>) {			
			for (m in meshes) {
				untyped m.material.diffuseColor = new Color3(0.2, 0.2, 0.2);
				cast(m.material, StandardMaterial).backFaceCulling = false;
				shadowCasters.push(m);
				if (m.name.indexOf("polySurface234_polySurface63.000") != -1) {
					var c1 = m.createInstance("leaves1");
					c1.position.set(-4.521, -10.328, -16.701);
					c1.rotation.set(0.92, 0, 0);
					
					var c2 = m.createInstance("leaves2");
					c2.position.set(-9.303, 3.44, -18.394);
					c2.rotation.set(0.83, -1.2, 0.48);
					
					var c3 = m.createInstance("leaves3");
					c3.position.set(20.63, 0.981, -24.353);
					c3.rotation.set(0.76, 0, 0);
					c3.scaling.set(1.3, 1.3, 1.3);
				} 
				else {
					untyped m.material.emissiveColor = new Color3(0.2, 0.2, 0.2);
				}
			}
		});
		
		objLoader = new ObjLoader(scene);
		objLoader.load("assets/models/", "Rock_4.obj", function(meshes:Array<Mesh>) {
			var m = meshes[0];
			untyped m.material.diffuseColor = new Color3(0.9, 0.9, 0.9);
			untyped m.material.emissiveColor = new Color3(0.2, 0.2, 0.2);
			
			shadowCasters.push(m);
			
			var rock2:InstancedMesh = m.createInstance("rock2");
			rock2.position.set(24, -4.2, -22.5);
			rock2.rotation.set(0.22, 1.82, 75.41);
			
			var rock3:InstancedMesh = m.createInstance("rock3");
			rock3.position.set(-36, -17.5, 24.7);
			rock3.rotation.set(1.45, -0.19, -0.67);
			//ll = rock3;
		});
		
		objLoader = new ObjLoader(scene);
		objLoader.load("assets/models/", "skeleton2.obj", function(meshes:Array<Mesh>) {
			var i = 0;
			for (m in meshes) {
				untyped m.material.diffuseColor = new Color3(0.9, 0.9, 0.9);
				untyped m.material.emissiveColor = new Color3(0.3, 0.3, 0.3);
				shadowCasters.push(m);
				m.receiveShadows = true;
				#if !js
				if (i++ == meshes.length - 7) {
				#else
				if (i++ == meshes.length - 8) {
				#end
					m.position.set( -3.63, 2.9, -0.1);
					m.rotation.set(0.88, 0.71, 0.28);
					untyped m.material.emissiveColor = new Color3(0.5, 0.5, 0.5);
					//ll = m;
				}
			}
		});
		
		objLoader = new ObjLoader(scene);
		objLoader.load("assets/models/", "ground.obj", function(meshes:Array<Mesh>) {
			var mat = new StandardMaterial("sand", scene);
			mat.diffuseTexture = new Texture("assets/models/sand.jpg", scene);
			mat.diffuseColor = new Color3(0.9, 0.9, 0.9);
			mat.specularColor = Color3.Black();
			untyped mat.diffuseTexture.uScale = 4;
			untyped mat.diffuseTexture.vScale = 4;
			meshes[0].material = mat;
			
			bottom = Mesh.CreateGround("bottom", 1024, 1024, 4, scene);
			bottom.position.y = -2;
			bottom.material = mat;
			
			send = Mesh.MergeMeshes([meshes[0], bottom], true);
			send.receiveShadows = true;
		});
		
		// Water
		var waterMesh = Mesh.CreateGround("waterMesh", 1024, 1024, 6, scene);
		waterMesh.position.y = -1.3;
		var water = new WaterMaterial("water", scene, new Vector2(1024, 1024));
		water.backFaceCulling = true;
		water.bumpTexture = new Texture("assets/img/waterbump.jpg", scene);
		water.windForce = -2;
		water.waveHeight = 0;
		water.bumpHeight = 0.05;
		water.colorBlendFactor = 0;
		water.addToRenderList(skybox);
		water.addToRenderList(send);
		for (m in shadowCasters) {
			water.addToRenderList(m);
			shadowGenerator.getShadowMap().renderList.push(m);
		}
		waterMesh.material = water;
		
		objLoader = new ObjLoader(scene);
		objLoader.load("assets/models/", "tv.obj", function(meshes:Array<Mesh>) {
			tvMesh = meshes[0];
			untyped tvMesh.material.diffuseColor = new Color3(1.2, 1.2, 1.2);
			untyped tvMesh.material.emissiveColor = new Color3(0.3, 0.3, 0.3);
			
			shadowGenerator.getShadowMap().renderList.push(tvMesh);
			water.addToRenderList(tvMesh);
			
			var clone1 = tvMesh.createInstance("tvclone_1");
			clone1.position.set(-6.2692, 4.4405, 2.0675);
			clone1.rotation.set(1.5751 - (Math.PI / 2), 0.2447, 0.4721);
			clone1.scaling.set( -0.243, 0.243, 0.243);			
			
			var clone2 = tvMesh.createInstance("tvclone_2");
			clone2.position.set( -8.5124, 0, 2.4345);
			clone2.rotation.set(0, 0.2369, 0);
			clone2.scaling.set( -0.521, 0.521, 0.521);
			
			var clone3 = tvMesh.createInstance("tvclone_3");
			clone3.position.set(8.869, 4.0074, 3.3566);
			clone3.rotation.set(0, -0.3582,0);
			clone3.scaling.set( -0.32, 0.32, 0.32);
			
			var clone4 = tvMesh.createInstance("tvclone_4");
			clone4.position.set(8.5124, 0, 2.4345);
			clone4.rotation.set(0, -0.2369, 0);
			clone4.scaling.set( -0.521, 0.521, 0.521);
			
			var clone5 = tvMesh.createInstance("tvclone_5");
			clone5.position.set(3.8393, 9.45, 1.5215);
			clone5.rotation.set(0, 0, 1.5708);
			clone5.scaling.set( -0.35, 0.35, 0.35);
			
			var clone6 = tvMesh.createInstance("tvclone_6");
			clone6.position.set( -5.4124, -0.4, 6.5345);
			clone6.rotation.set(-0.6, 0.3582, 0.2);
			clone6.scaling.set( -0.35, 0.35, 0.35);
		});	
		
		objLoader = new ObjLoader(scene);
		objLoader.load("assets/models/", "ekran.obj", function(meshes:Array<Mesh>) {
			var mat = new StandardMaterial("screenmat", scene);
			createTexture(scene);
			mat.diffuseTexture = tex;
			mat.backFaceCulling = false;
			mat.emissiveColor = Color3.White();
			
			screenMesh = meshes[0];
			
			screenMesh.material = mat;
			screenMesh.scaling.set(-1, 1.06, 1);
			screenMesh.position.set( -0.02, -0.3, 0);
			screenMesh.bakeCurrentTransformIntoVertices();
			
			water.addToRenderList(screenMesh);
			
			var clone1 = screenMesh.createInstance("screenclone_1");
			clone1.position.set(-6.2692, 4.4405, 2.0675);
			clone1.rotation.set(1.5751 - (Math.PI / 2), 0.2447, 0.4721);
			clone1.scaling.set( 0.243, 0.243, 0.243);
			
			var clone2 = screenMesh.createInstance("screenclone_2");
			clone2.position.set( -8.5124, 0, 2.4345);
			clone2.rotation.set(0, 0.2369, 0);
			clone2.scaling.set( 0.521, 0.521, 0.521);
			
			var clone3 = screenMesh.createInstance("screenclone_3");
			clone3.position.set(8.869, 4.0074, 3.3566);
			clone3.rotation.set(0, -0.3582,0);
			clone3.scaling.set( 0.32, 0.32, 0.32);
			
			var clone4 = screenMesh.createInstance("screenclone_4");
			clone4.position.set(8.5124, 0, 2.4345);
			clone4.rotation.set(0, -0.2369, 0);
			clone4.scaling.set( 0.521, 0.521, 0.521);
			
			var clone5 = screenMesh.createInstance("screenclone_5");
			clone5.position.set(3.8393, 9.45, 1.5215);
			clone5.rotation.set(0, 0, 1.5708);
			clone5.scaling.set( 0.35, 0.35, 0.35);
				
			nes = new NES(tex);
			
			this.scene.getEngine().keyDown.push(nes.input.keyDown);
			this.scene.getEngine().keyUp.push(nes.input.keyUp);	
			
			this.scene.getEngine().keyDown.push(handleKeypress);
			
			#if js
			var dropZone = js.Browser.document.getElementById("content");		
			dropZone.addEventListener("dragover", FileDragHover, false);
			dropZone.addEventListener("dragleave", FileDragHover, false);
			dropZone.addEventListener("drop", FileSelectHandler, false);
			#end
			
			shadowGenerator.getShadowMap().refreshRate = 0;
			shadowGenerator.blurScale = 1;
			shadowGenerator.setDarkness(0.5);
			shadowGenerator.useBlurExponentialShadowMap = true;
			
			startGame();			
			
			
			// Post-process
			/*var blurWidth = 1.0;
			
			var postProcess0 = new PassPostProcess("Scene copy", 1.0, camera);
			var postProcess1 = new PostProcess("Down sample", "downsample", ["screenSize", "highlightThreshold"], null, 0.25, camera, Texture.BILINEAR_SAMPLINGMODE);
			postProcess1.onApply = function (effect) {
				effect.setFloat2("screenSize", postProcess1.width, postProcess1.height);
				effect.setFloat("highlightThreshold", 0.90);
			};
			var postProcess2 = new BlurPostProcess("Horizontal blur", new Vector2(1.0, 0), blurWidth, 0.25, camera);
			var postProcess3 = new BlurPostProcess("Vertical blur", new Vector2(0, 1.0), blurWidth, 0.25, camera);
			var postProcess4 = new PostProcess("Final compose", "compose", ["sceneIntensity", "glowIntensity", "highlightIntensity"], ["sceneSampler"], 1, camera);
			postProcess4.onApply = function (effect) {
				effect.setTextureFromPostProcess("sceneSampler", postProcess0);
				effect.setFloat("sceneIntensity", 0.5);
				effect.setFloat("glowIntensity", 0.4);
				effect.setFloat("highlightIntensity", 1.0);
			};*/
		});	
		
	}
	
	#if js
	function createInfoMenu() {
		var infoImg = Browser.document.createImageElement();
		infoImg.src = "assets/img/info.png";
		infoImg.setAttribute("style", "top: 20px; left: 20px; position: absolute; cursor: pointer");
		Browser.document.body.appendChild(infoImg);
		
		var menu = Browser.document.createDivElement();
		menu.setAttribute("style", "opacity: 0.7; top: 20px; left: 20px; width: 320px; height: 374px; border-radius: 10px; border: solid 1px #fff; background-color: #000; padding: 10px; font-family: Consolas; font-size: 14px; color: #fff; display: none; position: absolute;");
		Browser.document.body.appendChild(menu);
		
		var closeBtn = Browser.document.createButtonElement();
		closeBtn.textContent = "close";
		closeBtn.setAttribute("style", "position: absolute; top: 3px; right: 3px; font-size: 12px; font-weight: bold; padding: 2px 6px; border-radius: 8px; cursor: pointer;");
		menu.appendChild(closeBtn);
		closeBtn.onclick = function() {
			infoImg.style.display = "block";
			menu.style.display = "none";
		};
		
		var p1 = Browser.document.createParagraphElement();
		p1.innerHTML = "<b style='color: #f59600; font-size: 16px;'>HaxedNES</b> - port of <a style='color: #f06f1e'  href='http://www.zophar.net/java/nes/vnes.html' target='_blank'>vNES</a> to <a style='color: #f06f1e' href='http://haxe.org/' target='_blank'>Haxe</a>";
		menu.appendChild(p1);
		
		var pPort = Browser.document.createParagraphElement();
		pPort.innerHTML = "Supported mappers:<br/>0, 1, 2, 3, 4, 7, 9, 10, 11, 15, 18, 21, 22, 23, 32, 33, 34, 48, 71, 72, 75, 78, 79, 87, 94, 105, 140, 182";
		menu.appendChild(pPort);
		
		var p2 = Browser.document.createParagraphElement();
		p2.innerHTML = "Rendered with <a style='color: #f06f1e' href='http://babylonhx.com/' target='_blank'>babylonhx</a> :)";
		menu.appendChild(p2);
		
		var p3 = Browser.document.createParagraphElement();
		p3.innerHTML = "Controls: <br/><b>Z</b> : A <br/><b>X</b> : B <br/><b>Enter</b> : Start <br/><b>Ctrl</b> : Select <br/><b>Arrow Keys</b> : Directions";
		menu.appendChild(p3);
		
		var p4 = Browser.document.createParagraphElement();
		p4.innerHTML = "";
		
		var romsList = Browser.document.createSelectElement();
		romsList.addEventListener("change", function ()	{
			var rom = Assets.getBytes("assets/roms/" + romsList.value + ".nes");
			var data = "";
			for (i in 0...rom.length) {
				data += String.fromCharCode(rom.get(i));
			}
			var romLoaded = nes.loadRom(data);
			if (romLoaded && nes.rom.valid) {
				nes.start();
				scene.unregisterBeforeRender(updateNoise);
				scene.registerBeforeRender(renderNesFrame);
			}
			
			infoImg.style.display = "block";
			menu.style.display = "none";
		});
		var defaultVal = Browser.document.createOptionElement();
		defaultVal.innerHTML = "- Few public domain roms to play with -";
		defaultVal.disabled = true;
		defaultVal.selected = true;
		romsList.appendChild(defaultVal);
		
		var romsNames = ["GemVenture Beta", "Sayoonara! by Chris Covell", "Solar Wars by Chris Covell", "Tetramino v0.30 by Damian Yerrick", "Wall Demo by Chris Covell", "Stars - Biology Demo", "Adventures of Lex & Grim", "Sack of Flour", "Brony Blaster", "Raycast"];
		for (name in romsNames) {
			var option = Browser.document.createOptionElement();
			option.innerHTML = name;
			option.value = name;
			romsList.appendChild(option);			
		}
		p4.appendChild(romsList);
		
		var endMsg = Browser.document.createSpanElement();
		endMsg.style.color = "#f0da1d";
		endMsg.innerHTML = "<br/><br/>Or DRAG'N'DROP any NES ROM (*.nes file) in your browser.";
		p4.appendChild(endMsg);
		menu.appendChild(p4);
		
		infoImg.onclick = function() {
			infoImg.style.display = "none";
			menu.style.display = "block";
		};
	}
	#end
	
	function handleKeypress(key:Int) {
		/*trace(key);
		switch(key) {
			case 100:
				ll.position.x += 0.1;
				
			case 97:
				ll.position.x -= 0.1;
				
			case 119:
				ll.position.z -= 0.1;
				
			case 115:
				ll.position.z += 0.1;
				
			case 116:
				ll.position.y -= 0.1;
				
			case 103:
				ll.position.y += 0.1;
				
			case 117:
				ll.rotation.x += 0.01;
				
			case 105:
				ll.rotation.x -= 0.01;
				
			case 106:
				ll.rotation.y += 0.01;
				
			case 107:
				ll.rotation.y -= 0.01;
				
			case 44:
				ll.rotation.z += 0.01;
				
			case 46:
				ll.rotation.z -= 0.01;
		}
		
		trace(ll.position);
		trace(ll.rotation);*/
	}
	
	private function createTexture(scene:Scene) {
		var data = new UInt8Array(256 * 256 * 4);	// RGB
		this.tex = new DynamicTexture("nestexture", { data: data, width: 256, height: 256 }, scene, false, Texture.NEAREST_SAMPLINGMODE);
		context = this.tex.getContext();
		
		generateNoise();
		
		GL.bindTexture(GL.TEXTURE_2D, tex.getInternalTexture()._webGLTexture);
		GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, tex._canvas.width, tex._canvas.height, 0, GL.RGBA, GL.UNSIGNED_BYTE, tex._canvas.data);
		GL.generateMipmap(GL.TEXTURE_2D);
		GL.bindTexture(GL.TEXTURE_2D, null);
		//scene.getEngine()._activeTexturesCache = [];
		tex._texture.isReady = true;
		
		scene.registerBeforeRender(updateNoise);
	}
	
	inline function generateNoise() {
		var value:Int = 0;
		var totalPixelsCount = 256 * 256 * 4;
		var i:Int = 0;
		while (i < totalPixelsCount) {
			value = Math.floor((Math.random() * (0.02 - 0.95) + 0.95) * 255);
			context[i] = value;
			context[i + 1] = value;
			context[i + 2] = value;
			context[i + 3] = 255;
			
			i += 4;
		}
	}
	
	inline function updateNoise(_, _) {
		generateNoise();
		updateFrame();
	}
	
	inline public function updateFrame() {
		GL.texSubImage2D(GL.TEXTURE_2D, 0, 0, 0, 256, 256, GL.RGBA, GL.UNSIGNED_BYTE, cast tex._canvas.data);
	}
	
	#if cpp
	public function startGameCPP() {
		if (selectedGame != "") {
			var ba = File.getContent(selectedGame);
			var loaded = nes.loadRom(ba);
			
			if (loaded && nes.rom.valid) {
				nes.start();
				scene.unregisterBeforeRender(updateNoise);
				scene.registerBeforeRender(renderNesFrame);
			}
		}
	}
	#end
	
	public function startGame() {	
		scene.getEngine().runRenderLoop(function () {			
			scene.render();			
		});
	}
	
	function renderNesFrame(_, _) {
		nes.frame();
		updateFrame();
	}
	
	
	#if js
	function FileDragHover(e:Dynamic) {
		e.stopPropagation();
		e.preventDefault();
	}
	
	function FileSelectHandler(e:Dynamic) {
		// cancel event and hover styling
		FileDragHover(e);
			
		var items:Array<Dynamic> = [];
		
		var dataTransfer = e.dataTransfer;
		if (dataTransfer != null) {
			items = dataTransfer.items != null ? dataTransfer.items : dataTransfer.files;	
			if (items != null) {
				var entry = items[0];
				if (entry.getAsEntry != null) {  			//Standard HTML5 API
					entry = untyped entry.getAsEntry();
				}
				else if (entry.webkitGetAsEntry != null) {  //WebKit implementation of HTML5 API.
					entry = untyped entry.webkitGetAsEntry();
				}
				
				if(entry.isFile){
					//Handle FileEntry
					handleFile(entry);
				}
				else {
					handleFirefoxFile(entry);
				}
			}
		}
		else {						
			trace("no file to process...");
			return;
		}
	}
	
	function handleFirefoxFile(file:Dynamic) {
		var reader = new FileReader();
		if (reader.readAsBinaryString != null) {
			reader.onload = function(e:Dynamic) {
				nes.loadRom(e.target.result);
				if (nes.rom.valid) {
					//startGame();
					nes.start();
				}
			};
			reader.readAsBinaryString(file);
		}
		else {
			reader.addEventListener("loadend", function (e:Dynamic) {
				var binary = "";
				var bytes:Array<Dynamic> = untyped __js__("new Uint8Array(arguments[0].target.result)");
				var length = untyped bytes.byteLength;
				for (i in 0...length) {
					binary += String.fromCharCode(bytes[i]);
				}
				var romLoaded = nes.loadRom(binary);
				if (romLoaded && nes.rom.valid) {
					nes.start();
					scene.unregisterBeforeRender(updateNoise);
					scene.registerBeforeRender(renderNesFrame);
				}
			});
			reader.readAsArrayBuffer(file);
		}
	}
	
	function handleFile(jsonFile:Dynamic) {
		jsonFile.file(function(file:Dynamic) {
			var reader = new FileReader();			
			
			reader.onload = function(e:Dynamic) {
				var romLoaded = nes.loadRom(e.target.result);
				if (romLoaded && nes.rom.valid) {
					nes.start();
					scene.unregisterBeforeRender(updateNoise);
					scene.registerBeforeRender(renderNesFrame);
				}
			};
			reader.readAsBinaryString(file);			
		});
	}
	#end
	
}
