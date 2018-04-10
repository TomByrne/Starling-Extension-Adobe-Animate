package starling.extensions.animate;

import flash.geom.Rectangle;
import haxe.Constraints.Function;
import openfl.Vector;
import starling.assets.AssetFactoryHelper;
import starling.assets.AssetManager;
import starling.assets.AssetReference;
import starling.assets.JsonFactory;
import starling.extensions.animate.AnimationAtlas;
import starling.textures.SubTexture;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
import starling.utils.Pool;

import Type;


class AssetManagerEx extends AssetManager
{
	
	
    // helper objects
   // private static var sNames : Vector<String> = Vector.ofArray([]);
    
    public function new()
    {
        super();
        registerFactory(new AnimationAtlasFactory(), 10);
    }
    
    override public function addAsset(name : String, asset : Dynamic, type : String = null) : Void
    {
        if (type == null && Std.is(asset, AnimationAtlas))
        {
            type = AnimationAtlas.ASSET_TYPE;
        }
        
        super.addAsset(name, asset, type);
    }
    
    /** Returns an animation atlas with a certain name, or null if it's not found. */
    public function getAnimationAtlas(name : String) : AnimationAtlas
    {
        return try cast(getAsset(AnimationAtlas.ASSET_TYPE, name), AnimationAtlas) catch(e:Dynamic) null;
    }
    
    /** Returns all animation atlas names that start with a certain string, sorted alphabetically.
     *  If you pass an <code>out</code>-vector, the names will be added to that vector. */
    public function getAnimationAtlasNames(prefix : String = "", out : Vector<String> = null) : Vector<String>
    {
        return getAssetNames(AnimationAtlas.ASSET_TYPE, prefix, true, out);
    }
    
    public function createAnimation(name : String) : Animation
    {
        var atlasNames : Vector<String> = getAnimationAtlasNames("", new Vector());
        var animation : Animation = null;
        
        for (atlasName in atlasNames)
        {
            var atlas : AnimationAtlas = getAnimationAtlas(atlasName);
            if (atlas.hasAnimation(name))
            {
                animation = atlas.createAnimation(name);
                break;
            }
        }
        
        if (animation == null && atlasNames.indexOf(name) != -1)
        {
            animation = getAnimationAtlas(name).createAnimation();
        }
        
        //sNames = [];
        return animation;
    }
    
    override private function getNameFromUrl(url : String) : String
    {
        var defaultName : String = super.getNameFromUrl(url);
        var separator : String = "/";
        
        if (defaultName == "Animation" || defaultName == "spritemap" &&
            url.indexOf(separator) != -1)
        {
            var elements : Array<Dynamic> = url.split(separator);
            var folderName : String = elements[elements.length - 2];
            var suffix : String = (defaultName == "Animation") ? AnimationAtlasFactory.ANIMATION_SUFFIX : "";
            return super.getNameFromUrl(folderName + suffix);
        }
        
        return defaultName;
    }
}




class AnimationAtlasFactory extends JsonFactory
{
    /** The lowest integer value in Flash and JS. */
    static inline var INT_MIN :Int = -2147483648;

    /** The highest integer value in Flash and JS. */
    static inline var INT_MAX :Int = 2147483647;
	
	
    public static inline var ANIMATION_SUFFIX : String = "_animation";
    public static inline var SPRITEMAP_SUFFIX : String = "_spritemap";
    
    override public function create(reference : AssetReference, helper : AssetFactoryHelper,
            onComplete : String->Dynamic->Void, onError : String -> Void) : Void
    {
        
        var onObjectComplete : String->Dynamic->Void = function(name : String, json : AnimationAtlasData) : Void
        {
			var framerate:Null<Int> = Reflect.field(json.metadata, "frameRate");
			if (framerate != null) json.metadata.framerate = framerate;
			
            if (json.ATLAS != null && json.meta != null)
            {
                helper.addPostProcessor(function(assets : AssetManager) : Void
                        {
                            if (name.indexOf(SPRITEMAP_SUFFIX) == name.length - SPRITEMAP_SUFFIX.length)
                            {
                                name = name.substr(0, name.length - SPRITEMAP_SUFFIX.length);
                            }
                            
                            var textureName : String = helper.getNameFromUrl(name);
                            var texture : Texture = assets.getTexture(textureName);
                            
                            assets.addAsset(name, new JsonTextureAtlas(texture, json));
                        }, 100);
            }
            else if (json.ANIMATION != null && json.SYMBOL_DICTIONARY != null)
            {
                helper.addPostProcessor(function(assets : AssetManager) : Void
                        {
                            var suffixIndex : Int = name.indexOf(ANIMATION_SUFFIX);
                            var baseName : String = name.substr(0, 
                                    (suffixIndex >= 0) ? suffixIndex : INT_MAX
                    );
                            
                            assets.addAsset(baseName, new AnimationAtlas(json, 
                                    assets.getTextureAtlas(baseName)), AnimationAtlas.ASSET_TYPE);
                        });
            }
            
            onComplete(name, json);
        }
		
        super.create(reference, helper, onObjectComplete, onError);
    }

    public function new()
    {
        super();
    }
}

class JsonTextureAtlas extends TextureAtlas
{
    public function new(texture : Texture, data : AnimationAtlasData = null)
    {
        super(texture, data);
    }
    
    override private function parseAtlasData(data : Dynamic) : Void
    {
        if (Type.typeof(data) == ValueType.TObject)
        {
            parseAtlasJson(data);
        }
        else
        {
            super.parseAtlasData(data);
        }
    }
    
    private function parseAtlasJson(data : AnimationAtlasData) : Void
    {
        var region : Rectangle = Pool.getRectangle();
        
		var sprites:Array<Dynamic> = data.ATLAS.SPRITES;
        for (element in sprites)
        {
            var node : Dynamic = element.SPRITE;
            region.setTo(node.x, node.y, node.w, node.h);
            var subTexture : SubTexture = new SubTexture(texture, region, false, null, node.rotated);
            addSubTexture(node.name, subTexture);
        }
        
        Pool.putRectangle(region);
    }
}

