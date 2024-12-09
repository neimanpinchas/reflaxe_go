package gostd;

enum abstract SliceType(Int) {
    public var FromTo=0;
    public var FromOnly=1;
    public var ToOnly=2;
    public var Copy=3;
}