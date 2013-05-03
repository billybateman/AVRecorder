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
     * The top_menu view
     * 
     * @author Billy Bateman - White Label
     */
    public class TopMenu extends MovieClip {
        
        static public var EVENT_CREATION_COMPLETE:String = "onCreationComplete";       	
			
		public var menu_bg_mc:MovieClip;
		
		public var recording_notify_txt:TextField;		
		
		public var audio_btn:MovieClip;
		public var audioObject:Object = new Object();		
		
		public var video_btn:MovieClip;
		public var videoObject:Object = new Object();		
		
		public var settings_btn:MovieClip;
		
		public var line_one:MovieClip;
		public var line_two:MovieClip;
		
		public var hover:Boolean = false;
		public var currentElementFrame:Number = 1;		
		
		
		
			
        public function TopMenu()
        {    
            trace("New TopMenu Loaded");		
			
			recording_notify_txt.visible = false;						
			
			audioObject.status = false;
			videoObject.status = false;		
		
			/* button listeners */
			audio_btn.addEventListener(MouseEvent.CLICK, clickBtnHandler);
			audio_btn.addEventListener(MouseEvent.MOUSE_OVER, hoverBtnHandler);
			audio_btn.addEventListener(MouseEvent.MOUSE_OUT, hoverBtnHandler);
			
			video_btn.addEventListener(MouseEvent.CLICK, clickBtnHandler);
			video_btn.addEventListener(MouseEvent.MOUSE_OVER, hoverBtnHandler);
			video_btn.addEventListener(MouseEvent.MOUSE_OUT, hoverBtnHandler);
			
			settings_btn.addEventListener(MouseEvent.CLICK, clickBtnHandler);
			settings_btn.addEventListener(MouseEvent.MOUSE_OVER, hoverBtnHandler);
			settings_btn.addEventListener(MouseEvent.MOUSE_OUT, hoverBtnHandler);			
			
						
			//Framework Listener
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage );		
        }	
		       
        private function onAddedToStage(event:Event):void
        {
        	trace('TopMenu is initialized');
        	dispatchEvent( new UIEvent(EVENT_CREATION_COMPLETE, this ) ); 
        }
		
		public function videoChange(str:String):void {
			trace("Video Change:" + str);	
			  
			if(str == "true"){
				currentElementFrame = 3;
				videoObject.status = true;						
				video_btn.gotoAndStop(3);						
			} else {
				currentElementFrame = 1;
				videoObject.status = false;
				video_btn.gotoAndStop(1);						
			}
        }
		
		public function audioChange(str:String):void {
		  	trace("Audio Change:" + str);
		  
		  	if(str == "true"){
				currentElementFrame = 3;
				audioObject.status = true;
				audio_btn.gotoAndStop(3);
			} else {
				currentElementFrame = 1;
				audioObject.status = false;
				audio_btn.gotoAndStop(1);
				trace("Got Here");
			}
        }
		
		public function clickBtnHandler(e:MouseEvent):void
		{			
			
			switch(e.target.name){				
				case "audio_btn":
					trace("Audio Button" + audioObject.status);
					
					if(audioObject.status == false){
						audioObject.status = true;
						audio_btn.gotoAndStop(3);
						dispatchEvent( new GenericEvent( ApplicationFacade.AUDIO_PUBLISH_CALL, null ));
					} else {
						audioObject.status = false;
						audio_btn.gotoAndStop(1);
						dispatchEvent( new GenericEvent( ApplicationFacade.AUDIO_UNPUBLISH_CALL, null ));
					}				
					
					
					
				break;
				case "video_btn":
					trace("Video Button:" + videoObject.status);
					if(videoObject.status == false){
						videoObject.status = true;						
						video_btn.gotoAndStop(3);
						dispatchEvent( new GenericEvent( ApplicationFacade.VIDEO_PUBLISH_CALL, null ));
					} else {
						videoObject.status = false;
						video_btn.gotoAndStop(1);
						dispatchEvent( new GenericEvent( ApplicationFacade.VIDEO_UNPUBLISH_CALL, null ));
					}
					
					
					
				break;
				case "settings_btn":
					trace("Open security panel");
					Security.showSettings(SecurityPanel.CAMERA);
				break;
				
				default:
				break;
			}
		}
		
		public function hoverBtnHandler(e:MouseEvent):void
		{			
			var scene:Number = new Number();		
			
			if(hover == false){
				hover = true;
			} else {
				hover = false;
			}			
			
			
			switch(e.target.name){
				case "audio_btn":
					
					if(hover == true){
						scene = audio_btn.currentFrame;
						currentElementFrame = scene;
						audio_btn.gotoAndStop(2);
					} else {							
						audio_btn.gotoAndStop(currentElementFrame);
					}
					
				break;
				case "video_btn":
					
					if(hover == true){
						scene = video_btn.currentFrame;
						currentElementFrame = scene;
						video_btn.gotoAndStop(2);
					} else {							
						video_btn.gotoAndStop(currentElementFrame);
					}
					
				break;
				case "settings_btn":
					
					if(hover == true){						
						settings_btn.gotoAndStop(2);
					} else {						
						settings_btn.gotoAndStop(1);
					}
					
				break;				
				
			}			
		}
		
		public function startRecord():void {
			recording_notify_txt.visible = true;
		}
		
		public function stopRecord():void {
			recording_notify_txt.visible = false;
		}
		

        public function setSize(w:Number, h:Number):void
        {
                               
           // Set the size to 100% of flash movie!
		  	   
		   var widthint:uint = w;
		   var heightint:uint = h;
		   
		    menu_bg_mc.width = w;
			
			recording_notify_txt.x = w - 5 - recording_notify_txt.width;
		            
        }		
		
		public function setObject(obj:*):void {
			  trace("Setting Object:" + obj);			 
        }		
		
    }
}
