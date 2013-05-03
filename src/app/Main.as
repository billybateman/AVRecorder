package app {
	
    import flash.display.MovieClip;
	import flash.text.*;
    import flash.events.Event;    
    import flash.display.LoaderInfo;
	import app.view.components.*;
	

    /**
     * PureMVC Gallery Demo main.fla Document Class
     */    
    public class Main extends MovieClip {
        	
		public var top_menu_mc:TopMenu;
		public var bottom_menu_mc:BottomMenu;
		public var video_area_mc:VideoArea;
		public var save_mc:Save;		
          
        public function Main()
        {    
            trace("Main: Loading Application");
			
			stop();
            // if there is a preloader, we will be added
            // to the stage once loading is completed
            addEventListener( Event.ADDED_TO_STAGE, start );
        }     
        
        /**
         * This is called by preloader once entire swf is loaded
         */
        public function start(e:Event=null) : void 
        {
        	trace("Main: Start");
			
			// advance timeline
            gotoAndStop( 'start' );             
            
            var flashVars:Object = LoaderInfo( this.loaderInfo ).parameters;
            
            // init PureMVC Facade
            var facade:ApplicationFacade = ApplicationFacade.getInstance();
            facade.startup( this, flashVars );
        }

    }
}
