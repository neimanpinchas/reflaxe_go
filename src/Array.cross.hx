package;

import haxe.iterators.ArrayKeyValueIterator;
using gostd.Lang;
import gostd.Lang.LangSyntax;

@:coreApi
@:add_file("Array.go")
extern class Array<T> {
	var length(default, null):Int;

	function new():Void;
	function concat(a:Array<T>):Array<T>;
	inline function join(sep:String):String{
		return {
			var tmpar=this;
			var stringified:Array<String>=tmpar.map((v)->Std.string(v));
			untyped __go__("strings.Join({0},{1})",stringified,sep);
		}
	};
	inline function pop():Null<T>{
		var out:T=null;
		untyped __go__("{1}, {0} = {0}[len({0})-1], {0}[:len({0})-1]",this,out);
		return out;
	};
	inline function push(x:T):Int{
		untyped __go__("{0}=append({0},{1})",this,x);
		var l;
		return l= this.length;
	};
	function reverse():Void;
    //@:nativeFunctionCode("{this}[{arg0}")
    //function at(n:Int):T;
	inline function shift():T{
        var tmp=this.at(0);
        this.slice_assign(this.slice_from(1,0));
        return tmp;
    };
	inline function slice(pos:Int, ?end:Int):Array<T>{
		return LangSyntax.slice_from_to(this,pos,end);
	};
	inline function sort(f:T->T->Int):Void{
		{
		var i = 0;
		var l = this.length;
		while (i < l) {
			var swap = false;
			var j = 0;
			var max = l - i - 1;
			while (j < max) {
				if (f(this[j], this[j + 1]) > 0) {
					var tmp = this[j + 1];
					this[j + 1] = this[j];
					this[j] = tmp;
					swap = true;
				}
				j += 1;
			}
			if (!swap)
				break;
			i += 1;
		}
	}
	};
	function splice(pos:Int, len:Int):Array<T>;
	inline function toString():String {
		return untyped __go__("string({0})",this);
	};
	function unshift(x:T):Void;

	inline function insert(pos:Int, x:T):Void {
		(cast this).splice(pos, 0, x);
	}

	inline function remove(x:T):Bool {
        return true;
		//return @:privateAccess HxOverrides.remove(this, x);
	}

	inline function contains(x:T):Bool {
		#if (js_es >= 6)
		return (cast this).includes(x);
		#else
		return this.indexOf(x) != -1;
		#end
	}

	#if (js_es >= 5)
	@:pure function indexOf(x:T, ?fromIndex:Int):Int;
	@:pure function lastIndexOf(x:T, ?fromIndex:Int):Int;
	#else
	inline function indexOf(x:T, ?fromIndex:Int):Int {
		return 0;
	}

	inline function lastIndexOf(x:T, ?fromIndex:Int):Int {
return 0;
	}
	#end

	@:pure
	inline function copy():Array<T> {
		return (cast this).slice();
	}

	inline function map<S>(f:T->S):Array<S> {
		return {
			var result:Array<S> = [];
			for(i in 0...length) {
				result[i] = f(this[i]);
			}
			return result;
		}
	}

	@:runtime inline function filter(f:T->Bool):Array<T> {
		return {
			var tmp=[for (v in this) if (f(v)) v];
			tmp;
		}
	}

	@:runtime inline function iterator():haxe.iterators.ArrayIterator<T> {
		return new haxe.iterators.ArrayIterator(this);
	}

	@:runtime inline function keyValueIterator():ArrayKeyValueIterator<T> {
		return new ArrayKeyValueIterator(this);
	}

	inline function resize(len:Int):Void {
		this.length = len;
	}
}
