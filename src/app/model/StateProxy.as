package app.model {
    
    import org.puremvc.patterns.observer.Notification;
    import org.puremvc.patterns.proxy.Proxy;
    import org.puremvc.interfaces.IProxy;
    
    import app.ApplicationFacade;
  

    /**
     * We use this proxy to manage all top level app state changes
     */
    public class StateProxy extends Proxy implements IProxy {
        
        public static const NAME:String = "StateProxy";
        
       
                
        public function StateProxy() {
            super(NAME, null);
        }
        
                
        // notification constants are in Application Facade
           private function notifyChanged(varName:String):void {
               var note:Notification = new Notification( "statechange_"+varName, this[varName] );
               facade.notifyObservers(note);
        }
        
        
    }
}
