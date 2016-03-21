package com.babylonhx.serializers.obj;

import com.babylonhx.mesh.Mesh;
import com.babylonhx.materials.StandardMaterial;

/**
 * ...
 * @author Krtolica Vujadin
 */
class ObjExport {

	//Exports the geometry of a Mesh in .OBJ file format (text)
	public static function OBJ(mesh:Mesh, materials:Bool = true, matlibname:String = "mat"):String {
		var output:Array<String> = [];
		var g = mesh.geometry;
		var trunkVerts = g.getVerticesData('position');
		var trunkNormals = g.getVerticesData('normal');
		var trunkUV = g.getVerticesData('uv');
		var trunkFaces = g.getIndices();
		if (materials) {
			output.push("mtllib " + matlibname + ".mtl");
		}
		
		var i:Int = 0;
		while (i < trunkVerts.length) {
			output.push("v " + trunkVerts[i] + " " + trunkVerts[i + 1] + " " + trunkVerts[i + 2]);
			i += 3;
		}
		
		i = 0;
		while (i < trunkNormals.length) {
			output.push("vn " + trunkNormals[i] + " " + trunkNormals[i + 1] + " " + trunkNormals[i + 2]);
			i += 3;
		}
		
		i = 0;
		while (i < trunkUV.length) {
			output.push("vt " + trunkUV[i] + " " + trunkUV[i + 1]);
			i += 2;
		}
		
		//TODO: submeshes (groups)
		//TODO: smoothing groups (s 1, s off)
		
		output.push("g gr1");
		if (materials) {
			output.push("usemtl mat1");
		}
		
		i = 0;
		while (i < trunkFaces.length) {
			output.push(
				"f " + (trunkFaces[i + 2] + 1) + "/" + (trunkFaces[i + 2] + 1) + "/" + (trunkFaces[i + 2] + 1) +
				" " + (trunkFaces[i + 1] + 1) + "/" + (trunkFaces[i + 1] + 1) + "/" + (trunkFaces[i + 1] + 1) +
				" " + (trunkFaces[i] + 1) + "/" + (trunkFaces[i] + 1) + "/" + (trunkFaces[i] + 1)
			);
			
			i += 3;
		}
		
		var text = output.join("\n");
		
		return (text);
	}

	//Exports the material(s) of a mesh in .MTL file format (text)
	public static function MTL(mesh:Mesh):String {
		var output:Array<String> = [];
		var m:StandardMaterial = cast mesh.material;
		output.push("newmtl mat1");
		output.push("Ns " + m.specularPower);
		output.push("Ni 1.5000");
		output.push("d " + m.alpha);
		output.push("Tr 0.0000");
		output.push("Tf 1.0000 1.0000 1.0000");
		output.push("illum 2");
		output.push("Ka " + m.ambientColor.r + " " + m.ambientColor.g + " " + m.ambientColor.b);
		output.push("Kd " + m.diffuseColor.r + " " + m.diffuseColor.g + " " + m.diffuseColor.b);
		output.push("Ks " + m.specularColor.r + " " + m.specularColor.g + " " + m.specularColor.b);
		output.push("Ke " + m.emissiveColor.r + " " + m.emissiveColor.g + " " + m.emissiveColor.b);
		
		//TODO: uv scale, offset, wrap
		//TODO: UV mirrored in Blender? second UV channel? lightMap? reflection textures?
		var uvscale = "";
		
		if (m.ambientTexture != null) {
			output.push("map_Ka " + uvscale + m.ambientTexture.name);
		}
		
		if (m.diffuseTexture != null) {
			output.push("map_Kd " + uvscale + m.diffuseTexture.name);
			//TODO: alpha testing, opacity in diffuse texture alpha channel (diffuseTexture.hasAlpha -> map_d)
		}
		
		if (m.specularTexture != null) {
			output.push("map_Ks " + uvscale + m.specularTexture.name);
			/* TODO: glossiness = specular highlight component is in alpha channel of specularTexture. (???)
			if (m.useGlossinessFromSpecularMapAlpha)  {
				output.push("  map_Ns "+uvscale + m.specularTexture.name);
			}
			*/
		}
		
		/* TODO: emissive texture not in .MAT format (???)
		if (m.emissiveTexture) {
			output.push("  map_d "+uvscale+m.emissiveTexture.name);
		}
		*/
		
		if (m.bumpTexture != null) {
			output.push("map_bump -imfchan z " + uvscale + m.bumpTexture.name);
		}
		
		if (m.opacityTexture != null) {
			output.push("map_d " + uvscale + m.opacityTexture.name);
		}
		
		var text = output.join("\n");
		
		return (text);
	}
	
}
