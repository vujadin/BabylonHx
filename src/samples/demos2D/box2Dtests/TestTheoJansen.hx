package samples.demos2D.box2Dtests;

/*
* Copyright (c) 2006-2007 Erin Catto http://www.gphysics.com
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 1. The origin of this software must not be misrepresented; you must not
* claim that you wrote the original software. If you use this software
* in a product, an acknowledgment in the product documentation would be
* appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
* misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
*/
import box2D.dynamics.*;
import box2D.collision.*;
import box2D.collision.shapes.*;
import box2D.dynamics.joints.*;
import box2D.dynamics.contacts.*;
import box2D.common.*;
import box2D.common.math.*;
import com.babylonhx.utils.Keycodes;

import box2D.dynamics.B2Body;
	// Input
// 	import General.Input;


class TestTheoJansen extends Test {

		
	public function new(){
		super();
		// Set Text field
// 			Main.m_aboutText.text = "Theo Jansen Walker";
		
		// scale walker by variable to easily change size
		tScale = m_physScale * 2;
		
		// Set position in world space
		m_offset.set(120.0/m_physScale, 250/m_physScale);
		m_motorSpeed = -2.0;
		m_motorOn = true;
		var pivot:B2Vec2 = new B2Vec2(0.0, -24.0/tScale);
		
		var pd:B2PolygonShape;
		var cd:B2CircleShape;
		var fd:B2FixtureDef;
		var bd:B2BodyDef;
		var body:B2Body;
		
// 			for (var i:int = 0; i < 40; ++i)
		for(i in 0...40)
		{
			cd = new B2CircleShape(7.5/tScale);
			
			bd = new B2BodyDef();
			bd.type = 2;//B2Body.B2_dynamicBody;
			// Position in world space
			bd.position.set((Math.random() * 620 + 10)/m_physScale, 350/m_physScale);
			
			body = m_world.createBody(bd);
			body.createFixture2(cd, 1.0);
		}
		
		{
			pd = new B2PolygonShape();
			pd.setAsBox(75 / tScale, 30 / tScale);
			fd = new B2FixtureDef();
			fd.shape = pd;
			fd.density = 1.0;
			fd.filter.groupIndex = -1;
			bd = new B2BodyDef();
			bd.type = 2;//B2Body.B2_dynamicBody;
			//bd.position = pivot + m_offset;
			bd.position = B2Math.addVV(pivot, m_offset);
			m_chassis = m_world.createBody(bd);
			m_chassis.createFixture(fd);
		}
		
		{
			cd = new B2CircleShape(48 / tScale);
			fd = new B2FixtureDef();
			fd.shape = cd;
			fd.density = 1.0;
			fd.filter.groupIndex = -1;
			bd = new B2BodyDef();
			bd.type = 2;//B2Body.B2_dynamicBody;
			//bd.position = pivot + m_offset;
			bd.position = B2Math.addVV(pivot, m_offset);
			m_wheel = m_world.createBody(bd);
			m_wheel.createFixture(fd);
		}
		
		{
			var jd:B2RevoluteJointDef = new B2RevoluteJointDef();
			var po:B2Vec2 = pivot.copy();
			po.add(m_offset);
			jd.initialize(m_wheel, m_chassis, po);
			jd.collideConnected = false;
			jd.motorSpeed = m_motorSpeed;
			jd.maxMotorTorque = 400.0;
			jd.enableMotor = m_motorOn;
			m_motorJoint = cast(m_world.createJoint(jd),B2RevoluteJoint);
		}
		
		var wheelAnchor:B2Vec2;
		
		//wheelAnchor = pivot + B2Vec2(0.0f, -0.8);
		wheelAnchor = new B2Vec2(0.0, 24.0/tScale);
		wheelAnchor.add(pivot);
		
		CreateLeg(-1.0, wheelAnchor);
		CreateLeg(1.0, wheelAnchor);
		
		m_wheel.setPositionAndAngle(m_wheel.getPosition(), 120.0 * Math.PI / 180.0);
		CreateLeg(-1.0, wheelAnchor);
		CreateLeg(1.0, wheelAnchor);
		
		m_wheel.setPositionAndAngle(m_wheel.getPosition(), -120.0 * Math.PI / 180.0);
		CreateLeg(-1.0, wheelAnchor);
		CreateLeg(1.0, wheelAnchor);
		
	}
	
	
	
	private function CreateLeg(s:Float, wheelAnchor:B2Vec2):Void{
		
		var p1:B2Vec2 = new B2Vec2(162 * s/tScale, 183/tScale);
		var p2:B2Vec2 = new B2Vec2(216 * s/tScale, 36 /tScale);
		var p3:B2Vec2 = new B2Vec2(129 * s/tScale, 57 /tScale);
		var p4:B2Vec2 = new B2Vec2( 93 * s/tScale, -24  /tScale);
		var p5:B2Vec2 = new B2Vec2(180 * s/tScale, -45  /tScale);
		var p6:B2Vec2 = new B2Vec2( 75 * s/tScale, -111 /tScale);
		
		//B2PolygonDef sd1, sd2;
		var sd1:B2PolygonShape = new B2PolygonShape();
		var sd2:B2PolygonShape = new B2PolygonShape();
		var fd1:B2FixtureDef = new B2FixtureDef();
		var fd2:B2FixtureDef = new B2FixtureDef();
		fd1.shape = sd1;
		fd2.shape = sd2;
		fd1.filter.groupIndex = -1;
		fd2.filter.groupIndex = -1;
		fd1.density = 1.0;
		fd2.density = 1.0;
		
		if (s > 0.0)
		{
			sd1.setAsArray([p3, p2, p1]);
			sd2.setAsArray([
				B2Math.subtractVV(p6, p4),
				B2Math.subtractVV(p5, p4),
				new B2Vec2()
				]);
		}
		else
		{
			sd1.setAsArray([p2, p3, p1]);
			sd2.setAsArray([
				B2Math.subtractVV(p5, p4),
				B2Math.subtractVV(p6, p4),
				new B2Vec2()
				]);
		}
		
		//B2BodyDef bd1, bd2;
		var bd1:B2BodyDef = new B2BodyDef();
		bd1.type = 2;//B2Body.B2_dynamicBody;
		var bd2:B2BodyDef = new B2BodyDef();
		bd2.type = 2;//B2Body.B2_dynamicBody;
		bd1.position.setV(m_offset);
		bd2.position = B2Math.addVV(p4, m_offset);
		
		bd1.angularDamping = 10.0;
		bd2.angularDamping = 10.0;
		
		var body1:B2Body = m_world.createBody(bd1);
		var body2:B2Body = m_world.createBody(bd2);
		
		body1.createFixture(fd1);
		body2.createFixture(fd2);
		
		var djd:B2DistanceJointDef = new B2DistanceJointDef();
		
		// Using a soft distance constraint can reduce some jitter.
		// It also makes the structure seem a bit more fluid by
		// acting like a suspension system.
		djd.dampingRatio = 0.5;
		djd.frequencyHz = 10.0;
		
		djd.initialize(body1, body2, B2Math.addVV(p2, m_offset), B2Math.addVV(p5, m_offset));
		m_world.createJoint(djd);
		
		djd.initialize(body1, body2, B2Math.addVV(p3, m_offset), B2Math.addVV(p4, m_offset));
		m_world.createJoint(djd);
		
		djd.initialize(body1, m_wheel, B2Math.addVV(p3, m_offset), B2Math.addVV(wheelAnchor, m_offset));
		m_world.createJoint(djd);
		
		djd.initialize(body2, m_wheel, B2Math.addVV(p6, m_offset), B2Math.addVV(wheelAnchor, m_offset));
		m_world.createJoint(djd);
		
		var rjd:B2RevoluteJointDef = new B2RevoluteJointDef();
		
		rjd.initialize(body2, m_chassis, B2Math.addVV(p4, m_offset));
		m_world.createJoint(rjd);
		
	}
	
	
	
	public override function Update():Void{
		
		//case 'a':
		if (Input.isKeyPressed(Keycodes.key_a)){ // A
			m_chassis.setAwake(true);
			m_motorJoint.setMotorSpeed(-m_motorSpeed);
		}
		//case 's':
		if (Input.isKeyPressed(Keycodes.key_s)){ // S
			m_chassis.setAwake(true);
			m_motorJoint.setMotorSpeed(0.0);
		}
		//case 'd':
		if (Input.isKeyPressed(Keycodes.key_d)){ // D
			m_chassis.setAwake(true);
			m_motorJoint.setMotorSpeed(m_motorSpeed);
		}
		//case 'm':
		if (Input.isKeyPressed(Keycodes.key_m)){ // M
			m_chassis.setAwake(true);
			m_motorJoint.enableMotor(!m_motorJoint.isMotorEnabled());
		}
		
		// Finally update super class
		super.Update();
	}
	
	
	//======================
	// Member Data 
	//======================
	private var tScale:Float;
	
	private var m_offset:B2Vec2 = new B2Vec2();
	private var m_chassis:B2Body;
	private var m_wheel:B2Body;
	private var m_motorJoint:B2RevoluteJoint;
	private var m_motorOn:Bool = true;
	private var m_motorSpeed:Float;
	
}