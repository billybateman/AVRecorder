﻿/* * Copyright 2006-2007 (c) Donovan Adams, http://blog.hydrotik.com/ * * Permission is hereby granted, free of charge, to any person * obtaining a copy of this software and associated documentation * files (the "Software"), to deal in the Software without * restriction, including without limitation the rights to use, * copy, modify, merge, publish, distribute, sublicense, and/or sell * copies of the Software, and to permit persons to whom the * Software is furnished to do so, subject to the following * conditions: * * The above copyright notice and this permission notice shall be * included in all copies or substantial portions of the Software. * * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR * OTHER DEALINGS IN THE SOFTWARE. */package com.bumpslide.net {		import flash.display.Loader;	import flash.display.LoaderInfo;	import flash.events.Event;	import flash.events.EventDispatcher;	import flash.events.IEventDispatcher;	import flash.events.IOErrorEvent;	import flash.events.ProgressEvent;	import flash.media.Sound;	import flash.net.URLRequest;		import com.bumpslide.events.QueueLoaderEvent;		import flash.system.LoaderContext;			public class QueueLoader implements IEventDispatcher {				// Colophon				public static const VERSION:String = "QueueLoader 3.0.6 - Stable";				public static const AUTHOR:String = "Donovan Adams - donovan[(at)]hydrotik.com based on as2 version by Felix Raab - f.raab[(at)]betriebsraum.de";				// List of file types				public static const FILE_IMAGE:int = 1;				public static const FILE_SWF:int = 2;				public static const FILE_AUDIO:int = 3;				// Private				private var _loader:Loader;				private var queuedItems:Array;				private var currItem:Object;				private var itemsToInit:Array;				private var loadedItems:Array;				private var isStarted:Boolean;				private var isStopped:Boolean;				private var isLoading:Boolean;		private var dispatcher:EventDispatcher;				private var _count:int = 0;				private var _max:int = 0;				private var _queuepercentage:Number;				private var _ignoreErrors:Boolean;				private var  _currType:int;				private var _currFile : *;				private var _loaderContext : LoaderContext;				private var _setMIMEType : Boolean;		/**		 * QueueLoader AS 3		 *		 * @author: Donovan Adams, E-Mail: donovan[(at)]hydrotik.com, url: http://www.hydrotik.com/		 * @author: Based on Felix Raab's QueueLoader for AS2, E-Mail: f.raab[(at)]betriebsraum.de, url: http://www.betriebsraum.de		 * @version: 3.0.6		 *		 * @description QueueLoader is a linear asset loading tool with progress monitoring. It's largely used to load a sequence of images or a set of external assets in one step. Please contact me if you make updates or enhancements to this file. If you use QueueLoader, I'd love to hear about it. Special thanks to Felix Raab for the original AS2 version! Please contact me if you find any errors or bugs in the class or documentation.		 *		 * @example This example shows how to use QueueLoader:				<code>					import com.hydrotik.utils.QueueLoader;					import com.hydrotik.utils.QueueLoaderEvent;															//Instantiate the QueueLoader					var _oLoader:QueueLoader = new QueueLoader();										//Run a loop that loads 3 images from the flashassets/images/slideshow folder					var image:Sprite = new Sprite();					addChild(image);					//Add a load item to the loader					_oLoader.addItem(prefix("") + "flashassets/images/slideshow/1.jpg", image, {title:"Image"});										//Add event listeners to the loader					_oLoader.addEventListener(QueueLoaderEvent.QUEUE_START, onQueueStart, false, 0, true);					_oLoader.addEventListener(QueueLoaderEvent.ITEM_START, onItemStart, false, 0, true);					_oLoader.addEventListener(QueueLoaderEvent.ITEM_PROGRESS, onItemProgress, false, 0, true);					_oLoader.addEventListener(QueueLoaderEvent.ITEM_INIT, onItemInit,false, 0, true);					_oLoader.addEventListener(QueueLoaderEvent.ITEM_ERROR, onItemError,false, 0, true);					_oLoader.addEventListener(QueueLoaderEvent.QUEUE_PROGRESS, onQueueProgress, false, 0, true);					_oLoader.addEventListener(QueueLoaderEvent.QUEUE_INIT, onQueueInit,false, 0, true);										//Run the loader					_oLoader.execute();										//Listener functions					function onQueueStart(event:QueueLoaderEvent):void {						trace(">> "+event.type);					}										function onItemStart(event:QueueLoaderEvent):void {						trace("\t>> "+event.type, "item title: "+event.title);					}										function onItemProgress(event:QueueLoaderEvent):void {						trace("\t>> "+event.type+": "+[" percentage: "+event.percentage]);					}										function onQueueProgress(event:QueueLoaderEvent):void {						trace("\t>> "+event.type+": "+[" queuepercentage: "+event.queuepercentage]);					}										function onItemInit(event:QueueLoaderEvent):void {						trace("\t>> name: "+event.title + " event:" + event.type+" - "+["target: "+event.targ, "w: "+event.width, "h: "+event.height]+"\n");					}										function onItemError(event:QueueLoaderEvent):void {						trace("\n>>"+event.message+"\n");					}										function onQueueInit(event:QueueLoaderEvent):void {						trace("** "+event.type);					}				</code>		 */ 		/**		 * @param	ignoreErrors:Boolean false for stopping the queue on an error, true for ignoring errors.		 * @return	void		 * @description Contructor for QueueLoader		 */        public function QueueLoader(ignoreErrors : Boolean = false, loaderContext : LoaderContext = null, setMIMEType : Boolean = false) {			dispatcher = new EventDispatcher(this);            _loader = new Loader();			_ignoreErrors = ignoreErrors;			_loaderContext = loaderContext;			_setMIMEType = setMIMEType;            configureListeners(_loader.contentLoaderInfo);           reset();        }		/**		 * @param	url:String - asset file path		 * @param	targ:* - target location		 * @param	info:Object - data		 * @return	void		 * @description Adds an item to the loading queue		 */		public function addItem(url:String, targ:*, info:Object):void{			addItemAt(queuedItems.length, url, targ, info);		}				/**		 * @param	index:Number - insertion index		 * @param	url:String - asset file path		 * @param	targ:* - target location		 * @param	info:Object - data to be stored and retrieved later		 * @return	void		 * @description Adds an item to the loading queue at a specific position		 */		public function addItemAt(index:Number, url:String, targ:*, info:Object):void {			if (targ == null) trace("QueueLoader: target undefined for "+url);			queuedItems.splice(index, 0, {url:url, targ:targ, info:info});			itemsToInit.splice(index, 0, {url:url, targ:targ, info:info});		}				/**		 * @description Removes Items Loaded from memory for Garbage Collection		 */		public function dispose() : void {			var i:int;			for(i = 0;i < loadedItems.length;i++) {				loadedItems[i].loaderInfo.loader.unload();				loadedItems[i] = null;			}			_loader = null;			_max = 0;			reset();		};				/**		 * @description Executes the loading sequence		 */		public function execute():void {			isStarted = true;			isLoading = true;			isStopped = false;					_max = queuedItems.length;			loadNextItem();			}				// --== Implemented interface methods ==--								public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void{			dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);		}			   		public function dispatchEvent(evt:Event):Boolean{			return dispatcher.dispatchEvent(evt);		}				public function hasEventListener(type:String):Boolean{			return dispatcher.hasEventListener(type);		}				public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void{			dispatcher.removeEventListener(type, listener, useCapture);		}					   		public function willTrigger(type:String):Boolean {			return dispatcher.willTrigger(type);		}				// --== Private Methods ==--				// --== Listeners and Handlers ==--        private function configureListeners(dispatcher:IEventDispatcher):void {            dispatcher.addEventListener(Event.INIT, completeHandler);            dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);            dispatcher.addEventListener(Event.OPEN, openHandler);            dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);        }               private function ioErrorHandler(event:IOErrorEvent):void {			if(event.text != ""){				dispatchEvent(new QueueLoaderEvent(QueueLoaderEvent.ITEM_ERROR, currItem.targ, _currFile, currItem.url, currItem.info.title, _currType, 0, 0, 0, _queuepercentage, 0, 0, "io error: "+event.text + " could not be loaded into " + currItem.targ.name, _count, queuedItems.length, _max, currItem.info.dataObj));				if(_ignoreErrors){					loadedItems.push(currItem.targ);						_count++;					isQueueComplete();				}			}		}        private function openHandler(event:Event):void {			if (isStarted) {				_max = queuedItems.length;				dispatchEvent(new QueueLoaderEvent(QueueLoaderEvent.QUEUE_START, currItem.targ, _currFile, currItem.url, currItem.info.title, _currType, 0, 0, 0, 0, 0, 0, "", _count, queuedItems.length, _max, currItem.info.dataObj));				isStarted = false;					}			dispatchEvent(new QueueLoaderEvent(QueueLoaderEvent.ITEM_START, currItem.targ, _currFile, currItem.url, currItem.info.title, _currType, 0, 0, 0, _queuepercentage, 0, 0, "", _count, queuedItems.length, _max, currItem.info.dataObj));        }        private function progressHandler(event:ProgressEvent):void { 			if (isLoading){				var sec:Number = 100/(_max + 1);				_queuepercentage =  ((_count * sec) + ((event.bytesLoaded/event.bytesTotal) * sec)) * .01;				dispatchEvent(new QueueLoaderEvent(QueueLoaderEvent.ITEM_PROGRESS, currItem.targ, _currFile, currItem.url, currItem.info.title, _currType, event.bytesLoaded, event.bytesTotal, event.bytesLoaded/event.bytesTotal, _queuepercentage, 0, 0, "", _count, queuedItems.length, _max, currItem.info.dataObj));				dispatchEvent(new QueueLoaderEvent(QueueLoaderEvent.QUEUE_PROGRESS, currItem.targ, _currFile, currItem.url, currItem.info.title, _currType, event.bytesLoaded, event.bytesTotal, event.bytesLoaded/event.bytesTotal, _queuepercentage, 0, 0, "", _count, queuedItems.length, _max, currItem.info.dataObj));			}		}				private function completeHandler(event:Event):void {			var w:Number = 0;			var h:Number = 0;			if(_currType != FILE_AUDIO){				var loader:Loader = Loader(event.target.loader);				loadedItems.push(loader.content);				 _currFile = loader.content;				var info:LoaderInfo = LoaderInfo(event.target);				w = info.width;				h = info.height;			}			dispatchEvent(new QueueLoaderEvent(QueueLoaderEvent.ITEM_INIT, currItem.targ, _currFile, currItem.url, currItem.info.title, _currType, 0, 0, 100, _queuepercentage, w, h,  "", _count, queuedItems.length, _max, currItem.info.dataObj));			_count++;			isQueueComplete();        }				private function loadNextItem():void {					currItem = queuedItems.shift();					if (currItem.targ == undefined) {					//onLoadError(currItem.targ, "TargetUndefined");								trace("load error");			} else {				if (!isStopped) {								_currType = 0;					if(_setMIMEType) {						if(currItem.info.mimeType != undefined) {							_currType = currItem.info.mimeType;						}else {							dispatchEvent(new QueueLoaderEvent(QueueLoaderEvent.ITEM_ERROR, currItem.targ, _currFile, currItem.url, currItem.info.title, _currType, 0, 0, 0, _queuepercentage, 0, 0, "QueueLoader error: " + currItem.info.title + " setMIMEType is set to true and no mime type for this item has been specified (example: QueueLoader.FILE_XML)", _count, queuedItems.length, _max, currItem.info.dataObj));						}					}else {						if(currItem.url.match(".jpg") != null) _currType = FILE_IMAGE;						if(currItem.url.match(".gif") != null) _currType = FILE_IMAGE;						if(currItem.url.match(".png") != null) _currType = FILE_IMAGE;						if(currItem.url.match(".swf") != null) _currType = FILE_SWF;						if(currItem.url.match(".mp3") != null) _currType = FILE_AUDIO;					}					var request:URLRequest = new URLRequest(currItem.url);					switch (_currType) {						case FILE_IMAGE:							trace("Image File");							_loader = new Loader();							configureListeners(_loader.contentLoaderInfo);							_loader.load(request);							currItem.targ.addChild(_loader);							break;						case FILE_SWF:							trace("External SWF File");							_loader = new Loader();							configureListeners(_loader.contentLoaderInfo);							_loader.load(request);							currItem.targ.addChild(_loader);							break;						case FILE_AUDIO:							trace("External Audio");							var sound:Sound = currItem.targ;							sound.addEventListener(Event.COMPLETE, completeHandler);							sound.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);							sound.addEventListener(ProgressEvent.PROGRESS, progressHandler);							sound.load(request);							break;						default:							trace("None Detected");					}				}			}						}				private function isQueueComplete():void {			if (!isStopped) {						if (queuedItems.length == 0) {						isLoading = false;					loadedItems = loadedItems;						dispatchEvent(new QueueLoaderEvent(QueueLoaderEvent.QUEUE_INIT, currItem.targ, _currFile, currItem.url, currItem.info.title, _currType, 0, 0, 0, _queuepercentage, 0, 0, "", _count, queuedItems.length, _max, currItem.info.dataObj));										reset();				} else {					loadNextItem();				}						}					}				private function reset():void {			queuedItems = new Array();			itemsToInit = new Array();			loadedItems = new Array();			currItem = null;					_max = 0;		}    }}