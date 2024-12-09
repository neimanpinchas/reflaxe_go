package gostd;

import gostd.Lang.Duet;

@:native("io")
extern class Io {
    public static function ReadAll(rdr:IoReader):Duet<Array<Int>,Exception>;
}
@:native("ioutil")
extern class IoUtil {
    public static function ReadAll(rdr:IoReader):Duet<Array<Int>,Exception>;
}

@:native("io_dot_Reader")
extern interface IoReader {
    
}