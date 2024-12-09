package haxe.ds;


@:native("map[string]{0}")
extern class NativeMap {
    
}
@:valueType
@:native("map[string]")
//@:generic
//@:genericBuild(Macro.build())
extern class StringMap<V>{//(NativeMap) {
    public function new();
    //public inline function new(){
    //   return untyped __go__("map[string]{0}",$type(V));
    //}
    inline function set(k:String,v:V):Void {
        untyped __go__("{0}[{1}]={2}",this,k,v);
    }
    inline function get(k):Null<V> {
        return untyped __go__("{0}[{1}]",this,k);
    }
    inline function remove(k):Void {
        untyped __go__("delete {0}[{1}]",this,k);
    }
    inline function clear() {
        untyped __go__("clear({0})",this);
    }
    public inline function exists(k:String):Bool{
        untyped __go__("_, ok:={0}[{1}]",this,k);
        return untyped __go__("ok");
    }
    public inline function keys():Array<String>{
       return  untyped __go__("slices.Collect(maps.Keys({0}))",this);
    }
}