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
    public class LocaleProxy extends Proxy implements IProxy {
        
       public static const NAME:String = "LocaleProxy";
 
		  public function LocaleProxy( name:String, data:Object )
		  {  
			 trace("Setup Locale Proxy"); 
			 super( name, data );
		  }
		  
		  public function getLocale():Object
		  {
			 return data as Object;
		  }
		  
		  public function setLocale(o:*):void
		  {
			 data = o;
		  }
	 
		  public function get locale():Object
		  {
			 return data as Object;
		  }
		       
    }
}
