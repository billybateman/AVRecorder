package app.controller {
    import org.puremvc.interfaces.ICommand;
    import org.puremvc.interfaces.INotification;
    import org.puremvc.patterns.command.SimpleCommand;
    
    import app.model.ServiceProxy;
    import app.model.StateProxy;    

    /**
     * BaseCommand for this app
     * 
     * By inheriting from this command class, commands
     * will get easy access to our proxies
     * 
     * @author David Knape
     */
    public class BaseCommand extends SimpleCommand implements ICommand {
          
         protected var state:StateProxy;
         
         public function BaseCommand() 
         {
             state = facade.retrieveProxy( StateProxy.NAME ) as StateProxy;
         }
    }
}
