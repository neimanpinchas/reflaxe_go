package haxe.ds;

extern class IMap<K,V> {
    inline function get(k:K):V{
        return untyped __go__("{0}[{1}]",this,k);
    }
    inline function exists(k:K):Bool{
        untyped __go__("_, ok={0}[{1}]",this,k);
        return untyped __go__("ok");
    }
    inline function set(k:K,v:V):Void{
        untyped __go__("{0}[{1}]={2}",this,k,v);
    }
    inline function toString() {
        return untyped __go__('fmt.Sprintf("%#v",{0})',this);
    }
}