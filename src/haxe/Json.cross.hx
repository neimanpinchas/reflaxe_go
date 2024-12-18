package haxe;
class Json<T> {
    
    public static function parse<T>(s:String):T {
        return gostd.Json.Parse(s);
    }
    
    public static function stringify<T>(s:T):String {
        return gostd.Json.Stringify(s);
    }
}