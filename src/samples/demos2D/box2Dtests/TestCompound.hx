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
	
 class TestCompound extends Test{
		
		public function new(){
			super();
			
			var bd:B2BodyDef;
			var body:B2Body;
			var i:Int;
			var x:Float;
			
			{
				var cd1:B2CircleShape = new B2CircleShape();
				cd1.setRadius(15.0/m_physScale);
				cd1.setLocalPosition(new B2Vec2( -15.0 / m_physScale, 15.0 / m_physScale));
				
				var cd2:B2CircleShape = new B2CircleShape();
				cd2.setRadius(15.0/m_physScale);
				cd2.setLocalPosition(new B2Vec2(15.0 / m_physScale, 15.0 / m_physScale));
				
				bd = new B2BodyDef();
				bd.type = 2;//B2Body.B2_dynamicBody;
				
// 				for (i = 0; i < 5; ++i)
				for(i in 0...5)
				{
					x = 320.0 + B2Math.randomRange(-3.0, 3.0);
					bd.position.set((x + 150.0)/m_physScale, (31.5 + 75.0 * -i + 300.0)/m_physScale);
					bd.angle = B2Math.randomRange(-Math.PI, Math.PI);
					body = m_world.createBody(bd);
					body.createFixture2(cd1, 2.0);
					body.createFixture2(cd2, 0.0);
				}
			}
			
			{
				var pd1:B2PolygonShape = new B2PolygonShape();
				pd1.setAsBox(7.5/m_physScale, 15.0/m_physScale);
				
				var pd2:B2PolygonShape = new B2PolygonShape();
				pd2.setAsOrientedBox(7.5/m_physScale, 15.0/m_physScale, new B2Vec2(0.0, -15.0/m_physScale), 0.5 * Math.PI);
				
				bd = new B2BodyDef();
				bd.type = 2;//B2Body.B2_dynamicBody;
				
// 				for (i = 0; i < 5; ++i)
				for(i in 0...5)
				{
					x = 320.0 + B2Math.randomRange(-3.0, 3.0);
					bd.position.set((x - 150.0)/m_physScale, (31.5 + 75.0 * -i + 300)/m_physScale);
					bd.angle = B2Math.randomRange(-Math.PI, Math.PI);
					body = m_world.createBody(bd);
					body.createFixture2(pd1, 2.0);
					body.createFixture2(pd2, 2.0);
				}
			}
			
			{
				var xf1:B2Transform = new B2Transform();
				xf1.R.set(0.3524 * Math.PI);
				xf1.position = B2Math.mulMV(xf1.R, new B2Vec2(1.0, 0.0));
				
				var sd1:B2PolygonShape = new B2PolygonShape();
				sd1.setAsArray([
					B2Math.mulX(xf1, new B2Vec2(-30.0/m_physScale, 0.0)),
					B2Math.mulX(xf1, new B2Vec2(30.0/m_physScale, 0.0)),
					B2Math.mulX(xf1, new B2Vec2(0.0, 15.0 / m_physScale)),
					]);
				
				var xf2:B2Transform = new B2Transform();
				xf2.R.set(-0.3524 * Math.PI);
				xf2.position = B2Math.mulMV(xf2.R, new B2Vec2(-30.0/m_physScale, 0.0));
				
				var sd2:B2PolygonShape = new B2PolygonShape();
				sd2.setAsArray([
					B2Math.mulX(xf2, new B2Vec2(-30.0/m_physScale, 0.0)),
					B2Math.mulX(xf2, new B2Vec2(30.0/m_physScale, 0.0)),
					B2Math.mulX(xf2, new B2Vec2(0.0, 15.0 / m_physScale)),
					]);
				
				bd = new B2BodyDef();
				bd.type = 2;//B2Body.B2_dynamicBody;
				bd.fixedRotation = true;
				
// 				for (i = 0; i < 5; ++i)
				for(i in 0...5)
				{
					x = 320.0 + B2Math.randomRange(-3.0, 3.0);
					bd.position.set(x/m_physScale, (-61.5 + 55.0 * -i + 300)/m_physScale);
					bd.angle = 0.0;
					body = m_world.createBody(bd);
					body.createFixture2(sd1, 2.0);
					body.createFixture2(sd2, 2.0);
				}
			}
			
			{
				var sd_bottom:B2PolygonShape = new B2PolygonShape();
				sd_bottom.setAsBox( 45.0/m_physScale, 4.5/m_physScale );
				
				var sd_left:B2PolygonShape = new B2PolygonShape();
				sd_left.setAsOrientedBox(4.5/m_physScale, 81.0/m_physScale, new B2Vec2(-43.5/m_physScale, -70.5/m_physScale), -0.2);
				
				var sd_right:B2PolygonShape = new B2PolygonShape();
				sd_right.setAsOrientedBox(4.5/m_physScale, 81.0/m_physScale, new B2Vec2(43.5/m_physScale, -70.5/m_physScale), 0.2);
				
				bd = new B2BodyDef();
				bd.type = 2;//B2Body.B2_dynamicBody;
				bd.position.set( 320.0/m_physScale, 300.0/m_physScale );
				body = m_world.createBody(bd);
				body.createFixture2(sd_bottom, 4.0);
				body.createFixture2(sd_left, 4.0);
				body.createFixture2(sd_right, 4.0);
			}
			
		}
		
		
		//======================
		// Member Data 
		//======================
	}
	