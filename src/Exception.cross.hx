package;

@:native("error")
extern class Exception {
    inline function toString(){
        return untyped __go__("string({0})",this);
    }
    //public var 
}

@:native("errors")
extern class ExceptionTools {
    public static function Is(t: Exception,other:Exception):Bool;
}