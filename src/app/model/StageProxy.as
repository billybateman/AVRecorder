package app.model {
    
    import org.puremvc.patterns.observer.Notification;
    import org.puremvc.patterns.proxy.Proxy;
    import org.puremvc.interfaces.IProxy;

    import flash.display.Stage;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
	import flash.display.StageDisplayState;
    import flash.utils.Timer;
    import flash.events.Event;
    import flash.events.TimerEvent;

    import app.ApplicationFacade;
    
    /**
     * @author tkdave
     */
    public class StageProxy extends Proxy implements IProxy {
        
        public static const NAME : String = "StageProxy";
        
        private static const MAX_WIDTH:Number = 1600;
        private static const MIN_WIDTH:Number = 150;
        private static const MAX_HEIGHT:Number = 1600;
        private static const MIN_HEIGHT:Number = 200;
        
        private var constrainedWidth : Number;
        private var constrainedHeight : Number;

        private var updateTimer:Timer;
		
		public var isFullScreen:String = "false";
                
        public function StageProxy(data:Stage, delayNotifications:Boolean=true) 
        {
            super(NAME, data);
            
            // disable scaling
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.stageFocusRect = false;
            
            // listen to stage resize events
            if(delayNotifications) {
            	stage.addEventListener( Event.RESIZE, update );
            } else {
            	stage.addEventListener( Event.RESIZE, notifyStageSizeChanged );
            }
                        
            // create timer to delay update events
            updateTimer = new Timer( 50, 1 );
            updateTimer.addEventListener( TimerEvent.TIMER_COMPLETE, notifyStageSizeChanged );
            
            // trigger stage update event
            update();
        }
        
        /**
         * Triggers a stage resize event after a brief delay has elapsed
         * If a previous update was pending, it will be canceled
         */
        public function update(e:Event=null) : void  {
            updateTimer.reset();
            updateTimer.start();
        }
           
        public function get stage () : Stage {
            return this.getData() as Stage;
        }
        
        public function get stageWidth () : Number {
            return constrainedWidth;
        }
        
        public function get stageHeight () : Number {
            return constrainedHeight;
        }
		
		public function toggleFullScreen () : void {
            if(isFullScreen == "false"){
				isFullScreen = "true";
				stage.displayState = StageDisplayState.FULL_SCREEN;
			} else {
				isFullScreen = "false";
				stage.displayState = StageDisplayState.NORMAL;
			}
        }
        
        private function notifyStageSizeChanged(e:Event=null):void 
        {        	
            constrainedHeight = Math.min( Math.max( stage.stageHeight, MIN_HEIGHT), MAX_HEIGHT );
            constrainedWidth = Math.min( Math.max( stage.stageWidth, MIN_WIDTH), MAX_WIDTH );
           
            facade.notifyObservers( new Notification( ApplicationFacade.STAGE_RESIZE, this ) );
        }
        
        
    }
}
