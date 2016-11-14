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
	
	
	
	class TestCCD extends Test{
		
		public function new(){
			super();
			// Set Text field
// 			Main.m_aboutText.text = "Continuous Collision Detection";
			
			var bd:B2BodyDef;
			var body:B2Body;
			var fixtureDef:B2FixtureDef = new B2FixtureDef();
			// These values are used for all the parts of the 'basket'
			fixtureDef.density = 4.0; 
			fixtureDef.restitution = 1.4;
			
			// Create 'basket'
			{
				bd = new B2BodyDef();
				bd.type = 2;//B2Body.B2_dynamicBody;
				bd.bullet = true;
				bd.position.set( 150.0/m_physScale, 100.0/m_physScale );
				body = m_world.createBody(bd);
				var sd_bottom:B2PolygonShape = new B2PolygonShape();
				sd_bottom.setAsBox( 45.0 / m_physScale, 4.5 / m_physScale );
				fixtureDef.shape = sd_bottom;
				body.createFixture( fixtureDef );
				
				var sd_left:B2PolygonShape = new B2PolygonShape();
				sd_left.setAsOrientedBox(4.5/m_physScale, 81.0/m_physScale, new B2Vec2(-43.5/m_physScale, -70.5/m_physScale), -0.2);
				fixtureDef.shape = sd_left;
				body.createFixture( fixtureDef );
				
				var sd_right:B2PolygonShape = new B2PolygonShape();
				sd_right.setAsOrientedBox(4.5/m_physScale, 81.0/m_physScale, new B2Vec2(43.5/m_physScale, -70.5/m_physScale), 0.2);
				fixtureDef.shape = sd_right;
				body.createFixture( fixtureDef );
			}
			
			// add some small circles for effect
// 			for (var i:int = 0; i < 5; i++)
			for(i in 0...5)
			{
				var cd:B2CircleShape = new B2CircleShape((Math.random() * 10 + 5) / m_physScale);
				fixtureDef.shape = cd;
				fixtureDef.friction = 0.3;
				fixtureDef.density = 1.0;
				fixtureDef.restitution = 1.1;
				bd = new B2BodyDef();
				bd.type = 2;// B2Body.B2_dynamicBody;
				bd.bullet = true;
				bd.position.set( (Math.random()*300 + 250)/m_physScale, (Math.random()*320 + 20)/m_physScale );
				body = m_world.createBody(bd);
				body.createFixture(fixtureDef);
			}
			
		}
		
		
		//======================
		// Member Data 
		//======================
		
	}
	