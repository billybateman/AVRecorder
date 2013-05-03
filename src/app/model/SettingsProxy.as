package app.model {
    import org.puremvc.patterns.proxy.Proxy;
    import org.puremvc.interfaces.IProxy;    
    import app.ApplicationFacade;
       
	import flash.display.Stage;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.utils.Timer;
    import flash.events.Event;
    import flash.events.TimerEvent;
	
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.navigateToURL;

    /**
     * Settings Proxy
     *      
     * 
     * @author Billy Bateman
     */
    public class SettingsProxy extends Proxy implements IProxy {
        
        // proxy name
        public static const NAME:String = "SettingsProxy";        
        
        // Stings URL         
		public var connectionString:String = new String(); 
		public var videoSecondsLength:int = new int(); 
       
        
        public function SettingsProxy(data:Stage)
        {
            trace("Settings Proxy");
			
			super(NAME, data);       
           
        }
		
		public function getSettings(settings_path:String):void{
			var settings_path:String = settings_path + "assets/settings.xml";
			 
			var loader:URLLoader = new URLLoader()
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, onLoadXML);
			loader.load(new URLRequest(settings_path));
		}
		
		public function onLoadXML(ev:Event):void {
		   try{
				//Convert the downloaded text into an XML
				var myXML:XML = new XML(ev.target.data);				
				connectionString = myXML.title.fmsserver.text();								
				
				// Dispatch Event
				sendNotification( ApplicationFacade.APP_READY, data);
				
			} catch (e:TypeError){
				//Could not convert the data, probavlu because
				//because is not formated correctly
				trace("Could not parse the XML")
				trace(e.message)
			}
		}
		
		public function getConnectionString():String {
			return connectionString;
		}
		
		public function getVideoSecondsLength():int {
			return videoSecondsLength;
		}
    }
}
