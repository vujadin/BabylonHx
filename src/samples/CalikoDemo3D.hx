package samples;

import com.babylonhx.Scene;

import calikohx.utils.Vec3f;
import calikohx.utils.Colour4f;
import calikohx.utils.Utils;
import calikohx.FabrikStructure3D;
import calikohx.FabrikChain3D;
import calikohx.FabrikChain3D.BaseboneConstraintType3D;
import calikohx.FabrikBone3D;
import calikohx.FabrikBone3D.BoneConnectionPoint3D;
import calikohx.FabrikJoint3D;
import calikohx.FabrikJoint3D.JointType;


/**
 * ...
 * @author Krtolica Vujadin
 */
class CalikoDemo3D {

	// Define cardinal axes
	static var X_AXIS:Vec3f = new Vec3f(1.0, 0.0, 0.0);
	static var Y_AXIS:Vec3f = new Vec3f(0.0, 1.0, 0.0);
	static var Z_AXIS:Vec3f = new Vec3f(0.0, 0.0, 1.0);
	
	// Defaults
	// Note: Bone initial directions will be going 'into' the screen along the -Z axis
	static var defaultBoneDirection:Vec3f   = Vec3f.clone(Z_AXIS).negated();
	static var defaultBoneLength:Float      = 10.0;
	static var boneLineWidth:Float          = 5.0;
	static var constraintLineWidth:Float    = 2.0;	
	static var baseRotationAmountDegs:Float = 0.3;
	
	public static var mStructure:FabrikStructure3D;
		
	/**
	 * Constructor.
	 * 
	 * @param	demoNumber	The number of the demo to set up.
	 */
	public function new(scene:Scene) { 
		setup(1); 
	}
	
	/**
	 * Set up a demo consisting of an arrangement of 3D IK chains with a given configuration.
	 * 
	 * @param	demoNumber	The number of the demo to set up.
	 */
	public function setup(demoNumber:Int) {
		var demoName:String = "";
		
		switch (demoNumber) {
			case 1: 
				demoName            = "Demo 1 - Unconstrained bones";
				mStructure          = new FabrikStructure3D(demoName);
				var boneColour:Colour4f = Colour4f.copy(Utils.GREEN);
				
				// Create a new chain...				
				var chain = new FabrikChain3D();
					
				// ...then create a basebone, set its draw colour and add it to the chain.
				var startLoc        = new Vec3f(0.0, 0.0, 40.0);
				var endLoc          = startLoc.plus(defaultBoneDirection.timesScalar(defaultBoneLength));
				var basebone = FabrikBone3D.create1(startLoc, endLoc);
				basebone.setColour(boneColour);
				chain.addBone(basebone);
				
				// Add additional consecutive, unconstrained bones to the chain				
				for (boneLoop in 0...7) {
					boneColour = (boneLoop % 2 == 0) ? boneColour.lighten(0.4) : boneColour.darken(0.4);
					chain.addConsecutiveBone2(defaultBoneDirection, defaultBoneLength, boneColour);
				}
				
				// Finally, add the chain to the structure
				mStructure.addChain(chain);					
				
			case 2: 
				demoName                  = "Demo 2 - Rotor / Ball Joint Constrained Bones";
				mStructure                = new FabrikStructure3D(demoName);
				var numChains             = 3;
				var rotStep             = 360.0 / numChains;
				var constraintAngleDegs = 45.0;
				var boneColour       = new Colour4f();
				
				for (chainLoop in 0...numChains) {
					// Create a new chain
					var chain = new FabrikChain3D();
					
					// Choose the bone colour
					switch (chainLoop % numChains) {
						case 0:	boneColour.setFrom(Utils.MID_RED);   
						case 1:	boneColour.setFrom(Utils.MID_GREEN); 
						case 2:	boneColour.setFrom(Utils.MID_BLUE);  
					}
					
					// Set up the initial base bone location...
					var startLoc = new Vec3f(0.0, 0.0, -40.0);
					startLoc       = Vec3f.rotateYDegs(startLoc, rotStep * chainLoop);
					var endLoc   = Vec3f.clone(startLoc);
					endLoc.z      -= defaultBoneLength;
					
					// ...then create a base bone, set its colour and add it to the chain.
					var basebone = FabrikBone3D.create1(startLoc, endLoc);
					basebone.setColour(boneColour);					
					chain.addBone(basebone);
					
					// Add additional consecutive rotor (i.e. ball joint) constrained bones to the chain					
					for (boneLoop in 0...7) {
						boneColour = (boneLoop % 2 == 0) ? boneColour.lighten(0.4) : boneColour.darken(0.4);						
						chain.addConsecutiveRotorConstrainedBone(defaultBoneDirection, defaultBoneLength, constraintAngleDegs, boneColour);	
					}
					
					// Finally, add the chain to the structure
					mStructure.addChain(chain);					
				}		
			
			case 3:	
				demoName                          = "Demo 3 - Rotor Constrained Base Bones";
				mStructure                        = new FabrikStructure3D(demoName);
				var numChains                     = 3;
				var rotStep                      = 360.0 / numChains;
				var baseBoneConstraintAngleDegs  = 20.0;
				
				// ... and add multiple chains to it.
				var boneColour          = new Colour4f();
				var baseBoneColour      = new Colour4f();					
				var baseBoneConstraintAxis = new Vec3f();
				for (chainLoop in 0...numChains) {					
					// Choose the bone colours and base bone constraint axes
					switch (chainLoop % 3) {
						case 0:
							boneColour.setFrom(Utils.MID_RED);
							baseBoneColour.setFrom(Utils.RED);
							baseBoneConstraintAxis = X_AXIS;
							
						case 1:
							boneColour.setFrom(Utils.MID_GREEN);
							baseBoneColour.setFrom(Utils.MID_GREEN);
							baseBoneConstraintAxis = Y_AXIS;
							
						case 2:
							boneColour.setFrom(Utils.MID_BLUE);
							baseBoneColour.setFrom(Utils.BLUE);
							baseBoneConstraintAxis = Z_AXIS.negated();
							
					}
					
					// Create a new chain
					var chain = new FabrikChain3D();
					
					// Set up the initial base bone location...
					var startLoc = new Vec3f(0.0, 0.0, -40.0);
					startLoc       = Vec3f.rotateYDegs(startLoc, rotStep * chainLoop);					
					var endLoc     = startLoc.plus(baseBoneConstraintAxis.timesScalar(defaultBoneLength * 2.0));
					
					// ...then create a base bone, set its colour, add it to the chain and specify that it should be global rotor constrained.
					var basebone = FabrikBone3D.create1(startLoc, endLoc);
					basebone.setColour(baseBoneColour);					
					chain.addBone(basebone);
					chain.setRotorBaseboneConstraint(BaseboneConstraintType3D.GLOBAL_ROTOR, baseBoneConstraintAxis, baseBoneConstraintAngleDegs);
					
					// Add additional consecutive, unconstrained bones to the chain
					for (boneLoop in 0...7) {	
						boneColour = (boneLoop % 2 == 0) ? boneColour.lighten(0.5) : boneColour.darken(0.5);
						chain.addConsecutiveBone2(defaultBoneDirection, defaultBoneLength, boneColour);
					}
					
					// Finally, add the chain to the structure
					mStructure.addChain(chain);
				}	
				
			case 4:	
				demoName      = "Demo 4 - Freely Rotating Global Hinges";
				mStructure    = new FabrikStructure3D(demoName);
				var numChains = 3;
				var rotStep = 360.0 / numChains;
				
				// We'll create a circular arrangement of 3 chains which are each constrained about different global axes.
				// Note: Although I've used the cardinal X/Y/Z axes here, any axis can be used.
				var globalHingeAxis = new Vec3f();
				for (chainLoop in 0...numChains) {	
					// Set colour and axes							
					var chainColour = new Colour4f();
					switch (chainLoop % numChains) {
						case 0:
							chainColour.setFrom(Utils.RED);
							globalHingeAxis = X_AXIS;
							
						case 1:
							chainColour.setFrom(Utils.GREEN);
							globalHingeAxis = Y_AXIS;
							
						case 2:
							chainColour.setFrom(Utils.BLUE);
							globalHingeAxis = Z_AXIS;
							
					}
					
					// Create a new chain
					var chain = new FabrikChain3D();
					
					// Set up the initial base bone location...
					var startLoc = new Vec3f(0.0, 0.0, -40.0);
					startLoc     = Vec3f.rotateYDegs(startLoc, rotStep * chainLoop);
					var endLoc   = startLoc.plus(defaultBoneDirection.timesScalar(defaultBoneLength));
					
					// ...then create a base bone, set its colour, and add it to the chain.
					var basebone = FabrikBone3D.create1(startLoc, endLoc);
					basebone.setColour(chainColour);
					chain.addBone(basebone);
					
					// Add alternating global hinge constrained and unconstrained bones to the chain
					for (boneLoop in 0...7) {
						if (boneLoop % 2 == 0) {
							chain.addConsecutiveFreelyRotatingHingedBone2(defaultBoneDirection, defaultBoneLength, JointType.GLOBAL_HINGE, globalHingeAxis, Utils.GREY);
						}
						else {
							chain.addConsecutiveBone2(defaultBoneDirection, defaultBoneLength, chainColour);
						}						
					}
					
					// Finally, add the chain to the structure
					mStructure.addChain(chain);					
				}		
				
			case 5:	
				demoName   = "Demo 5 - Global Hinges With Reference Axis Constraints";
				mStructure = new FabrikStructure3D(demoName);
				
				// Create a new chain				
				var chain = new FabrikChain3D();
				
				// Set up the initial base bone location...
				var startLoc = new Vec3f(0.0, 30, -40.0);
				var endLoc   = Vec3f.clone(startLoc);
				endLoc.y    -= defaultBoneLength;
				
				// ...then create a base bone, set its colour, and add it to the chain.
				var basebone = FabrikBone3D.create1(startLoc, endLoc);
				basebone.setColour(Utils.YELLOW);
				chain.addBone(basebone);
				
				// Add alternating global hinge constrained and unconstrained bones to the chain
				var cwDegs  = 120.0;
				var acwDegs = 120.0;
				for (boneLoop in 0...8) {
					if (boneLoop % 2 == 0) {
						// Params: bone direction, bone length, joint type, hinge rotation axis, clockwise constraint angle, anticlockwise constraint angle, hinge constraint reference axis, colour
						// Note: There is a version of this method where you do not specify the colour - the default is to draw the bone in white.
						chain.addConsecutiveHingedBone(Y_AXIS.negated(), defaultBoneLength, JointType.GLOBAL_HINGE, Z_AXIS, cwDegs, acwDegs, Y_AXIS.negated(), Utils.GREY);
					}
					else {
						chain.addConsecutiveBone2(Y_AXIS.negated(), defaultBoneLength, Utils.MID_GREEN);
					}
				}
				
				// Finally, add the chain to the structure
				mStructure.addChain(chain);	
				
			case 6: 
				demoName      = "Demo 6 - Freely Rotating Local Hinges";
				mStructure    = new FabrikStructure3D(demoName);
				var numChains = 3;
				
				// We'll create a circular arrangement of 3 chains with alternate bones each constrained about different local axes.
				// Note: Local hinge rotation axes are relative to the rotation matrix of the previous bone in the chain.
				var hingeRotationAxis  = new Vec3f();
				
				var rotStep = 360.0 / numChains;
				for (loop in 0...numChains) {	
					// Set colour and axes							
					var chainColour = new Colour4f();
					switch (loop % 3) {
						case 0:
							chainColour = Utils.RED;
							hingeRotationAxis  = Vec3f.clone(X_AXIS);
							
						case 1:
							chainColour = Utils.GREEN;
							hingeRotationAxis = Vec3f.clone(Y_AXIS);
							
						case 2:
							chainColour = Utils.BLUE;
							hingeRotationAxis = Vec3f.clone(Z_AXIS);
							
					}
					
					// Create a new chain
					var chain = new FabrikChain3D();
					
					// Set up the initial base bone location...
					var startLoc = new Vec3f(0.0, 0.0, -40.0);
					startLoc       = Vec3f.rotateYDegs(startLoc, rotStep * loop);					
					var endLoc   = startLoc.plus(defaultBoneDirection.timesScalar(defaultBoneLength) );
					
					// ...then create a base bone, set its colour, and add it to the chain.
					var basebone = FabrikBone3D.create1(startLoc, endLoc);
					basebone.setColour(chainColour);
					chain.addBone(basebone);
					
					// Add alternating local hinge constrained and unconstrained bones to the chain
					for (boneLoop in 0...6) {
						if (boneLoop % 2 == 0) {
							chain.addConsecutiveFreelyRotatingHingedBone2(defaultBoneDirection, defaultBoneLength, JointType.LOCAL_HINGE, hingeRotationAxis, Utils.GREY);
						}
						else {
							chain.addConsecutiveBone2(defaultBoneDirection, defaultBoneLength, chainColour);
						}
					}
					
					// Finally, add the chain to the structure
					mStructure.addChain(chain);	
				}
				
			case 7: 
				demoName      = "Demo 7 - Local Hinges with Reference Axis Constraints";
				mStructure    = new FabrikStructure3D(demoName);
				var numChains = 3;
				
				// We'll create a circular arrangement of 3 chains with alternate bones each constrained about different local axes.
				// Note: Local hinge rotation axes are relative to the rotation matrix of the previous bone in the chain.
				var hingeRotationAxis  = new Vec3f();
				var hingeReferenceAxis = new Vec3f();
				
				var rotStep = 360.0 / numChains;
				for (loop in 0...numChains) {	
					// Set colour and axes							
					var chainColour = new Colour4f();
					switch (loop % 3) {
						case 0:
							chainColour        = Utils.RED;
							hingeRotationAxis  = Vec3f.clone(X_AXIS);
							hingeReferenceAxis = Vec3f.clone(Y_AXIS);
							
						case 1:
							chainColour        = Utils.GREEN;
							hingeRotationAxis  = Vec3f.clone(Y_AXIS);
							hingeReferenceAxis = Vec3f.clone(X_AXIS);
							
						case 2:
							chainColour        = Utils.BLUE;
							hingeRotationAxis  = Vec3f.clone(Z_AXIS);
							hingeReferenceAxis = Vec3f.clone(Y_AXIS);
							
					}
					
					// Create a new chain
					var chain = new FabrikChain3D();
					
					// Set up the initial base bone location...
					var startLoc = new Vec3f(0.0, 0.0, -40.0);
					startLoc     = Vec3f.rotateYDegs(startLoc, rotStep * loop);					
					var endLoc   = startLoc.plus(defaultBoneDirection.timesScalar(defaultBoneLength));
					
					// ...then create a base bone, set its colour, and add it to the chain.
					var basebone = FabrikBone3D.create1(startLoc, endLoc);
					basebone.setColour(chainColour);
					chain.addBone(basebone);
					
					// Add alternating local hinge constrained and unconstrained bones to the chain
					var constraintAngleDegs = 90.0;
					for (boneLoop in 0...6) {
						if (boneLoop % 2 == 0) {
							chain.addConsecutiveHingedBone(defaultBoneDirection, defaultBoneLength, JointType.LOCAL_HINGE, hingeRotationAxis, constraintAngleDegs, constraintAngleDegs, hingeReferenceAxis, Utils.GREY);
						}
						else {
							chain.addConsecutiveBone2(defaultBoneDirection, defaultBoneLength, chainColour);
						}
					}
					
					// Finally, add the chain to the structure
					mStructure.addChain(chain);	
				}
			
			case 8: 
				demoName            = "Demo 8 - Connected Chains";
				mStructure          = new FabrikStructure3D(demoName);
				var boneColour 		= Colour4f.copy(Utils.GREEN);
				
				// Create a new chain...				
				var chain = new FabrikChain3D();
				
				// ...then create a basebone, set its draw colour and add it to the chain.
				var startLoc        = new Vec3f(0.0, 0.0, 40.0);
				var endLoc          = startLoc.plus(defaultBoneDirection.timesScalar(defaultBoneLength));
				var basebone 		= FabrikBone3D.create1(startLoc, endLoc);
				basebone.setColour(boneColour);
				chain.addBone(basebone);
				
				// Add additional consecutive, unconstrained bones to the chain				
				for (boneLoop in 0...5) {
					boneColour = (boneLoop % 2 == 0) ? boneColour.lighten(0.4) : boneColour.darken(0.4);
					chain.addConsecutiveBone2(defaultBoneDirection, defaultBoneLength, boneColour);
				}
				
				// Finally, add the chain to the structure
				mStructure.addChain(chain);		
				
				var secondChain = new FabrikChain3D("Second Chain");
				var base = FabrikBone3D.create1(Vec3f.create0(100.0), Vec3f.create0(110.0));
				secondChain.addBone(base);
				secondChain.addConsecutiveBone(X_AXIS, 20.0);
				secondChain.addConsecutiveBone(Y_AXIS, 20.0);
				secondChain.addConsecutiveBone(Z_AXIS, 20.0);
				
				// Set the colour of all bones in the chain in a single call, then connect it to the chain...
				secondChain.setColour(Utils.RED);
				mStructure.connectChain2(secondChain, 0, 0, BoneConnectionPoint3D.START);
				
				// ...we can keep adding the same chain at various points if we like, because the chain we
				// connect is actually a clone of the one we provide, and not the original 'secondChain' argument.
				secondChain.setColour(Utils.WHITE);
				mStructure.connectChain2(secondChain, 0, 2, BoneConnectionPoint3D.START);
				
				// We can also set connect the chain to the end of a specified bone (this overrides the START/END 
				// setting of the bone we connect to).
				secondChain.setColour(Utils.BLUE);
				mStructure.connectChain2(secondChain, 0, 4, BoneConnectionPoint3D.END);
			
			case 9: 
				demoName            = "Demo 9 - Global Rotor Constrained Connected Chains";
				mStructure          = new FabrikStructure3D(demoName);
				var boneColour 		= Colour4f.copy(Utils.GREEN);
				
				// Create a new chain...				
				var chain = new FabrikChain3D();
				
				// ...then create a basebone, set its draw colour and add it to the chain.
				var startLoc        = new Vec3f(0.0, 0.0, 40.0);
				var endLoc          = startLoc.plus(defaultBoneDirection.timesScalar(defaultBoneLength) );
				var basebone 		= FabrikBone3D.create1(startLoc, endLoc);
				basebone.setColour(boneColour);
				chain.addBone(basebone);
				
				// Add additional consecutive, unconstrained bones to the chain				
				for (boneLoop in 0...7) {
					boneColour = (boneLoop % 2 == 0) ? boneColour.lighten(0.4) : boneColour.darken(0.4);
					chain.addConsecutiveBone2(defaultBoneDirection, defaultBoneLength, boneColour);
				}
				
				// Finally, add the chain to the structure
				mStructure.addChain(chain);					
				
				var secondChain = new FabrikChain3D("Second Chain");
				var base = FabrikBone3D.create1(new Vec3f(), new Vec3f(15.0, 0.0, 0.0));
				secondChain.addBone(base);
				secondChain.setRotorBaseboneConstraint(BaseboneConstraintType3D.GLOBAL_ROTOR, X_AXIS, 45.0);				
				
				secondChain.addConsecutiveBone(X_AXIS, 15.0);
				secondChain.addConsecutiveBone(X_AXIS, 15.0);
				secondChain.addConsecutiveBone(X_AXIS, 15.0);
				secondChain.setColour(Utils.RED);
				
				mStructure.connectChain2(secondChain, 0, 3, BoneConnectionPoint3D.START);
				
				var thirdChain = new FabrikChain3D("Second Chain");
				base = FabrikBone3D.create1(new Vec3f(), new Vec3f(0.0, 15.0, 0.0));
				thirdChain.addBone(base);
				thirdChain.setRotorBaseboneConstraint(BaseboneConstraintType3D.GLOBAL_ROTOR, Y_AXIS, 45.0);
				
				thirdChain.addConsecutiveBone(Y_AXIS, 15.0);
				thirdChain.addConsecutiveBone(Y_AXIS, 15.0);
				thirdChain.addConsecutiveBone(Y_AXIS, 15.0);
				thirdChain.setColour(Utils.BLUE);
				
				mStructure.connectChain2(thirdChain, 0, 6, BoneConnectionPoint3D.START);
				
			case 10: 
				demoName            = "Demo 10 - Local Rotor Constrained Connected Chains";
				mStructure          = new FabrikStructure3D(demoName);
				var boneColour 	    = Colour4f.copy(Utils.GREEN);
				
				// Create a new chain...				
				var chain = new FabrikChain3D();
				
				// ...then create a basebone, set its draw colour and add it to the chain.
				var startLoc        = new Vec3f(0.0, 0.0, 40.0);
				var endLoc          = startLoc.plus(defaultBoneDirection.timesScalar(defaultBoneLength));
				var basebone 		= FabrikBone3D.create1(startLoc, endLoc);
				basebone.setColour(boneColour);
				chain.addBone(basebone);
				
				// Add additional consecutive, unconstrained bones to the chain				
				for (boneLoop in 0...7) {
					boneColour = (boneLoop % 2 == 0) ? boneColour.lighten(0.4) : boneColour.darken(0.4);
					chain.addConsecutiveBone2(defaultBoneDirection, defaultBoneLength, boneColour);
				}
				
				// Finally, add the chain to the structure
				mStructure.addChain(chain);		
				
				// Create a second chain which will have a relative (i.e. local) rotor basebone constraint about the X axis.
				var secondChain = new FabrikChain3D("Second Chain");
				basebone = FabrikBone3D.create1(new Vec3f(), new Vec3f(15.0, 0.0, 0.0));
				secondChain.addBone(basebone);
				secondChain.setRotorBaseboneConstraint(BaseboneConstraintType3D.LOCAL_ROTOR, X_AXIS, 45.0);				
				
				// Add some additional bones
				secondChain.addConsecutiveBone(X_AXIS, 15.0);
				secondChain.addConsecutiveBone(X_AXIS, 15.0);
				secondChain.addConsecutiveBone(X_AXIS, 15.0);
				secondChain.setColour(Utils.RED);
				
				// Connect this second chain to the start point of bone 3 in chain 0 of the structure
				mStructure.connectChain2(secondChain, 0, 3, BoneConnectionPoint3D.START);
			
			case 11: 
				demoName            = "Demo 11 - Connected Chains with Freely-Rotating Global Hinged Basebone Constraints";
				mStructure          = new FabrikStructure3D(demoName);
				var boneColour 		= Colour4f.copy(Utils.GREEN);
				
				// Create a new chain...				
				var chain = new FabrikChain3D();
				
				// ...then create a basebone, set its draw colour and add it to the chain.
				var startLoc        = new Vec3f(0.0, 0.0, 40.0);
				var endLoc          = startLoc.plus(defaultBoneDirection.timesScalar(defaultBoneLength) );
				var basebone 		= FabrikBone3D.create1(startLoc, endLoc);
				basebone.setColour(boneColour);
				chain.addBone(basebone);
				
				// Add additional consecutive, unconstrained bones to the chain				
				for (boneLoop in 0...7) {
					boneColour = (boneLoop % 2 == 0) ? boneColour.lighten(0.4) : boneColour.darken(0.4);
					chain.addConsecutiveBone2(defaultBoneDirection, defaultBoneLength, boneColour);
				}
				
				// Finally, add the chain to the structure
				mStructure.addChain(chain);		
				
				// Create a second chain which will have a relative (i.e. local) rotor basebone constraint about the X axis.
				var secondChain = new FabrikChain3D("Second Chain");
				var base = FabrikBone3D.create1(new Vec3f(), new Vec3f(15.0, 0.0, 0.0));
				secondChain.addBone(base);
				
				// Set this second chain to have a freely rotating global hinge which rotates about the Y axis
				// Note: We MUST add the basebone to the chain before we can set the basebone constraint on it.
				secondChain.setFreelyRotatingGlobalHingedBasebone(Y_AXIS);				
				
				// Add some additional bones
				secondChain.addConsecutiveBone(X_AXIS, 15.0);
				secondChain.addConsecutiveBone(X_AXIS, 15.0);
				secondChain.addConsecutiveBone(X_AXIS, 15.0);
				secondChain.setColour(Utils.GREY);
				
				// Connect this second chain to the start point of bone 3 in chain 0 of the structure
				mStructure.connectChain2(secondChain, 0, 3, BoneConnectionPoint3D.START);
			
			case 12: 
				demoName            = "Demo 12 - Connected Chains with Non-Freely-Rotating Global Hinge Basebone Constraints";
				mStructure          = new FabrikStructure3D(demoName);
				var boneColour 		= Colour4f.copy(Utils.GREEN);
				
				// Create a new chain...				
				var chain = new FabrikChain3D();
				
				// ...then create a basebone, set its draw colour and add it to the chain.
				var startLoc        = new Vec3f(0.0, 0.0, 40.0);
				var endLoc          = startLoc.plus(defaultBoneDirection.timesScalar(defaultBoneLength));
				var basebone 		= FabrikBone3D.create1(startLoc, endLoc);
				basebone.setColour(boneColour);
				chain.addBone(basebone);
				
				// Add additional consecutive, unconstrained bones to the chain				
				for (boneLoop in 0...7) {
					boneColour = (boneLoop % 2 == 0) ? boneColour.lighten(0.4) : boneColour.darken(0.4);
					chain.addConsecutiveBone2(defaultBoneDirection, defaultBoneLength, boneColour);
				}
				
				// Finally, add the chain to the structure
				mStructure.addChain(chain);		
				
				// Create a second chain which will have a relative (i.e. local) rotor basebone constraint about the X axis.
				var secondChain = new FabrikChain3D("Second Chain");
				var base 		= FabrikBone3D.create1(new Vec3f(), new Vec3f(15.0, 0.0, 0.0));
				secondChain.addBone(base);
				
				// Set this second chain to have a freely rotating global hinge which rotates about the Y axis
				// Note: We MUST add the basebone to the chain before we can set the basebone constraint on it.				
				secondChain.setHingeBaseboneConstraint(BaseboneConstraintType3D.GLOBAL_HINGE, Y_AXIS, 90.0, 45.0, X_AXIS);
				
				/** Other potential options for basebone constraint types **/
				//secondChain.setFreelyRotatingGlobalHingedBasebone(Y_AXIS);
				//secondChain.setFreelyRotatingLocalHingedBasebone(Y_AXIS);
				//secondChain.setHingeBaseboneConstraint(BaseboneConstraintType3D.GLOBAL_HINGE, Y_AXIS, 90.0f, 45.0f, X_AXIS);
				//secondChain.setRotorBaseboneConstraint(BaseboneConstraintType3D.GLOBAL_ROTOR, Z_AXIS, 30.0f, 60.0f, Y_AXIS);
				//secondChain.setRotorBaseboneConstraint(BaseboneConstraintType3D.LOCAL_ROTOR, Z_AXIS, 30.0f, 60.0f, Y_AXIS);
				
				// Add some additional bones
				secondChain.addConsecutiveBone(X_AXIS, 15.0);
				secondChain.addConsecutiveBone(X_AXIS, 10.0);
				secondChain.addConsecutiveBone(X_AXIS, 10.0);
				secondChain.setColour(Utils.GREY);
				
				// Connect this second chain to the start point of bone 3 in chain 0 of the structure
				mStructure.connectChain2(secondChain, 0, 3, BoneConnectionPoint3D.START);
			
			default:
				throw "No such demo number: " + demoNumber;
			
		}
		
	}
	
}
