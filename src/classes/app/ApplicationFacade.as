package app
{
    import flash.display.DisplayObject;
	
	import org.puremvc.interfaces.*;
    import org.puremvc.patterns.proxy.*;
    import org.puremvc.patterns.facade.*;
	import org.puremvc.patterns.observer.*;
	
    import app.view.*;
    import app.controller.*;     

    /**
     * A concrete <code>Facade</code> for the application.
     * <P>
     * The main job of the <code>ApplicationFacade</code> is to act as a single 
     * place for mediators, proxies and commands to access and communicate
     * with each other without having to interact with the Model, View, and
     * Controller classes directly. All this capability it inherits from 
     * the PureMVC Facade class.</P>
     * 
     * <P>
     * This concrete Facade subclass is also a central place to define 
     * notification constants which will be shared among commands, proxies and
     * mediators, as well as initializing the controller with Command to 
     * Notification mappings.</P>
     */
    public class ApplicationFacade extends Facade
    {
        
        // Notification name constants
        public static const CMD_STARTUP:String              = "cmdStartup";      
        public static const CMD_STAGE_UPDATE:String         = "cmdStageUpdate";        
        public static const STAGE_RESIZE:String             = "stageResize";
		public static const JAVASCRIPT_CALL:String          = "javascriptCall";
		public static const JAVASCRIPT_CMD:String          = "javascriptCmd";
        public static const EVENT_CREATION_COMPLETE:String	= "onCreationComplete";
		public static const NET_CONNECTION:String			= "onNetConnection";
		
		// Flash Media Server
		public static const APP_READY:String 				= "appready";
		public static const GET_SETTINGS_CMD:String 		= "getSettingsCmd";
		public static const NETSTATUS:String 				= "netstatus";
		public static const LOG:String 						= "log";
		public static const INIT_LOCALE:String				= "onInitLocaleProxy";		
		
		public static const CHANGE_VOLUME_CMD:String       	= "onChangeVolumeCmd";
		public static const CHANGE_VOLUME_CALL:String       = "onChangeVolumeCall";
		
		public static const VIDEO_STOP_CALL:String       	= "onVideoStopCall";
		
		public static const VIDEO_PLAY_CALL:String       	= "onVideoPlayCall";
		public static const VIDEO_PLAY_CMD:String       	= "onVideoPlayCmd";
		
		public static const VIDEO_LENGTH_CALL:String       	= "onVideoLengthCall";
		public static const VIDEO_RECORD_CMD:String       	= "onVideoRecordCmd";
		public static const VIDEO_RECORD_CALL:String       	= "onVideoRecordCall";		
		
		public static const VIDEO_SAVED_CALL:String       	= "onVideoSavedCall";
		public static const VIDEO_SAVED_CMD:String       	= "onVideoSavedCommand";
		public static const VIDEO_SAVE_CMD:String       	= "onVideoSaveCommand";
		
		public static const VIDEO_PAUSE_CALL:String       	= "onVideoPauseCall";
		public static const VIDEO_SEEK_CALL:String       	= "onVideoSeekCall";
		public static const VIDEO_CHANGE_CALL:String       	= "onVideoChangeCall";		
		
		public static const AUDIO_PUBLISH_CALL:String       = "onAudioPublish";
		public static const AUDIO_UNPUBLISH_CALL:String     = "onAudioUnPublish";
		public static const AUDIO_CHANGE_CALL:String        = "onAudioChange";

		public static const VIDEO_PUBLISH_CALL:String       = "onVideoPublishCall";
		public static const VIDEO_UNPUBLISH_CALL:String     = "onVideoUnPublishCall";
		
		public static const PUBLISH_STREAM_CALL:String      = "onPublishStreamCall";		
		public static const VIDEO_STOP_PUBLISH_CALL:String  = "onVideoStopPublishCall";
		
		public static const FULL_SCREEN_CALL:String      	= "onFullScreenCall";	
		public static const FULL_SCREEN_CMD:String      	= "onFullScreenCmd";	
		
        /**
         * Startup method 
         */
        public function startup( root:DisplayObject, flashVars:Object ) : void {
            trace("Application Facade: Startup");			
			notifyObservers( new Notification( ApplicationFacade.INIT_LOCALE, flashVars ) );
			notifyObservers( new Notification( ApplicationFacade.CMD_STARTUP, root ) );			
        }
                
        /**
         * Register Commands with the Controller 
         */
        override protected function initializeController( ) : void 
        {
            trace("Application Facade: Initialize");			
			 
			super.initializeController();
			
			registerCommand( LOG, 				LogCommand );
			registerCommand( APP_READY, 		AppReadyCommand );
			
			registerCommand( VIDEO_SAVE_CMD, 	SaveVideoCommand );
			registerCommand( VIDEO_SAVED_CMD, 	SavedVideoCommand );
			registerCommand( VIDEO_PLAY_CMD, 	PlayVideoCommand );
			registerCommand( VIDEO_RECORD_CMD, 	RecordVideoCommand );
			registerCommand( CHANGE_VOLUME_CMD, ChangeVolumeCommand );
			registerCommand( FULL_SCREEN_CMD, 	FullScreenCommand );
			
			
			registerCommand( GET_SETTINGS_CMD, 	GetSettingsCommand );			
			registerCommand( NETSTATUS, 		NetStatusCommand );
			registerCommand( INIT_LOCALE, 		InitLocaleProxyCommand );
			registerCommand( JAVASCRIPT_CMD, 	JavaScriptCommand );			
            registerCommand( CMD_STARTUP,       StartupCommand      );           
            registerCommand( CMD_STAGE_UPDATE,  StageUpdateCommand  );
        }
        
        
        /**
         * Singleton ApplicationFacade Factory Method
         */
        public static function getInstance() : ApplicationFacade 
        {
            trace("Application Facade: Get Instance");			
			
			if ( instance == null ){
				instance = new ApplicationFacade( );
		    }
            	
			return instance as ApplicationFacade;
			
			
        }
        
    }
}
