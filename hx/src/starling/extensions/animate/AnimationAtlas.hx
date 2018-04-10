package starling.extensions.animate;

import openfl.errors.ArgumentError;
import starling.display.Image;
import starling.extensions.animate.AnimationAtlasData;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
import starling.textures.TextureSmoothing;

class AnimationAtlas
{
    public var frameRate(get, set) : Float;

    public static inline var ASSET_TYPE : String = "animationAtlas";
    
    private var _atlas : TextureAtlas;
    private var _symbolData : Map<String, SymbolData>;
    private var _symbolPool : Map<String, Array<Symbol>>;
    private var _imagePool : Array<Image>;
    private var _frameRate : Float;
    private var _defaultSymbolName : String;
    
    private static var STD_MATRIX3D_DATA : Matrix3DData = {
            m00 : 1,
            m01 : 0,
            m02 : 0,
            m03 : 0,
            m10 : 0,
            m11 : 1,
            m12 : 0,
            m13 : 0,
            m20 : 0,
            m21 : 0,
            m22 : 1,
            m23 : 0,
            m30 : 0,
            m31 : 0,
            m32 : 0,
            m33 : 1
        };
    
    public function new(data : AnimationAtlasData, atlas : TextureAtlas)
    {
        parseData(data);
        
        _atlas = atlas;
        _symbolPool = new Map();
        _imagePool = [];
    }
    
    public function hasAnimation(name : String) : Bool
    {
        return hasSymbol(name);
    }
    
    public function createAnimation(name : String = null) : Animation
    {
        name = (name != null) ? name : _defaultSymbolName;
        if (!hasSymbol(name))
        {
            throw new ArgumentError("Animation not found: " + name);
        }
        return new Animation(getSymbolData(name), this);
    }
    
    public function getAnimationNames(prefix : String = "", out : Array<String> = null) : Array<String>
    {
        out = (out != null) ? out : new Array<String>();
        
        for (name in _symbolData.keys())
        {
            if (name != Symbol.BITMAP_SYMBOL_NAME && name.indexOf(prefix) == 0)
            {
                out[out.length] = name;
            }
        }
        
        //out.sort(Array.CASEINSENSITIVE);
		out.sort(function(a1, a2) : Int {
			a1 = a1.toLowerCase();
			a2 = a2.toLowerCase();
			if (a1 < a2){
				return -1;
			}else if (a1 > a2){
				return 1;
			}else{
				return 0;
			}
		});
        return out;
    }
    
    // pooling
    
    @:allow(starling.extensions.animate)
    private function getTexture(name : String) : Texture
    {
        return _atlas.getTexture(name);
    }
    
    @:allow(starling.extensions.animate)
    private function getImage(texture : Texture) : Image
    {
        if (_imagePool.length == 0)
        {
            var image = new Image(texture);
			//image.textureSmoothing = TextureSmoothing.NONE;
			return image;
        }
        else
        {
            var image : Image = try cast(_imagePool.pop(), Image) catch(e:Dynamic) null;
            image.texture = texture;
            image.readjustSize();
			//image.textureSmoothing = TextureSmoothing.NONE;
            return image;
        }
    }
    
    @:allow(starling.extensions.animate)
    private function putImage(image : Image) : Void
    {
        _imagePool[_imagePool.length] = image;
    }
    
    @:allow(starling.extensions.animate)
    private function hasSymbol(name : String) : Bool
    {
        return _symbolData.exists(name);
    }
    
    @:allow(starling.extensions.animate)
    private function getSymbol(name : String) : Symbol
    {
        var pool : Array<Symbol> = getSymbolPool(name);
        if (pool.length == 0)
        {
            return new Symbol(getSymbolData(name), this);
        }
        else
        {
            return pool.pop();
        }
    }
    
    @:allow(starling.extensions.animate)
    private function putSymbol(symbol : Symbol) : Void
    {
        symbol.reset();
        var pool : Array<Symbol> = getSymbolPool(symbol.symbolName);
        pool.push(symbol);
        symbol.currentFrame = 0;
    }
    
    // helpers
    
    private function parseData(data : AnimationAtlasData) : Void
    {
        var metaData = data.metadata;
        
        if (metaData != null && metaData.framerate != null && metaData.framerate > 0)
        {
            _frameRate = (metaData.framerate);
        }
        else
        {
            _frameRate = 24;
        }
        
        _symbolData = new Map();
        
        // the actual symbol dictionary
		var symbols = data.SYMBOL_DICTIONARY.Symbols;
        for (symbolData in symbols)
        {
            _symbolData[symbolData.SYMBOL_name] = preprocessSymbolData(symbolData);
        }
        
        // the main animation
        var defaultSymbolData : SymbolData = preprocessSymbolData(data.ANIMATION);
        _defaultSymbolName = defaultSymbolData.SYMBOL_name;
		_symbolData.set(_defaultSymbolName, defaultSymbolData);
        
        // a purely internal symbol for bitmaps - simplifies their handling
        _symbolData.set(Symbol.BITMAP_SYMBOL_NAME, {
                    SYMBOL_name : Symbol.BITMAP_SYMBOL_NAME,
                    TIMELINE : {
                        LAYERS : []
                    }
                });
    }
    
    private static function preprocessSymbolData(symbolData : SymbolData) : SymbolData
    {
        var timeLineData : SymbolTimelineData = symbolData.TIMELINE;
        var layerDates : Array<LayerData> = timeLineData.LAYERS;
        
        // In Animate CC, layers are sorted front to back.
        // In Starling, it's the other way round - so we simply reverse the layer data.
        
        if (!timeLineData.sortedForRender)
        {
            timeLineData.sortedForRender = true;
            layerDates.reverse();
        }
        
        // We replace all "ATLAS_SPRITE_instance" elements with symbols of the same contents.
        // That way, we are always only dealing with symbols.
        
        for (layerData in layerDates)
        {
            var frames : Array<LayerFrameData> = layerData.Frames;
            var numFrames : Int = frames.length;
            
            for (frame in frames)
            {
                var elements : Array<ElementData> = frame.elements;
                for (e in 0 ... elements.length)
                {
					var element:ElementData = elements[e];
                    if (element.ATLAS_SPRITE_instance)
                    {
                        element = elements[e] = {
                                            SYMBOL_Instance : {
                                                SYMBOL_name : Symbol.BITMAP_SYMBOL_NAME,
                                                Instance_Name : "InstName",
                                                bitmap : element.ATLAS_SPRITE_instance,
                                                symbolType : SymbolType.GRAPHIC,
                                                firstFrame : 0,
                                                loop : LoopMode.LOOP,
                                                transformationPoint : {
                                                    x : 0,
                                                    y : 0
                                                },
                                                Matrix3D : STD_MATRIX3D_DATA
                                            }
                                        };
                    }
                    
                    // not needed - remove decomposed matrix to save some memory
                    //delete element.SYMBOL_Instance.DecomposedMatrix;
                }
            }
        }
        
        return symbolData;
    }
    
    private function getSymbolData(name : String) : SymbolData
    {
        return _symbolData.get(name);
    }
    
    private function getSymbolPool(name : String) : Array<Symbol>
    {
        var pool : Array<Symbol> = _symbolPool.get(name);
        if (pool == null)
        {
            pool = [];
			_symbolPool.set(name, pool);
        }
        return pool;
    }
    
    // properties
    
    private function get_frameRate() : Float
    {
        return _frameRate;
    }
    private function set_frameRate(value : Float) : Float
    {
        _frameRate = value;
        return value;
    }
}

