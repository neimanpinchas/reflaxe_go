package gostd;

import haxe.Int64;

@:native("time")
extern class TimePkg {
    extern static function Now():Time;
    //extern static function Parse(format:String,dt:String):Tuple2<Time,Exception>;
    inline static function Parse(format:String,dt:String):Tuple2<Time,Exception>{
        return untyped __go__("Tuple2_multi_return(time.Parse({0},{1}))",format,dt);
    };
    extern static function Date(y:Int,m:Month,d:Int,h:Int,mi:Int,s:Int,nn:Int,type:Location):Time;
    extern static function UnixMilli(y:Int64):Time;
    extern static function Month(y:Int):Month;
    extern static var Millisecond:Duration;
    extern static function LoadLocation(a:String):Location;
    extern static function NewTimer(interval:Duration):Timer;
    extern static function NewTicker(interval:Duration):Ptr<Ticker>;
    inline static function NewTimerWithMS(interval:Int){
        return NewTimer(mul(Duration(interval),Millisecond));
    }
    inline static function NewTickerWithMS(interval:Int){
        return NewTicker(mul(Duration(interval),Millisecond));
    }

    inline static function mul(a:Duration,b:Duration):Duration{
        return untyped __go__("{0}*{1}",a,b);
    }

    extern static function Duration(interval:Int):Duration;
}

@:valueType
@:native("time_dot_Duration")
extern class Duration {
    
}

@:native("time_dot_Timer")
extern class Timer {
    extern var C:Chan<Void>;
    extern function stop():Void;     
}
@:native("time_dot_Ticker")
extern class Ticker {
    extern var C:Chan<Void>;
    extern function stop():Void;     
}

class Chan<T> {
    public inline function recv<T>(){
        return untyped __go__("<-{0}",this);
    }
    public inline function send<T>(v){
        return untyped __go__("{0}<-{1}",this,v);
    }
}

@:native("time_dot_Time")
extern class Time {
    extern function UnixMilli():Int;
    extern function Unix():Int;
    extern function Month():Int;
    extern function Year():Int;
    extern function Day():Int;
    extern function Weekday():Int;
    extern function Date():Int;
    extern function Hour():Int;
    extern function Minute():Int;
    extern function Second():Int;
    extern function String():String;
}


@:native("time_dot_Location")
extern class Location {
    
}
@:native("time_dot_Month")
extern class Month {
    
}