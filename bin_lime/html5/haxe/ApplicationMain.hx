import MainLime;
import lime.Assets;


class ApplicationMain {
	
	
	public static var config:lime.app.Config;
	public static var preloader:lime.app.Preloader;
	
	private static var app:lime.app.Application;
	
	
	public static function create ():Void {
		
		#if !munit
		//app = new MainLime ();
		//app.create (config);
		#end
		
		preloader = new lime.app.Preloader ();
		preloader.onComplete = start;
		preloader.create (config);
		
		#if (js && html5)
		var urls = [];
		var types = [];
		
		
		
		if (config.assetsPrefix != null) {
			
			for (i in 0...urls.length) {
				
				if (types[i] != AssetType.FONT) {
					
					urls[i] = config.assetsPrefix + urls[i];
					
				}
				
			}
			
		}
		
		preloader.load (urls, types);
		#end
		
	}
	
	
	public static function main () {
		
		config = {
			
			antialiasing: Std.int (0),
			background: Std.int (16777215),
			borderless: false,
			company: "Krtolica Vujadin",
			depthBuffer: true,
			file: "BabylonHx_Lime",
			fps: Std.int (0),
			fullscreen: false,
			hardware: true,
			height: Std.int (0),
			orientation: "",
			packageName: "com.babylonhx",
			resizable: true,
			stencilBuffer: true,
			title: "BabylonHx_Lime",
			version: "1.0.0",
			vsync: false,
			width: Std.int (0),
			
		}
		
		#if (!html5 || munit)
		create ();
		#end
		
	}
	
	
	public static function start ():Void {
		
		#if !munit
		
		app = new MainLime ();
		app.create (config);
		var result = app.exec ();
		
		#if (sys && !nodejs && !emscripten)
		Sys.exit (result);
		#end
		
		#else
		
		new MainLime ();
		
		#end
		
	}
	
	
	#if neko
	@:noCompletion public static function __init__ () {
		
		var loader = new neko.vm.Loader (untyped $loader);
		loader.addPath (haxe.io.Path.directory (Sys.executablePath ()));
		loader.addPath ("./");
		loader.addPath ("@executable_path/");
		
	}
	#end
	
	
}
