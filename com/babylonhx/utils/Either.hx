package com.babylonhx.utils;

/**
 * ...
 * @author Krtolica Vujadin
 */

abstract Either<L, R>(haxe.ds.Either<L, R>) {
	
	inline function new(e:haxe.ds.Either<L, R>) {
        this = e;
    }
	
	public var type(get, never):haxe.ds.Either<L, R>;
	inline function get_type():haxe.ds.Either<L, R> {
        return this;
    }
	
	public var length(get, never):Int;
	inline function get_length():Int {
		return switch(type) {
			case Left(array):
				untyped array.length;
				
			case Right(nativeArray):
				untyped nativeArray.length;
		}
	}
	
	@:arrayAccess inline public function get(index:Int) {
		return untyped this[index];
	}
	
	inline public function push(val:Dynamic) {
		untyped this[length] = val;
	}
	
	@:from static inline public function fromLeft<L>(left:L) {
        return new Either(Left(left));
    }
	
	@:from static inline public function fromRight<R>(right:R) {
        return new Either(Right(right));
    }
	
}
