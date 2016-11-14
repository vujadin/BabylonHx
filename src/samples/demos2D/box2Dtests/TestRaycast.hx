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

class TestRaycast extends Test{
		
		public var laser:B2Body;
		
		public function new()
		 {
			super();
			// Set Text field
// 			Main.m_aboutText.text = "Raycast";
			
			m_world.setGravity(new B2Vec2(0,0));
			
			var ground:B2Body = m_world.getGroundBody();
			
			var box:B2PolygonShape = new B2PolygonShape();
			box.setAsBox(30 / m_physScale, 4 / m_physScale);
			var fd:B2FixtureDef = new B2FixtureDef();
			fd.shape = box;
			fd.density = 4;
			fd.friction = 0.4;
			fd.restitution = 0.3;
			fd.userData="laser";
			var bd:B2BodyDef = new B2BodyDef();
			bd.type = B2Body.b2_dynamicBody;
			bd.position.set(320 / m_physScale, 150 / m_physScale);
			bd.position.set(40 / m_physScale, 150 / m_physScale);
			laser = m_world.createBody(bd);
			laser.createFixture(fd);
			laser.setAngle(0.5);
			laser.setAngle(Math.PI);
			
			var circle:B2CircleShape = new B2CircleShape(30 / m_physScale);
			fd.shape = circle;
			fd.density = 4;
			fd.friction = 0.4;
			fd.restitution = 0.3;
			fd.userData="circle";
			bd.position.set(100 / m_physScale, 100 / m_physScale);
			var body:B2Body = m_world.createBody(bd);
			body.createFixture(fd);
		}
		
		
		//======================
		// Member Data 
		//======================
		
		public override function Update():Void{
			super.Update();
			
			var p1:B2Vec2 = laser.getWorldPoint(new B2Vec2(30.1 / m_physScale, 0));
			var p2:B2Vec2 = laser.getWorldPoint(new B2Vec2(130.1 / m_physScale, 0));
			
			var f:B2Fixture = m_world.rayCastOne(p1, p2);
			var lambda:Float = 1;
			if (f != null)
			{
				var input:B2RayCastInput = new B2RayCastInput(p1, p2);
				var output:B2RayCastOutput = new B2RayCastOutput();
				f.rayCast(output, input);
				lambda = output.fraction;
			}
			m_sprite.graphics.lineStyle(1,0xff0000,1);
			m_sprite.graphics.moveTo(p1.x * m_physScale, p1.y * m_physScale);
			m_sprite.graphics.lineTo( 	(p2.x * lambda + (1 - lambda) * p1.x) * m_physScale,
										(p2.y * lambda + (1 - lambda) * p1.y) * m_physScale);

		}
	}
	
