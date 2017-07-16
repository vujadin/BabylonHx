package com.babylonhx.tools;

import haxe.Timer;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * An implementation of a loop for asynchronous functions.
 */

@:expose('BABYLON.AsyncLoop') class AsyncLoop {
	
	public var iterations:Int;
	
	public var index:Int;
	private var _done:Bool;
	
	private var _fn:AsyncLoop->Void;
	private var _successCallback:Void->Void;
	

	/**
	 * Constructor.
	 * @param iterations the number of iterations.
	 * @param _fn the function to run each iteration
	 * @param _successCallback the callback that will be called upon succesful execution
	 * @param offset starting offset.
	 */
	public function new(iterations:Int, _fn:AsyncLoop->Void, _successCallback:Void->Void, offset:Int = 0) {
		this.iterations = iterations;
		this._fn = _fn;
		this._successCallback = _successCallback;
		
		this.index = offset - 1;
		this._done = false;
	}

	/**
	 * Execute the next iteration. Must be called after the last iteration was finished.
	 */
	public function executeNext() {
		if (!this._done) {
			if (this.index + 1 < this.iterations) {
				++this.index;
				this._fn(this);
			} else {
				this.breakLoop();
			}
		}
	}

	/**
	 * Break the loop and run the success callback.
	 */
	public function breakLoop() {
		this._done = true;
		this._successCallback();
	}

	/**
	 * Helper function
	 */
	public static function Run(iterations:Int, _fn:AsyncLoop->Void, _successCallback:Void->Void, offset:Int = 0):AsyncLoop {
		var loop = new AsyncLoop(iterations, _fn, _successCallback, offset);
		
		loop.executeNext();
		
		return loop;
	}


	/**
	 * A for-loop that will run a given number of iterations synchronous and the rest async.
	 * @param iterations total number of iterations
	 * @param syncedIterations number of synchronous iterations in each async iteration.
	 * @param fn the function to call each iteration.
	 * @param callback a success call back that will be called when iterating stops.
	 * @param breakFunction a break condition (optional)
	 * @param timeout timeout settings for the setTimeout function. default - 0.
	 * @constructor
	 */
	public static function SyncAsyncForLoop(iterations:Int, syncedIterations:Int, fn:Int->Void, cback:Void->Void, ?breakFunction:Void->Bool, timeout:Int = 0) {
		AsyncLoop.Run(Math.ceil(iterations / syncedIterations), function(loop:AsyncLoop) {
			if (breakFunction != null && breakFunction()) {
				loop.breakLoop();
			}
			else {
				Tools.delay(function() {
					for (i in 0...syncedIterations) {
						var iteration = (loop.index * syncedIterations) + i;
						if (iteration >= iterations) {
							break;
						}
						
						fn(iteration);
						
						if (breakFunction != null && breakFunction()) {
							loop.breakLoop();
							break;
						}
					}
					loop.executeNext();
				}, timeout);
			}
		}, cback);
	}
	
}
	