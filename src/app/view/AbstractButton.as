// TODO ::
// Fade the over_mc clip in and out
// Not sure what tweening package you want to go with...

package app.view
{
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class AbstractButton extends MovieClip
	{
		
		
		
		private var _isActive:Boolean;
		public function get isActive( ):Boolean
		{
			return _isActive;
		}
		
		public function set isActive( b:Boolean ):void
		{
			_isActive = b;
			this.mouseEnabled = _isActive;
			if( _isActive )
			{
				fadeOverState( 0 );
			}
			else
			{
				fadeOverState( 1 );
			}
		}
		
		public function AbstractButton( )
		{
			init( );
		}
		
		private function init( ):void
		{
			over_mc.alpha = 0;
			this.buttonMode = true;
			this.addEventListener( MouseEvent.MOUSE_OVER, over );
			this.addEventListener( MouseEvent.MOUSE_OUT, out );
		}
		
		private function over( e:MouseEvent ):void
		{
			if( _isActive )
			{
				return;
			}
			fadeOverState( 1 );
		}
		
		private function out( e:MouseEvent ):void
		{
			if( _isActive )
			{
				return;
			}
			fadeOverState( 0 );
		}
		
		private function fadeOverState( i:int )
		{
			// TODO :: Tween over_mc to i
			over_mc.alpha = i;
		}
	}
}