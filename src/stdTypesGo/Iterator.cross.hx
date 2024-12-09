package stdTypesGo;

interface Iterator<T> {
    public function hasNext():Bool;
    public function next():T;
}
