package samples;

import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class TestRegEx {
	
    public function new(scene:Scene) {
       trace(Replace("vec3 ppo#[Ind] = r_z( vec3(vuv.x,vuv.y,0.),0.,centeri#[Ind]); ", "#[Ind]", "_2_"));
    }
    
    static public function Replace(s:String, t:String, d:String):String {
		var ignore = false;
		var regex:EReg = ~/([\/\\,\\!\\\^\$\{\}\[\]\(\)\.\*\+\?\|\\<\\>\-\\&])/g;
		var regex2:EReg = ~/\$/g;
		var regex3:EReg = new EReg(regex.replace(t, "\\$&"), (ignore ? "gi" : "g"));
		
		return regex3.replace(s, regex2.replace(d, "$$$$"));
	}
	
}
