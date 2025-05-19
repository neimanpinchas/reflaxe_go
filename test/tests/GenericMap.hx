package tests;

function main() {
    var m=new Map<String,Tuple2<String,String>>();
    m["abc"]=new Tuple2("def","ghi");
    trace(m.get("abc").b=="ghi");
}
