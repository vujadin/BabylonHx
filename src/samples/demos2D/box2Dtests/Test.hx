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
	
	
	
 class Test {
		
	 
		var m_physScale = 30;
	 	var m_sprite = Global.world_sprite;
	 	
		public function new(){
			
// 			m_sprite = Main.m_sprite;
			
			var worldAABB:B2AABB = new B2AABB();
			worldAABB.lowerBound.set(-1000.0, -1000.0);
			worldAABB.upperBound.set(1000.0, 1000.0);
			
			// Define the gravity vector
			var gravity:B2Vec2 = new B2Vec2(0.0, 10.0);
			
			// Allow bodies to sleep
			var doSleep:Bool = true;
			
			// Construct a world object
			m_world = new B2World(gravity, doSleep);
			//m_world.setBroadPhase(new B2BroadPhase(worldAABB));
			m_world.setWarmStarting(true);
			// set debug draw
			var dbgDraw:B2DebugDraw = new B2DebugDraw();
			var dbgSprite:Sprite = new Sprite();
			m_sprite.addChild(dbgSprite);
			dbgDraw.setSprite(m_sprite);
			dbgDraw.setDrawScale(30.0);
			dbgDraw.setFillAlpha(0.3);
			dbgDraw.setLineThickness(1.0);
			dbgDraw.setFlags(B2DebugDraw.e_shapeBit | B2DebugDraw.e_jointBit);
			m_world.setDebugDraw(dbgDraw);
			
			// Create border of boxes
			var wall:B2PolygonShape= new B2PolygonShape();
			var wallBd:B2BodyDef = new B2BodyDef();
			var wallB:B2Body;
			
			// Left
			wallBd.position.set( -95 / m_physScale, 360 / m_physScale / 2);
			wall.setAsBox(100/m_physScale, 400/m_physScale/2);
			wallB = m_world.createBody(wallBd);
			wallB.createFixture2(wall);
			// Right
			wallBd.position.set((640 + 95) / m_physScale, 360 / m_physScale / 2);
			wallB = m_world.createBody(wallBd);
			wallB.createFixture2(wall);
			// Top
			wallBd.position.set(640 / m_physScale / 2, -95 / m_physScale);
			wall.setAsBox(680/m_physScale/2, 100/m_physScale);
			wallB = m_world.createBody(wallBd);
			wallB.createFixture2(wall);
			// Bottom
			wallBd.position.set(640 / m_physScale / 2, (360 + 95) / m_physScale);
			wallB = m_world.createBody(wallBd);
			wallB.createFixture2(wall);
		}
		
		
		public function Update():Void {
			// Update mouse joint
			UpdateMouseWorld();
			MouseDestroy();
			MouseDrag();
			
			// Update physics
			m_world.step(m_timeStep, m_velocityIterations, m_positionIterations);
			m_world.clearForces();
			
// 			Main.m_fpsCounter.updatePhys(physStart);
			
			// Render
			m_world.drawDebugData();
			// joints
			/*for (var jj:B2Joint = m_world.m_jointList; jj; jj = jj.m_next){
				//DrawJoint(jj);
			}
			// bodies
			for (var bb:B2Body = m_world.m_bodyList; bb; bb = bb.m_next){
				for (var s:B2Shape = bb.GetShapeList(); s != null; s = s.GetNext()){
					//DrawShape(s);
				}
			}*/
			
			//DrawPairs();
			//DrawBounds();
			
		}
		
		
		//======================
		// Member Data 
		//======================
		public var m_world:B2World;
		public var m_bomb:B2Body;
		public var m_mouseJoint:B2MouseJoint;
		public var m_velocityIterations:Int = 10;
		public var m_positionIterations:Int = 10;
		public var m_timeStep:Float = 1.0/30.0;
// 		public var m_physScale:Float = 30;
		// world mouse position
		static public var mouseXWorldPhys:Float;
		static public var mouseYWorldPhys:Float;
		static public var mouseXWorld:Float;
		static public var mouseYWorld:Float;
		// Sprite to draw in to
// 		public var m_sprite:Sprite;
		
		
		
		//======================
		// Update mouseWorld
		//======================
		public function UpdateMouseWorld():Void{
			mouseXWorldPhys = (Input.mouseX)/m_physScale; 
			mouseYWorldPhys = (Input.mouseY)/m_physScale; 
			
			mouseXWorld = (Input.mouseX); 
			mouseYWorld = (Input.mouseY); 
		}
		
		
		
		//======================
		// Mouse Drag 
		//======================
		public function MouseDrag():Void{
			// mouse press
			if (Input.mouseDown && m_mouseJoint==null){
				
				var body:B2Body = GetBodyAtMouse();
				
				if (body!=null)
				{
					var md:B2MouseJointDef = new B2MouseJointDef();
					md.bodyA = m_world.getGroundBody();
					md.bodyB = body;
					md.target.set(mouseXWorldPhys, mouseYWorldPhys);
					md.collideConnected = true;
					md.maxForce = 300.0 * body.getMass();
					m_mouseJoint = cast(m_world.createJoint(md), B2MouseJoint);
					body.setAwake(true);
				}
			}
			
			
			// mouse release
			if (!Input.mouseDown){
				if (m_mouseJoint!=null)
				{
					m_world.destroyJoint(m_mouseJoint);
					m_mouseJoint = null;
				}
			}
			
			
			// mouse move
			if (m_mouseJoint!=null)
			{
				var p2:B2Vec2 = new B2Vec2(mouseXWorldPhys, mouseYWorldPhys);
				m_mouseJoint.setTarget(p2);
			}
		}
		
		
		
		//======================
		// Mouse Destroy
		//======================
		public function MouseDestroy():Void{
			// mouse press
			if (!Input.mouseDown && Input.isKeyPressed(68/*D*/)){
				
				var body:B2Body = GetBodyAtMouse(true);
				
				if (body!=null)
				{
					m_world.destroyBody(body);
					return;
				}
			}
		}
		
		
		
		//======================
		// GetBodyAtMouse
		//======================
		private var mousePVec:B2Vec2 = new B2Vec2();
		public function GetBodyAtMouse(includeStatic:Bool = false):B2Body {
			// Make a small box.
			mousePVec.set(mouseXWorldPhys, mouseYWorldPhys);
			var aabb:B2AABB = new B2AABB();
			aabb.lowerBound.set(mouseXWorldPhys - 0.001, mouseYWorldPhys - 0.001);
			aabb.upperBound.set(mouseXWorldPhys + 0.001, mouseYWorldPhys + 0.001);
			var body:B2Body = null;
			var fixture:B2Fixture;
			
			// Query the world for overlapping shapes.
			function GetBodyCallback(fixture:B2Fixture):Bool
			{
				var shape:B2Shape = fixture.getShape();
				if (fixture.getBody().getType() != 0 || includeStatic)
				{
					var inside:Bool = shape.testPoint(fixture.getBody().getTransform(), mousePVec);
					if (inside)
					{
						body = fixture.getBody();
						return false;
					}
				}
				return true;
			}
			m_world.queryAABB(GetBodyCallback, aabb);
			return body;
		}
		
		
		
		//======================
		// Draw Bounds
		//======================
		/*public function DrawBounds(){
			var b:B2AABB = new B2AABB();
			
			var bp:B2BroadPhase = m_world.m_broadPhase;
			var invQ:B2Vec2 = new B2Vec2();
			invQ.set(1.0 / bp.m_quantizationFactor.x, 1.0 / bp.m_quantizationFactor.y);
			
			for (var i:int = 0; i < B2Settings.B2_maxProxies; ++i)
			{
				var p:B2Proxy = bp.m_proxyPool[ i ];
				if (p.isValid() == false)
				{
					continue;
				}
				
				b.minVertex.x = bp.m_worldAABB.minVertex.x + invQ.x * bp.m_bounds[0][p.lowerBounds[0]].value;
				b.minVertex.y = bp.m_worldAABB.minVertex.y + invQ.y * bp.m_bounds[1][p.lowerBounds[1]].value;
				b.maxVertex.x = bp.m_worldAABB.minVertex.x + invQ.x * bp.m_bounds[0][p.upperBounds[0]].value;
				b.maxVertex.y = bp.m_worldAABB.minVertex.y + invQ.y * bp.m_bounds[1][p.upperBounds[1]].value;
				
				m_sprite.graphics.lineStyle(1,0xff22ff,1);
				m_sprite.graphics.moveTo(b.minVertex.x * m_physScale, b.minVertex.y * m_physScale);
				m_sprite.graphics.lineTo(b.maxVertex.x * m_physScale, b.minVertex.y * m_physScale);
				m_sprite.graphics.lineTo(b.maxVertex.x * m_physScale, b.maxVertex.y * m_physScale);
				m_sprite.graphics.lineTo(b.minVertex.x * m_physScale, b.maxVertex.y * m_physScale);
				m_sprite.graphics.lineTo(b.minVertex.x * m_physScale, b.minVertex.y * m_physScale);
			}
		}
		
		
		//======================
		// Draw Pairs
		//======================
		public function DrawPairs():void{
			
			var bp:B2BroadPhase = m_world.m_broadPhase;
			var invQ:B2Vec2 = new B2Vec2();
			invQ.set(1.0 / bp.m_quantizationFactor.x, 1.0 / bp.m_quantizationFactor.y);
			
			for (var i:int = 0; i < B2Pair.B2_tableCapacity; ++i)
			{
				var index:uint = bp.m_pairManager.m_hashTable[i];
				while (index != B2Pair.B2_nullPair)
				{
					var pair:B2Pair = bp.m_pairManager.m_pairs[ index ];
					var p1:B2Proxy = bp.m_proxyPool[ pair.proxyId1 ];
					var p2:B2Proxy = bp.m_proxyPool[ pair.proxyId2 ];
					
					var b1:B2AABB = new B2AABB();
					var B2:B2AABB = new B2AABB();
					b1.minVertex.x = bp.m_worldAABB.minVertex.x + invQ.x * bp.m_bounds[0][p1.lowerBounds[0]].value;
					b1.minVertex.y = bp.m_worldAABB.minVertex.y + invQ.y * bp.m_bounds[1][p1.lowerBounds[1]].value;
					b1.maxVertex.x = bp.m_worldAABB.minVertex.x + invQ.x * bp.m_bounds[0][p1.upperBounds[0]].value;
					b1.maxVertex.y = bp.m_worldAABB.minVertex.y + invQ.y * bp.m_bounds[1][p1.upperBounds[1]].value;
					B2.minVertex.x = bp.m_worldAABB.minVertex.x + invQ.x * bp.m_bounds[0][p2.lowerBounds[0]].value;
					B2.minVertex.y = bp.m_worldAABB.minVertex.y + invQ.y * bp.m_bounds[1][p2.lowerBounds[1]].value;
					B2.maxVertex.x = bp.m_worldAABB.minVertex.x + invQ.x * bp.m_bounds[0][p2.upperBounds[0]].value;
					B2.maxVertex.y = bp.m_worldAABB.minVertex.y + invQ.y * bp.m_bounds[1][p2.upperBounds[1]].value;
					
					var x1:B2Vec2 = B2Math.MulFV(0.5, B2Math.AddVV(b1.minVertex, b1.maxVertex) );
					var x2:B2Vec2 = B2Math.MulFV(0.5, B2Math.AddVV(B2.minVertex, B2.maxVertex) );
					
					m_sprite.graphics.lineStyle(1,0xff2222,1);
					m_sprite.graphics.moveTo(x1.x * m_physScale, x1.y * m_physScale);
					m_sprite.graphics.lineTo(x2.x * m_physScale, x2.y * m_physScale);
					
					index = pair.next;
				}
			}
		}
		
		//======================
		// Draw Contacts
		//======================
		public function DrawContacts():void{
			for (var c:B2Contact = m_world.m_contactList; c; c = c.m_next)
			{
				var ms:Array = c.GetManifolds();
				for (var i:int = 0; i < c.GetManifoldCount(); ++i)
				{
					var m:B2Manifold = ms[ i ];
					//this.graphics.lineStyle(3,0x11CCff,0.7);
					
					for (var j:int = 0; j < m.pointCount; ++j)
					{	
						m_sprite.graphics.lineStyle(m.points[j].normalImpulse,0x11CCff,0.7);
						var v:B2Vec2 = m.points[j].position;
						m_sprite.graphics.moveTo(v.x * m_physScale, v.y * m_physScale);
						m_sprite.graphics.lineTo(v.x * m_physScale, v.y * m_physScale);
						
					}
				}
			}
		}
		
		
		//======================
		// Draw Shape 
		//======================
		public function DrawShape(shape:B2Shape):void{
			switch (shape.m_type)
			{
			case B2Shape.e_circleShape:
				{
					var circle:B2CircleShape = shape as B2CircleShape;
					var pos:B2Vec2 = circle.m_position;
					var r:Number = circle.m_radius;
					var k_segments:Number = 16.0;
					var k_increment:Number = 2.0 * Math.PI / k_segments;
					m_sprite.graphics.lineStyle(1,0xffffff,1);
					m_sprite.graphics.moveTo((pos.x + r) * m_physScale, (pos.y) * m_physScale);
					var theta:Number = 0.0;
					
					for (var i:int = 0; i < k_segments; ++i)
					{
						var d:B2Vec2 = new B2Vec2(r * Math.cos(theta), r * Math.sin(theta));
						var v:B2Vec2 = B2Math.AddVV(pos , d);
						m_sprite.graphics.lineTo((v.x) * m_physScale, (v.y) * m_physScale);
						theta += k_increment;
					}
					m_sprite.graphics.lineTo((pos.x + r) * m_physScale, (pos.y) * m_physScale);
					
					m_sprite.graphics.moveTo((pos.x) * m_physScale, (pos.y) * m_physScale);
					var ax:B2Vec2 = circle.m_R.col1;
					var pos2:B2Vec2 = new B2Vec2(pos.x + r * ax.x, pos.y + r * ax.y);
					m_sprite.graphics.lineTo((pos2.x) * m_physScale, (pos2.y) * m_physScale);
				}
				break;
			case B2Shape.e_polyShape:
				{
					var poly:B2PolyShape = shape as B2PolyShape;
					var tV:B2Vec2 = B2Math.AddVV(poly.m_position, B2Math.B2MulMV(poly.m_R, poly.m_vertices[i]));
					m_sprite.graphics.lineStyle(1,0xffffff,1);
					m_sprite.graphics.moveTo(tV.x * m_physScale, tV.y * m_physScale);
					
					for (i = 0; i < poly.m_vertexCount; ++i)
					{
						v = B2Math.AddVV(poly.m_position, B2Math.B2MulMV(poly.m_R, poly.m_vertices[i]));
						m_sprite.graphics.lineTo(v.x * m_physScale, v.y * m_physScale);
					}
					m_sprite.graphics.lineTo(tV.x * m_physScale, tV.y * m_physScale);
				}
				break;
			}
		}
		
		
		//======================
		// Draw Joint 
		//======================
		public function DrawJoint(joint:B2Joint):void
		{
			var b1:B2Body = joint.m_body1;
			var B2:B2Body = joint.m_body2;
			
			var x1:B2Vec2 = b1.m_position;
			var x2:B2Vec2 = B2.m_position;
			var p1:B2Vec2 = joint.GetAnchor1();
			var p2:B2Vec2 = joint.GetAnchor2();
			
			m_sprite.graphics.lineStyle(1,0x44aaff,1/1);
			
			switch (joint.m_type)
			{
			case B2Joint.e_distanceJoint:
			case B2Joint.e_mouseJoint:
				m_sprite.graphics.moveTo(p1.x * m_physScale, p1.y * m_physScale);
				m_sprite.graphics.lineTo(p2.x * m_physScale, p2.y * m_physScale);
				break;
				
			case B2Joint.e_pulleyJoint:
				var pulley:B2PulleyJoint = joint as B2PulleyJoint;
				var s1:B2Vec2 = pulley.GetGroundPoint1();
				var s2:B2Vec2 = pulley.GetGroundPoint2();
				m_sprite.graphics.moveTo(s1.x * m_physScale, s1.y * m_physScale);
				m_sprite.graphics.lineTo(p1.x * m_physScale, p1.y * m_physScale);
				m_sprite.graphics.moveTo(s2.x * m_physScale, s2.y * m_physScale);
				m_sprite.graphics.lineTo(p2.x * m_physScale, p2.y * m_physScale);
				break;
				
			default:
				if (b1 == m_world.m_groundBody){
					m_sprite.graphics.moveTo(p1.x * m_physScale, p1.y * m_physScale);
					m_sprite.graphics.lineTo(x2.x * m_physScale, x2.y * m_physScale);
				}
				else if (B2 == m_world.m_groundBody){
					m_sprite.graphics.moveTo(p1.x * m_physScale, p1.y * m_physScale);
					m_sprite.graphics.lineTo(x1.x * m_physScale, x1.y * m_physScale);
				}
				else{
					m_sprite.graphics.moveTo(x1.x * m_physScale, x1.y * m_physScale);
					m_sprite.graphics.lineTo(p1.x * m_physScale, p1.y * m_physScale);
					m_sprite.graphics.lineTo(x2.x * m_physScale, x2.y * m_physScale);
					m_sprite.graphics.lineTo(p2.x * m_physScale, p2.y * m_physScale);
				}
			}
		}*/
	}