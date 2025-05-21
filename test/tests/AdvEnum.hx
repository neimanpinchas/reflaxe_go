package tests;


enum TestEnum {
    One(a:Int);
    Two(a:Float);
    Three(a:String);
}

function main() {
    var a=One(1);
    var b=switch a {
        case One(a):1;
        case Two(a):Std.int(2);
        case a:{
            trace(a);
            0;
        }
    }
    trace(b);
}