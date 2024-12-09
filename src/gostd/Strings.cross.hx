package gostd;

import gostd.Io.IoReader;

@:native("strings")
extern class Strings {
    public static function NewReader(s:String):IoReader;
}
