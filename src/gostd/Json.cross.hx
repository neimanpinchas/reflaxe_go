package gostd;

extern class Json {
    inline static function Stringify(s:Dynamic):String {
        //TODO handle error normally
        var @:discard_error b_arr= untyped __go__("json.Marshal({0})",s);
        return untyped __go__("string({0})",b_arr);
    }
    
    inline static function Parse<T>(s:String):T {
        //TODO handle error normally
        var o:T=null;
        //untyped __go__("var o interface{}");
        var err = untyped __go__("json.Unmarshal([]byte(s),&{0})",o);
        return o;
    }
    /*
    inline static function Parse<T>(s:String):T {
        //TODO handle error normally
        var o:T;
        //untyped __go__("var o interface{}");
        var err = untyped __go__("json.Unmarshal([]byte(s),&{0})",o);
        return o;
    }
    */
}