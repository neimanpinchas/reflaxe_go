enum TestEnum {
    One;
    Two;
    Three;
}

function main() {
    var a=One;
    var b=switch a {
        case One:1;
        case Two:2;
        case a:{
            trace(a);
            0;
        }
    }
    trace(b);
}