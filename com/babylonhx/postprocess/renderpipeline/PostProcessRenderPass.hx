package com.babylonhx.postprocess.renderpipeline;

import com.babylonhx.materials.textures.RenderTargetTexture;
import com.babylonhx.tools.EventState;
import com.babylonhx.mesh.Mesh;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.PostProcessRenderPass') class PostProcessRenderPass {
	
	private var _enabled:Bool = true;
	private var _renderList:Array<Mesh>;
	private var _renderTexture:RenderTargetTexture;
	private var _scene:Scene;
	private var _refCount:Int = 0;

	// private
	public var _name:String;
	

	public function new(scene:Scene, name:String, size:Int, renderList:Array<Mesh>, beforeRender:Int->Null<EventState>->Void, afterRender:Int->Null<EventState>->Void) {
		this._name = name;
		
		this._renderTexture = new RenderTargetTexture(name, size, scene);
		this.setRenderList(renderList);
		
		this._renderTexture.onBeforeRenderObservable.add(beforeRender);
		this._renderTexture.onAfterRenderObservable.add(afterRender);
		
		this._scene = scene;
		
		this._renderList = renderList;
	}

	// private

	public function _incRefCount():Int {
		if (this._refCount == 0) {
			this._scene.customRenderTargets.push(this._renderTexture);
		}
		
		return ++this._refCount;
	}

	public function _decRefCount():Int {
		this._refCount--;
		
		if (this._refCount <= 0) {
			this._scene.customRenderTargets.splice(this._scene.customRenderTargets.indexOf(this._renderTexture), 1);
		}
		
		return this._refCount;
	}

	public function _update():Void {
		this.setRenderList(this._renderList);
	}

	// public

	public function setRenderList(renderList:Array<Mesh>):Void {
		this._renderTexture.renderList = cast renderList;
	}

	public function getRenderTexture():RenderTargetTexture {
		return this._renderTexture;
	}
	
}
