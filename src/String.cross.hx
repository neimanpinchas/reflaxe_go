package;

/**
	Your target needs to provide custom implementations of every Haxe API class.
	How this is achieved is different for each target, so be sure to research and try different methods!

	To help you get started, this String.hx was provided.
	But you'll need to handle the rest from here!

	This file is based on the cross implementation for String:
	https://github.com/HaxeFoundation/haxe/blob/development/std/String.hx

	-- Examples --
	JavaScript  https://github.com/HaxeFoundation/haxe/tree/development/std/js/_std/String.hx
	Hashlink    https://github.com/HaxeFoundation/haxe/blob/development/std/hl/_std/String.hx
	Python      https://github.com/HaxeFoundation/haxe/blob/development/std/python/_std/String.hx
**/
extern class String {
   var length(get, null):Int;
   
   inline function get_length(){
		return untyped __go__("len({0})",this);
   };

	function new(string:String):Void;

	function toUpperCase():String;
	function toLowerCase():String;
	function charAt(index:Int):String;
	function charCodeAt(index:Int):Null<Int>;
	inline function indexOf(str:String, ?startIndex:Int):Int {
		return untyped __go__("strings.Index({0},{1})",this,str);
	};
	inline function lastIndexOf(str:String, ?startIndex:Int):Int{
		//TODO position param
		return untyped __go__("strings.LastIndex({0},{1})",this,str);
	}
	inline function split(delimiter:String):Array<String>{
		var tmp=this;
		return untyped __go__("strings.Split({0},{1})",tmp,delimiter);
	};
	inline function substr(pos:Int, ?leng:Int):String{
		return if (leng==null||leng==0){
			untyped __go__("{0}[{1}:]",this,pos);
		} else {
			untyped __go__("{0}[{1}:{2}]",this,pos,pos+leng);
		}
	};
	inline function substring(startIndex:Int, ?endIndex:Int):String{
		return if (endIndex==null){
			untyped __go__("{0}[{1}:]",this,startIndex);
		} else {
			untyped __go__("{0}[{1}:{2}]",this,startIndex,endIndex);
		}
	};
	inline function toString():String{
		return this;
	};

	@:pure inline static function fromCharCode(code:Int):String{
		return untyped __go__("string([]byte{{0}})",code);
	};
}
