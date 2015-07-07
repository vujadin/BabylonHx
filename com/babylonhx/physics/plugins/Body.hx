package com.babylonhx.physics.plugins;

import oimohx.math.Mat33;
import oimohx.math.Quat;
import oimohx.math.Vec3;
import oimohx.physics.collision.shape.BoxShape;
import oimohx.physics.collision.shape.Shape;
import oimohx.physics.collision.shape.ShapeConfig;
import oimohx.physics.collision.shape.SphereShape;
import oimohx.physics.dynamics.RigidBody;
import oimohx.physics.dynamics.World;


/**
 * ...
 * @author Krtolica Vujadin
 */
class Body {
	
	public var body:RigidBody;
	public var parent:World;
	public var name:String;
	public var sleeping:Bool;

	public function new(Obj:Dynamic) {
		var obj:Dynamic = Obj != null ? Obj : {};
		
		if (obj.world == null) {
			return;
		}
		
		// the world where i am
		this.parent = obj.world;
		
		// Yep my name 
		this.name = obj.name != null ? obj.name : '';
		
		// I'm dynamique or not
		var move:Bool = obj.move != null ? cast obj.move : false;
		
		// I can sleep or not
		var noSleep:Bool = obj.noSleep != null ? cast obj.noSleep : false;
				
		// My start position
		var p:Array<Float> = obj.pos != null ? cast obj.pos : [0, 0, 0];
		p[0] *= World.INV_SCALE;
		p[1] *= World.INV_SCALE;
		p[2] *= World.INV_SCALE;
		
		// My size 
		var s:Array<Float> = obj.size != null ? cast obj.size : [1, 1, 1];
		s[0] *= World.INV_SCALE;
		s[1] *= World.INV_SCALE;
		s[2] *= World.INV_SCALE;
		
		// My rotation in degre
		var rot:Array<Float> = obj.rot != null ? cast obj.rot : [0, 0, 0];
				
		var r:Array<Float> = [];
		var tmp = EulerToAxis(rot[0], rot[1], rot[2]);
		r.push(tmp[0]);  
		r.push(tmp[1]); 
		r.push(tmp[2]); 
		r.push(tmp[3]);
		
		// My physics setting
		var sc:ShapeConfig = obj.sc != null ? cast obj.sc : new ShapeConfig();
		
		if(obj.config != null){
			// The density of the shape.
			sc.density = obj.config[0] != null ? obj.config[0] : 1;
			// The coefficient of friction of the shape.
			sc.friction = obj.config[1] != null ? obj.config[1] : 0.4;
			// The coefficient of restitution of the shape.
			sc.restitution = obj.config[2] != null ? obj.config[2] : 0.2;
			// The bits of the collision groups to which the shape belongs.
			sc.belongsTo = obj.config[3] != null ? obj.config[3] : 1;
			// The bits of the collision groups with which the shape collides.
			sc.collidesWith = obj.config[4] != null ? obj.config[4] : 0xffffffff;
		}
		
		if(obj.massPos != null){
			obj.massPos = obj.massPos.map(function(x) { return x * World.INV_SCALE; });
			sc.relativePosition.init(obj.massPos[0], obj.massPos[1], obj.massPos[2]);
		}
		
		if(obj.massRot != null){
			obj.massRot = obj.massRot.map(function(x) { return x * World.TO_RAD; });
			sc.relativeRotation = EulerToMatrix(obj.massRot[0], obj.massRot[1], obj.massRot[2]);
		}
		
		// My rigidbody		
		this.body = new RigidBody(p[0], p[1], p[2], r[0], r[1], r[2], r[3]);
		
		// My shapes
		var shape:Shape = null;
		var _type = obj.type != null ? obj.type : "box";
		
		switch(_type) {
			case "sphere": 
				shape = new SphereShape(sc, s[0]);
				
			case "cylinder": 
				shape = new BoxShape(sc, s[0], s[1], s[2]); // fake cylinder
				
			case "box": 
				shape = new BoxShape(sc, s[0], s[1], s[2]); 
				
		}
		this.body.addShape(shape);
		
		// I'm static or i move
		if(move){
			if (obj.massPos != null || obj.massRot != null) {
				this.body.setupMass(0x1, false);
			}
			else {
				this.body.setupMass(0x1, true);
			}
			if (noSleep) {
				this.body.allowSleep = false;
			}
			else {
				this.body.allowSleep = true;
			}
		} 
		else {
			this.body.setupMass(0x2, false);
		}
		
		this.body.name = this.name;
		this.sleeping = this.body.sleeping;
		
		// finaly add to physics world
		this.parent.addRigidBody(this.body);
	}
	
	public function setPosition(x:Float, y:Float, z:Float) {
        this.body.setPosition(new Vec3(x, y, z));
    }
	
	public function setRotation(rot:Vec3) {
        this.body.setRotation(rot);
    }
		
    // GET
    public function getPosition():Vec3 {
        return this.body.position;
    }
		
    public function getSleep():Bool {
        return this.body.sleeping;
    }
	
    // RESET
    public function resetPosition(x:Float, y:Float, z:Float) {
        this.body.resetPosition(x, y, z);
    }
	
    // force wakeup
    public function awake() {
        this.body.awake();
    }
	
    // remove rigidbody
    public function remove() {
        this.parent.removeRigidBody(this.body);
    }
	
    // test if this object hit another
    public function checkContact(name:String){
        this.parent.checkContact(this.name, name);
    }
	
	public static function EulerToAxis(ox:Float, oy:Float, oz:Float):Array<Float> {	// angles in radians
		var c1 = Math.cos(oy * 0.5);	//heading
		var s1 = Math.sin(oy * 0.5);
		var c2 = Math.cos(oz * 0.5);	//altitude
		var s2 = Math.sin(oz * 0.5);
		var c3 = Math.cos(ox * 0.5);	//bank
		var s3 = Math.sin(ox * 0.5);
		var c1c2 = c1 * c2;
		var s1s2 = s1 * s2;
		var w = c1c2 * c3 - s1s2 * s3;
		var x = c1c2 * s3 + s1s2 * c3;
		var y = s1 * c2 * c3 + c1 * s2 * s3;
		var z = c1 * s2 * c3 - s1 * c2 * s3;
		var angle = 2 * Math.acos(w);
		var norm = x * x + y * y + z * z;
		if (norm < 0.001) {
			x = 1;
			y = z = 0;
		} 
		else {
			norm = Math.sqrt(norm);
			x /= norm;
			y /= norm;
			z /= norm;
		}
		
		return [angle, x, y, z];
	}
	
	public static function EulerToMatrix(ox:Float, oy:Float, oz:Float):Mat33 {// angles in radians
		var ch = Math.cos(oy);	//heading
		var sh = Math.sin(oy);
		var ca = Math.cos(oz);	//altitude
		var sa = Math.sin(oz);
		var cb = Math.cos(ox);	//bank
		var sb = Math.sin(ox);
		var mtx = new Mat33();
		
		mtx.elements[0] = ch * ca;
		mtx.elements[1] = sh * sb - ch * sa * cb;
		mtx.elements[2] = ch * sa * sb + sh * cb;
		mtx.elements[3] = sa;
		mtx.elements[4] = ca * cb;
		mtx.elements[5] = -ca * sb;
		mtx.elements[6] = -sh * ca;
		mtx.elements[7] = sh * sa * cb + ch * sb;
		mtx.elements[8] = -sh * sa * sb + ch * cb;
		return mtx;
	}
	
}
