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
	
import box2D.dynamics.joints.B2PulleyJoint;
	
	
class TestCrankGearsPulley extends Test
{
	
		public function new(){
			super();
			// Set Text field
			//Main.m_aboutText.text = "Joints";
			
			var ground:B2Body = m_world.getGroundBody();
			
			var body:B2Body;
			var circleBody:B2Body;
			var sd:B2PolygonShape;
			var bd:B2BodyDef;
			var fixtureDef:B2FixtureDef = new B2FixtureDef();
			
			//
			// CRANK
			//
			{
				// Define crank.
				sd = new B2PolygonShape();
				sd.setAsBox(7.5 / m_physScale, 30.0 / m_physScale);
				fixtureDef.shape = sd;
				fixtureDef.density = 1.0;
				
				var rjd:B2RevoluteJointDef = new B2RevoluteJointDef();
				
				var prevBody:B2Body = ground;
				
				bd = new B2BodyDef();
				bd.type = 2;
				bd.position.set(100.0/m_physScale, (360.0-105.0)/m_physScale);
				body = m_world.createBody(bd);
				body.createFixture(fixtureDef);
				
				rjd.initialize(prevBody, body, new B2Vec2(100.0/m_physScale, (360.0-75.0)/m_physScale));
				rjd.motorSpeed = 1.0 * -Math.PI;
				rjd.maxMotorTorque = 5000.0;
				rjd.enableMotor = true;
				m_joint1 = cast(m_world.createJoint(rjd),B2RevoluteJoint);
				
				prevBody = body;
				
				// Define follower.
				sd = new B2PolygonShape();
				sd.setAsBox(7.5 / m_physScale, 60.0 / m_physScale);
				fixtureDef.shape = sd;
				bd.position.set(100.0/m_physScale, (360.0-195.0)/m_physScale);
				body = m_world.createBody(bd);
				body.createFixture(fixtureDef);
				
				rjd.initialize(prevBody, body, new B2Vec2(100.0/m_physScale, (360.0-135.0)/m_physScale));
				rjd.enableMotor = false;
				m_world.createJoint(rjd);
				
				prevBody = body;
				
				// Define piston
				sd = new B2PolygonShape();
				sd.setAsBox(22.5 / m_physScale, 22.5 / m_physScale);
				fixtureDef.shape = sd;
				bd.position.set(100.0/m_physScale, (360.0-255.0)/m_physScale);
				body = m_world.createBody(bd);
				body.createFixture(fixtureDef);
				
				rjd.initialize(prevBody, body, new B2Vec2(100.0/m_physScale, (360.0-255.0)/m_physScale));
				m_world.createJoint(rjd);
				
				var pjd:B2PrismaticJointDef = new B2PrismaticJointDef();
				pjd.initialize(ground, body, new B2Vec2(100.0/m_physScale, (360.0-255.0)/m_physScale), new B2Vec2(0.0, 1.0));
				
				pjd.maxMotorForce = 500.0;
				pjd.enableMotor = true;
				
				m_joint2 = cast(m_world.createJoint(pjd),B2PrismaticJoint);
				
				// Create a payload
				sd = new B2PolygonShape();
				sd.setAsBox(22.5 / m_physScale, 22.5 / m_physScale);
				fixtureDef.shape = sd;
				fixtureDef.density = 2.0;
				bd.position.set(100.0/m_physScale, (360.0-345.0)/m_physScale);
				body = m_world.createBody(bd);
				body.createFixture(fixtureDef);
			}
			
			
			// 
			// GEARS
			//
			//{
				var circle1:B2CircleShape = new B2CircleShape(25 / m_physScale);
				fixtureDef.shape = circle1;
				fixtureDef.density = 5.0;
				
				var bd1:B2BodyDef = new B2BodyDef();
				bd1.type = 2;//B2Body.B2_dynamicBody;
				bd1.position.set(200 / m_physScale, 360/2 / m_physScale);
				var body1:B2Body = m_world.createBody(bd1);
				body1.createFixture(fixtureDef);
				
				var jd1:B2RevoluteJointDef = new B2RevoluteJointDef();
				jd1.initialize(ground, body1, bd1.position);
				m_gJoint1 = cast(m_world.createJoint(jd1),B2RevoluteJoint);
				
				var circle2:B2CircleShape = new B2CircleShape(50 / m_physScale);
				fixtureDef.shape = circle2;
				fixtureDef.density = 5.0;
				
				var bd2:B2BodyDef = new B2BodyDef();
				bd2.type = 2;//B2Body.B2_dynamicBody;
				bd2.position.set(275 / m_physScale, 360/2 / m_physScale);
				var body2:B2Body = m_world.createBody(bd2);
				body2.createFixture(fixtureDef);
				
				var jd2:B2RevoluteJointDef = new B2RevoluteJointDef();
				jd2.initialize(ground, body2, bd2.position);
				m_gJoint2 = cast(m_world.createJoint(jd2),B2RevoluteJoint);
				
				var box:B2PolygonShape = new B2PolygonShape();
				box.setAsBox(10 / m_physScale, 100 / m_physScale);
				fixtureDef.shape = box;
				fixtureDef.density = 5.0;
				
				var bd3:B2BodyDef = new B2BodyDef();
				bd3.type = 2;//B2Body.B2_dynamicBody;
				bd3.position.set(335 / m_physScale, 360/2 / m_physScale);
				var body3:B2Body = m_world.createBody(bd3);
				body3.createFixture(fixtureDef);
				
				var jd3:B2PrismaticJointDef = new B2PrismaticJointDef();
				jd3.initialize(ground, body3, bd3.position, new B2Vec2(0,1));
				jd3.lowerTranslation = -25.0 / m_physScale;
				jd3.upperTranslation = 100.0 / m_physScale;
				jd3.enableLimit = true;
				
				m_gJoint3 = cast(m_world.createJoint(jd3),B2PrismaticJoint);
				
				var jd4:B2GearJointDef = new B2GearJointDef();
				jd4.bodyA = body1;
				jd4.bodyB = body2;
				jd4.joint1 = m_gJoint1;
				jd4.joint2 = m_gJoint2;
				jd4.ratio = circle2.getRadius() / circle1.getRadius();
				m_gJoint4 = cast(m_world.createJoint(jd4),B2GearJoint);
				
				var jd5:B2GearJointDef = new B2GearJointDef();
				jd5.bodyA = body2;
				jd5.bodyB = body3;
				jd5.joint1 = m_gJoint2;
				jd5.joint2 = m_gJoint3;
				jd5.ratio = -1.0 / circle2.getRadius();
				m_gJoint5 = cast(m_world.createJoint(jd5),B2GearJoint);
			//}
			
			
			
			//
			// PULLEY
			//
			//{
				sd = new B2PolygonShape();
				sd.setAsBox(50 / m_physScale, 20 / m_physScale);
				fixtureDef.shape = sd;
				fixtureDef.density = 5.0;
				
				bd = new B2BodyDef();
				bd.type = B2Body.b2_dynamicBody;
				
				bd.position.set(480 / m_physScale, 200 / m_physScale);
				body2 = m_world.createBody(bd);
				body2.createFixture(fixtureDef);
				
				var pulleyDef:B2PulleyJointDef = new B2PulleyJointDef();
				
				var anchor1:B2Vec2 = new B2Vec2(335 / m_physScale, 180 / m_physScale);
				var anchor2:B2Vec2 = new B2Vec2(480 / m_physScale, 180 / m_physScale);
				var groundAnchor1:B2Vec2 = new B2Vec2(335 / m_physScale, 50 / m_physScale);
				var groundAnchor2:B2Vec2 = new B2Vec2(480 / m_physScale, 50 / m_physScale);
				pulleyDef.initialize(body3, body2, groundAnchor1, groundAnchor2, anchor1, anchor2, 2.0);
				
				pulleyDef.maxLengthA = 200 / m_physScale;
				pulleyDef.maxLengthB = 150 / m_physScale;
				
				//m_joint1 = m_world.CreateJoint(pulleyDef) as b2PulleyJoint;
				m_world.createJoint(pulleyDef);// as b2PulleyJoint;
				
				
				// Add a circle to weigh down the pulley
				var circ:B2CircleShape = new B2CircleShape(40 / m_physScale);
				fixtureDef.shape = circ;
				fixtureDef.friction = 0.3;
				fixtureDef.restitution = 0.3;
				fixtureDef.density = 5.0;
				bd.position.set(485 / m_physScale, 100 / m_physScale);
				body1 = circleBody = m_world.createBody(bd);
				body1.createFixture(fixtureDef);
			//}
			
			//
			// LINE JOINT
			//
			{
				sd = new B2PolygonShape();
				sd.setAsBox(7.5 / m_physScale, 30.0 / m_physScale);
				fixtureDef.shape = sd;
				fixtureDef.density = 1.0;
				
				bd = new B2BodyDef();
				bd.type = B2Body.b2_dynamicBody;
				bd.position.set(500 / m_physScale, 500/2 / m_physScale);
				
				body = m_world.createBody(bd);
				body.createFixture(fixtureDef);
				
				var ljd:B2LineJointDef = new B2LineJointDef();
				ljd.initialize(ground, body, body.getPosition(), new B2Vec2(0.4, 0.6));

				ljd.lowerTranslation = -1;
				ljd.upperTranslation = 1;
				ljd.enableLimit = true;
				
				ljd.maxMotorForce = 1;
				ljd.motorSpeed = 0;
				ljd.enableMotor = true;
// 				m_world.createJoint(ljd); // perhaps left join not supported in openfl or else :(
			}
			//*/
			//
			// FRICTION JOINT
			//
			{
				var fjd:B2FrictionJointDef = new B2FrictionJointDef();
				fjd.initialize(circleBody, m_world.getGroundBody(), circleBody.getPosition());
				fjd.collideConnected = true;
				fjd.maxForce = 200;
				m_world.createJoint(fjd);
			}
			
			//
			// WELD JOINT
			//
			// Not enabled as Weld joints are not encouraged compared with merging two bodies
			if(false)
			{
				var wjd:B2WeldJointDef = new B2WeldJointDef();
				wjd.initialize(circleBody, body, circleBody.getPosition());
				m_world.createJoint(wjd);
			}

		}
		
		
		//======================
		// Member Data 
		//======================
		private var m_joint1:B2RevoluteJoint;
		private var m_joint2:B2PrismaticJoint;
		
		public var m_gJoint1:B2RevoluteJoint;
		public var m_gJoint2:B2RevoluteJoint;
		public var m_gJoint3:B2PrismaticJoint;
		public var m_gJoint4:B2GearJoint;
		public var m_gJoint5:B2GearJoint;
		
	}
	