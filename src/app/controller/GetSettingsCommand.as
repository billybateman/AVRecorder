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
		
		
	
		public class GetSettingsCommand extends SimpleCommand implements ICommand
		{
			/* 
				When this runs we have initialised the framework and its players.
				Let's grab a proxy and connect to FMS.			
			 */
			override public function execute( note:INotification ):void
			{			
				// send something to the trace window
				sendNotification( ApplicationFacade.LOG, "Get Settings Command: Execute");
				
				/* Get the user from the local proxy */
				var localProxy:LocaleProxy = facade.retrieveProxy( LocaleProxy.NAME ) as LocaleProxy;
				var flashVars:Object = localProxy.getLocale() as Object;				
				var settings_path:String = flashVars.basePath;
				
				sendNotification( ApplicationFacade.LOG, "Settings Path: " + settings_path);
				
				
				/* Get the user from the local proxy */
				var settingsProxy:SettingsProxy = facade.retrieveProxy( SettingsProxy.NAME ) as SettingsProxy;
				settingsProxy.getSettings(settings_path);			
				
				
			}
		
		}
		
	}