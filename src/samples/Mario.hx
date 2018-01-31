package samples;

import mario.def.SoundManager;

import com.babylonhx.Engine;
import com.babylonhx.Scene;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.cameras.Camera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.InstancedMesh;
import com.babylonhx.serializers.obj.ObjExport;
import com.babylonhxext.loaders.obj.ObjLoader;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.particles.ParticleSystem;

import com.babylonhx.postprocess.VolumetricLightScatteringPostProcess;

import com.babylonhx.postprocess.PostProcess;
import com.babylonhx.postprocess.DreamVisionPostProcess;
import com.babylonhx.postprocess.ThermalVisionPostProcess;
import com.babylonhx.postprocess.BloomPostProcess;
import com.babylonhx.postprocess.CrossHatchingPostProcess;
import com.babylonhx.postprocess.NightVisionPostProcess;
import com.babylonhx.postprocess.CrossStitchingPostProcess;
import com.babylonhx.postprocess.VignettePostProcess;
import com.babylonhx.postprocess.KnittedPostProcess;
import com.babylonhx.postprocess.Blur2PostProcess;
import com.babylonhx.postprocess.ScreenDistortionPostProcess;
import com.babylonhx.postprocess.VibrancePostProcess;
import com.babylonhx.postprocess.HueSaturationPostProcess;
import com.babylonhx.postprocess.InkPostProcess;
import com.babylonhx.postprocess.HexagonalPixelatePostProcess;
import com.babylonhx.postprocess.NaturalColorPostProcess;
import com.babylonhx.postprocess.MosaicPostProcess;
import com.babylonhx.postprocess.BleachBypassPostProcess;
import com.babylonhx.postprocess.LimbDarkeningPostProcess;

import com.babylonhx.animations.Animation;
import com.babylonhx.actions.ActionEvent;

/*import com.babylonhxext.gui.GUIGroup;
import com.babylonhxext.gui.GUIObject;
import com.babylonhxext.gui.GUIPanel;
import com.babylonhxext.gui.GUISystem;*/

import haxe.Timer;


import haxe.Json;
import mario.KeyBoard;
//import mario.MobileInput;
import mario.def.LevelFormat;
import mario.engine.Level;

import mario.figures.*;

#if js
import js.Browser;
import js.html.Audio;
#else
import lime.audio.AudioSource;
#end

/**
 * ...
 * @author Krtolica Vujadin
 */
class Mario {
	
	var level:String = '{"width":252,"height":30,"id":0,"background":1,"data":[["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","pipe_top_left","pipe_left","pipe_left_grass","pipe_left_soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","pipe_top_right","pipe_right","pipe_right_grass","pipe_right_soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","mario","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","multiple_coinbox","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","planted_soil_left"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","planted_soil_middle"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","planted_soil_right"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","bush_left","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","bush_middle","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","bush_middle_right","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","bush_right","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","mushroombox","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","pipe_top_left","pipe_left","pipe_left_grass","pipe_left_soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","pipe_top_right","pipe_right","pipe_right_grass","pipe_right_soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","coinbox","","","","brown_block","brown_block","brown_block","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","brown_block","brown_block","brown_block","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","pipe_top_left","pipe_left","pipe_left_grass","pipe_left_soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","pipe_top_right","pipe_right","pipe_right_grass","pipe_right_soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","coinbox","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","ballmonster","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","grass_top_left","grass_left","grass_left","grass_top_left_corner","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil","soil","soil","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil","soil","soil","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil","soil","soil","soil"],["","","","","","","","","","","","","","","","","","","","","","coinbox","","","","grass_top","soil","planted_soil_left","soil","soil"],["","","","","","","","","","","","","","","","","","","","","","brown_block","","","","grass_top","soil","planted_soil_right","soil","soil"],["","","","","","","","","","","","","","","","","","","","","","coinbox","","","","grass_top","soil","soil","soil","soil"],["","","","","","","","","","","","","","","","","","","","","","brown_block","","","","grass_top","soil","soil","soil","soil"],["","","","","","","","","","","","","","","","","","","","","","coinbox","","","","grass_top","soil","soil","soil","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil","soil","soil","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil","soil","soil","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil","soil","soil","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","ballmonster","grass_top","soil","soil","soil","soil"],["","","","","","","","","","","","","","","","","","","","","","","pipe_top_left","pipe_left","pipe_left","pipe_left_grass","pipe_left_soil","pipe_left_soil","pipe_left_soil","pipe_left_soil"],["","","","","","","","","","","","","","","","","","","","","","","pipe_top_right","pipe_right","pipe_right","pipe_right","pipe_right","pipe_right","pipe_right_grass","pipe_right_soil"],["","","","","","","","","","","","","","","","","","","","","brown_block","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","brown_block","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","brown_block","","","","coinbox","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","brown_block","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","brown_block","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","ballmonster","brown_block","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","coin","coin","coin","coin","coin","coin","coin","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top_right_rounded","soil_right"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top_left_rounded","soil_left"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","brown_block","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","mushroombox","","","","brown_block","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","brown_block","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","pipe_top_left","pipe_left","pipe_left_grass","pipe_left_soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","pipe_top_right","pipe_right","pipe_right_grass","pipe_right_soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","coinbox","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","bush_left","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","bush_middle_left","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","bush_middle","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","brown_block","","","bush_middle_right","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","brown_block","","","bush_right","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","coinbox","","","","brown_block","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","coinbox","","","","brown_block","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","coinbox","","","","coinbox","","","","brown_block","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","coinbox","","","","coinbox","","","","brown_block","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","coinbox","","","","brown_block","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","coinbox","","","","brown_block","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","brown_block","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","brown_block","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","greenturtle","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top_right_rounded","soil_right"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top_left_rounded","soil_left"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","pipe_top_left","pipe_left","pipe_left_grass","pipe_left_soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","pipe_top_right","pipe_right","pipe_right_grass","pipe_right_soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","coinbox","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","planted_soil_left"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","ballmonster","grass_top","planted_soil_middle"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","planted_soil_right"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","coinbox","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","greenturtle","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","pipe_top_left","pipe_left","pipe_left_grass","pipe_left_soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","pipe_top_right","pipe_right","pipe_right_grass","pipe_right_soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","ballmonster","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","starbox","","","","brown_block","brown_block","brown_block","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","brown_block","brown_block","brown_block","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","grass_top_left","grass_left","grass_left","grass_top_left_corner","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil","soil","soil","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil","soil","soil","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil","soil","soil","soil"],["","","","","","","","","","","","","","","","","","","","","","coinbox","","","","grass_top","soil","soil","soil","soil"],["","","","","","","","","","","","","","","","","","","","","","brown_block","","","","grass_top","soil","soil","soil","soil"],["","","","","","","","","","","","","","","","","","","","","","coinbox","","","","grass_top","soil","soil","soil","soil"],["","","","","","","","","","","","","","","","","","","","","","brown_block","","","","grass_top","planted_soil_left","soil","soil","soil"],["","","","","","","","","","","","","","","","","","","","","","coinbox","","","","grass_top","planted_soil_middle","soil","soil","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","planted_soil_right","soil","soil","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil","soil","soil","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil","soil","soil","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil","soil","soil","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil","soil","soil","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil","soil","soil","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","ballmonster","grass_top","soil","soil","soil","soil"],["","","","","","","","","","","","","","","","","","","","","","","pipe_top_left","pipe_left","pipe_left","pipe_left_grass","pipe_left_soil","pipe_left_soil","pipe_left_soil","pipe_left_soil"],["","","","","","","","","","","","","","","","","","","","","","","pipe_top_right","pipe_right","pipe_right","pipe_right","pipe_right","pipe_right","pipe_right_grass","pipe_right_soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","coinbox","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","ballmonster","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","pipe_top_left","pipe_left","pipe_left_grass","pipe_left_soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","pipe_top_right","pipe_right","pipe_right_grass","pipe_right_soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","ballmonster","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","coinbox","","","","brown_block","brown_block","brown_block","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","brown_block","brown_block","brown_block","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","pipe_top_left","pipe_left","pipe_left_grass","pipe_left_soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","pipe_top_right","pipe_right","pipe_right_grass","pipe_right_soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","greenturtle","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","bush_left","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","bush_middle_left","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","bush_middle_right","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","bush_right","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","greenturtle","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top_right_rounded","soil_right"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""],["","","","","","","","","","","","","","","","","","","","","","","","","","","brown_block","brown_block","grass_top_left_rounded","soil_left"],["","","","","","","","","","","","","","","","","","","","","","","","","","","brown_block","brown_block","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","brown_block","brown_block","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","brown_block","brown_block","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","brown_block","brown_block","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","brown_block","brown_block","brown_block","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","brown_block","brown_block","brown_block","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","stone","","","","brown_block","brown_block","brown_block","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","stone","","","","brown_block","brown_block","brown_block","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","multiple_coinbox","","","","brown_block","brown_block","brown_block","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","brown_block","brown_block","brown_block","grass_top_right_rounded","soil_right"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""],["","","","","","","","","","","","","","","","","","","","","","","","","","","","brown_block","grass_top_left_rounded","soil_left"],["","","","","","","","","","","","","","","","","","","","","","","","","","","brown_block","brown_block","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","brown_block","brown_block","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","brown_block","coin","brown_block","brown_block","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","brown_block","brown_block","","brown_block","brown_block","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","brown_block","brown_block","coin","brown_block","brown_block","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","brown_block","","brown_block","brown_block","","brown_block","brown_block","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","brown_block","brown_block","coin","brown_block","brown_block","coin","brown_block","brown_block","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","brown_block","brown_block","brown_block","","brown_block","brown_block","brown_block","brown_block","brown_block","grass_top","soil"],["","","","","","","","","","","","","","","","","","","brown_block","brown_block","brown_block","brown_block","coin","brown_block","brown_block","brown_block","brown_block","brown_block","grass_top","soil"],["","","","","","","","","","","","","","","","","","brown_block","brown_block","brown_block","brown_block","brown_block","","brown_block","brown_block","brown_block","brown_block","brown_block","grass_top","soil"],["","","","","","","","","","","","","","","","","brown_block","brown_block","brown_block","brown_block","brown_block","brown_block","coin","brown_block","brown_block","brown_block","brown_block","brown_block","grass_top","soil"],["","","","","","","","","","","","","","","","","brown_block","brown_block","brown_block","brown_block","brown_block","brown_block","","brown_block","brown_block","brown_block","brown_block","brown_block","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","coin","","coin","","coin","","coin","","coin","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"],["","","","","","","","","","","","","","","","","","","","","","","","","","","","","grass_top","soil"]]}';
	
	var baseMesh:Mesh;
	var allMeshes:Map<String, Mesh> = new Map();
	var levelMario:Level;
	
	var engine:Engine;
	
	#if (!js && lime && !openfl)
	private var ambience:AudioSource;
	#end
	

	public function new(scene:Scene) {
		this.engine = scene.getEngine();
		
		#if js
		if (untyped Browser.window.parent.level3D != null) {
			level = untyped Browser.window.parent.level3D;
		}
		/*Browser.window.document.onmousedown = function(event) {
			if (untyped event.button == 2) {
				var allObjs:Array<Dynamic> = [];
				var allMtls:Array<Dynamic> = [];
				
				var bmMtl:String = ObjExport.MTL(baseMesh);
				allMtls.push(bmMtl);
				
				for (m in allMeshes) {
					baseMesh.position.copyFrom(m.position);
					var bmObj:String = ObjExport.OBJ(baseMesh);					
					
					allObjs.push(bmObj);
				}	
			}
		}*/
		#end
		
		#if (lime && !openfl)
		SoundManager.sfx["jump"] = new AudioSource(lime.Assets.getAudioBuffer("assets/sounds/jump.ogg"));
		SoundManager.sfx["hurt"] = new AudioSource(lime.Assets.getAudioBuffer("assets/sounds/hurt.ogg"));
		SoundManager.sfx["die"] = new AudioSource(lime.Assets.getAudioBuffer("assets/sounds/die.ogg"));
		#end
		
		var camera = new ArcRotateCamera("fcam", 7.85571150914772, 1.406620390355844, 400, new Vector3(20, 500, -200), scene);
		//camera.attachControl();
		
		var light = new HemisphericLight("light1", new Vector3(0, 1, 0), scene);
		
		var skybox = Mesh.CreateBox("skyBox", 10000.0, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/TropicalSunnyDay", scene);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		#if android
		skyboxMaterial.disableLighting = true;
		#end
		skybox.material = skyboxMaterial;
		skybox.infiniteDistance = true;
		
		var baseMat:StandardMaterial = new StandardMaterial("baseMat", scene);
		baseMat.diffuseTexture = new Texture("assets/img/ground4.jpg", scene);
		
		var goomba:Mesh = null;
		var questionBox:Mesh = null;
		var brickblock:Mesh = null;
		var koopaShell:Mesh = null;
		var musroom:Mesh = null;
		var grass:Mesh = null;
		var pipe:Mesh = null;
		var coin:Mesh = null;
		var star:Mesh = null;
		var mario:Mesh = null;
		var bullet:Mesh = Mesh.CreateSphere("bullet", 16, 16, scene);
		var ghost:Mesh = Mesh.CreateSphere("ghost", 32, 32, scene);
		ghost.material = new StandardMaterial("ghostmat", scene);
		cast(ghost.material, StandardMaterial).diffuseColor = Color3.Blue();
		cast(ghost.material, StandardMaterial).alpha = 0.5;
		ghost.setEnabled(false);
		var coinBox:Mesh = Mesh.CreateBox("coinbox", 28, scene);
		coinBox.material = new StandardMaterial("coinboxmat", scene);
		cast(coinBox.material, StandardMaterial).diffuseColor = Color3.Yellow();
		coinBox.setEnabled(false);
		
		var marioSkel:Array<Skeleton> = [];
		
		baseMesh = Mesh.CreateBox("box", 32, scene);
		baseMesh.material = baseMat;
		baseMesh.setEnabled(false);
		
		allMeshes.set("base", baseMesh);
		allMeshes.set("bullet", bullet);
		allMeshes.set("ghost", ghost);
		allMeshes.set("coinbox", coinBox);
		
		pipe = Mesh.CreateBox("box", 32, scene);
		var pipeMat = new StandardMaterial("pipemat", scene);
		pipeMat.diffuseColor = Color3.Green();
		pipe.material = pipeMat;
		pipe.setEnabled(false);
		allMeshes.set("pipe", pipe);
		
		var objLoader = new ObjLoader(scene);
		
		SceneLoader.ImportMesh("", "assets/models/koopashell/", "koopashell.babylon", scene, function (newMeshes:Array<AbstractMesh>, newParticles:Array<ParticleSystem>, newSkeletons:Array<Skeleton>) {
			koopaShell = cast newMeshes[0];
			koopaShell.scaling.set(5, 5, 5);
			allMeshes.set("koopaShell", koopaShell);
			koopaShell.setEnabled(false);
		});
		
		SceneLoader.ImportMesh("", "assets/models/brickblock/", "brickblock.babylon", scene, function (newMeshes:Array<AbstractMesh>, newParticles:Array<ParticleSystem>, newSkeletons:Array<Skeleton>) {
			brickblock = cast newMeshes[0];
			brickblock.setEnabled(false);
			allMeshes.set("brickblock", brickblock);
		});
		
		SceneLoader.ImportMesh("", "assets/models/star/", "star.babylon", scene, function (newMeshes:Array<AbstractMesh>, newParticles:Array<ParticleSystem>, newSkeletons:Array<Skeleton>) {
			star = cast newMeshes[0];
			star.setEnabled(false);
			allMeshes.set("star", star);
		});
		
		SceneLoader.ImportMesh("", "assets/models/coin/", "coin.babylon", scene, function (newMeshes:Array<AbstractMesh>, newParticles:Array<ParticleSystem>, newSkeletons:Array<Skeleton>) {
			coin = cast newMeshes[0];
			coin.setEnabled(false);
			allMeshes.set("coin", coin);
		});
		
		mario = Mesh.CreateBox("box", 32, scene);
		allMeshes.set("mario", mario);
		
		/*SceneLoader.ImportMesh("", "assets/models/demon/", "demon.babylon", scene, function (newMeshes:Array<AbstractMesh>, newParticles:Array<ParticleSystem>, newSkeletons:Array<Skeleton>) {
			mario = Mesh.CreateBox("box", 0.1, scene);
			mario = Mesh.CreateBox("box", 32, scene);
			//mario.setEnabled(false);
			allMeshes.set("mario", mario);
			
			//var editControl = new com.babylonhxext.editcontrol.EditControl(mario, camera, 1);
			//editControl.enableTranslation();d
			
			for (m in newMeshes) {
				m.parent = mario;
				m.rotation.y = Math.PI / 2;
				m.scaling = new Vector3(0.32, 0.32, 0.32);
				m.position.y = -14.5;
			}
			
			scene.beginAnimation(newSkeletons[0], 60, 109, true, 0.7);
			scene.beginAnimation(newSkeletons[1], 60, 109, true, 0.7);
			
			marioSkel.push(newSkeletons[0]);
			marioSkel.push(newSkeletons[1]);
		});*/
		
		SceneLoader.ImportMesh("", "assets/models/mushrooms/", "Mushrooms.babylon", scene, function (newMeshes:Array<AbstractMesh>, newParticles:Array<ParticleSystem>, newSkeletons:Array<Skeleton>) {
			musroom = cast newMeshes[0];
			musroom.setEnabled(false);
			allMeshes.set("mushroom", musroom);
		});
		
		SceneLoader.ImportMesh("", "assets/models/level1/", "level1.babylon", scene, function (newMeshes:Array<AbstractMesh>, newParticles:Array<ParticleSystem>, newSkeletons:Array<Skeleton>) {
			trace("level meshes: " +  newMeshes.length);
			for (mesh in newMeshes) {
				mesh.scaling.set(1, 1, 1);
			}
			
			var matt = scene.getMaterialByID("level1.Coniferous01Mat");
			cast(matt, StandardMaterial).useAlphaFromDiffuseTexture = true;
			cast(matt, StandardMaterial).backFaceCulling = false;
			matt = scene.getMaterialByID("level1.Decidious01Mat");
			cast(matt, StandardMaterial).useAlphaFromDiffuseTexture = true;
			cast(matt, StandardMaterial).backFaceCulling = false;
		});
		
		SceneLoader.ImportMesh("", "assets/models/goomba/", "goomba.babylon", scene, function (newMeshes:Array<AbstractMesh>, newParticles:Array<ParticleSystem>, newSkeletons:Array<Skeleton>) {
			goomba = cast newMeshes[0];
			goomba.setEnabled(false);
			allMeshes.set("ballmonster", goomba);
			
			SceneLoader.ImportMesh("", "assets/models/grass/", "grass.babylon", scene, function (newMeshes:Array<AbstractMesh>, newParticles:Array<ParticleSystem>, newSkeletons:Array<Skeleton>) {
				grass = cast newMeshes[0];
				grass.setEnabled(false);
				allMeshes.set("grass", grass);
				
				SceneLoader.ImportMesh("", "assets/models/questionblock/", "questionblock.babylon", scene, function (newMeshes:Array<AbstractMesh>, newParticles:Array<ParticleSystem>, newSkeletons:Array<Skeleton>) {
					questionBox = cast newMeshes[0];
					questionBox.setEnabled(false);
					allMeshes.set("mushroombox", questionBox);
					
					var lvl = Json.parse(level);
					
					//#if mobile
					//levelMario = new Level("test", new MobileInput(scene), scene.getEngine(), allMeshes);
					//#else
					levelMario = new Level("test", new KeyBoard(), scene.getEngine(), allMeshes);
					//#end
					levelMario.scene = scene;
					levelMario.marioSkel = marioSkel;
					levelMario.load(new LevelFormat(level));
					levelMario.start();
					
					/*var lvlData:Array<Array<String>> = cast lvl.data;
					for (i in 0...lvlData.length) {
						for (j in 0...lvlData[i].length) {
							if (lvlData[i][j] != "" && lvlData[i][j].indexOf("bush") == -1) {
								switch (lvlData[i][j]) {
									case "mario":
										//mario.position.y = j * -3.2;
										//mario.position.x = i * 3.2;
										//allMeshes.push(mario);
										
									default:
										//var inst = baseMesh.createInstance("box" + (i + j));
										var inst = Mesh.CreateBox("box", 3.2, scene);
										inst.position.y = j * -3.2;
										inst.position.x = i * 3.2;
										allMeshes.push(inst);
								}
								
							}
						}
					}
					
					baseMesh = Mesh.MergeMeshes(allMeshes, true);
					baseMesh.material = baseMat;*/
					
					engine.mouseUp.push(function(x:Int, y:Int, button:Int) {
						//trace(camera.alpha, camera.beta, camera.radius);
					});
					
					var vec = new Vector3(0, -60, 0);
					engine.runRenderLoop(function () {
						scene.render();
						levelMario.tick();
						camera.setTarget(levelMario.mario.view.getMesh().position.subtract(vec));
						camera.alpha = 7.85571150914772;
						camera.beta = 1.406620390355844;
						camera.radius = 400;
						
						//camera.target = Vector3.Lerp(camera.target, levelMario.mario.view.getMesh().position, 0.05);
						//camera.radius = camera.radius * 0.95 * 0.05;
					});
					
					/*var godrays = new VolumetricLightScatteringPostProcess('godrays', 1.0, camera, null, 50, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false);
					godrays.exposure = .1;
					var sun = godrays.mesh;
					cast(sun.material, StandardMaterial).diffuseTexture = new Texture("assets/img/colorcircle.png", scene, true, false, Texture.BILINEAR_SAMPLINGMODE);
					cast(sun.material, StandardMaterial).diffuseTexture.hasAlpha = true;
					cast(sun.material, StandardMaterial).diffuseTexture.level = 1;			
					sun.scaling = new Vector3(50, 50, 1);
					sun.position = mario.position.clone();
					sun.position.x = 5;
					sun.position.z += 10;
					sun.position.y += 5;*/
					
					/*var postProcess:Map<String, PostProcess> = new Map();
					
					var dreamPP = new DreamVisionPostProcess("dreamvision_PP", 1.0, camera);
					postProcess["dreamvision_PP"] = (dreamPP);
					camera.detachPostProcess(dreamPP);
					
					var thermalPP = new ThermalVisionPostProcess("thermalvision_PP", 1.0, camera);
					postProcess["thermalvision_PP"] = (thermalPP);
					camera.detachPostProcess(thermalPP);
					
					var crossHatchPP = new CrossHatchingPostProcess("crosshatch_PP", 1.0, camera);
					crossHatchPP.vx_offset = 0.5;
					postProcess["crosshatch_PP"] = (crossHatchPP);
					camera.detachPostProcess(crossHatchPP);
					
					var nightVisionPP = new NightVisionPostProcess("nightvision_PP", "assets/img/transpix.png", 1.0, camera);
					postProcess["nightvision_PP"] = (nightVisionPP);
					camera.detachPostProcess(nightVisionPP);
					
					var crossStitchPP = new CrossStitchingPostProcess("crosstitch_PP", 1.0, camera);
					postProcess["crosstitch_PP"] = (crossStitchPP);
					camera.detachPostProcess(crossStitchPP);
					
					var vignettePP = new VignettePostProcess("vignette_PP", 1.0, camera);
					postProcess["vignette_PP"] = (vignettePP);
					camera.detachPostProcess(vignettePP);
					
					var knittedPP = new KnittedPostProcess("knitted_PP", 1.0, camera);
					postProcess["knitted_PP"] = (knittedPP);
					camera.detachPostProcess(knittedPP);
					
					var blur2PP = new Blur2PostProcess("blur2_PP", 1.0, camera);
					postProcess["blur2_PP"] = (blur2PP);
					camera.detachPostProcess(blur2PP);
					
					var distortPP = new ScreenDistortionPostProcess("scenedist_PP", 1.0, camera);
					postProcess["scenedist_PP"] = (distortPP);
					camera.detachPostProcess(distortPP);
					
					var vibrancePP = new VibrancePostProcess("vibrance_PP", 1.0, camera);
					postProcess["vibrance_PP"] = (vibrancePP);
					camera.detachPostProcess(vibrancePP);
					
					var hueSatPP = new HueSaturationPostProcess("huesat_PP", 1.0, camera);
					postProcess["huesat_PP"] = (hueSatPP);
					camera.detachPostProcess(hueSatPP);
					
					var inkPP = new InkPostProcess("ink_PP", 1.0, camera);
					postProcess["ink_PP"] = (inkPP);
					camera.detachPostProcess(inkPP);
					
					var hexPixPP = new HexagonalPixelatePostProcess("hexpix_PP", 1.0, camera);
					postProcess["hexpix_PP"] = (hexPixPP);
					camera.detachPostProcess(hexPixPP);
					
					var naturalColorPP = new NaturalColorPostProcess("naturalColor_PP", 1.0, camera);
					postProcess["naturalColor_PP"] = (naturalColorPP);
					camera.detachPostProcess(naturalColorPP);
					
					var bloomPP = new BloomPostProcess("bloom_PP", 1.0, camera);
					postProcess["bloom_PP"] = bloomPP;
					camera.detachPostProcess(bloomPP);
					
					var mosaicPP = new MosaicPostProcess("mosaic_PP", 1.0, camera);
					postProcess["mosaic_PP"] = mosaicPP;
					camera.detachPostProcess(mosaicPP);
					
					var bleachPP = new BleachBypassPostProcess("bleach_PP", 1.0, camera);
					bleachPP.opacity = -3.8;
					postProcess["bleach_PP"] = bleachPP;
					camera.detachPostProcess(bleachPP);
					
					var limbDarkPP = new LimbDarkeningPostProcess("limbDark_PP", 1.0, camera);
					postProcess["limbDark_PP"] = limbDarkPP;
					
					var currentPP:PostProcess = limbDarkPP;
					
					camera.detachPostProcess(limbDarkPP);
					
					#if js
					var btn = Browser.window.document.createButtonElement();
					btn.textContent = "none";
					btn.setAttribute("style", "position: absolute; top: 10px; right: 10px; opacity: 0.7; width: 110px; font-size: 11px;");
					btn.onclick = function() {
						camera.detachPostProcess(currentPP);
					};
					Browser.window.document.body.appendChild(btn);
					
					var i:Int = 1;
					for (key in postProcess.keys()) {
						var btn = Browser.window.document.createButtonElement();
						btn.textContent = key;
						btn.setAttribute("style", "position: absolute; top: " + ((i++ * 24) + 10) + "px; right: 10px; opacity: 0.7; width: 110px; font-size: 11px;");
						btn.onclick = function() {
							camera.detachPostProcess(currentPP);
							currentPP = postProcess[key];
							camera.attachPostProcess(currentPP);
						};
						Browser.window.document.body.appendChild(btn);
					}					
					
					var btn = Browser.window.document.createButtonElement();
					btn.textContent = "Export obj/mtl";
					btn.setAttribute("style", "position: absolute; top: 10px; left: 10px; opacity: 0.7;");
					btn.onclick = exportObj;
					Browser.window.document.body.appendChild(btn);
					#end*/
					
					#if js
					var audio = new Audio('assets/music/mario.mp3');
					audio.play();
					#elseif (lime && !openfl)
					ambience = new AudioSource(lime.Assets.getAudioBuffer("assets/music/mario.ogg"));
					ambience.play();
					#end					
					
				});
			});
		});	
	}
	
	function animate(mesh:Mesh, fps:Int) {
		Animation.CreateAndStartAnimation("", mesh, "rotation.z", 60, fps, mesh.rotation.z, mesh.rotation.z + Math.PI *2, Animation.ANIMATIONLOOPMODE_CONSTANT);
	}
	
	function exportObj() {
		var bmObj:String = ObjExport.OBJ(baseMesh);	
		var bmMtl:String = ObjExport.MTL(baseMesh);
		
		#if js
		untyped Browser.window.parent.showExport3D(bmObj + "|||" + bmMtl);
		#end
	}
	
}
