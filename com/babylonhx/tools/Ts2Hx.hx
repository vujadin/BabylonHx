package com.babylonhx.tools;

import haxe.Json;
import haxe.Timer;

class Ts2Hx {

    static private var _timeouts:Map<Int,Timer> = new Map<Int,Timer>();
    static private var _intervals:Map<Int,Timer> = new Map<Int,Timer>();
    static private var _nextTimerId:Int = 1;

    static public function getValue(obj:Dynamic, key:Dynamic):Dynamic {
        if (Std.is(obj, Array)) {
            return cast(obj, Array<Dynamic>)[Std.int(key)];
        } else {
            return Reflect.field(obj, cast(key, String));
        }
    }

    static public function setValue(obj:Dynamic, key:Dynamic, val:Dynamic):Dynamic {
        if (Std.is(obj, Array)) {
            cast(obj, Array<Dynamic>)[Std.int(key)] = val;
        } else {
            Reflect.setField(obj, cast(key, String), val);
        }
        return val;
    }

    static public function isTrueInt(aInt:Int):Bool {
        #if cpp
        return aInt != 0.0 && !Math.isNaN(aInt);
        #else
        return aInt != 0 && aInt == aInt;
        #end
    }

    static public function isTrueFloat(aFloat:Float):Bool {
        #if cpp
        return aFloat != 0.0 && !Math.isNaN(aFloat);
        #else
        return aFloat != 0.0 && aFloat == aFloat;
        #end
    }

    static public function isTrueString(aString:String):Bool {
        return aString != null && aString.length > 0;
    }

    static public function isTrue(obj:Dynamic):Bool {
        return (Reflect.isObject(obj) && (!Std.is(obj, String) || cast(obj, String).length > 0))
            || (Std.is(obj, Bool) && cast(obj, Bool) == true)
            || (Std.is(obj, Int) && isTrueInt(cast(obj, Int)))
            || (Std.is(obj, Float) && isTrueFloat(cast(obj, Float)));
    }

    static public function areEqual(obj1:Dynamic, obj2:Dynamic):Bool {
        return obj1 == obj2;
    }

    static public function setTimeout(fn:Dynamic, delay:Int):Int {
        var timerId:Int = _nextTimerId++;
        var timer:Timer = new Timer(delay);
        _timeouts.set(timerId, timer);
        timer.run = function() {
            timer.stop();
            _timeouts.remove(timerId);
            fn();
        };
        return timerId;
    }

    static public function clearTimeout(id:Int):Void {
        if (_timeouts.exists(id)) {
            var timer:Timer = _timeouts.get(id);
            _timeouts.remove(id);
            timer.stop();
        }
    }

    static public function setInterval(fn:Dynamic, interval:Int):Int {
        var timerId:Int = _nextTimerId++;
        var timer:Timer = new Timer(interval);
        _intervals.set(timerId, timer);
        timer.run = fn;
        return timerId;
    }

    static public function clearInterval(id:Int):Void {
        if (_intervals.exists(id)) {
            var timer:Timer = _intervals.get(id);
            _intervals.remove(id);
            timer.stop();
        }
    }

    static public function JSONstringify(value:Dynamic, replacer:Dynamic = null, space:Dynamic = null):String {
        var finalSpace:String;
        if (Std.is(space, Int)) {
            finalSpace = "";
            var i:Int = 0;
            while (i < space) {
                finalSpace += " ";
                i++;
            }
        } else {
            finalSpace = space;
        }
        return Json.stringify(value, replacer, finalSpace);
    }

    static public function JSONparse(value:String):Dynamic {
        return Json.parse(value);
    }

    static public function forEach(input:Dynamic, callback:Dynamic):Void {
        if (Std.is(input, Array)) {
            var inputAsArray:Array<Dynamic> = cast(input, Array<Dynamic>);
            var len:Int = inputAsArray.length;
            var i:Int = 0;
            var numberOfArgs:Int = -1;

            // Very dirty way of checking the callback signature
            // Using reflection would be a better idea, if possible. Maybe Rtti on haxe 3.2.
            if (i < len) {
                try {
                    callback(inputAsArray[i], i, inputAsArray);
                    numberOfArgs = 3;
                } catch (e:Dynamic) {
                    try {
                        callback(inputAsArray[i], i);
                        numberOfArgs = 2;
                    } catch (e:Dynamic) {
                        callback(inputAsArray[i]);
                        numberOfArgs = 1;
                    }
                }
                i++;
            }
            if (numberOfArgs == 3) {
                while (i < len) {
                    callback(inputAsArray[i], i, inputAsArray);
                    i++;
                }
            }
            else if (numberOfArgs == 2) {
                while (i < len) {
                    callback(inputAsArray[i], i);
                    i++;
                }
            }
            else {
                while (i < len) {
                    callback(inputAsArray[i]);
                    i++;
                }
            }
        } else {

            //Reflect.callMethod(input, 'forEach', [callback]);
        }
    }
}
