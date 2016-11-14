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


	
	
import box2D.dynamics.controllers.B2BuoyancyController;
import box2D.dynamics.controllers.B2Controller;

import box2D.dynamics.*;
import box2D.collision.*;
import box2D.collision.shapes.*;
import box2D.dynamics.joints.*;
import box2D.dynamics.contacts.*;
import box2D.common.*;
import box2D.common.math.*;
	
	
	
	class TestBuoyancy extends Test{
		
		private var m_bodies:Array<B2Body> = new Array();
		private var m_controller:B2Controller;
		
		public function new(){
			super();
			var bc:B2BuoyancyController = new B2BuoyancyController();
			m_controller = bc;
			
			bc.normal.set(0,-1);
			bc.offset = -200 / m_physScale;
			bc.density = 2.0;
			bc.linearDrag = 5;
			bc.angularDrag = 2;
			
			var ground:B2Body = m_world.getGroundBody();
			var i:Int;
			var anchor:B2Vec2 = new B2Vec2();
			var body:B2Body;
			var fd:B2FixtureDef;
			
			// Spawn in a bunch of crap
			var boxDef:B2PolygonShape = new B2PolygonShape();
			//for (i = 0; i < 5; i++)
			var bodyDef:B2BodyDef = new B2BodyDef();
			for(i in 0...5)
			{

				bodyDef.type = 2;//B2Body.B2_dynamicBody;
				//bodyDef.isBullet = true;
				fd = new B2FixtureDef();
				fd.shape = boxDef;
				fd.density = 1.0;
				// Override the default friction.
				fd.friction = 0.3;
				fd.restitution = 0.1;
				boxDef.setAsBox((Math.random() * 5 + 10) / m_physScale, (Math.random() * 5 + 10) / m_physScale);
				bodyDef.position.set((Math.random() * 400 + 120) / m_physScale, (Math.random() * 150 + 50) / m_physScale);
				bodyDef.angle = Math.random() * Math.PI;
				body = m_world.createBody(bodyDef);
				body.createFixture(fd);
				m_bodies.push(body);
				
			}
				var circDef:B2CircleShape;
			//for (i = 0; i < 5; i++)
			for (i in 0...5)
			{
				var bodyDefC:B2BodyDef = new B2BodyDef();
				bodyDefC.type = 2;//B2Body.B2_dynamicBody;
				//bodyDefC.isBullet = true;
				circDef = new B2CircleShape((Math.random() * 5 + 10) / m_physScale);
				fd = new B2FixtureDef();
				fd.shape = circDef;
				fd.density = 1.0;
				// Override the default friction.
				fd.friction = 0.3;
				fd.restitution = 0.1;
				bodyDefC.position.set((Math.random() * 400 + 120) / m_physScale, (Math.random() * 150 + 50) / m_physScale);
				bodyDefC.angle = Math.random() * Math.PI;
				body = m_world.createBody(bodyDefC);
				body.createFixture(fd);
				m_bodies.push(body);
			}
				var bodyDefP:B2BodyDef;
			//for (i = 0; i < 15; i++)
			for (i in 0...5)
			{
				bodyDefP = new B2BodyDef();
				bodyDefP.type = 2;//B2Body.B2_dynamicBody;
				//bodyDefP.isBullet = true;
				var polyDef:B2PolygonShape = new B2PolygonShape();
				if (Math.random() > 0.66) {
					polyDef.setAsArray([
						new B2Vec2((-10 -Math.random()*10) / m_physScale, ( 10 +Math.random()*10) / m_physScale),
						new B2Vec2(( -5 -Math.random()*10) / m_physScale, (-10 -Math.random()*10) / m_physScale),
						new B2Vec2((  5 +Math.random()*10) / m_physScale, (-10 -Math.random()*10) / m_physScale),
						new B2Vec2(( 10 +Math.random() * 10) / m_physScale, ( 10 +Math.random() * 10) / m_physScale)
						]);
				}
				else if (Math.random() > 0.5) 
				{
					var array:Array<B2Vec2> = [];
					array[0] = new B2Vec2(0, (10 +Math.random()*10) / m_physScale);
					array[2] = new B2Vec2((-5 -Math.random()*10) / m_physScale, (-10 -Math.random()*10) / m_physScale);
					array[3] = new B2Vec2(( 5 +Math.random()*10) / m_physScale, (-10 -Math.random()*10) / m_physScale);
					array[1] = new B2Vec2((array[0].x + array[2].x), (array[0].y + array[2].y));
					array[1].multiply(Math.random()/2+0.8);
					array[4] = new B2Vec2((array[3].x + array[0].x), (array[3].y + array[0].y));
					array[4].multiply(Math.random() / 2 + 0.8);
					polyDef.setAsArray(array);
				}
				else 
				{
					polyDef.setAsArray([
						new B2Vec2(0, (10 +Math.random()*10) / m_physScale),
						new B2Vec2((-5 -Math.random()*10) / m_physScale, (-10 -Math.random()*10) / m_physScale),
						new B2Vec2(( 5 +Math.random() * 10) / m_physScale, ( -10 -Math.random() * 10) / m_physScale)
					]);
				}
				fd = new B2FixtureDef();
				fd.shape = polyDef;
				fd.density = 1.0;
				fd.friction = 0.3;
				fd.restitution = 0.1;
				bodyDefP.position.set((Math.random() * 400 + 120) / m_physScale, (Math.random() * 150 + 50) / m_physScale);
				bodyDefP.angle = Math.random() * Math.PI;
				body = m_world.createBody(bodyDefP);
				body.createFixture(fd);
				m_bodies.push(body);

			}
			
			//Add some exciting bath toys

				
			boxDef.setAsBox(40 / m_physScale, 10 / m_physScale);
			fd = new B2FixtureDef();
			fd.shape = boxDef;
			fd.density = 3.0;
			bodyDef.position.set(50 / m_physScale, 300 / m_physScale);
			bodyDef.angle = 0;
			body = m_world.createBody(bodyDef);
			body.createFixture(fd);
			m_bodies.push(body);
			
			bodyDef.position.set(300/ m_physScale, 300 / m_physScale);
			body = m_world.createBody(bodyDef);
			circDef = new B2CircleShape(7 / m_physScale);
			fd = new B2FixtureDef();
			fd.shape = circDef;
			fd.density =2;

// 			circDef.B2internal:m_p.set(30 / m_physScale, 0 / m_physScale);
			circDef.setLocalPosition(new B2Vec2(30 / m_physScale, 0 / m_physScale));
			body.createFixture(fd);
			
//  			circDef.B2internal::m_p.set(-30 / m_physScale, 0 / m_physScale);
			circDef.setLocalPosition(new B2Vec2(-30 / m_physScale, 0 / m_physScale));
			body.createFixture(fd);
// 			circDef.B2internal::m_p.set(0 / m_physScale, 30 / m_physScale);
			circDef.setLocalPosition(new B2Vec2(0 / m_physScale, 30 / m_physScale));
			body.createFixture(fd);
// 			circDef.B2internal::m_p.set(0 / m_physScale, -30 / m_physScale);
			circDef.setLocalPosition(new B2Vec2(0 / m_physScale, -30 / m_physScale));
				body.createFixture(fd);
			
			fd = new B2FixtureDef();
			fd.shape = boxDef;
			fd.density = 2.0;
			boxDef.setAsBox(30 / m_physScale, 2 / m_physScale);
			body.createFixture(fd);
			fd.density = 2.0;
			boxDef.setAsBox(2 / m_physScale, 30 / m_physScale);
			body.createFixture(fd);
			m_bodies.push(body);

			for(body in m_bodies){
				m_controller.addBody(body);
			}
			
			m_world.addController(m_controller);
			
			// Set Text field
// 			Main.m_aboutText.text = "Buoyancy";
			
		}
		
		
		
		//======================
		// Member Data 
		//======================
		
		public override function Update():Void{
			
			super.Update();
			//Draw water line
			m_sprite.graphics.lineStyle(1,0x0000ff,1);
			m_sprite.graphics.moveTo(5,200);
			m_sprite.graphics.lineTo(635,200);
			//It's not water without transparency...
			m_sprite.graphics.lineStyle(1, 0xff0000);
			m_sprite.graphics.beginFill(0x0000ff,0.2);
			m_sprite.graphics.moveTo(5,200);
			m_sprite.graphics.lineTo(635,200);
			m_sprite.graphics.lineTo(635,355);
			m_sprite.graphics.lineTo(5,355);
			m_sprite.graphics.endFill();

		}
	}
	
