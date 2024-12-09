package;
import go.Syntax;


class Sys {
    public function new() {
        
    }
    public static function println(values) {
        Syntax.code('fmt.Println(values)');
    }
    public static function time():Float {
        return Date.now().getTime();
    }
    public inline static function getEnv(k:String):String {
        return gostd.Os.Getenv(k);
    }
    public inline static function getCwd():String {
        var @:discard_error wd=gostd.Os.Getwd();
        return wd;
    }
    public inline static function systemName():String {
        return untyped __go__("runtime.GOOS");
    }
    public static function isOfType(v:Dynamic, t:Dynamic):Bool{
    //TODO
        return true;
    }
}