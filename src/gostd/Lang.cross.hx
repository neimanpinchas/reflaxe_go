package gostd;

extern class Lang {
    public extern static function go(d:Dynamic):Void;
    public extern static function append(d:Dynamic,d2:Dynamic):Void;
}

@:native("error")
extern class GoError {

}



class LangSyntax {
    
    public static inline function slice_to<T>(v:Array<T>,i1:Int,i2:Int):Array<T>{
        return untyped __go__("{0}[:{1}]",v,i2);
    }

    public static inline function slice_from<T>(v:Array<T>,i1:Int,i2:Int):Array<T>{
        return untyped __go__("{0}[{1}:]",v,i1);
    }
    public static inline function slice_clone<T>(v:Array<T>,i1:Int,i2:Int):Array<T>{
        return untyped __go__("{0}[:]",v);
    }
    public static inline function slice_from_to<T>(v:Array<T>,i1:Int,i2:Int):Array<T>{
        return untyped __go__("{0}[{1}:{2}]",v,i1,i2);
    }
    public static inline function at<T>(v:Array<T>,i:Int):T{
        return untyped __go__("{0}[{1}]",v,i);
    }
    public static inline function slice_assign<T>(v:Array<T>,f){
        untyped __go__("{0}={1}",v,f);
    }
    public static inline function iface_to_type(v,) {
        
    }


}


@:multiReturn class Duet<T1,T2> {
    public function new() {
        //db=_db;
        //err=_err;
    }
    public var db:T1;
    public var err:T2;
}
