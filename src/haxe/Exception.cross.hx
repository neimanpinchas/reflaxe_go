package haxe;

import gostd.Debug;

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
        return Fmt.Sprint(this);
    }
    public var message(get,never):String;
    inline function get_message():String{
        return toString();
    }
    public var stack(get,never):String;
    inline function get_stack(){
        return Debug.Stack().toString();
    }
    #if false
    public var previous(get,never):Exception;
    inline function get_previous(){
        return this;
    }
    #end
}

@:native("errors")
extern class ExceptionTools {
    public static function Is(t: Exception,other:Exception):Bool;
}