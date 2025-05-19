package haxe;

import gostd.Time.TimePkg;
import gostd.Time;
import gostd.Time;
import gostd.Lang.go;

class Timer {
	public var ms:Int;
	var _continue=true;
    public static function stamp():Int {
        return cast(TimePkg.Now().Unix(),Int);
    }
	public function stop(){
		_continue=false;
	}
	public function new(_ms){
		ms=_ms;
		var timer=gostd.Time.TimePkg.NewTickerWithMS(ms);
		go(()->{
			while(_continue) {
				timer.deref().C.recv();
				run();
			}
		});
	}
	public dynamic function run(){
		trace("timer tick");
	}
	public static function delay(f:()->Void,ms:Int){
		var t=new Timer(ms);
		t.run=()->{
			f();
			t.stop();
		}
		return t;
	}
}
