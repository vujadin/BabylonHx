var canvas = document.createElement(navigator.isCocoonJS ? 'screencanvas' : 'canvas');
var dpr = window.devicePixelRatio;
var w= 960;
var h = 640;
canvas.width= w;
canvas.height= h;

var scaleX = window.innerWidth/w;
var scaleY = window.innerHeight/h;

canvas.style.position = "absolute";
canvas.style.width = (w * scaleX) + "px";
canvas.style.height = (h * scaleY) + "px";
canvas.style.left = (window.innerWidth * 0.5 - w * scaleX * 0.5) + "px";
canvas.style.top = (window.innerHeight * 0.5 - h * scaleY * 0.5) + "px";

document.body.appendChild(canvas);

ctx= canvas.getContext("2d");

var imgStock = [];

function initStockImages()
{
    for (var i = 0; i <= 19; ++i)
    {
        var img = new Image();
        img.src = "resources/images/digit" + i + ".png";
        imgStock.push(img);
    }
}


var friendImages =  [] ;
var spriteTypes = 0;
var spriteNumber = 100;
var backgroundColor = "black";
var speed = 0.0015;
var direction = 1;
var animationEnabled = true;


function createImages()
{
    friendImages = [];
    for (var i = 0; i < spriteNumber; ++i)
    {
        var random =  Math.floor((Math.random()*19));
        if (spriteTypes == 1) random = random % 10;
        if (spriteTypes == 2) random = 10 + random % 10;
        friendImages.push(imgStock[random]);
    }
}

initStockImages();
createImages();


var frame = 0 ;
var positions = [];
setInterval( 
    function()
    {
        if(animationEnabled) frame += direction;
        ctx.fillStyle = backgroundColor;
        ctx.fillRect(0, 0, canvas.width , canvas.height);
        for( var i = 0 ; i < friendImages.length ; ++i)
        {
            if(animationEnabled)
            {
                fx = canvas.width  / 2 + 0.5*(i/2+1) * canvas.width  * 0.05 * Math.sin( frame * speed * i/2 + Math.PI * (i%2) ) ;
                fy = canvas.height / 2 + 0.5*(i/2+1) * canvas.height * 0.05 * Math.cos( frame * speed * i/2 + Math.PI * (i%2) ) ;    
                positions[i] = {x: fx, y: fy};
            }
        
            ctx.drawImage(friendImages[i],positions[i].x,positions[i].y);
        }           
 
        
    }, 
    1000/60 
);

canvas.addEventListener("touchstart", function()
{
    Cocoon.App.forwardAsync("Cocoon.WebView.show(0, 0, " + canvas.width/2 * window.devicePixelRatio + "," + canvas.height * window.devicePixelRatio + ");");
    /*
    * Disable the touch events in the CocoonJS side so this event is not called when there is touches over the webview.
    */
    Cocoon.Touch.disable();
});

canvas.addEventListener("mousedown", function(clickEvent) 
{ 
    Cocoon.App.forwardAsync("Cocoon.WebView.show(0, 0, " + canvas.width/2 * window.devicePixelRatio + "," + canvas.height * window.devicePixelRatio + ");");
}, false);

function captureScreen()
{
    try
    {

        /* 
        * Screen Capture can be Sync or Async. Sync mode allows to capture 
        * the screen even in the middle of a frame rendering.
        * Async mode captures a final frame as soon as possible.
        * 
        * In this demo we use the External Storage to make easier extracting the saved images. 
        * In a production app its recommended to use TEMPORARY_STORAGE
        */
        Cocoon.Utils.captureScreenAsync("capture.png", "EXTERNAL_STORAGE", Cocoon.Utils.CaptureType.EVERYTHING,
        function(url)
        {
             console.log("Screen captured: " + url);
        });

    }
    catch(ex)
    {
        console.error("Error capturing screen: " + ex);
    }
}






