package app.controller
	{
		
		import flash.net.NetConnection;
		import flash.display.DisplayObject;
    
		import org.puremvc.interfaces.*;
		import org.puremvc.patterns.command.*;
		import org.puremvc.patterns.observer.*;
		
		import app.model.*;
		import app.view.ApplicationMediator;
		import app.ApplicationFacade;
		import app.Main;
		
		
	
		public class ChangeVolumeCommand extends SimpleCommand implements ICommand
		{
			/* 
				When this runs we have initialised the framework and its players.
				Let's grab a proxy and connect to FMS.			
			 */
			override public function execute( note:INotification ):void
			{			
				// send something to the trace window
				sendNotification( ApplicationFacade.LOG, "Change Volume Command: Execute");							
				
				/* set the new volume_level in the local proxy */
				var localProxy:LocaleProxy = facade.retrieveProxy( LocaleProxy.NAME ) as LocaleProxy;
				var flashVars:Object = localProxy.getLocale() as Object;
				flashVars.volume_level = note.getBody();
				localProxy.setLocale(flashVars);
				
				
				sendNotification( ApplicationFacade.CHANGE_VOLUME_CALL, note.getBody());
				
			}
		
		}
		
	}