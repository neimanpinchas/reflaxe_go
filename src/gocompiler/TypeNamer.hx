package gocompiler;
import reflaxe.output.DataAndFileInfo;
import haxe.macro.Expr.TypeParam;
import gocompiler.Types.UsePointer;
import gocompiler.Util.anon_name;
import haxe.macro.Type;
using StringTools;
class TypeNamer {
	public static var pkg:String;
	public static var classes=new Array();
    public static var current:BaseType=null;
    
	public static var anon_types = new Map<String, Bool>();


public static function proper_name(type:Type, use_pointer:UsePointer = Neutral, generic_params:Array<TypeParameter>=null):String {
    try {
        return switch type {
            case TInst(t, params): {
                    // t.get().name;

                    return switch (t.get()) {
                        // case {meta:m} if (m!=null && m.has(":nonptr")): try proper_name(params[0],Never);
                        case {meta: m} if (use_pointer != Never && m != null && m.has(":valueType")): try proper_name(type, Never);

                        // generics
                        case {name: n, kind:KTypeParameter(constraints)} if (n.length < 3 && n.startsWith("T")): n+'/*$constraints*/';
                        case {name: n, kind:KTypeParameter(constraints)} : n+'/*$constraints*/';
                        case {name: "Bool"}: "bool";
                        case {name: "Void"}: "";
                        case {name: "Int"}: "int";
                        case {name: "Float"}: "float64";
                        case {name: "String"}: "string";
                        case {name: "Exception"}: "error";
                        case {name: "Null", params: p}: "/*?*/" + proper_name(params[0], use_pointer); // todo maybe just return nil bool
                        case {name: "Ptr", params: p}: "*" + proper_name(params[0], use_pointer); // todo maybe just return nil bool
                        case {name: "Chan", params: p}: "chan " + proper_name(params[0]);
                        case {name: "NonPtr", params: p}: proper_name(params[0], Never);
                        case {name: "IMap", params: p}: 'map[${proper_name(p[0].t, Never)}]${proper_name(p[1].t, Never)}';
                        case {name: "map[string]", params: p}: 'map[string]${proper_name(params[0])}';
                        case {name: "Array", params: p}: {
                            var gentype=proper_name(params[0]);
                            //if (gentype=="T"){
                            //    gentype="interface{}";
                            //}
                            "[]"+gentype;
                        }
                        // case _:"/* tinst */"+Std.string(t.get());
                        case _: {
                                if (use_pointer == Never) {
                                    trace(type, t, params);
                                }
                                var ptr = switch ([t.get().isExtern || t.get().isInterface, use_pointer]) {
                                    case [_, Force]: "*";
                                    case [_, Never]: "";
                                    case [true, Neutral]: "";
                                    case [false, Neutral]: "*";
                                };
                                var name = t.get().name.replace("_dot_", ".");
                                var generics = if (generic_params != null && generic_params.length > 0) {
                                    '[' + generic_params.map(v -> proper_name(v.t)).join(",") + ']/*generic*/';
                                } else {
                                    t.get()
                                        .params.length > 0 ? '[/*gen */' + params.map(type_param_to_string).join(",") + "]" : "";
                                        //.params.length > 0 ? '[/*gen ${t.get()} ${params}  ${generic_params}*/' + params.map(type_param_to_string).join(",") + "]" : "";
                                };
                                ptr + name + generics + '/* tinst */';
                            }
                    }
                };
            case TAnonymous(a): {
                var generics=new Map<String,Bool>();
                    var out=new AST.Class();
                    var f = a.get().fields.map(f -> {
                        out.vars.push({n:Util.fix_reserved(f.name),t:proper_name(f.type),i:null});
                        if (f.params.length>1){

                        }
                        
                    }).join("\n");
                    var has_non_func=a.get().fields.filter(v->switch(v.type){
                        case TFun(args, ret):false;
                        case _:true;
                    });
                    var name = anon_name(a.get().fields);
                    out.class_name=name;
            //         var text = if (has_non_func.length>0) '
            //         package $pkg
            // type $name struct {
            //     $f
            // }
            // ' else '
            // package $pkg
            // type $name interface {
            //     ${f.replace("func","")}
            // }
            // ';
                    if (name.length>0 && !anon_types.exists(name)) {
                        if (current==null){
                            throw "current is null";
                        }
                        if (current.module==null){
                            current.module="typedef";
                        }
                        classes.push(new DataAndFileInfo(out, current, name, null));
                        // code_injections[name]=text;
                        anon_types[name] = true;
                    }
                    // todo maybe handle use pointer global on all types
                    (switch use_pointer {
                        case Force:"*";
                        case Never:"";
                        case Neutral:has_non_func.length>0?"*":"";
                    }) + name;
                };
            // case TDynamic(d):(if(use_pointer!=Never) "*"; else "")+"TypedDynamic";
            case TDynamic(d): (if (use_pointer == UsePointer.Force) "*"; else "") + "interface{}";
            case TAbstract(ta, params): switch ta.get() {
                    case {name: n} if (n.length < 3 && n.startsWith("T")): n;
                    case {name: "Int"}: "int";
                    case {name: "Int64"}: "int64";
                    case {name: "Float"}: "float64";
                    case {name: "Void"}: "";
                    case {name: "Bool"}: "bool";
                    case {name: "String"}: "string";
                    case {name: "Map"}: 'map[${proper_name(params[0], use_pointer)}]${proper_name(params[1], use_pointer)}';
                    case {name: "Null", params: p}: proper_name(params[0], use_pointer); // todo maybe just return nil bool

                    case {name: something}: {
                        if (ta.get().type.getName()==type.getName()){
                            return "interface{}/*recursive*/";
                        }
                        proper_name(ta.get().type,use_pointer) +'/*$something ${params[0]} abst?*/'; // +Std.string(ta.get())+"*/";
                    }
                };
            case TType(t, params): proper_name(t.get().type, use_pointer);
            case TEnum(t, params): t.get().name; // todo this will not work with ADT
            case TFun(args, ret): {
                    var a = args.map(v -> '${proper_name(v.t)} ${v.opt ? '/*opt*/' : ''}').join(",");
                    '/*tntf*/func($a)' + proper_name(ret);
                }
            case TMono(t):'/* TMono ${t.get()}*/interface{}';
            case TLazy(f):proper_name(f(),use_pointer,generic_params);
            case _: "/*type?*/" + type.getName();
        }
    } catch (ex) {
        return 'interface{}/*ErrorFindingType $ex */';
    }
}

}

function ptr_by_name(n:String) {
    switch (n){
        case "error","string":{
            return "";
        }
        case _:
    }
    if (n.startsWith("T")){
        return "";
    } else {
        return "*";
    }
}

function type_param_to_string(tin:haxe.macro.Type) {
    return switch tin{
        case TInst(tinn, params):
            var n=tinn.toString().split(".");
            //remove all path in generic parameters
            var name=n[n.length-1];
            var ptr=ptr_by_name(name);
            return ptr+name;
        case _:"N";
    }
}