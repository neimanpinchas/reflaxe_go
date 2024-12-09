package gocompiler;

import haxe.macro.Type;

class Util {
	public static function anon_name(fields) {
		return fields.map(f -> {
			return if (f.name.length <= 4) {
				f.name;
			} else {
				~/[aeiou]/g.replace(f.name, "");
			}
		}).join("_");
	}

	public static function is_multi_return(type:Type):Array<String> {
		return switch type {
			case TInst(t, params):
				switch (t.get()) {
					case {meta: meta, fields: fields} if (meta.has(":multiReturn")): fields.get().map(v -> v.name);

					case _: [];
				}
			case _: [];
		}
	}

    public static var reserved=["map","type","out"];
    public static function fix_reserved(v) {
        if (reserved.contains(v)){
            return "_"+v;
        } else {
            return v;
        }
    }
}
