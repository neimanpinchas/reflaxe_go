package;

import gostd.Ptr;

class EReg {
    public var re:Ptr<gostd.Regex>;
    public var matches:Array<Array<String>>;
    //todo mode
    public function new(pat:String,mode:String) {
        re=gostd.Regex.RegexPkg.MustCompile(pat);
    }
    public function match(text) {
        matches=re.deref().FindAllStringSubmatch(text,-1);
        return matches.length>0;
    }
    public function matched(n) {
        if (matches[0].length<=n){
            throw "EReg:matched no match with this number";
        }
        return matches[0][n];
    }
    public function split(text){
        return re.deref().Split(text,-1);
    }
}