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
     * Mediator for BottomMenu
     * 
     * @author Billy Bateman
     */
    public class BottomMenuMediator extends BaseMediator implements IMediator {
        
       public static const NAME:String = "BottomMenuMediator";
       
	   public var nc:NetConnection;
	   	   
	   public var video_obj:Object;
	   public var audio_obj:Object
	   ;	   
	   public var record_length:int;	    
	   public var user:String;	   
	   public var stream_name:String;
	   public var applicationView:String;
	   public var autoStart:String;
	   public var volume_level:Number;
		
        public function BottomMenuMediator(viewComponent:Object = null)
        {
            
			trace("BottomMenu Mediator Loaded");
			
			super(NAME, viewComponent);			
            
           	bottommenu.addEventListener( ApplicationFacade.VIDEO_PLAY_CMD, onVideoPlayNotification );
			bottommenu.addEventListener( ApplicationFacade.VIDEO_SEEK_CALL, onVideoSeekNotification );
			bottommenu.addEventListener( ApplicationFacade.VIDEO_RECORD_CMD, onVideoRecordNotification );
			bottommenu.addEventListener( ApplicationFacade.VIDEO_PAUSE_CALL, onVideoPauseNotification );
			bottommenu.addEventListener( ApplicationFacade.CHANGE_VOLUME_CMD, onChangeVolumeNotification );
			bottommenu.addEventListener( ApplicationFacade.FULL_SCREEN_CMD, onFullScreenNotification );
        }
		
		/* Full Screen Notification */
		private function onFullScreenNotification( e:GenericEvent ):void
		{
			sendNotification( ApplicationFacade.FULL_SCREEN_CMD, e.data );			
		}
		
		/* Video Seek Notification */
		private function onVideoSeekNotification( e:GenericEvent ):void
		{
			sendNotification( ApplicationFacade.VIDEO_SEEK_CALL, e.data );			
		}
		
		
		/* Change Volume Notification */
		private function onChangeVolumeNotification( e:GenericEvent ):void
		{
			sendNotification( ApplicationFacade.CHANGE_VOLUME_CMD, e.data );			
		}
		
		
		/* Video Play Notification */
		private function onVideoPlayNotification( e:GenericEvent ):void
		{
			sendNotification( ApplicationFacade.VIDEO_PLAY_CMD, e.data );			
		}
		
		/* Video Record Notification */
		private function onVideoRecordNotification( e:GenericEvent ):void
		{			
			trace("BottomMenu Mediator: Video Record Notification:" + e.data);
			
			sendNotification( ApplicationFacade.VIDEO_RECORD_CMD, e.data );			
		}
		
		/* Video Play Notification */
		private function onVideoPauseNotification( e:GenericEvent ):void
		{
			sendNotification( ApplicationFacade.VIDEO_PAUSE_CALL, e.data );			
		}
			
		private function connectUI(){
			trace("Connect UI");
			
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
			
			bottommenu.applicationView(applicationView);
			
			
			// Get Volume level
			volume_level = flashVars.volume_level;
			
			bottommenu.setVolumeLevel(volume_level);
			
			// Get auto start
			autoStart = flashVars.autoStart;
			
			if(autoStart == "true"){
				sendNotification( ApplicationFacade.VIDEO_PLAY_CMD, "true" );
			}
			
		}	
						
        
        /**
         * viewComponent cast to appropriate type
         */
        public function get bottommenu() : BottomMenu {
            return viewComponent as BottomMenu;
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
				ApplicationFacade.VIDEO_PAUSE_CALL,
				ApplicationFacade.VIDEO_LENGTH_CALL
				
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
                    	
						bottommenu.y = stage.stageHeight - 24;
						
						bottommenu.setSize( stage.stageWidth, stage.stageHeight );					
                    break;
				
				case ApplicationFacade.NET_CONNECTION:
						nc = note.getBody() as NetConnection;
						
						connectUI();
					break;	
				
				case ApplicationFacade.VIDEO_RECORD_CALL:
						var recordStr = note.getBody() as String;
						
						if(recordStr == "true"){
							trace("Bottom Menu Mediator: Start Record");
							bottommenu.startRecord(record_length);
						} else {
							trace("Bottom Menu Mediator: Stop Record");
							bottommenu.stopRecord();
						}
						
					break;
					
				case ApplicationFacade.VIDEO_PLAY_CALL:
						var playStr = note.getBody() as String;
						
						if(playStr == "true"){
							trace("Bottom Menu Mediator: Start Play");
							bottommenu.startPlay();
						} else {
							trace("Bottom Menu Mediator: Stop Play");
							bottommenu.stopPlay();
						}
						
					break;
					
				case ApplicationFacade.VIDEO_PAUSE_CALL:
						var pauseStr = note.getBody() as String;
						
						if(pauseStr == "true"){
							bottommenu.stopTimer();
						} else {
							bottommenu.restartTimer();
						}
						
					break;
				
				case ApplicationFacade.VIDEO_LENGTH_CALL:						
						bottommenu.startTimer(note.getBody());	
						
					break;
                
                default:
                    break;
            }
        }       
        
    }
}