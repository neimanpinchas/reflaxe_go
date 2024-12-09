package sys;

class Http {
    
    public static function requestUrl(url:String):String{
        var @:discard_error resp=untyped __go__('http.Get({0})',url);
        //TODO handle error
        var @:discard_error as_text=untyped __go__("io.ReadAll({0})",resp.Body);
        return untyped __go__('string({0})',as_text);
    }
}
