package gostd;

extern interface Writer {
    extern function Write(a:Int,b:Int):Int;
}

@:native("interface{}")
extern interface EmptyInterface {
    
}