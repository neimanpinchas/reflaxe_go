package tests;

function main() {
    var sum=0;
    for (i in 0...100){
        if (i%5==0){
            sum++;
        }
    }
    Sys.println(sum);
}
