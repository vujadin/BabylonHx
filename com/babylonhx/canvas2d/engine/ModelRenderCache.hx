package com.babylonhx.canvas2d.engine;

import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector4;
import com.babylonhx.materials.Effect;
import com.babylonhx.tools.DynamicFloatArray;

/**
 * ...
 * @author Krtolica Vujadin
 */
class ModelRenderCache {
	
	public var _engine:Engine;
	private var _modelKey:String;
	private var _nextKey:Int;
	private var _refCounter:Int;

	private var _partData:Array<ModelRenderCachePartData>;
	private var _partsClassInfo:Array<ClassTreeInfo<InstanceClassInfo, InstancePropInfo>>;
	

	public function new(engine:Engine, modelKey:String) {
		this._engine = engine;
		this._modelKey = modelKey;
		this._nextKey = 1;
		this._refCounter = 1;
		this._partData = null;
	}

	public function dispose():Bool {
		if (--this._refCounter != 0) {
			return false;
		}
		
		// Remove the Model Render Cache from the global dictionary
		var edata = this._engine.getExternalData<Canvas2DEngineBoundData>("__BJSCANVAS2D__");
		if (edata != null) {
			edata.DisposeModelRenderCache(this);
		}
		
		return true;
	}

	public var isDisposed(get, never):Bool;
	private function get_isDisposed():Bool {
		return this._refCounter <= 0;
	}

	public function addRef():Int {
		return ++this._refCounter;
	}

	public var modelKey(get, never):String;
	private function get_modelKey():String {
		return this._modelKey;
	}

	/**
	 * Render the model instances
	 * @param instanceInfo
	 * @param context
	 * @return must return true is the rendering succeed, false if the rendering couldn't be done (asset's not yet ready, like Effect)
	 */
	public function render(instanceInfo:GroupInstanceInfo, context:Render2DContext):Bool {
		return true;
	}

	public function getPartIndexFromId(partId:Int):Int {
		for (i in 0...this._partData.length) {
			if (this._partData[i]._partId == partId) {
				return i;
			}
		}
		
		return -1;
	}

	public function loadInstancingAttributes(partId:Int, effect:Effect):Array<InstancingAttributeInfo> {
		var i = this.getPartIndexFromId(partId);
		if (i == -1) {
			return null;
		}
		
		var ci = this._partsClassInfo[i];
		var categories = this._partData[i]._partUsedCategories;
		var res = ci.classContent.getInstancingAttributeInfos(effect, categories);
		
		return res;
	}

	//setupUniformsLocation(effect: Effect, uniforms: string[], partId: number) {
	//    let i = this.getPartIndexFromId(partId);
	//    if (i === null) {
	//        return null;
	//    }

	//    let pci = this._partsClassInfo[i];
	//    pci.fullContent.forEach((k, v) => {
	//        if (uniforms.indexOf(v.attributeName) !== -1) {
	//            v.uniformLocation = effect.getUniform(v.attributeName);
	//        }
	//    });
	//}

	private static var v2:Vector2 = Vector2.Zero();
	private static var v3:Vector3 = Vector3.Zero();
	private static var v4:Vector4 = Vector4.Zero();

	public function setupUniforms(effect:Effect, partIndex:Int, data:DynamicFloatArray, elementCount:Int) {
		var pd = this._partData[partIndex];
		var offset = (pd._partDataStride / 4) * elementCount;
		var pci = this._partsClassInfo[partIndex];
		
		var self = this;
		for (v in pci.fullContent) {
			if (v.category || pd._partUsedCategories.indexOf(v.category) !== -1) {
				switch (v.dataType) {
					case ShaderDataType.float:
					{
						let attribOffset = v.instanceOffset.get(pd._partJoinedUsedCategories);
						effect.setFloat(v.attributeName, data.buffer[offset + attribOffset]);
						break;
					}
					case ShaderDataType.Vector2:
					{
						let attribOffset = v.instanceOffset.get(pd._partJoinedUsedCategories);
						ModelRenderCache.v2.x = data.buffer[offset + attribOffset + 0];
						ModelRenderCache.v2.y = data.buffer[offset + attribOffset + 1];
						effect.setVector2(v.attributeName, ModelRenderCache.v2);
						break;
					}
					case ShaderDataType.Color3:
					case ShaderDataType.Vector3:
					{
						let attribOffset = v.instanceOffset.get(pd._partJoinedUsedCategories);
						ModelRenderCache.v3.x = data.buffer[offset + attribOffset + 0];
						ModelRenderCache.v3.y = data.buffer[offset + attribOffset + 1];
						ModelRenderCache.v3.z = data.buffer[offset + attribOffset + 2];
						effect.setVector3(v.attributeName, ModelRenderCache.v3);
						break;
					}
					case ShaderDataType.Color4:
					case ShaderDataType.Vector4:
					{
						let attribOffset = v.instanceOffset.get(pd._partJoinedUsedCategories);
						ModelRenderCache.v4.x = data.buffer[offset + attribOffset + 0];
						ModelRenderCache.v4.y = data.buffer[offset + attribOffset + 1];
						ModelRenderCache.v4.z = data.buffer[offset + attribOffset + 2];
						ModelRenderCache.v4.w = data.buffer[offset + attribOffset + 3];
						effect.setVector4(v.attributeName, ModelRenderCache.v4);
						break;
					}
					default:
				}
			}
		});
	}
	
}
