package gostd;

@:native("math")
extern class GoMath {
    public static function IsNaN(values:Float):Bool;
    public static function IsInf(values:Float,sign:Int):Bool;
    public static function Floor(a:Float):Float;
    public static function Ceil(a:Float):Float;
    public static function Log(values:Float):Float;
    public static function Pow(values:Float,by:Float):Float;
    public static function Round(values:Float):Int;
    public static function Max(a:Float,b:Float):Float;
}