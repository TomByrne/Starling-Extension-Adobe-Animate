import flash.display.Sprite;
import flash.filesystem.File;
import flash.geom.Rectangle;
import starling.core.Starling;
import starling.events.Event;
import starling.extensions.animate.AssetManagerEx;

@:meta(SWF(width="320",height="480",frameRate="60",backgroundColor="#ffffff"))

class StartupMobile extends Sprite
{
    private var _starling : Starling;
    
    public function new()
    {
        super();
        var viewPort : Rectangle = new Rectangle(0, 0, 
        stage.fullScreenWidth, stage.fullScreenHeight);
        
        _starling = new Starling(Demo, stage, viewPort);
        _starling.skipUnchangedFrames = true;
        _starling.addEventListener(Event.ROOT_CREATED, loadAssets);
        _starling.start();
    }
    
    private function loadAssets() : Void
    {
        var demo : Demo = try cast(_starling.root, Demo) catch(e:Dynamic) null;
        var appDir : File = File.applicationDirectory;
        var assets : AssetManagerEx = new AssetManagerEx();
        assets.enqueue(appDir.resolvePath("assets/ninja-girl/"));
        assets.enqueue(appDir.resolvePath("assets/bunny/"));
        assets.enqueue(appDir.resolvePath("assets/background.jpg"));
        assets.loadQueue(demo.start);
    }
}

