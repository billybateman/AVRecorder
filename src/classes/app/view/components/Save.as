package app.view.components {
    
    import app.ApplicationFacade;
    import app.model.*;
    import app.view.events.*;
    import app.view.components.*;
	
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.Sprite;	
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.text.TextField;
	
	import flash.system.Security;
	import flash.system.SecurityPanel;
	import flash.net.ObjectEncoding;
	import flash.net.NetStream;
	import flash.media.*;
	   
    import com.bumpslide.events.UIEvent;	
	import gs.TweenLite;
	
    /**
     * The save view
     * 
     * @author Billy Bateman - White Label
     */
    public class Save extends MovieClip {
        
        static public var EVENT_CREATION_COMPLETE:String = "onCreationComplete";  		         
       	
		public var save_bg_mc:MovieClip;
		
		public var save_close_btn:SimpleButton;
		public var save_btn:SimpleButton;		
		
		public var message_txt:TextField;				
			
        public function Save()
        {    
            trace("New Save Loaded");					
				
			save_close_btn.addEventListener(MouseEvent.CLICK, clickBtnHandler);
			save_btn.addEventListener(MouseEvent.CLICK, clickBtnHandler);
						
			//Framework Listener
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage );		
        }	
		       
        private function onAddedToStage(event:Event):void
        {
        	trace('Save is initialized');
        	dispatchEvent( new UIEvent(EVENT_CREATION_COMPLETE, this ) ); 
        }
		
		public function clickBtnHandler(e:MouseEvent):void
		{			
			switch(e.target.name){
				case "save_btn":				
					dispatchEvent( new GenericEvent( ApplicationFacade.VIDEO_SAVE_CMD, "true" ));					
				break;
				case "save_close_btn":
					dispatchEvent( new GenericEvent( ApplicationFacade.VIDEO_SAVE_CMD, "false" ));
				break;
			}
		}		
		
        public function setSize(w:Number, h:Number):void
        {
                               
           // Set the size to 100% of flash movie!
		  	   
		   var widthint:uint = w;
		   var heightint:uint = h;	 
		   
		   // Was used for testing events without using browser because it locks publish 
		   // after publishing once
		   //trace("Dispatching Event");
		   //dispatchEvent( new GenericEvent( ApplicationFacade.JAVASCRIPT_CALL, '0x0099CC' ));            
        }		
		
		public function setObject(obj:*):void {
			  trace("Setting Object:" + obj);			 
        }		
		
    }
}
