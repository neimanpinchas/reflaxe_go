package sys.thread;

@:coreApi
abstract Deque<T>(Chan<T>) {
    public function new() {
        this=new Deque();
    }
    public function add(v:T){
       this.send(v);
    }
}