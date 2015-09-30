package samples.game;

import haxe.ds.StringMap;
import haxe.ds.IntMap;


class SparseGrid<T> {
    
    private var cells:StringMap<Array<T>>;
    private var columnWidth:Float;
    private var rowHeight:Float;
	

    public function new(columnWidth:Float, rowHeight:Float) {
        this.columnWidth = columnWidth;
        this.rowHeight = rowHeight;
        this.cells = new StringMap<Array<T>>();
    }

    public function insert(boundingBox : BoundingBox, value : T) {
        this.eachCell(boundingBox, function(old : Array<T>, x : Float, y : Float, key : String) {
            if(old == null) {
                old = [value];
                this.cells.set(key, old);
            } else if(old.indexOf(value) == -1) {
                old.push(value);
            }
        });
    }

    public function remove(boundingBox : BoundingBox, value : T) {
        this.eachCell(boundingBox, function(old : Array<T>, x : Float, y : Float, key : String) {
            if(old != null) {
                var i = old.indexOf(value);
                if(i != -1) {
                    if(old.length == 1) this.cells.remove(key);
                    else old.splice(i, 1);
                }
            }
        });
    }

    public function find(boundingBox : BoundingBox, getUniqueId : T -> Int) {
        var found = new IntMap<Bool>();
        var result = [];
        this.eachCell(boundingBox, function(old : Array<T>, x : Float, y : Float, key : String) {
            if(old != null) {
                for(i in 0 ... old.length) {
                    var value = old[i];
                    if(getUniqueId == null) {
                        result.push(value);
                    } else {
                        var k = getUniqueId(value);
                        if(!found.exists(k)) {
                            result.push(value);
                            found.set(k, true);
                        }
                    }
                }
            }
        });
        return result;
    }

    public function eachCell(boundingBox : BoundingBox, callback : Array<T> -> Float -> Float -> String -> Void) {
        var minX = Math.floor((boundingBox.x - boundingBox.halfWidth) / this.columnWidth);
        var maxX = Math.floor((boundingBox.x + boundingBox.halfWidth) / this.columnWidth);
        var minY = Math.floor((boundingBox.y - boundingBox.halfHeight) / this.rowHeight);
        var maxY = Math.floor((boundingBox.y + boundingBox.halfHeight) / this.rowHeight);
        for(x in minX ... maxX + 1) {
            for(y in minY ... maxY + 1) {
                var key = x + ',' + y;
                callback(this.cells.get(key), x, y, key);
            }
        }
    }
    
}
