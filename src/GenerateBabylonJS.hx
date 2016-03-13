package;

import com.babylonhx.math.Angle;
import com.babylonhx.math.Arc;
import com.babylonhx.math.Axis;
import com.babylonhx.math.Space;
import com.babylonhx.math.BezierCurve;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Curve3;
import com.babylonhx.math.Frustum;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Path2;
import com.babylonhx.math.Path3D;
import com.babylonhx.math.Plane;
import com.babylonhx.math.PositionNormalTextureVertex;
import com.babylonhx.math.PositionNormalVertex;
import com.babylonhx.math.Quaternion;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector4;
import com.babylonhx.math.Viewport;
import com.babylonhx.math.Tools;

import com.babylonhx.actions.Action;
import com.babylonhx.actions.ActionEvent;
import com.babylonhx.actions.ActionManager;
import com.babylonhx.actions.CombineAction;
import com.babylonhx.actions.Condition;
import com.babylonhx.actions.DoNothingAction;
import com.babylonhx.actions.ExecuteCodeAction;
import com.babylonhx.actions.IncrementValueAction;
import com.babylonhx.actions.InterpolateValueAction;
import com.babylonhx.actions.PlayAnimationAction;
import com.babylonhx.actions.PlaySoundAction;
import com.babylonhx.actions.PredicateCondition;
import com.babylonhx.actions.SetParentAction;
import com.babylonhx.actions.SetStateAction;
import com.babylonhx.actions.SetValueAction;
import com.babylonhx.actions.StateCondition;
import com.babylonhx.actions.StopAnimationAction;
import com.babylonhx.actions.StopSoundAction;
import com.babylonhx.actions.SwitchBooleanAction;
import com.babylonhx.actions.ValueCondition;

import com.babylonhx.animations.IAnimatable;
import com.babylonhx.animations.Animatable;
import com.babylonhx.animations.Animation;
import com.babylonhx.animations.AnimationEvent;
import com.babylonhx.animations.AnimationRange;
import com.babylonhx.animations.PathCursor;

import com.babylonhx.animations.easing.IEasingFunction;
import com.babylonhx.animations.easing.BackEase;
import com.babylonhx.animations.easing.BounceEase;
import com.babylonhx.animations.easing.CircleEase;
import com.babylonhx.animations.easing.CubicEase;
import com.babylonhx.animations.easing.EasingFunction;
import com.babylonhx.animations.easing.ElasticEase;
import com.babylonhx.animations.easing.ExponentialEase;
import com.babylonhx.animations.easing.PowerEase;
import com.babylonhx.animations.easing.QuadraticEase;
import com.babylonhx.animations.easing.QuarticEase;
import com.babylonhx.animations.easing.QuinticEase;
import com.babylonhx.animations.easing.SineEase;

import com.babylonhx.audio.Analyser;
import com.babylonhx.audio.AudioEngine;
import com.babylonhx.audio.Sound;
import com.babylonhx.audio.SoundTrack;

import com.babylonhx.bones.Bone;
import com.babylonhx.bones.Skeleton;

import com.babylonhx.cameras.AnaglyphArcRotateCamera;
import com.babylonhx.cameras.AnaglyphFreeCamera;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.cameras.Camera;
import com.babylonhx.cameras.FollowCamera;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.cameras.TargetCamera;
import com.babylonhx.cameras.TouchCamera;
import com.babylonhx.cameras.VRCameraMetrics;
import com.babylonhx.cameras.WebVRFreeCamera;

import com.babylonhx.collisions.Collider;
import com.babylonhx.collisions.CollisionCoordinator;
import com.babylonhx.collisions.CollisionCoordinatorLegacy;
import com.babylonhx.collisions.ICollisionCoordinator;
import com.babylonhx.collisions.IntersectionInfo;
import com.babylonhx.collisions.PickingInfo;

import com.babylonhx.culling.BoundingBox;
import com.babylonhx.culling.BoundingInfo;
import com.babylonhx.culling.BoundingSphere;
import com.babylonhx.culling.Ray;

import com.babylonhx.culling.octrees.IOctreeContainer;
import com.babylonhx.culling.octrees.Octree;
import com.babylonhx.culling.octrees.OctreeBlock;

import com.babylonhx.layer.Layer;

import com.babylonhx.lensflare.LensFlare;
import com.babylonhx.lensflare.LensFlareSystem;

import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.IShadowLight;
import com.babylonhx.lights.Light;
import com.babylonhx.lights.PointLight;
import com.babylonhx.lights.SpotLight;

import com.babylonhx.lights.shadows.ShadowGenerator;

import com.babylonhx.loading.SceneLoader;

import com.babylonhx.loading.plugins.BabylonFileLoader;

import com.babylonhx.materials.Effect;
import com.babylonhx.materials.EffectFallbacks;
import com.babylonhx.materials.FresnelParameters;
import com.babylonhx.materials.Material;
import com.babylonhx.materials.ShaderMaterial;
import com.babylonhx.materials.ShadersStore;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.StandardMaterialDefines;

import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.DynamicTexture;
import com.babylonhx.materials.textures.HDRCubeTexture;
import com.babylonhx.materials.textures.MirrorTexture;
import com.babylonhx.materials.textures.RawTexture;
import com.babylonhx.materials.textures.RefractionTexture;
import com.babylonhx.materials.textures.RenderTargetTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.VideoTexture;
import com.babylonhx.materials.textures.WebGLTexture;

import com.babylonhx.materials.textures.procedurals.CustomProceduralTexture;

import com.babylonhx.materials.textures.procedurals.standard.BrickProceduralTexture;
import com.babylonhx.materials.textures.procedurals.standard.CloudProceduralTexture;
import com.babylonhx.materials.textures.procedurals.standard.FireProceduralTexture;
import com.babylonhx.materials.textures.procedurals.standard.GrassProceduralTexture;
import com.babylonhx.materials.textures.procedurals.standard.MarbleProceduralTexture;
import com.babylonhx.materials.textures.procedurals.standard.RoadProceduralTexture;
import com.babylonhx.materials.textures.procedurals.standard.StarfieldProceduralTexture;
import com.babylonhx.materials.textures.procedurals.standard.WoodProceduralTexture;

import com.babylonhx.mesh._InstancesBatch;
import com.babylonhx.mesh._VisibleInstances;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.Geometry;
import com.babylonhx.mesh.GroundMesh;
import com.babylonhx.mesh.IGetSetVerticesData;
import com.babylonhx.mesh.InstancedMesh;
import com.babylonhx.mesh.LinesMesh;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.mesh.VertexData;
import com.babylonhx.mesh.WebGLBuffer;

import com.babylonhx.mesh.csg.CSG;
import com.babylonhx.mesh.csg.Node;
import com.babylonhx.mesh.csg.Plane;
import com.babylonhx.mesh.csg.Polygon;
import com.babylonhx.mesh.csg.Vertex;

import com.babylonhx.mesh.polygonmesh.IndexedPoint;
import com.babylonhx.mesh.polygonmesh.Polygon;
import com.babylonhx.mesh.polygonmesh.PolygonBounds;
import com.babylonhx.mesh.polygonmesh.PolygonMeshBuilder;
import com.babylonhx.mesh.polygonmesh.PolygonPoints;

import com.babylonhx.mesh.primitives._Primitive;
import com.babylonhx.mesh.primitives.Box;
import com.babylonhx.mesh.primitives.Cylinder;
import com.babylonhx.mesh.primitives.Ground;
import com.babylonhx.mesh.primitives.Plane;
import com.babylonhx.mesh.primitives.Ribbon;
import com.babylonhx.mesh.primitives.Sphere;
import com.babylonhx.mesh.primitives.TiledGround;
import com.babylonhx.mesh.primitives.Torus;
import com.babylonhx.mesh.primitives.TorusKnot;

import com.babylonhx.mesh.simplification.DecimationTriangle;
import com.babylonhx.mesh.simplification.DecimationVertex;
import com.babylonhx.mesh.simplification.ISimplificationSettings;
import com.babylonhx.mesh.simplification.ISimplificationTask;
import com.babylonhx.mesh.simplification.ISimplifier;
import com.babylonhx.mesh.simplification.QuadraticErrorSimplification;
import com.babylonhx.mesh.simplification.QuadraticMatrix;
import com.babylonhx.mesh.simplification.Reference;
import com.babylonhx.mesh.simplification.SimplificationQueue;
import com.babylonhx.mesh.simplification.SimplificationSettings;
import com.babylonhx.mesh.simplification.SimplificationTask;

import com.babylonhx.particles.Particle;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.particles.ModelShape;
import com.babylonhx.particles.SolidParticle;
import com.babylonhx.particles.SolidParticleSystem;

import com.babylonhx.physics.IPhysicsEnginePlugin;
import com.babylonhx.physics.PhysicsBodyCreationOptions;
import com.babylonhx.physics.PhysicsCompoundBodyPart;
import com.babylonhx.physics.PhysicsEngine;

import com.babylonhx.physics.plugins.Body;
import com.babylonhx.physics.plugins.Link;
import com.babylonhx.physics.plugins.OimoPlugin;

import com.babylonhx.postprocess.AnaglyphPostProcess;
import com.babylonhx.postprocess.BlackAndWhitePostProcess;
import com.babylonhx.postprocess.BlurPostProcess;
import com.babylonhx.postprocess.ColorCorrectionPostProcess;
import com.babylonhx.postprocess.ConvolutionPostProcess;
import com.babylonhx.postprocess.DisplayPassPostProcess;
import com.babylonhx.postprocess.FilterPostProcess;
import com.babylonhx.postprocess.FxaaPostProcess;
import com.babylonhx.postprocess.HDRRenderingPipeline;
import com.babylonhx.postprocess.LensRenderingPipeline;
import com.babylonhx.postprocess.OculusDistortionCorrectionPostProcess;
import com.babylonhx.postprocess.PassPostProcess; 
import com.babylonhx.postprocess.PostProcess;
import com.babylonhx.postprocess.PostProcessManager;
import com.babylonhx.postprocess.RefractionPostProcess; 
import com.babylonhx.postprocess.SSAORenderingPipeline;
import com.babylonhx.postprocess.StereoscopicInterlacePostProcess;
import com.babylonhx.postprocess.VRDistortionCorrectionPostProcess;
import com.babylonhx.postprocess.VolumetricLightScatteringPostProcess;

import com.babylonhx.postprocess.renderpipeline.PostProcessRenderEffect;
import com.babylonhx.postprocess.renderpipeline.PostProcessRenderPass;
import com.babylonhx.postprocess.renderpipeline.PostProcessRenderPipeline;
import com.babylonhx.postprocess.renderpipeline.PostProcessRenderPipelineManager;

import com.babylonhx.probes.ReflectionProbe;

import com.babylonhx.rendering.BoundingBoxRenderer;
import com.babylonhx.rendering.DepthRenderer;
import com.babylonhx.rendering.OutlineRenderer;
import com.babylonhx.rendering.RenderingGroup;
import com.babylonhx.rendering.RenderingManager;

import com.babylonhx.sprites.Sprite;
import com.babylonhx.sprites.SpriteManager;

import com.babylonhx.states._AlphaState;
import com.babylonhx.states._DepthCullingState;

import com.babylonhx.tools.AsyncLoop;
import com.babylonhx.tools.ColorTools;
import com.babylonhx.tools.SceneSerializer;
import com.babylonhx.tools.SmartArray;
import com.babylonhx.tools.SmartCollection;
import com.babylonhx.tools.Tags;
import com.babylonhx.tools.Tools;

import com.babylonhx.tools.hdr.CMGBoundinBox;
import com.babylonhx.tools.hdr.CubeMapToSphericalPolynomialTools;
import com.babylonhx.tools.hdr.FileFaceOrientation;
import com.babylonhx.tools.hdr.HDRTools;
import com.babylonhx.tools.hdr.PanoramaToCubeMapTools;
import com.babylonhx.tools.hdr.PMREMGenerator;

import com.babylonhx.tools.sceneoptimizer.HardwareScalingOptimization;
import com.babylonhx.tools.sceneoptimizer.LensFlaresOptimization;
import com.babylonhx.tools.sceneoptimizer.MergeMeshesOptimization;
import com.babylonhx.tools.sceneoptimizer.ParticlesOptimization;
import com.babylonhx.tools.sceneoptimizer.PostProcessesOptimization;
import com.babylonhx.tools.sceneoptimizer.RenderTargetsOptimization;
import com.babylonhx.tools.sceneoptimizer.SceneOptimization;
import com.babylonhx.tools.sceneoptimizer.SceneOptimizer;
import com.babylonhx.tools.sceneoptimizer.SceneOptimizerOptions;
import com.babylonhx.tools.sceneoptimizer.ShadowsOptimization;
import com.babylonhx.tools.sceneoptimizer.TextureOptimization;

import com.babylonhx.Engine;
import com.babylonhx.EngineCapabilities;
import com.babylonhx.IDisposable;
import com.babylonhx.ISmartArrayCompatible;
import com.babylonhx.Node;
import com.babylonhx.Scene;


/**
 * ...
 * @author Krtolica Vujadin
 */
class GenerateBabylonJS {
	
	public function new() {
		
	}
	
	static function main() {
		new GenerateBabylonJS();
	}		
	
}
