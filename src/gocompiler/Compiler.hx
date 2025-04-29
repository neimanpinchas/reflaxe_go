package gocompiler;
import reflaxe.data.TypedExprOrString;
import gocompiler.AST.Enum;
import gocompiler.AST.Func;
import gocompiler.AST.SimpleVarInfo;
import gocompiler.AST.Expr;
import gocompiler.Util.anon_name;
import gocompiler.Util.is_multi_return;
import gocompiler.TypeNamer.proper_name;
import haxe.Json;
import sys.io.File;
using reflaxe.helpers.NullableMetaAccessHelper;
using reflaxe.helpers.NameMetaHelper;
import gocompiler.Types.UsePointer;
import haxe.macro.TypedExprTools;
using StringTools;
using reflaxe.helpers.TypedExprHelper;
using reflaxe.helpers.ClassFieldHelper;
using reflaxe.helpers.TypeHelper;


// Make sure this code only exists at compile-time.
#if (macro || go_runtime)
// Import relevant Haxe macro types.
import haxe.macro.Type;
// Import Reflaxe types
import reflaxe.GenericCompiler;
import reflaxe.data.ClassFuncData;
import reflaxe.data.ClassVarData;
import reflaxe.data.EnumOptionData;
import reflaxe.output.DataAndFileInfo;
import reflaxe.output.StringOrBytes;

using Lambda;

var code_injections = new Map<String, String>();
var imports = new Map<String, Bool>();
var pkg='haxe_out';
typedef CompilerConfig = {
	class_blacklist:Array<String>
}

/**
	The class used to compile the Haxe AST into your target language's code.

	This must extend from `GenericCompiler`.
**/
class Compiler extends GenericCompiler<AST.Class, AST.Enum, AST.Expr> {
	/**
		This is the function from the `GenericCompiler` to override to compile Haxe classes.
		Given the `haxe.macro.ClassType` and its variables and fields, extract data needed to generate your output.
		If `null` is returned, the class is ignored and nothing is compiled for it.

		https://api.haxe.org/haxe/macro/ClassType.html
	**/
	public var config:CompilerConfig = try {
		trace(Sys.getCwd());
		Json.parse(File.getContent("./compiler_config.json"));
	} catch (ex) {
		trace(ex);
		{
			class_blacklist: []
		};
	};

	public override function onCompileStart() {
		config.class_blacklist.push("PosException");
		config.class_blacklist.push("NotImplementedException");
		config.class_blacklist.push("LangSyntax");
		config.class_blacklist.push("ArrayIterator");
		config.class_blacklist.push("Chan");
		config.class_blacklist.push("error");
		config.class_blacklist.push("Ptr");
		super.onCompileStart();
	}

	public function compile_binop(e1, e2, op) {
		var st1 = compileExpressionToString(e1);
		var st2 = compileExpressionToString(e2);
		var t1 = proper_name(e1.t);
		var t2 = proper_name(e2.t);
		var final_st1 = convert_to_needed_type(st1, t2, t1);
		var final_st2 = convert_to_needed_type(st2, t1, t2);

		var hack_unused=if (op=="="){
			'\n_=$final_st1';
		} else {
			'';
		}

		// todo check for oposite
		return '$final_st1$op$final_st2'+'$hack_unused';
	}


	public override function onCompileEnd() {
		for (c in TypeNamer.classes){
			classes.push(c);
		}
		// for (c in classes){
		// 	if (c.data.trim().length==0){
		// 		classes.remove(c);
		// 	}
		// }
		/*
		classes.unshift(new DataAndFileInfo('package $pkg
		import(
			${{iterator:()->imports.keys()}.map(v->' "$v" ').join("\n")}
		)
		', current_class, null, null));
		*/
	}

	public function compileClassImpl(classType:ClassType, varFields:Array<ClassVarData>, funcFields:Array<ClassFuncData>):Null<AST.Class> {
		// code_injections=[];
		var out= new AST.Class();
		
		var current_class = classType;
		TypeNamer.current = classType;
		//TypeNamer.pkg = pkg;

		if (classType.isExtern) {
			return null;
		}

		if (config.class_blacklist.contains(classType.name)) {
			trace("skipping", classType.name);
			return null;
		}

		// TODO: implement
		out.class_name=classType.name;
		var class_name = classType.name;
		// trace(class_name);
		var inj = "";
		// var goimports=classType.meta.extract(":goimport");
		var goimports = NullableMetaAccessHelper.extractStringFromAllMeta(classType.meta, ":goimport");
		var add_file = NullableMetaAccessHelper.extractStringFromAllMeta(classType.meta, ":add_file");
		if (add_file.length > 0) {
			inj += classType;
		}
		trace(class_name, goimports);
		goimports.foreach((v) -> {
			trace("adding import");
			out.imports.push(v);
			return true;
		});

		out.generics=classType.params.map(p -> p.name);



		var main = compileExpressionImpl(getMainExpr(), false);

		if (true){//main.startsWith(class_name + "_")) {
			out.main="main todo";//main;
			code_injections["main"] = '\nfunc main(){
				$main
			}\n';
			inj += code_injections.array().join("\n");
		}
		var static_fields = new Array<SimpleVarInfo>();
		var initializers = [];
		var class_init=compileExpression(classType.init);
		var fields = varFields.map(f -> {
			var ftname = proper_name(f.field.type);
			var force_prt_on_recursive = if (ftname == class_name) {
				"*";
			} else {
				"";
			}
			var has_init = false;
			var init = try {
				var expr = (f.findDefaultExpr());
				if (expr == null) {
					StringInject("//was unable to get expr");
				} else if (f.hasDefaultValue()) {
					has_init = true;
					compileExpression(expr);
				} else {
					Nothing;
				}
			} catch (ex) {
				StringInject("//" + ex.toString());
			}
			var out:SimpleVarInfo=cast {};
			if (f.isStatic) {
				static_fields.push({
					n: f.field.name,
					t: force_prt_on_recursive + proper_name(f.field.type),
					i: init,
					has_init: has_init,
				});
				return null;
			} else if (has_init) {
				out.i=init;

			}
			if (f.field.name == "cache") {
				trace(f.field);
			}
			out.n=f.field.name;
			out.p=f.field.isPublic;
			out.t=force_prt_on_recursive + proper_name(f.field.type, UsePointer.Neutral, f.field.params);
			return out;
		});

		out.vars=fields;
		out.static_vars=static_fields;
		for (f in funcFields){
		//out.funcs = funcFields.map(function(f):Func {
			var func:Func=cast {};
			func.g=out.generics;
			func.n=f.field.name;
			//switch 
			func.b=compileExpressionImpl(f.expr,true);
			var args = f.args.map(a -> {
				return switch a.type {
					// case TEnum(t, params):
					// 	// t.get().name+"_"+a.name + ' ' + proper_name(a.type, UsePointer.Neutral);
					// 	a.name + ' ' + proper_name(a.type, UsePointer.Neutral);
					case _:
						{n:a.getName(),t:proper_name(a.type, UsePointer.Neutral)};
				}
			});
			func.p=args;
			var ret_type = proper_name(f.ret, Neutral);
			func.r=ret_type;
			var ret=ret_type;

			if (f.kind.match(MethDynamic) && !f.isStatic) {
				// todo setup initializer
				var arg_str=args.map(v->v.t).join(",");
				var init=StringInject('_inst.${f.field.name}=func(${arg_str}){
					${compileExpressionImpl(f.expr, false)}
				}');
				fields.push({n:f.field.name ,t: " func(" + arg_str + ")",i:init});
				initializers.push(init);
				continue;
				// "//" + f.field.name + " is dynamic \n ";
			}

			if (f.isStatic){
				out.static_funcs.push(func);
			} else {
				out.funcs.push(func);
			}

			

			//return out;
		};

		out.static_funcs.push({
			n: "__init__",
			g: [],
			b: class_init,
			r: "",
			p:[],
		});

		var fields_str = fields.join("\n");

		var super_str = classType.superClass != null ? "super " + (classType.superClass.t.get().name) + "\n" : "";
		trace("finished",class_name, goimports);
		return out;
	}

	/**
		Works just like `compileClassImpl`, but for Haxe enums.
		Since we're returning `null` here, all Haxe enums are ignored.

		https://api.haxe.org/haxe/macro/EnumType.html
	**/
	public function compileEnumImpl(enumType:EnumType, constructs:Array<EnumOptionData>):Null<AST.Enum> {
		var name = enumType.name;
		var simple = constructs.filter(v -> v.args.length == 0);
		var simple_count = simple.length;
		var multies = constructs.filter(v -> v.args.length > 0);
		var gen=enumType.params.length>0?"["+enumType.params.map(v->v.name+" any").join(",")+"]":"";
		// var body='package $pkg\n
		var fields = new Map<String, String>();
		var multi_str = multies.mapi((i, c) -> {
			var mapf = (v) -> {
				fields[v.name] = proper_name(v.type);
				return v.name + " " + proper_name(v.type);
			};
			var args = c.args.map(mapf).join(",");
			//var gen=c.field.params.map(v->v.name).join(",");
			return 'func ${name}_${c.name}$gen($args) ${name}_obj {
			var _e=${name}_obj{}
			_e.__hxindex=${i + simple_count}
			${c.args.map(v -> '_e.' + v.name + '=' + v.name).join("\n")}
			return _e
		}';
		}).join("\r\n");
		var body = '
		package $pkg
		type ${name}_int int
		type ${name}$gen interface {
			Index() int
			Fields() ${name}_obj
		}
		func (e ${name}_int) Index() int {
			return int(e);
		}

		func (e ${name}_int) Fields() ${name}_obj {
			return ${name}_obj{__hxindex:int(e)}
		}

		func (e ${name}_obj) Index() int {
			return int(e.__hxindex)
		}

		func (e ${name}_obj) Fields() ${name}_obj {
			return e
		}


		
		\n'
			+ simple.mapi((i, c) -> 'const ${name}_' + c.name + ' ${name}_int = $i').join("\n")
			+ '
		type ${name}_obj ${name}_fields
		$multi_str

		type ${name}_fields$gen struct {
			${{iterator:()->fields.keyValueIterator()}.map((kv)->kv.key+" "+kv.value).join("\n")}
			__hxindex int
		}
		';
		var out=new Enum();
		out.body=body;
		return out;
	}


	/**
		This is the final required function.
		It compiles the expressions generated from Haxe.

		PLEASE NOTE: to recusively compile sub-expressions, use these functions from `GenericCompiler`:
		```haxe
		GenericCompiler.compileExpression(expr: TypedExpr): Null<AST.Expr>
		GenericCompiler.compileExpressionOrError(expr: TypedExpr): AST.Expr
		```

		https://api.haxe.org/haxe/macro/TypedExpr.html
	**/
	public function compileExpressionImpl(expr:TypedExpr, topLevel:Bool):Null<AST.Expr> {
		if (expr==null){
			return StringInject("/* expr was null */");
		}
		return switch (expr.expr) {
			//these are not currently used but the one below in the string compiler
			// Here's a very basic example of converting `untyped __go__("something")` into source code...
			case TCall({expr: TIdent("__go__")}, [{expr: TConst(TString(s))}]): {
				trace("compiling",s);
				return StringInject(s);
			}
			case TCall({expr: TIdent("__go__")},el):{
				trace("compiling __go__");
				return StringInject(compileExpressionToString(el[0],true));
			}

			case _: StringInject(compileExpressionToString(expr));
		}
	}

	

	public function compileExpressionToString(expr:TypedExpr,nothing=false):Null<String> {
		if (expr == null) {
			return "";
		}
		return try {
			 //'/*${expr.expr.getName()}*/'+switch expr.expr {
			switch expr.expr {
				case TEnumIndex(e1): compileExpressionToString(e1) + ".Index()";
				case TIdent(s): {
						var fs = if (s.charAt(0) == "$") s.substr(1); else s;
						return '/*ident*/$fs';
					} // TargetCodeInjection.checkTargetCodeInjection("");
				case TCast(e, m):
					var expr = compileExpressionToString(e);
					return "/*TCast*/" + switch (m) {
						case TClassDecl(c):
							c.get().name + '($expr)';
						case TAbstract(a):
							proper_name(a.get().type) + '($expr)';
						case something:
							if (something == null)
								return expr;
							'/* ${something.getName()} */($expr)';
					}
				case TBlock(el):
					// return el.map(l->compileExpressionImpl(l,false)).join("\n");
					el.map(l -> l != null ? compileExpressionToString(l) : '0/*l was null???*/').join("\n");

				case TCall(e, el):
					var fname = compileExpressionToString(e);
					// if (fname=="Log_trace") trace(e,el);
					if (fname == "Syntax.code") {
						var format = compileExpressionToString(el[0]);
						return format.substring(1, format.length - 1);
					}
					if (fname == "Lang.go") {
						var funcname = compileExpressionToString(el[0], false);
						return "go " + funcname + "()";
					}
					if (fname.endsWith("__go__")) {
						return compileStringWithArgs(el[0],null,el);
						
					}

					var expected_args_array = switch (e.t) {
						case TFun(args, ret): args;
						case _: [];
					}

					var args=fill_args(el,expected_args_array);


					switch e.expr {
						case TField(e2, fa): {
								switch fa {
									case FInstance(cl, params, cf) if (cl.get().params.length > 0): {
											return cl.get().name + "_" + cf.get().name + "(" + compileExpressionToString(e2) + "," + args.join(",") + ")";
										}
									case _:
								}
							}
						case _:
					}


					var gen=e?.getFunctionTypeParams()?.map(v->try proper_name(v,Neutral) catch(ex) '/*$ex*/interface{}');
					var gen_string=gen!=null && gen.length>0 ? "["+gen.join(",")+"]":"";
					
					


					

					fname + gen_string+ "(" + args.join(",") + ")";
				case TField(e, fa): {
						return switch fa {
							case FInstance(cl, par, cf): {
									if (cl.get().meta.has(":multiReturn")) {
										compileExpressionToString(e) + "_" + cf.get().name;
									} else if (cl.get().name == "Array" && cf.get().name == "length") {
										'len(${compileExpressionToString(e)})';
									} else {
										var f=cf.get();
										compileExpressionToString(e) + "." + Util.fix_public(f.name,(!f.isMethodKind()) && f.isPublic);
									}
								}
							case FStatic(c, cf): {
									if (c.get().isExtern || cf.get().isExtern) {
										c.get().name + "." + cf.get().name;
									} else {
										c.get().name + "_" + cf.get().name;
									};
								};
							// case FAnon(cf):compileExpressionToString(e)+'["${cf.get().name}"].('+proper_name(cf.get().type)+')';
							case FAnon(cf): compileExpressionToString(e) + '.${cf.get().name}';
							case FEnum(e, enf): e.get().name + "_" + enf.name;
							case FDynamic(s): 'reflect.ValueOf(&${compileExpressionToString(e)}).Elem().FieldByName("$s")';
							case FClosure(c, cf): compileExpressionToString(e) + "/*FClosure*/." + cf.get().name;
							case el: compileExpressionToString(e) + "/fieldexpr/." + fa.getName();
						}
					}
				case TConst(c): switch c {
						case TString(s): haxe.Json.stringify(s);
						case TBool(b): if (b) "true" else "false";
						case TFloat(s): s;
						case TInt(i): '$i';
						case TNull: "nil";
						case TThis: "_inst";
						case TSuper: {
								return "_inst.super_new";
							}

						case t: '/*${t.getName()}*/';
					}
				case TEnumParameter(e1, ef, index):
					var e = switch ef.type {
						case TFun(args, ret):
							args[index].name;
						case _: Std.string(ef);
					}
					return compileExpressionToString(e1) + ".Fields()." + e;
					return e1 + "\n" + ef + "\n" + index + '\n${Std.string(proper_name(e1.t))}_obj.${ef.name}';
				case TSwitch(e, cases, edef): {
						var cases_str = cases.map(c -> 'case ${c.values.map(t -> compileExpressionToString(t)).join(",")}: 
				${compileExpressionToString(c.expr)}
				')
							.join("\n");
						'switch ${compileExpressionToString(e)} {
					${cases_str}
				}';
					}
				case TMeta(m, e1): "/*" + m.name + " meta */" + compileExpressionToString(e1);
				case TObjectDecl(fields): {
						var fs = fields.map(f -> f.name + ':' + compileExpressionToString(f.expr, false));
						function type_has_meta(t:Type,meta){
							return switch t {
								case TInst(t, params):t.get().meta.has(meta);
								case TAbstract(t, params):t.get().meta.has(meta);
								case _:false;
							}
						}
						
						var ptr=type_has_meta(expr.t,":valueType") ? "" :"&";
						return ptr + proper_name(expr.t, Never) + '{${fs.join(",\n")}}';
					}
				case TArray(e1, e2): switch e1.t {
					case TDynamic(t):{
						compileExpressionToString(e1) + '.([]interface{})[${compileExpressionToString(e2)}]';
					}
					case _:
					compileExpressionToString(e1) + '[' + compileExpressionToString(e2) + ']';
				}
				case TVar(v, rval): {
						var name = Util.fix_reserved(v.name);
						var discard = if (v.meta.has(":discard_error")) {
							",_";
						} else {
							"";
						}
						//var not_new=["_inst","out"];
						var not_new=["out"];
						var smiley=not_new.indexOf(name)>-1?"=":":=";
						var imr = is_multi_return(v.t);
						if (imr.length > 0) {
							return imr.map(f -> name + "_" + f).join(",") + smiley + compileExpressionToString(rval);
						}
						var thetype=proper_name(v.t, UsePointer.Neutral);
						var gen=gen_string(v.extra!=null?v.extra.params:[]);
						switch (v.t) {
							case TEnum(t, params): "/*type*/" + if (rval != null){
								//t.get()?.name + "_" + name + ":=" + compileExpressionToString(rval);
								name + smiley + compileExpressionToString(rval);
							} else {
								'var ${name} $thetype$gen';
							}
							case e: {
									if (rval != null) {
										var cmpexpr = compileExpressionToString(rval);
										//'var $name $thetype'+
										if (cmpexpr == "nil") {
											'';
										} else {
											'\n'+name + discard + smiley + cmpexpr+"\n_="+name;
										}
									} else {
										'var ${name}$discard $thetype$gen';
									}
								};
						}
					};
				// todo make custum new such as for exception
				case TNew(c, params, el): {
						var constructor=c.get().constructor.get();
						if (constructor!=null  && constructor.hasMeta(":custom")){
							var s=constructor.getNameOrMeta(":custom");
							trace(el);
							return compileStringWithArgs(s,null,[null].concat(el));
						}
						//trace(c.get().name,c.get().fields.get());
						var expected_args=constructor.type.getTFunArgs();
						//var p = el.map(v -> compileExpressionToString(v)).join(",");
						var p=fill_args(el,expected_args);
						var gen = params.length > 0 ? "[" + params.map(v -> proper_name(v)).join(",") + "]" : "";
						if (c.get().name.startsWith("map[")){
							return c.get().name+proper_name(params[0])+'{}';
						}
						c.get().name + '_new$gen(${p.join(",")})';
					};
				case TLocal(v): {
						return switch v.t {
							//case TEnum(t, params): return proper_name(v.t, Never) + "_" + v.name;
							case TEnum(t, params): return v.name;
							case _: Util.fix_reserved(v.name);
						}
					}
				case TFor(v, e1, e2): 'for {${e2}}';
				case TWhile(econd, e, normalWhile): 'for ${compileExpressionToString(econd)} {
				${compileExpressionToString(e)}
			}';
				case TParenthesis(e): '(${compileExpressionToString(e)})';
				case TBinop(op, e1, e2): switch op {
						case OpLt: compileExpressionToString(e1) + "<" + compileExpressionToString(e2);
						case OpLte: compileExpressionToString(e1) + "<=" + compileExpressionToString(e2);
						case OpGt: compileExpressionToString(e1) + ">" + compileExpressionToString(e2);
						case OpGte: compileExpressionToString(e1) + ">=" + compileExpressionToString(e2);
						// TODO first decl
						case OpAssign: compile_binop(e1, e2, "=");
						case OpAssignOp(op2): switch op2 {
								case OpAdd: compileExpressionToString(e1) + "=" + compileExpressionToString(e1) + "+" + compileExpressionToString(e2);
								case OpMult: compileExpressionToString(e1) + "=" + compileExpressionToString(e1) + "*" + compileExpressionToString(e2);
								case OpDiv: compileExpressionToString(e1) + "=float64(" + compileExpressionToString(e1) + "/" + compileExpressionToString(e2) + ")";
								case op3: compileExpressionToString(e1) + op3.getName();
							}
						case OpEq: {
								compile_binop(e1, e2, "==");
							}
						case OpNotEq: compile_binop(e1, e2, "!=");
						// todo do not convert to float if is within Std.int
						case OpDiv: "float64(" + compileExpressionToString(e1) + "/" + compileExpressionToString(e2) + ")";
						case OpMult: compileExpressionToString(e1) + "*" + compileExpressionToString(e2);
						case OpSub: compileExpressionToString(e1) + "-" + compileExpressionToString(e2);
						case OpBoolOr: compileExpressionToString(e1) + "||" + compileExpressionToString(e2);
						case OpBoolAnd: compileExpressionToString(e1) + "&&" + compileExpressionToString(e2);
						case OpAnd: compileExpressionToString(e1) + "&" + compileExpressionToString(e2);
						case OpOr: compileExpressionToString(e1) + "|" + compileExpressionToString(e2);
						case OpShl: compileExpressionToString(e1) + "<<" + compileExpressionToString(e2);
						case OpShr: compileExpressionToString(e1) + ">>" + compileExpressionToString(e2);
						case OpMod: compileExpressionToString(e1) + "%" + compileExpressionToString(e2);
						case OpAdd: {
								if (proper_name(e1.t) == "string") {
									compile_string_concat(e1,e2);
								} else {
									compileExpressionToString(e1) + "+" + compileExpressionToString(e2);
								}
							};
						case bin_op: compileExpressionToString(e1) + '/*binop${op.getName()}*/' + compileExpressionToString(e2);
					}

				case TUnop(op, postFix, e): switch op {
						case OpIncrement: {
								var varname = compileExpressionToString(e);
								// todo not neccerily int
								'func()int{
						${postFix ? 'orig:=$varname' : ''}
						$varname=$varname+1
						${postFix ? "return orig" : 'return $varname'}
					}()';
							}
						case OpDecrement: {
								var varname = compileExpressionToString(e);
								// todo not neccerily int
								'func()int{
						${postFix ? 'orig:=$varname' : ''}
						$varname=$varname-1
						${postFix ? "return orig" : 'return $varname'}
					}()';
							}
						case OpNot: "!" + compileExpressionToString(e);
						case u: op.getName() + compileExpressionToString(e);
					}
				case TReturn(e): if (e != null) "return "
						+ convert_to_needed_type(compileExpressionToString(e), proper_name(e.t), proper_name(expr.t)) else "return";
				case TIf(econd, eif, eelse): 'if ${compileExpressionToString(econd)} {
				${compileExpressionToString(eif)}
			}'
					+ if (eelse != null) ' else {
				${compileExpressionToString(eelse)}
			}' else '//no else';
				case TBreak:
					'break';
				case TContinue:
					'continue';
				case TThrow(e):
					'panic(${e != null ? compileExpressionToString(e) : "0"})';
				case TTry(e, catches):
					// todo check catch
					'func(){
					defer func() {
						if ex := recover(); ex != nil {
							${compileExpressionToString(catches[0].expr)}
						}
					}()
					${compileExpressionToString(e)}
				}()';
				case TFunction(tfunc): {
						try {
							var args = try {
								tfunc.args.map(v -> try v.v.name + " " + proper_name(v.v.t)).join(",");
							} catch (ex) {
								'/*' + Std.string(tfunc.args) + '*/';
							}
							//trace("compiled args");
							var type = proper_name(tfunc.t);
							//trace('compiled type $type');
							var body = compileExpressionToString(tfunc.expr);
							//trace('compiled body $type');
							'/*TFunction*/func($args)$type{
						$body
					}';
						} catch (ex) {
							var function_text = TypedExprTools.toString(tfunc.expr, true);
							trace("ex while compiling function", ex, function_text, tfunc);
							'/*ex comp func $ex $function_text $tfunc*/func(){} ';
						}
					}
				case TTypeExpr(tt):
					switch (tt) {
						case TClassDecl(c):
							'reflect.$c';
						case t: Std.string(t);
					}
				case TArrayDecl(el):
					var t = proper_name(expr.t);
					// var t=el.length>0?proper_name(el[0].t):"interface{}";
					'$t{' + el.map(v -> compileExpressionToString(v)).join(",") + '}';
				 
				case e: '/*' + Std.string(e) + '*/';
			}
		} catch (ex) {
			var type = expr.expr.getName();
			var as_text = TypedExprTools.toString(expr, true);
			return '/* failed to compile $type $as_text $ex ${ex.stack}*/';
		}
	}
	function fill_args(el:Array<TypedExpr>, expected_args_array:Array<{name:String, opt:Bool, t:Type}>) {
		
		var expected_args = expected_args_array.map(a -> proper_name(a.t));

		var i = 0;

		var args = el.map(a -> {
			var v = compileExpressionToString(a, false);
			var needed_type = expected_args[i++];
			var value_type = proper_name(a.t);
			return convert_to_needed_type(compileExpressionToString(a, false), needed_type, value_type);
		});

		var index=args.length;

		if (expected_args.length>args.length){
			for (i in index...expected_args.length){
				//todo this is not good, we need to get the actual default value
				expected_args_array[i].opt?args.push(convert_to_needed_type("nil",proper_name(expected_args_array[i].t),null)):"";
			}
		}
		return args;
	}
	
	function compileStringWithArgs(arg:TypedExprOrString, that:Null<TypedExpr>, el:Array<TypedExpr>) {
		var funcname = if (arg.isExpression()){
			var funcname=compileExpressionToString(arg.getExpression(), false);
			funcname=funcname.replace('\\"','"');
					funcname=funcname.replace('\\n','\n');
					funcname.substr(1).substr(0,-1);
		}		else {
			arg.getString() ?? "t_new";
		}	
					funcname=funcname.replace('{this}',compileExpressionToString(that));
					for (i in 0...el.length+1){
						funcname=funcname.replace('{$i}',compileExpressionToString(el[1+i]));
					}
					return funcname;
	}
	

	function gen_string(arr:Array<TypeParameter>) {
		return try if (arr!=null && arr.length>0){
			"["+arr.map(v->v.name).join(",")+"]";
		} else {
			"";
		}
	}

	function e2string_ar(e:TypedExpr):Array<String> {
		return switch e.expr{
			case TBinop(op, ie1, ie2):switch op {
				case OpAdd if (proper_name(ie1.t) == "string"):return [e2string_ar(ie1),e2string_ar(ie2)].flatten();
				case _:[compileExpressionToString(e)];
			}
			case _:[compileExpressionToString(e)];
		}
	}

	function compile_string_concat(e1:TypedExpr, e2:TypedExpr) {
		var parts=[e2string_ar(e1),e2string_ar(e2)].flatten();
		return 'fmt.Sprint(' + parts.join(",") + ')';

	}

	public function convert_to_needed_type(v, t_to, t_from) {
		if (t_to == "TypedDynamic") {
			return switch (t_from) {
				case "string": 'TypedDynamic_fromString($v)';
				case "int": 'TypedDynamic_fromInt($v)';
				case _: 'TypedDynamic_fromInterface($v)';
			}
		}
		/*
		if (t_from=="interface{}"){
			return v+'.($t_to)';
		}
		*/
		return switch ([v, t_to]) {
			case ["nil", "string"]: '""';
			case ["nil", "int"]: '0';
			case ["nil", "float64"]: '0';
			case [_, _]: v;
		}
	}


	/**
		This is used to configure what files are generated.
		Create an iterator to return the file data.

		NOTE: the `GenericCompiler` has fields containing the generated module types:
		```haxe
		var classes: Array<DataAndFileInfo<AST.Class>>;
		var enums: Array<DataAndFileInfo<AST.Enum>>;
		```
	**/
	public function generateOutputIterator():Iterator<DataAndFileInfo<StringOrBytes>> {
		var index = 0;
		return {
			hasNext: function() {
				return index < (classes.length + enums.length);
			},
			next: function() {
				return if (index < classes.length) {
					final cls = classes[index++];
					cls.withOutput(Generator.generateClass(cls.data));
				} else {
					final enm = enums[(index++) - classes.length];
					enm.withOutput(Generator.generateEnum(enm.data));
				}
			}
		}
	}
}
#end
