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
     * The main canvas view
     * 
     * @author Billy Bateman - White Label
     */
    public class Canvas extends MovieClip {
        
        static public var EVENT_CREATION_COMPLETE:String = "onCreationComplete";  		         
       	
		public var cam    :   Camera;
		public var camFPS :   Number    = 15;
		public var camW   :   Number  	= 320;
		public var camH   :   Number 	 = 240;		
		
		public var video_mc:Video = new Video();
		public var webcam:Video = new Video();
		
		public var recording_notify_txt:TextField;
		public var time_txt:TextField;
		public var video_seconds_length:int;
		public var current_video_seconds_length:int;
		
		
		public var video_length:int;
		public var current_video_length:int;
		
		public var recordTimer:Timer;
		public var playerTimer:Timer;
		public var slider_mc:MovieClip;
		public var slider_base_mc:MovieClip;
		
		public var record_btn:SimpleButton;
		public var stop_btn:SimpleButton;
		public var play_btn:SimpleButton;
		public var save_btn:SimpleButton;
		
		
		public var audio_btn:MovieClip;
		public var audioObject:Object = new Object();		
		public var video_btn:MovieClip;
		public var videoObject:Object = new Object();		
		public var settings_btn:MovieClip;		
		public var webcam_menu_mc:MovieClip;
		
		public var hover:Boolean = false;
		public var currentElementFrame:Number = 1;
		
		public var video_state:String = new String();
		
		public var ns:NetStream;
		
			
        public function Canvas()
        {    
            trace("New Canvas Loaded");		
			
			recording_notify_txt.visible = false;
			
			slider_mc.width = 0;
			
			save_btn.visible = false;
			
			save_btn.enabled = false;
			stop_btn.enabled = false;
			play_btn.enabled = false;
			record_btn.enabled = true;
			
			
			
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
			
			record_btn.addEventListener(MouseEvent.CLICK, clickBtnHandler);			
			stop_btn.addEventListener(MouseEvent.CLICK, clickBtnHandler);			
			play_btn.addEventListener(MouseEvent.CLICK, clickBtnHandler);
			save_btn.addEventListener(MouseEvent.CLICK, clickBtnHandler);
			
			addChild(webcam);
			addChild(video_mc);
						
			//Framework Listener
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage );		
        }	
		       
        private function onAddedToStage(event:Event):void
        {
        	trace('Canvas is initialized');
        	dispatchEvent( new UIEvent(EVENT_CREATION_COMPLETE, this ) ); 
        }
		
		public function clickBtnHandler(e:MouseEvent):void
		{			
			
			switch(e.target.name){
				case "record_btn":
					trace("Record Button");
					recordVideo();
					
				break;
				case "stop_btn":
					trace("Stop Button");
					
					
					if(video_state == "Recording"){
						stopRecord();
					} else {
						stopVideo();
					}
					
				break;
				case "play_btn":
					trace("Play Button");
					dispatchEvent( new GenericEvent( ApplicationFacade.VIDEO_PLAY_CALL, null ));
					
				break;
				case "save_btn":
					trace("Save Button");
					dispatchEvent( new GenericEvent( ApplicationFacade.VIDEO_SAVE_CMD, null ));
					
				break;
				case "audio_btn":
					trace("Audio Button");
					if(audioObject.status == false){
						audioObject.status = true;
						audio_btn.gotoAndStop(3);
					} else {
						audioObject.status = false;
						audio_btn.gotoAndStop(1);
					}
					//dispatchEvent( new GenericEvent( ApplicationFacade.AUDIO_CHANGE_CALL, audioObject ));
					
				break;
				case "video_btn":
					trace("Video Button:" + videoObject.status);
					if(videoObject.status == false){
						videoObject.status = true;						
						video_btn.gotoAndStop(3);
						webcam.attachCamera(cam);
						webcam.visible = true;
					} else {
						videoObject.status = false;
						video_btn.gotoAndStop(1);
						webcam.attachCamera(null);
						webcam.visible = false;
					}
					
					//dispatchEvent( new GenericEvent( ApplicationFacade.VIDEO_CHANGE_CALL, videoObject ));
					
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
					if(audioObject.status == false){
						if(hover == true){
							scene = audio_btn.currentFrame;
							currentElementFrame = scene;
							audio_btn.gotoAndStop(2);
						} else {
							currentElementFrame = 1;
							audio_btn.gotoAndStop(1);
						}
					}
				break;
				case "video_btn":
					if(videoObject.status == false){
						if(hover == true){
							scene = video_btn.currentFrame;
							currentElementFrame = scene;
							video_btn.gotoAndStop(2);
						} else {
							currentElementFrame = 1;
							video_btn.gotoAndStop(1);
						}
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
		
		public function startRecording(video_seconds_length_in:int):void {
			trace("Start Recording video, allowed length is " + video_seconds_length_in);
			
			recording_notify_txt.visible = true;
			
			// Calculate amount of time allowed for recording and set time_txt to formatted text 			
			time_txt.text = formatTime(video_seconds_length_in);
			
			// Setup slider bar to proper length based on video_seconds_length
			// move this to setup function
			current_video_seconds_length = 0;
			video_seconds_length = video_seconds_length_in;
			
			// Start slider bar
			recordTimer = new Timer(1000); // 1 second
			recordTimer.addEventListener(TimerEvent.TIMER, changeRecordPosition);
			recordTimer.start();			
			
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
				
				
				
				stopRecord();				
			}
		}
		
		public function updateRecordSlider():void {
			
			var pos:Number = current_video_seconds_length/video_seconds_length;			
			
			var slider_width:Number = slider_base_mc.width;
			
			slider_mc.width = pos * slider_width;
			
		}
		
		
		
		public function stopRecording():void {
			trace("Stop Recording video");
			
			time_txt.text = "00:00";
			
			// Setup to play recorded video			
			video_state = "Playing"
			
			recording_notify_txt.visible = false;
			
		}
		
		public function recordVideo():void {
			trace("Record Video");			
			
			save_btn.enabled = false;
			stop_btn.enabled = true;
			play_btn.enabled = false;
			record_btn.enabled = false;
			
			// Dispath Record Event
			dispatchEvent( new GenericEvent( ApplicationFacade.VIDEO_PUBLISH_CALL, cam ));			
			
			video_state = "Recording";
			
			video_mc.visible = false;
			
			recording_notify_txt.visible = true;
		}
		
		public function stopRecord():void {
			trace("Stop Record Video");				
			
			save_btn.enabled = true;
			stop_btn.enabled = false;
			play_btn.enabled = true;
			record_btn.enabled = true;
			
			// Dispath Record Event
			dispatchEvent( new GenericEvent( ApplicationFacade.VIDEO_STOP_PUBLISH_CALL, null ));
			
			// Stop Timer
			recordTimer.stop();
			
			// Stop Bar
			slider_mc.width = 0;			
			
			video_state = "Playing";
			
			video_mc.visible = true;
		}
		
		public function playVideo(ns_in:NetStream, streamName:String):void{
			trace("Play video " + streamName);			
			
			save_btn.enabled = false;
			stop_btn.enabled = true;
			play_btn.enabled = false;
			record_btn.enabled = false;			
			
			
			video_mc.x = 0;
			video_mc.y = 0;			
			video_mc.width = 320;
			video_mc.height = 240;			
			
			ns = ns_in;
			var netClient:Object = new Object();
			netClient.onMetaData = function(meta:Object)
			{
					
					video_mc.visible = true;
					
					time_txt.text = formatTime(meta.duration);
					
					
					// Setup slider bar to proper length based on video_seconds_length
					// move this to setup function
					current_video_length = 0;
					video_length = meta.duration;
					
					// Start slider bar
					playerTimer = new Timer(1000); // 1 second
					playerTimer.addEventListener(TimerEvent.TIMER, changePlayerPosition);
					playerTimer.start();
					
					
			};
			
			ns.client = netClient;
			
			video_mc.attachNetStream(ns);
			ns.play(streamName);			
			
			video_mc.visible = true;
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
				
				stopVideo();
				
				playerTimer.stop();
			}
		}
		
		public function updatePlayerSlider():void {
			
			var ppos:Number = current_video_length/video_length;			
			
			var pslider_width:Number = slider_base_mc.width;
			
			slider_mc.width = ppos * pslider_width;
			
		}
		
		public function stopVideo():void {
			trace("Canvas : Stop Video");
			// Enable Record button, disable stop button
			save_btn.enabled = true;
			stop_btn.enabled = false;
			play_btn.enabled = true;
			record_btn.enabled = true;			
			
			//video_mc.visible = false;
			video_state = "Playing";
			
			ns.close();
			
			playerTimer.stop();
			
		}
		
		public function VideoSavedCall():void {
			trace("Canvas : Video Saved Call");
			// Enable Record button, disable stop button
			save_btn.enabled = false;
			stop_btn.enabled = false;
			play_btn.enabled = false;
			record_btn.enabled = true;		
			
			video_mc.visible = false;
			
			video_state = "";
			
		}
		
		public function VideoStopCall():void {
			trace("Canvas : Video Stop Call");
			// Enable Record button, disable stop button
			save_btn.enabled = true;
			stop_btn.enabled = false;
			play_btn.enabled = true;
			record_btn.enabled = true;		
			
			video_state = "Playing";			
			
		}

		
		public function setupWebcam():void{
			trace("Setup Webcam");
						
			cam = Camera.getCamera();
			cam.setMode(camW, camH, camFPS);			
			
			webcam.x = 0;
			webcam.y = 0;			
			webcam.width = 320;
			webcam.height = 240;
			webcam.smoothing = true;
			
			webcam.attachCamera(cam);			
			
			videoObject.status = true;
			video_btn.gotoAndStop(3);
			audioObject.status = true;
			audio_btn.gotoAndStop(3);		
			
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
