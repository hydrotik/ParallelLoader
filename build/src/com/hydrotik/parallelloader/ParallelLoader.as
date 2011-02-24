/*
 * Copyright 2007-2009 (c) Donovan Adams, http://blog.hydrotik.com/
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */


package com.hydrotik.parallelloader {
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.system.LoaderContext;
	import flash.utils.Timer;

	[Event(name="ITEM_START", type="com.hydrotik.queueloader.ParallelLoaderEvent")]

	[Event(name="ITEM_PROGRESS", type="com.hydrotik.queueloader.ParallelLoaderEvent")]

	[Event(name="ITEM_COMPLETE", type="com.hydrotik.queueloader.ParallelLoaderEvent")]

	[Event(name="ITEM_ERROR", type="com.hydrotik.queueloader.ParallelLoaderEvent")]

	[Event(name="START", type="com.hydrotik.queueloader.ParallelLoaderEvent")]

	[Event(name="PROGRESS", type="com.hydrotik.queueloader.ParallelLoaderEvent")]

	[Event(name="COMPLETE", type="com.hydrotik.queueloader.ParallelLoaderEvent")]

	public class ParallelLoader implements IEventDispatcher, IParallelLoader {

		
		
		
		
		
		// See ItemList for respective Item Types
		/**************************************/

		
		protected static var _init : Boolean = false;

		protected var dispatcher : EventDispatcher;

		protected var _ignoreErrors : Boolean;

		protected var _loaderContext : LoaderContext;

		protected var debug : Function;

		protected var _index : int;

		protected var _loadingQueue : Vector.<ILoadable>;

		protected var _isLoading : Boolean;

		protected var _percentage : Number;

		protected var _currBytes : int = 0;

		protected var _totalBytes : int = 0;
		
		protected var _isComplete : Boolean;

		protected var _bandwidth : Number;

		protected var _prevBytes : Number;

		protected var _bwTimer : Timer;

		protected var _bwChecking : Boolean;

		protected var _packetRec : Array;

		protected var _id : String = "";
		
		private var _bytesLoaded : Vector.<Number>;

		/**
		 * ParallelLoader AS 3
		 *
		 * @author: Donovan Adams, E-Mail: donovan[(replace at)]hydrotik.com, url: http://blog.hydrotik.com/
		 * @author: Project home: <a href="" target="blank">ParallelLoader on Google Code</a><br><br>
		 * @version: 0.1.0
		 *
		 * @description 
		 *
		 * @history <a href="" target="blank">Up-To-Date Change Log Information here</a>
		 *
		 * @example Go to <a href="" target="blank">ParallelLoader Guide on Google Code</a> for more usage info. This example shows how to use ParallelLoader in a basic application:
		<code>
		</code>
		 */  
		/**
		 * @param	ignoreErrors: Boolean false for stopping the queue on an error, true for ignoring errors.
		 * @param	loaderContext: Allows access of a loaded SWF's class references
		 * @param	bandwidthMonitoring: Turns on bandwidth monitoring, returning a continious KB/S value to the bandwidth property in the event handler.
		 * @return	void
		 * @description Contructor for ParallelLoader
		 */
		public function ParallelLoader(ignoreErrors : Boolean = false, loaderContext : LoaderContext = null, bandwidthMonitoring : Boolean = false, id : String = "") {
			if(!_init) _init = ItemList.initItems();
			dispatcher = new EventDispatcher(this);
			debug = trace;
			if(ParallelLoaderConst.VERBOSE) debug("\n\n========== new ParallelLoader() version:" + ParallelLoaderConst.VERSION + " - publish: " + (new Date()).toString());
			init();
			_isComplete = false;
			_loaderContext = loaderContext;
			_ignoreErrors = ignoreErrors;
			_bwChecking = bandwidthMonitoring;
			if(_bwChecking) _bwTimer = new Timer(100);
			_id = id;
			if(_id != "") PLManager.addQueue(_id, this);
		}

		/**
		 * @param	src:String - asset file path
		 * @param	container:* - container location
		 * @param	info:Object - data
		 * @return	void
		 * @description Adds an item to the loading queue
		 */
		public function addItem(src : String, container : * = null, info : Object = null) : void {
			if(ParallelLoaderConst.VERBOSE) debug(">> addItem() args:" + [src, container, info, info.mimeType, info.cacheKiller]);
			addItemAt(_loadingQueue.length, src, container, (info != null) ? info : {});
		}

		/**
		 * @param	index:Number - insertion index
		 * @param	src:String - asset file path
		 * @param	container:* - container location
		 * @param	info:Object - data to be stored and retrieved later
		 * @return	void
		 * @description Adds an item to the loading queue at a specific position
		 */
		public function addItemAt(index : Number, src : String, container : *, info : Object) : void {
			if(ParallelLoaderConst.VERBOSE) debug(">> addItemAt() args:" + [index, src, container, info]);
			var fileType : int;
			var i : String;
			var strip : Array = src.split("?");
			var urlVars : String = "?";
			if(strip.length > 1) {
				var hash : Array = strip[1].split("&");
				for(var v : int = 0;v < hash.length; v++) {
					var pairs : Array = hash[v].split("=");
					urlVars = urlVars + pairs[0] + "=" + pairs[1];
					if (hash.length - 1 != v) urlVars += "&";
				}
			}
			if(info.cacheKiller != null) urlVars = urlVars + "cache=" + (new Date()).getTime().toString();
			var urlReq : URLRequest;
			if(info.mimeType == null) {
				for(i in ItemList.itemArray) if(strip[0].search(ItemList.itemArray[int(i)].regEx) != -1) fileType = int(i);
				urlReq = new URLRequest(strip[0] + ((getMode() && urlVars.length > 1) ? urlVars : ""));
			} else {
				fileType = info.mimeType;
				urlReq = new URLRequest(strip[0] + ((urlVars.length > 1) ? urlVars : ""));
			}
			for(i in ItemList.itemArray) if(int(i) == fileType) _loadingQueue.splice(index, 0, new (ItemList.itemArray[int(i)].classRef)(urlReq, container, info, _loaderContext, int(i)) as ILoadable);
		}


		/**
		 * @description Executes the loading sequence
		 * @return	void
		 */
		public function execute() : void {
			if(ParallelLoaderConst.VERBOSE) debug(">> execute() " + [_isLoading, _bwTimer]);
			if(_loadingQueue.length < 1){
				throw new Error("Your ParallelLoader queue has nothing in it!");
			}
			if(_isLoading) return;
			_isComplete = false;	
			_index = 0;
			_percentage = 0;
			_currBytes = 0;
			_totalBytes = 0;
			_bandwidth = 0;
			_prevBytes = 0;
			for (var i : int = 0; i < _loadingQueue.length; i++) {
				if(_loadingQueue[i].registerItem(this)){
					_loadingQueue[i].index = i;
					_bytesLoaded[i] = 0;
					_loadingQueue[i].load();
				}
			}
		}
		
		public function updateTotal(bytes:int):void{
			_totalBytes = _totalBytes + bytes;
		}
		
		/**
		 * @description Removes Items Loaded from memory for Garbage Collection
		 * @return	void
		 */
		public function dispose() : void {
			if(ParallelLoaderConst.VERBOSE) debug(">> dispose()");
			
			while(_loadingQueue.length > 0) {
				var item : ILoadable = _loadingQueue.pop();
				item.deConfigureListeners();
				if(item.isLoaded) item.dispose();
				item = null;
			}
			if(_id != "") {
				var removed : Boolean = PLManager.removeQueue(_id);
				if(ParallelLoaderConst.VERBOSE) debug("QueueRemoved: " + _id, removed);
			}
			init();
		};
		
		
		// --== Implemented interface methods ==--
		public function addEventListener(type : String, listener : Function, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false) : void {
			dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		public function dispatchEvent(evt : Event) : Boolean {
			return dispatcher.dispatchEvent(evt);
		}

		public function hasEventListener(type : String) : Boolean {
			return dispatcher.hasEventListener(type);
		}

		public function removeEventListener(type : String, listener : Function, useCapture : Boolean = false) : void {
			dispatcher.removeEventListener(type, listener, useCapture);
		}

		public function willTrigger(type : String) : Boolean {
			return dispatcher.willTrigger(type);
		}

		public function httpStatusHandler(event : HTTPStatusEvent) : void {
			dispatchEvent(new ParallelLoaderEvent(ParallelLoaderEvent.ITEM_HTTP_STATUS, null, _totalBytes, _currBytes, _percentage));
		}
		
		public function ioErrorHandler(currItem:ILoadable) : void {
			dispatchEvent(new ParallelLoaderEvent(ParallelLoaderEvent.ITEM_ERROR, currItem, _totalBytes, _currBytes, _percentage));
		}

		public function openHandler(currItem:ILoadable) : void {
			if(!_isLoading){
				dispatchEvent(new ParallelLoaderEvent(ParallelLoaderEvent.START, null, _totalBytes, _currBytes, _percentage));
				_isLoading = true;
			}
			dispatchEvent(new ParallelLoaderEvent(ParallelLoaderEvent.ITEM_START, currItem, _totalBytes, _currBytes, _percentage));
		}

		public function progressHandler() : void {
			var total:Number = 0;
			for (var i : int = 0; i < _loadingQueue.length; i++) {
				dispatchEvent(new ParallelLoaderEvent(ParallelLoaderEvent.ITEM_PROGRESS, _loadingQueue[i], _totalBytes, _currBytes, _percentage));
				total = total + _loadingQueue[i].bytesLoaded;
			}
			_currBytes = total;
			_percentage = _currBytes / _totalBytes;
			dispatchEvent(new ParallelLoaderEvent(ParallelLoaderEvent.PROGRESS, null, _totalBytes, _currBytes, _percentage));
		}

		
		public function completeHandler(currItem:ILoadable) : void {
			dispatchEvent(new ParallelLoaderEvent(ParallelLoaderEvent.ITEM_COMPLETE, currItem, _totalBytes, _currBytes, _percentage));
			if(_index == _loadingQueue.length - 1){
				dispatchEvent(new ParallelLoaderEvent(ParallelLoaderEvent.COMPLETE, null, _totalBytes, _currBytes, _percentage));
				_isLoading = false;
			}
			_index++;
		}
		
		
		/*****************************************************************************************************
		
		
		
		 ******************************************************************************************************/

		protected function init() : void {
			_loadingQueue = new Vector.<ILoadable>();
			_bytesLoaded = new Vector.<Number>();
			_ignoreErrors = false;
			_loaderContext = null;
			_index = 0;
			_isLoading = false;
			_percentage = 0;
			_currBytes = 0;
			_totalBytes = 0;
			_bandwidth = 0;
			_prevBytes = 0;
			_bwChecking = false;
			_packetRec = [];
		}

//		protected function loadNextItem() : void {
//			if(!_isLoading && _isComplete) return;
//			_currItem = _loadingQueue[_index];
//			if(_currItem.registerItem(this)) _currItem.load();
//		}

		protected function getMode() : Boolean {
			if (Capabilities.playerType == "External" || Capabilities.playerType == "StandAlone") {
				return false;
			} else {
				return true;
			}
		}

		protected function checkBandwidth(event : TimerEvent) : void {
			var bw : Number = (_currBytes - _prevBytes) / 1024;
			_packetRec.push(bw);
			if(_packetRec.length == 100) _packetRec.shift();
			var buffer : Number = 0;
			for (var i : int = 0;i < _packetRec.length; i++) buffer = buffer + _packetRec[i];  
			_bandwidth = round((((buffer) / _packetRec.length) * (_bwTimer.delay)) * (80 / 1000), 3);
			_prevBytes = _currBytes;
		}

		protected function round(num : Number, decimal : Number = 1) : Number {
			return Math.round(num * Math.pow(10, decimal)) / Math.pow(10, decimal);
		}
	}
}