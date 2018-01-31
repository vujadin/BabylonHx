package samples;

import com.babylonhx.Scene;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.VertexData;
import com.babylonhx.math.Vector3;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.utils.Image;
import com.babylonhx.math.Tools as MathTools;

import lime.utils.Float32Array;
import lime.utils.UInt32Array;

import com.babylonhx.layer.Layer;

import com.babylonhx.postprocess.renderpipeline.pipelines.StandardRenderingPipeline;
import com.babylonhx.postprocess.renderpipeline.pipelines.DefaultRenderingPipeline;

import com.babylonhx.materials.lib.shadowonly.ShadowOnlyMaterial;

/**
 * ...
 * @author Krtolica Vujadin
 */
class BScene {

	public function new(scene:Scene) {
		// This creates and positions a free camera (non-mesh)
		//var camera = new FreeCamera("camera1", new Vector3(0, 5, -10), scene);
		var camera:ArcRotateCamera = new ArcRotateCamera("camera1", -Math.PI / 2.4, Math.PI / 2.2, 20, Vector3.Zero(), scene);
		
		// This targets the camera to scene origin
		camera.setTarget(Vector3.Zero());
		
		// This attaches the camera to the canvas
		camera.attachControl();
		
		//var bkgLayer = new Layer("background", "assets/img/ground.jpg", scene, true);
		
		// This creates a light, aiming 0,1,0 - to the sky (non-mesh)
		var light = new HemisphericLight("light1", new Vector3(0, 1, 0), scene);
		
		// Default intensity is 1. Let's dim the light a small amount
		light.intensity = 0.7;
		
		// Our built-in 'sphere' shape. Params: name, subdivs, size, scene
		var sphere = Mesh.CreateSphere("sphere1", 16, 2, scene);
		
		var size = 512;
		var tex = new Image(null, size, size);// new Texture("assets/img/ll_SS.png", scene);
		tex.perlinNoise(size / 11, size / 11, 7, Std.int(Math.random() * Math.POSITIVE_INFINITY));
		
		var diffTex = new Texture("assets/img/ll_SS.png", scene);
		
		var mat = new StandardMaterial("mat", scene);
		//mat.diffuseTexture = diffTex;
		
		var texBumpImg = Image.CreateBumpMap(diffTex.readPixels());
		
		var texBump = Texture.fromImage("bump", texBumpImg, scene);
		
		mat.diffuseTexture = diffTex;
		
		// Move the sphere upward 1/2 its height
		sphere.position.y = 1;
		
		// Our built-in 'ground' shape. Params: name, width, depth, subdivs, scene
		var ground = Mesh.CreateGround("ground1", 6, 6, 2, scene);
		ground.material = mat;
		
		var capsule = setGeometryData(scene);
		capsule.material = mat;
		
		scene.getEngine().runRenderLoop(function() {
            scene.render();
        });
	}

	var axisSamples:Int = 15;
	var sphereSamples:Int = 15;
	var radialSamples:Int = 15;
	var radius:Float = 2;
	var height:Float = 5;
	
	var verts:Array<Float> = [];
	var norms:Array<Float> = [];
	var texs:Array<Float> = [];
	var inds:Array<Int> = [];
	

    private function setGeometryData(scene:Scene):Mesh {		
        // generate geometry
        var inverseRadial:Float = 1.0 / radialSamples;
        var inverseSphere:Float = 1.0 / sphereSamples;
        var halfHeight:Float = 0.5 * height;
		
        // Generate points on the unit circle to be used in computing the mesh
        // points on a cylinder slice.
        var sin:Array<Float> = [];
        var cos:Array<Float> = [];
		
        for (radialCount in 0...radialSamples) {
            var angle = MathTools.TWOPI * inverseRadial * radialCount;
            cos[radialCount] = Math.cos(angle);
            sin[radialCount] = Math.sin(angle);
        }
        sin[radialSamples] = sin[0];
        cos[radialSamples] = cos[0];
		
        var tempA:Vector3 = new Vector3();
		
        // top point.
        verts.push(0);
		verts.push(radius + halfHeight);
		verts.push(0);
        norms.push(0);
		norms.push(1);
		norms.push(0);
        texs.push(1);
		texs.push(1);
		
        // generating the top dome.
        for (i in 0...sphereSamples) {
            var center = radius * (1 - (i + 1) * (inverseSphere));
            var lengthFraction = (center + height + radius) / (height + 2 * radius);
			
            // compute radius of slice
            var fSliceRadius = Math.sqrt(Math.abs(radius * radius - center * center));
			
            for (j in 0...radialSamples + 1) {
				tempA.set(cos[j], 0, sin[j]);
                var kRadial:Vector3 = tempA;
                kRadial.scaleInPlace(fSliceRadius);
                verts.push(kRadial.x);
				verts.push(center + halfHeight);
				verts.push(kRadial.z);
                kRadial.y = center;
                kRadial.normalize();
                norms.push(kRadial.x);
				norms.push(kRadial.y);
				norms.push(kRadial.z);
                var radialFraction = 1 - (j * inverseRadial); // in [0,1)
                texs.push(radialFraction);
				texs.push(lengthFraction);
            }
        }
		
        // generate cylinder... but no need to add points for first and last
        // samples as they are already part of domes.
        for (i in 1...axisSamples) {
            var center = halfHeight - (i * height / axisSamples);
            var lengthFraction = (center + halfHeight + radius) / (height + 2 * radius);
			
            for (j in 0...radialSamples + 1) {
				tempA.set(cos[j], 0, sin[j]);
                var kRadial:Vector3 = tempA;
                kRadial.scaleInPlace(radius);
                verts.push(kRadial.x);
				verts.push(center);
				verts.push(kRadial.z);
                kRadial.normalize();
                norms.push(kRadial.x);
				norms.push(kRadial.y);
				norms.push(kRadial.z);
                var radialFraction = 1 - (j * inverseRadial); // in [0,1)
                texs.push(radialFraction);
				texs.push(lengthFraction);
            }
        }
		
        // generating the bottom dome.
        for (i in 0...sphereSamples) {
            var center = i * (radius / sphereSamples);
            var lengthFraction = (radius - center) / (height + 2 * radius);
			
            // compute radius of slice
            var fSliceRadius = Math.sqrt(Math.abs(radius * radius - center * center));
			
            for (j in 0...radialSamples + 1) {
				tempA.set(cos[j], 0, sin[j]);
                var kRadial:Vector3 = tempA;
                kRadial.scaleInPlace(fSliceRadius);
                verts.push(kRadial.x);
				verts.push( -center - halfHeight);
				verts.push(kRadial.z);
                kRadial.y = (-center);
                kRadial.normalize();
                norms.push(kRadial.x);
				norms.push(kRadial.y);
				norms.push(kRadial.z);
                var radialFraction = 1 - (j * inverseRadial); // in [0,1)
                texs.push(radialFraction);
				texs.push(lengthFraction);
            }
        }
		
        // bottom point.
        verts.push(0);
		verts.push( -radius - halfHeight);
		verts.push(0);
        norms.push(0);
		norms.push( -1);
		norms.push(0);
        texs.push(0);
		texs.push(0);
		
		setIndexData();
		
		inds.reverse();
		
		var _positions = new Float32Array(verts);
		var _indices = new UInt32Array(inds);
		var _normals = new Float32Array(norms);
		var _uvs = new Float32Array(verts);
		
		// Result
		var vertexData = new VertexData();
		
		vertexData.indices = _indices;
		vertexData.positions = _positions;
		vertexData.normals = _normals;
		vertexData.uvs = _uvs;
		
		var mesh = new Mesh('capsule', scene);
		vertexData.applyToMesh(mesh, false);
		return mesh;
    }

    private function setIndexData() {
        // start with top of top dome.
        for (samples in 1...radialSamples + 1) {
            inds.push(samples + 1);
            inds.push(samples);
            inds.push(0);
        }
		
        for (plane in 1...sphereSamples) {
            var topPlaneStart:Int = Std.int(plane * (radialSamples + 1));
            var bottomPlaneStart:Int = Std.int((plane - 1) * (radialSamples + 1));
            for (sample in 1...radialSamples + 1) {
                inds.push(bottomPlaneStart + sample);
                inds.push(bottomPlaneStart + sample + 1);
                inds.push(topPlaneStart + sample);
                inds.push(bottomPlaneStart + sample + 1);
                inds.push(topPlaneStart + sample + 1);
                inds.push(topPlaneStart + sample);
            }
        }
		
        var start:Int = Std.int(sphereSamples * (radialSamples + 1));
		
        // add cylinder
        for (plane in 0...axisSamples) {
            var topPlaneStart = start + plane * (radialSamples + 1);
            var bottomPlaneStart = start + (plane - 1) * (radialSamples + 1);
            for (sample in 1...radialSamples + 1) {
                inds.push(bottomPlaneStart + sample);
                inds.push(bottomPlaneStart + sample + 1);
                inds.push(topPlaneStart + sample);
                inds.push(bottomPlaneStart + sample + 1);
                inds.push(topPlaneStart + sample + 1);
                inds.push(topPlaneStart + sample);
            }
        }
		
        start += Std.int((axisSamples - 1) * (radialSamples + 1));
		
        // Add most of the bottom dome triangles.
        for (plane in 1...sphereSamples) {
            var topPlaneStart = Std.int(start + plane * (radialSamples + 1));
            var bottomPlaneStart = Std.int(start + (plane - 1) * (radialSamples + 1));
            for (sample in 1...radialSamples + 1) {
                inds.push(bottomPlaneStart + sample);
                inds.push(bottomPlaneStart + sample + 1);
                inds.push(topPlaneStart + sample);
                inds.push(bottomPlaneStart + sample + 1);
                inds.push(topPlaneStart + sample + 1);
                inds.push(topPlaneStart + sample);
            }
        }
		
        start += Std.int((sphereSamples - 1) * (radialSamples + 1));
        // Finally the bottom of bottom dome.
        for (samples in 1...radialSamples + 1) {
            inds.push(start + samples);
            inds.push(start + samples + 1);
            inds.push(start + radialSamples + 2);
        }
    }
	
}
