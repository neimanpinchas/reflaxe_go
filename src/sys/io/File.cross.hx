package sys.io;

import gostd.Io;

// #if macro
// import gostd.LangMacros.go2exception;
// #end
class File {
    /*
    commented because aperantly macros are not working from reflaxe
	public static macro function go2exception(func:Expr):Expr {
		return macro {
			var stati = $func;
			if (stati.err != null) {
				throw stati.err;
			} else {
				return stati.db;
			};
		}
	}
    */

	public static function getContent(fn:String) {
		var stati = gostd.Os.ReadFile(fn);
		if (stati.err != null) {
			throw stati.err;
		} else {
			return stati.db.toString();
		};
	}

	// return go2exception(gostd.Os.ReadFile(fn));


public static function saveContent(fn:String, content:String) {
    //var rdr=gostd.Strings.NewReader(content);
    var stati = gostd.Os.WriteFile(fn,untyped __go__("[]byte({0})",content),777);
    /*
		if (stati.err != null) {
			throw stati.err;
		} else {
			return stati.db;
		};
        */
	
}

// #if macro
// #end
}
