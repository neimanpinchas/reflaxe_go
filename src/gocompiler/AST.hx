package gocompiler;

//#if (macro || go_runtime)

typedef SimpleVarInfo ={
	n:String,t:String,i:Expr,
	?has_init:Bool,
	?p:Bool,
}

/**
	Stores intermediate data generated from the Haxe class AST.
	The information here will be used to generate the Golang files.
**/
class Class {
	public var class_name="";
	public var imports=new Array<String>();
	public var static_vars=new Array<SimpleVarInfo>();
	public var vars=new Array<SimpleVarInfo>();
	public var funcs=new Array<Func>();
	public var static_funcs=new Array<Func>();
	public var generics=new Array<String>();
	public var main="";
	public var full_info="";
	public var initializers(default, null)=new Array<SimpleVarInfo>();
	public var isInterface(default, null)=false;
	public function new() {
		
	}
	// insert data relating to your target's class implementation...
}

typedef Func = {n:String,p:Array<{n:String,t:String}>,r:String,b:Expr,g:Array<String>}

/**
	Stores intermediate data generated from the Haxe enum AST.
	The information here will be used to generate the Golang files.
**/
class Enum {
	public function new() {
		
	}
	public var body="";
	// insert data relating to your target's enum implementation...
}

/**
	A Golang-based expression AST that will be generated from Haxe typed expressions.
	The information here will be used to generate expression content in `Class` and `Enum`.
**/
enum Expr {
	// input your targets expression types....
	Nothing;
	StringInject(code: String);
}

//#end
