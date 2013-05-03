package com.bumpslide.util {    import flash.display.DisplayObject;    import flash.display.Sprite;    import flash.events.EventDispatcher;    import flash.geom.Point;    import flash.geom.Rectangle;    import flash.utils.Dictionary;           /**     * GridLayout is similar in nature to a Repeater, TileGrid, or List component.     *      *      *      * @author David Knape     */    public class GridLayout extends EventDispatcher {        //--- Events ---        static public const EVENT_CHANGED : String = "onGridLayoutChanged";        static public const EVENT_LAYOUT_COMPLETE : String = "onGridLayoutComplete";        //-- LAYOUT MODES --        static public const DIRECTION_DOWN_FIRST : Boolean = true;        static public const DIRECTION_ACROSS_FIRST : Boolean = false;        //--- CONFIG ---        public var debugEnabled : Boolean = false;                public var rowHeight : Number = 100;        public var columnWidth : Number = 100;        public var direction : Boolean = false;	                private var rows : Number = 5;        private var columns : Number = 1;                        //--- Private ---			        // target timeline (where holder will be created)        private var mTimeline : Sprite;        private var mTimelineOrigY : Number;        private var mTimelineOrigX : Number;        // empty clip that holds items and is re-created every time we redraw        private var mItemHolder : Sprite;	        // display object class to attach        // must implement IGridItem        private var mItemClass : Class;        // dataprovider        private var mDataProvider : *;		// offset and shortcuts        private var mOffset : Number = 0;        private var mIndexFirst : Number = 0;         private var mIndexLast : Number = 0;         private var mMinOffset : Number = 0;        private var mMaxOffset : Number = 0;        // array of all item clips        private var mItemClips : Array;        // array of item clips mapped to indexes        private var mClipMap : Object;        private var mActiveClips : Dictionary;		        // stack of un-assigned clips (to be recycled)        private var mSpareClips : Array;			// misc state vars        private var mDrawn : Boolean = false;        private var mUpdateRequired : Boolean = false;        private var mSleeping : Boolean = false;        private var mWidth : Number;        private var mHeight : Number;                /**         * Create a new grid layout         *          * @param	targetTimeline_mc         * @param	mItemLinkageIdIdString		*/        function GridLayout( inTimeline:Sprite, inItemClass:Class, inColumnWidth:Number=100, inRowHeight:Number=100, inWidth:Number=-1, inHeight:Number=-1) {            //AsBroadcaster.initialize( this );            mTimeline = inTimeline;            mTimelineOrigY = mTimeline.y;            mTimelineOrigX = mTimeline.x;            mItemClass = inItemClass;		                        rowHeight = inRowHeight;            columnWidth = inColumnWidth;                        reset();                        if(inWidth!=-1 && inHeight!=-1) {            	setSize( inWidth, inHeight );            }			            			//DataProvider.Initialize( Array );        }        /**         * array of references to all the grid item MovieClips in the current view         */        public function get itemClips() : Array {            return mItemClips;        }        /**         * A recordset or an array         *          * TODO - Add support for data providers? (fl.data.DataProvider?)         *          * @return array of item data         */        public function get dataProvider() : * {            return mDataProvider;        }        /**         * An array         *          * @param	data array         */        public function set dataProvider( dp : * ) : void {            mDataProvider = dp;			            debug('setting dataProvider length=' + dataProvider.length);			            mMinOffset = 0;            mMaxOffset = dataProvider.length - itemsPerPage;			            // TODO - listen to dataprovider events            //mDataProvider.addEventListener( 'modelChanged', this );            reset();			//delayedCall = Reactor.callNextFrame( update );	        }        /**         * returns length of the dataprovider (total number of items in grid)         * @return         */        public function get length() : int {            if(dataProvider != null) return dataProvider.length;			else return 0;        }        /**         * returns reference to timeline         * @return         */        public function get timeline() : DisplayObject {            return mTimeline;        }        /**         * offset in dataprovider (index of first item in the grid)         *          * @param	n         */        public function get offset() : Number {            return mOffset;        }        /**         * offset in dataprovider (index of first item in the grid)         *          * @param	n         */        public function set offset( inOffset : Number ) : void {						//var previous_value:Number = mOffset;			            // constrain offset            mOffset = Math.max(mMinOffset, Math.min(mMaxOffset, inOffset));						//if(mOffset==previous_value) return;						debug('offset changed to ' + mOffset);						mIndexFirst = Math.floor(mOffset);            mIndexLast = Math.ceil( mOffset ) + itemsPerPage - 1;                        var fractionalOffset:Number = (mOffset - Math.floor(mOffset));            var scroll:Rectangle = null;                        //if(fractionalOffset!=0) {	                        	// offset main holder to simulate "scrolling"            	// if rect width is greater than the default page size, add an item to the end            	// this allows us to do smooth scrolling from end to end            	scroll = new Rectangle( 0, 0, mWidth, mHeight);	            if(rows == 1) {	            	scroll.x = Math.round(columnWidth * fractionalOffset); 	            	if(mWidth>columnWidth*columns) mIndexLast+=1;	            }	            if(columns == 1) {	            	scroll.y = Math.round(rowHeight * fractionalOffset);	            	if(mHeight>rowHeight*rows) mIndexLast+=1;	            }	            //}                         if(mItemHolder!=null) {	            	mItemHolder.scrollRect = scroll;			}			            mIndexLast = Math.max( Math.min( mIndexLast, length-1 ), 0 );						//trace('length ='+length );			//trace('mIndexLast ='+mIndexLast );			            debug(mIndexFirst + ' - ' + mIndexLast);            if(length>0) update();        }        /**         * Items per page         */        public function get itemsPerPage() : Number {            return rows * columns;        }        /**         * Returns the total number of pages          *          * This is calculated using the  current dataprovider and the number of items per page         *          * This is useful for displaying page info in controls and things like that.         *          * @return         */        public function get totalPages() : Number {		            return Math.ceil(length / itemsPerPage);        }                /**         * Minimum scroll offset         */        public function get minOffset() : Number {		            return mMinOffset;        }        /**         * Minimum scroll offset         */        public function set minOffset( val : Number ) : void {            mMinOffset = val;		        }        /**         * Maximum scroll offset         */        public function get maxOffset() : Number {		            return mMaxOffset;        }        /**         * Maximum scroll offset         */        public function set maxOffset( val : Number ) : void {            mMaxOffset = val;		        }                /**         * Update the grid - non-destructive         */        public function update( fromModelChange : Boolean = false ) : void {		            if(mSleeping) {                debug('updated while sleeping , waiting to wake');                mUpdateRequired = true;                return;            }                       doUpdate(fromModelChange);                    }        /**         * hibernation, grid won't respond to changes until awakened         */        public function sleep() : void {            debug('sleep');            mSleeping = true;        }        /**         * brings grid back to life, updates it if something has changed while we were sleeping         */        public function wake() : void {	            debug('wake');            mSleeping = false;            if(mUpdateRequired) update();        }        /**         * Zero-index page number based on current mOffset         */        public function get page() : int {            return Math.floor(mOffset / itemsPerPage);        }        /**         * sets the page number (0 is first page)         * @param	num         */        public function set page( num : int ) : void {		            offset = itemsPerPage * num;		        }        /**         * go to the next page         */        public function pageNext() : void {            offset += itemsPerPage;        }        /**         * go to the previous page         */        public function pagePrevious() : void {            offset -= itemsPerPage;        }        /**          * Sizes the Grid         *          * Based on the current rowHeight and columnWidth, this updates the column and row count         * and triggers a redraw if the items per page changes.         *          */        public function setSize(w : Number, h : Number) : void {		            debug('set size ' + w + ',' + h);			mWidth = Math.round(w);			mHeight = Math.round(h);			            //var oldItemsPerPage : int = rows * columns;			            rows = 1;            columns = 1;			            if(!isNaN(rowHeight) && rowHeight > 0) {                rows = Math.max(1, Math.floor(h / rowHeight)); 	            }			            if(!isNaN(columnWidth) && columnWidth > 0) {                columns = Math.max(1, Math.floor(w / columnWidth));	            }			            debug('rows = ' + rows + ', cols=' + columns);						// update max offset			mMaxOffset = length - itemsPerPage;                        // constrain offset by settting it to itself            // this will also trigger an update            offset = mOffset;						// always update on size change            //update();        }        /**         * Clear items and reset         */        public function reset() : void {			                        mSleeping = false;            mUpdateRequired = false;            mDrawn = false;                        if( mItemHolder!=null && mTimeline.contains( mItemHolder )) {            	mTimeline.removeChild( mItemHolder );            }            mItemHolder = new Sprite();            mTimeline.addChild(mItemHolder);	            mItemClips = new Array();            mSpareClips = new Array();            mClipMap = new Array();            mActiveClips = new Dictionary();            			            offset = 0;        }        /**         * Destroy the grid - upload          */	        public function destroy() : void {            reset();						// remove all dispatcher listeners			// TODO: remove all listeners			//removeAllListeners( EVENT_CHANGED );        }//        private function modelChanged() : void {//            debug('model changed');//            update(true);//        }        /**         * Updates the grid         */        private function doUpdate(fromModelChange : Boolean = false) : void {						            if(dataProvider == null || dataProvider.length == 0) return;						mUpdateRequired = false;			            debug('doUpdate');						for each( var item:IGridItem in mActiveClips ) {				recycleIfNecessary( item );			}			            var mc : IGridItem;			            for( var n : int = mIndexFirst;n <= mIndexLast; n++ ) {				                //debug('doUpdate item' + n);				                // look for MC already assigned to this index and update its position                //mc = mClipMap['_'+n];				mc = mActiveClips[n];				                if(mc == null) {		                	// create new grid item (pull from stack of latent clips if there are some)                    mc = getItemClip();                                        // update the item with proper data                    updateItem(mc, n);	                    mItemHolder.addChild(mc as DisplayObject);				                } else {	                    // If this was triggered by a model change, check to see if                     // data has changed for this item index		                    if(fromModelChange) {                        var item_data : Object = dataProvider.getItemAt != undefined ? dataProvider.getItemAt(n) : dataProvider[n];                        if(mc.gridItemData != item_data) {					                            debug('updating exisiting clip ' + mc.gridIndex + ' to be ' + n);                            updateItem(mc, n);                        }	                    } else {	                    // update exisiting clips item position				                var pos : Point = calculateItemPosition(n);		                mc.x = pos.x;		                mc.y = pos.y;	                    }					                }                //trace(mc['name'] + '.x='+mc['x']);				                            }					            if(mDrawn) {                //dispatchEvent(new UIEvent(EVENT_CHANGED, this));            } else {                mDrawn = true;                notifyComplete();            }        }	        /**         * Recycle unused item clips and hold save them for re-use         */        private function recycleIfNecessary( mc : IGridItem) : void {            if(( mc.gridIndex < mIndexFirst || mc.gridIndex > mIndexLast ) ) {                debug('recycling clip ' + mc['name']);                //mClipMap['_'+mc.gridIndex] = null;                delete mActiveClips[ mc.gridIndex ];                                mc.gridIndex = Number.NaN;                mc.destroy();                 mItemHolder.removeChild(mc as DisplayObject);                mSpareClips.push(mc);            }        }        /**         * Get spare item clip or create a new one         */        private function getItemClip() : IGridItem {            var item : IGridItem;            // If we have some spare, unused clips, use them             if(!mSpareClips.length) {                 item = new mItemClass() as IGridItem;                debug('created new clip '+item['name']);                // hold on to this for future use                mItemClips.push(item);             } else {	                		                item = mSpareClips.pop() as IGridItem;                debug('re-using old clip '+item['name']);	            }		            return item;        }		        private function updateItem( item : IGridItem, idx : int ) : void {	            debug('update item ' + idx + ' ' + item);	                        item.gridIndex = idx;            item.gridItemData = dataProvider.getItemAt != undefined ? dataProvider.getItemAt(idx) : dataProvider[idx];            		            var pos : Point = calculateItemPosition(idx);            item.x = pos.x;            item.y = pos.y;		                        //mClipMap['_'+idx] = item;            mActiveClips[idx] = item;        }        private function notifyComplete() : void {		            //dispatchEvent(new UIEvent(EVENT_LAYOUT_COMPLETE, this));            //dispatchEvent(new UIEvent(EVENT_CHANGED, this));        }        /**         * Calculated the x and y pos for the grid item at index n         *          * @param	i         * @return x,y location as point         */        private function calculateItemPosition( n : Number ) : Point {					            var i : int = n - mIndexFirst;            var column : int;            var row : int;					            // If columns count is valid...            if(!isNaN(columns) && columns > 0 && rows>1) {                // calculate grid index (column and row)                if(direction == DIRECTION_DOWN_FIRST) {                    row = i % rows;                    column = Math.floor(i / rows);		                } 				else {                    column = i % columns;                    row = Math.floor(i / columns);		                }			            } 			else {		                // assume an endless row, so column is simply n,                 // and the row is always 0 (the first row)                column = i;                row = 0;				            }			            return new Point(Math.round(columnWidth * column), Math.round(rowHeight * row));        }        /**         * Debug/trace         */        private function debug(s : *) : void {            if(debugEnabled) trace('[GridLayout] ' + s);        }    }}