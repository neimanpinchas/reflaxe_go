package haxe;

@:native("error")
extern class Exception {
    @:custom("errors.New({0})")
    public function new(s:String,?p:haxe.Exception):Void;
        
    /*
    inline function new(s:String,?p:haxe.Exception) {
        return untyped __go__('errors.New({0})',s);
    }
        */
    inline function toString(){
        return untyped __go__("string({0})",this);
    }
    //public var 
}

@:native("errors")
extern class ExceptionTools {
    public static function Is(t: Exception,other:Exception):Bool;
}