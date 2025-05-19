function main() {
    var a:Dynamic={};
    Reflect.setField(a,"aaa",1);
    var g=Reflect.field(a,"aaa");
    trace(g);
}