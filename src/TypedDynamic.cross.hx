package;

import gostd.ComIface.EmptyInterface;

@:keep
class TypedDynamic {
    public var string_value:String;
    public function new() {
        
    }
    public static function fromString(s:String){
        var t=new TypedDynamic();
        t.string_value=s;
        return t;
    }
    public static function fromInt(i:Int){
        var t=new TypedDynamic();
        t.string_value=Std.string(i);
        return t;
    }
    public static function fromInterface(s:EmptyInterface){
        var t=new TypedDynamic();
        t.string_value=Std.string(s);
        return t;
    }
}