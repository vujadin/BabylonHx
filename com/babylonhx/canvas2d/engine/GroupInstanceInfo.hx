package com.babylonhx.canvas2d.engine;

import haxe.ds.Vector;

/**
 * ...
 * @author Krtolica Vujadin
 */
class GroupInstanceInfo {

	private var _partCount:Int;
	private var _strides:Vector<Int>;
	private var _usedShaderCategories:Vector<String>;
	private var _opaqueData:Vector<GroupInfoPartData>;
	private var _alphaTestData:Vector<GroupInfoPartData>;
	private var _transparentData:Vector<TransparentGroupInfoPartData>;
	
	public var partIndexFromId:StringDictionary<Int>;
	
	private var _isDisposed:Bool;
    public var owner:Group2D;

    public var modelRenderCache:ModelRenderCache;
	
	public var opaqueDirty:Bool;
	public var alphaTestDirty:Bool;
	public var transparentOrderDirty:Bool;
    public var transparentDirty:Bool;
	
	public var usedShaderCategories(get, never):Array<String>;
	private function get_usedShaderCategories():Array<String> {
		return this._usedShaderCategories;
	}
	
	public var strides(get, never):Vector<Int>;
	private function get_strides():Vector<Int> {
		return this._strides;
	}
	

	public function new(owner:Group2D, mrc:ModelRenderCache, partCount:Int) {
		this._partCount = partCount;
		this.owner = owner;
		this.modelRenderCache = mrc;
		this.modelRenderCache.addRef();
		this.partIndexFromId = new StringDictionary<Int>();
		this._usedShaderCategories = new Vector<String>(partCount);
		this._strides = new Vector<Int>(partCount);
		this._opaqueData = null;
		this._alphaTestData = null;
		this._transparentData = null;
		this.opaqueDirty = this.alphaTestDirty = this.transparentDirty = this.transparentOrderDirty = false;
	}

	public function dispose():Bool {
		if (this._isDisposed) {
			return false;
		}
		
		if (this.modelRenderCache != null) {
			this.modelRenderCache.dispose();
			this.modelRenderCache = null;
		}
		
		var engine = this.owner.owner.engine;
		
		if (this._opaqueData != null) {
			for (d in this._opaqueData) {
				d.dispose(engine));
			}
			this._opaqueData = null;
		}
		
		if (this._alphaTestData != null) {
			for (d in this._alphaTestData) {
				d.dispose(engine));
			}
			this._alphaTestData = null;
		}
		
		if (this._transparentData != null) {
			for (d in this._transparentData) {
				d.dispose(engine));
			}
			this._transparentData = null;
		}
		
		this.partIndexFromId = null;
		this._isDisposed = true;
		
		return true;
	}

	public var hasOpaqueData(get, never):Bool;
	private function get_hasOpaqueData():Bool {
		return this._opaqueData != null;
	}

	public var hasAlphaTestData(get, set):Bool;
	private function get_hasAlphaTestData():Bool {
		return this._alphaTestData != null;
	}
	private function get_hasTransparentData():Bool {
		return this._transparentData != null;
	}

	public var opaqueData(get, never):Vector<GroupInfoPartData>;
	private function get_opaqueData():Vector<GroupInfoPartData> {
		if (this._opaqueData == null) {
			this._opaqueData = new Vector<GroupInfoPartData>(this._partCount);
			for (i in 0...this._partCount) {
				this._opaqueData[i] = new GroupInfoPartData(this._strides[i]);
			}
		}
		
		return this._opaqueData;
	}

	public var alphaTestData(get, never):Vector<GroupInfoPartData>;
	private function get_alphaTestData():Vector<GroupInfoPartData> {
		if (this._alphaTestData == null) {
			this._alphaTestData = new Vector<GroupInfoPartData>(this._partCount);
			for (i in 0...this._partCount) {
				this._alphaTestData[i] = new GroupInfoPartData(this._strides[i]);
			}
		}
		
		return this._alphaTestData;
	}

	public var transparentData(get, never):Array<TransparentGroupInfoPartData>;
	private function get_transparentData():Array<TransparentGroupInfoPartData> {
		if (this._transparentData == null) {
			this._transparentData = new Vector<TransparentGroupInfoPartData>(this._partCount);
			for (i in 0...this._partCount) {
				let zoff = this.modelRenderCache._partData[i]._zBiasOffset;
				this._transparentData[i] = new TransparentGroupInfoPartData(this._strides[i], zoff);
			}
		}
		
		return this._transparentData;
	}

	public function sortTransparentData() {
		if (!this.transparentOrderDirty) {
			return;
		}
		
		for (i in 0...this._transparentData.length) {
			var td = this._transparentData[i];
			td._partData.sort();
		}
		
		this.transparentOrderDirty = false;
	}
	
}
