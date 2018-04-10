import flash.display.Sprite;
import starling.core.Starling;
import starling.events.Event;
import starling.extensions.animate.AssetManagerEx;

@:meta(SWF(width="500",height="500",frameRate="60",backgroundColor="#eeeeee"))

class StartupWeb extends Sprite
{
    private var _starling : Starling;
    
    public function new()
    {
        super();
        _starling = new Starling(Demo, stage);
        _starling.skipUnchangedFrames = true;
        _starling.addEventListener(Event.ROOT_CREATED, loadAssets);
        _starling.start();
    }
    
    private function loadAssets() : Void
    {
        var demo : Demo = try cast(_starling.root, Demo) catch(e:Dynamic) null;
        var assets : AssetManagerEx = new AssetManagerEx();
        assets.enqueue(EmbeddedAssets);
        assets.loadQueue(demo.start);
    }
}


class EmbeddedAssets
{
    // It's important to follow these naming conventions when embedding "Animate CC" animations.
    //
    // file name: [name]/Animation.json -> member name: [name]_animation
    // file name: [name]/spritemap.json -> member name: [name]_spritemap
    // file name: [name]/spritemap.png  -> member name: [name]
    
    @:meta(Embed(source="../assets/ninja-girl/Animation.json",mimeType="application/octet-stream"))

    public static var ninja_girl_animation : Class<Dynamic>;
    
    @:meta(Embed(source="../assets/ninja-girl/spritemap.json",mimeType="application/octet-stream"))

    public static var ninja_girl_spritemap : Class<Dynamic>;
    
    @:meta(Embed(source="../assets/ninja-girl/spritemap.png"))

    public static var ninja_girl : Class<Dynamic>;
    
    @:meta(Embed(source="../assets/bunny/Animation.json",mimeType="application/octet-stream"))

    public static var bunny_animation : Class<Dynamic>;
    
    @:meta(Embed(source="../assets/bunny/spritemap.json",mimeType="application/octet-stream"))

    public static var bunny_spritemap : Class<Dynamic>;
    
    @:meta(Embed(source="../assets/bunny/spritemap.png"))

    public static var bunny : Class<Dynamic>;
    
    @:meta(Embed(source="../assets/background.jpg"))

    public static var background : Class<Dynamic>;

    public function new()
    {
    }
}
