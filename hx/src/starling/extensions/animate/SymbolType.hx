package starling.extensions.animate;

import starling.errors.AbstractClassError;

class SymbolType
{
    /** @private */
    @:allow(starling.extensions.animate)
    private function new()
    {
        throw new AbstractClassError();
    }
    
    public static inline var GRAPHIC : String = "graphic";
    public static inline var MOVIE_CLIP : String = "movieclip";
    public static inline var BUTTON : String = "button";
    
    public static function isValid(value : String) : Bool
    {
        return value == GRAPHIC || value == MOVIE_CLIP || value == BUTTON;
    }
}

