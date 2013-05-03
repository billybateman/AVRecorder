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
     * Mediator for TopMenu
     * 
     * @author Billy Bateman
     */
    public class TopMenuMediator extends BaseMediator implements IMediator {
        
       public static const NAME:String = "TopMenuMediator";	  
	  	   
	   public var nc:NetConnection = new NetConnection;
	   
	   public var applicationView:String;
	   
		
        public function TopMenuMediator(viewComponent:Object = null)
        {
            
			trace("TopMenu Mediator Loaded");
			
			
			
			super(NAME, viewComponent);			
            
            // listen for UI events from our view
            topmenu.addEventListener( ApplicationFacade.VIDEO_PUBLISH_CALL, onVideoPublishNotification );	
			topmenu.addEventListener( ApplicationFacade.VIDEO_UNPUBLISH_CALL, onVideoStopPublishNotification );	
			topmenu.addEventListener( ApplicationFacade.AUDIO_PUBLISH_CALL, onAudioPublishNotification );
		    topmenu.addEventListener( ApplicationFacade.AUDIO_UNPUBLISH_CALL, onAudioStopPublishNotification );
			
			
			topmenu.visible = false;
        }
		
		
		
		/* Video Publish Notification */
		private function onVideoPublishNotification( e:GenericEvent ):void
		{
						
			sendNotification( ApplicationFacade.VIDEO_PUBLISH_CALL, null );
			
		}		
		
		/* Video Stop Publish Notification */
		private function onVideoStopPublishNotification( e:GenericEvent ):void
		{
						
			sendNotification( ApplicationFacade.VIDEO_UNPUBLISH_CALL, null );
			
		}
		
		/* Audio Publish Notification */
		private function onAudioPublishNotification( e:GenericEvent ):void
		{			
					
			sendNotification( ApplicationFacade.AUDIO_PUBLISH_CALL, null );
		}		
		
		/* Audio Stop Publish Notification */
		private function onAudioStopPublishNotification( e:GenericEvent ):void
		{
						
			sendNotification( ApplicationFacade.AUDIO_UNPUBLISH_CALL, null );
		}		
		
		private function connectUI(){
			trace("Connect UI");
			
			// Get GUID from localproxy
			var localProxy:LocaleProxy = facade.retrieveProxy( LocaleProxy.NAME ) as LocaleProxy;
         	var flashVars:Object = localProxy.getLocale() as Object;
			
			// Get user
			applicationView = flashVars.applicationView;
			
			
			//topmenu.applicationView(applicationView);
			
			if(applicationView == "player"){
				topmenu.visible = false;
			} else {
				topmenu.visible = true;
			}
			
		}		
		
		
        /**
         * viewComponent cast to appropriate type
         */
        public function get topmenu() : TopMenu {
            return viewComponent as TopMenu;
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
				ApplicationFacade.VIDEO_PUBLISH_CALL,
				ApplicationFacade.VIDEO_UNPUBLISH_CALL,
				ApplicationFacade.AUDIO_PUBLISH_CALL,
				ApplicationFacade.AUDIO_UNPUBLISH_CALL
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
                    	topmenu.setSize( stage.stageWidth, stage.stageHeight );					
                    break;				
				
				case ApplicationFacade.NET_CONNECTION:
						nc = note.getBody() as NetConnection;					
						connectUI();
					break;
				
				case ApplicationFacade.VIDEO_PUBLISH_CALL:
						topmenu.videoChange("true");			
					break;
				
				case ApplicationFacade.VIDEO_UNPUBLISH_CALL:
						topmenu.videoChange("false");
					break;
				
				case ApplicationFacade.AUDIO_PUBLISH_CALL:
						topmenu.audioChange("true");			
					break;
				
				case ApplicationFacade.AUDIO_UNPUBLISH_CALL:
						topmenu.audioChange("false");
					break;
				
				case ApplicationFacade.VIDEO_RECORD_CALL:
						var recordStr = note.getBody() as String;
						
						if(recordStr == "true"){
							topmenu.startRecord();
						} else {
							topmenu.stopRecord();
						}
						
					break;		
                
                default:
                    break;
            }
        }       
        
    }
}
