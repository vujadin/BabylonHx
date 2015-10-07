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

class Scrolling extends State {

    var scroll: mint.Scroll;
    var scroll2: mint.Scroll;

    override function onenter<T>(_:T) {

        MainLuxe.disp.text = 'Test: Scrolling';

        scroll = new mint.Scroll({
            parent: MainLuxe.canvas,
            options: { color_handles:new Color().rgb(0xf6007b) },
            x:20, y:100, w: 256, h: 256
        });

        scroll2 = new mint.Scroll({
            parent: MainLuxe.canvas,
            options: { color_handles:new Color().rgb(0xcc0000) },
            x:340, y:100, w: 256, h: 256
        });

        new mint.Image({
            parent: scroll,
            w:1024, h: 1024,
            path: 'assets/image.png'
        });

        new mint.Image({
            parent: scroll2,
            w:128, h: 128,
            path: 'assets/image.png'
        });

    } //onenter

    override function onleave<T>(_:T) {

    } //onleave


} //Scrolling