// This code borrowed from "Xinf", http://xinf.org
// Copyright of original author.
package com.babylonhx.extensions.svg;

// https://github.com/openfl/svg
class PathParser {
	
    var lastMoveX:Float;
    var lastMoveY:Float;
    var prev:PathSegment;

    
    static var sCommandArgs:Array<Int>;

    static inline var MOVE  = "M".code;
    static inline var MOVER = "m".code;
    static inline var LINE  = "L".code;
    static inline var LINER = "l".code;
    static inline var HLINE = "H".code;
    static inline var HLINER = "h".code;
    static inline var VLINE = "V".code;
    static inline var VLINER = "v".code;
    static inline var CUBIC = "C".code;
    static inline var CUBICR = "c".code;
    static inline var SCUBIC = "S".code;
    static inline var SCUBICR = "s".code;
    static inline var QUAD = "Q".code;
    static inline var QUADR = "q".code;
    static inline var SQUAD = "T".code;
    static inline var SQUADR = "t".code;
    static inline var ARC = "A".code;
    static inline var ARCR = "a".code;
    static inline var CLOSE = "Z".code;
    static inline var CLOSER = "z".code;

    static inline var UNKNOWN = -1;
    static inline var SEPARATOR = -2;
    static inline var FLOAT = -3;
    static inline var FLOAT_SIGN = -4;
    static inline var FLOAT_DOT = -5;
    static inline var FLOAT_EXP = -6;


    public function new() {
        if (sCommandArgs == null) {
           sCommandArgs = [];
           for(i in 0...128) {
              sCommandArgs[i] = commandArgs(i);
		   }
        }
    }

    public function parse(pathToParse:String, inConvertCubics:Bool):Array<PathSegment> {
        lastMoveX = lastMoveY = 0;
        var pos = 0;
        var args = new Array<Float>();
        var segments = new Array<PathSegment>();
        var current_command_pos = 0;
        var current_command = -1;
        var current_args = -1;
        
        prev = null;

        var len = pathToParse.length;
        var finished = false;
        while (pos <= len) {
            var code = pos == len ? 32 : pathToParse.charCodeAt(pos);
            var command = (code > 0 && code < 128) ? sCommandArgs[code] : UNKNOWN;
			
            if (command == UNKNOWN) {
				throw("failed parsing path near '" + pathToParse.substr(pos) + "'");
			}
			 
            if (command == SEPARATOR) {
               pos++;
            }
            else if (command <= FLOAT) {
				var end = pos + 1;
				var e_pos = -1;
				var seen_dot = command == FLOAT_DOT;
				if (command == FLOAT_EXP) {
					e_pos = 0;
					seen_dot = true;
				}
				while (end < pathToParse.length) {
					var ch = pathToParse.charCodeAt(end);
					var code =  ch < 0 || ch > 127 ? UNKNOWN :sCommandArgs[ch];
					if (code > FLOAT) {
						break;
					}
					if (code == FLOAT_DOT && seen_dot) {
						break;
					}
					if (e_pos >= 0) {
						if (code == FLOAT_SIGN) {
							if (e_pos != 0) {
								break;
							}
						}
						else if (code != FLOAT) {
							break;
						}
                        
						e_pos++;
					}
					else if (code == FLOAT_EXP) {
						if (e_pos >= 0) {
							break;
						}
						e_pos = 0;
						seen_dot = true;
					}
					else if (code == FLOAT_SIGN) {
						break;
					}
					end++;
				}
				if (current_command < 0) {
					//throw "Too many numbers near '" +
                    //pathToParse.substr(current_command_pos) + "'";
				}
				else {
					var f = Std.parseFloat(pathToParse.substr(pos, end - pos));
					args.push(f);
				}
				pos = end;
			}
            else {
               current_command = code;
               current_args = command;
               finished = false;
               current_command_pos = pos;
               args = [];
               pos++;
            }
			
            var px:Float = 0.0;
            var py:Float = 0.0;
            if (current_command >= 0) {
				if (current_args == args.length) {
					if (inConvertCubics && prev != null) {
						px = prev.prevX();
						py = prev.prevY();
					}
					prev = createCommand(current_command, args);
					if (prev == null) {
						throw "Unknown command " + String.fromCharCode(current_command) + " near '" + pathToParse.substr(current_command_pos) + "'"; 
					}
					if (inConvertCubics && prev.getType() == PathSegment.CUBIC) {
						var cubic:CubicSegment = cast prev;
						var quads = cubic.toQuadratics(px, py);
						for (q in quads) {
							segments.push(q);
						}
					}
					else {
						segments.push(prev);
					}
					
					finished = true;
					if (current_args == 0) {
						current_args = -1;
						current_command = -1;
					}
					else if (current_command == MOVE) {
						current_command = LINE;
					}
					else if (current_command == MOVER) {
						current_command = LINER;
					}
					
					current_command_pos = pos;
					args = [];
				}
            }
        }
		
        if (current_command >= 0 && !finished) {
            throw "Unfinished command (" + args.length + "/" + current_args + ") near '" + pathToParse.substr(current_command_pos) + "'"; 
        }
        
        return segments;
    }
    
    function commandArgs(inCode:Int):Int {
		if (inCode == 10) {
			return SEPARATOR;
		}
		
		var str = String.fromCharCode(inCode).toUpperCase();
		if (str >= "0" && str <= "9") {
			return FLOAT;
		}
		
		switch(str) {
			case "Z": 
				return 0;
				
			case "H", "V": 
				return 1;
				
			case "M", "L", "T": 
				return 2;
				
			case "S", "Q": 
				return 4;
				
			case "C": 
				return 6;
				
			case "A": 
				return 7;
				
			case "\t", "\n", " ", "\r", ",": 
				return SEPARATOR;
				
			case "-": 
				return FLOAT_SIGN;
				
			case "+": 
				return FLOAT_SIGN;
				
			case "E", "e": 
				return FLOAT_EXP;
				
			case ".": 
				return FLOAT_DOT;
		}
		
		return UNKNOWN;
    }

    function prevX():Float {
		return (prev != null) ? prev.prevX() : 0;
	}
    function prevY():Float {
		return (prev != null) ? prev.prevY() : 0;
	}
    function prevCX():Float {
		return (prev != null) ? prev.prevCX() : 0;
	}
    function prevCY():Float {
		return (prev != null) ? prev.prevCY() : 0;
	}
    
    function createCommand(code:Int , a:Array<Float>):PathSegment {
        switch(code) {
			case MOVE:
				lastMoveX = a[0];
				lastMoveY = a[1];
				return new MoveSegment(lastMoveX, lastMoveY);
				
			case MOVER:
				lastMoveX = a[0] + prevX();
				lastMoveY = a[1] + prevY();
				return new MoveSegment(lastMoveX, lastMoveY);
				
			case LINE:  
				return new DrawSegment(a[0], a[1]);
				
			case LINER: 
				return new DrawSegment(a[0] + prevX(), a[1] + prevY());
				
			case HLINE:  
				return new DrawSegment(a[0], prevY());
				
			case HLINER: 
				return new DrawSegment(a[0] + prevX(), prevY());
				
			case VLINE:  
				return new DrawSegment(prevX(), a[0]);
				
			case VLINER: 
				return new DrawSegment(prevX(), a[0] + prevY());
				
			case CUBIC:
				return new CubicSegment(a[0], a[1], a[2], a[3], a[4], a[5]);
				
			case CUBICR:
				var rx = prevX();
				var ry = prevY();
				return new CubicSegment(a[0] + rx, a[1] + ry, a[2] + rx, a[3] + ry, a[4] + rx, a[5] + ry);
				
			case SCUBIC:
				var rx = prevX();
				var ry = prevY();
				return new CubicSegment(rx * 2 - prevCX(), ry * 2 - prevCY(), a[0], a[1], a[2], a[3]);
				
			case SCUBICR:
				var rx = prevX();
				var ry = prevY();
				return new CubicSegment(rx * 2 - prevCX(), ry * 2 - prevCY(), a[0] + rx, a[1] + ry, a[2] + rx, a[3] + ry);
				
			case QUAD: 
				return new QuadraticSegment(a[0], a[1], a[2], a[3]);
				
			case QUADR:
				var rx = prevX();
				var ry = prevY();
				return new QuadraticSegment(a[0] + rx, a[1] + ry, a[2] + rx, a[3] + ry);
				
			case SQUAD:
				var rx = prevX();
				var ry = prevY();
				return new QuadraticSegment(rx * 2 - prevCX(), rx * 2 - prevCY(), a[2], a[3]);
				
			case SQUADR:
				var rx = prevX();
				var ry = prevY();
				return new QuadraticSegment(rx * 2 - prevCX(), ry * 2 - prevCY(), a[0] + rx, a[1] + ry);
				
			case ARC:
				return new ArcSegment(prevX(), prevY(), a[0], a[1], a[2], a[3] != 0., a[4] != 0., a[5], a[6]);
				
			case ARCR:
				var rx = prevX();
				var ry = prevY();
				return new ArcSegment(rx, ry, a[0], a[1], a[2], a[3] != 0., a[4] != 0., a[5] + rx, a[6] + ry);
				
			case CLOSE:
				return new DrawSegment(lastMoveX, lastMoveY);
				
			case CLOSER:
				return new DrawSegment(lastMoveX, lastMoveY);
		}
		
        return null;
    }
	
}
