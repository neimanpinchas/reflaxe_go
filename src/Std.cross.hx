package;

import haxe.macro.Type.ClassType;
import haxe.Int64;
import gostd.Lang.GoError;
import gostd.Lang.Duet;
import go.Syntax;
import go.Syntax;

@:goimport("math/rand")
@:goimport("strconv")
class Std {
    public static function string(values:Dynamic):String {
        return untyped __go__('fmt.Sprint({0})',values);
    }
    public static function isOfType(v:Dynamic, t:Dynamic):Bool{
        //TODO
            return untyped __go__('reflect.TypeOf({0}).Kind()=={1}',v,t);
    }
    public static inline function float(i:Int):Float {
        return cast(i,Float);
    }
    public static inline function int(i:Float):Int {
        return untyped __go__("int({0})",i);
    }
    public static inline function int64(i:Float):Int64 {
        return untyped __go__("int64({0})",i);
    }
    public static function parseInt(s:String):Null<Int> {
        return {
            var tmp:Duet<Int,Exception>=untyped __go__("strconv.Atoi({0})",s);
            if (tmp.err==null){
                tmp.db;
            } else {
                0;
            }
        }
    }
    public static inline function parseFloat(s:String):Float {
        return {
            var tmp:Duet<Int,Exception>=untyped __go__("strconv.ParseFloat({0},64)",s);
            if (tmp.err==null){
                tmp.db;
            } else {
                0;
            }
        }
    }
    public static inline function random(max:Int) {
        return untyped __go__("rand.New(rand.NewSource(7)).Int31n(int32({0}))",max);
    }
    public static function is(v:Dynamic,t:Dynamic):Bool {
        return false;
    }
    public function new() {
        
    }
}

@:multiReturn extern class AtoiReturn{
    var parsed:Int;
    var err:GoError;
}