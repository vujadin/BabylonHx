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


	
	
import box2D.common.math.B2Vec2;
	
	import box2D.dynamics.*;
	import box2D.collision.*;
	import box2D.collision.shapes.*;
	import box2D.dynamics.joints.*;
	import box2D.dynamics.contacts.*;
	import box2D.common.*;
	import box2D.common.math.*;
	
	//TODO_BORIS: Remove
//	use namespace B2internal;
	
	 class TestStack extends Test{
		 
		public function new(){
			super();
			// Set Text field
// 			Main.m_aboutText.text = "Stacked Boxes";
			
			// Add bodies
			var fd:B2FixtureDef = new B2FixtureDef();
			var sd:B2PolygonShape = new B2PolygonShape();
			var bd:B2BodyDef = new B2BodyDef();
			bd.type = 2;//B2Body.B2_dynamicBody;
			//bd.isBullet = true;
			var b:B2Body;
			fd.density = 1.0;
			fd.friction = 0.5;
			fd.restitution = 0.1;
			fd.shape = sd;
			var i:Int;
			// Create 3 stacks
// 			for (i = 0; i < 10; i++)
			for(i in 0...10)
			{
				sd.setAsBox((10) / m_physScale, (10) / m_physScale);
				//bd.position.set((640/2+100+Math.random()*0.02 - 0.01) / m_physScale, (360-5-i*25) / m_physScale);
				bd.position.set((640/2+100) / m_physScale, (360-5-i*25) / m_physScale);
				b = m_world.createBody(bd);
				b.createFixture(fd);
			}
// 			for (i = 0; i < 10; i++)
			for(i in 0...10)
			{
				sd.setAsBox((10) / m_physScale, (10) / m_physScale);
				bd.position.set((640/2-0+Math.random()*0.02 - 0.01) / m_physScale, (360-5-i*25) / m_physScale);
				b = m_world.createBody(bd);
				b.createFixture(fd);
			}
// 			for (i = 0; i < 10; i++)
			for(i in 0...10)
			{
				sd.setAsBox((10) / m_physScale, (10) / m_physScale);
				bd.position.set((640/2+200+Math.random()*0.02 - 0.01) / m_physScale, (360-5-i*25) / m_physScale);
				b = m_world.createBody(bd);
				b.createFixture(fd);
			}
			// Create ramp
			var vxs:Array<B2Vec2> = [new B2Vec2(0, 0),
				new B2Vec2(0, -100 / m_physScale),
				new B2Vec2(200 / m_physScale, 0)];
			sd.setAsArray(vxs, vxs.length);
			fd.density = 0;
			bd.type = 0;//B2Body.B2_staticBody;
			bd.userData = "ramp";
			bd.position.set(0, 360 / m_physScale);
			b = m_world.createBody(bd);
			b.createFixture(fd);
			
			// Create ball
			var cd:B2CircleShape = new B2CircleShape();
			cd.m_radius = 40/m_physScale;
			fd.density = 2;
			fd.restitution = 0.2;
			fd.friction = 0.5;
			fd.shape = cd;
			bd.type = 2;//B2Body.B2_dynamicBody;
			bd.userData = "ball";
			bd.position.set(50/m_physScale, 100 / m_physScale);
			b = m_world.createBody(bd);
			b.createFixture(fd);
			
		}
		
		
		//======================
		// Member Data 
		//======================
	}
	
