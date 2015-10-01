package samples.game;


class BoundingBox {
    
    public var x:Float;
    public var y:Float;
    public var halfWidth:Float;
    public var halfHeight:Float;

    public function new(x:Float, y:Float, width:Float, height:Float) {
        this.x = x;
        this.y = y;
        this.halfWidth = width / 2.0;
        this.halfHeight = height / 2.0;
    }

    public function intersects(that:BoundingBox) {
        return (
            Math.abs(this.x - that.x) < (this.halfWidth + that.halfWidth) &&
            Math.abs(this.y - that.y) < (this.halfHeight + that.halfHeight)
        );
    }

    public function extendedBy(x:Float, y:Float) {
        return new BoundingBox(
            this.x + x / 2.0,
            this.y + y / 2.0,
            this.halfWidth * 2.0 + Math.abs(x),
            this.halfHeight * 2.0 + Math.abs(y)
        );
    }
	
}
