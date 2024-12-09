package gostd;
import go.Syntax;

class GoArray<T> {
    public function length() {
        return Syntax.code("len()");
    }
    public function at(i:Int) {
        return Syntax.code("len({0})",this);
    }
    public function slice(a,b) {
        return Syntax.code("len({0})",this);
    }
}