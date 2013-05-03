package app.model {
    
    import org.puremvc.patterns.observer.Notification;
    import org.puremvc.patterns.proxy.Proxy;
    import org.puremvc.interfaces.IProxy;

    import flash.external.ExternalInterface;
	import flash.events.Event;
    import flash.events.TimerEvent;

    import app.ApplicationFacade;
    
    /**
     * @author Billy Bateman
     */
    public class JavascriptProxy extends Proxy implements IProxy {
        
        public static const NAME : String = "JavascriptProxy";
                                
        public function JavascriptProxy() 
        {
            super(NAME);			
			init();            
        }
        
		public function init() : void  {			
			ExternalInterface.addCallback("sendToActionscript", callFromJavaScript);						
        }
		
		public function callFromJavaScript(theObject:*){			
			
			if(theObject.action == "save"){
				sendNotification( ApplicationFacade.VIDEO_SAVE_CMD, theObject.message );
			} else {
				facade.notifyObservers( new Notification( ApplicationFacade.JAVASCRIPT_CMD, theObject ) );
			}
		}
		
		 public function saveVideo(obj:Object):void {
			sendNotification( ApplicationFacade.LOG, "Javascript Proxy: Save Video");
			
			ExternalInterface.call('saveVideo', obj);
		
			//sendNotification( ApplicationFacade.VIDEO_SAVED_CMD, "The video has been saved" );
        }
    }
}
