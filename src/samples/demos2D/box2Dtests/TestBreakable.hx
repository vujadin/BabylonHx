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
	
	
	
class TestBreakable extends Test{
		
		public function new(){
			super();
			// Set Text field
// 			Global.caption.text = "Breakable";
			
			m_world.setContactListener(new ContactListenerBreakable(this));
			
			var ground:B2Body = m_world.getGroundBody();
			
			// Breakable Dynamic Body
			{
				var bd:B2BodyDef = new B2BodyDef();
				bd.type = 2;//B2Body.b2_dynamicBody;
				bd.position.set(5.0, 5.0);
				bd.angle = 0.25 * Math.PI;
				m_body1 = m_world.createBody(bd);
				
				m_shape1.setAsOrientedBox(0.5, 0.5, new B2Vec2( -0.5, 0.0));
				m_piece1 = m_body1.createFixture2(m_shape1, 1.0);
				
				m_shape2.setAsOrientedBox(0.5, 0.5, new B2Vec2( 0.5, 0.0));
				m_piece2 = m_body1.createFixture2(m_shape2, 1.0);
			}
			
			m_break = false;
			m_broke = false;
		}
		
		public function Break():Void
		{
			// Apply cached velocity for more realistic break
			m_body1.setLinearVelocity(m_velocity);
			m_body1.setAngularVelocity(m_angularVelocity);
			
			// Split body into two pieces
			m_body1.split(function(fixture:B2Fixture):Bool {
				return fixture != m_piece1;
			});
		}
		
		override public function Update():Void 
		{
			super.Update();
			if (m_break)
			{
				Break();
				m_broke = true;
				m_break = false;
			}
			
			// Cache velocities to improve movement on breakage
			if (m_broke == false)
			{
				m_velocity = m_body1.getLinearVelocity();
				m_angularVelocity = m_body1.getAngularVelocity();
			}
		}
		
		//======================
		// Member Data 
		//======================
		
		public var m_body1:B2Body;
		public var m_velocity:B2Vec2 = new B2Vec2();
		public var m_angularVelocity:Float;
		public var m_shape1:B2PolygonShape = new B2PolygonShape();
		public var m_shape2:B2PolygonShape = new B2PolygonShape();
		public var m_piece1:B2Fixture;
		public var m_piece2:B2Fixture;
		public var m_broke:Bool;
		public var m_break:Bool;
	}