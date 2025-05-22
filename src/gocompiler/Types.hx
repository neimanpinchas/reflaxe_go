package gocompiler;

import haxe.DynamicAccess;

enum UsePointer {
    Force;
    Never;
    Neutral;
}

typedef CompileCache = {
    gofmt:DynamicAccess<String>,
    final_code:DynamicAccess<String>,
}