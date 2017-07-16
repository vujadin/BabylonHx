package com.babylonhx.shaderbuilder;
import samples.ShaderBuilder1;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Helper {

	static inline public var Red:Int = 0;
	static inline public var Yellow:Int = 1;
	static inline public var White:Int = 2;
	static inline public var Cyan:Int = 4;
	static inline public var Blue:Int = 5;
	static inline public var Pink:Int = 6;
	static inline public var Black:Int = 7;
	static inline public var Green:Int = 8;
	
	
	static public function get():ShaderBuilder {
		var setting = Shader.Me.Setting;
		var instance = new ShaderBuilder();
		instance.Parent = Shader.Me;
		instance.Setting = setting;
		
		return instance;
	}

	static function Depth(far:Dynamic) {
		return 'max(0.,min(1.,(' + Shader.Print(far) + '-abs(length(camera-pos)))/' + Shader.Print(far) + ' ))';
	}
	
}
