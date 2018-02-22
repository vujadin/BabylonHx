package com.babylonhx.extensions.steering;

import com.babylonhx.mesh.AbstractMesh;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Entity {
	
	public var mesh:AbstractMesh;
	public var mass:Float = 1;
	public var maxSpeed:Float = 10;

	public function new() {
		
	}
	
}



Entity = function (mesh) {

    THREE.Group.apply(this);

    this.mesh = mesh;
    this.mass = 1;
    this.maxSpeed = 10;

    this.position = new THREE.Vector3(0, 0, 0);
    this.velocity = new THREE.Vector3(0, 0, 0);

    this.box = new THREE.Box3().setFromObject(mesh);
    this.raycaster = new THREE.Raycaster();

    this.velocitySamples = []
    this.numSamplesForSmoothing = 20

    Object.defineProperty(Entity.prototype, 'width', {
        enumerable: true,
        configurable: true,
        get: function () {
            return (this.box.max.x - this.box.min.x)
        }

    });

    Object.defineProperty(Entity.prototype, 'height', {
        enumerable: true,
        configurable: true,
        get: function () {
            return (this.box.max.y - this.box.min.y)
        }

    });

    Object.defineProperty(Entity.prototype, 'depth', {
        enumerable: true,
        configurable: true,
        get: function () {
            return (this.box.max.z - this.box.min.z)
        }

    });

    Object.defineProperty(Entity.prototype, 'forward', {
        enumerable: true,
        configurable: true,
        get: function () {
            return new THREE.Vector3(0, 0, -1).applyQuaternion(this.quaternion).negate()
        }

    });

    Object.defineProperty(Entity.prototype, 'backward', {
        enumerable: true,
        configurable: true,
        get: function () {
            return this.forward.clone().negate()
        }

    });

    Object.defineProperty(Entity.prototype, 'left', {
        enumerable: true,
        configurable: true,
        get: function () {
            return this.forward.clone().applyAxisAngle(new THREE.Vector3(0, 1, 0), Math.PI * .5)
        }

    });

    Object.defineProperty(Entity.prototype, 'right', {
        enumerable: true,
        configurable: true,
        get: function () {
            return this.left.clone().negate()
        }

    });

    this.add(this.mesh)

    this.radius = 200 //temp

}

Entity.prototype = Object.assign(Object.create(THREE.Group.prototype), {
    constructor: Entity,

    update: function () {
        this.velocity.clampLength(0, this.maxSpeed)
        this.velocity.setY(0);
        this.position.add(this.velocity)
    },


    bounce: function (box) {

        if (this.position.x > box.max.x) {
            this.position.setX(box.max.x);
            this.velocity.angle = this.velocity.angle + .1
        }

        if (this.position.x < box.min.x) {
            this.position.setX(box.min.x);
            this.velocity.angle = this.velocity.angle + .1
        }

        if (this.position.z > box.max.z) {
            this.position.setZ(box.max.z);
            this.velocity.angle = this.velocity.angle + .1
        }
        if (this.position.z < box.min.z) {
            this.position.setZ(box.min.z);
            this.velocity.angle = this.velocity.angle + .1
        }

        if (this.position.y > box.max.y) {
            this.position.setY(box.max.y);
        }

        if (this.position.y < box.min.y) {
            this.position.setY(-box.min.y);
        }
    },

    wrap: function (box) {
        if (this.position.x > box.max.x) {
            this.position.setX(box.min.x + 1);
        }

        else if (this.position.x < box.min.x) {
            this.position.setX(box.max.x - 1);
        }

        if (this.position.z > box.max.z) {
            this.position.setZ(box.min.z + 1);

        }
        else if (this.position.z < box.min.z) {
            this.position.setZ(box.max.z - 1);
        }

        if (this.position.y > box.max.y) {
            this.position.setY(box.min.y + 1);
        }

        else if (this.position.y < box.min.y) {
            this.position.setY(box.max.y + 1);
        }
    },


    lookWhereGoing: function (smoothing) {
        var direction = this.position.clone().add(this.velocity).setY(this.position.y)
        if (smoothing) {
            if (this.velocitySamples.length == this.numSamplesForSmoothing) {
                this.velocitySamples.shift();
            }

            this.velocitySamples.push(this.velocity.clone().setY(this.position.y));
            direction.set(0, 0, 0);
            for (var v = 0; v < this.velocitySamples.length; v++) {
                direction.add(this.velocitySamples[v])
            }
            direction.divideScalar(this.velocitySamples.length)
            direction = this.position.clone().add(direction).setY(this.position.y)
        }
        this.lookAt(direction)
    }
});

SteeringEntity = function (mesh) {

    Entity.call(this, mesh);

    this.maxForce = 5;
    this.arrivalThreshold = 400;

    this.wanderAngle = 0
    this.wanderDistance = 10;
    this.wanderRadius = 5;
    this.wanderRange = 1;

    this.avoidDistance = 400
    this.avoidBuffer = 20; //NOT USED

    this.inSightDistance = 200
    this.tooCloseDistance = 60

    this.pathIndex = 0

    this.steeringForce = new THREE.Vector3(0, 0, 0);
}

SteeringEntity.prototype = Object.assign(Object.create(Entity.prototype), {

    constructor: SteeringEntity,

    seek: function (position) {
        var desiredVelocity = position.clone().sub(this.position);
        desiredVelocity.normalize().setLength(this.maxSpeed).sub(this.velocity);
        this.steeringForce.add(desiredVelocity);
    },

    flee: function (position) {
        var desiredVelocity = position.clone().sub(this.position);
        desiredVelocity.normalize().setLength(this.maxSpeed).sub(this.velocity);
        this.steeringForce.sub(desiredVelocity);
    },

    arrive: function (position) {
        var desiredVelocity = position.clone().sub(this.position);
        desiredVelocity.normalize()
        var distance = this.position.distanceTo(position)
        if (distance > this.arrivalThreshold)
            desiredVelocity.setLength(this.maxSpeed);
        else
            desiredVelocity.setLength(this.maxSpeed * distance / this.arrivalThreshold)
        desiredVelocity.sub(this.velocity);
        this.steeringForce.add(desiredVelocity);
    },

    pursue: function (target) {
        var lookAheadTime = this.position.distanceTo(target.position) / this.maxSpeed;
        var predictedTarget = target.position.clone().add(target.velocity.clone().setLength(lookAheadTime));
        this.seek(predictedTarget);
    },

    evade: function (target) {
        var lookAheadTime = this.position.distanceTo(target.position) / this.maxSpeed;
        var predictedTarget = target.position.clone().sub(target.velocity.clone().setLength(lookAheadTime));
        this.flee(predictedTarget);
    },

    idle: function () {
        this.velocity.setLength(0)
        this.steeringForce.set(0, 0, 0);
    },


    wander: function () {
        var center = this.velocity.clone().normalize().setLength(this.wanderDistance);
        var offset = new THREE.Vector3(1, 1, 1);
        offset.setLength(this.wanderRadius);
        offset.x = Math.sin(this.wanderAngle) * offset.length()
        offset.z = Math.cos(this.wanderAngle) * offset.length()
        offset.y = Math.sin(this.wanderAngle) * offset.length()

        this.wanderAngle += Math.random() * this.wanderRange - this.wanderRange * .5;
        center.add(offset)
        center.setY(0)
        this.steeringForce.add(center);
    },

    interpose: function (targetA, targetB) {
        var midPoint = targetA.position.clone().add(targetB.position.clone()).divideScalar(2);
        var timeToMidPoint = this.position.distanceTo(midPoint) / this.maxSpeed;
        var pointA = targetA.position.clone().add(targetA.velocity.clone().multiplyScalar(timeToMidPoint))
        var pointB = targetB.position.clone().add(targetB.velocity.clone().multiplyScalar(timeToMidPoint))
        midPoint = pointA.add(pointB).divideScalar(2);
        this.seek(midPoint)
    },


    separation: function (entities, separationRadius = 300, maxSeparation = 100) {
        var force = new THREE.Vector3(0, 0, 0);
        var neighborCount = 0

        for (var i = 0; i < entities.length; i++) {
            if (entities[i] != this && entities[i].position.distanceTo(this.position) <= separationRadius) {
                force.add(entities[i].position.clone().sub(this.position));
                neighborCount++;
            }
        }
        if (neighborCount != 0) {
            force.divideScalar(neighborCount)
            force.negate();
        }
        force.normalize();
        force.multiplyScalar(maxSeparation);
        this.steeringForce.add(force);
    },

    isOnLeaderSight: function (leader, ahead, leaderSightRadius) {
        return (ahead.distanceTo(this.position) <= leaderSightRadius || leader.position.distanceTo(this.position) <= leaderSightRadius)
    },

    followLeader: function (leader, entities, distance = 400, separationRadius = 300, maxSeparation = 100, leaderSightRadius = 1600, arrivalThreshold = 200) {
        var tv = leader.velocity.clone();
        tv.normalize().multiplyScalar(distance)
        var ahead = leader.position.clone().add(tv)
        tv.negate()
        var behind = leader.position.clone().add(tv)

        if (this.isOnLeaderSight(leader, ahead, leaderSightRadius)) {
            this.evade(leader);
        }
        this.arrivalThreshold = arrivalThreshold;
        this.arrive(behind);
        this.separation(entities, separationRadius, maxSeparation);

    },

    getNeighborAhead: function (entities) {
        var maxQueueAhead = 500;
        var maxQueueRadius = 500;
        var res;
        var qa = this.velocity.clone().normalize().multiplyScalar(maxQueueAhead);
        var ahead = this.position.clone().add(qa);

        for (var i = 0; i < entities.length; i++) {
            var distance = ahead.distanceTo(entities[i].position);
            if (entities[i] != this && distance <= maxQueueRadius) {
                res = entities[i]
                break;
            }
        }
        return res;
    },

    queue: function (entities, maxQueueRadius = 500) {

        var neighbor = this.getNeighborAhead(entities);
        var brake = new THREE.Vector3(0, 0, 0)
        var v = this.velocity.clone()
        if (neighbor != null) {
            brake = this.steeringForce.clone().negate().multiplyScalar(0.8);
            v.negate().normalize();
            brake.add(v)
            if (this.position.distanceTo(neighbor.position) <= maxQueueRadius) {
                this.velocity.multiplyScalar(0.3)
            }
        }

        this.steeringForce.add(brake);
    },

    inSight: function (entity) {
        if (this.position.distanceTo(entity.position) > this.inSightDistance)
            return false;
        var heading = this.velocity.clone().normalize();
        var difference = entity.position.clone().sub(this.position);
        var dot = difference.dot(heading)
        if (dot < 0)
            return false;
        return true;

    },


    flock: function (entities) {
        var averageVelocity = this.velocity.clone();
        var averagePosition = new THREE.Vector3(0, 0, 0);
        var inSightCount = 0;
        for (var i = 0; i < entities.length; i++) {
            if (entities[i] != this && this.inSight(entities[i])) {
                averageVelocity.add(entities[i].velocity)
                averagePosition.add(entities[i].position)
                if (this.position.distanceTo(entities[i].position) < this.tooCloseDistance) {
                    this.flee(entities[i].position)
                }
                inSightCount++;
            }
        }
        if (inSightCount > 0) {
            averageVelocity.divideScalar(inSightCount);
            averagePosition.divideScalar(inSightCount);
            this.seek(averagePosition);
            this.steeringForce.add(averageVelocity.sub(this.velocity))
        }
    },

    followPath: function (path, loop, thresholdRadius = 1) {
        var wayPoint = path[this.pathIndex]
        if (wayPoint == null)
            return;
        if (this.position.distanceTo(wayPoint) < thresholdRadius) {
            if (this.pathIndex >= path.length - 1) {
                if (loop)
                    this.pathIndex = 0;
            }
            else {
                this.pathIndex++
            }
        }
        if (this.pathIndex >= path.length - 1 && !loop)
            this.arrive(wayPoint)
        else
            this.seek(wayPoint)

    },


    avoid: function (obstacles) {
        var dynamic_length = this.velocity.length() / this.maxSpeed;
        var ahead = this.position.clone().add(this.velocity.clone().normalize().multiplyScalar(dynamic_length))
        var ahead2 = this.position.clone().add(this.velocity.clone().normalize().multiplyScalar(this.avoidDistance * .5));
        //get most threatening
        var mostThreatening = null;
        for (var i = 0; i < obstacles.length; i++)
        {
            if (obstacles[i] === this)
                continue;
            var collision = obstacles[i].position.distanceTo(ahead) <= obstacles[i].radius || obstacles[i].position.distanceTo(ahead2) <= obstacles[i].radius
            if (collision && (mostThreatening == null || this.position.distanceTo(obstacles[i].position) < this.position.distanceTo(mostThreatening.position))) {
                mostThreatening = obstacles[i];
            }
        }
        //end
        var avoidance = new THREE.Vector3(0, 0, 0)
        if (mostThreatening != null) {
            avoidance = ahead.clone().sub(mostThreatening.position).normalize().multiplyScalar(100)
        }
        this.steeringForce.add(avoidance);
    },

    update: function () {
        this.steeringForce.clampLength(0, this.maxForce);
        this.steeringForce.divideScalar(this.mass);
        this.velocity.add(this.steeringForce);
        this.steeringForce.set(0, 0, 0);
        Entity.prototype.update.call(this);
    }
});


/**
 * Returns a random number between min (inclusive) and max (exclusive)
 */
Math.getRandomArbitrary = function (min, max) {
    return Math.random() * (max - min) + min;
}

/**
 * Returns a random integer between min (inclusive) and max (inclusive)
 * Using Math.round() will give you a non-uniform distribution!
 */
Math.getRandomInt = function (min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

THREE.Vector3.prototype.perp = function () {
    return new THREE.Vector3(-this.z, 0, this.x)
}

THREE.Vector3.prototype.sign = function (vector) {
    return this.perp().dot(vector) < 0 ? -1 : 1
}


Object.defineProperty(THREE.Vector3.prototype, 'angle', {
    enumerable: true,
    configurable: true,
    get: function () {
        return Math.atan2(this.z, this.x)
    },

    set: function (value) {
        this.x = Math.cos(value) * this.length()
        this.z = Math.sin(value) * this.length()
    }

});
