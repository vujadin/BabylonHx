package com.babylonhx.canvas2d.engine;

import com.babylonhx.math.Vector2;
import com.babylonhx.tools.Observable;

/**
 * ...
 * @author Krtolica Vujadin
 */
class RenderableGroupData {
	
	public var _primDirtyList:Array<Prim2DBase>;
	public var _primNewDirtyList:Array<Prim2DBase>;
	public var _childrenRenderableGroups:Array<Group2D>;
	public var _renderGroupInstancesInfo:StringDictionary<GroupInstanceInfo>;

	public var _cacheNode:PackedRect;
	public var _cacheTexture:MapTexture;
	public var _cacheRenderSprite:Sprite2D;
	public var _cacheNodeUVs:Array<Vector2>;
	public var _cacheNodeUVsChangedObservable:Observable<Array<Vector2>>;
	public var _cacheSize:Size;
	public var _useMipMap:Bool;
	public var _anisotropicLevel:Int;
	public var _noResizeOnScale:Bool;

	public var _transparentListChanged:Bool;
	public var _transparentPrimitives:Array<TransparentPrimitiveInfo>;
	public var _transparentSegments:Array<TransparentSegment>;
	public var _renderingScale:Float;
	

	public function new() {
		this._primDirtyList = new Array<Prim2DBase>();
		this._primNewDirtyList = new Array<Prim2DBase>();
		this._childrenRenderableGroups = new Array<Group2D>();
		this._renderGroupInstancesInfo = new StringDictionary<GroupInstanceInfo>();
		this._transparentPrimitives = new Array<TransparentPrimitiveInfo>();
		this._transparentSegments = new Array<TransparentSegment>();
		this._transparentListChanged = false;
		this._cacheNode = null;
		this._cacheTexture = null;
		this._cacheRenderSprite = null;
		this._renderingScale = 1;
		this._cacheNodeUVs = null;
		this._cacheNodeUVsChangedObservable = null;
		this._cacheSize = Size.Zero();
		this._useMipMap = false;
		this._anisotropicLevel = 1;
		this._noResizeOnScale = false;
	}
	
	public function dispose(owner:Canvas2D) {
		var engine = owner.engine;
		
		if (this._cacheRenderSprite != null) {
			this._cacheRenderSprite.dispose();
			this._cacheRenderSprite = null;
		}
		
		if (this._cacheTexture != null && this._cacheNode != null) {
			this._cacheTexture.freeRect(this._cacheNode);
			this._cacheTexture = null;
			this._cacheNode = null;
		}
		
		if (this._primDirtyList != null) {
			this._primDirtyList.splice(0);
			this._primDirtyList = null;
		}
		
		if (this._renderGroupInstancesInfo != null) {
			for (v in this._renderGroupInstancesInfo)
				v.dispose();
			}
			this._renderGroupInstancesInfo = null;
		}
		
		if (this._cacheNodeUVsChangedObservable != null) {
			this._cacheNodeUVsChangedObservable.clear();
			this._cacheNodeUVsChangedObservable = null;
		}
		
		if (this._transparentSegments != null) {
			for (ts in this._transparentSegments) {
				ts.dispose(engine);
			}
			this._transparentSegments.splice(0);
			this._transparentSegments = null;
		}
	}

	public function addNewTransparentPrimitiveInfo(prim:RenderablePrim2D, gii:GroupInstanceInfo):TransparentPrimitiveInfo {
		var tpi = new TransparentPrimitiveInfo();
		tpi._primitive = prim;
		tpi._groupInstanceInfo = gii;
		tpi._transparentSegment = null;
		
		this._transparentPrimitives.push(tpi);
		this._transparentListChanged = true;
		
		return tpi;
	}

	public function removeTransparentPrimitiveInfo(tpi:TransparentPrimitiveInfo) {
		var index = this._transparentPrimitives.indexOf(tpi);
		if (index != -1) {
			this._transparentPrimitives.splice(index, 1);
			this._transparentListChanged = true;
		}
	}

	public function transparentPrimitiveZChanged(tpi:TransparentPrimitiveInfo) {
		this._transparentListChanged = true;
		//this.updateSmallestZChangedPrim(tpi);
	}
	
}
