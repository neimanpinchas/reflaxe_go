package gostd;

@:native("regexp_dot_Regexp")
extern class Regex {
    public function  FindAllStringSubmatch(s :String, n :Int):Array<Array<String>>;
    public function  Split(s :String, n :Int):Array<String>;
}
@:native("regexp")
extern class RegexPkg {
    public static function MustCompile(pat:String):Ptr<Regex>;
}