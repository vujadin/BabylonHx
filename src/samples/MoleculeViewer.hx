package samples;

import com.babylonhx.Scene;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.VertexData;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Scalar;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.PointLight;
import com.babylonhx.materials.StandardMaterial;

/**
 * ...
 * @author Krtolica Vujadin
 */
class MoleculeViewer {
	
	var c60 = 'c60\n  Mrv0541 08071320073D          \n\n 60 90  0  0  0  0            999 V2000\n   -1.1810   -5.2190    0.5230 C   0  0  2  0  0  0  0  0  0  0  0  0\n   -1.5270   -4.2190    1.4490 C   0  0  2  0  0  0  0  0  0  0  0  0\n   -2.9260   -4.2250    1.5930 C   0  0  1  0  0  0  0  0  0  0  0  0\n   -2.5070   -6.2520   -1.2610 C   0  0  2  0  0  0  0  0  0  0  0  0\n   -1.4570   -6.0350   -2.1710 C   0  0  2  0  0  0  0  0  0  0  0  0\n   -0.2570   -5.4060   -1.7360 C   0  0  2  0  0  0  0  0  0  0  0  0\n   -0.1200   -4.9990   -0.3980 C   0  0  1  0  0  0  0  0  0  0  0  0\n   -0.8140   -2.9890    1.4660 C   0  0  1  0  0  0  0  0  0  0  0  0\n    0.2360   -2.7710    0.5560 C   0  0  1  0  0  0  0  0  0  0  0  0\n    0.5850   -3.7810   -0.3810 C   0  0  2  0  0  0  0  0  0  0  0  0\n   -3.6280   -2.9980    1.7540 C   0  0  1  0  0  0  0  0  0  0  0  0\n   -2.9240   -1.7810    1.7700 C   0  0  2  0  0  0  0  0  0  0  0  0\n   -3.7210   -6.0430   -1.9390 C   0  0  2  0  0  0  0  0  0  0  0  0\n   -5.3650   -3.8010    0.2280 C   0  0  1  0  0  0  0  0  0  0  0  0\n   -4.8420   -2.7880    1.0770 C   0  0  2  0  0  0  0  0  0  0  0  0\n   -2.0230   -5.6950   -3.4130 C   0  0  1  0  0  0  0  0  0  0  0  0\n   -3.4230   -5.6980   -3.2700 C   0  0  2  0  0  0  0  0  0  0  0  0\n    0.8830   -3.4360   -1.7110 C   0  0  1  0  0  0  0  0  0  0  0  0\n    0.3650   -4.4400   -2.5480 C   0  0  2  0  0  0  0  0  0  0  0  0\n   -5.9340   -3.4600   -1.0120 C   0  0  2  0  0  0  0  0  0  0  0  0\n   -5.5890   -4.4610   -1.9390 C   0  0  1  0  0  0  0  0  0  0  0  0\n   -3.7030   -0.8200    1.1020 C   0  0  2  0  0  0  0  0  0  0  0  0\n   -4.8880   -1.4430    0.6710 C   0  0  1  0  0  0  0  0  0  0  0  0\n   -0.2100   -4.0930   -3.8020 C   0  0  1  0  0  0  0  0  0  0  0  0\n   -1.3950   -4.7160   -4.2320 C   0  0  2  0  0  0  0  0  0  0  0  0\n   -5.2860   -4.1120   -3.2830 C   0  0  2  0  0  0  0  0  0  0  0  0\n   -4.2100   -4.7260   -3.9450 C   0  0  1  0  0  0  0  0  0  0  0  0\n   -5.4630   -1.0960   -0.5820 C   0  0  2  0  0  0  0  0  0  0  0  0\n   -5.9810   -2.1000   -1.4200 C   0  0  1  0  0  0  0  0  0  0  0  0\n   -1.6750    0.1620    0.1390 C   0  0  2  0  0  0  0  0  0  0  0  0\n   -3.0750    0.1590    0.2820 C   0  0  1  0  0  0  0  0  0  0  0  0\n    0.4910   -1.0750   -1.1920 C   0  0  1  0  0  0  0  0  0  0  0  0\n    0.8370   -2.0760   -2.1180 C   0  0  2  0  0  0  0  0  0  0  0  0\n   -2.1740   -3.7550   -4.9010 C   0  0  1  0  0  0  0  0  0  0  0  0\n   -3.5890   -3.7590   -4.7560 C   0  0  2  0  0  0  0  0  0  0  0  0\n   -0.2860   -0.1140   -1.8610 C   0  0  2  0  0  0  0  0  0  0  0  0\n   -1.3770    0.5070   -1.1920 C   0  0  1  0  0  0  0  0  0  0  0  0\n   -3.6420    0.4990   -0.9600 C   0  0  2  0  0  0  0  0  0  0  0  0\n   -4.8410   -0.1310   -1.3950 C   0  0  1  0  0  0  0  0  0  0  0  0\n   -5.6830   -1.7550   -2.7490 C   0  0  2  0  0  0  0  0  0  0  0  0\n   -5.3330   -2.7650   -3.6860 C   0  0  1  0  0  0  0  0  0  0  0  0\n   -4.9780   -0.5370   -2.7330 C   0  0  2  0  0  0  0  0  0  0  0  0\n   -2.5910    0.7160   -1.8700 C   0  0  2  0  0  0  0  0  0  0  0  0\n   -4.8120   -5.4220   -1.2690 C   0  0  2  0  0  0  0  0  0  0  0  0\n   -4.6740   -5.0160    0.0700 C   0  0  1  0  0  0  0  0  0  0  0  0\n   -3.4450   -5.2280    0.7560 C   0  0  1  0  0  0  0  0  0  0  0  0\n   -2.3670   -5.8420    0.0940 C   0  0  2  0  0  0  0  0  0  0  0  0\n   -1.5090   -1.7770    1.6250 C   0  0  2  0  0  0  0  0  0  0  0  0\n   -0.8880   -0.8110    0.8140 C   0  0  1  0  0  0  0  0  0  0  0  0\n    0.1890   -1.4250    0.1520 C   0  0  1  0  0  0  0  0  0  0  0  0\n   -4.2840   -2.5470   -4.5960 C   0  0  1  0  0  0  0  0  0  0  0  0\n   -3.9170   -0.3170   -3.6540 C   0  0  2  0  0  0  0  0  0  0  0  0\n   -3.5710   -1.3170   -4.5800 C   0  0  1  0  0  0  0  0  0  0  0  0\n   -1.4700   -2.5380   -4.8840 C   0  0  2  0  0  0  0  0  0  0  0  0\n   -0.2560   -2.7480   -4.2070 C   0  0  1  0  0  0  0  0  0  0  0  0\n   -2.1720   -1.3120   -4.7240 C   0  0  2  0  0  0  0  0  0  0  0  0\n    0.2680   -1.7350   -3.3580 C   0  0  1  0  0  0  0  0  0  0  0  0\n   -0.4240   -0.5200   -3.2010 C   0  0  1  0  0  0  0  0  0  0  0  0\n   -2.7310    0.3060   -3.2250 C   0  0  2  0  0  0  0  0  0  0  0  0\n   -1.6520   -0.3080   -3.8860 C   0  0  2  0  0  0  0  0  0  0  0  0\n  1  2  1  0  0  0  0\n  1  7  1  0  0  0  0\n  1 47  1  0  0  0  0\n  2  3  1  0  0  0  0\n  2  8  1  0  0  0  0\n  3 11  1  0  0  0  0\n  3 46  1  0  0  0  0\n  4  5  1  0  0  0  0\n  4 13  1  0  0  0  0\n  4 47  1  0  0  0  0\n  5  6  1  0  0  0  0\n  5 16  1  0  0  0  0\n  6  7  1  0  0  0  0\n  6 19  1  0  0  0  0\n  7 10  1  0  0  0  0\n  8  9  1  0  0  0  0\n  8 48  1  0  0  0  0\n  9 10  1  0  0  0  0\n  9 50  1  0  0  0  0\n 10 18  1  0  0  0  0\n 11 12  1  0  0  0  0\n 11 15  1  0  0  0  0\n 12 22  1  0  0  0  0\n 12 48  1  0  0  0  0\n 13 17  1  0  0  0  0\n 13 44  1  0  0  0  0\n 14 15  1  0  0  0  0\n 14 20  1  0  0  0  0\n 14 45  1  0  0  0  0\n 15 23  1  0  0  0  0\n 16 17  1  0  0  0  0\n 16 25  1  0  0  0  0\n 17 27  1  0  0  0  0\n 18 19  1  0  0  0  0\n 18 33  1  0  0  0  0\n 19 24  1  0  0  0  0\n 20 21  1  0  0  0  0\n 20 29  1  0  0  0  0\n 21 26  1  0  0  0  0\n 21 44  1  0  0  0  0\n 22 23  1  0  0  0  0\n 22 31  1  0  0  0  0\n 23 28  1  0  0  0  0\n 24 25  1  0  0  0  0\n 24 55  1  0  0  0  0\n 25 34  1  0  0  0  0\n 26 27  1  0  0  0  0\n 26 41  1  0  0  0  0\n 27 35  1  0  0  0  0\n 28 29  1  0  0  0  0\n 28 39  1  0  0  0  0\n 29 40  1  0  0  0  0\n 30 31  1  0  0  0  0\n 30 37  1  0  0  0  0\n 30 49  1  0  0  0  0\n 31 38  1  0  0  0  0\n 32 33  1  0  0  0  0\n 32 36  1  0  0  0  0\n 32 50  1  0  0  0  0\n 33 57  1  0  0  0  0\n 34 35  1  0  0  0  0\n 34 54  1  0  0  0  0\n 35 51  1  0  0  0  0\n 36 37  1  0  0  0  0\n 36 58  1  0  0  0  0\n 37 43  1  0  0  0  0\n 38 39  1  0  0  0  0\n 38 43  1  0  0  0  0\n 39 42  1  0  0  0  0\n 40 41  1  0  0  0  0\n 40 42  1  0  0  0  0\n 41 51  1  0  0  0  0\n 42 52  1  0  0  0  0\n 43 59  1  0  0  0  0\n 44 45  1  0  0  0  0\n 45 46  1  0  0  0  0\n 46 47  1  0  0  0  0\n 48 49  1  0  0  0  0\n 49 50  1  0  0  0  0\n 51 53  1  0  0  0  0\n 52 53  1  0  0  0  0\n 52 59  1  0  0  0  0\n 53 56  1  0  0  0  0\n 54 55  1  0  0  0  0\n 54 56  1  0  0  0  0\n 55 57  1  0  0  0  0\n 56 60  1  0  0  0  0\n 57 58  1  0  0  0  0\n 58 60  1  0  0  0  0\n 59 60  1  0  0  0  0\nM  END\n';

	var scene:Scene;
	
	
	public function new(scene:Scene) {
		this.scene = scene;
		
		initBy(readMol(c60));
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}

	function readMol(data:String):Dynamic {
		var atoms:Array<Array<Float>> = [];
		var bonds:Array<Array<Float>> = [];
		var l = data.split('\n');
		var lenA:Int = Std.parseInt(l[3].substr(0, 3));
		var lenB:Int = Std.parseInt(l[3].substr(3, 3));
		var ofsA:Int = 4;
		var ofsB:Int = lenA + ofsA;
		var x:Float = 0;
		var y:Float = 0;
		var z:Float = 0;
		var f:Float = 0;
		var t:Float = 0;
		var n:Float = 0;
		var minx:Float = 10000;
		var maxx:Float = -10000;
		var miny:Float = 10000;
		var maxy:Float = -10000;
		var minz:Float = 10000;
		var maxz:Float = -10000;
		
		for (i in 4...ofsB) {
			x = Std.parseFloat(l[i].substr(0, 10));
			y = Std.parseFloat(l[i].substr(10, 10));
			z = Std.parseFloat(l[i].substr(20, 10));
			if (minx > x) minx = x;
			if (maxx < x) maxx = x;
			if (miny > y) miny = y;
			if (maxy < y) maxy = y;
			if (minz > z) minz = z;
			if (maxz < z) maxz = z;
			atoms.push([x, y, z]);
		}
		
		var cx = minx + (maxx - minx) / 2.0;
		var cy = miny + (maxy - miny) / 2.0;
		var cz = minz + (maxz - minz) / 2.0;
		for (i in 0...atoms.length) {
			atoms[i][0] -= cx;
			atoms[i][1] -= cy;
			atoms[i][2] -= cz;
		}
		
		for (i in ofsB...ofsB + lenB) {
			f = Std.parseInt(l[i].substr(0, 3)) - 1;
			t = Std.parseInt(l[i].substr(3, 3)) - 1;
			n = Std.parseInt(l[i].substr(6, 3));
			bonds.push([f, t, n]);
		}
		
		return {
			'atoms': atoms,
			'bonds': bonds
		};
	}

	function initBy(mol:Dynamic) {
		var camera = new ArcRotateCamera("Camera", 0, 0.8, 15, Vector3.Zero(), scene);
		camera.attachControl();
		
		var light0 = new PointLight("Omni0", new Vector3(0, 100, 100), scene);
		
		var sphere = Mesh.CreateSphere("Sphere", 16, 0, scene);
		
		// atoms
		for (i in 0...mol.atoms.length) {
			var atom = Mesh.CreateSphere("Sphere", 16, 0.7, scene);
			var material = new StandardMaterial("material01", scene);
			material.diffuseColor = new Color3(1.0, 1.0, 1.0);
			atom.material = material;
			
			atom.position.x = mol.atoms[i][0];
			atom.position.y = mol.atoms[i][1];
			atom.position.z = mol.atoms[i][2];
			atom.parent = sphere;
		}
		
		// bonds
		for (i in 0...mol.bonds.length) {
			var f = mol.atoms[mol.bonds[i][0]];
			var t = mol.atoms[mol.bonds[i][1]];
			var r = mol.bonds[i][2] * 0.1;
			var c = mol.bonds[i][2] == 1 ? 0x00ff00 : 0xff0000;
			var bond = createCylinder(f[0], f[1], f[2], r, t[0], t[1], t[2], r, c, true);
			bond.parent = sphere;
		}
	}

	function createCylinder(x0:Float, y0:Float, z0:Float, r0:Float, x1:Float, y1:Float, z1:Float, r1:Float, col:Int, open:Bool) {
		var v = new Vector3(x0 - x1, y0 - y1, z0 - z1);
		var len = v.length();
		var cylinder = Mesh.CreateCylinder("cylinder", 1, 0.25, 0.25, 6, 6, scene, false);
		var material = new StandardMaterial("material01", scene);
		
		var colorR = ((col & 0xff0000) >> 16) / 255;
		var colorG = ((col & 0x00ff00) >> 8) / 255;
		var colorB = ((col & 0x0000ff) >> 0) / 255;
		material.diffuseColor = new Color3(colorR, colorG, colorB);
		cylinder.material = material;
		
		if (len > 0.001) {
			cylinder.rotation.z = Math.acos(v.y / len);
			cylinder.rotation.y = 0.5 * Math.PI + Math.atan2(v.x, v.z);
		}
		
		cylinder.position.x = (x1 + x0) / 2;
		cylinder.position.y = (y1 + y0) / 2;
		cylinder.position.z = (z1 + z0) / 2;
		
		return cylinder;
	}
	
}
