package gostd;

class Ptr<T> {
    public inline function deref():T{
        return untyped this;
    }
}