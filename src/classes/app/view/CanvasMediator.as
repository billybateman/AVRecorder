package app.view {

    import org.puremvc.interfaces.IMediator;
    import org.puremvc.interfaces.INotification;
    
       
    import app.ApplicationFacade;    
	import app.model.*;
    import app.view.events.*;
    import app.view.components.*;
    
    import com.bumpslide.events.UIEvent;
	
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	import flash.net.NetStream;
	import flash.media.*;
	import flash.utils.Timer;
	
	import gs.*;
	
    /**
     * Mediator for Canvas
     * 
     * @author Billy Bateman
     */
    public class CanvasMediator extends BaseMediator implements IMediator {
        
       public static const NAME:String = "CanvasMediator";
       
	   public var nc:NetConnection = new NetConnection;
	   
	   public var ns2:NetStream;
	   
	   public var video_obj:Object;
	   public var audio_obj:Object;
	   
	 
	   public var camFPS   :    Number    	= 15;
	   public var camW     :    Number  	= 640;
	   public var camH     :    Number 		= 480;
	   
	   public var video_seconds_length:int;
	    
	   public var user:String = new String();
	   
	   public var stream_name:String = new String();
	   
	   public var guid:GUID = new GUID();
		
        public function CanvasMediator(viewComponent:Object = null)
        {
            
			trace("Canvas Mediator Loaded");
			
			super(NAME, viewComponent);			
            
            // listen for UI events from our view
            canvas.addEventListener( ApplicationFacade.VIDEO_PUBLISH_CALL, onVideoPublishNotification );	
			canvas.addEventListener( ApplicationFacade.VIDEO_STOP_PUBLISH_CALL, onVideoStopPublishNotification );	
			canvas.addEventListener( ApplicationFacade.AUDIO_PUBLISH_CALL, onAudioNotification );
		    canvas.addEventListener( ApplicationFacade.VIDEO_CHANGE_CALL, onVideoNotification );
			canvas.addEventListener( ApplicationFacade.VIDEO_PLAY_CALL, onVideoPlayNotification );
			canvas.addEventListener( ApplicationFacade.VIDEO_SAVE_CMD, onVideoSaveNotification );
        }
		
		/* Video Publish Notification */
		private function onVideoSaveNotification( e:GenericEvent ):void
		{//
						
			var saveObject:Object = new Object();
			
			saveObject.user = user;
			saveObject.stream_name = stream_name;
			
			sendNotification( ApplicationFacade.VIDEO_SAVE_CMD, saveObject );
		}
		
		/* Video Publish Notification */
		private function onVideoPublishNotification( e:GenericEvent ):void
		{
			
			
			publishCamera(stream_name, e.data);			
			
		}
		
		
		private function onVideoStopPublishNotification( e:GenericEvent ):void
		{
			
			stopPublish();			
			
		}
		
		/* Video Play Notification */
		private function onVideoPlayNotification( e:GenericEvent ):void
		{
			
			playVideo(stream_name);			
			
		}
		
		/* Video Publish Notification */
		private function onVideoNotification( e:GenericEvent ):void
		{//
			video_obj = e.data;
			
			if(video_obj.status == false){				
				video_obj.status = true;
			} else {
				stopPublish();
				video_obj.status = false;
			}
			
			sendNotification( ApplicationFacade.VIDEO_PUBLISH_CALL, e.data );
		}
		
		/* Audio Publish Notification */
		private function onAudioNotification( e:GenericEvent ):void
		{
			sendNotification( ApplicationFacade.AUDIO_PUBLISH_CALL, e.data );
			audio_obj = e.data;
			
			if(audio_obj.status == true){
				//publishMicrophone();
			} else {
				//unPublishMicrophone();
			}
		}
		
		private function connectUI(){
			trace("Connect UI");
			
			// Get GUID from localproxy
			var localProxy:LocaleProxy = facade.retrieveProxy( LocaleProxy.NAME ) as LocaleProxy;
         	var flashVars:Object = localProxy.getLocale() as Object;
			
			// Set user
			user = flashVars.user;
			
			// Set stream_name
			if(flashVars.file){
				stream_name = flashVars.file;
			} else {				
				stream_name = guid.create(40);
			}
			
			canvas.setupWebcam();			
			
		}
		
		
		public function playVideo(stream_name:String){
			
			var nsPxy:NetStreamProxy = facade.retrieveProxy( NetStreamProxy.NAME ) as NetStreamProxy;
			nsPxy.connect( nc );
			var ns:NetStream = 	nsPxy.getNetStream() as NetStream;
			canvas.playVideo(ns, stream_name);
			
		}
		
		
		public function publishCamera(streamName:String, cam:Camera){
			 					
			trace("Publishing Camera:" + streamName);
			
			// Get VideoSecondsLength from SettingsProxy
			var settings_proxy:SettingsProxy = facade.retrieveProxy(SettingsProxy.NAME ) as SettingsProxy;
         	video_seconds_length = settings_proxy.getVideoSecondsLength() as int;						
			
			// Setup Shared Object Proxy
			var nsPxy2:NetStreamProxy = facade.retrieveProxy( NetStreamProxy.NAME ) as NetStreamProxy;
			nsPxy2.connect( nc );			
			ns2 = nsPxy2.getNetStream() as NetStream;			
			
			
	        cam.setMode(camW, camH, camFPS);
	        cam.setQuality(512000, 90);
	        cam.setLoopback(false);
			
			ns2.attachCamera(cam);
			ns2.publish(streamName, "record");
			
			// Send Notification to component to start timer and status bar
			canvas.startRecording(video_seconds_length);
		}
		
		public function stopPublish(){			 					
			ns2.close();
			
			// Send Notification to component to stop timer and status bar
			canvas.stopRecording();
			
			//sendNotification( ApplicationFacade.VIDEO_STOP_PUBLISH_CALL, null );
			playVideo(stream_name);
		}		
		
        
        /**
         * viewComponent cast to appropriate type
         */
        public function get canvas() : Canvas {
            return viewComponent as Canvas;
        }
        
        /**
         * List all notifications this Mediator is interested in.
         * 
         * @return Array the list of Nofitication names
         */
        override public function listNotificationInterests():Array 
        {
            return [
               
                ApplicationFacade.STAGE_RESIZE,
				ApplicationFacade.JAVASCRIPT_CALL,
				ApplicationFacade.NET_CONNECTION,
				ApplicationFacade.VIDEO_STOP_PUBLISH_CALL,
				ApplicationFacade.VIDEO_STOP_CALL,
				ApplicationFacade.VIDEO_PLAY_CALL,
				ApplicationFacade.VIDEO_SAVED_CALL
            ];            
        }

        /**
         * Handle all notifications this Mediator is interested in.
         * 
         * @param INotification a notification 
         */
        override public function handleNotification( note:INotification ):void 
        {
            switch ( note.getName() ) 
            {
               
                case ApplicationFacade.STAGE_RESIZE:
                    	var stage:StageProxy = note.getBody() as StageProxy;
                    	canvas.setSize( stage.stageWidth, stage.stageHeight );					
                    break;
				case ApplicationFacade.JAVASCRIPT_CALL:
                    trace("Application Facade Javascript Call");
					canvas.setObject(note.getBody());
                    break;
				case ApplicationFacade.NET_CONNECTION:
					nc = note.getBody() as NetConnection;
					
					connectUI();
					break;
				case ApplicationFacade.VIDEO_STOP_PUBLISH_CALL:
				
					//playVideo(stream_name);
					
					break;
				case ApplicationFacade.VIDEO_STOP_CALL:
					canvas.VideoStopCall();
					break;
				case ApplicationFacade.VIDEO_PLAY_CALL:
					
					break;
				case ApplicationFacade.VIDEO_SAVED_CALL:
					canvas.VideoSavedCall();
					connectUI();
					break;
                
                default:
                    break;
            }
        }       
        
    }
}
