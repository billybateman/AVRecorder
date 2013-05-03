package app.model {
    import org.puremvc.patterns.proxy.Proxy;
    import org.puremvc.interfaces.IProxy;

    import flash.events.*;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.navigateToURL;
    
    import app.ApplicationFacade;   
   

    /**
     *
     * @author Billy Bateman
     */
    public class ServiceProxy extends Proxy implements IProxy {
        
        // proxy name
        public static const NAME:String = "ServiceProxy";
		
		public var videoObj:Object;
        
		       
        public function ServiceProxy()
        {
            super(NAME);           
        }
        
        public function saveVideo(serviceUrl:String, obj:Object):void {
			sendNotification( ApplicationFacade.LOG, "Service Proxy: Save Video");
			
			videoObj = obj;
		
			var urlRequest:URLRequest = new URLRequest(serviceUrl + "/" + obj.file + "/" + obj.user);
			
			var loader:URLLoader = new URLLoader();
            configureListeners(loader);

            try {        
				
				loader.load(urlRequest);
            } catch (error:Error) {
                sendNotification( ApplicationFacade.LOG, "Unable to load requested document.");
            }
        }		
		

        private function configureListeners(dispatcher:IEventDispatcher):void {
            dispatcher.addEventListener(Event.COMPLETE, completeHandler);
            dispatcher.addEventListener(Event.OPEN, openHandler);
            dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        }
		

        private function completeHandler(event:Event):void {
            var loader:URLLoader = URLLoader(event.target);
			
			/* Get the user from the local proxy */
			videoObj.id = loader.data;
			var javascriptProxy:JavascriptProxy = facade.retrieveProxy(JavascriptProxy.NAME ) as JavascriptProxy;
			javascriptProxy.saveVideo(videoObj);
            
			sendNotification( ApplicationFacade.LOG, "video saved handler: " + loader.data);			
			sendNotification( ApplicationFacade.VIDEO_SAVED_CMD, loader.data );
			
        }     		
		
		
		private function openHandler(event:Event):void {
            sendNotification( ApplicationFacade.LOG, "openHandler: " + event);
        }

        private function progressHandler(event:ProgressEvent):void {
            sendNotification( ApplicationFacade.LOG, "progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
        }

        private function securityErrorHandler(event:SecurityErrorEvent):void {
            sendNotification( ApplicationFacade.LOG, "securityErrorHandler: " + event);
        }

        private function httpStatusHandler(event:HTTPStatusEvent):void {
            sendNotification( ApplicationFacade.LOG, "httpStatusHandler: " + event);
        }

        private function ioErrorHandler(event:IOErrorEvent):void {
            sendNotification( ApplicationFacade.LOG, "ioErrorHandler: " + event);
        }
        
        
    }
}
