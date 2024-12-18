package;

@:extern
@:native("fmt")
class Fmt {
    public extern static function Print(what:Dynamic):Void;
    public overload extern static function Fprintf(stream:gostd.ComIface.Writer,whata:Dynamic,whatb:Dynamic):Void;
    public overload extern static function Fprintf(stream:gostd.ComIface.Writer,whata:Dynamic):Void;
}