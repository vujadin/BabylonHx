package com.babylonhx.canvas2d.engine;

/**
 * ...
 * @author Krtolica Vujadin
 */

class InstanceClassInfo {
	
	public function new(base:InstanceClassInfo) {
		this._baseInfo = base;
		this._nextOffset = new StringDictionary<number>();
		this._attributes = new Array<InstancePropInfo>();
	}

	public function mapProperty(propInfo:InstancePropInfo, push:Bool) {
		var curOff = this._nextOffset.getOrAdd(InstanceClassInfo._CurCategories, 0);
		propInfo.instanceOffset.add(InstanceClassInfo._CurCategories, this._getBaseOffset(InstanceClassInfo._CurCategories) + curOff);
		//console.log(`[${InstanceClassInfo._CurCategories}] New PropInfo. Category: ${propInfo.category}, Name: ${propInfo.attributeName}, Offset: ${propInfo.instanceOffset.get(InstanceClassInfo._CurCategories)}, Size: ${propInfo.size / 4}`);
		
		this._nextOffset.set(InstanceClassInfo._CurCategories, curOff + (propInfo.size / 4));
		
		if (push) {
			this._attributes.push(propInfo);
		}
	}

	getInstancingAttributeInfos(effect: Effect, categories: string[]): InstancingAttributeInfo[] {
		let catInline = ";" + categories.join(";") + ";";
		let res = new Array<InstancingAttributeInfo>();
		let curInfo: InstanceClassInfo = this;
		while (curInfo) {
			for (let attrib of curInfo._attributes) {
				// Only map if there's no category assigned to the instance data or if there's a category and it's in the given list
				if (!attrib.category || categories.indexOf(attrib.category) !== -1) {
					let index = effect.getAttributeLocationByName(attrib.attributeName);
					let iai = new InstancingAttributeInfo();
					iai.index = index;
					iai.attributeSize = attrib.size / 4; // attrib.size is in byte and we need to store in "component" (i.e float is 1, vec3 is 3)
					iai.offset = attrib.instanceOffset.get(catInline) * 4; // attrib.instanceOffset is in float, iai.offset must be in bytes
					iai.attributeName = attrib.attributeName;
					res.push(iai);
				}
			}

			curInfo = curInfo._baseInfo;
		}
		return res;
	}

	getShaderAttributes(categories: string[]): string[] {
		let res = new Array<string>();
		let curInfo: InstanceClassInfo = this;
		while (curInfo) {
			for (let attrib of curInfo._attributes) {
				// Only map if there's no category assigned to the instance data or if there's a category and it's in the given list
				if (!attrib.category || categories.indexOf(attrib.category) !== -1) {
					res.push(attrib.attributeName);
				}
			}

			curInfo = curInfo._baseInfo;
		}
		return res;
	}

	private _getBaseOffset(categories: string): number {
		let curOffset = 0;
		let curBase = this._baseInfo;
		while (curBase) {
			curOffset += curBase._nextOffset.getOrAdd(categories, 0);
			curBase = curBase._baseInfo;
		}
		return curOffset;
	}

	static _CurCategories: string;
	private _baseInfo: InstanceClassInfo;
	private _nextOffset: StringDictionary<number>;
	private _attributes: Array<InstancePropInfo>;
	
}
