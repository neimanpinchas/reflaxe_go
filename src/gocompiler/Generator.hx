package gocompiler;

import haxe.io.Bytes;
import haxe.crypto.Base64;
import sys.io.File;
import haxe.macro.Compiler;
import haxe.macro.Context;
import sys.io.Process;
import gocompiler.AST.Func;
import haxe.Json;
#if macro
import haxe.macro.Compiler as HaxeCompiler;
#end
import gocompiler.TypeNamer.proper_name;
import gocompiler.Types.UsePointer;
import gocompiler.Compiler.CompilerConfig;

using StringTools;
using Lambda;

function get_define(n:String):Null<String> {
	#if macro
	return Context.definedValue(n);
	#else
	return ""; // Compiler.getDefine(n);
	#end
}

var config:CompilerConfig = try {
	trace(Sys.getCwd());
	Json.parse(File.getContent("./compiler_config.json"));
} catch (ex) {
	trace(ex);
	{
		class_blacklist: [],
		corrections:{},
	};
};

#if (macro || go_runtime)
var pkg = get_define("pkg") ?? "haxe_out";
var goimports = get_define("goimports") ?? "C:/Users/ps/Desktop/haxe_projects/tests/tools/cmd/goimports/goimports.exe";
var cache:Types.CompileCache=try {
	Json.parse(File.getContent("./compile_cache.json"));
} catch(ex){
	var a:Dynamic={};
	var b:Dynamic={};
	{gofmt: a,final_code: b}
};
var new_cache:Types.CompileCache={
	var a:Dynamic={};
	var b:Dynamic={};
	{gofmt: a,final_code: b}
};
/**
	Used to generate Golang class source code from your intermediate data.
**/
function generateClass(c:AST.Class):Null<String> {
	if (c.main != null && c.main.trim().length > 0) {
		trace("generating main");
		File.saveContent("main.go", '
package main

import (
	"./$pkg"
)

func main() {
	haxe_out.${c.main}
}

		');
	}
	//trace(c.class_name);
	var force_prt_on_recursive = ""; // TODO no idea what this is for
	var fields_str = c.vars.map(f -> {
		if (f == null) {
			trace("Skipping null field");
			return "//null\n";
		}
		return Util.fix_public(f.n, f.p) + " " + force_prt_on_recursive + f.t;
	}).join("\n");
	var static_vars_str = c.static_vars.map(f -> {
		return 'var ${c.class_name}_' + f.n + " " + f.t + (f.has_init ? " = " + switch f.i {
			case Nothing: "//noinit";
			case StringInject(code): code;
			case _: "//noinit";
		} : "");
	}).join("\n");
	// initializers.push("_inst." + f.field.name + "=" + init);
	//

	// not when generating single file var inj=code_injections.array().join("\n");
	var methods = c.funcs.map(v -> {
		return generateMethod(c, v, false);
	}).join("\n");
	var static_fields_str = c.static_funcs.map(v -> {
		return generateMethod(c, v, true);
	}).join("\n");
	var generics = c.generics.length > 0 ? "[" + c.generics.map(v -> v + " any").join(",") + "]" : "";
	var generics_use = c.generics.length > 0 ? "[" + c.generics.join(",") + "]" : "";
	var super_str = "";
	var inj = "";

	var imports = if (c.imports.length > 0) {
		'import (\n' + c.imports.map(imp -> '"$imp"').join("\n") + ')\n';
	} else {
		"";
	}
	var full_info_base64=Base64.encode(Bytes.ofString(c.full_info));

	var full_text = 'package $pkg\n
			$imports
		//	$full_info_base64
			$static_vars_str
	$static_fields_str \n type ${c.class_name}$generics struct{$super_str $fields_str}\n $methods
	 $inj'
		+ if (c.initializers.length > 0) {
			'
	func ${c.class_name}_inst_init$generics(_inst * $c.class_name$generics_use){
		${c.initializers.join("\n")}

	
	}
		
	$methods
	/**
	 ${Json.stringify(c)}
	 * /
	 */
	';
		} else {
			'';
		};
		for (k=>v in config.corrections){
			full_text=full_text.replace(k,v);
			try {

				//full_text=new EReg(k,"g").replace(full_text,v);
			} catch(ex){
				trace(ex);
			}
		}
		if (!cache.gofmt.exists(full_text)) trace("finished",c.class_name);
	return format(full_text);
}

function format(full_text) {
	if (cache.gofmt.exists(full_text)){
		//save for next time;
		new_cache.gofmt[full_text]=cache.gofmt[full_text];
		
		return cache.gofmt[full_text];
	}
	var p = new Process(goimports);
	p.stdin.writeString(full_text);
	p.stdin.close();
	var real = p.stdout.readAll();
	var errs = p.stderr.readAll().toString();
	if (errs.length > 0) {
		trace(full_text);
		trace(errs);
		// return null;
		return "//"+(errs + "\n" + full_text).split("\n").join("\n//");
	}
	var output=real.toString();
	new_cache.gofmt[full_text]=output;
	//trace(new_cache.gofmt.keys().length,"keys");
	return output;
}

function array_uniq(a:Array<String>):Array<String> {
	var uniq = new Map<String, Bool>();
	for (v in a)
		uniq.set(v, null);
	return {iterator: () -> uniq.keys()}.array();
}

function generateMethod(c:AST.Class, f:Func, isStatic) {
	var class_name = c.class_name;
	var ret_type = f.r;
	var ret = ret_type.length > 0 ? "(out " + ret_type + ")" : "";
	// var total_generics=array_uniq([].concat(f.g).concat(c.generics));
	var total_generics = f.g.length > 0 ? f.g : c.generics;
	var has_generics = total_generics.length > 0;
	var has_receiver = if (isStatic || f.n.endsWith("new") || has_generics) false else true;
	var first_param_this = !has_receiver && (!isStatic && has_generics) && f.n != "new";
	var generics_use = total_generics.length > 0 ? "[" + total_generics.join(",") + "]" : "";
	var thisvar = {n: "_inst", t: '* $class_name$generics_use'};
	if (first_param_this) {
		// f.p.unshift(thisvar);
		f.p.unshift(thisvar);
	}
	var local_generics = if (!has_receiver && total_generics.length > 0) {
		"[" + total_generics.map(v -> v + " any").join(",") + "]";
	} else {
		"";
	}
	var gendesc = '
		//has_generics $has_generics
		//has_receiver $has_receiver
		//first_param_this $first_param_this
	';
	var hdr = if (!has_receiver) '$gendesc\nfunc ${class_name}_${f.n}$local_generics' else 'func (${thisvar.n + " " + thisvar.t})${f.n}';
	var body = if (f.n == "new") {
		'
		${"_inst:=&"+class_name+'$generics_use{}'}
		${c.initializers.length>0? '${class_name}_inst_init(_inst)':"" }
		${generateExpression(f.b)}
		${"return _inst"}
		';
	} else {
		generateExpression(f.b);
	}
	if (c.isInterface) {
		return f.n + '(${f.p.join(",")})$ret';
	}
	return '$hdr(${f.p.map(v -> v.n + " " + v.t).join(",")})  ${f.n == "new" ? "*" + '$class_name$generics_use' : '$ret'}{
		 $body
	} /* ${f.g} */';
}

/**
	Used to generate Golang enum source code from your intermediate data.
**/
function generateEnum(c:AST.Enum):Null<String> {
	// convert your intermediate `Enum` type to Golang source code...
	return format(c.body);
}

/**
	Convert `AST.Expr` to source code.
	This should be used in `generateClass` or `generateEnum`.
**/
function generateExpression(e:AST.Expr):Null<String> {
	if (e == null) {
		return "//null expr";
	}
	return switch (e) {
		// Example for direclty injecting source code.
		case StringInject(code): code;
		case Nothing: "";

			// TODO: implement other cases that are created...
	}
}
#end
