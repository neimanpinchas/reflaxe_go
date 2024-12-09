package haxe;
class Json {
    
    public static function parse(s:String):Dynamic {
        return gostd.Json.Parse(s);
    }
    
    public static function stringify(s:Dynamic):String {
        return gostd.Json.Stringify(s);
    }
}