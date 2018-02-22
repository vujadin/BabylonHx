package com.babylonhx.extensions.dungeongenerator.utils;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Array2D {
	
	public var rows:Array<Array<Int>>;
	public var size:Array<Int>;
	

	public function new(size:Array<Int> = [0, 0], default_value:Int = -1) {
		this.rows = [];
        this.size = [];
		
        for (y in 0...size[1]) {
            var row:Array<Int> = [];
            for (x in 0...size[0]) {
                row.push(default_value);
            }
            this.rows.push(row);
        }
	}
	
	public function iter(callback:Dynamic, context:Dynamic) {
        for (y in 0...size[1]) {
            for (x in 0...size[0]) {
                callback(context, [[x, y], this.get([x, y])]);
            }
        }
    }

    public function get(arr:Array<Int>) {
        if (this.rows[arr[1] == null) {
            return null;
        }
        return this.rows[y][x];
    }

    public function set(arr:Array<Int>, val) {
        this.rows[y][x] = val;
    }

    set_horizontal_line([start_x, start_y], delta_x, val) {
        let c = Math.abs(delta_x),
            mod = delta_x < 0 ? -1 : 1;

        for (let x=0; x <= c; x++) {
            this.set([pos[0] + x  * mod, pos[1]], val);
        }
    }

    set_vertical_line([start_x, start_y], delta_y, val) {
        let c = Math.abs(delta_y),
            mod = delta_y < 0 ? -1 : 1;

        for (let y=0; y <= c; y++) {
            this.set([pos[0], pos[1] + y * mod], val);
        }
    }

    get_square([x, y], [size_x, size_y]) {
        let retv = new Array2d([size_x, size_y]);
        for (let dx = 0; dx < size_x; dx ++) {
            for (let dy = 0; dy < size_y; dy ++) {
                retv.set([dx, dy], this.get([x + dx, y + dy]));
            }
        }
        return retv;
    }

    set_square([x, y], [size_x, size_y], val, fill=false) {
        if (!fill) {
            this.line_h([x, y], size_x - 1, val);
            this.line_h([x, y + size_y - 1], size_x - 1, val);
            this.line_v([x, y], size_y -1, val);
            this.line_v([x + size_x - 1, y], size_y - 1, val);
        } else {
            for (let dx = 0; dx < size_x; dx ++) {
                for (let dy = 0; dy < size_y; dy ++) {
                    this.set([x + dx, y + dy], val);
                }
            }
        }
    }
	
}
