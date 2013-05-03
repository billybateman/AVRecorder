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
	
	import flash.media.SoundTransform;
	import flash.events.SecurityErrorEvent;
	
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
    public class VideoArea extends MovieClip {
        
        static public var EVENT_CREATION_COMPLETE:String = "onCreationComplete";  		         
       	
		public var cam    :   Camera;
		public var camFPS :   Number    = 15;
		public var camW   :   Number  	= 640;
		public var camH   :   Number 	 = 480;
		
		public var mic	  :	  Microphone;
		
		public var audioObject:Object = new Object();
		public var videoObject:Object = new Object();
		
		public var video_length:int;
		public var current_video_length:int;
		
		public var play_video_mc:Video = new Video();
		public var record_video_mc:Video = new Video();
		
		public var video_bg_mc:MovieClip;
		public var message_txt:TextField;
		public var applicationViewSet:String;
				
		public var ns:NetStream;
		public var videoSound:SoundTransform = new SoundTransform();
		public var volumeLevel:Number = 0;
		
			
        public function VideoArea()
        {    
            trace("New Video Area Loaded");						
			
			message_txt.visible = false;
			
			
			audioObject.status = false;
			videoObject.status = false;			
			
			addChild(play_video_mc);
			addChild(record_video_mc);
			
			play_video_mc.x = 0;
			play_video_mc.y = 24;			
			play_video_mc.width = 400;
			play_video_mc.height = 300;
			play_video_mc.smoothing = true;
			
			record_video_mc.x = 0;
			record_video_mc.y = 24;			
			record_video_mc.width = 400;
			record_video_mc.height = 300;
			record_video_mc.smoothing = true;
			
			videoSound.volume = volumeLevel;
						
			//Framework Listener
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage );		
        }	
		       
        private function onAddedToStage(event:Event):void
        {
        	trace('Video Area is initialized');
        	dispatchEvent( new UIEvent(EVENT_CREATION_COMPLETE, this ) ); 
        }
		
		public function setVolumeLevel(level:Number):void {
			volumeLevel = level;
			videoSound.volume = volumeLevel;			
			//ns.soundTransform = videoSound;
		}
					
		public function startRecord():void {
			trace("Video Area : Start Record");			
			
			// Dispatch publishCamera event
			dispatchEvent( new GenericEvent( ApplicationFacade.PUBLISH_STREAM_CALL, "true" ));
			
			play_video_mc.visible = false;
			record_video_mc.visible = true;
		}
		
		public function stopRecord():void {
			trace("Video Area : Stop Record");				
			dispatchEvent( new GenericEvent( ApplicationFacade.VIDEO_STOP_PUBLISH_CALL, null ));			
		}
		
		public function applicationView(applicationViewIn:String):void {
			 
			applicationViewSet = applicationViewIn;
			
			if(applicationViewSet == "player"){
				message_txt.visible = false;
				 record_video_mc.y = 0;
				 play_video_mc.y = 0;
			}
			
			if(applicationViewSet == "recorder"){
				message_txt.visible = true;
				 record_video_mc.y = 24;
				 play_video_mc.y = 24;
			}
		}
		
		public function videoChange(str:String):void {
			trace("Video Change:" + str);	
			  
			if(str == "true"){
				cam = Camera.getCamera();
				cam.setMode(camW, camH, camFPS);			
				cam.setQuality(512000, 90);	
			
				record_video_mc.attachCamera(cam);
				videoObject.status = true;
				
				play_video_mc.visible = false;
				record_video_mc.visible = true;
				
			} else {				
				
				videoObject.status = false;	
				cam = null;				
				
				
				record_video_mc.attachCamera(null);
				record_video_mc.clear();
				
				play_video_mc.visible = false;
				record_video_mc.visible = false;
				
				
			}
        }
		
		public function audioChange(str:String):void {
		  	trace("Audio Change:" + str);
		  
		  	if(str == "true"){
				mic = Microphone.getMicrophone();
				mic.gain = 50; //normal setting turn down for loud rooms possibl
						
				audioObject.status = true;		
				
			} else {
				mic = null;
				audioObject.status = false;
				
			}
        }

		
		public function setupAV():void{
			trace("Setup AV");
						
			cam = Camera.getCamera();
			cam.setMode(camW, camH, camFPS);			
			cam.setQuality(512000, 90);			
			
			record_video_mc.attachCamera(cam);
			
			mic = Microphone.getMicrophone();
			mic.gain = 50; //normal setting turn down for loud rooms possibl

			
			videoObject.status = true;			
			audioObject.status = true;
			
			play_video_mc.visible = false;
			record_video_mc.visible = true;
			
			// Send notifcation of publish stream change
			dispatchEvent( new GenericEvent( ApplicationFacade.VIDEO_PUBLISH_CALL, cam ));
			dispatchEvent( new GenericEvent( ApplicationFacade.AUDIO_PUBLISH_CALL, mic ));
			
		}
		
		
		public function startPlay(ns_in:NetStream, streamName:String):void{
			trace("Video Area: Start Play: stream--" + streamName);
			
			ns = ns_in;
			ns.soundTransform = videoSound;
			var netClient:Object = new Object();
			netClient.onMetaData = function(meta:Object)
			{
					
					play_video_mc.visible = true;				
					video_length = meta.duration;
					
					// Dispath notification to views of length of video
					dispatchEvent( new GenericEvent( ApplicationFacade.VIDEO_LENGTH_CALL, video_length ));
										
			};
			
			ns.client = netClient;
			
			play_video_mc.attachNetStream(ns);
			ns.play(streamName);			
			
			play_video_mc.visible = true;
			record_video_mc.visible = false;
		}
		
		public function stopPlay():void {
			trace("VideoArea : Stop Play");					
			ns.close();			
		}
		
		public function pauseStream(){			
			ns.pause();		
		}
		
		public function resumeStream(){	
			ns.resume();
		}
		
		public function setStreamVolume(vol:*){	
			
			videoSound.volume = vol;
		}
		
		
		
        public function setSize(w:Number, h:Number):void
        {
                               
           // Set the size to 100% of flash movie!
		  	   
		   var widthint:uint = w;
		   var heightint:uint = h;
		   
		   record_video_mc.width = w;
		   
		   if(applicationViewSet == "recorder"){
			   record_video_mc.height = h - 48;
		   } else {
			   record_video_mc.height = h - 24;
		   }
		   
		   play_video_mc.width = w;
		   
		   if(applicationViewSet == "recorder"){
			   play_video_mc.height = h - 48;
		   } else {
			   play_video_mc.height = h - 24;
		   }
		   
		  	   
		   message_txt.x = (w / 2) - ( message_txt.width / 2 );
		   message_txt.y = (h / 2) - ( message_txt.height / 2 );
		   
		   video_bg_mc.width = w;
		   video_bg_mc.height = h;
		               
        }		
		
		public function setObject(obj:*):void {
			  trace("Setting Object:" + obj);			 
        }		
		
    }
}
