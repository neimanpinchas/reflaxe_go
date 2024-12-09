package;

class Date {
    public var me:gostd.Time;
    public function new(y:Int,m:Int,d:Int,h:Int,mi:Int,s:Int) {
        var @:discard_error  loc =  untyped __go__('time.LoadLocation("")');
        var gotime=gostd.Time.TimePkg.Date(y,gostd.Time.TimePkg.Month(m),d,h,mi,s,0,loc);
        me=gotime;
    }
    public function getTime(){
        return Std.float(me.UnixMilli());
    }
    public function getMonth(){
        return Std.int(me.Month());
    }
    public function getDay(){
        return Std.int(me.Weekday());
    }
    public function getDate(){
        return me.Day();
    }
    public function getHours(){
        return me.Hour();
    }
    public function getMinutes(){
        return me.Minute();
    }
    public function getSeconds(){
        return me.Second();
    }
    public function getTimezoneOffset(){
        return me.Second();
    }
    public function getFullYear(){
        return me.Year();
    }
    public static function now(){
        return Date.fromGodate(gostd.Time.TimePkg.Now());
    }
    public function toString(){
        return me.String();
    }
    public function setGodate(gd) {
        me=gd;
    }
    public static inline function fromGodate(gd) {
        var d= new Date(0,0,0,0,0,0);
        d.setGodate(gd);
        return d;
    }
    public static inline function fromTime(ms:Float) {
        return Date.fromGodate(gostd.Time.TimePkg.UnixMilli(Std.int64(ms)));
    }
    public static function fromString(dt:String){
        var fmt=switch(dt.length){
            case 8: "hh:mm:ss";
			case 10: "YYYY-MM-DD";
			case 19: "YYYY-MM-DD hh:mm:ss";
            case _:"";
        }
        var tuple=gostd.Time.TimePkg.Parse(fmt,dt);
        if (tuple.b!=null){
            throw tuple.b;
        } else {

            return Date.fromGodate(tuple.a);
        }
    }
}