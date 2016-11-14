package com.babylonhx.d2.text;

import com.babylonhx.d2.display.BitmapData;
import com.babylonhx.d2.display.Bitmap;
import com.babylonhx.d2.display.Sprite;
import com.babylonhx.d2.geom.Point;
import com.babylonhx.d2.geom.Rectangle;
import com.babylonhx.tools.Tools;
import com.babylonhx.utils.Image;
import com.babylonhx.utils.typedarray.UInt8Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
class TextField extends Sprite {
	
	private var _text:String;
	public var text(get, set):String;	

	private static var glyphMap:Map<String, Map<Int, Glyph>> = new Map();
	private static var bDataMap:Map<String, BitmapData> = new Map();
	private static var lineHeights:Map<String, Int> = new Map();
	
	private var _font:String = "";
	
	private var _lineHeight:Int;
	
	private var _bmp:Bitmap;
	private var _bd:BitmapData;
	
	
	public function new(text:String, font:String = "", width:Int = 256, height:Int = 64) {
		super();
		
		this._bd = BitmapData.empty(width, height);
		this._bmp = new Bitmap(this._bd);
		addChild(_bmp);
		
		if (!bDataMap.exists(BHxDefaultFont.name)) {
			var img = new Image(new UInt8Array(BHxDefaultFont.image), 64, 256);
			var bData = new BitmapData(img);
			addSheet(BHxDefaultFont.name, bData);
			
			var fnt = BHxDefaultFont.fontDesc.join('\n');
			glyphMap[BHxDefaultFont.name] = new Map();
			parseFont(fnt, BHxDefaultFont.name);
			this._lineHeight = lineHeights[BHxDefaultFont.name];
		}
		
		if (font != "" && bDataMap.exists(font)) {
			this._font = font;
			this._lineHeight = lineHeights[font];
			this.text = text;
		}
		else if (font == "") {
			this._font = BHxDefaultFont.name;
			this._lineHeight = lineHeights[BHxDefaultFont.name];
			this.text = text;
		}
		else {
			trace('No registered font with name "${font}". You have to register font first with TextField.registerFont() method! Switching to BabylonHx default font.');
			
			this._font = BHxDefaultFont.name;
			this._lineHeight = lineHeights[BHxDefaultFont.name];
			this.text = text;
		}
	}
	
	private function get_text():String {
		return this._text;
	}
	private function set_text(text:String):String {
		if (text == this._text) {
			return "";
		}
		
		this._bd.cleanPixels(new Rectangle(0, 0, this.width, this.height));
		
		var curX:Int = 0;
		var curY:Int = 0;
		
		for(curCharIdx in 0...text.length) {
			// Identify the glyph.
			var curChar:Int = text.charCodeAt(curCharIdx);
			
			var curGlyph:Glyph = glyphMap[_font][curChar];
			if (curGlyph == null) {
				if (text.charAt(curCharIdx) == '\n') {
					curY += this._lineHeight;
					curX = 0;
				}
				
				continue;
			}
			
			/*if (_text.length == text.length) {
				if (_text.charCodeAt(curCharIdx) == curChar) {
					// Update cursor position
					curX += curGlyph.xadvance;
					continue;	// we don't want to redraw the same char
				}
				else {
					// clean area ocupied by previous char
					var oldGlyph:Glyph = glyphMap[_font][_text.charCodeAt(curCharIdx)];
					this.bitmapData.cleanPixels(new Rectangle(curX - 1 + curGlyph.xoffset, curY + curGlyph.yoffset, oldGlyph.width, oldGlyph.height));
				}
			}*/			
			
			// Draw the glyph.
			this._bd.copyPixels(bDataMap[_font], 
				new Rectangle(curGlyph.x, curGlyph.y, curGlyph.width, curGlyph.height),
				new Point(curX + curGlyph.xoffset, curY + curGlyph.yoffset));
				
			// Update cursor position
			curX += curGlyph.xadvance;
		}
		
		this._text = text;
		
		return text;
	}
	
	/**
	 * Add a bitmapdata.
	 */
	private static function addSheet(id:String, bits:BitmapData) {
		if(bDataMap[id] == null) {
			bDataMap[id] = bits;
		}            
	}
	
	/**
	 * Parse a BMFont textual font description.
	 */
	private static function parseFont(fontDesc:String, name:String) {
		var fontLines:Array<String> = fontDesc.split("\n");
		
		for (i in 0...fontLines.length) {			
			var fontLine:Array<String> = fontLines[i].split(" ");
			var keyWord:String = fontLine[0].toLowerCase();
			
			switch(keyWord) {
				case "char":
					parseChar(fontLine, name);
					
				case "common":
					for(i in 1...fontLine.length) {
						var charEntry:Array<String> = fontLine[i].split("=");
						
						if(charEntry.length != 2) {
							continue;
						}
						
						var charKey:String = charEntry[0];
						var charVal:Int = Std.parseInt(charEntry[1]);
						
						switch (charKey) {
							case "lineHeight":
								lineHeights[name] = charVal;
								break;
						}
					}
			}
		}
	}
	
	/**
	 * Helper function to parse and register a glyph from a BMFont description..
	 */
	private static function parseChar(charLine:Array<String>, name:String) {
		var g:Glyph = new Glyph();
		
		for(i in 1...charLine.length) {
			// Parse to key value.
			var charEntry:Array<String> = charLine[i].split("=");
			if(charEntry.length != 2) {
				continue;
			}
			
			var charKey:String = charEntry[0];
			var charVal:Int = Std.parseInt(charEntry[1]);
			
			switch (charKey) {
				case "id":
					g.id = charVal;
					
				case "x":
					g.x = charVal;
					
				case "y":
					g.y = charVal;
					
				case "width":
					g.width = charVal;
					
				case "height":
					g.height = charVal;
					
				case "xoffset":
					g.xoffset = charVal;
					
				case "yoffset":
					g.yoffset = charVal;
					
				case "xadvance":
					g.xadvance = charVal;
					
				case "page":
					g.page = charVal;
					
				case "chnl":
					g.chnl = charVal;
			}
		}
		
		glyphMap[name][g.id] = g;
	}
	
	public static function registerFont(fontPath:String, name:String) {
		if (!bDataMap.exists(name)) {
			var pngPath = StringTools.replace(fontPath, ".fnt", ".png");
			Tools.LoadImage(pngPath, function(img) {
				addSheet(name, new BitmapData(img));
				//trace(haxe.Json.stringify(img.data));
				Tools.LoadFile(fontPath, function(font:String) {
					glyphMap[name] = new Map();
					
					parseFont(font, name);
				});
			});
		}
		else {
			trace('Font with name "${name}" is already registered!');
		}
	}
	
	override private function get_width():Float {
		return this._bd.width;
	}
	
	override private function get_height():Float {
		return this._bd.height;
	}
	
}
