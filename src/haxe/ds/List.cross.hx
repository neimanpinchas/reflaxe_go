package haxe.ds;

@:forward
abstract List<T>(Array<T>){
    public function new() {
        this=new Array();
    }
    public function add(a:T) {
        return this.push(a);
    }
    public function first() {
        return this[0];
    }
    public function iterator(){
        return this.iterator();
    }
}