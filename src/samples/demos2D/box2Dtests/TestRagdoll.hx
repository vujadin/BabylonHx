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
	
import com.babylonhx.d2.display.Sprite;
	
	
class TestRagdoll extends Test{
	
	
	public function new(){
		super();
		// Set Text field
		//Main.m_aboutText.text = "Ragdolls";
		var circ:B2CircleShape; 
		var box:B2PolygonShape;
		var bd:B2BodyDef = new B2BodyDef();
		var jd:B2RevoluteJointDef = new B2RevoluteJointDef();
		var fixtureDef:B2FixtureDef = new B2FixtureDef();
		//trace('world');
		// Add 5 ragdolls along the top
		//for (var i:int = 0; i < 2; i++)
		for(i in 0...2)
		{
			
			var startX:Float = 70 + Math.random() * 20 + 480 * i;
			var startY:Float = 20 + Math.random() * 50;
			
			// BODIES
			// Set these to dynamic bodies
			bd.type = 2;
			
			// Head
			circ = new B2CircleShape( 12.5 / m_physScale );
			fixtureDef.shape = circ;
			fixtureDef.density = 1.0;
			fixtureDef.friction = 0.4;
			fixtureDef.restitution = 0.3;
			bd.position.set(startX / m_physScale, startY / m_physScale);
			var head:B2Body = m_world.createBody(bd);
			head.createFixture(fixtureDef);
			//if (i == 0){
				head.applyImpulse(new B2Vec2(Math.random() * 100 - 50, Math.random() * 100 - 50), head.getWorldCenter());
			//}
			
			// Torso1
			box = new B2PolygonShape();
			box.setAsBox(15 / m_physScale, 10 / m_physScale);
			fixtureDef.shape = box;
			fixtureDef.density = 1.0;
			fixtureDef.friction = 0.4;
			fixtureDef.restitution = 0.1;
			bd.position.set(startX / m_physScale, (startY + 28) / m_physScale);
			var torso1:B2Body = m_world.createBody(bd);
			torso1.createFixture(fixtureDef);
			// Torso2
			box = new B2PolygonShape();
			box.setAsBox(15 / m_physScale, 10 / m_physScale);
			fixtureDef.shape = box;
			bd.position.set(startX / m_physScale, (startY + 43) / m_physScale);
			var torso2:B2Body = m_world.createBody(bd);
			torso2.createFixture(fixtureDef);
			// Torso3
			box.setAsBox(15 / m_physScale, 10 / m_physScale);
			fixtureDef.shape = box;
			bd.position.set(startX / m_physScale, (startY + 58) / m_physScale);
			var torso3:B2Body = m_world.createBody(bd);
			torso3.createFixture(fixtureDef);
			
			// UpperArm
			fixtureDef.density = 1.0;
			fixtureDef.friction = 0.4;
			fixtureDef.restitution = 0.1;
			// L
			box = new B2PolygonShape();
			box.setAsBox(18 / m_physScale, 6.5 / m_physScale);
			fixtureDef.shape = box;
			bd.position.set((startX - 30) / m_physScale, (startY + 20) / m_physScale);
			var upperArmL:B2Body = m_world.createBody(bd);
			upperArmL.createFixture(fixtureDef);
			// R
			box = new B2PolygonShape();
			box.setAsBox(18 / m_physScale, 6.5 / m_physScale);
			fixtureDef.shape = box;
			bd.position.set((startX + 30) / m_physScale, (startY + 20) / m_physScale);
			var upperArmR:B2Body = m_world.createBody(bd);
			upperArmR.createFixture(fixtureDef);
			
			// LowerArm
			fixtureDef.density = 1.0;
			fixtureDef.friction = 0.4;
			fixtureDef.restitution = 0.1;
			// L
			box = new B2PolygonShape();
			box.setAsBox(17 / m_physScale, 6 / m_physScale);
			fixtureDef.shape = box;
			bd.position.set((startX - 57) / m_physScale, (startY + 20) / m_physScale);
			var lowerArmL:B2Body = m_world.createBody(bd);
			lowerArmL.createFixture(fixtureDef);
			// R
			box = new B2PolygonShape();
			box.setAsBox(17 / m_physScale, 6 / m_physScale);
			fixtureDef.shape = box;
			bd.position.set((startX + 57) / m_physScale, (startY + 20) / m_physScale);
			var lowerArmR:B2Body = m_world.createBody(bd);
			lowerArmR.createFixture(fixtureDef);
			
			// UpperLeg
			fixtureDef.density = 1.0;
			fixtureDef.friction = 0.4;
			fixtureDef.restitution = 0.1;
			// L
			box = new B2PolygonShape();
			box.setAsBox(7.5 / m_physScale, 22 / m_physScale);
			fixtureDef.shape = box;
			bd.position.set((startX - 8) / m_physScale, (startY + 85) / m_physScale);
			var upperLegL:B2Body = m_world.createBody(bd);
			upperLegL.createFixture(fixtureDef);
			// R
			box = new B2PolygonShape();
			box.setAsBox(7.5 / m_physScale, 22 / m_physScale);
			fixtureDef.shape = box;
			bd.position.set((startX + 8) / m_physScale, (startY + 85) / m_physScale);
			var upperLegR:B2Body = m_world.createBody(bd);
			upperLegR.createFixture(fixtureDef);
			
			// LowerLeg
			fixtureDef.density = 1.0;
			fixtureDef.friction = 0.4;
			fixtureDef.restitution = 0.1;
			// L
			box = new B2PolygonShape();
			box.setAsBox(6 / m_physScale, 20 / m_physScale);
			fixtureDef.shape = box;
			bd.position.set((startX - 8) / m_physScale, (startY + 120) / m_physScale);
			var lowerLegL:B2Body = m_world.createBody(bd);
			lowerLegL.createFixture(fixtureDef);
			// R
			box = new B2PolygonShape();
			box.setAsBox(6 / m_physScale, 20 / m_physScale);
			fixtureDef.shape = box;
			bd.position.set((startX + 8) / m_physScale, (startY + 120) / m_physScale);
			var lowerLegR:B2Body = m_world.createBody(bd);
			lowerLegR.createFixture(fixtureDef);
			
			
			// JOINTS
			jd.enableLimit = true;
			
			// Head to shoulders
			jd.lowerAngle = -40 / (180/Math.PI);
			jd.upperAngle = 40 / (180/Math.PI);
			jd.initialize(torso1, head, new B2Vec2(startX / m_physScale, (startY + 15) / m_physScale));
			m_world.createJoint(jd);
			
			// Upper arm to shoulders
			// L
			jd.lowerAngle = -85 / (180/Math.PI);
			jd.upperAngle = 130 / (180/Math.PI);
			jd.initialize(torso1, upperArmL, new B2Vec2((startX - 18) / m_physScale, (startY + 20) / m_physScale));
			m_world.createJoint(jd);
			// R
			jd.lowerAngle = -130 / (180/Math.PI);
			jd.upperAngle = 85 / (180/Math.PI);
			jd.initialize(torso1, upperArmR, new B2Vec2((startX + 18) / m_physScale, (startY + 20) / m_physScale));
			m_world.createJoint(jd);
			
			// Lower arm to upper arm
			// L
			jd.lowerAngle = -130 / (180/Math.PI);
			jd.upperAngle = 10 / (180/Math.PI);
			jd.initialize(upperArmL, lowerArmL, new B2Vec2((startX - 45) / m_physScale, (startY + 20) / m_physScale));
			m_world.createJoint(jd);
			// R
			jd.lowerAngle = -10 / (180/Math.PI);
			jd.upperAngle = 130 / (180/Math.PI);
			jd.initialize(upperArmR, lowerArmR, new B2Vec2((startX + 45) / m_physScale, (startY + 20) / m_physScale));
			m_world.createJoint(jd);
			
			// Shoulders/stomach
			jd.lowerAngle = -15 / (180/Math.PI);
			jd.upperAngle = 15 / (180/Math.PI);
			jd.initialize(torso1, torso2, new B2Vec2(startX / m_physScale, (startY + 35) / m_physScale));
			m_world.createJoint(jd);
			// Stomach/hips
			jd.initialize(torso2, torso3, new B2Vec2(startX / m_physScale, (startY + 50) / m_physScale));
			m_world.createJoint(jd);
			
			// Torso to upper leg
			// L
			jd.lowerAngle = -25 / (180/Math.PI);
			jd.upperAngle = 45 / (180/Math.PI);
			jd.initialize(torso3, upperLegL, new B2Vec2((startX - 8) / m_physScale, (startY + 72) / m_physScale));
			m_world.createJoint(jd);
			// R
			jd.lowerAngle = -45 / (180/Math.PI);
			jd.upperAngle = 25 / (180/Math.PI);
			jd.initialize(torso3, upperLegR, new B2Vec2((startX + 8) / m_physScale, (startY + 72) / m_physScale));
			m_world.createJoint(jd);
			
			// Upper leg to lower leg
			// L
			jd.lowerAngle = -25 / (180/Math.PI);
			jd.upperAngle = 115 / (180/Math.PI);
			jd.initialize(upperLegL, lowerLegL, new B2Vec2((startX - 8) / m_physScale, (startY + 105) / m_physScale));
			m_world.createJoint(jd);
			// R
			jd.lowerAngle = -115 / (180/Math.PI);
			jd.upperAngle = 25 / (180/Math.PI);
			jd.initialize(upperLegR, lowerLegR, new B2Vec2((startX + 8) / m_physScale, (startY + 105) / m_physScale));
			m_world.createJoint(jd);
			
		}
		
		
		// Add stairs on the left, these are static bodies so set the type accordingly
		bd.type = 0;
		fixtureDef.density = 0.0;
		fixtureDef.friction = 0.4;
		fixtureDef.restitution = 0.3;
		//for (var j:int = 1; j <= 10; j++) 
		for (j in 1...11)
		{
			box = new B2PolygonShape();
			box.setAsBox((10*j) / m_physScale, 10 / m_physScale);
			fixtureDef.shape = box;
			bd.position.set((10*j) / m_physScale, (150 + 20*j) / m_physScale);
			var head = m_world.createBody(bd);
			head.createFixture(fixtureDef);
		}
		
		// Add stairs on the right
		//for (var k:int = 1; k <= 10; k++)
		for(k in 1...11)
		{
			box = new B2PolygonShape();
			box.setAsBox((10 * k) / m_physScale, 10 / m_physScale);
			fixtureDef.shape = box;
			bd.position.set((640-10*k) / m_physScale, (150 + 20*k) / m_physScale);
			var head = m_world.createBody(bd);
			head.createFixture(fixtureDef);
		}
		
		box = new B2PolygonShape();
		box.setAsBox(30 / m_physScale, 40 / m_physScale);
		fixtureDef.shape = box;
		bd.position.set(320 / m_physScale, 320 / m_physScale);
		var head = m_world.createBody(bd);
		head.createFixture(fixtureDef);
		
		
	}
	
	
	//======================
	// Member Data 
	//======================
}