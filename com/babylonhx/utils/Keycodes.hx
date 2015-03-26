package com.babylonhx.utils;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * copy of https://github.com/underscorediscovery/snow/blob/master/snow/input/Keycodes.hx
 */


/** The keycode class, with conversion helpers for scancodes. The values below come directly from SDL header include files,
but they aren't specific to SDL so they are used generically */
@:noCompletion class Keycodes {

	/** Convert a scancode to a keycode for comparison */
    public static function from_scan( scancode : Int ) : Int {
        return (scancode | Scancodes.MASK);
    } //from_scan

	/** Convert a keycode to a scancode if possible.
		NOTE - this will only map a large % but not all keys,
		there is a list of unmapped keys commented in the code. */
    public static function to_scan( keycode : Int ) : Int {

		//quite a lot map directly to a masked scancode
		//if that's the case, return it directly
        if ((keycode & Scancodes.MASK) != 0) {
            return keycode &~ Scancodes.MASK;
        }

		//now we translate them to the scan where unmapped

        switch(keycode) {
            case Keycodes.enter:         return Scancodes.enter;
            case Keycodes.escape:        return Scancodes.escape;
            case Keycodes.backspace:     return Scancodes.backspace;
            case Keycodes.tab:           return Scancodes.tab;
            case Keycodes.space:         return Scancodes.space;
            case Keycodes.slash:         return Scancodes.slash;
            case Keycodes.key_0:         return Scancodes.key_0;
            case Keycodes.key_1:         return Scancodes.key_1;
            case Keycodes.key_2:         return Scancodes.key_2;
            case Keycodes.key_3:         return Scancodes.key_3;
            case Keycodes.key_4:         return Scancodes.key_4;
            case Keycodes.key_5:         return Scancodes.key_5;
            case Keycodes.key_6:         return Scancodes.key_6;
            case Keycodes.key_7:         return Scancodes.key_7;
            case Keycodes.key_8:         return Scancodes.key_8;
            case Keycodes.key_9:         return Scancodes.key_9;
            case Keycodes.semicolon:     return Scancodes.semicolon;
            case Keycodes.equals:        return Scancodes.equals;
            case Keycodes.leftbracket:   return Scancodes.leftbracket;
            case Keycodes.backslash:     return Scancodes.backslash;
            case Keycodes.rightbracket:  return Scancodes.rightbracket;
            case Keycodes.backquote:     return Scancodes.grave;
            case Keycodes.key_a:         return Scancodes.key_a;
            case Keycodes.key_b:         return Scancodes.key_b;
            case Keycodes.key_c:         return Scancodes.key_c;
            case Keycodes.key_d:         return Scancodes.key_d;
            case Keycodes.key_e:         return Scancodes.key_e;
            case Keycodes.key_f:         return Scancodes.key_f;
            case Keycodes.key_g:         return Scancodes.key_g;
            case Keycodes.key_h:         return Scancodes.key_h;
            case Keycodes.key_i:         return Scancodes.key_i;
            case Keycodes.key_j:         return Scancodes.key_j;
            case Keycodes.key_k:         return Scancodes.key_k;
            case Keycodes.key_l:         return Scancodes.key_l;
            case Keycodes.key_m:         return Scancodes.key_m;
            case Keycodes.key_n:         return Scancodes.key_n;
            case Keycodes.key_o:         return Scancodes.key_o;
            case Keycodes.key_p:         return Scancodes.key_p;
            case Keycodes.key_q:         return Scancodes.key_q;
            case Keycodes.key_r:         return Scancodes.key_r;
            case Keycodes.key_s:         return Scancodes.key_s;
            case Keycodes.key_t:         return Scancodes.key_t;
            case Keycodes.key_u:         return Scancodes.key_u;
            case Keycodes.key_v:         return Scancodes.key_v;
            case Keycodes.key_w:         return Scancodes.key_w;
            case Keycodes.key_x:         return Scancodes.key_x;
            case Keycodes.key_y:         return Scancodes.key_y;
            case Keycodes.key_z:         return Scancodes.key_z;


			//These are unmappable because they are not keys
			//but values on the key (like a shift key combo)
			//and to hardcode them to the key you think it is,
			//would be to map it to a fixed locale probably.
			//They don't have scancodes, so we don't return one
            // case exclaim:      ;
            // case quotedbl:     ;
            // case hash:         ;
            // case percent:      ;
            // case dollar:       ;
            // case ampersand:    ;
            // case quote:        ;
            // case leftparen:    ;
            // case rightparen:   ;
            // case asterisk:     ;
            // case plus:         ;
            // case comma:        ;
            // case minus:        ;
            // case period:       ;
            // case less:         ;
            // case colon:        ;
            // case greater:      ;
            // case question:     ;
            // case at:           ;
            // case caret:        ;
            // case underscore:   ;

        } //switch(keycode)

        return Scancodes.unknown;

    } //to_scan

	/** Convert a keycode to string */
    public static function name( keycode : Int ) : String {

        //we don't use to_scan because it would consume
        //the typeable characters and we want those as unicode etc.

        if ((keycode & Scancodes.MASK) != 0) {
            return Scancodes.name(keycode &~ Scancodes.MASK);
        }

        switch(keycode) {

            case Keycodes.enter:     return Scancodes.name(Scancodes.enter);
            case Keycodes.escape:    return Scancodes.name(Scancodes.escape);
            case Keycodes.backspace: return Scancodes.name(Scancodes.backspace);
            case Keycodes.tab:       return Scancodes.name(Scancodes.tab);
            case Keycodes.space:     return Scancodes.name(Scancodes.space);
            case Keycodes.delete:    return Scancodes.name(Scancodes.delete);

            default: {

                var decoder = new haxe.Utf8();
                    decoder.addChar(keycode);

                return decoder.toString();

            } //default

        } //switch(keycode)

    } //name

    public static var unknown : Int                     = 0;

    public static var enter : Int                       = 13;
    public static var escape : Int                      = 27;
    public static var backspace : Int                   = 8;
    public static var tab : Int                         = 9;
    public static var space : Int                       = 32;
    public static var exclaim : Int                     = 33;
    public static var quotedbl : Int                    = 34;
    public static var hash : Int                        = 35;
    public static var percent : Int                     = 37;
    public static var dollar : Int                      = 36;
    public static var ampersand : Int                   = 38;
    public static var quote : Int                       = 39;
    public static var leftparen : Int                   = 40;
    public static var rightparen : Int                  = 41;
    public static var asterisk : Int                    = 42;
    public static var plus : Int                        = 43;
    public static var comma : Int                       = 44;
    public static var minus : Int                       = 45;
    public static var period : Int                      = 46;
    public static var slash : Int                       = 47;
    public static var key_0 : Int                       = 48;
    public static var key_1 : Int                       = 49;
    public static var key_2 : Int                       = 50;
    public static var key_3 : Int                       = 51;
    public static var key_4 : Int                       = 52;
    public static var key_5 : Int                       = 53;
    public static var key_6 : Int                       = 54;
    public static var key_7 : Int                       = 55;
    public static var key_8 : Int                       = 56;
    public static var key_9 : Int                       = 57;
    public static var colon : Int                       = 58;
    public static var semicolon : Int                   = 59;
    public static var less : Int                        = 60;
    public static var equals : Int                      = 61;
    public static var greater : Int                     = 62;
    public static var question : Int                    = 63;
    public static var at : Int                          = 64;
    /*
       Skip uppercase letters
     */
    public static var leftbracket : Int                 = 91;
    public static var backslash : Int                   = 92;
    public static var rightbracket : Int                = 93;
    public static var caret : Int                       = 94;
    public static var underscore : Int                  = 95;
    public static var backquote : Int                   = 96;
    public static var key_a : Int                       = 97;
    public static var key_b : Int                       = 98;
    public static var key_c : Int                       = 99;
    public static var key_d : Int                       = 100;
    public static var key_e : Int                       = 101;
    public static var key_f : Int                       = 102;
    public static var key_g : Int                       = 103;
    public static var key_h : Int                       = 104;
    public static var key_i : Int                       = 105;
    public static var key_j : Int                       = 106;
    public static var key_k : Int                       = 107;
    public static var key_l : Int                       = 108;
    public static var key_m : Int                       = 109;
    public static var key_n : Int                       = 110;
    public static var key_o : Int                       = 111;
    public static var key_p : Int                       = 112;
    public static var key_q : Int                       = 113;
    public static var key_r : Int                       = 114;
    public static var key_s : Int                       = 115;
    public static var key_t : Int                       = 116;
    public static var key_u : Int                       = 117;
    public static var key_v : Int                       = 118;
    public static var key_w : Int                       = 119;
    public static var key_x : Int                       = 120;
    public static var key_y : Int                       = 121;
    public static var key_z : Int                       = 122;

    public static var capslock : Int             = from_scan(Scancodes.capslock);

    public static var f1 : Int                   = from_scan(Scancodes.f1);
    public static var f2 : Int                   = from_scan(Scancodes.f2);
    public static var f3 : Int                   = from_scan(Scancodes.f3);
    public static var f4 : Int                   = from_scan(Scancodes.f4);
    public static var f5 : Int                   = from_scan(Scancodes.f5);
    public static var f6 : Int                   = from_scan(Scancodes.f6);
    public static var f7 : Int                   = from_scan(Scancodes.f7);
    public static var f8 : Int                   = from_scan(Scancodes.f8);
    public static var f9 : Int                   = from_scan(Scancodes.f9);
    public static var f10 : Int                  = from_scan(Scancodes.f10);
    public static var f11 : Int                  = from_scan(Scancodes.f11);
    public static var f12 : Int                  = from_scan(Scancodes.f12);

    public static var printscreen : Int          = from_scan(Scancodes.printscreen);
    public static var scrolllock : Int           = from_scan(Scancodes.scrolllock);
    public static var pause : Int                = from_scan(Scancodes.pause);
    public static var insert : Int               = from_scan(Scancodes.insert);
    public static var home : Int                 = from_scan(Scancodes.home);
    public static var pageup : Int               = from_scan(Scancodes.pageup);
    public static var delete : Int               = 127;
    public static var end : Int                  = from_scan(Scancodes.end);
    public static var pagedown : Int             = from_scan(Scancodes.pagedown);
    public static var right : Int                = from_scan(Scancodes.right);
    public static var left : Int                 = from_scan(Scancodes.left);
    public static var down : Int                 = from_scan(Scancodes.down);
    public static var up : Int                   = from_scan(Scancodes.up);

    public static var numlockclear : Int         = from_scan(Scancodes.numlockclear);
    public static var kp_divide : Int            = from_scan(Scancodes.kp_divide);
    public static var kp_multiply : Int          = from_scan(Scancodes.kp_multiply);
    public static var kp_minus : Int             = from_scan(Scancodes.kp_minus);
    public static var kp_plus : Int              = from_scan(Scancodes.kp_plus);
    public static var kp_enter : Int             = from_scan(Scancodes.kp_enter);
    public static var kp_1 : Int                 = from_scan(Scancodes.kp_1);
    public static var kp_2 : Int                 = from_scan(Scancodes.kp_2);
    public static var kp_3 : Int                 = from_scan(Scancodes.kp_3);
    public static var kp_4 : Int                 = from_scan(Scancodes.kp_4);
    public static var kp_5 : Int                 = from_scan(Scancodes.kp_5);
    public static var kp_6 : Int                 = from_scan(Scancodes.kp_6);
    public static var kp_7 : Int                 = from_scan(Scancodes.kp_7);
    public static var kp_8 : Int                 = from_scan(Scancodes.kp_8);
    public static var kp_9 : Int                 = from_scan(Scancodes.kp_9);
    public static var kp_0 : Int                 = from_scan(Scancodes.kp_0);
    public static var kp_period : Int            = from_scan(Scancodes.kp_period);

    public static var application : Int          = from_scan(Scancodes.application);
    public static var power : Int                = from_scan(Scancodes.power);
    public static var kp_equals : Int            = from_scan(Scancodes.kp_equals);
    public static var f13 : Int                  = from_scan(Scancodes.f13);
    public static var f14 : Int                  = from_scan(Scancodes.f14);
    public static var f15 : Int                  = from_scan(Scancodes.f15);
    public static var f16 : Int                  = from_scan(Scancodes.f16);
    public static var f17 : Int                  = from_scan(Scancodes.f17);
    public static var f18 : Int                  = from_scan(Scancodes.f18);
    public static var f19 : Int                  = from_scan(Scancodes.f19);
    public static var f20 : Int                  = from_scan(Scancodes.f20);
    public static var f21 : Int                  = from_scan(Scancodes.f21);
    public static var f22 : Int                  = from_scan(Scancodes.f22);
    public static var f23 : Int                  = from_scan(Scancodes.f23);
    public static var f24 : Int                  = from_scan(Scancodes.f24);
    public static var execute : Int              = from_scan(Scancodes.execute);
    public static var help : Int                 = from_scan(Scancodes.help);
    public static var menu : Int                 = from_scan(Scancodes.menu);
    public static var select : Int               = from_scan(Scancodes.select);
    public static var stop : Int                 = from_scan(Scancodes.stop);
    public static var again : Int                = from_scan(Scancodes.again);
    public static var undo : Int                 = from_scan(Scancodes.undo);
    public static var cut : Int                  = from_scan(Scancodes.cut);
    public static var copy : Int                 = from_scan(Scancodes.copy);
    public static var paste : Int                = from_scan(Scancodes.paste);
    public static var find : Int                 = from_scan(Scancodes.find);
    public static var mute : Int                 = from_scan(Scancodes.mute);
    public static var volumeup : Int             = from_scan(Scancodes.volumeup);
    public static var volumedown : Int           = from_scan(Scancodes.volumedown);
    public static var kp_comma : Int             = from_scan(Scancodes.kp_comma);
    public static var kp_equalsas400 : Int       = from_scan(Scancodes.kp_equalsas400);

    public static var alterase : Int             = from_scan(Scancodes.alterase);
    public static var sysreq : Int               = from_scan(Scancodes.sysreq);
    public static var cancel : Int               = from_scan(Scancodes.cancel);
    public static var clear : Int                = from_scan(Scancodes.clear);
    public static var prior : Int                = from_scan(Scancodes.prior);
    public static var return2 : Int              = from_scan(Scancodes.return2);
    public static var separator : Int            = from_scan(Scancodes.separator);
    public static var out : Int                  = from_scan(Scancodes.out);
    public static var oper : Int                 = from_scan(Scancodes.oper);
    public static var clearagain : Int           = from_scan(Scancodes.clearagain);
    public static var crsel : Int                = from_scan(Scancodes.crsel);
    public static var exsel : Int                = from_scan(Scancodes.exsel);

    public static var kp_00 : Int                = from_scan(Scancodes.kp_00);
    public static var kp_000 : Int               = from_scan(Scancodes.kp_000);
    public static var thousandsseparator : Int   = from_scan(Scancodes.thousandsseparator);
    public static var decimalseparator : Int     = from_scan(Scancodes.decimalseparator);
    public static var currencyunit : Int         = from_scan(Scancodes.currencyunit);
    public static var currencysubunit : Int      = from_scan(Scancodes.currencysubunit);
    public static var kp_leftparen : Int         = from_scan(Scancodes.kp_leftparen);
    public static var kp_rightparen : Int        = from_scan(Scancodes.kp_rightparen);
    public static var kp_leftbrace : Int         = from_scan(Scancodes.kp_leftbrace);
    public static var kp_rightbrace : Int        = from_scan(Scancodes.kp_rightbrace);
    public static var kp_tab : Int               = from_scan(Scancodes.kp_tab);
    public static var kp_backspace : Int         = from_scan(Scancodes.kp_backspace);
    public static var kp_a : Int                 = from_scan(Scancodes.kp_a);
    public static var kp_b : Int                 = from_scan(Scancodes.kp_b);
    public static var kp_c : Int                 = from_scan(Scancodes.kp_c);
    public static var kp_d : Int                 = from_scan(Scancodes.kp_d);
    public static var kp_e : Int                 = from_scan(Scancodes.kp_e);
    public static var kp_f : Int                 = from_scan(Scancodes.kp_f);
    public static var kp_xor : Int               = from_scan(Scancodes.kp_xor);
    public static var kp_power : Int             = from_scan(Scancodes.kp_power);
    public static var kp_percent : Int           = from_scan(Scancodes.kp_percent);
    public static var kp_less : Int              = from_scan(Scancodes.kp_less);
    public static var kp_greater : Int           = from_scan(Scancodes.kp_greater);
    public static var kp_ampersand : Int         = from_scan(Scancodes.kp_ampersand);
    public static var kp_dblampersand : Int      = from_scan(Scancodes.kp_dblampersand);
    public static var kp_verticalbar : Int       = from_scan(Scancodes.kp_verticalbar);
    public static var kp_dblverticalbar : Int    = from_scan(Scancodes.kp_dblverticalbar);
    public static var kp_colon : Int             = from_scan(Scancodes.kp_colon);
    public static var kp_hash : Int              = from_scan(Scancodes.kp_hash);
    public static var kp_space : Int             = from_scan(Scancodes.kp_space);
    public static var kp_at : Int                = from_scan(Scancodes.kp_at);
    public static var kp_exclam : Int            = from_scan(Scancodes.kp_exclam);
    public static var kp_memstore : Int          = from_scan(Scancodes.kp_memstore);
    public static var kp_memrecall : Int         = from_scan(Scancodes.kp_memrecall);
    public static var kp_memclear : Int          = from_scan(Scancodes.kp_memclear);
    public static var kp_memadd : Int            = from_scan(Scancodes.kp_memadd);
    public static var kp_memsubtract : Int       = from_scan(Scancodes.kp_memsubtract);
    public static var kp_memmultiply : Int       = from_scan(Scancodes.kp_memmultiply);
    public static var kp_memdivide : Int         = from_scan(Scancodes.kp_memdivide);
    public static var kp_plusminus : Int         = from_scan(Scancodes.kp_plusminus);
    public static var kp_clear : Int             = from_scan(Scancodes.kp_clear);
    public static var kp_clearentry : Int        = from_scan(Scancodes.kp_clearentry);
    public static var kp_binary : Int            = from_scan(Scancodes.kp_binary);
    public static var kp_octal : Int             = from_scan(Scancodes.kp_octal);
    public static var kp_decimal : Int           = from_scan(Scancodes.kp_decimal);
    public static var kp_hexadecimal : Int       = from_scan(Scancodes.kp_hexadecimal);

    public static var lctrl : Int                = from_scan(Scancodes.lctrl);
    public static var lshift : Int               = from_scan(Scancodes.lshift);
    public static var lalt : Int                 = from_scan(Scancodes.lalt);
    public static var lmeta : Int                = from_scan(Scancodes.lmeta);
    public static var rctrl : Int                = from_scan(Scancodes.rctrl);
    public static var rshift : Int               = from_scan(Scancodes.rshift);
    public static var ralt : Int                 = from_scan(Scancodes.ralt);
    public static var rmeta : Int                = from_scan(Scancodes.rmeta);

    public static var mode : Int                 = from_scan(Scancodes.mode);

    public static var audionext : Int            = from_scan(Scancodes.audionext);
    public static var audioprev : Int            = from_scan(Scancodes.audioprev);
    public static var audiostop : Int            = from_scan(Scancodes.audiostop);
    public static var audioplay : Int            = from_scan(Scancodes.audioplay);
    public static var audiomute : Int            = from_scan(Scancodes.audiomute);
    public static var mediaselect : Int          = from_scan(Scancodes.mediaselect);
    public static var www : Int                  = from_scan(Scancodes.www);
    public static var mail : Int                 = from_scan(Scancodes.mail);
    public static var calculator : Int           = from_scan(Scancodes.calculator);
    public static var computer : Int             = from_scan(Scancodes.computer);
    public static var ac_search : Int            = from_scan(Scancodes.ac_search);
    public static var ac_home : Int              = from_scan(Scancodes.ac_home);
    public static var ac_back : Int              = from_scan(Scancodes.ac_back);
    public static var ac_forward : Int           = from_scan(Scancodes.ac_forward);
    public static var ac_stop : Int              = from_scan(Scancodes.ac_stop);
    public static var ac_refresh : Int           = from_scan(Scancodes.ac_refresh);
    public static var ac_bookmarks : Int         = from_scan(Scancodes.ac_bookmarks);

    public static var brightnessdown : Int       = from_scan(Scancodes.brightnessdown);
    public static var brightnessup : Int         = from_scan(Scancodes.brightnessup);
    public static var displayswitch : Int        = from_scan(Scancodes.displayswitch);
    public static var kbdillumtoggle : Int       = from_scan(Scancodes.kbdillumtoggle);
    public static var kbdillumdown : Int         = from_scan(Scancodes.kbdillumdown);
    public static var kbdillumup : Int           = from_scan(Scancodes.kbdillumup);
    public static var eject : Int                = from_scan(Scancodes.eject);
    public static var sleep : Int                = from_scan(Scancodes.sleep);

} //Keycodes


/** The scancode class. The values below come directly from SDL header include files,
but they aren't specific to SDL so they are used generically */
@:noCompletion class Scancodes {

	/** Convert a scancode to a name */
    public static function name( scancode : Int ) : String {

        var res = null;

        if (scancode >= 0 && scancode < scancode_names.length) {
            res = scancode_names[scancode];
        }

        return res != null ? res : "";

    } //name

	//special value remains caps
    public static var MASK:Int                      = (1<<30);

    public static var unknown : Int                 = 0;

   // Usage page 0x07
   // These values are from usage page 0x07 (USB keyboard page).

    public static var key_a : Int                   = 4;
    public static var key_b : Int                   = 5;
    public static var key_c : Int                   = 6;
    public static var key_d : Int                   = 7;
    public static var key_e : Int                   = 8;
    public static var key_f : Int                   = 9;
    public static var key_g : Int                   = 10;
    public static var key_h : Int                   = 11;
    public static var key_i : Int                   = 12;
    public static var key_j : Int                   = 13;
    public static var key_k : Int                   = 14;
    public static var key_l : Int                   = 15;
    public static var key_m : Int                   = 16;
    public static var key_n : Int                   = 17;
    public static var key_o : Int                   = 18;
    public static var key_p : Int                   = 19;
    public static var key_q : Int                   = 20;
    public static var key_r : Int                   = 21;
    public static var key_s : Int                   = 22;
    public static var key_t : Int                   = 23;
    public static var key_u : Int                   = 24;
    public static var key_v : Int                   = 25;
    public static var key_w : Int                   = 26;
    public static var key_x : Int                   = 27;
    public static var key_y : Int                   = 28;
    public static var key_z : Int                   = 29;

    public static var key_1 : Int                   = 30;
    public static var key_2 : Int                   = 31;
    public static var key_3 : Int                   = 32;
    public static var key_4 : Int                   = 33;
    public static var key_5 : Int                   = 34;
    public static var key_6 : Int                   = 35;
    public static var key_7 : Int                   = 36;
    public static var key_8 : Int                   = 37;
    public static var key_9 : Int                   = 38;
    public static var key_0 : Int                   = 39;

    public static var enter : Int                   = 40;
    public static var escape : Int                  = 41;
    public static var backspace : Int               = 42;
    public static var tab : Int                     = 43;
    public static var space : Int                   = 44;

    public static var minus : Int                   = 45;
    public static var equals : Int                  = 46;
    public static var leftbracket : Int             = 47;
    public static var rightbracket : Int            = 48;

	/** Located at the lower left of the return
		key on ISO keyboards and at the right end
		of the QWERTY row on ANSI keyboards.
		Produces REVERSE SOLIDUS (backslash) and
		VERTICAL LINE in a US layout, REVERSE
		SOLIDUS and VERTICAL LINE in a UK Mac
		layout, NUMBER SIGN and TILDE in a UK
		Windows layout, DOLLAR SIGN and POUND SIGN
		in a Swiss German layout, NUMBER SIGN and
		APOSTROPHE in a German layout, GRAVE
		ACCENT and POUND SIGN in a French Mac
		layout, and ASTERISK and MICRO SIGN in a
		French Windows layout.
	*/
    public static var backslash : Int               = 49;

	/** ISO USB keyboards actually use this code
		instead of 49 for the same key, but all
		OSes I've seen treat the two codes
		identically. So, as an implementor, unless
		your keyboard generates both of those
		codes and your OS treats them differently,
		you should generate public static var BACKSLASH
		instead of this code. As a user, you
		should not rely on this code because SDL
		will never generate it with most (all?)
		keyboards.
	*/
    public static var nonushash : Int          = 50;
    public static var semicolon : Int          = 51;
    public static var apostrophe : Int         = 52;

	/** Located in the top left corner (on both ANSI
		and ISO keyboards). Produces GRAVE ACCENT and
		TILDE in a US Windows layout and in US and UK
		Mac layouts on ANSI keyboards, GRAVE ACCENT
		and NOT SIGN in a UK Windows layout, SECTION
		SIGN and PLUS-MINUS SIGN in US and UK Mac
		layouts on ISO keyboards, SECTION SIGN and
		DEGREE SIGN in a Swiss German layout (Mac:
		only on ISO keyboards); CIRCUMFLEX ACCENT and
		DEGREE SIGN in a German layout (Mac: only on
		ISO keyboards), SUPERSCRIPT TWO and TILDE in a
		French Windows layout, COMMERCIAL AT and
		NUMBER SIGN in a French Mac layout on ISO
		keyboards, and LESS-THAN SIGN and GREATER-THAN
		SIGN in a Swiss German, German, or French Mac
		layout on ANSI keyboards.
	*/
    public static var grave : Int              = 53;
    public static var comma : Int              = 54;
    public static var period : Int             = 55;
    public static var slash : Int              = 56;

    public static var capslock : Int           = 57;

    public static var f1 : Int                 = 58;
    public static var f2 : Int                 = 59;
    public static var f3 : Int                 = 60;
    public static var f4 : Int                 = 61;
    public static var f5 : Int                 = 62;
    public static var f6 : Int                 = 63;
    public static var f7 : Int                 = 64;
    public static var f8 : Int                 = 65;
    public static var f9 : Int                 = 66;
    public static var f10 : Int                = 67;
    public static var f11 : Int                = 68;
    public static var f12 : Int                = 69;

    public static var printscreen : Int        = 70;
    public static var scrolllock : Int         = 71;
    public static var pause : Int              = 72;

	/** insert on PC, help on some Mac keyboards (but does send code 73, not 117) */
    public static var insert : Int             = 73;
    public static var home : Int               = 74;
    public static var pageup : Int             = 75;
    public static var delete : Int             = 76;
    public static var end : Int                = 77;
    public static var pagedown : Int           = 78;
    public static var right : Int              = 79;
    public static var left : Int               = 80;
    public static var down : Int               = 81;
    public static var up : Int                 = 82;

	/** num lock on PC, clear on Mac keyboards */
    public static var numlockclear : Int       = 83;
    public static var kp_divide : Int          = 84;
    public static var kp_multiply : Int        = 85;
    public static var kp_minus : Int           = 86;
    public static var kp_plus : Int            = 87;
    public static var kp_enter : Int           = 88;
    public static var kp_1 : Int               = 89;
    public static var kp_2 : Int               = 90;
    public static var kp_3 : Int               = 91;
    public static var kp_4 : Int               = 92;
    public static var kp_5 : Int               = 93;
    public static var kp_6 : Int               = 94;
    public static var kp_7 : Int               = 95;
    public static var kp_8 : Int               = 96;
    public static var kp_9 : Int               = 97;
    public static var kp_0 : Int               = 98;
    public static var kp_period : Int          = 99;


	/** This is the additional key that ISO
		keyboards have over ANSI ones,
		located between left shift and Y.
		Produces GRAVE ACCENT and TILDE in a
		US or UK Mac layout, REVERSE SOLIDUS
		(backslash) and VERTICAL LINE in a
		US or UK Windows layout, and
		LESS-THAN SIGN and GREATER-THAN SIGN
		in a Swiss German, German, or French
		layout. */
    public static var nonusbackslash : Int     = 100;

	/** windows contextual menu, compose */
    public static var application : Int        = 101;

	/** The USB document says this is a status flag,
		not a physical key - but some Mac keyboards
		do have a power key. */
    public static var power : Int              = 102;
    public static var kp_equals : Int          = 103;
    public static var f13 : Int                = 104;
    public static var f14 : Int                = 105;
    public static var f15 : Int                = 106;
    public static var f16 : Int                = 107;
    public static var f17 : Int                = 108;
    public static var f18 : Int                = 109;
    public static var f19 : Int                = 110;
    public static var f20 : Int                = 111;
    public static var f21 : Int                = 112;
    public static var f22 : Int                = 113;
    public static var f23 : Int                = 114;
    public static var f24 : Int                = 115;
    public static var execute : Int            = 116;
    public static var help : Int               = 117;
    public static var menu : Int               = 118;
    public static var select : Int             = 119;
    public static var stop : Int               = 120;

	/** redo */
    public static var again : Int              = 121;
    public static var undo : Int               = 122;
    public static var cut : Int                = 123;
    public static var copy : Int               = 124;
    public static var paste : Int              = 125;
    public static var find : Int               = 126;
    public static var mute : Int               = 127;
    public static var volumeup : Int           = 128;
    public static var volumedown : Int         = 129;

	// not sure whether there's a reason to enable these
	//     public static var lockingcapslock = 130,
	//     public static var lockingnumlock = 131,
	//     public static var lockingscrolllock = 132,

    public static var kp_comma : Int           = 133;
    public static var kp_equalsas400 : Int     = 134;

	/** used on Asian keyboards; see footnotes in USB doc */
    public static var international1 : Int     = 135;
    public static var international2 : Int     = 136;

	/** Yen */
    public static var international3 : Int     = 137;
    public static var international4 : Int     = 138;
    public static var international5 : Int     = 139;
    public static var international6 : Int     = 140;
    public static var international7 : Int     = 141;
    public static var international8 : Int     = 142;
    public static var international9 : Int     = 143;
	/** Hangul/English toggle */
    public static var lang1 : Int              = 144;
	/** Hanja conversion */
    public static var lang2 : Int              = 145;
	/** Katakana */
    public static var lang3 : Int              = 146;
	/** Hiragana */
    public static var lang4 : Int              = 147;
	/** Zenkaku/Hankaku */
    public static var lang5 : Int              = 148;
	/** reserved */
    public static var lang6 : Int              = 149;
	/** reserved */
    public static var lang7 : Int              = 150;
	/** reserved */
    public static var lang8 : Int              = 151;
	/** reserved */
    public static var lang9 : Int              = 152;
	/** Erase-Eaze */
    public static var alterase : Int           = 153;
    public static var sysreq : Int             = 154;
    public static var cancel : Int             = 155;
    public static var clear : Int              = 156;
    public static var prior : Int              = 157;
    public static var return2 : Int            = 158;
    public static var separator : Int          = 159;
    public static var out : Int                = 160;
    public static var oper : Int               = 161;
    public static var clearagain : Int         = 162;
    public static var crsel : Int              = 163;
    public static var exsel : Int              = 164;

    public static var kp_00 : Int              = 176;
    public static var kp_000 : Int             = 177;
    public static var thousandsseparator : Int = 178;
    public static var decimalseparator : Int   = 179;
    public static var currencyunit : Int       = 180;
    public static var currencysubunit : Int    = 181;
    public static var kp_leftparen : Int       = 182;
    public static var kp_rightparen : Int      = 183;
    public static var kp_leftbrace : Int       = 184;
    public static var kp_rightbrace : Int      = 185;
    public static var kp_tab : Int             = 186;
    public static var kp_backspace : Int       = 187;
    public static var kp_a : Int               = 188;
    public static var kp_b : Int               = 189;
    public static var kp_c : Int               = 190;
    public static var kp_d : Int               = 191;
    public static var kp_e : Int               = 192;
    public static var kp_f : Int               = 193;
    public static var kp_xor : Int             = 194;
    public static var kp_power : Int           = 195;
    public static var kp_percent : Int         = 196;
    public static var kp_less : Int            = 197;
    public static var kp_greater : Int         = 198;
    public static var kp_ampersand : Int       = 199;
    public static var kp_dblampersand : Int    = 200;
    public static var kp_verticalbar : Int     = 201;
    public static var kp_dblverticalbar : Int  = 202;
    public static var kp_colon : Int           = 203;
    public static var kp_hash : Int            = 204;
    public static var kp_space : Int           = 205;
    public static var kp_at : Int              = 206;
    public static var kp_exclam : Int          = 207;
    public static var kp_memstore : Int        = 208;
    public static var kp_memrecall : Int       = 209;
    public static var kp_memclear : Int        = 210;
    public static var kp_memadd : Int          = 211;
    public static var kp_memsubtract : Int     = 212;
    public static var kp_memmultiply : Int     = 213;
    public static var kp_memdivide : Int       = 214;
    public static var kp_plusminus : Int       = 215;
    public static var kp_clear : Int           = 216;
    public static var kp_clearentry : Int      = 217;
    public static var kp_binary : Int          = 218;
    public static var kp_octal : Int           = 219;
    public static var kp_decimal : Int         = 220;
    public static var kp_hexadecimal : Int     = 221;

    public static var lctrl : Int              = 224;
    public static var lshift : Int             = 225;
	/** alt, option */
    public static var lalt : Int               = 226;
	/** windows, command (apple), meta */
    public static var lmeta : Int              = 227;
    public static var rctrl : Int              = 228;
    public static var rshift : Int             = 229;
	/** alt gr, option */
    public static var ralt : Int               = 230;
	/** windows, command (apple), meta */
    public static var rmeta : Int              = 231;

	/** Not sure if this is really not covered
    by any of the above, but since there's a
    special KMOD_MODE for it I'm adding it here */
    public static var mode : Int               = 257;


    //
    //    Usage page 0x0C
    //    These values are mapped from usage page 0x0C (USB consumer page).

    public static var audionext : Int          = 258;
    public static var audioprev : Int          = 259;
    public static var audiostop : Int          = 260;
    public static var audioplay : Int          = 261;
    public static var audiomute : Int          = 262;
    public static var mediaselect : Int        = 263;
    public static var www : Int                = 264;
    public static var mail : Int               = 265;
    public static var calculator : Int         = 266;
    public static var computer : Int           = 267;
    public static var ac_search : Int          = 268;
    public static var ac_home : Int            = 269;
    public static var ac_back : Int            = 270;
    public static var ac_forward : Int         = 271;
    public static var ac_stop : Int            = 272;
    public static var ac_refresh : Int         = 273;
    public static var ac_bookmarks : Int       = 274;

      // Walther keys
      // These are values that Christian Walther added (for mac keyboard?).

    public static var brightnessdown : Int     = 275;
    public static var brightnessup : Int       = 276;

	/** display mirroring/dual display switch, video mode switch */
    public static var displayswitch : Int      = 277;

    public static var kbdillumtoggle : Int     = 278;
    public static var kbdillumdown : Int       = 279;
    public static var kbdillumup : Int         = 280;
    public static var eject : Int              = 281;
    public static var sleep : Int              = 282;

    public static var app1 : Int               = 283;
    public static var app2 : Int               = 284;

    static var scancode_names:Array<String> = [
        null, null, null, null,
        "A",
        "B",
        "C",
        "D",
        "E",
        "F",
        "G",
        "H",
        "I",
        "J",
        "K",
        "L",
        "M",
        "N",
        "O",
        "P",
        "Q",
        "R",
        "S",
        "T",
        "U",
        "V",
        "W",
        "X",
        "Y",
        "Z",
        "1",
        "2",
        "3",
        "4",
        "5",
        "6",
        "7",
        "8",
        "9",
        "0",
        "Enter",
        "Escape",
        "Backspace",
        "Tab",
        "Space",
        "-",
        "=",
        "[",
        "]",
        "\\",
        "#",
        ";",
        "'",
        "`",
        ",",
        ".",
        "/",
        "CapsLock",
        "F1",
        "F2",
        "F3",
        "F4",
        "F5",
        "F6",
        "F7",
        "F8",
        "F9",
        "F10",
        "F11",
        "F12",
        "PrintScreen",
        "ScrollLock",
        "Pause",
        "Insert",
        "Home",
        "PageUp",
        "Delete",
        "End",
        "PageDown",
        "Right",
        "Left",
        "Down",
        "Up",
        "Numlock",
        "Keypad /",
        "Keypad *",
        "Keypad -",
        "Keypad +",
        "Keypad Enter",
        "Keypad 1",
        "Keypad 2",
        "Keypad 3",
        "Keypad 4",
        "Keypad 5",
        "Keypad 6",
        "Keypad 7",
        "Keypad 8",
        "Keypad 9",
        "Keypad 0",
        "Keypad .",
        null,
        "Application",
        "Power",
        "Keypad =",
        "F13",
        "F14",
        "F15",
        "F16",
        "F17",
        "F18",
        "F19",
        "F20",
        "F21",
        "F22",
        "F23",
        "F24",
        "Execute",
        "Help",
        "Menu",
        "Select",
        "Stop",
        "Again",
        "Undo",
        "Cut",
        "Copy",
        "Paste",
        "Find",
        "Mute",
        "VolumeUp",
        "VolumeDown",
        null, null, null,
        "Keypad ,",
        "Keypad = (AS400)",
        null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        "AltErase",
        "SysReq",
        "Cancel",
        "Clear",
        "Prior",
        "Enter",
        "Separator",
        "Out",
        "Oper",
        "Clear / Again",
        "CrSel",
        "ExSel",
        null, null, null, null, null, null, null, null, null, null, null,
        "Keypad 00",
        "Keypad 000",
        "ThousandsSeparator",
        "DecimalSeparator",
        "CurrencyUnit",
        "CurrencySubUnit",
        "Keypad (",
        "Keypad )",
        "Keypad {",
        "Keypad }",
        "Keypad Tab",
        "Keypad Backspace",
        "Keypad A",
        "Keypad B",
        "Keypad C",
        "Keypad D",
        "Keypad E",
        "Keypad F",
        "Keypad XOR",
        "Keypad ^",
        "Keypad %",
        "Keypad <",
        "Keypad >",
        "Keypad &",
        "Keypad &&",
        "Keypad |",
        "Keypad ||",
        "Keypad :",
        "Keypad #",
        "Keypad Space",
        "Keypad @",
        "Keypad !",
        "Keypad MemStore",
        "Keypad MemRecall",
        "Keypad MemClear",
        "Keypad MemAdd",
        "Keypad MemSubtract",
        "Keypad MemMultiply",
        "Keypad MemDivide",
        "Keypad +/-",
        "Keypad Clear",
        "Keypad ClearEntry",
        "Keypad Binary",
        "Keypad Octal",
        "Keypad Decimal",
        "Keypad Hexadecimal",
        null, null,
        "Left Ctrl",
        "Left Shift",
        "Left Alt",
        "Left Meta",
        "Right Ctrl",
        "Right Shift",
        "Right Alt",
        "Right Meta",
        null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        "ModeSwitch",
        "AudioNext",
        "AudioPrev",
        "AudioStop",
        "AudioPlay",
        "AudioMute",
        "MediaSelect",
        "WWW",
        "Mail",
        "Calculator",
        "Computer",
        "AC Search",
        "AC Home",
        "AC Back",
        "AC Forward",
        "AC Stop",
        "AC Refresh",
        "AC Bookmarks",
        "BrightnessDown",
        "BrightnessUp",
        "DisplaySwitch",
        "KBDIllumToggle",
        "KBDIllumDown",
        "KBDIllumUp",
        "Eject",
        "Sleep",
    ]; //scancode names


} //Scancodes

 