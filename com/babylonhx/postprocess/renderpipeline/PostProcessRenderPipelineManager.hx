package com.babylonhx.postprocess.renderpipeline;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.PostProcessRenderPipelineManager') class PostProcessRenderPipelineManager {
	
	private var _renderPipelines:Map<String, PostProcessRenderPipeline>;
	

	public function new() {
		this._renderPipelines = new Map<String, PostProcessRenderPipeline>();
	}

	public function addPipeline(renderPipeline:PostProcessRenderPipeline) {
		this._renderPipelines[renderPipeline._name] = renderPipeline;
	}

	public function attachCamerasToRenderPipeline(renderPipelineName:String, cameras:Dynamic, unique:Bool = false) {
		var renderPipeline:PostProcessRenderPipeline = this._renderPipelines[renderPipelineName];
		
		if (renderPipeline == null) {
			return;
		}
		
		renderPipeline._attachCameras(cameras, unique);
	}

	public function detachCamerasFromRenderPipeline(renderPipelineName:String, cameras:Dynamic) {
		var renderPipeline:PostProcessRenderPipeline = this._renderPipelines[renderPipelineName];
		
		if (renderPipeline == null) {
			return;
		}
		
		renderPipeline._detachCameras(cameras);
	}

	public function enableEffectInPipeline(renderPipelineName:String, renderEffectName:String, cameras:Dynamic) {
		var renderPipeline:PostProcessRenderPipeline = this._renderPipelines[renderPipelineName];
		
		if (renderPipeline == null) {
			return;
		}
		
		renderPipeline._enableEffect(renderEffectName, cameras);
	}

	public function disableEffectInPipeline(renderPipelineName:String, renderEffectName:String, cameras:Dynamic) {
		var renderPipeline:PostProcessRenderPipeline = this._renderPipelines[renderPipelineName];
		
		if (renderPipeline == null) {
			return;
		}
		
		renderPipeline._disableEffect(renderEffectName, cameras);
	}

	public function enableDisplayOnlyPassInPipeline(renderPipelineName:String, passName:String, cameras:Dynamic) {
		var renderPipeline:PostProcessRenderPipeline = this._renderPipelines[renderPipelineName];
		
		if (renderPipeline == null) {
			return;
		}
		
		renderPipeline._enableDisplayOnlyPass(passName, cameras);
	}

	public function disableDisplayOnlyPassInPipeline(renderPipelineName:String, cameras:Dynamic) {
		var renderPipeline:PostProcessRenderPipeline = this._renderPipelines[renderPipelineName];
		
		if (renderPipeline == null) {
			return;
		}
		
		renderPipeline._disableDisplayOnlyPass(cameras);
	}

	public function update() {
		for (renderPipelineName in this._renderPipelines.keys()) {
			var pipeline = this._renderPipelines[renderPipelineName];
			if (!pipeline.isSupported) {
				pipeline.dispose();
				this._renderPipelines[renderPipelineName] = null;
				this._renderPipelines.remove(renderPipelineName);
			} 
			else {
				pipeline._update();
			}
		}
	}
	
}
