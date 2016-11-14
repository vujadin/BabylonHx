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
	
	class TestOneSidedPlatform extends Test {
		

		
		public function new(){
			super();
			// Set Text field
// 			Main.m_aboutText.text = "One Sided Platform\n" +
// 				"Press: (c) create a shape, (d) destroy a shape.";
				
			var bd:B2BodyDef;
			var body:B2Body;
			
			// Platform
			{
				bd = new B2BodyDef();
				bd.position.set(10.0, 10.0);
				body = m_world.createBody(bd);
				
				var polygon:B2PolygonShape = B2PolygonShape.asBox(3.0, 0.5);
				m_platform = body.createFixture2(polygon);
				
				m_bottom = bd.position.y + 0.5;
				m_top = bd.position.y - 0.5;
				
			}
			
			// Actor
			{
				bd = new B2BodyDef();
				bd.type = 2;//B2Body.B2_dynamicBody;
				bd.position.set(10.0, 12.0);
				body = m_world.createBody(bd);
				
				m_radius = 0.5;
				var circle:B2CircleShape = new B2CircleShape(m_radius);
				m_character = body.createFixture2(circle, 1.0);
				
				m_state = e_unknown;
			}
			
			m_world.setContactListener(new ContactListenerOneSidePlatform(this));
		}
		
		//======================
		// Member Data 
		//======================
		
		static private var e_unknown:Int = 0;
		static private var e_above:Int = 1;
		static private var e_below:Int = 2;
		
		public var m_radius:Float;
		public var m_top:Float;
		public var m_bottom:Float;
		public var m_state:Int;
		public var m_platform:B2Fixture;
		public var m_character:B2Fixture;
		
	}
