package haxe;
@:generic
class Json2<T> {
    
    public static function parse<T>(s:String):T {
        return gostd.Json.Parse(s);
    }
    
    public static function stringify(s:Dynamic):String {
        return gostd.Json.Stringify(s);
    }
}