package tests;

import luxe.Color;
import luxe.Vector;
import luxe.Input;
import luxe.Text;
import luxe.States;

import mint.Control;
import mint.types.Types;
import mint.render.luxe.Convert;
import mint.render.luxe.Label;
import mint.layout.margins.Margins;

class KitchenSink extends State {

    //var bg: luxe.Sprite;

        //some controls we want to edit outside of their scope
    var window1: mint.Window;
    var window2: mint.Window;
    var window3: mint.Window;
    var check: mint.Checkbox;
    var progress: mint.Progress;
    var canvas: mint.Canvas;
    var text1: mint.TextEdit;

    override function onleave<T>(_:T) {

        //bg.destroy();

        canvas = null;
        window1 = null;
        window2 = null;
        window3 = null;
        check = null;
        progress = null;

    } //onleave

    override function onenter<T>(_:T) {

        canvas = MainLuxe.canvas;

        MainLuxe.disp.text = 'Test: KitchenSink. Press 0 or 9 to cycle test cases';

        // Luxe.snow.windowing.enable_vsync(false);

        //bg = new luxe.Sprite({ name:'bg',texture:Luxe.resources.texture('assets/960.png'), centered:false, depth:-1 });

        create_basics();
        create_window1();
        create_window2();
        create_window3();

    } //onenter

    var progress_dir = -1;

    function create_window1() {

        window1 = new mint.Window({
            parent: canvas,
            name: 'window1',
            title: 'window',
            options: {
                color:new Color().rgb(0x121212),
                color_titlebar:new Color().rgb(0x191919),
                label: { color:new Color().rgb(0x06b4fb) },
                close_button: { color:new Color().rgb(0x06b4fb) },
            },
            x:160, y:10, w:256, h: 400,
            w_min: 256, h_min:256,
            collapsible:true
        });

        var _list = new mint.List({
            parent: window1,
            name: 'list1',
            options: { view: { color:new Color().rgb(0x19191c) } },
            x: 4, y: 28, w: 248, h: 400-28-4
        });

        MainLuxe.layout.margin(_list, right, fixed, 4);
        MainLuxe.layout.margin(_list, bottom, fixed, 4);

        var titles = ['Sword of Extraction', 'Fortitude', 'Wisdom stone', 'Cursed Blade', 'Risen Staff' ];
        var desc = ['Steals 30% life of every hit from the target',
                    '3 second Invulnerability', 'Passive: intelligence +5',
                    'Each attack deals 1 damage to the weilder', 'Undead staff deals 3x damage to human enemies' ];

        inline function create_block(idx:Int) {

            var _panel = new mint.Panel({
                parent: _list,
                name: 'panel_${idx}',
                x:2, y:4, w:236, h:96,
            });

            MainLuxe.layout.margin(_panel, right, fixed, 8);

            new mint.Image({
                parent: _panel, name: 'icon_${idx}',
                x:8, y:8, w:80, h:80,
                path: 'assets/transparency.png'
            });

            var _title = new mint.Label({
                parent: _panel, name: 'label_${idx}',
                mouse_input:true, x:96, y:8, w:148, h:18, text_size: 16,
                align: TextAlign.left, align_vertical: TextAlign.top,
                text: titles[idx],
            });

            var _desc = new mint.Label({
                parent: _panel, name: 'desc_${idx}',
                x:96, y:30, w:132, h:18, text_size: 12,
                align: TextAlign.left, align_vertical: TextAlign.top, bounds_wrap: true,
                text: desc[idx]
            });

            MainLuxe.layout.margin(_title, right, fixed, 8);
            MainLuxe.layout.margin(_desc, right, fixed, 8);

            return _panel;

        } //create_block

        for(i in 0 ... 5) {

            _list.add_item( create_block(i), 0, (i == 0) ? 0 : 8 );

        } //for

    } //create_window1

    function create_window2() {

        var _window = new mint.Window({
            parent: canvas, name: 'window2', title: 'window',
            visible: false, closable: false, collapsible: true,
            x:500, y:10, w:256, h: 131,
            h_max: 131, h_min: 131, w_min: 131
        });

        var _anchored = new mint.Image({
            parent: canvas, name: 'image2', x:0, y:400, w:32, h: 32,
            path: 'assets/transparency.png'
        });

        var _platform = new mint.Dropdown({
            parent: _window,
            name: 'dropdown', text: 'Platform...',
            options: { color:new Color().rgb(0x343439) },
            x:10, y:32+22+10+32, w:256-10-10, h:24,
        });

        var plist = ['windows', 'linux', 'ios', 'android', 'web'];

        inline function add_plat(name:String) {
            var first = plist.indexOf(name) == 0;
            _platform.add_item(
                new mint.Label({
                    parent: _platform, text: '$name', align:TextAlign.left,
                    name: 'plat-$name', w:225, h:24, text_size: 14
                }),
                10, (first) ? 0 : 10
            );
        }

        for(p in plist) add_plat(p);

        _platform.onselect.listen(function(idx,_,_){ _platform.label.text = plist[idx]; });

        text1 = new mint.TextEdit({
            parent: _window, name: 'textedit1', text: 'snõwkit / mínt', renderable: true,
            x: 10, y:32, w: 256-10-10, h: 22
        });

        text1.onchange.listen(function(s){ trace(s); });

        var numbers = new EReg('^[0-9]+[.]?[0-9]{0,2}$','gi');
        var _text2 = new mint.TextEdit({
            parent: _window, name: 'textnumbersonly', text: '314.29',
            x: 10, y:32+22+10, w: 256-10-10, h: 22,
            filter: function(char,future,prev){
                return numbers.match(future);
            },
            options: {
                color: new Color(0.96,0.96,0.96),
                color_hover: new Color(),
                color_cursor: new Color().rgb(0xf6007b),
                label:{ color: new Color().rgb(0xf6007b) }
            }
        });

        MainLuxe.layout.anchor(_anchored, _window, left, right);
        MainLuxe.layout.anchor(_anchored, _window, top, top);

        MainLuxe.layout.margin(_platform, right, fixed, 10);
        MainLuxe.layout.margin(text1, right, fixed, 10);
        MainLuxe.layout.margin(_text2, right, fixed, 10);

        Luxe.timer.schedule(1, function(){ _window.visible = true; });

    } //create_window2

    function create_window3() {

        window3 = new mint.Window({
            parent: canvas, name: 'customwindow', title: 'custom window', text_size: 13,
            rendering: new CustomWindowRendering(),
            x:500, y:150, w:256, h:180+42+32,
            w_min: 128, h_min:128
        });

        //reach into the rendering specifics and change stuff
        var _close_render = (cast window3.close_button.renderer:Label);
            _close_render.text.point_size = 16;

        var _list = new mint.List({ parent: window3, name: 'list', x: 10, y: 50, w: 236, h: 64 });

        for(i in 0 ... 20) {
            _list.add_item(
                new mint.Label({
                    parent: _list, w:100, h:30, align:TextAlign.left,
                    name: 'label$i', text: 'label $i', text_size: 14,
                    options: {
                        color: new Color().rgb(0xf6007b),
                        color_hover: new Color().rgb(0xffffff)
                    },
                }),
                10, i == 0 ? 0 : 10
            );
        } //for


        var _panel1 = new mint.Panel({
            parent: window3, name: 'p1', x: 32, y: 120, w: 32, h: 32,
            options:{ color:new Color().rgb(0x06b4fb) }
        });

        var _panel2 = new mint.Panel({ parent: window3, name: 'p2', x: 32, y: 36, w: 8, h: 8 });

        MainLuxe.layout.margin(_list, right, fixed, 10);

        MainLuxe.layout.anchor(_panel1, center_x, center_x);
        MainLuxe.layout.anchor(_panel1, center_y, center_y);

        MainLuxe.layout.size(_panel2, width, 50);
        MainLuxe.layout.anchor(_panel2, center_x, center_x);

    } //create_window3

    function create_basics() {

        new mint.Label({
            parent: canvas,
            name: 'labelmain',
            x:10, y:10, w:100, h:32,
            text: 'hello mint',
            align:left,
            text_size: 14,
            onclick: function(e,c) {trace('hello mint! ${Luxe.time}' );}
        });

        check = new mint.Checkbox({
            parent: canvas,
            name: 'check1',
            x: 120, y: 16, w: 24, h: 24
        });

        new mint.Checkbox({
            parent: canvas,
            name: 'check2',
            options: {
                color_node: new Color().rgb(0xf6007b),
                color_node_off: new Color().rgb(0xcecece),
                color: new Color().rgb(0xefefef),
                color_hover: new Color().rgb(0xffffff),
                color_node_hover: new Color().rgb(0xe2005a)
            },
            x: 120, y: 48, w: 24, h: 24
        });

        progress = new mint.Progress({
            parent: canvas,
            name: 'progress1',
            progress: 0.2,
            options: { color:new Color(), color_bar:new Color().rgb(0x121219) },
            x: 10, y:95 , w:128, h: 16
        });

        inline function make_slider(_n,_x,_y,_w,_h,_c,_min,_max,_initial,_step:Null<Float>,_vert) {

            var _s = new mint.Slider({
                parent: canvas, name: _n, x:_x, y:_y, w:_w, h:_h,
                options: { color_bar:new Color().rgb(_c) },
                min: _min, max: _max, step: _step, vertical:_vert, value:_initial
            });

            var _l = new mint.Label({
                parent:_s, text_size:12, x:0, y:0, w:_s.w, h:_s.h,
                align: TextAlign.center, align_vertical: TextAlign.center,
                name : _s.name+'.label', text: '${_s.value}'
            });

            _s.onchange.listen(function(_val,_) { _l.text = '$_val'; });

        } //make_slider

        make_slider('slider1', 10, 330, 128, 24, 0x9dca63, -100, 100, 0, 10, false);
        make_slider('slider2', 10, 357, 128, 24, 0x9dca63, 0, 100, 50, 1, false);
        make_slider('slider3', 10, 385, 128, 24, 0xf6007b, null, null, null, null, false);

        make_slider('slider4', 14, 424, 32, 128, 0x9dca63, 0, 100, 20, 10, true);
        make_slider('slider5', 56, 424, 32, 128, 0x9dca63, 0, 100, 0.3, 1, true);
        make_slider('slider6', 98, 424, 32, 128, 0xf6007b, null, null, null, null, true);

        new mint.Button({
            parent: canvas,
            name: 'button1',
            x: 10, y: 52, w: 60, h: 32,
            text: 'mint',
            text_size: 14,
            options: { label: { color:new Color().rgb(0x9dca63) } },
            onclick: function(e,c) {trace('mint button! ${Luxe.time}' );}
        });

        new mint.Button({
            parent: canvas,
            name: 'button2',
            x: 76, y: 52, w: 32, h: 32,
            text: 'O',
            options: { color_hover: new Color().rgb(0xf6007b) },
            text_size: 16,
            onclick: function(e,c) {trace('mint button! ${Luxe.time}' );}
        });

        new mint.Image({
            parent: canvas,
            name: 'image1',
            x: 10, y: 120, w: 64, h: 64,
            options: { uv: new luxe.Rectangle(0,0,32,32) },
            path: 'assets/transparency.png'
        });

        new mint.Panel({
            parent: canvas,
            name: 'panel1',
            x:84, y:120, w:64, h: 64,
        });

        var _scroll = new mint.Scroll({
            parent: canvas,
            name: 'scroll1',
            options: { color_handles:new Color().rgb(0xffffff) },
            x:16, y:190, w: 128, h: 128,
        });

        new mint.Image({
            parent: _scroll,
            name: 'image_other',
            x:0, y:100, w:512, h: 512,
            path: 'assets/image.png'
        });


    } //create_basics


    override function onkeyup(e:luxe.Input.KeyEvent) {

        if(e.keycode == Key.key_1) if(window1 != null) window1.open();
        if(e.keycode == Key.key_2) if(window2 != null) window2.open();
        if(e.keycode == Key.key_3) if(window3 != null) window3.open();
        if(e.keycode == Key.key_4) if(check != null) check.visible = !check.visible;
        if(e.keycode == Key.key_5) {
            if( text1.display_char == null ) {
                text1.display_char = '•';
            } else {
                text1.display_char = null;
            }
        }

    } //onkeyup

    override function update(dt:Float) {

        if(progress != null) {
            progress.progress += (0.2 * dt) * progress_dir;
            if(progress.progress >= 1) progress_dir = -1;
            if(progress.progress <= 0) progress_dir = 1;
        }

    } //update

} //KitchenSink


class CustomWindowRenderer extends mint.render.Render {

    var window : mint.Window;
    var visual : luxe.NineSlice;

    public function new( _render:mint.render.Rendering, _control:mint.Window ) {

        super(_render, _control);
        window = _control;

        visual = new luxe.NineSlice({
            name: _control.name + '.visual',
            texture : Luxe.resources.texture('assets/mint.box.png'),
            top : 32, left : 32, right : 32, bottom : 32,
        });

        visual.create(new Vector(window.x, window.y), window.w, window.h);

        window.title.y_local += 3;
        window.close_button.y_local += 1;

    } //new

    override function ondestroy() {
        visual.destroy();
        visual = null;
    }

    override function onbounds() {
        visual.pos = new Vector(control.x, control.y);
        visual.size = new Vector(control.w, control.h);
    }

    override function onvisible( _visible:Bool ) visual.visible = _visible;
    override function ondepth( _depth:Float ) visual.depth = _depth;

}

class CustomWindowRendering extends mint.render.Rendering {

    override function get<T:Control, T1>( type:Class<T>, control:T ) : T1 {
        return cast switch(type) {
            case mint.Window: new CustomWindowRenderer(this, cast control);
            case _: null;
        }
    } //get

} //CustomWindowRendering