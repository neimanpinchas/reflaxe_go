package haxe;

import gostd.Time;
import gostd.Lang.go;

class Timer {
	public var ms:Int;
    public static function stamp():Int {
        return cast(TimePkg.Now().Unix(),Int);
    }
	public function new(_ms){
		ms=_ms;
		var timer=gostd.Time.TimePkg.NewTickerWithMS(ms);
		go(()->{
			while(true) {
				timer.deref().C.recv();
				run();
			}
		});
	}
	public dynamic function run(){
		trace("timer tick");
	}
}
