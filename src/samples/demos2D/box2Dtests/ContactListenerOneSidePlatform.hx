package samples.demos2D.box2Dtests;

import box2D.dynamics.*;
import box2D.collision.*;
import box2D.collision.shapes.*;
import box2D.dynamics.joints.*;
import box2D.dynamics.contacts.*;
import box2D.common.*;
import box2D.common.math.*;


class ContactListenerOneSidePlatform extends B2ContactListener
{
	private var test:TestOneSidedPlatform;
	public function new(test:TestOneSidedPlatform)
	{
		super();
		this.test = test;
	}
	override public function preSolve(contact:B2Contact, oldManifold:B2Manifold):Void 
	{
		var fixtureA:B2Fixture = contact.getFixtureA();
		var fixtureB:B2Fixture = contact.getFixtureB();
		if (fixtureA != test.m_platform && fixtureA != test.m_character)
			return;
		if (fixtureB != test.m_platform && fixtureB != test.m_character)
			return;
			
		var position:B2Vec2 = test.m_character.getBody().getPosition();
		if (position.y > test.m_top)
			contact.setEnabled(false);
	}
}