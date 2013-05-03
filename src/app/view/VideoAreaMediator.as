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
     * Mediator for VideoArea
     * 
     * @author Billy Bateman
     */
    public class VideoAreaMediator extends BaseMediator implements IMediator {
        
       public static const NAME:String = "VideoAreaMediator";
       
	   public var nc:NetConnection = new NetConnection;
	   
	   public var cam    :   Camera;
	   public var mic	  :	  Microphone;
	   
	   
	   public var ns:NetStream;
	   public var ns2:NetStream;
	   
	   public var flash_vars:Object;
	   public var video_obj:Object;
	   public var audio_obj:Object;
	   
	   public var user:String;	   
	   public var stream_name:String;	   
	   public var record_length:int;
	   public var volume_level:Number;
	   public var applicationView:String;
	 
	   public var camFPS   :    Number    	= 15;
	   public var camW     :    Number  	= 640;
	   public var camH     :    Number 		= 480;
	   
	   public var isPaused:String = "false";
	   
		
        public function VideoAreaMediator(viewComponent:Object = null)
        {
            
			trace("VideoArea Mediator Loaded");
			
			super(NAME, viewComponent);
			
			videoarea.addEventListener( ApplicationFacade.PUBLISH_STREAM_CALL, publishStream );			
			videoarea.addEventListener( ApplicationFacade.VIDEO_STOP_PUBLISH_CALL, unpublishStream );
			
			videoarea.addEventListener( ApplicationFacade.VIDEO_PUBLISH_CALL, publishCamera );			
			videoarea.addEventListener( ApplicationFacade.VIDEO_UNPUBLISH_CALL, unpublishCamera );
			
			videoarea.addEventListener( ApplicationFacade.AUDIO_PUBLISH_CALL, publishAudio );			
			videoarea.addEventListener( ApplicationFacade.AUDIO_UNPUBLISH_CALL, unpublishAudio );
			
			videoarea.addEventListener( ApplicationFacade.VIDEO_LENGTH_CALL, updateLength );
            
        }
		
		
		private function connectUI(){
			trace("Connect UI");
			
			
			// Setup Net Stream Proxy
			var nsPxy:NetStreamProxy = facade.retrieveProxy( NetStreamProxy.NAME ) as NetStreamProxy;
			nsPxy.connect( nc );			
			ns = nsPxy.getNetStream() as NetStream;			
			
			// Get GUID from localproxy
			var localProxy:LocaleProxy = facade.retrieveProxy( LocaleProxy.NAME ) as LocaleProxy;
         	var flashVars:Object = localProxy.getLocale() as Object;
			
			// Get user
			user = flashVars.user;
			
			// Get stream_name
			stream_name = flashVars.file;
			
			// Get record_length
			record_length = flashVars.record_length;
			
			
			// Get applicationView
			applicationView = flashVars.applicationView;
			
			videoarea.applicationView(applicationView);
			
			if(applicationView == "recorder"){
				// Setup webcam in view			
				videoarea.setupAV();
			}
			
			// Get Volume level
			volume_level = flashVars.volume_level;
			
			videoarea.setVolumeLevel(volume_level);
			
		}	
			
		
		public function publishCamera( e:GenericEvent ){
			 					
			trace("Publishing Camera");			
			
	       	cam = e.data;
			
			ns.attachCamera(e.data);
			
			sendNotification( ApplicationFacade.VIDEO_PUBLISH_CALL, null );
			
		}
		
		public function unpublishCamera( e:GenericEvent ){		
					
			ns.attachCamera(null);
			
			sendNotification( ApplicationFacade.VIDEO_UNPUBLISH_CALL, null );
		}
		
		public function publishAudio( e:GenericEvent ){
			 					
			trace("Publishing Microphone");			
			
	       	mic = e.data;
			
			ns.attachAudio(e.data);
			
			sendNotification( ApplicationFacade.AUDIO_PUBLISH_CALL, null );
			
		}
		
		public function unpublishAudio( e:GenericEvent ){		
			
			ns.attachAudio(null);
			
			sendNotification( ApplicationFacade.AUDIO_UNPUBLISH_CALL, null );
			
		}
		
		public function publishStream( e:GenericEvent ){
			 					
			trace("Publishing Stream:" + stream_name);			
			
			ns.publish(stream_name, "record");			
			
		}
		
		public function unpublishStream( e:GenericEvent ){
			 					
			trace("UnPublishing Stream:" + stream_name);			
			
			ns.close();			
			
		}
		
		
		public function updateLength( e:GenericEvent ){
			sendNotification( ApplicationFacade.VIDEO_LENGTH_CALL, e.data );
		}
		
        
        /**
         * viewComponent cast to appropriate type
         */
        public function get videoarea() : VideoArea {
            return viewComponent as VideoArea;
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
				ApplicationFacade.NET_CONNECTION,
				ApplicationFacade.VIDEO_RECORD_CALL,
				ApplicationFacade.VIDEO_PLAY_CALL,
				ApplicationFacade.VIDEO_SAVED_CALL,
				ApplicationFacade.VIDEO_PAUSE_CALL,
				ApplicationFacade.CHANGE_VOLUME_CALL,
				ApplicationFacade.VIDEO_PUBLISH_CALL,
				ApplicationFacade.VIDEO_UNPUBLISH_CALL,
				ApplicationFacade.AUDIO_PUBLISH_CALL,
				ApplicationFacade.AUDIO_UNPUBLISH_CALL,
				ApplicationFacade.VIDEO_SEEK_CALL
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
                    	videoarea.setSize( stage.stageWidth, stage.stageHeight );					
                    break;
				
				case ApplicationFacade.NET_CONNECTION:
						nc = note.getBody() as NetConnection;						
						connectUI();
					break;
					
				case ApplicationFacade.VIDEO_SEEK_CALL:
						var seek = note.getBody() as Number;
												
						ns2.seek(seek);
						
						if(isPaused == "true"){
							isPaused = "false";							
							videoarea.resumeStream();
						}
						
					break;
					
				case ApplicationFacade.VIDEO_RECORD_CALL:
						var recordStr = note.getBody() as String;
						
						if(recordStr == "true"){
							videoarea.startRecord();
						} else {
							videoarea.stopRecord();
						}
						
					break;
					
				case ApplicationFacade.VIDEO_PLAY_CALL:
						var playStr = note.getBody() as String;
						
						if(playStr == "true"){						
			
							// Setup Net Stream Proxy
							var nsPxy2:NetStreamProxy = facade.retrieveProxy( NetStreamProxy.NAME ) as NetStreamProxy;
							nsPxy2.connect( nc );			
							ns2 = nsPxy2.getNetStream() as NetStream;			
							
							// Get GUID from localproxy
							var localProxy:LocaleProxy = facade.retrieveProxy( LocaleProxy.NAME ) as LocaleProxy;
							var flashVars:Object = localProxy.getLocale() as Object;
							
							// Get user
							user = flashVars.user;
							
							// Get stream_name
							stream_name = flashVars.file;			
							
							// Setup webcam in view			
							videoarea.startPlay(ns2, stream_name);	
						} else {
							videoarea.stopPlay();
						}
						
					break;
				case ApplicationFacade.VIDEO_SAVED_CALL:
						// Get GUID from localproxy
						var localProxy2:LocaleProxy = facade.retrieveProxy( LocaleProxy.NAME ) as LocaleProxy;
						var flashVars2:Object = localProxy2.getLocale() as Object;
												
						// Get stream_name
						stream_name = flashVars2.file;						
						
						trace("VideoAREA Mediator: Video Saved Call : " + stream_name);
						
						connectUI();
						
					break;
				case ApplicationFacade.VIDEO_PAUSE_CALL:
						var pauseStr = note.getBody() as String;
						
						isPaused = pauseStr;
						
						if(pauseStr == "true"){
							videoarea.pauseStream();	
						} else {
							videoarea.resumeStream();
						}
						
					break;
					
				case ApplicationFacade.CHANGE_VOLUME_CALL:
						videoarea.setStreamVolume(note.getBody());
					break;
					
				case ApplicationFacade.VIDEO_PUBLISH_CALL:						
						ns.attachCamera(cam);						
						videoarea.videoChange("true");			
					break;
				
				case ApplicationFacade.VIDEO_UNPUBLISH_CALL:
						ns.attachCamera(null);						
						videoarea.videoChange("false");
					break;
				
				case ApplicationFacade.AUDIO_PUBLISH_CALL:
						ns.attachAudio(mic);						
						videoarea.audioChange("true");			
					break;
				
				case ApplicationFacade.AUDIO_UNPUBLISH_CALL:
						ns.attachAudio(null);
						videoarea.audioChange("false");
					break;
                
                default:
                    break;
            }
        }       
        
    }
}
