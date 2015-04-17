package com.babylonhx.physics.plugins;

import oimohx.physics.constraint.joint.BallAndSocketJoint;
import oimohx.physics.constraint.joint.DistanceJoint;
import oimohx.physics.constraint.joint.HingeJoint;
import oimohx.physics.constraint.joint.Joint;
import oimohx.physics.constraint.joint.JointConfig;
import oimohx.physics.constraint.joint.PrismaticJoint;
import oimohx.physics.constraint.joint.SliderJoint;
import oimohx.physics.constraint.joint.WheelJoint;
import oimohx.physics.dynamics.RigidBody;
import oimohx.physics.dynamics.World;
import oimohx.math.Vec3;

/**
 * ...
 * @author Krtolica Vujadin
 */

typedef LinkConfig = {
	world:Null<World>,
	name:Null<String>,
	type:Null<String>,
	axe1:Null<Array<Float>>,
	axe2:Null<Array<Float>>,
	pos1:Null<Array<Float>>,
	pos2:Null<Array<Float>>,
	min:Null<Float>,
	max:Null<Float>,
	limit:Null<Array<Float>>,
	spring:Null<Dynamic>,
	motor:Null<Dynamic>,
	collision:Null<Dynamic>,
	body1:Null<Dynamic>,
	body2:Null<Dynamic>
}
 
class Link {
	
	public var parent:World;
	public var name:String;
	public var joint:Joint;
	

	public function new(obj:Dynamic) {
		if (obj.world == null) {
			return;
		}
		
		// the world where i am
		this.parent = obj.world;
		
		this.name = obj.name != null ? obj.name : '';
		var type = obj.type != null ? obj.type : "jointHinge";
		var axe1 = obj.axe1 != null ? obj.axe1 : [1.0, 0.0, 0.0];
		var axe2 = obj.axe2 != null ? obj.axe2 : [1.0, 0.0, 0.0];
		var pos1 = obj.pos1 != null ? obj.pos1 : [0.0, 0.0, 0.0];
		var pos2 = obj.pos2 != null ? obj.pos2 : [0.0, 0.0, 0.0];
		
		pos1 = pos1.map(function(x) { return x * World.INV_SCALE; });
		pos2 = pos2.map(function(x) { return x * World.INV_SCALE; });
		
		var min:Float;
		var max:Float;
		if(type == "jointDistance"){
			min = obj.min != null ? obj.min : 0;
			max = obj.max != null ? obj.max : 10;
			min = min * World.INV_SCALE;
			max = max * World.INV_SCALE;
		}else{
			min = obj.min != null ? obj.min : 57.29578;
			max = obj.max != null ? obj.max : 0;
			min = min * World.TO_RAD;
			max = max * World.TO_RAD;
		}
		
		var limit:Array<Float> = obj.limit;
		var spring = obj.spring;
		var motor = obj.motor;
		
		// joint setting
		var jc:JointConfig = new JointConfig();
		jc.allowCollision = obj.collision != null ? obj.collision : false;
		jc.localAxis1.init(axe1[0], axe1[1], axe1[2]);
		jc.localAxis2.init(axe2[0], axe2[1], axe2[2]);
		jc.localAnchorPoint1.init(pos1[0], pos1[1], pos1[2]);
		jc.localAnchorPoint2.init(pos2[0], pos2[1], pos2[2]);
		/*var b1:RigidBody = null;
		var b2:RigidBody = null;
		if (Std.is(obj.body1, String)) {
			b1 = obj.world.getByName(cast obj.body1);
		} else {
			b1 = obj.body1;
		}
		if (Std.is(obj.body2, String)) {
			b2 = obj.world.getByName(cast obj.body2);
		} else {
			b2 = obj.body2;
		}*/
		jc.body1 = obj.body1;
		jc.body2 = obj.body2;
		
		
		switch(type){
			case "jointDistance": 
				this.joint = new DistanceJoint(jc, min, max); 
				if (spring != null) {
					cast(this.joint, DistanceJoint).limitMotor.setSpring(spring[0], spring[1]);
				}
				if (motor != null) {
					cast(this.joint, DistanceJoint).limitMotor.setSpring(motor[0], motor[1]);
				}
			
			case "jointHinge": 
				this.joint = new HingeJoint(jc, min, max);
				if (spring != null) {
					cast(this.joint, HingeJoint).limitMotor.setSpring(spring[0], spring[1]);// soften the joint ex: 100, 0.2
				}
				if (motor != null) {
					cast(this.joint, HingeJoint).limitMotor.setSpring(motor[0], motor[1]);
				}
			
			case "jointPrisme": 
				this.joint = new PrismaticJoint(jc, min, max); 
				
			case "jointSlide": 
				this.joint = new SliderJoint(jc, min, max);
				
			case "jointBall": 
				this.joint = new BallAndSocketJoint(jc); 
				
			case "jointWheel": 
				this.joint = new WheelJoint(jc);  
				if (limit != null) {
					cast(this.joint, WheelJoint).rotationalLimitMotor1.setLimit(limit[0], limit[1]);
				}
				if (spring != null) {
					cast(this.joint, WheelJoint).rotationalLimitMotor1.setSpring(spring[0], spring[1]);
				}
				if (motor != null) {
					cast(this.joint, WheelJoint).rotationalLimitMotor1.setSpring(motor[0], motor[1]);
				}
			
		}
		
		//this.joint.name = this.name;
		
		// finaly add to physics world
		this.parent.addJoint(this.joint);
	}
	
	/*public function getPosition():Array<Vec3> {
        // array of two vect3 [point1, point2]
        return this.joint.getPosition();
    }
	
    public function getMatrix():Array<Float> {
        return this.joint.getMatrix();
    }*/
	
    // remove joint
    public function remove() {
        this.parent.removeJoint(this.joint);
    }
	
    // force wakeup linked body
    public function awake() {
        this.joint.awake();
    }
	
}
