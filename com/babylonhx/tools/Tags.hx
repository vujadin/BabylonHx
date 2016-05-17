package com.babylonhx.tools;

//import com.babylonhx.tools.internals.AndOrNotEvaluator;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Tags') class Tags {
	
	public static function EnableFor(obj:Dynamic) {
		obj._tags = obj._tags != null ? obj._tags : {};

		obj.hasTags = function():Bool {
			return Tags.HasTags(obj);
		};

		obj.addTags = function(tagsString:String) {
			Tags.AddTagsTo(obj, tagsString);
		};

		obj.removeTags = function(tagsString:String) {
			Tags.RemoveTagsFrom(obj, tagsString);
		};

		/*obj.matchesTagsQuery = function(tagsQuery:String):Dynamic {
			return Tags.MatchesQuery(obj, tagsQuery);
		};*/
	}

	public static function DisableFor(obj:Dynamic) {
		obj._tags = null;
		obj.hasTags = null;
		obj.addTags = null;
		obj.removeTags = null;
		obj.matchesTagsQuery = null;
	}

	public static function HasTags(obj:Dynamic):Bool {
		if (!obj._tags) {
			return false;
		}
		return !Tools.IsEmpty(obj._tags);
	}

	public static function GetTags(obj:Dynamic):Dynamic {
		if (obj._tags == null) {
			return null;
		}
		return obj._tags;
	}

	// the tags 'true' and 'false' are reserved and cannot be used as tags
	// a tag cannot start with '||', '&&', and '!'
	// it cannot contain whitespaces
	public static function AddTagsTo(obj:Dynamic, tagsString:String = "") {
		if (tagsString == "") {
			return;
		}

		var tags = tagsString.split(" ");
		for (t in tags) {
			Tags._AddTagTo(obj, t);
		}
	}

	public static function _AddTagTo(obj:Dynamic, tag:String) {
		tag = StringTools.trim(tag);
		
		if (tag == "" || tag == "true" || tag == "false") {
			return;
		}
		
		var regex = ~/[\s]/;
		var regex2 = ~/^([!]|([|]|[&]){2})/;
		if(regex.match(tag) || regex2.match(tag)) {
			return;
		}
		
		Tags.EnableFor(obj);
		Reflect.setProperty(obj._tags, tag, true);
	}

	public static function RemoveTagsFrom(obj:Dynamic, tagsString:String) {
		if (!Tags.HasTags(obj)) {
			return;
		}
		var tags = tagsString.split(" ");
		for (t in tags) {
			Tags._RemoveTagFrom(obj, t);
		}
	}

	public static function _RemoveTagFrom(obj:Dynamic, tag:String) {
		obj._tags.remove(tag);
	}

	/*public static function MatchesQuery(obj:Dynamic, ?tagsQuery:String):Bool {
		if (tagsQuery == null) {
			return true;
		}

		if (tagsQuery == "") {
			return Tags.HasTags(obj);
		}

		return AndOrNotEvaluator.Eval(tagsQuery, function(r:String):Bool { return Tags.HasTags(obj) && obj._tags[r]; });
	}*/
	
}
