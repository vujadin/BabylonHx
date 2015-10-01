package samples.game;

import js.html.CanvasRenderingContext2D;

class Actor {
    
    private static var resolution = 10;
    private static var epsilon = 0.1;
    private static var nextId = 1;
    public var boundingBox : BoundingBox;
    public var velocityX : Float;
    public var velocityY : Float;
    public var solid : Bool;
    public var id : Int;

    public function new(boundingBox : BoundingBox, velocityX = 0.0, velocityY = 0.0, solid = false) {
        this.boundingBox = boundingBox;
        this.velocityX = velocityX;
        this.velocityY = velocityY;
        this.solid = solid;
        this.id = nextId++;
    }

    public function setBoundingBox(boundingBox : BoundingBox) {
        this.boundingBox = boundingBox;
    }

    public function setVelocity(velocityX, velocityY) {
        this.velocityX = velocityX;
        this.velocityY = velocityY;
    }

    public function draw(context : CanvasRenderingContext2D) {
        var box = this.boundingBox;
        // TODO: Better culling (but the culling is very important - this function vastly dominates CPU usage without it)
        if(box.x + box.halfWidth > 0 && box.x - box.halfWidth < 1024 && box.y + box.halfHeight > 0 && box.y - box.halfHeight < 768) {
            if(this.solid) context.strokeStyle = '#505050';
            else context.strokeStyle = '#a00000';
            context.strokeRect(box.x - box.halfWidth, box.y - box.halfHeight, box.halfWidth * 2, box.halfHeight * 2);
        }
    }

    public function move(grid : SparseGrid<Actor>, deltaTime : Float) {
        if(this.velocityX != 0 || this.velocityY != 0) {
            var deltaX = this.velocityX * deltaTime;
            var deltaY = this.velocityY * deltaTime;
            var xActors : Array<Actor> = [];
            var yActors : Array<Actor> = [];
            if(deltaX != 0) { 
                var xBox = this.boundingBox.extendedBy(deltaX, 0);
                xActors = grid.find(xBox, Actor.getUniqueId);
                xActors.sort(deltaX < 0.0 ? collisionOrderLeft : collisionOrderRight);
            }
            if(deltaY != 0) {
                var yBox = this.boundingBox.extendedBy(0, deltaY);
                yActors = grid.find(yBox, Actor.getUniqueId);
                yActors.sort(deltaY < 0.0 ? collisionOrderUp : collisionOrderDown);
            }
            var moved = false;
            while(deltaX != 0 || deltaY != 0) {
                var stepX = deltaX;
                var stepY = deltaY;
                if(deltaTime < 1.0 && Math.max(Math.abs(stepX), Math.abs(stepY)) > resolution) {
                    var factor = resolution / Math.max(Math.abs(stepX), Math.abs(stepY));
                    stepX *= factor;
                    stepY *= factor;
                    //console.log("factor: " + factor + ", x: " + stepX + ", y: " + stepY);
                }
                
                if(stepX != 0) {
                    var newX = this.moveX(xActors, stepX);
                    if(newX != this.boundingBox.x) {
                        if(!moved) grid.remove(this.boundingBox, this);
                        this.boundingBox.x = newX;
                        moved = true;
                    }
                }
                
                if(stepY != 0) {
                    var newY = this.moveY(yActors, stepY);
                    if(newY != this.boundingBox.y) {
                        if(!moved) grid.remove(this.boundingBox, this);
                        this.boundingBox.y = newY;
                        moved = true;
                    }
                }
                
                deltaX -= stepX;
                deltaY -= stepY;
            }
            if(moved && this.solid) grid.insert(this.boundingBox, this);
        }
    }

    function moveX(actors : Array<Actor>, delta : Float) {
        if(delta == 0) return this.boundingBox.x;
        var box = this.boundingBox.extendedBy(delta, 0);
        var half = this.boundingBox.halfWidth;
        var result = this.boundingBox.x + delta;
        for(i in 0 ... actors.length) {
            var that = actors[i];
            if(this != that && box.intersects(that.boundingBox)) {
                var thatBox = that.boundingBox;
                if(delta > 0 && thatBox.x - thatBox.halfWidth < result + half) {
                    result = thatBox.x - thatBox.halfWidth - half - epsilon;
                } else if(delta < 0 && thatBox.x + thatBox.halfWidth > result - half) {
                    result = thatBox.x + thatBox.halfWidth + half + epsilon;
                }
                var velocity = this.velocityX;
                this.velocityX = 0;
                var done = this.onCollision(that, -velocity, null, result, this.boundingBox.y);
                that.onCollisionBy(this, velocity, null);
                if(done) return result;
            }
        }
        return result;
    }

    function moveY(actors : Array<Actor>, delta : Float) {
        if(delta == 0) return this.boundingBox.y;
        var box = this.boundingBox.extendedBy(0, delta);
        var half = this.boundingBox.halfHeight;
        var result = this.boundingBox.y + delta;
        for(i in 0 ... actors.length) {
            var that = actors[i];
            if(this != that && box.intersects(that.boundingBox)) {
                var thatBox = that.boundingBox;
                if(delta > 0 && thatBox.y - thatBox.halfHeight < result + half) {
                    result = thatBox.y - thatBox.halfHeight - half - epsilon;
                } else if(delta < 0 && thatBox.y + thatBox.halfHeight > result - half) {
                    result = thatBox.y + thatBox.halfHeight + half + epsilon;
                }
                var velocity = this.velocityY;
                this.velocityY = 0;
                var done = this.onCollision(that, null, -velocity, this.boundingBox.x, result);
                that.onCollisionBy(this, null, velocity);
                if(done) return result;
            }
        }
        return result;
    }

    public function onTick(deltaTime : Float) {}
    public function onCollision(that : Actor, bounceVelocityX : Float, bounceVelocityY : Float, bounceX : Float, bounceY : Float) : Bool { return true;  }
    public function onCollisionBy(that : Actor, incomingVelocityX : Float, incomingVelocityY : Float) : Void { }

    function collisionOrderLeft(a : Actor, b : Actor) : Int {
        var x = this.boundingBox.x - this.boundingBox.halfWidth;
        var r = Math.abs((a.boundingBox.x + a.boundingBox.halfWidth) - x) - Math.abs((b.boundingBox.x + b.boundingBox.halfWidth) - x);
        return r < 0 ? -1 : r > 0 ? 1 : 0;
    }
    function collisionOrderRight(a : Actor, b : Actor) : Int {
        var x = this.boundingBox.x + this.boundingBox.halfWidth;
        var r = Math.abs((a.boundingBox.x - a.boundingBox.halfWidth) - x) - Math.abs((b.boundingBox.x - b.boundingBox.halfWidth) - x);
        return r < 0 ? -1 : r > 0 ? 1 : 0;
    }
    function collisionOrderUp(a : Actor, b : Actor) : Int {
        var y = this.boundingBox.y - this.boundingBox.halfHeight;
        var r = Math.abs((a.boundingBox.y + a.boundingBox.halfHeight) - y) - Math.abs((b.boundingBox.y + b.boundingBox.halfHeight) - y);
        return r < 0 ? -1 : r > 0 ? 1 : 0;
    }
    function collisionOrderDown(a : Actor, b : Actor) : Int {
        var y = this.boundingBox.y + this.boundingBox.halfHeight;
        var r = Math.abs((a.boundingBox.y - a.boundingBox.halfHeight) - y) - Math.abs((b.boundingBox.y - b.boundingBox.halfHeight) - y);
        return r < 0 ? -1 : r > 0 ? 1 : 0;
    }

    static function getUniqueId(actor) { return actor.id; };
    
}
