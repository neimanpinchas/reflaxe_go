package;

import gostd.GoMath;

@:goimport("math")
@:goimport("math/rand")
class Math {
    public static var NEGATIVE_INFINITY:Float=12344;
    public static var POSITIVE_INFINITY:Float=12344;
    public static var NaN:Dynamic={};
    public static inline function isNaN(values:Float):Bool {
        return GoMath.IsNaN(values);
    }
    public static function isFinite(values:Float):Bool {
        return !GoMath.IsInf(values,0);
    }
    public static function floor(a):Int {
        return Std.int(GoMath.Floor(a));
    }
    public static function ceil(a):Int {
        return Std.int(GoMath.Ceil(a));
    }
    public static function log(a):Float {
        return GoMath.Log(a);
    }
    public static function pow(a,b):Int {
        return Std.int(GoMath.Pow(a,Std.float(b)));
    }
    public static function round(a):Int {
        return Std.int(GoMath.Round(a));
    }
    public static function fround(a):Float {
        return GoMath.Round(a);
    }
    public static function max(a,b):Float {
        return GoMath.Max(a,b);
    }
    public static inline function abs(a:Float):Int {
        return Std.int(a>0?a:0-a);
    }
    public static function random():Float {
        return untyped __go__("rand.Float64()");
    }
}