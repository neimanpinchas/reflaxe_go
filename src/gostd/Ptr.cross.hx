package gostd;

class Ptr<T> {
    public inline function deref():T{
        return untyped __go__("/**/{0}", this);
    }
    public static inline function wrap<T>(v:T):Ptr<T> {
        return cast v;
    }
}