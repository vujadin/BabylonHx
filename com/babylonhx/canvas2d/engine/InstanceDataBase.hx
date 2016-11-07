package;

/**
 * ...
 * @author Krtolica Vujadin
 */

class InstanceDataBase {
	
	groupInstanceInfo: GroupInstanceInfo;
	arrayLengthChanged: boolean;
	curElement: number;
	renderMode: number;
	dataElements: DynamicFloatArrayElementInfo[];
	dataBuffer: DynamicFloatArray;
	typeInfo: ClassTreeInfo<InstanceClassInfo, InstancePropInfo>;
	
	public var id:Int;
	public var isVisible:Bool;

	private _dataElementCount: number;
	
	
	public function new(partId:Int, dataElementCount:Int) {
		this.id = partId;
		this.curElement = 0;
		this._dataElementCount = dataElementCount;
		this.renderMode = 0;
		this.arrayLengthChanged = false;
	}

	

	get zBias(): Vector2 {
		return null;
	}
	set zBias(value: Vector2) {
	}

	get transformX(): Vector4 {
		return null;
	}
	set transformX(value: Vector4) {
	}

	get transformY(): Vector4 {
		return null;
	}
	set transformY(value: Vector4) {
	}

	get opacity(): number {
		return null;
	}
	set opacity(value: number) {
	}

	getClassTreeInfo(): ClassTreeInfo<InstanceClassInfo, InstancePropInfo> {
		if (!this.typeInfo) {
			this.typeInfo = ClassTreeInfo.get<InstanceClassInfo, InstancePropInfo>(Object.getPrototypeOf(this));
		}
		return this.typeInfo;
	}

	allocElements() {
		if (!this.dataBuffer || this.dataElements) {
			return;
		}
		let res = new Array<DynamicFloatArrayElementInfo>(this.dataElementCount);
		for (let i = 0; i < this.dataElementCount; i++) {
			res[i] = this.dataBuffer.allocElement();
		}
		this.dataElements = res;
	}

	freeElements() {
		if (!this.dataElements) {
			return;
		}
		for (let ei of this.dataElements) {
			this.dataBuffer.freeElement(ei);
		}
		this.dataElements = null;
	}

	get dataElementCount(): number {
		return this._dataElementCount;
	}

	set dataElementCount(value: number) {
		if (value === this._dataElementCount) {
			return;
		}

		this.arrayLengthChanged = true;
		this.freeElements();
		this._dataElementCount = value;
		this.allocElements();
	}
	
}
