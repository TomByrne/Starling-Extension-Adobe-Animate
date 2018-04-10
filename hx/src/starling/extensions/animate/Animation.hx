package starling.extensions.animate;

import haxe.Constraints.Function;
import starling.animation.IAnimatable;
import starling.display.DisplayObjectContainer;
import starling.events.Event;
import starling.extensions.animate.MovieBehavior.MovieFrameAction;

class Animation extends DisplayObjectContainer implements IAnimatable
{
    public var currentLabel(get, never) : String;
    public var currentFrame(get, set) : Int;
    public var currentTime(get, set) : Float;
    public var frameRate(get, set) : Float;
    public var loop(get, set) : Bool;
    public var numFrames(get, never) : Int;
    public var isPlaying(get, never) : Bool;
    public var totalTime(get, never) : Float;

    private var _symbol : Symbol;
    private var _behavior : MovieBehavior;
    private var _cumulatedTime : Float = 0.0;
    
    public function new(data : Dynamic, atlas : AnimationAtlas)
    {
        super();
        _symbol = new Symbol(data, atlas);
        _symbol.update();
        addChild(_symbol);
        
        _behavior = new MovieBehavior(this, onFrameChanged, atlas.frameRate);
        _behavior.numFrames = _symbol.numFrames;
        _behavior.addEventListener(Event.COMPLETE, onComplete);
        play();
    }
    
    private function onComplete() : Void
    {
        dispatchEventWith(Event.COMPLETE);
    }
    
    private function onFrameChanged(frameIndex : Int) : Void
    {
        _symbol.currentFrame = frameIndex;
    }
    
    public function play() : Void
    {
        _behavior.play();
    }
    
    public function pause() : Void
    {
        _behavior.pause();
    }
    
    public function stop() : Void
    {
        _behavior.stop();
    }
    
    public function gotoFrame(index : Int) : Void
    {
        currentFrame = index;
    }
    
    public function gotoLabel(label : String) : Void
    {
        currentFrame = _symbol.getFrame(label);
    }
    
    public function getFrame(label : String) : Int
    {
        return _symbol.getFrame(label);
    }
    
    public function addFrameAction(index : Int, action : MovieFrameAction) : Void
    {
        _behavior.addFrameAction(index, action);
    }
    
    public function removeFrameAction(index : Int, action : MovieFrameAction) : Void
    {
        _behavior.removeFrameAction(index, action);
    }
    
    public function removeFrameActions(index : Int) : Void
    {
        _behavior.removeFrameActions(index);
    }
    
    public function advanceTime(time : Float) : Void
    {
        var frameRate : Float = _behavior.frameRate;
        var prevTime : Float = _cumulatedTime;
        
        _behavior.advanceTime(time);
        _cumulatedTime += time;
        
        if (Std.int(prevTime * frameRate) != Std.int(_cumulatedTime * frameRate))
        {
            _symbol.nextFrame_MovieClips();
        }
    }
    
    public function getNextLabel(afterLabel : String = null) : String
    {
        return _symbol.getNextLabel(afterLabel);
    }
    
    private function get_currentLabel() : String
    {
        return _symbol.currentLabel;
    }
    
    private function get_currentFrame() : Int
    {
        return _behavior.currentFrame;
    }
    private function set_currentFrame(value : Int) : Int
    {
        _behavior.currentFrame = value;
        return value;
    }
    
    private function get_currentTime() : Float
    {
        return _behavior.currentTime;
    }
    private function set_currentTime(value : Float) : Float
    {
        _behavior.currentTime = value;
        return value;
    }
    
    private function get_frameRate() : Float
    {
        return _behavior.frameRate;
    }
    private function set_frameRate(value : Float) : Float
    {
        _behavior.frameRate = value;
        return value;
    }
    
    private function get_loop() : Bool
    {
        return _behavior.loop;
    }
    private function set_loop(value : Bool) : Bool
    {
        _behavior.loop = value;
        return value;
    }
    
    private function get_numFrames() : Int
    {
        return _behavior.numFrames;
    }
    private function get_isPlaying() : Bool
    {
        return _behavior.isPlaying;
    }
    private function get_totalTime() : Float
    {
        return _behavior.totalTime;
    }
}

