package haxe.ds;

import haxe.macro.Context;

class Macro {
    static public function build() {
      switch (Context.getLocalType()) {
        case TInst(_, [t1]):
          trace(t1);
        case t:
          Context.error("Class expected", Context.currentPos());
      }
      return null;
    }
  }