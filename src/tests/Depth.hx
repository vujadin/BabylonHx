package tests;

import luxe.Color;
import luxe.Vector;
import luxe.Input;
import luxe.Text;
import luxe.States;

import mint.Control;
import mint.types.Types;
import mint.render.luxe.LuxeMintRender;
import mint.render.luxe.Convert;
import mint.render.luxe.Label;

import mint.layout.margins.Margins;

class Depth extends State {

    var scroll: mint.Scroll;
    var scroll2: mint.Scroll;

    override function onenter<T>(_:T) {

        MainLuxe.disp.text = 'Test: Depth';

        var _r0 = new mint.Panel({
            parent: MainLuxe.canvas, name:'r0',
            x:20, y:20, w:64, h: 64,
            options: { color:new Color().rgb(0x222222) }
        });

        var _r1 = new mint.Panel({
            parent: _r0, name:'r1',
            x:40, y:40, w:64, h: 64,
            options: { color:new Color().rgb(0x444444) }
        });

        var _r2 = new mint.Panel({
            parent: _r1, name:'r2',
            x:40, y:40, w:64, h: 64,
            options: { color:new Color().rgb(0x555555) }
        });

        var _c0 = new mint.Panel({
            parent: MainLuxe.canvas, name:'c0',
            x:220, y:20, w:64, h: 64,
            options: { color:new Color().rgb(0x222222) }
        });

        var _c1 = new mint.Panel({
            parent: _c0, name:'c1',
            x:40, y:40, w:64, h: 64,
            options: { color:new Color().rgb(0x444444) }
        });

        var _c2 = new mint.Panel({
            parent: _c1, name:'c2',
            x:40, y:40, w:64, h: 64,
            options: { color:new Color().rgb(0x555555) }
        });

    } //onenter

    override function onleave<T>(_:T) {

    } //onleave


} //Depth