package samples.demos2D;

import com.babylonhx.d2.display.Sprite;
import com.babylonhx.d2.display.Stage;
import com.babylonhx.d2.events.Event;
import com.babylonhx.d2.events.KeyboardEvent;
import com.babylonhx.d2.events.MouseEvent;
import com.babylonhx.Scene;

import jellohx.Body;
import jellohx.World;
import jellohx.DraggablePressureBody;
import jellohx.DraggableSpringBody;
import jellohx.Vector2;
import jellohx.ClosedShape;
import jellohx.PointMass;
import jellohx.PressureBody;
import jellohx.VectorTools;
import jellohx.Utils;
import jellohx.SpringBody;

/**
 * ...
 * @author Krtolica Vujadin
 */
class JellyPhysics {
	
	var showDebug:Bool;
	var dragBody:Body;
	var mouseDown:Bool;
	var dragPoint:Int;
	
	var mWorld:World;
	var RenderCanvas:Sprite;
	var mSpringBodies:Array<DraggableSpringBody>;
	var mPressureBodies:Array<DraggablePressureBody>;
	var mStaticBodies:Array<Body>;
	var tId:Int;
	
	
	var pg:DraggablePressureBody;
	
	var stage:Stage;
	

	public function new(scene:Scene) {		
		this.stage = scene.stage2D;
        
        mWorld = new World();
		mSpringBodies = new Array<DraggableSpringBody>();
		mPressureBodies = new Array<DraggablePressureBody>();
		mStaticBodies = new Array<Body>();
		tId = 0;
		
		showDebug = false;
		mouseDown = false;
		dragPoint = 0;
		
		init();
	}

	private function det(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float):Float {
		// This is a function which finds the determinant of a 3x3 matrix.
		// If you studied matrices, you'd know that it returns a positive number if three given points are in clockwise order, negative if they are in anti-clockwise order and zero if they lie on the same line.
		// Another useful thing about determinants is that their absolute value is two times the face of the triangle, formed by the three given points.
		return x1 * y2 + x2 * y3 + x3 * y1 - y1 * x2 - y2 * x3 - y3 * x1;
	}

	function init() {		
		// entry point
		RenderCanvas = new Sprite();
		RenderCanvas.scaleX = RenderCanvas.scaleY = 0.7;
		stage.addChild(RenderCanvas);
		showDebug = false;
		
		stage.addEventListener(Event.ENTER_FRAME, loop);
		RenderCanvas.addEventListener(MouseEvent.MOUSE_DOWN, mouseClick);
		RenderCanvas.addEventListener(MouseEvent.MOUSE_UP, mouseup);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);	
		stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
		
		loadTest();
	}
	
	public function keyPressed(e:KeyboardEvent) {
		var i:Int = cast e.keyCode;
		switch(i) {	
			case 37:	// left arrow				
				
			case 38:	// up arrow
				mPressureBodies[0].setEdgeSpringConstants(1200.2, 82.6);
				mPressureBodies[0].GasPressure = 40;
			
			case 39:	// right arrow
				
			case 66:
				//createBox(mWorld, mSpringBodies, mPressureBodies, mStaticBodies, stage.mouseX, stage.mouseY, 40, 40, 0);
				mPressureBodies.push(createDragablePressureBodyFromPoints(mWorld, "-760,-160,-840,-80,-840,0,-760,80,-680,80,-600,0,-600,-80,-680,-160", stage.mouseX, stage.mouseY, 0xff00ff, true));
		}
	}
	
	public function keyUp(e:KeyboardEvent) {
		var i:Int = cast e.keyCode;
		switch(i) {	
			case 37:	// left arrow
				
				
			case 38:	// up arrow
				mPressureBodies[0].setEdgeSpringConstants(400.8, 20.3);
				mPressureBodies[0].GasPressure = 3.0;
			
			case 39:	// right arrow
		}
	}
	
	static public function createDragablePressureBodyFromPoints(world:World, pts:String, x:Float, y:Float, color:Int = 0x00ff00, reverse:Bool = true):DraggablePressureBody {
		var pp:Array<String> = pts.split(",");
		var ppts:Array<Float> = [];
		var ppp:Array<Vector2> = [];
		var bball = new ClosedShape();
		
		if (reverse) {
			for(p in pp) {
				ppts.push(Std.parseFloat(p));
			}
			
			ppts.reverse();
			
			
			bball.begin();
			var i:Int = 0;
			while (i < ppts.length) {
				bball.addVertex(new Vector2(ppts[i], ppts[i + 1]));
				i += 2;
			}	
		} 
		else {
			var p:Int = 0;
			while(p < pp.length) {
				ppp.push(new Vector2(Std.parseFloat(pp[p]), Std.parseFloat(pp[p + 1])));
				p += 2;
			}
			
			ppp.reverse();
			for (p in ppp) {
				bball.addVertexPos(p.X, p.Y);
			}
		}
		bball.transformOwn(0, new Vector2(0.4, 0.4));
		bball.finish();
		var pg = new DraggablePressureBody(world, bball, 2, 100.0, 100.0, 65.0, 51.0, 20.0, new Vector2(x, y), 0.0, new Vector2(1, 1));
		pg.finalizeTriangles(color, color);
		
		return pg;
	}
	
	function createDragableSpringBodyFromPoints(pts:String, x:Float, y:Float, color:Int = 0x00ff00, reverse:Bool = true):Void {
		var pp:Array<String> = pts.split(",");
		var ppts:Array<Float> = [];
		var ppp:Array<Vector2> = [];
		var bball = new ClosedShape();
		
		if (reverse) {
			for(p in pp) {
				ppts.push(Std.parseFloat(p));
			}
			
			ppts.reverse();			
			
			bball.begin();
			var i:Int = 0;
			while(i < ppts.length) {
				bball.addVertex(new Vector2(ppts[i], ppts[i+1]));
				i += 2;
			}	
		} 
		else {
			var p:Int = 0;
			while(p < pp.length) {
				ppp.push(new Vector2(Std.parseFloat(pp[p]), Std.parseFloat(pp[p + 1])));
				p += 2;
			}
			
			ppp.reverse();
			for (p in ppp) {
				bball.addVertexPos(p.X, p.Y);
			}
		}
		
		bball.transformOwn(0, new Vector2(0.4, 0.4));
		bball.finish();
		
		var pg = new DraggableSpringBody(mWorld, bball, 1, 100.0, 5.0, 200.0, 20.0, new Vector2(x, y), 0.0, Vector2.One.clone());
		pg.finalizeTriangles(color, color);
		mSpringBodies.push(pg);
	}
	
	function createStaticBody(pts:String, x:Float, y:Float, reverse:Bool = true):Body {
		var pp:Array<String> = pts.split(",");
		var ppts:Array<Float> = [];
		var ppp:Array<Vector2> = [];
		var bball = new ClosedShape();
		
		if (reverse) {
			for(p in pp) {
				ppts.push(Std.parseFloat(p));
			}
			
			ppts.reverse();
			
			
			bball.begin();
			var i:Int = 0;
			while (i < ppts.length) {
				bball.addVertex(new Vector2(ppts[i], ppts[i + 1]));
				i += 2;
			}	
		} 
		else {
			var p:Int = 0;
			while(p < pp.length) {
				ppp.push(new Vector2(Std.parseFloat(pp[p]), Std.parseFloat(pp[p + 1])));
				p += 2;
			}
			
			ppp.reverse();
			for (p in ppp) {
				bball.addVertexPos(p.X, p.Y);
			}
		}
		
		//bball.transformOwn(1.2, new Vector2(1, 1));
		bball.finish();
		var pg = new Body(mWorld, bball, Utils.fillArray(Math.POSITIVE_INFINITY, bball.Vertices.length), new Vector2(x, y), Math.PI/2, Vector2.One.clone(), false);
		
		return pg;
	}

	function loadTest() {
		// Temp vars:
		var shape:ClosedShape;
		var pb:DraggablePressureBody;
		
		mStaticBodies.push(createStaticBody("83.91,-64.1,45,-60.71,21.84,4.17,-75.07,478.28,-89.26,508.27,-112.1,526.27,-141.75,529.73,-172.44,517.63,-207.79,480.97,-247.38,415.82,-258.63,380.16,-251.73,319.85,-250.6,284.15,-261.44,270.91,-293.34,261.5,-344.49,263.23,-375.67,275.33,-389.94,294.93,-407.87,372.58,-462.26,504.91,-491.7,551.11,-521.7,574.99,-565.75,590.85,-630.32,595,-685.63,585.54,-723.13,566.21,-746.87,540.69,-801.04,413.18,-819.73,392.31,-851.11,380.7,-895.88,383.84,-950.07,402.22,-1007.67,451.01,-1041.27,472.65,-1070.32,474.93,-1110.64,466.34,-1140.23,447.21,-1171.61,403.81,-1175.67,395.33,-1281.46,-68.77,-1325.68,-69.03,-1323.85,631.11,80.86,627.05", 700, 650, true));
		
		mPressureBodies.push(createDragablePressureBodyFromPoints(mWorld, "-630,245,-630,210,-630,175,-630,140,-630,105,-630,70,-630,35,-630,0,-595,0,-595,35,-560,35,-560,70,-525,70,-525,35,-490,35,-490,0,-455,0,-455,35,-455,70,-455,105,-455,140,-455,175,-455,210,-455,245,-490,245,-490,210,-490,175,-490,140,-490,105,-525,105,-525,140,-560,140,-560,105,-595,105,-595,140,-595,175,-595,210,-595,245", 300, 200, 0xff00ff, false));
		
		createDragableSpringBodyFromPoints("-315,0,-332.5,0,-350,0,-385,0,-420,0,-420,17.5,-420,35,-420,70,-420,87.5,-420,105,-420,140,-420,157.5,-420,175,-420,210,-420,227.5,-420,245,-385,245,-350,245,-332.5,245,-315,245,-315,210,-332.5,210,-350,210,-385,210,-385,175,-385,140,-350,140,-332.5,140,-315,140,-315,105,-332.5,105,-350,105,-385,105,-385,70,-385,35,-350,35,-332.5,35,-315,35", 900, 200, 0xff00ff, true);
		
		mPressureBodies.push(createDragablePressureBodyFromPoints(mWorld, "-840,35,-875,35,-910,35,-945,35,-945,70,-945,105,-945,140,-945,175,-945,210,-910,210,-875,210,-875,175,-910,175,-910,140,-875,140,-840,140,-840,175,-840,210,-840,245,-875,245,-910,245,-945,245,-980,245,-980,210,-980,175,-980,140,-980,105,-980,70,-980,35,-980,0,-945,0,-910,0,-875,0,-840,0", 700, 100, 0xff00ff, false));
		
		createDragableSpringBodyFromPoints("-805,245,-805,210,-805,175,-805,140,-805,105,-805,70,-787.5,52.5,-770,35,-752.5,17.5,-735,0,-717.5,17.5,-700,35,-682.5,52.5,-665,70,-665,87.5,-665,105,-665,140,-665,175,-665,210,-665,245,-700,245,-700,210,-700,175,-700,140,-700,105,-735,70,-770,105,-770,140,-739.68,140,-709.36,140,-709.36,175,-739.68,175,-770,175,-770,210,-770,245", 800, 100, 0xff00ff, false);
		
		createBox(mWorld, mSpringBodies, mPressureBodies, mStaticBodies, 500, 400, 50, 50, 2);
		createBox(mWorld, mSpringBodies, mPressureBodies, mStaticBodies, 600, 400, 50, 50, 2);
		createBox(mWorld, mSpringBodies, mPressureBodies, mStaticBodies, 700, 400, 50, 50, 2);
		createBox(mWorld, mSpringBodies, mPressureBodies, mStaticBodies, 800, 400, 50, 50, 2);
		
		createBox(mWorld, mSpringBodies, mPressureBodies, mStaticBodies, 500, 300, 50, 50, 0);
		createBox(mWorld, mSpringBodies, mPressureBodies, mStaticBodies, 300, 300, 50, 50, 0);
		createBox(mWorld, mSpringBodies, mPressureBodies, mStaticBodies, 400, 300, 50, 50, 0);
		createBox(mWorld, mSpringBodies, mPressureBodies, mStaticBodies, 800, 300, 50, 50, 0);
		
		createBox(mWorld, mSpringBodies, mPressureBodies, mStaticBodies, 600, 100, 50, 50, 1);
		createBox(mWorld, mSpringBodies, mPressureBodies, mStaticBodies, 400, 100, 50, 50, 1);		
	}

	static public function createBox(world:World, springBodies:Array<DraggableSpringBody>, pressureBodies:Array<DraggablePressureBody>, staticBodies:Array<Body>, x:Float, y:Float, w:Float, h:Float, t:Int = 0):Body {
		var shape = new ClosedShape();
		if(t == 0)  {
			shape.begin();
			shape.addVertexPos(0, 0);
			shape.addVertexPos(0, h);
			shape.addVertexPos(w, h);
			shape.addVertexPos(w, 0);
			shape.finish();
			var body:DraggableSpringBody = new DraggableSpringBody(world, shape, 20, 100.0, 5.0, 300.0, 15.0, new Vector2(x, y), Math.PI/4, Vector2.One.clone());
			body.addInternalSpring(0, 2, 300, 10);
			body.addInternalSpring(1, 3, 300, 10);
			body.finalizeTriangles(0xDDDD00, 0xDDDD00);
			springBodies.push(body);
			
			return body;
		}
		else if (t == 1) {
			shape.begin();
			shape.addVertexPos(0, 0);
			shape.addVertexPos(0, h / 2);
			shape.addVertexPos(0, h);
			shape.addVertexPos(w / 2, h);
			shape.addVertexPos(w, h);
			shape.addVertexPos(w, h / 2);
			shape.addVertexPos(w, 0);
			shape.addVertexPos(w / 2, 0);
			shape.finish();
			var body1:DraggablePressureBody = new DraggablePressureBody(world, shape, 10, 40.0, 150.0, 5.0, 300.0, 15.0, new Vector2(x, y), 0.0, new Vector2(0.5, 0.5));
			pressureBodies.push(body1);
			body1.finalizeTriangles(0x00FF7F, 0x00FF7F);
			
			return body1;
		}
		else if (t == 2)  {
			shape.begin();
			shape.addVertexPos(0, 0);
			shape.addVertexPos(0, h / 2);
			shape.addVertexPos(0, h);
			shape.addVertexPos(w / 2, h);
			shape.addVertexPos(w, h);
			shape.addVertexPos(w, h / 2);
			shape.addVertexPos(w, 0);
			shape.addVertexPos(w / 2, 0);
			shape.finish();
			var body2:SpringBody = new SpringBody(world, shape, 3, 900, 50, 30, 15, new Vector2(x, y), Math.PI/4, Vector2.One.clone(), true);
			staticBodies.push(body2);
			
			return body2;
		}
		else if(t == 3)  {
			shape.begin();
			shape.addVertexPos(0, 0);
			shape.addVertexPos(0, h);
			shape.addVertexPos(w, h);
			shape.addVertexPos(w, 0);
			shape.finish();
			var body3:Body = new Body(world, shape, Utils.fillArray(Math.POSITIVE_INFINITY, shape.Vertices.length), new Vector2(x, y), 0, Vector2.One.clone(), false);
			staticBodies.push(body3);
			
			return body3;
		}
		
		return null;
	}

	var body:Array<Int> = [];
	var dragp:Array<Int> = [];
	public function mouseClick(e:MouseEvent) {
		if (dragBody == null) {
			mWorld.getClosestPointMass(cursorPos, body, dragp);
			dragPoint = dragp[0];
			dragBody = mWorld.getBody(body[0]);
		}
		mouseDown = true;
	}

	public function mouseup(e:MouseEvent) {
		mouseDown = false;
		dragBody = null;
	}

	public function numbOfPairs(numb:Int, wholeNumb:Int):Int {
		var i:Int = 0;
		while(wholeNumb > numb) {
			wholeNumb -= numb;
			i++;
		}
		
		return i;
	}

	var cursorPos:Vector2 = new Vector2();
	var pm:PointMass;
	public function loop(e:EnterFrameEvent) {
		cursorPos.setTo(RenderCanvas.mouseX, RenderCanvas.mouseY);
		
		for (i in 0...5) {
			mWorld.update(1.0 / 50.0);
			if (dragBody != null)  {
				pm = dragBody.getPointMass(dragPoint);
				if (Std.is(dragBody, DraggableSpringBody)) {
					cast((dragBody), DraggableSpringBody).setDragForce(VectorTools.calculateSpringForceRetPos(pm.PositionX, pm.PositionY, pm.VelocityX, pm.VelocityY, cursorPos.X, cursorPos.Y, 0, 0, 0.0, 100.0, 10.0), dragPoint);
				}
				else if (Std.is(dragBody, DraggablePressureBody)) {
					cast((dragBody), DraggablePressureBody).setDragForce(VectorTools.calculateSpringForceRetPos(pm.PositionX, pm.PositionY, pm.VelocityX, pm.VelocityY, cursorPos.X, cursorPos.Y, 0, 0, 0.0, 100.0, 10.0), dragPoint);
				}
			}
		}
		
		RenderCanvas.graphics.clear();
		
		if(!showDebug)  {
			for(i in mSpringBodies) {
				i.drawMe(RenderCanvas.graphics);
			}
			for(i in mPressureBodies) {
				i.drawMe(RenderCanvas.graphics);
			}
			for(i in mStaticBodies) {
				i.debugDrawMe(RenderCanvas.graphics);
			}
		}
		else  {
			// draw all the bodies in debug mode, to confirm physics.
			mWorld.debugDrawMe(RenderCanvas.graphics);
			mWorld.debugDrawAllBodies(RenderCanvas.graphics, false);
		}
		
		if (dragBody != null)  {
			pm = dragBody.mPointMasses[dragPoint];
			RenderCanvas.graphics.lineStyle(1, 0xD2B48C);
			RenderCanvas.graphics.moveTo(pm.PositionX, pm.PositionY);
			RenderCanvas.graphics.lineTo(RenderCanvas.mouseX, RenderCanvas.mouseY);
		}
		else  {
			dragBody = null;
			dragPoint = -1;
		}
	}
	
}
