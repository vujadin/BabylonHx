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

class ContactListenerBreakable extends B2ContactListener
{
	private var test:TestBreakable;
	public function new(test:TestBreakable)
	{
		super();
		this.test = test;
	}
	
	override public function postSolve(contact:B2Contact, impulse:B2ContactImpulse):Void 
	{
		if (test.m_broke)
		{
			// The body already broke
			return;
		}
		
		// Should the body break?
		var count:Int = contact.getManifold().m_pointCount;
		
		var maxImpulse:Float = 0.0;
// 		for (var i:int = 0; i < count; i++)
		for(i in 0...count)
		{
			maxImpulse = B2Math.max(maxImpulse, impulse.normalImpulses[i]);
		}
		
		if (maxImpulse > 50)
		{
			test.m_break = true;
		}
	}
}