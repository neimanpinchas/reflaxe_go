package gocompiler;

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
using StringTools;

using Lambda;

function get_define(n:String):Null<String>{
#if macro
	return Context.definedValue(n);
#else 
	return "";//Compiler.getDefine(n);
#end
}
#if (macro || go_runtime)
var pkg = get_define("pkg") ?? "haxe_out";
var goimports=get_define("goimports") ?? "C:/Users/ps/Desktop/haxe_projects/tests/tools/cmd/goimports/goimports.exe";

/**
	Used to generate Golang class source code from your intermediate data.
**/
function generateClass(c:AST.Class):Null<String> {
	trace(c.class_name);
	var force_prt_on_recursive = ""; // TODO no idea what this is for
	var fields_str = c.vars.map(f -> {
		if (f == null) {
			trace("Skipping null field");
			return "//null\n";
		}
		return f.n + " " + force_prt_on_recursive + f.t;
	}).join("\n");
	var static_vars_str = c.static_vars.map(f -> {
		return 'var ${c.class_name}_' + f.n + " " + f.t + (f.has_init ? " = " + switch f.i{
			case Nothing:"//noinit";
			case StringInject(code):code;
			case _:"//noinit";
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

	var full_text = 'package $pkg\n
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
		return format(full_text);
}

function format(full_text) {
	var p=new Process(goimports);
		p.stdin.writeString(full_text);
		p.stdin.close();
		var real=p.stdout.readAll();
		var errs=p.stderr.readAll().toString();
		if (errs.length>0){
			trace(full_text);
			trace(errs);
			//return null;
			return "/*"+full_text+"*/";
		}
		return real.toString();
}

function generateMethod(c:AST.Class, f:Func, isStatic) {
	var class_name = c.class_name;
	var ret_type = f.r;
	var ret = ret_type.length > 0 ? "(out " + ret_type + ")" : "";

	var has_generics = c.generics.length > 0;
	var has_receiver = if (isStatic || f.n.endsWith("new") || has_generics) false else true;
	var first_param_this = !has_receiver && (!isStatic && has_generics) && f.n != "new";
	var generics_use = c.generics.length > 0 ? "[" + c.generics.join(",") + "]" : "";
	var thisvar = {n: "_inst", t: '* $class_name$generics_use'};
	if (first_param_this) {
		// f.p.unshift(thisvar);
		f.p.unshift(thisvar);
	}
	var local_generics = if (!has_receiver && c.generics.length > 0) {
		"[" + c.generics.map(v -> v + " any").join(",") + "]";
	} else {
		"";
	}
	var hdr = if (!has_receiver) 'func ${class_name}_${f.n}$local_generics' else 'func (${thisvar.n + " " + thisvar.t})${f.n}';
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
