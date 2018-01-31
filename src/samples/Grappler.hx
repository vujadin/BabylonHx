package samples;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Grappler
{

	public function new() 
	{
		
	}
	
}

/*
			Copyright (c) 2010, Jason Brown. All rights reserved.
			Code licensed under the BSD License:
			http://somethinghitme.com/projects/jsgrapple/license.txt
			
			Concept from the awesome game Wire Hang Redux (http://www.gingerbeardman.com/wirehang/) by Matt Sephton
			
			*/

var c = Math,
    d = c.random,
    f = [],
    i, j, k, l, m, n, q, s, t, u, v, w, fa=false,tr=true,y = 80;
a = document.body.children.c;
a.width = 256;
a.height = 512;
b = a.getContext("2d");
g = 128;
h = 400;
for (e = 0; e < 3; e++) f[e] = {
    x: d() * 186,
    y: 170 * e
};
r = x = p = o = aa=0;
a.onclick = function (z) {
    if (!w) {
        r = tr;
        s = g;
        t = h;
        l = z.clientX - s;
        m = z.clientY - t;
        v = u = c.atan2(m, l) * 57.32;
        u > -170 && u < -10 && (w = tr)
    }
};
setInterval(function () {
    with(b) {
        clearRect(0, 0, 256, 512);
        fillText(x + '/' + aa, 5, 15);
        for (e = 0; e < 3; e++) {
            if (f[e].y > 512) {
                f[e].x = d() * 186;
                f[e].y = 0
            }
            fillRect(f[e].x, q ? f[e].y -= p * 4 : f[e].y, y, 15)
        }
        fillRect(g, h, 5, 5);
        if (r) {
            if (q) {
                j -= p * 4;
                x++
            }
            y = 80 - x / 65;
            l = g - i;
            m = h - j;
            n = c.sqrt(l * l + m * m);
            if (k && h > j + 20) {
                beginPath();
                moveTo(g, h);
                lineTo(i, j);
                stroke();
                o += (i - g) / (n * 30);
                p += (j - h) / (n * 30)
            } else k = fa;
            if (w) {
                s += c.cos(v * 0.017) * 15;
                t -= c.sin(u * -0.017) * 15;
                fillRect(s, t, 4, 4);
                for (e = 0; e < 3; e++) {
                    if (s > f[e].x && s < f[e].x + y && t > f[e].y && t < f[e].y + 15) {
                        k = tr;
                        w = fa;
                        i = s;
                        j = t;
                        return
                    }
                    k = fa
                }
                t < 0 && (w = fa);
                (s > 256 || s < 0) && (v -= u)
            }
            p > 0 && (q = fa);
            p += .01;
            q || (h += p * 4);
            g += o;
            h < 170 && (q = tr);
            if(h > 512){r = fa;x>aa&&(aa=x)};
            (g < 0 || g > 256) && (o = -o)
        }else{g=128;h =400;y=80;x=p=o=w=0}
    }
}, 10);