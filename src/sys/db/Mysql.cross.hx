package sys.db;
import gostd.Lang.Duet;
import haxe.Exception;
import sys.db.Connection;
import gostd.Ptr;

typedef MysqlOps = 
    {
		host:String,
		?port:Int,
		user:String,
		pass:String,
		?socket:String,
		?database:String
	}


class Mysql {
    public static function connect(params:MysqlOps):Connection {
        var con=new MysqlConnection(params);
        return con;
    }
}

/*
db, err := sql.Open("aaa", "aaa")
rows,err:=db.Query("select 1",)
*/
class MysqlConnection implements Connection {
    var db:Ptr<DB>;
    var params:Dynamic;
    public function new(params:MysqlOps) {
        var db_err=Sql.Open("mysql",'mysql://${params.user}:${params.pass}@${params.host}:${params.port}/${params.database??""}');
        if (db_err.err!=null){
            throw db_err.err;
        }
        db=db_err.db;
    }

    public function request(sql):ResultSet {
        var results_err=db.deref().Query(sql,params);
        /*
        var out=[];
        while (results_err.db.deref().Next()){
            var iface:Array<Dynamic>=[];
            results_err.db.deref().Scan(iface);
            out.push(iface);
        }
        */
        if (results_err.err!=null){
            throw results_err.err;
        }

        return new MysqlResultSet(results_err.db);

    }

    public function close() {
        db.deref().Close();
    }

    public function escape(s:String) {
        return s.split("'").join("''");
    }

    public function quote(s:String) {
        //if (s.indexOf(0) >= 0)
            //if (s.indexOf("\000") >= 0)
        //    return "x'" + new String(untyped _encode(s.__s, "0123456789ABCDEF".__s)) + "'";
        return "'" + s.split("'").join("''") + "'";
    }

    public function addValue(s:StringBuf, v:Dynamic) {
        trace(s,v);
        /*
        var t = Type.typeof(v);
        if (t==TInt||t==TNull)
            s.add(v);
        else if (t==TBool)
            s.add(if (v) 1 else 0);
        else
            s.add(quote(Std.string(v)));
        */
    }

    public function lastInsertId() {
        return 0;//_last_id(c);
    }

    public function dbName() {
        return "SQLite";
    }

    public function startTransaction() {
        request("BEGIN TRANSACTION");
    }

    public function commit() {
        request("COMMIT");
    }

    public function rollback() {
        request("ROLLBACK");
    }
    
}

@:native("sql")
extern class Sql {
    public static function Open(driver:String,dsn:String):Duet<Ptr<DB>,Exception>;
}

@:native("sql_dot_DB")
extern class DB {
    public function Query(str:String,params:Dynamic):Duet<Ptr<SqlRows>,Exception>;
    public function Close():Void;
}

@:native("sql_dot_Rows")
extern class SqlRows {
    public function Next():Bool;       
    public function Scan(out:Dynamic):Void;
    public function Close():Void;
    public function Columns():Duet<Array<String>,Exception>;

}



class MysqlResultSet implements sys.db.ResultSet {
    public var length(get, null):Int;
    public var nfields(get, null):Int;
    var field_names:Array<String>;

    var r:Ptr<SqlRows>;
    var noutput:Dynamic;
    var soutput:Dynamic;
    var cache:Array<Dynamic>;
    var eof=false;

    public function new(r:Ptr<SqlRows>) {
        cache = new Array<Dynamic>();
        this.r = r;
        var hn=hasNext(); // execute the request
        if (!hn) eof=true;
    }

    function get_length() {
        if (nfields != 0) {
            while (true) {
                var c:Dynamic = doNext();
                if (c == null)
                    break;
                cache.push(c);
            }
            return cache.length;
        }
        return 0;
    }

    function get_nfields() {
       if (field_names!=null){
           return field_names.length;
       }
        return getFieldsNames().length;
    }

    public function hasNext() {
       var can_move=try {
           r.deref().Next();
       } catch(ex) {
           false;
       };
        if (can_move==false){
            r.deref().Close();
        }

        
        return can_move;
    }

    public function next():Dynamic {
       if (eof){
           return null;
       }
        var c = cache.pop();
        if (c != null)
            return c;
        return doNext();
    }

    private function doNext():Dynamic {
        noutput=r.deref().Columns();
        r.deref().Scan(soutput);
       return soutput;
    }

    public function results():List<Dynamic> {
        var l = new List<Dynamic>();
        do {
            var c = next();
            if (c == null)
                break;
            l.add(c);
        } while (hasNext());
        return l;
    }

    public function getResult(n:Int) {
        return Std.string(noutput[n]);
    }

    public function getIntResult(n:Int):Int {
        return noutput[n];
    }

    public function getFloatResult(n:Int):Float {
        return noutput[n];
    }

    public function getFieldsNames():Array<String> {
       if (field_names!=null){
           return field_names;
       }
        var @:discard_err fn= r.deref().Columns();
        field_names=fn.db;
        return field_names;
    }


}
