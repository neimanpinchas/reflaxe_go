package gostd;

import gostd.Lang.Duet;

@:native("os")
extern class Os {
    extern static function Getenv(s:String):String;
    extern static function Stat(s:String):Duet<gostd.Os.FileInfo,Exception>;
    extern static function ReadDir(s:String):Duet<Array<String>,Exception>;
    extern static var ErrNotExist:Exception;
    extern static function Getwd():String;
    extern static function ReadFile(p:String):Duet<Array<Int>,Exception>;
    extern static function WriteFile(p:String,d:Array<Int>,mode:Int):String;
}


@:native("os_dot_FileInfo")
extern class FileInfo {
    public function ModTime():Time;
}