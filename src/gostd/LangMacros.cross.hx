package gostd;
#if macro
class LangMacros {
    
    public static  macro function go2exception(func:Expr):Expr {
        return macro  {
            var stati = $func;
                    if (stati.err!=null){
                        throw stati.err;
                    } else {
                        return stati.db;
                        };
                    }
        
    }
}
#end