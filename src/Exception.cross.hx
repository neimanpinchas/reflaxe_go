package;

@:native("error")
extern class Exception {
    inline function toString(){
        return Fmt.Sprint(this);
    }
    public var stack(get,never):String;
    inline function get_stack() {
        return gostd.Debug.Stack().toString();
    }
}

@:native("errors")
extern class ExceptionTools {
    public static function Is(t: Exception,other:Exception):Bool;
}