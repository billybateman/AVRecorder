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
	import flash.geom.Rectangle;
	
	
	
	
	import flash.system.Security;
	import flash.system.SecurityPanel;
	import flash.net.ObjectEncoding;
	import flash.net.NetStream;
	import flash.media.*;
	   
    import com.bumpslide.events.UIEvent;	
	import gs.TweenLite;
	
    /**
     * The main bottom_menu_mc view
     * 
     * @author Billy Bateman - White Label
     */
    public class BottomMenu extends MovieClip {
        
        static public var EVENT_CREATION_COMPLETE:String = "onCreationComplete";  		         
       		
		public var video_seconds_length:int;
		public var current_video_seconds_length:int;		
		public var video_length:int;
		public var current_video_length:int;		
		public var recordTimer:Timer;
		public var playerTimer:Timer;
		
		public var menu_bg_mc:MovieClip;
		public var line_one:MovieClip;
		public var line_two:MovieClip;
		public var line_three:MovieClip;
		public var line_four:MovieClip;		
		
		public var record_btn:SimpleButton;
		public var stop_btn:SimpleButton;
		public var play_btn:SimpleButton;
		public var pause_btn:SimpleButton;
		
		public var scrubber_bg_mc:MovieClip;
		public var scrubber_level_mc:MovieClip;
		public var scrub_btn:MovieClip;
		
		public var time_txt:TextField;
		
		public var volume_icon_mc:MovieClip;
		public var volume_bg_mc:MovieClip;
		public var volume_level_mc:MovieClip;
		public var volume_scrub_btn:MovieClip;
		
		public var fullscreen_btn:SimpleButton;
		
		public var video_state:String = "Playing";
		public var pause_state:String = "false";
		
		public var ns:NetStream;
		
		public var obj:Object = new Object();
		
		
		public var volumeBounds:Rectangle;
		public var volumeLevel:Number = 0;
		public var Bounds:Rectangle;
		public var frame:Number = 0;
		public var applicationViewSet:String;
		
		public var widthint:uint = 400;
		public var heightint:uint = 348;
		
			
        public function BottomMenu()
        {    
            trace("New Bottom Menu Loaded");	
			
			pause_btn.visible = false;
			stop_btn.visible = true;		
			
			play_btn.enabled = false;
			
			record_btn.visible = false;
			
			volume_level_mc.width = volume_scrub_btn.x - volume_bg_mc.x;
						
			record_btn.addEventListener(MouseEvent.CLICK, clickBtnHandler);			
			stop_btn.addEventListener(MouseEvent.CLICK, clickBtnHandler);			
			play_btn.addEventListener(MouseEvent.CLICK, clickBtnHandler);
			pause_btn.addEventListener(MouseEvent.CLICK, clickBtnHandler);
			fullscreen_btn.addEventListener(MouseEvent.CLICK, clickBtnHandler);
			
			volume_scrub_btn.buttonMode = true;			
			volume_scrub_btn.addEventListener(MouseEvent.MOUSE_DOWN, handleVolumeScrubberDown );
			volume_scrub_btn.addEventListener( MouseEvent.MOUSE_UP, handleVolumeScrubberUp );
			volume_scrub_btn.addEventListener( MouseEvent.MOUSE_MOVE, handleVolumeScrubberMove );
			
			scrub_btn.buttonMode = true;			
			scrub_btn.addEventListener(MouseEvent.MOUSE_DOWN, handleScrubberDown );
			scrub_btn.addEventListener( MouseEvent.MOUSE_UP, handleScrubberUp );
			scrub_btn.addEventListener( MouseEvent.MOUSE_MOVE, handleScrubberMove );
			
			// Record Timer
			recordTimer = new Timer(1000); // 1 second
			recordTimer.addEventListener(TimerEvent.TIMER, changeRecordPosition);
			
			// Player Timer
			playerTimer = new Timer(1000); // 1 second
			playerTimer.addEventListener(TimerEvent.TIMER, changePlayerPosition);
			
			//Framework Listener
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage );		
        }
		
		private function handleVolumeScrubberDown( event:MouseEvent ):void {

			volumeBounds = new Rectangle( volume_bg_mc.x, 6, volume_bg_mc.width, 0 );			
		
			volume_scrub_btn.startDrag( false, volumeBounds);			
		
		}
		
		private function handleVolumeScrubberUp( event:MouseEvent ):void {
		
			volume_scrub_btn.stopDrag();
			
			volumeLevel = (volume_level_mc.width / volume_bg_mc.width);			
			
								 
			dispatchEvent( new GenericEvent( ApplicationFacade.CHANGE_VOLUME_CMD, volumeLevel ));			
		
		}
		
		private function handleVolumeScrubberMove( event:MouseEvent ):void {

		
			volumeLevel = (volume_level_mc.width / volume_bg_mc.width);
			
			volume_level_mc.width = volume_scrub_btn.x - volume_bg_mc.x;		
		
		}
		
		public function setVolumeLevel(level:Number):void {
			volumeLevel = level;
			
			volume_level_mc.width = (volumeLevel * volume_bg_mc.width);			   
			volume_scrub_btn.x = (volumeLevel * volume_bg_mc.width) + volume_bg_mc.x;
		}
		
		private function handleScrubberDown( event:MouseEvent ):void {

			if(video_state == "Playing"){
				Bounds = new Rectangle( scrubber_bg_mc.x, 6, scrubber_bg_mc.width, 0 );
			
				playerTimer.stop();
		
				scrub_btn.startDrag( false, Bounds);
			}
		
		}
		
		private function handleScrubberUp( event:MouseEvent ):void {
		
			if(video_state == "Playing"){
				scrub_btn.stopDrag();						
			
				scrubber_level_mc.width = scrub_btn.x - scrubber_bg_mc.x;
				
				frame = (scrubber_level_mc.width / scrubber_bg_mc.width);			
				
				var newTime:Number = (frame * video_length);		
				
				current_video_length = newTime;
				
				time_txt.text = formatTime(newTime);
				
				playerTimer.start();
				
				pause_state = "false";
				
				pause_btn.visible = true;
				play_btn.visible = false;
				
				if(applicationViewSet == "recorder"){
					record_btn.visible = false;
					stop_btn.visible = true;
				}
				
				
				dispatchEvent( new GenericEvent( ApplicationFacade.VIDEO_SEEK_CALL, newTime ));
			}
		
		}
		
		private function handleScrubberMove( event:MouseEvent ):void {
			
			scrubber_level_mc.width = scrub_btn.x - scrubber_bg_mc.x;
			
			frame = (scrubber_level_mc.width / scrubber_bg_mc.width);			
			
			var newTime:Number = (frame * video_length);		
			
			time_txt.text = formatTime(newTime);			
		
		}
		       
        private function onAddedToStage(event:Event):void
        {
        	trace('BottomMenu is initialized');
        	dispatchEvent( new UIEvent(EVENT_CREATION_COMPLETE, this ) ); 
        }
		
		public function clickBtnHandler(e:MouseEvent):void
		{			
			
			switch(e.target.name){
				case "record_btn":
					trace("Record Button");					
					video_state = "Recording";
					dispatchEvent( new GenericEvent( ApplicationFacade.VIDEO_RECORD_CMD, "true" ));					
				break;
				case "stop_btn":
					trace("Stop Button");					
					
					pause_state = "false";
					
					if(video_state == "Recording"){
						dispatchEvent( new GenericEvent( ApplicationFacade.VIDEO_RECORD_CMD, "false" ));
					} else {
						video_state = "Playing";
						dispatchEvent( new GenericEvent( ApplicationFacade.VIDEO_PLAY_CMD, "false" ));
					}					
				break;
				case "play_btn":
					trace("Play Button");					
					
					if(video_state == "Playing"){					
					
						if(pause_state == "true"){				
							pause_state = "false";
							dispatchEvent( new GenericEvent( ApplicationFacade.VIDEO_PAUSE_CALL, "false" ));
						} else {						
							dispatchEvent( new GenericEvent( ApplicationFacade.VIDEO_PLAY_CMD, "true" ));
						}
						
					}
					
					if(video_state == "Recording"){
						dispatchEvent( new GenericEvent( ApplicationFacade.VIDEO_RECORD_CMD, "false" ));
					}
					
				break;
				
				case "pause_btn":
					trace("Pause Button");
					pause_state = "true";
					dispatchEvent( new GenericEvent( ApplicationFacade.VIDEO_PAUSE_CALL, "true" ));
					
				break;
				
				case "fullscreen_btn":
					trace("Fullscreen Button");
					dispatchEvent( new GenericEvent( ApplicationFacade.FULL_SCREEN_CMD, null ));					
										
				break;
				
				default:
				break;
			}
		}		
		
					
		public function startRecord(video_seconds_length_in:int):void {
			trace("Record Video");			
			
			// Scrubber Level width
			scrubber_level_mc.width = 0;			
					
			// Calculate amount of time allowed for recording and set time_txt to formatted text 			
			time_txt.text = formatTime(video_seconds_length_in);
			
			// Setup current time = 0 and video length to amount of seconds allowed
			current_video_seconds_length = 0;
			video_seconds_length = video_seconds_length_in;
			
			
			recordTimer.start();
			
			video_state = "Recording";			
			
			if(applicationViewSet == "recorder"){
				record_btn.visible = false;
			
				stop_btn.visible = true;
			}
			pause_btn.visible = false;
			play_btn.enabled = false;		
			
		}
		
		
		public function applicationView(applicationViewIn:String):void {
			 
			applicationViewSet = applicationViewIn;
			
			if(applicationViewSet == "player"){
				record_btn.visible = false;
				stop_btn.visible = true;
			}
			
			if(applicationViewSet == "recorder"){
				record_btn.visible = true;
				stop_btn.visible = false;
			}
		}
		
		public function stopRecord():void {
			trace("Stop Record Video");			
			
			// Stop Timer
			recordTimer.stop();
			
			// Stop Bar
			scrubber_level_mc.width = 0;		
			
			
			if(applicationViewSet == "recorder"){
				record_btn.visible = true;
				stop_btn.visible = false;
			}
			
			pause_btn.visible = false;
			play_btn.visible = true;
			play_btn.enabled = true;
			
			
		}
		
		public function changeRecordPosition(event:TimerEvent):void {
			// This Moves the slider
			if (current_video_seconds_length < video_seconds_length){
				// Update counter, trying to get to 0
				current_video_seconds_length = current_video_seconds_length + 1;
				
				// Update time_txt with new formatted time
				time_txt.text = formatTime(current_video_seconds_length);			
				
				updateRecordSlider();				
				
			} else {				
				
				trace("Force Stop from Bottom Menu change record position");
				
				recordTimer.stop();
				
				dispatchEvent( new GenericEvent( ApplicationFacade.VIDEO_RECORD_CMD, "false" ));
				
			}
		}
		
		public function updateRecordSlider():void {
			
			var pos:Number = current_video_seconds_length/video_seconds_length;			
			
			var slider_width:Number = scrubber_bg_mc.width;
			
			scrubber_level_mc.width = pos * slider_width;
			
			scrub_btn.x = scrubber_level_mc.width + scrubber_level_mc.x;
			
		}
		
		
		
		public function startPlay():void{
			video_state = "Playing";
			current_video_length = 0;
			if(applicationViewSet == "recorder"){
				record_btn.visible = false;
				stop_btn.visible = true;
			}
			
			pause_btn.visible = true;
			play_btn.visible = false;		
			
		}
		
		public function stopPlay():void{
			
			if(applicationViewSet == "recorder"){
				record_btn.visible = true;
				stop_btn.visible = false;
			}
			
			pause_btn.visible = false;
			play_btn.visible = true;
			play_btn.enabled = true;
			
			playerTimer.stop();
			
		}
		
		public function startTimer(inLength:*){		
			
			video_length = inLength;
			/* Start slider bar*/
			
			playerTimer.start();
					
		}
		
		public function stopTimer(){
			
			pause_btn.visible = false;
			play_btn.visible = true;		
		
			playerTimer.stop();
		
		}
		
		public function restartTimer(){		
			
			pause_btn.visible = true;
			play_btn.visible = false;		
			
			/* Start slider bar*/			
			playerTimer.start();
					
		}
		
		public function changePlayerPosition(event:TimerEvent):void {
			// This Moves the slider
			if (current_video_length < video_length){
				// Update counter, trying to get to 0
				current_video_length = current_video_length + 1;
				
				// Update time_txt with new formatted time
				time_txt.text = formatTime(current_video_length);			
				
				updatePlayerSlider();				
				
			} else {				
				
				trace("Force Stop from Bottom Menu change player position");
				
				playerTimer.stop();
				
				dispatchEvent( new GenericEvent( ApplicationFacade.VIDEO_PLAY_CMD, "false" ));				
				
			}
		}
		
		public function updatePlayerSlider():void {
			
			var ppos:Number = current_video_length/video_length;			
			
			var pslider_width:Number = scrubber_bg_mc.width;
			
			scrubber_level_mc.width = ppos * pslider_width;			
					
			scrub_btn.x = scrubber_level_mc.width + scrubber_level_mc.x;
			
		}		
				
				
				
		public function formatTime(t:int):String {
			// returns the minutes and seconds with leading zeros
			// for example: 70 returns 01:10
			var s:int = Math.round(t);
			var m:int = 0;
			if (s > 0) {
				while (s > 59) {
					m++;
					s -= 60;
				}
				return String((m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s);
			} else {
				return "00:00";
			}
		}

        public function setSize(w:Number, h:Number):void
        {
                               
           // Set the size to 100% of flash movie!
		  	   
		   widthint = w;
		   heightint = h;
		   
		  
		   
			   menu_bg_mc.width = w;
			   
			   fullscreen_btn.x = w - 28;
			   
			   line_four.x = w - 32;
			   volume_bg_mc.x = w - 75;			  
			   volume_icon_mc.x = w - 90;
			   
			   volume_level_mc.x = w - 75;			   
			   volume_scrub_btn.x = (volumeLevel * volume_bg_mc.width) + volume_bg_mc.x;
			   
			   line_three.x = w - 95;
			   
			   time_txt.x = w - 137;
			   
			   scrubber_bg_mc.width = w - 200;
			   
			   
			   scrub_btn.x = (frame * scrubber_bg_mc.width) + scrubber_bg_mc.x;
			   scrubber_level_mc.width = (frame * scrubber_bg_mc.width);
			
		   
		   
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
