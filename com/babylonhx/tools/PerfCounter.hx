package com.babylonhx.tools;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PerfCounter {

	public static var Enabled:Bool = true;

	/**
	 * Returns the smallest value ever
	 */
	public var min(get, never):Float;
	inline private function get_min():Float {
		return this._min;
	}

	/**
	 * Returns the biggest value ever
	 */
	public var max(get, never):Float;
	inline private function get_max():Float {
		return this._max;
	}

	/**
	 * Returns the average value since the performance counter is running
	 */
	public var average(get, never):Float;
	inline private function get_average():Float {
		return this._average;
	}

	/**
	 * Returns the average value of the last second the counter was monitored
	 */
	public var lastSecAverage(get, never):Float;
	inline private function get_lastSecAverage():Float {
		return this._lastSecAverage;
	}

	/**
	 * Returns the current value
	 */
	public var current(get, never):Int;
	inline private function get_current():Int {
		return this._current;
	}

	public var total(get, never):Float;
	inline private function get_total():Float {
		return this._totalAccumulated;
	}
	

	public function new() {
		this._startMonitoringTime = 0;
		this._min = 0;
		this._max = 0;
		this._average = 0;
		this._lastSecAverage = 0;
		this._current = 0;
		this._totalValueCount = 0;
		this._totalAccumulated = 0;
		this._lastSecAccumulated = 0;
		this._lastSecTime = 0;
		this._lastSecValueCount = 0;
	}

	/**
	 * Call this method to start monitoring a new frame.
	 * This scenario is typically used when you accumulate monitoring time many times for a single frame, you call this method at the start of the frame, then beginMonitoring to start recording and endMonitoring(false) to accumulated the recorded time to the PerfCounter or addCount() to accumulate a monitored count.
	 */
	public function fetchNewFrame() {
		this._totalValueCount++;
		this._current = 0;
		this._lastSecValueCount++;
	}

	/**
	 * Call this method to monitor a count of something (e.g. mesh drawn in viewport count)
	 * @param newCount the count value to add to the monitored count
	 * @param fetchResult true when it's the last time in the frame you add to the counter and you wish to update the statistics properties (min/max/average), false if you only want to update statistics.
	 */
	public function addCount(newCount:Int, fetchResult:Bool) {
		if (!PerfCounter.Enabled) {
			return;
		}
		this._current += newCount;
		if (fetchResult) {
			this._fetchResult();
		}
	}

	/**
	 * Start monitoring this performance counter
	 */
	public function beginMonitoring() {
		if (!PerfCounter.Enabled) {
			return;
		}
		this._startMonitoringTime = Tools.Now();
	}

	/**
	 * Compute the time lapsed since the previous beginMonitoring() call.
	 * @param newFrame true by default to fetch the result and monitor a new frame, if false the time monitored will be added to the current frame counter
	 */
	public function endMonitoring(newFrame:Bool = true) {
		if (!PerfCounter.Enabled) {
			return;
		}
		
		if (newFrame) {
			this.fetchNewFrame();
		}
		
		var currentTime = Tools.Now();
		this._current = Std.int(currentTime - this._startMonitoringTime);
		
		if (newFrame) {
			this._fetchResult();
		}
	}

	private function _fetchResult() {
		this._totalAccumulated += this._current;
		this._lastSecAccumulated += this._current;
		
		// Min/Max update
		this._min = Math.min(this._min, this._current);
		this._max = Math.max(this._max, this._current);
		this._average = this._totalAccumulated / this._totalValueCount;
		
		// Reset last sec?
		var now = Tools.Now();
		if ((now - this._lastSecTime) > 1000) {
			this._lastSecAverage = this._lastSecAccumulated / this._lastSecValueCount;
			this._lastSecTime = now;
			this._lastSecAccumulated = 0;
			this._lastSecValueCount = 0;
		}
	}

	private var _startMonitoringTime:Float;
	private var _min:Float;
	private var _max:Float;
	private var _average:Float;
	private var _current:Int;
	private var _totalValueCount:Float;
	private var _totalAccumulated:Float;
	private var _lastSecAverage:Float;
	private var _lastSecAccumulated:Float;
	private var _lastSecTime:Float;
	private var _lastSecValueCount:Float;
	
}