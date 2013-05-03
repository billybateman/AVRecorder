	
	package app.controller
	{
		import org.puremvc.interfaces.*;
		import org.puremvc.patterns.command.*;
		import org.puremvc.patterns.observer.*;
		
		import app.model.*;
		import app.view.ApplicationMediator;
		import app.ApplicationFacade;
		import app.Main;
		
		import org.osflash.thunderbolt.Logger;
	
		public class LogCommand extends SimpleCommand implements ICommand
		{
			
			override public function execute( note:INotification ):void
			{
				var msg:String = note.getBody() as String;
				
				// Trace to output window
				trace( msg );
				
				Logger.info("AV Recorder:", msg);
				
			}
		}
	}