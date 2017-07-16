package com.babylonhx.canvas2d.engine;

import com.babylonhx.tools.StringDictionary;

/**
 * ...
 * @author Krtolica Vujadin
 */

class ClassTreeInfo<TClass, TProp>{
	
	private var _type:Dynamic;
	private var _classContent:TClass;
	private var _baseClass:ClassTreeInfo<TClass, TProp>;
	private var _subClasses:Array<Dynamic>;  // Array<{ type: Object, node: ClassTreeInfo<TClass, TProp> }>;
	private var _levelContent:StringDictionary<TProp>;
	private var _fullContent:StringDictionary<TProp>;
	private var _classContentFactory:TClass=>TClass;
	
	
	public function new(baseClass:ClassTreeInfo<TClass, TProp>, type:Dynamic, classContentFactory:TClass=>TClass) {
		this._baseClass = baseClass;
		this._type = type;
		this._subClasses = new Array<{ type: Object, node: ClassTreeInfo<TClass, TProp> }>();
		this._levelContent = new StringDictionary<TProp>();
		this._classContentFactory = classContentFactory;
	}

	get classContent(): TClass {
		if (!this._classContent) {
			this._classContent = this._classContentFactory(this._baseClass ? this._baseClass.classContent : null);
		}
		
		return this._classContent;
	}

	get type(): Object {
		return this._type;
	}

	get levelContent(): StringDictionary<TProp> {
		return this._levelContent;
	}

	get fullContent(): StringDictionary<TProp> {
		if (!this._fullContent) {
			let dic = new StringDictionary<TProp>();
			let curLevel: ClassTreeInfo<TClass, TProp> = this;
			while (curLevel) {
				curLevel.levelContent.forEach((k, v) => dic.add(k, v));
				curLevel = curLevel._baseClass;
			}

			this._fullContent = dic;
		}

		return this._fullContent;
	}

	getLevelOf(type: Object): ClassTreeInfo<TClass, TProp> {
		// Are we already there?
		if (type === this._type) {
			return this;
		}

		let baseProto = Object.getPrototypeOf(type);
		let curProtoContent = this.getOrAddType(Object.getPrototypeOf(baseProto), baseProto);
		if (!curProtoContent) {
			this.getLevelOf(baseProto);
		}

		return this.getOrAddType(baseProto, type);
	}

	getOrAddType(baseType: Object, type: Object): ClassTreeInfo<TClass, TProp> {

		// Are we at the level corresponding to the baseType?
		// If so, get or add the level we're looking for
		if (baseType === this._type) {
			for (let subType of this._subClasses) {
				if (subType.type === type) {
					return subType.node;
				}
			}
			let node = new ClassTreeInfo<TClass, TProp>(this, type, this._classContentFactory);
			let info = { type: type, node: node };
			this._subClasses.push(info);
			return info.node;
		}

		// Recurse down to keep looking for the node corresponding to the baseTypeName
		for (let subType of this._subClasses) {
			let info = subType.node.getOrAddType(baseType, type);
			if (info) {
				return info;
			}
		}
		return null;
	}

	static get<TClass, TProp>(type: Object): ClassTreeInfo<TClass, TProp> {
		let dic = <ClassTreeInfo<TClass, TProp>>type["__classTreeInfo"];
		if (!dic) {
			return null;
		}
		return dic.getLevelOf(type);
	}

	static getOrRegister<TClass, TProp>(type: Object, classContentFactory: (base: TClass) => TClass): ClassTreeInfo<TClass, TProp> {
		let dic = <ClassTreeInfo<TClass, TProp>>type["__classTreeInfo"];
		if (!dic) {
			dic = new ClassTreeInfo<TClass, TProp>(null, type, classContentFactory);
			type["__classTreeInfo"] = dic;
		}
		return dic;
	}
	
}
