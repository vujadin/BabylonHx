package com.babylonhx.tools.hdr;

import com.babylonhx.math.Vector4;
import com.babylonhx.utils.typedarray.ArrayBufferView;
import com.babylonhx.utils.typedarray.Float32Array;
import com.babylonhx.utils.typedarray.UInt8Array;
import com.babylonhx.utils.typedarray.UInt32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PMREMGenerator {

	private static var CP_MAX_MIPLEVELS:Int = 16;

	private static var CP_UDIR:Int = 0;
	private static var CP_VDIR:Int = 1;
	private static var CP_FACEAXIS:Int = 2;

	//used to index cube faces
	private static var CP_FACE_X_POS:Int = 0;
	private static var CP_FACE_X_NEG:Int = 1;
	private static var CP_FACE_Y_POS:Int = 2;
	private static var CP_FACE_Y_NEG:Int = 3;
	private static var CP_FACE_Z_POS:Int = 4;
	private static var CP_FACE_Z_NEG:Int = 5;

	//used to index image edges
	// NOTE.. the actual number corresponding to the edge is important
	//  do not change these, or the code will break
	//
	// CP_EDGE_LEFT   is u = 0
	// CP_EDGE_RIGHT  is u = width-1
	// CP_EDGE_TOP    is v = 0
	// CP_EDGE_BOTTOM is v = height-1
	private static var CP_EDGE_LEFT:Int = 0;
	private static var CP_EDGE_RIGHT:Int = 1;
	private static var CP_EDGE_TOP:Int = 2;
	private static var CP_EDGE_BOTTOM:Int = 3;

	//corners of CUBE map (P or N specifys if it corresponds to the 
	//  positive or negative direction each of X, Y, and Z
	private static var CP_CORNER_NNN:Int = 0;
	private static var CP_CORNER_NNP:Int = 1;
	private static var CP_CORNER_NPN:Int = 2;
	private static var CP_CORNER_NPP:Int = 3;
	private static var CP_CORNER_PNN:Int = 4;
	private static var CP_CORNER_PNP:Int = 5;
	private static var CP_CORNER_PPN:Int = 6;
	private static var CP_CORNER_PPP:Int = 7;

	private static var _vectorTemp:Vector4 = new Vector4(0, 0, 0, 0);

	//3x2 matrices that map cube map indexing vectors in 3d 
	// (after face selection and divide through by the 
	//  _ABSOLUTE VALUE_ of the max coord)
	// into NVC space
	//Note this currently assumes the D3D cube face ordering and orientation
	private static var _sgFace2DMapping:Array<Array<Array<Int>>> = [
		//XPOS face
		[
			[0, 0, -1], //u towards negative Z
			[0, -1, 0], //v towards negative Y
			[1, 0, 0]	//pos X axis
		],   
		//XNEG face
		[
			[0, 0, 1],  //u towards positive Z
			[0, -1, 0], //v towards negative Y
			[-1, 0, 0]	//neg X axis
		],        
		//YPOS face
		[
			[1, 0, 0], //u towards positive X
			[0, 0, 1], //v towards positive Z
			[0, 1, 0]  //pos Y axis 
		],  
		//YNEG face
		[
			[1, 0, 0],  //u towards positive X
			[0, 0, -1], //v towards negative Z
			[0, -1, 0]	//neg Y axis 
		],  
		//ZPOS face
		[
			[1, 0, 0],  //u towards positive X
			[0, -1, 0], //v towards negative Y
			[0, 0, 1]	//pos Z axis
		],   
		//ZNEG face
		[
			[-1, 0, 0], //u towards negative X
			[0, -1, 0], //v towards negative Y
			[0, 0, -1]	//neg Z axis 
		],  
	];

	//------------------------------------------------------------------------------
	// D3D cube map face specification
	//   mapping from 3D x,y,z cube map lookup coordinates 
	//   to 2D within face u,v coordinates
	//
	//   --------------------> U direction 
	//   |                   (within-face texture space)
	//   |         _____
	//   |        |     |
	//   |        | +Y  |
	//   |   _____|_____|_____ _____
	//   |  |     |     |     |     |
	//   |  | -X  | +Z  | +X  | -Z  |
	//   |  |_____|_____|_____|_____|
	//   |        |     |
	//   |        | -Y  |
	//   |        |_____|
	//   |
	//   v   V direction
	//      (within-face texture space)
	//------------------------------------------------------------------------------

	//Information about neighbors and how texture coorrdinates change across faces 
	//  in ORDER of left, right, top, bottom (e.g. edges corresponding to u=0, 
	//  u=1, v=0, v=1 in the 2D coordinate system of the particular face.
	//Note this currently assumes the D3D cube face ordering and orientation
	private static var _sgCubeNgh:Array<Array<Array<Int>>> = [
		//XPOS face
		[
			[PMREMGenerator.CP_FACE_Z_POS, PMREMGenerator.CP_EDGE_RIGHT],
			[PMREMGenerator.CP_FACE_Z_NEG, PMREMGenerator.CP_EDGE_LEFT],
			[PMREMGenerator.CP_FACE_Y_POS, PMREMGenerator.CP_EDGE_RIGHT],
			[PMREMGenerator.CP_FACE_Y_NEG, PMREMGenerator.CP_EDGE_RIGHT]
		],
		//XNEG face
		[
			[PMREMGenerator.CP_FACE_Z_NEG, PMREMGenerator.CP_EDGE_RIGHT],
			[PMREMGenerator.CP_FACE_Z_POS, PMREMGenerator.CP_EDGE_LEFT],
			[PMREMGenerator.CP_FACE_Y_POS, PMREMGenerator.CP_EDGE_LEFT],
			[PMREMGenerator.CP_FACE_Y_NEG, PMREMGenerator.CP_EDGE_LEFT]
		],
		//YPOS face
		[
			[PMREMGenerator.CP_FACE_X_NEG, PMREMGenerator.CP_EDGE_TOP],
			[PMREMGenerator.CP_FACE_X_POS, PMREMGenerator.CP_EDGE_TOP],
			[PMREMGenerator.CP_FACE_Z_NEG, PMREMGenerator.CP_EDGE_TOP],
			[PMREMGenerator.CP_FACE_Z_POS, PMREMGenerator.CP_EDGE_TOP]
		],
		//YNEG face
		[
			[PMREMGenerator.CP_FACE_X_NEG, PMREMGenerator.CP_EDGE_BOTTOM],
			[PMREMGenerator.CP_FACE_X_POS, PMREMGenerator.CP_EDGE_BOTTOM],
			[PMREMGenerator.CP_FACE_Z_POS, PMREMGenerator.CP_EDGE_BOTTOM],
			[PMREMGenerator.CP_FACE_Z_NEG, PMREMGenerator.CP_EDGE_BOTTOM]
		],
		//ZPOS face
		[
			[PMREMGenerator.CP_FACE_X_NEG, PMREMGenerator.CP_EDGE_RIGHT],
			[PMREMGenerator.CP_FACE_X_POS, PMREMGenerator.CP_EDGE_LEFT],
			[PMREMGenerator.CP_FACE_Y_POS, PMREMGenerator.CP_EDGE_BOTTOM],
			[PMREMGenerator.CP_FACE_Y_NEG, PMREMGenerator.CP_EDGE_TOP]
		],
		//ZNEG face
		[
			[PMREMGenerator.CP_FACE_X_POS, PMREMGenerator.CP_EDGE_RIGHT],
			[PMREMGenerator.CP_FACE_X_NEG, PMREMGenerator.CP_EDGE_LEFT],
			[PMREMGenerator.CP_FACE_Y_POS, PMREMGenerator.CP_EDGE_TOP],
			[PMREMGenerator.CP_FACE_Y_NEG, PMREMGenerator.CP_EDGE_BOTTOM]
		]
	];

	//The 12 edges of the cubemap, (entries are used to index into the neighbor table)
	// this table is used to average over the edges.
	private static var _sgCubeEdgeList:Array<Array<Int>> = [
		[PMREMGenerator.CP_FACE_X_POS, PMREMGenerator.CP_EDGE_LEFT],
		[PMREMGenerator.CP_FACE_X_POS, PMREMGenerator.CP_EDGE_RIGHT],
		[PMREMGenerator.CP_FACE_X_POS, PMREMGenerator.CP_EDGE_TOP],
		[PMREMGenerator.CP_FACE_X_POS, PMREMGenerator.CP_EDGE_BOTTOM],
		
		[PMREMGenerator.CP_FACE_X_NEG, PMREMGenerator.CP_EDGE_LEFT],
		[PMREMGenerator.CP_FACE_X_NEG, PMREMGenerator.CP_EDGE_RIGHT],
		[PMREMGenerator.CP_FACE_X_NEG, PMREMGenerator.CP_EDGE_TOP],
		[PMREMGenerator.CP_FACE_X_NEG, PMREMGenerator.CP_EDGE_BOTTOM],
		
		[PMREMGenerator.CP_FACE_Z_POS, PMREMGenerator.CP_EDGE_TOP],
		[PMREMGenerator.CP_FACE_Z_POS, PMREMGenerator.CP_EDGE_BOTTOM],
		[PMREMGenerator.CP_FACE_Z_NEG, PMREMGenerator.CP_EDGE_TOP],
		[PMREMGenerator.CP_FACE_Z_NEG, PMREMGenerator.CP_EDGE_BOTTOM]
	];

	//Information about which of the 8 cube corners are correspond to the 
	//  the 4 corners in each cube face
	//  the order is upper left, upper right, lower left, lower right
	private static var _sgCubeCornerList:Array<Array<Int>> = [
		[PMREMGenerator.CP_CORNER_PPP, PMREMGenerator.CP_CORNER_PPN, PMREMGenerator.CP_CORNER_PNP, PMREMGenerator.CP_CORNER_PNN], // XPOS face
		[PMREMGenerator.CP_CORNER_NPN, PMREMGenerator.CP_CORNER_NPP, PMREMGenerator.CP_CORNER_NNN, PMREMGenerator.CP_CORNER_NNP], // XNEG face
		[PMREMGenerator.CP_CORNER_NPN, PMREMGenerator.CP_CORNER_PPN, PMREMGenerator.CP_CORNER_NPP, PMREMGenerator.CP_CORNER_PPP], // YPOS face
		[PMREMGenerator.CP_CORNER_NNP, PMREMGenerator.CP_CORNER_PNP, PMREMGenerator.CP_CORNER_NNN, PMREMGenerator.CP_CORNER_PNN], // YNEG face
		[PMREMGenerator.CP_CORNER_NPP, PMREMGenerator.CP_CORNER_PPP, PMREMGenerator.CP_CORNER_NNP, PMREMGenerator.CP_CORNER_PNP], // ZPOS face
		[PMREMGenerator.CP_CORNER_PPN, PMREMGenerator.CP_CORNER_NPN, PMREMGenerator.CP_CORNER_PNN, PMREMGenerator.CP_CORNER_NNN] // ZNEG face
	];

	private var _outputSurface:Array<Array<ArrayBufferView>> = [];
	private var _normCubeMap:Array<ArrayBufferView>;
	private var _filterLUT:Array<Array<ArrayBufferView>>;
	private var _numMipLevels:Int = 0;
	
	public var input:Array<ArrayBufferView>;
	public var inputSize:Int;
	public var outputSize:Int;
	public var maxNumMipLevels:Int;
	public var numChannels:Int;
	public var isFloat:Bool;
	public var specularPower:Float;
	public var cosinePowerDropPerMip:Float;
	public var excludeBase:Bool;
	public var fixup:Bool;
	
	/**
	 * Constructor of the generator.
	 * 
	 * @param input The different faces data from the original cubemap in the order X+ X- Y+ Y- Z+ Z-
	 * @param inputSize The size of the cubemap faces
	 * @param outputSize The size of the output cubemap faces
	 * @param maxNumMipLevels The max number of mip map to generate (0 means all)
	 * @param numChannels The number of channels stored in the cubemap (3 for RBGE for instance)
	 * @param isFloat Specifies if the input texture is in float or int (hdr is usually in float)
	 * @param specularPower The max specular level of the desired cubemap
	 * @param cosinePowerDropPerMip The amount of drop the specular power will follow on each mip
	 * @param excludeBase Specifies wether to process the level 0 (original level) or not
	 * @param fixup Specifies wether to apply the edge fixup algorythm or not
	 */
	public function new(input:Array<ArrayBufferView>, inputSize:Int, outputSize:Int, maxNumMipLevels:Int, numChannels:Int, isFloat:Bool, specularPower:Float, cosinePowerDropPerMip:Float, excludeBase:Bool, fixup:Bool) {
		this.input = input;
		this.inputSize = inputSize;
		this.outputSize = outputSize;
		this.maxNumMipLevels = maxNumMipLevels;
		this.numChannels = numChannels;
		this.isFloat = isFloat;
		this.specularPower = specularPower;
		this.cosinePowerDropPerMip = cosinePowerDropPerMip;
		this.excludeBase = excludeBase;
		this.fixup = fixup;
	}

	public function filterCubeMap():Array<Array<ArrayBufferView>> {
		// Init cubemap processor
		this.init();
		
		// Filters the cubemap
		this.filterCubeMapMipChain();
		
		// Returns the filtered mips.
		return this._outputSurface;
	}

	private function init() {
		var mipLevelSize:Int;
		
		//if nax num mip levels is set to 0, set it to generate the entire mip chain
		if (this.maxNumMipLevels == 0) {
			this.maxNumMipLevels = PMREMGenerator.CP_MAX_MIPLEVELS;
		}
		
		//first miplevel size 
		mipLevelSize = this.outputSize;
		
		//Iterate over mip chain, and init ArrayBufferView for mip-chain
		for (j in 0...this.maxNumMipLevels) {
			//this._outputSurface.length++;
			this._outputSurface[j] = [];
			
			//Iterate over faces for output images
			for (i in 0...6) {
				//this._outputSurface[j].length++;
				
				// Initializes a new array for the output.
				if (this.isFloat) {
					this._outputSurface[j][i] = new Float32Array(Std.int(mipLevelSize * mipLevelSize * this.numChannels));
				} 
				else {
					this._outputSurface[j][i] = new UInt32Array(Std.int(mipLevelSize * mipLevelSize * this.numChannels));
				}
			}
			
			//next mip level is half size
			mipLevelSize >>= 1;
			
			this._numMipLevels++;
			
			//terminate if mip chain becomes too small
			if (mipLevelSize == 0) {
				this.maxNumMipLevels = j;
				return;
			}
		}
	}

	//--------------------------------------------------------------------------------------
	//Cube map filtering and mip chain generation.
	// the cube map filtereing is specified using a number of parameters:
	// Filtering per miplevel is specified using 2D cone angle (in degrees) that 
	//  indicates the region of the hemisphere to filter over for each tap. 
	//                
	// Note that the top mip level is also a filtered version of the original input images 
	//  as well in order to create mip chains for diffuse environment illumination.
	// The cone angle for the top level is specified by a_BaseAngle.  This can be used to
	//  generate mipchains used to store the resutls of preintegration across the hemisphere.
	//
	// Then the mip angle used to genreate the next level of the mip chain from the first level 
	//  is a_InitialMipAngle
	//
	// The angle for the subsequent levels of the mip chain are specified by their parents 
	//  filtering angle and a per-level scale and bias
	//   newAngle = oldAngle * a_MipAnglePerLevelScale;
	//
	//--------------------------------------------------------------------------------------
	private function filterCubeMapMipChain() {
		// First, take count of the lighting model to modify SpecularPower
		// var refSpecularPower = (a_MCO.LightingModel == CP_LIGHTINGMODEL_BLINN || a_MCO.LightingModel == CP_LIGHTINGMODEL_BLINN_BRDF) ? a_MCO.SpecularPower / GetSpecularPowerFactorToMatchPhong(a_MCO.SpecularPower) : a_MCO.SpecularPower; 
		// var refSpecularPower = this.specularPower; // Only Phong BRDF yet. This explains the line below using this.specularpower.
		
		//Cone angle start (for generating subsequent mip levels)
		var currentSpecularPower = this.specularPower;
		
		//Build filter lookup tables based on the source miplevel size
		this.precomputeFilterLookupTables(this.inputSize);
		
		// Note that we need to filter the first level before generating mipmap
		// So LevelIndex == 0 is base filtering hen LevelIndex > 0 is mipmap generation
		for (levelIndex in 0...this._numMipLevels) {
			// TODO : Write a function to copy and scale the base mipmap in output
			// I am just lazy here and just put a high specular power value, and do some if.
			if (this.excludeBase && (levelIndex == 0)) {
				// If we don't want to process the base mipmap, just put a very high specular power (this allow to handle scale of the texture).
				currentSpecularPower = 100000.0;
			}
			
			// Special case for cosine power mipmap chain. For quality requirement, we always process the current mipmap from the top mipmap
			var srcCubeImage = this.input;
			var dstCubeImage = this._outputSurface[levelIndex];
			var dstSize = this.outputSize >> levelIndex;
			
			// Compute required angle.
			var angle = this.getBaseFilterAngle(currentSpecularPower);
			
			// filter cube surfaces
			this.filterCubeSurfaces(srcCubeImage, this.inputSize, dstCubeImage, dstSize, angle, currentSpecularPower);
			
			// fix seams
			if (this.fixup) {
				this.fixupCubeEdges(dstCubeImage, dstSize);
			}
			
			// Decrease the specular power to generate the mipmap chain
			// TODO : Use another method for Exclude (see first comment at start of the function
			if (this.excludeBase && (levelIndex == 0)) {
				currentSpecularPower = this.specularPower;
			}
			
			currentSpecularPower *= this.cosinePowerDropPerMip;
		}
	}

	//--------------------------------------------------------------------------------------
	// This function return the BaseFilterAngle require by PMREMGenerator to its FilterExtends
	// It allow to optimize the texel to access base on the specular power.
	//--------------------------------------------------------------------------------------
	private function getBaseFilterAngle(cosinePower:Float):Float {
		// We want to find the alpha such that:
		// cos(alpha)^cosinePower = epsilon
		// That's: acos(epsilon^(1/cosinePower))
		var threshold = 0.000001; // Empirical threshold (Work perfectly, didn't check for a more big number, may get some performance and still god approximation)
		var angle = 180.0;
		angle = Math.acos(Math.pow(threshold, 1.0 / cosinePower));
		angle *= 180.0 / Math.PI; // Convert to degree
		angle *= 2.0; // * 2.0f because PMREMGenerator divide by 2 later
		
		return angle;
	}

	//--------------------------------------------------------------------------------------
	//Builds the following lookup tables prior to filtering:
	//  -normalizer cube map
	//  -tap weight lookup table
	// 
	//--------------------------------------------------------------------------------------
	private function precomputeFilterLookupTables(srcCubeMapWidth:Int) {
		//var srcTexelAngle:Float;
		//var iCubeFace:Float;
		
		//clear pre-existing normalizer cube map
		this._normCubeMap = [];
		
		//Normalized vectors per cubeface and per-texel solid angle 
		this.buildNormalizerSolidAngleCubemap(srcCubeMapWidth);
	}

	//--------------------------------------------------------------------------------------
	//Builds a normalizer cubemap, with the texels solid angle stored in the fourth component
	//
	//Takes in a cube face size, and an array of 6 surfaces to write the cube faces into
	//
	//Note that this normalizer cube map stores the vectors in unbiased -1 to 1 range.
	// if _bx2 style scaled and biased vectors are needed, uncomment the SCALE and BIAS
	// below
	//--------------------------------------------------------------------------------------
	private function buildNormalizerSolidAngleCubemap(size:Int) {
		var iCubeFace:Int;
		var u:Float;
		var v:Float;
		
		//iterate over cube faces
		for (iCubeFace in 0...6) {
			//First three channels for norm cube, and last channel for solid angle
			this._normCubeMap.push(new Float32Array(Std.int(size * size * 4)));
			
			//fast texture walk, build normalizer cube map
			var facesData = this.input[iCubeFace];
			
			for (v in 0...size) {
				for (u in 0...size) {
					var vect = this.texelCoordToVect(iCubeFace, u, v, size, this.fixup);
					cast (this._normCubeMap[iCubeFace], Float32Array)[Std.int((v * size + u) * 4 + 0)] = vect.x;
					cast (this._normCubeMap[iCubeFace], Float32Array)[Std.int((v * size + u) * 4 + 1)] = vect.y;
					cast (this._normCubeMap[iCubeFace], Float32Array)[Std.int((v * size + u) * 4 + 2)] = vect.z;
					
					var solidAngle = this.texelCoordSolidAngle(iCubeFace, u, v, size);
					cast (this._normCubeMap[iCubeFace], Float32Array)[Std.int((v * size + u) * 4 + 4)] = solidAngle;
				}
			}
		}
	}

	//--------------------------------------------------------------------------------------
	// Convert cubemap face texel coordinates and face idx to 3D vector
	// note the U and V coords are integer coords and range from 0 to size-1
	//  this routine can be used to generate a normalizer cube map
	//--------------------------------------------------------------------------------------
	// SL BEGIN
	private function texelCoordToVect(faceIdx:Int, u:Float, v:Float, size:Int, fixup:Bool):Vector4 {
		var nvcU:Float;
		var nvcV:Float;
		var tempVec:Vector4;
		
		// Change from original AMD code
		// transform from [0..res - 1] to [- (1 - 1 / res) .. (1 - 1 / res)]
		// + 0.5f is for texel center addressing
		nvcU = (2.0 * (u + 0.5) / size) - 1.0;
		nvcV = (2.0 * (v + 0.5) / size) - 1.0;
		
		// warp fixup
		if (fixup && size > 1) {
			// Code from Nvtt : http://code.google.com/p/nvidia-texture-tools/source/browse/trunk/src/nvtt/CubeSurface.cpp
			var a = Math.pow(size, 2.0) / Math.pow(size - 1, 3.0);
			nvcU = a * Math.pow(nvcU, 3) + nvcU;
			nvcV = a * Math.pow(nvcV, 3) + nvcV;
		}
		
		// Get current vector
		// generate x,y,z vector (xform 2d NVC coord to 3D vector)
		// U contribution
		var UVec = PMREMGenerator._sgFace2DMapping[faceIdx][PMREMGenerator.CP_UDIR];
		PMREMGenerator._vectorTemp.x = UVec[0] * nvcU;
		PMREMGenerator._vectorTemp.y = UVec[1] * nvcU;
		PMREMGenerator._vectorTemp.z = UVec[2] * nvcU;
		
		// V contribution and Sum
		var VVec = PMREMGenerator._sgFace2DMapping[faceIdx][PMREMGenerator.CP_VDIR];
		PMREMGenerator._vectorTemp.x += VVec[0] * nvcV;
		PMREMGenerator._vectorTemp.y += VVec[1] * nvcV;
		PMREMGenerator._vectorTemp.z += VVec[2] * nvcV;
		
		//add face axis
		var faceAxis = PMREMGenerator._sgFace2DMapping[faceIdx][PMREMGenerator.CP_FACEAXIS];
		PMREMGenerator._vectorTemp.x += faceAxis[0];
		PMREMGenerator._vectorTemp.y += faceAxis[1];
		PMREMGenerator._vectorTemp.z += faceAxis[2];
		
		//normalize vector              
		PMREMGenerator._vectorTemp.normalize();
		
		return PMREMGenerator._vectorTemp;
	}

	//--------------------------------------------------------------------------------------
	// Convert 3D vector to cubemap face texel coordinates and face idx 
	// note the U and V coords are integer coords and range from 0 to size-1
	//  this routine can be used to generate a normalizer cube map
	//
	// returns face IDX and texel coords
	//--------------------------------------------------------------------------------------
	// SL BEGIN
	/*
	Mapping Texture Coordinates to Cube Map Faces
	Because there are multiple faces, the mapping of texture coordinates to positions on cube map faces
	is more complicated than the other texturing targets.  The EXT_texture_cube_map extension is purposefully
	designed to be consistent with DirectX 7's cube map arrangement.  This is also consistent with the cube
	map arrangement in Pixar's RenderMan package. 
	For cube map texturing, the (s,t,r) texture coordinates are treated as a direction vector (rx,ry,rz)
	emanating from the center of a cube.  (The q coordinate can be ignored since it merely scales the vector
	without affecting the direction.) At texture application time, the interpolated per-fragment (s,t,r)
	selects one of the cube map face's 2D mipmap sets based on the largest magnitude coordinate direction 
	the major axis direction). The target column in the table below explains how the major axis direction
	maps to the 2D image of a particular cube map target. 

	major axis 
	direction     target                              sc     tc    ma 
	----------    ---------------------------------   ---    ---   --- 
	+rx          GL_TEXTURE_CUBE_MAP_POSITIVE_X_EXT   -rz    -ry   rx 
	-rx          GL_TEXTURE_CUBE_MAP_NEGATIVE_X_EXT   +rz    -ry   rx 
	+ry          GL_TEXTURE_CUBE_MAP_POSITIVE_Y_EXT   +rx    +rz   ry 
	-ry          GL_TEXTURE_CUBE_MAP_NEGATIVE_Y_EXT   +rx    -rz   ry 
	+rz          GL_TEXTURE_CUBE_MAP_POSITIVE_Z_EXT   +rx    -ry   rz 
	-rz          GL_TEXTURE_CUBE_MAP_NEGATIVE_Z_EXT   -rx    -ry   rz

	Using the sc, tc, and ma determined by the major axis direction as specified in the table above,
	an updated (s,t) is calculated as follows 
	s   =   ( sc/|ma| + 1 ) / 2 
	t   =   ( tc/|ma| + 1 ) / 2
	If |ma| is zero or very nearly zero, the results of the above two equations need not be defined
	(though the result may not lead to GL interruption or termination).  Once the cube map face's 2D mipmap
	set and (s,t) is determined, texture fetching and filtering proceeds like standard OpenGL 2D texturing. 
	*/
	// Note this method return U and V in range from 0 to size-1
	// SL END
	// Store the information in vector3 for convenience (faceindex, u, v)
	private function vectToTexelCoord(x:Float, y:Float, z:Float, size:Float):Vector4 {
		var maxCoord:Float;
		var faceIdx:Int;
		
		//absolute value 3
		var absX = Math.abs(x);
		var absY = Math.abs(y);
		var absZ = Math.abs(z);
		
		if (absX >= absY && absX >= absZ) {
			maxCoord = absX;
			
			if (x >= 0) { //face = XPOS
				faceIdx = PMREMGenerator.CP_FACE_X_POS;
			} 
			else {
				faceIdx = PMREMGenerator.CP_FACE_X_NEG;
			}
		} 
		else if (absY >= absX && absY >= absZ) {
			maxCoord = absY;
			
			if (y >= 0) { //face = XPOS
				faceIdx = PMREMGenerator.CP_FACE_Y_POS;
			} 
			else {
				faceIdx = PMREMGenerator.CP_FACE_Y_NEG;
			}
		} 
		else {
			maxCoord = absZ;
			
			if (z >= 0) { //face = XPOS
				faceIdx = PMREMGenerator.CP_FACE_Z_POS;
			} 
			else {
				faceIdx = PMREMGenerator.CP_FACE_Z_NEG;
			}
		}
		
		//divide through by max coord so face vector lies on cube face
		var scale = 1 / maxCoord;
		x *= scale;
		y *= scale;
		z *= scale;
		
		var temp = PMREMGenerator._sgFace2DMapping[faceIdx][PMREMGenerator.CP_UDIR];
		var nvcU = temp[0] * x + temp[1] * y + temp[2] * z;
		
		temp = PMREMGenerator._sgFace2DMapping[faceIdx][PMREMGenerator.CP_VDIR];
		var nvcV = temp[0] * x + temp[1] * y + temp[2] * z;
		
		// Modify original AMD code to return value from 0 to Size - 1
		var u = Math.floor((size - 1) * 0.5 * (nvcU + 1.0));
		var v = Math.floor((size - 1) * 0.5 * (nvcV + 1.0));
		
		PMREMGenerator._vectorTemp.x = faceIdx;
		PMREMGenerator._vectorTemp.y = u;
		PMREMGenerator._vectorTemp.z = v;
		
		return PMREMGenerator._vectorTemp;
	}

	//--------------------------------------------------------------------------------------
	//Original code from Ignacio CastaÒo
	// This formula is from Manne ÷hrstrˆm's thesis.
	// Take two coordiantes in the range [-1, 1] that define a portion of a
	// cube face and return the area of the projection of that portion on the
	// surface of the sphere.
	//--------------------------------------------------------------------------------------
	private function areaElement(x:Float, y:Float):Float {
		return Math.atan2(x * y, Math.sqrt(x * x + y * y + 1));
	}

	private function texelCoordSolidAngle(faceIdx:Int, u:Float, v:Float, size:Int):Float {
		// transform from [0..res - 1] to [- (1 - 1 / res) .. (1 - 1 / res)]
		// (+ 0.5f is for texel center addressing)
		u = (2.0 * (u + 0.5) / size) - 1.0;
		v = (2.0 * (v + 0.5) / size) - 1.0;
		
		// Shift from a demi texel, mean 1.0f / a_Size with U and V in [-1..1]
		var invResolution = 1.0 / size;
		
		// U and V are the -1..1 texture coordinate on the current face.
		// Get projected area for this texel
		var x0 = u - invResolution;
		var y0 = v - invResolution;
		var x1 = u + invResolution;
		var y1 = v + invResolution;
		var solidAngle = this.areaElement(x0, y0) - this.areaElement(x0, y1) - this.areaElement(x1, y0) + this.areaElement(x1, y1);
		
		return solidAngle;
	}

	//--------------------------------------------------------------------------------------
	//The key to the speed of these filtering routines is to quickly define a per-face 
	//  bounding box of pixels which enclose all the taps in the filter kernel efficiently.  
	//  Later these pixels are selectively processed based on their dot products to see if 
	//  they reside within the filtering cone.
	//
	//This is done by computing the smallest per-texel angle to get a conservative estimate 
	// of the number of texels needed to be covered in width and height order to filter the
	// region.  the bounding box for the center taps face is defined first, and if the 
	// filtereing region bleeds onto the other faces, bounding boxes for the other faces are 
	// defined next
	//--------------------------------------------------------------------------------------
	private function filterCubeSurfaces(srcCubeMap:Array<ArrayBufferView>, srcSize:Int, dstCubeMap:Array<ArrayBufferView>, dstSize:Int, filterConeAngle:Float, specularPower:Float) {
		
		// note that pixels within these regions may be rejected 
		// based on the anlge    
		var iCubeFace:Int;
		var u:Float;
		var v:Float;
		
		// bounding box per face to specify region to process
		var filterExtents:Array<CMGBoundinBox> = [];
		for (iCubeFace in 0...6) {
			filterExtents.push(new CMGBoundinBox());
		}
		
		// min angle a src texel can cover (in degrees)
		var srcTexelAngle = (180.0 / (Math.PI) * Math.atan2(1.0, srcSize));
		
		// angle about center tap to define filter cone
		// filter angle is 1/2 the cone angle
		var filterAngle = filterConeAngle / 2.0;
		
		//ensure filter angle is larger than a texel
		if (filterAngle < srcTexelAngle) {
			filterAngle = srcTexelAngle;
		}
		
		//ensure filter cone is always smaller than the hemisphere
		if (filterAngle > 90.0) {
			filterAngle = 90.0;
		}
		
		// the maximum number of texels in 1D the filter cone angle will cover
		//  used to determine bounding box size for filter extents
		var filterSize = Math.ceil(filterAngle / srcTexelAngle);
		
		// ensure conservative region always covers at least one texel
		if (filterSize < 1) {
			filterSize = 1;
		}
		
		// dotProdThresh threshold based on cone angle to determine whether or not taps 
		//  reside within the cone angle
		var dotProdThresh = Math.cos((Math.PI / 180.0) * filterAngle);
		
		// process required faces
		for (iCubeFace in 0...6) {
			//iterate over dst cube map face texel
			for (v in 0...dstSize) {
				for (u in 0...dstSize) {
					//get center tap direction
					var centerTapDir = this.texelCoordToVect(iCubeFace, u, v, dstSize, this.fixup).clone();
					
					//clear old per-face filter extents
					this.clearFilterExtents(filterExtents);
					
					//define per-face filter extents
					this.determineFilterExtents(centerTapDir, srcSize, filterSize, filterExtents);
					
					//perform filtering of src faces using filter extents 
					var vect = this.processFilterExtents(centerTapDir, dotProdThresh, filterExtents, srcCubeMap, srcSize, specularPower);
					
					cast (dstCubeMap[iCubeFace], Float32Array)[(v * dstSize + u) * this.numChannels + 0] = vect.x;
					cast (dstCubeMap[iCubeFace], Float32Array)[(v * dstSize + u) * this.numChannels + 1] = vect.y;
					cast (dstCubeMap[iCubeFace], Float32Array)[(v * dstSize + u) * this.numChannels + 2] = vect.z;
				}
			}
		}
	}

	//--------------------------------------------------------------------------------------
	//Clear filter extents for the 6 cube map faces
	//--------------------------------------------------------------------------------------
	private function clearFilterExtents(filterExtents:Array<CMGBoundinBox>) {
		for (iCubeFaces in 0...6) {
			filterExtents[iCubeFaces].clear();
		}
	}

	//--------------------------------------------------------------------------------------
	//Define per-face bounding box filter extents
	//
	// These define conservative texel regions in each of the faces the filter can possibly 
	// process.  When the pixels in the regions are actually processed, the dot product  
	// between the tap vector and the center tap vector is used to determine the weight of 
	// the tap and whether or not the tap is within the cone.
	//
	//--------------------------------------------------------------------------------------
	private function determineFilterExtents(centerTapDir:Vector4, srcSize:Int, bboxSize:Int, filterExtents:Array<CMGBoundinBox>) {
		//neighboring face and bleed over amount, and width of BBOX for
		// left, right, top, and bottom edges of this face
		var bleedOverAmount:Array<Float> = [0, 0, 0, 0];
		var bleedOverBBoxMin:Array<Float> = [0, 0, 0, 0];
		var bleedOverBBoxMax:Array<Float> = [0, 0, 0, 0];
		
		var neighborFace:Int = 0;
		var neighborEdge:Int = 0;
		var oppositeFaceIdx:Int = 0;

		//get face idx, and u, v info from center tap dir
		var result = this.vectToTexelCoord(centerTapDir.x, centerTapDir.y, centerTapDir.z, srcSize);
		var faceIdx = result.x;
		var u = result.y;
		var v = result.z;
		
		//define bbox size within face
		filterExtents[cast faceIdx].augment(u - bboxSize, v - bboxSize, 0);
		filterExtents[cast faceIdx].augment(u + bboxSize, v + bboxSize, 0);
		
		filterExtents[cast faceIdx].clampMin(0, 0, 0);
		filterExtents[cast faceIdx].clampMax(srcSize - 1, srcSize - 1, 0);
		
		//u and v extent in face corresponding to center tap
		var minU = filterExtents[cast faceIdx].min.x;
		var minV = filterExtents[cast faceIdx].min.y;
		var maxU = filterExtents[cast faceIdx].max.x;
		var maxV = filterExtents[cast faceIdx].max.y;
		
		//bleed over amounts for face across u=0 edge (left)    
		bleedOverAmount[0] = (bboxSize - u);
		bleedOverBBoxMin[0] = minV;
		bleedOverBBoxMax[0] = maxV;
		
		//bleed over amounts for face across u=1 edge (right)    
		bleedOverAmount[1] = (u + bboxSize) - (srcSize - 1);
		bleedOverBBoxMin[1] = minV;
		bleedOverBBoxMax[1] = maxV;
		
		//bleed over to face across v=0 edge (up)
		bleedOverAmount[2] = (bboxSize - v);
		bleedOverBBoxMin[2] = minU;
		bleedOverBBoxMax[2] = maxU;
		
		//bleed over to face across v=1 edge (down)
		bleedOverAmount[3] = (v + bboxSize) - (srcSize - 1);
		bleedOverBBoxMin[3] = minU;
		bleedOverBBoxMax[3] = maxU;
		
		//compute bleed over regions in neighboring faces
		for (i in 0...4) {
			if (bleedOverAmount[i] > 0) {
				neighborFace = PMREMGenerator._sgCubeNgh[cast faceIdx][i][0];
				neighborEdge = PMREMGenerator._sgCubeNgh[cast faceIdx][i][1];
				
				//For certain types of edge abutments, the bleedOverBBoxMin, and bleedOverBBoxMax need to 
				//  be flipped: the cases are 
				// if a left   edge mates with a left or bottom  edge on the neighbor
				// if a top    edge mates with a top or right edge on the neighbor
				// if a right  edge mates with a right or top edge on the neighbor
				// if a bottom edge mates with a bottom or left  edge on the neighbor
				//Seeing as the edges are enumerated as follows 
				// left   =0 
				// right  =1 
				// top    =2 
				// bottom =3            
				// 
				// so if the edge enums are the same, or the sum of the enums == 3, 
				//  the bbox needs to be flipped
				if ((i == neighborEdge) || ((i + neighborEdge) == 3)) {
					bleedOverBBoxMin[i] = (srcSize - 1) - bleedOverBBoxMin[i];
					bleedOverBBoxMax[i] = (srcSize - 1) - bleedOverBBoxMax[i];
				}
				
				//The way the bounding box is extended onto the neighboring face
				// depends on which edge of neighboring face abuts with this one
				switch (PMREMGenerator._sgCubeNgh[cast faceIdx][i][1]) {
					case PMREMGenerator.CP_EDGE_LEFT:
						filterExtents[neighborFace].augment(0, bleedOverBBoxMin[i], 0);
						filterExtents[neighborFace].augment(bleedOverAmount[i], bleedOverBBoxMax[i], 0);
						
					case PMREMGenerator.CP_EDGE_RIGHT:
						filterExtents[neighborFace].augment((srcSize - 1), bleedOverBBoxMin[i], 0);
						filterExtents[neighborFace].augment((srcSize - 1) - bleedOverAmount[i], bleedOverBBoxMax[i], 0);
						
					case PMREMGenerator.CP_EDGE_TOP:
						filterExtents[neighborFace].augment(bleedOverBBoxMin[i], 0, 0);
						filterExtents[neighborFace].augment(bleedOverBBoxMax[i], bleedOverAmount[i], 0);
						
					case PMREMGenerator.CP_EDGE_BOTTOM:
						filterExtents[neighborFace].augment(bleedOverBBoxMin[i], (srcSize - 1), 0);
						filterExtents[neighborFace].augment(bleedOverBBoxMax[i], (srcSize - 1) - bleedOverAmount[i], 0);
					
				}
				
				//clamp filter extents in non-center tap faces to remain within surface
				filterExtents[neighborFace].clampMin(0, 0, 0);
				filterExtents[neighborFace].clampMax(srcSize - 1, srcSize - 1, 0);
			}
			
			//If the bleed over amount bleeds past the adjacent face onto the opposite face 
			// from the center tap face, then process the opposite face entirely for now. 
			//Note that the cases in which this happens, what usually happens is that 
			// more than one edge bleeds onto the opposite face, and the bounding box 
			// encompasses the entire cube map face.
			if (bleedOverAmount[i] > srcSize) {
				//determine opposite face 
				switch (faceIdx) {
					case PMREMGenerator.CP_FACE_X_POS:
						oppositeFaceIdx = PMREMGenerator.CP_FACE_X_NEG;
						
					case PMREMGenerator.CP_FACE_X_NEG:
						oppositeFaceIdx = PMREMGenerator.CP_FACE_X_POS;
						
					case PMREMGenerator.CP_FACE_Y_POS:
						oppositeFaceIdx = PMREMGenerator.CP_FACE_Y_NEG;
						
					case PMREMGenerator.CP_FACE_Y_NEG:
						oppositeFaceIdx = PMREMGenerator.CP_FACE_Y_POS;
						
					case PMREMGenerator.CP_FACE_Z_POS:
						oppositeFaceIdx = PMREMGenerator.CP_FACE_Z_NEG;
						
					case PMREMGenerator.CP_FACE_Z_NEG:
						oppositeFaceIdx = PMREMGenerator.CP_FACE_Z_POS;
						
					default:
						//
				}
				
				//just encompass entire face for now
				filterExtents[oppositeFaceIdx].augment(0, 0, 0);
				filterExtents[oppositeFaceIdx].augment((srcSize - 1), (srcSize - 1), 0);
			}
		}
	}

	//--------------------------------------------------------------------------------------
	//ProcessFilterExtents 
	//  Process bounding box in each cube face 
	//
	//--------------------------------------------------------------------------------------
	private function processFilterExtents(centerTapDir:Vector4, dotProdThresh:Float, filterExtents:Array<CMGBoundinBox>,
		srcCubeMap:Array<ArrayBufferView>, srcSize:Int, specularPower:Float):Vector4 {
		//accumulators are 64-bit floats in order to have the precision needed 
		// over a summation of a large number of pixels 
		var dstAccum:Array<Float> = [0, 0, 0, 0];
		var weightAccum:Float = 0;
		var nSrcChannels = this.numChannels;
		
		// norm cube map and srcCubeMap have same face width
		var faceWidth = srcSize;
		
		//amount to add to pointer to move to next scanline in images
		var normCubePitch = faceWidth * 4; // 4 channels in normCubeMap.
		var srcCubePitch = faceWidth * this.numChannels; // numChannels correponds to the cubemap number of channel
		
		var IsPhongBRDF = 1; // Only works in Phong BRDF yet.
		//(a_LightingModel == CP_LIGHTINGMODEL_PHONG_BRDF || a_LightingModel == CP_LIGHTINGMODEL_BLINN_BRDF) ? 1 : 0; // This value will be added to the specular power
		
		// iterate over cubefaces
		for (iFaceIdx in 0...6) {
			//if bbox is non empty
			if (!filterExtents[iFaceIdx].empty()) {
				var uStart:Int = cast filterExtents[iFaceIdx].min.x;
				var vStart:Int = cast filterExtents[iFaceIdx].min.y;
				var uEnd:Int = cast filterExtents[iFaceIdx].max.x;
				var vEnd:Int = cast filterExtents[iFaceIdx].max.y;
				
				var startIndexNormCubeMap = (4 * ((vStart * faceWidth) + uStart));
				var startIndexSrcCubeMap = (this.numChannels * ((vStart * faceWidth) + uStart));
				
				//note that <= is used to ensure filter extents always encompass at least one pixel if bbox is non empty
				for (v in vStart...vEnd + 1) {
					var normCubeRowWalk:Int = 0;
					var srcCubeRowWalk:Int = 0;
					
					for (u in uStart...uEnd + 1) {
						//pointer to direction in cube map associated with texel
						var texelVectX = cast (this._normCubeMap[iFaceIdx], Float32Array)[startIndexNormCubeMap + normCubeRowWalk + 0];
						var texelVectY = cast (this._normCubeMap[iFaceIdx], Float32Array)[startIndexNormCubeMap + normCubeRowWalk + 1];
						var texelVectZ = cast (this._normCubeMap[iFaceIdx], Float32Array)[startIndexNormCubeMap + normCubeRowWalk + 2];
						
						//check dot product to see if texel is within cone
						var tapDotProd = texelVectX * centerTapDir.x +
							texelVectY * centerTapDir.y +
							texelVectZ * centerTapDir.z;
							
						if (tapDotProd >= dotProdThresh && tapDotProd > 0.0) {
							//solid angle stored in 4th channel of normalizer/solid angle cube map
							var weight = cast (this._normCubeMap[iFaceIdx], Float32Array)[startIndexNormCubeMap + normCubeRowWalk + 3];
							
							// Here we decide if we use a Phong/Blinn or a Phong/Blinn BRDF.
							// Phong/Blinn BRDF is just the Phong/Blinn model multiply by the cosine of the lambert law
							// so just adding one to specularpower do the trick.    
							weight *= Math.pow(tapDotProd, (specularPower + IsPhongBRDF));
							
							//iterate over channels
							for (k in 0...nSrcChannels) { //(aSrcCubeMap[iFaceIdx].m_NumChannels) //up to 4 channels 
								dstAccum[k] += weight * cast (srcCubeMap[iFaceIdx], Float32Array)[startIndexSrcCubeMap + srcCubeRowWalk];
								srcCubeRowWalk++;
							}
							
							weightAccum += weight; //accumulate weight
						} 
						else {
							//step across source pixel
							srcCubeRowWalk += nSrcChannels;
						}
						
						normCubeRowWalk += 4; // 4 channels per norm cube map.
					}
					
					startIndexNormCubeMap += normCubePitch;
					startIndexSrcCubeMap += srcCubePitch;
				}
			}
		}
		
		//divide through by weights if weight is non zero
		if (weightAccum != 0.0) {
			PMREMGenerator._vectorTemp.x = (dstAccum[0] / weightAccum);
			PMREMGenerator._vectorTemp.y = (dstAccum[1] / weightAccum);
			PMREMGenerator._vectorTemp.z = (dstAccum[2] / weightAccum);
			if (this.numChannels > 3) {
				PMREMGenerator._vectorTemp.w = (dstAccum[3] / weightAccum);
			}
		} 
		else {
			// otherwise sample nearest
			// get face idx and u, v texel coordinate in face
			var coord = this.vectToTexelCoord(centerTapDir.x, centerTapDir.y, centerTapDir.z, srcSize).clone();
			
			PMREMGenerator._vectorTemp.x = cast (srcCubeMap[cast coord.x], Float32Array)[Std.int(this.numChannels * (coord.z * srcSize + coord.y) + 0)];
			PMREMGenerator._vectorTemp.y = cast (srcCubeMap[cast coord.x], Float32Array)[Std.int(this.numChannels * (coord.z * srcSize + coord.y) + 1)];
			PMREMGenerator._vectorTemp.z = cast (srcCubeMap[cast coord.x], Float32Array)[Std.int(this.numChannels * (coord.z * srcSize + coord.y) + 2)];
			if (this.numChannels > 3) {
				PMREMGenerator._vectorTemp.z = cast (srcCubeMap[cast coord.x], Float32Array)[Std.int(this.numChannels * (coord.z * srcSize + coord.y) + 3)];
			}
		}
		
		return PMREMGenerator._vectorTemp;
	}

	//--------------------------------------------------------------------------------------
	// Fixup cube edges
	//
	// average texels on cube map faces across the edges
	// WARP/BENT Method Only.
	//--------------------------------------------------------------------------------------
	private function fixupCubeEdges(cubeMap:Array<ArrayBufferView>, cubeMapSize:Int) {
		var iFace:Int = 0;
		var iCorner:Int = 0;

		var cornerNumPtrs = [0, 0, 0, 0, 0, 0, 0, 0]; //indexed by corner and face idx
		var faceCornerStartIndicies:Array<Array<Int>> = [
			[],
			[],
			[],
			[]
		]; //corner pointers for face keeping track of the face they belong to.

		// note that if functionality to filter across the three texels for each corner, then 
		//indexed by corner and face idx. the array contains the face the start points belongs to.
		var cornerPtr:Array<Array<Array<Int>>> = [
			[
				[],
				[],
				[]
			],
			[
				[],
				[],
				[]
			],
			[
				[],
				[],
				[]
			],
			[
				[],
				[],
				[]
			],
			[
				[],
				[],
				[]
			],
			[
				[],
				[],
				[]
			],
			[
				[],
				[],
				[]
			],
			[
				[],
				[],
				[]
			]
		];
		
		//if there is no fixup, or fixup width = 0, do nothing
		if (cubeMapSize < 1) {
			return;
		}
		
		//special case 1x1 cubemap, average face colors
		if (cubeMapSize == 1) {
			//iterate over channels
			for (k in 0...this.numChannels) {
				var accum = 0.0;
				
				//iterate over faces to accumulate face colors
				for (iFace in 0...6) {
					accum += cast (cubeMap[iFace], Float32Array)[k];
				}
				
				//compute average over 6 face colors
				accum /= 6.0;
				
				//iterate over faces to distribute face colors
				for (iFace in 0...6) {
					cast (cubeMap[iFace], Float32Array)[k] = accum;
				}
			}
			
			return;
		}
		
		//iterate over faces to collect list of corner texel pointers
		for (iFace in 0...6) {
			//the 4 corner pointers for this face
			faceCornerStartIndicies[0] = [iFace, 0];
			faceCornerStartIndicies[1] = [iFace, ((cubeMapSize - 1) * this.numChannels)];
			faceCornerStartIndicies[2] = [iFace, ((cubeMapSize) * (cubeMapSize - 1) * this.numChannels)];
			faceCornerStartIndicies[3] = [iFace, ((((cubeMapSize) * (cubeMapSize - 1)) + (cubeMapSize - 1)) * this.numChannels)];
			
			//iterate over face corners to collect cube corner pointers
			for (iCorner in 0...4) {
				var corner = PMREMGenerator._sgCubeCornerList[iFace][iCorner];
				cornerPtr[corner][cornerNumPtrs[corner]] = faceCornerStartIndicies[iCorner];
				cornerNumPtrs[corner]++;
			}
		}
		
		//iterate over corners to average across corner tap values
		for (iCorner in 0...8) {
			for (k in 0...this.numChannels) {
				var cornerTapAccum = 0.0;
				
				//iterate over corner texels and average results
				for (i in 0...3) {
					cornerTapAccum += cast (cubeMap[cornerPtr[iCorner][i][0]], Float32Array)[cornerPtr[iCorner][i][1] + k]; // Get in the cube map face the start point + channel.
				}
				
				//divide by 3 to compute average of corner tap values
				cornerTapAccum *= (1.0 / 3.0);
				
				//iterate over corner texels and average results
				for (i in 0...3) {
					cast (cubeMap[cornerPtr[iCorner][i][0]], Float32Array)[cornerPtr[iCorner][i][1] + k] = cornerTapAccum;
				}
			}
		}
		
		//iterate over the twelve edges of the cube to average across edges
		for (i in 0...12) {
			var face = PMREMGenerator._sgCubeEdgeList[i][0];
			var edge = PMREMGenerator._sgCubeEdgeList[i][1];
			
			var neighborFace = PMREMGenerator._sgCubeNgh[face][edge][0];
			var neighborEdge = PMREMGenerator._sgCubeNgh[face][edge][1];
			
			var edgeStartIndex = 0; // a_CubeMap[face].m_ImgData;
			var neighborEdgeStartIndex = 0; // a_CubeMap[neighborFace].m_ImgData;
			var edgeWalk = 0;
			var neighborEdgeWalk = 0;
			
			//Determine walking pointers based on edge type
			// e.g. CP_EDGE_LEFT, CP_EDGE_RIGHT, CP_EDGE_TOP, CP_EDGE_BOTTOM
			switch (edge) {
				case PMREMGenerator.CP_EDGE_LEFT:
					// no change to faceEdgeStartPtr  
					edgeWalk = this.numChannels * cubeMapSize;
					
				case PMREMGenerator.CP_EDGE_RIGHT:
					edgeStartIndex += (cubeMapSize - 1) * this.numChannels;
					edgeWalk = this.numChannels * cubeMapSize;
					
				case PMREMGenerator.CP_EDGE_TOP:
					// no change to faceEdgeStartPtr  
					edgeWalk = this.numChannels;
					
				case PMREMGenerator.CP_EDGE_BOTTOM:
					edgeStartIndex += (cubeMapSize) * (cubeMapSize - 1) * this.numChannels;
					edgeWalk = this.numChannels;
				
			}
			
			//For certain types of edge abutments, the neighbor edge walk needs to 
			//  be flipped: the cases are 
			// if a left   edge mates with a left or bottom  edge on the neighbor
			// if a top    edge mates with a top or right edge on the neighbor
			// if a right  edge mates with a right or top edge on the neighbor
			// if a bottom edge mates with a bottom or left  edge on the neighbor
			//Seeing as the edges are enumerated as follows 
			// left   =0 
			// right  =1 
			// top    =2 
			// bottom =3            
			// 
			//If the edge enums are the same, or the sum of the enums == 3, 
			//  the neighbor edge walk needs to be flipped
			if ((edge == neighborEdge) || ((edge + neighborEdge) == 3)) { //swapped direction neighbor edge walk
				switch (neighborEdge) {
					case PMREMGenerator.CP_EDGE_LEFT: //start at lower left and walk up
						neighborEdgeStartIndex += (cubeMapSize - 1) * (cubeMapSize) * this.numChannels;
						neighborEdgeWalk = -(this.numChannels * cubeMapSize);
						
					case PMREMGenerator.CP_EDGE_RIGHT: //start at lower right and walk up
						neighborEdgeStartIndex += ((cubeMapSize - 1) * (cubeMapSize) + (cubeMapSize - 1)) * this.numChannels;
						neighborEdgeWalk = -(this.numChannels * cubeMapSize);
						
					case PMREMGenerator.CP_EDGE_TOP: //start at upper right and walk left
						neighborEdgeStartIndex += (cubeMapSize - 1) * this.numChannels;
						neighborEdgeWalk = -this.numChannels;
						
					case PMREMGenerator.CP_EDGE_BOTTOM: //start at lower right and walk left
						neighborEdgeStartIndex += ((cubeMapSize - 1) * (cubeMapSize) + (cubeMapSize - 1)) * this.numChannels;
						neighborEdgeWalk = -this.numChannels;
						
				}
			} 
			else {
				//swapped direction neighbor edge walk
				switch (neighborEdge) {
					case PMREMGenerator.CP_EDGE_LEFT: //start at upper left and walk down
						//no change to neighborEdgeStartPtr for this case since it points 
						// to the upper left corner already
						neighborEdgeWalk = this.numChannels * cubeMapSize;
						
					case PMREMGenerator.CP_EDGE_RIGHT: //start at upper right and walk down
						neighborEdgeStartIndex += (cubeMapSize - 1) * this.numChannels;
						neighborEdgeWalk = this.numChannels * cubeMapSize;
						
					case PMREMGenerator.CP_EDGE_TOP: //start at upper left and walk left
						//no change to neighborEdgeStartPtr for this case since it points 
						// to the upper left corner already
						neighborEdgeWalk = this.numChannels;
						
					case PMREMGenerator.CP_EDGE_BOTTOM: //start at lower left and walk left
						neighborEdgeStartIndex += (cubeMapSize) * (cubeMapSize - 1) * this.numChannels;
						neighborEdgeWalk = this.numChannels;
					
				}
			}
			
			//Perform edge walk, to average across the 12 edges and smoothly propagate change to 
			//nearby neighborhood
			
			//step ahead one texel on edge
			edgeStartIndex += edgeWalk;
			neighborEdgeStartIndex += neighborEdgeWalk;
			
			// note that this loop does not process the corner texels, since they have already been
			//  averaged across faces across earlier
			for (j in 1...cubeMapSize - 1) {
				//for each set of taps along edge, average them
				// and rewrite the results into the edges
				for (k in 0...this.numChannels) {
					var edgeTap = cast (cubeMap[face], Float32Array)[edgeStartIndex + k];
					var neighborEdgeTap = cast (cubeMap[neighborFace], Float32Array)[neighborEdgeStartIndex + k];
					
					//compute average of tap intensity values
					var avgTap = 0.5 * (edgeTap + neighborEdgeTap);
					
					//propagate average of taps to edge taps
					cast (cubeMap[face], Float32Array)[edgeStartIndex + k] = avgTap;
					cast (cubeMap[neighborFace], Float32Array)[neighborEdgeStartIndex + k] = avgTap;
				}
				
				edgeStartIndex += edgeWalk;
				neighborEdgeStartIndex += neighborEdgeWalk;
			}
		}
	}
	
}
