package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.PointLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;
import com.babylonhx.audio.*;
import com.babylonhx.utils.typedarray.UInt8Array;
/**
 * ...
 * @author Brendon Smith
 */
class AudioAnalyzer {

	var bar:Array<Dynamic> = [];
	var square = "assets/img/square.jpg";
	var bjs = "assets/img/metal.png";
	var fft:UInt8Array;

	// Better random function
	public function rnd(min, max) {
	    return Math.floor(Math.random() * (max - min + 1) + min);
	}

	// Create the equalizer
	public function createRingcubes(r, nb, scene) {
	    var TWO_PI = Math.PI * 2;
	    var angle = TWO_PI / nb;
	    var cube;

	    // Create a really cool metal material with bump :)
	    var m1 = new StandardMaterial("m", scene);
	    m1.diffuseTexture = new Texture(square, scene);
	    m1.bumpTexture = new Texture("assets/img/grained_uv.png", scene);
	    m1.reflectionTexture = new Texture(bjs, scene);
	    m1.reflectionTexture.level = 0.8;
	    m1.reflectionTexture.coordinatesMode = Texture.SPHERICAL_MODE;

	    for (i in 0...nb) {
	        if (i == 0) {
	            bar[i] = Mesh.CreateBox("b", 0.02, scene);

	            bar[i].material = m1;
	            bar[i].isVisible = false;
	        }
	        else {
	            bar[i] = bar[0].createInstance("b" + i);

	            bar[i].position.x = r * Math.sin(angle * i);
	            bar[i].position.y = r * Math.cos(angle * i);
	            bar[i].position.z = 0;

	            bar[i].scaling.y = 20.0;
	            bar[i].scaling.x = 200.0;

	            // Remember, you learned it in the "Lookat" PG !
	            bar[i].lookAt(new Vector3(0, 0, 0));
	        }

	    }
	}

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 0, 0, 25, Vector3.Zero(), scene);
		camera.setTarget(Vector3.Zero());
		camera.attachControl();
		
		var light = new HemisphericLight("light1", new Vector3(0, 1, 0), scene);

	    // Streaming sound using HTML5 Audio element
	    var music = new Sound("Music", "assets/audio/cosmosis.mp3", scene, null, { streaming: true, autoplay: true });

	    // Here we go !
	    createRingcubes(20, 256, scene);

	    // Create some cool material.
	    var mball = new StandardMaterial("m", scene);
	    mball.backFaceCulling = false;
	    mball.bumpTexture = new Texture("assets/img/grained_uv.png", scene);
	    mball.reflectionTexture = new Texture(bjs, scene);
	    mball.reflectionTexture.level = 0.8;
	    mball.reflectionTexture.coordinatesMode = Texture.SPHERICAL_MODE;

	    // Center sphere
	    var sphere = Mesh.CreateSphere("s", 32, 20, scene);
	    sphere.material = mball;

	    // Start the analyser
	    var myAnalyser = new Analyser(scene);
	    scene.getEngine().audioEngine.connectToAnalyser(myAnalyser);
	    myAnalyser.FFT_SIZE = 512;
	    myAnalyser.SMOOTHING = 0.9;
	    var t = 0.0;



		scene.registerBeforeRender(function() {
			fft = myAnalyser.getByteFrequencyData();

	        // Scale cubes according to music ! :)
	        // here we multiply by 4 because we are working on a very little scene like (20x20x20)
	        for (i in 0...bar.length) {
	            bar[i].scaling.z = fft[i] * 4;
	        }

	        // Move camera
	        camera.alpha = 4.0 * (Math.PI / 20 + Math.cos(t / 35));
	        camera.beta = 1.5 * (Math.PI / 20 + Math.sin(t / 50));
	        camera.radius = 100 + (-25 + 25 * Math.sin(t / 30));

	        t += 0.1;
		});
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
