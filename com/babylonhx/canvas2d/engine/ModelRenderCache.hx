package com.babylonhx.canvas2d.engine;

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

	public dispose(): boolean {
		if (--this._refCounter !== 0) {
			return false;
		}

		// Remove the Model Render Cache from the global dictionary
		let edata = this._engine.getExternalData<Canvas2DEngineBoundData>("__BJSCANVAS2D__");
		if (edata) {
			edata.DisposeModelRenderCache(this);
		}

		return true;
	}

	public get isDisposed(): boolean {
		return this._refCounter <= 0;
	}

	public addRef(): number {
		return ++this._refCounter;
	}

	public get modelKey(): string {
		return this._modelKey;
	}

	/**
	 * Render the model instances
	 * @param instanceInfo
	 * @param context
	 * @return must return true is the rendering succeed, false if the rendering couldn't be done (asset's not yet ready, like Effect)
	 */
	render(instanceInfo: GroupInstanceInfo, context: Render2DContext): boolean {
		return true;
	}

	protected getPartIndexFromId(partId: number) {
		for (var i = 0; i < this._partData.length; i++) {
			if (this._partData[i]._partId === partId) {
				return i;
			}
		}
		return null;
	}

	protected loadInstancingAttributes(partId: number, effect: Effect): InstancingAttributeInfo[] {
		let i = this.getPartIndexFromId(partId);
		if (i === null) {
			return null;
		}

		var ci = this._partsClassInfo[i];
		var categories = this._partData[i]._partUsedCategories;
		let res = ci.classContent.getInstancingAttributeInfos(effect, categories);

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

	private static v2 = Vector2.Zero();
	private static v3 = Vector3.Zero();
	private static v4 = Vector4.Zero();

	protected setupUniforms(effect: Effect, partIndex: number, data: DynamicFloatArray, elementCount: number) {
		let pd = this._partData[partIndex];
		let offset = (pd._partDataStride/4) * elementCount;
		let pci = this._partsClassInfo[partIndex];

		let self = this;
		pci.fullContent.forEach((k, v) => {
			if (!v.category || pd._partUsedCategories.indexOf(v.category) !== -1) {
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
