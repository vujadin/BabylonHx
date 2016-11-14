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
	
	class TestBridge extends Test{
		
		
		public function new(){
			
			super();
			// Set Text field
			//Main.m_aboutText.text = "Bridge";
			
			var ground:B2Body = m_world.getGroundBody();
			var i:Int;
			var anchor:B2Vec2 = new B2Vec2();
			var body:B2Body;
			
			var fixtureDef:B2FixtureDef = new B2FixtureDef();
			// Bridge
			{
				var sd:B2PolygonShape = new B2PolygonShape();

				sd.setAsBox(24 / m_physScale, 5 / m_physScale);
				fixtureDef.shape = sd;
				fixtureDef.density = 20.0;
				fixtureDef.friction = 0.2;
				
				var bd:B2BodyDef = new B2BodyDef();
				bd.type = B2Body.b2_dynamicBody;
				
				var jd:B2RevoluteJointDef = new B2RevoluteJointDef();
				var numPlanks:Int = 10;
				jd.lowerAngle = -15 / (180/Math.PI);
				jd.upperAngle = 15 / (180/Math.PI);
				jd.enableLimit = true;
				
				var prevBody:B2Body = ground;
				//for (i = 0; i < numPlanks; ++i)
				for (i in 0...numPlanks)
				{
					bd.position.set((100 + 22 + 44 * i) / m_physScale, 250 / m_physScale);
					body = m_world.createBody(bd);
					body.createFixture(fixtureDef);
					
					anchor.set((100 + 44 * i) / m_physScale, 250 / m_physScale);
					jd.initialize(prevBody, body, anchor);
					m_world.createJoint(jd);
					
					prevBody = body;
				}
				
				anchor.set((100 + 44 * numPlanks) / m_physScale, 250 / m_physScale);
				jd.initialize(prevBody, ground, anchor);
				m_world.createJoint(jd);
			}
			
			// Spawn in a bunch of crap
			//for (i = 0; i < 5; i++)
			for (i in 0...5)
			{
				var bodyDef:B2BodyDef = new B2BodyDef();
				bodyDef.type = B2Body.b2_dynamicBody;
				var boxShape:B2PolygonShape = new B2PolygonShape();
				fixtureDef.shape = boxShape;
				fixtureDef.density = 1.0;
				// Override the default friction.
				fixtureDef.friction = 0.3;
				fixtureDef.restitution = 0.1;
				boxShape.setAsBox((Math.random() * 5 + 10) / m_physScale, (Math.random() * 5 + 10) / m_physScale);
				bodyDef.position.set((Math.random() * 400 + 120) / m_physScale, (Math.random() * 150 + 50) / m_physScale);
				bodyDef.angle = Math.random() * Math.PI;
				body = m_world.createBody(bodyDef);
				body.createFixture(fixtureDef);
				
			}
//			for (i = 0; i < 5; i++)
			for (i in 0...5)
			{
				var bodyDefC:B2BodyDef = new B2BodyDef();
				bodyDefC.type = B2Body.b2_dynamicBody;
				var circShape:B2CircleShape = new B2CircleShape((Math.random() * 5 + 10) / m_physScale);
				fixtureDef.shape = circShape;
				fixtureDef.density = 1.0;
				// Override the default friction.
				fixtureDef.friction = 0.3;
				fixtureDef.restitution = 0.1;
				bodyDefC.position.set((Math.random() * 400 + 120) / m_physScale, (Math.random() * 150 + 50) / m_physScale);
				bodyDefC.angle = Math.random() * Math.PI;
				body = m_world.createBody(bodyDefC);
				body.createFixture(fixtureDef);
				
			}
			var j:Int;
// 			for (i = 0; i < 15; i++)
			for (i in 0...15)
			{
				var bodyDefP:B2BodyDef = new B2BodyDef();
				bodyDefP.type = 2;//B2Body.b2_dynamicBody;
				var polyShape:B2PolygonShape = new B2PolygonShape();
				var vertices:Array<B2Vec2> = new Array();
				var vertexCount:Int;
				if (Math.random() > 0.66){
					vertexCount = 4;
// 					for ( j = 0; j < vertexCount; ++j )
					for (j in 0...vertexCount)
					{
						vertices[j] = new B2Vec2();
					}
					vertices[0].set((-10 -Math.random()*10) / m_physScale, ( 10 +Math.random()*10) / m_physScale);
					vertices[1].set(( -5 -Math.random()*10) / m_physScale, (-10 -Math.random()*10) / m_physScale);
					vertices[2].set((  5 +Math.random()*10) / m_physScale, (-10 -Math.random()*10) / m_physScale);
					vertices[3].set(( 10 +Math.random()*10) / m_physScale, ( 10 +Math.random()*10) / m_physScale);
				}
				else if (Math.random() > 0.5){
					vertexCount = 5;
// 					for ( j = 0; j < vertexCount; ++j )
					for (j in 0...vertexCount)
					{
						vertices[j] = new B2Vec2();
					}
					vertices[0].set(0, (10 +Math.random()*10) / m_physScale);
					vertices[2].set((-5 -Math.random()*10) / m_physScale, (-10 -Math.random()*10) / m_physScale);
					vertices[3].set(( 5 +Math.random()*10) / m_physScale, (-10 -Math.random()*10) / m_physScale);
					vertices[1].set((vertices[0].x + vertices[2].x), (vertices[0].y + vertices[2].y));
					vertices[1].multiply(Math.random()/2+0.8);
					vertices[4].set((vertices[3].x + vertices[0].x), (vertices[3].y + vertices[0].y));
					vertices[4].multiply(Math.random()/2+0.8);
				}
				else{
					vertexCount = 3;
// 					for ( j = 0; j < vertexCount; ++j )
					for (j in 0...vertexCount)
					{
						vertices[j] = new B2Vec2();
					}
					vertices[0].set(0, (10 +Math.random()*10) / m_physScale);
					vertices[1].set((-5 -Math.random()*10) / m_physScale, (-10 -Math.random()*10) / m_physScale);
					vertices[2].set(( 5 +Math.random()*10) / m_physScale, (-10 -Math.random()*10) / m_physScale);
				}
				polyShape.setAsArray( vertices, vertexCount );
				fixtureDef.shape = polyShape;
				fixtureDef.density = 1.0;
				fixtureDef.friction = 0.3;
				fixtureDef.restitution = 0.1;
				bodyDefP.position.set((Math.random() * 400 + 120) / m_physScale, (Math.random() * 150 + 50) / m_physScale);
				bodyDefP.angle = Math.random() * Math.PI;
				body = m_world.createBody(bodyDefP);
				body.createFixture(fixtureDef);
			}
			
		}
		
		
		//======================
		// Member Data 
		//======================
	}
