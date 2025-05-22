package tests;
using Lambda;
function main() {
    
var aaa=({iterator:()->0...100}).array();
trace(aaa.map(v->v*2));
trace(aaa.map(v->2/v));
}