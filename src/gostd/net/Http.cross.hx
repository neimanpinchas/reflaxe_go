package gostd.net;

import gostd.ComIface.Writer;

@:native("http")
extern class Http {
    public extern static function HandleFunc(path:String,fun:Handler):Void;
    public extern static function ListenAndServe(addr:String,fun:Handler):Void;
}

@:native("http_dot_ResponseWriter")
extern class HttpResponseWriter implements Writer {
    public extern function Write(a:Int,b:Int):Int;
}

@:native("http_dot_Request")
extern class HttpRequest {
    public var RequestURI:String;
    public function FormValue(s:String):String;
}

typedef Handler = (w:HttpResponseWriter,r:Ptr<HttpRequest>)->Void;