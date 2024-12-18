package;
import gostd.NonPtr;

class Tuple2<@:nonptr T1,@:nonptr T2> {
    #if !macro
    public function new(?_a,?_b){
        a=_a;
        b=_b;
    }
    public var a:T1;
    public var b:T2;
    public static function multi_return<T1,T2>(_a:T1,_b:T2):Tuple2<T1,T2>{
        var out=@:generics("T1,T2") new Tuple2(_a,_b);
        out.a=_a;
        out.b=_b;
        return out;
    }
    #end
    /*
    public static macro  function multi_return_lang<T,T2>(func:Expr,type:Expr,arg:Expr):Expr {
        return macro untyped __go__('Tuple2_multi_return[$type,error]($func)',$arg);
    }
    */
}