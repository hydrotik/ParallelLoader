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


package {
	import flash.system.Capabilities;
	import flash.display.Graphics;

	import com.hydrotik.parallelloader.ParallelLoaderEvent;
	import com.hydrotik.parallelloader.ParallelLoader;

	import flash.display.Sprite;

	/**
	 * @author Donovan Adams | Hydrotik | http://blog.hydrotik.com
	 * @version: 0.1.0
	 */
	 
	public class Example extends Sprite {
		
		private static const THUMB_WIDTH:int = 42;
		
		private static const THUMB_HEIGHT:int = 60;
		
		private var _pl : ParallelLoader;
		
		private var _items : Vector.<Object>;
		
		private var _containers : Vector.<Sprite>;
		
		private var _itemLoaders : Vector.<Sprite>;
		
		private var _overallProgressBar : Sprite;

		public function Example() {
			
			
			
			_items = new Vector.<Object>();
			
			_itemLoaders = new Vector.<Sprite>();
			
			_containers = new Vector.<Sprite>();
			
			_items.push({src:"../flashassets/images/thumbnail1.jpg", title:"Image 1"});
			_items.push({src:"../flashassets/images/thumbnail2.jpg", title:"Image 2"});
			_items.push({src:"../flashassets/images/thumbnail3.jpg", title:"Image 3"});
			_items.push({src:"../flashassets/images/thumbnail4.jpg", title:"Image 4"});
			_items.push({src:"../flashassets/images/thumbnail5.jpg", title:"Image 5"});
			_items.push({src:"../flashassets/images/thumbnail6.jpg", title:"Image 6"});
			_items.push({src:"../flashassets/images/thumbnail7.jpg", title:"Image 7"});
			// Error Test
			//_items.push({src:"../flashassets/images/thumbnail8.jpg", title:"image 8"});
			// SWF Test
			_items.push({src:(getMode() ? "swf/" : "" ) + "swf_asset.swf", title:"SWF Item 8"});
			
			_pl = new ParallelLoader(false, null, "test");
			
			var startX:int = 10;
			var startY:int = 10;
			
			for (var i : int = 0; i < _items.length; i++) {
				_containers[i] = new Sprite();
				addChild(_containers[i]);
				_containers[i].x = startX;
				_containers[i].y = startY;
				
				_itemLoaders[i] = new Sprite();
				addChild(_itemLoaders[i]);
				_itemLoaders[i].x = startX;
				_itemLoaders[i].y = startY + THUMB_HEIGHT + 4;
				drawBar(_itemLoaders[i], THUMB_WIDTH);
				_itemLoaders[i].scaleX = 0;
				
				startX = startX + THUMB_WIDTH + 5;
				
				_pl.addItem(_items[i].src, _containers[i], {title:_items[i].title});
			}
			
			_overallProgressBar = new Sprite();
			addChild(_overallProgressBar);
			drawBar(_overallProgressBar, startX - 15);
			_overallProgressBar.scaleX = 0;
			_overallProgressBar.x = 10;
			_overallProgressBar.y = 100;
			
			_pl.addEventListener(ParallelLoaderEvent.START, onOverallStartHandler);
			_pl.addEventListener(ParallelLoaderEvent.ITEM_START, onItemStartHandler);
			_pl.addEventListener(ParallelLoaderEvent.ITEM_ERROR, onItemErrorHandler);
			_pl.addEventListener(ParallelLoaderEvent.ITEM_PROGRESS, onItemProgress);
			_pl.addEventListener(ParallelLoaderEvent.ITEM_COMPLETE, onItemCompleteHandler);
			_pl.addEventListener(ParallelLoaderEvent.PROGRESS, onOverallProgress);
			_pl.addEventListener(ParallelLoaderEvent.COMPLETE, onOverallCompleteHandler);
			
			_pl.execute();
		}

		private function onItemProgress(event : ParallelLoaderEvent) : void {
			_itemLoaders[event.currItem.index].scaleX = event.currItem.percentage;
		}
		
		private function onOverallProgress(event : ParallelLoaderEvent) : void {
			_overallProgressBar.scaleX = event.percentage;
		}

		private function onOverallStartHandler(event : ParallelLoaderEvent) : void {
			trace("Loader Start");
		}
		
		private function onItemStartHandler(event : ParallelLoaderEvent) : void {
			trace("\t"+event.title+" Start");
		}

		private function onItemCompleteHandler(event : ParallelLoaderEvent) : void {
			trace("\t"+event.title+" Complete, " + event.width, event.height);
		}
		
		private function onItemErrorHandler(event : ParallelLoaderEvent) : void {
			trace(event.type);
		}

		private function onOverallCompleteHandler(event : ParallelLoaderEvent) : void {
			trace("Loader Complete");
		}

		private function drawBar(target:Sprite, width:int):void{
			target.graphics.beginFill(0x990000);
			target.graphics.drawRect(0, 0, width, 2);
		}
		
		protected function getMode() : Boolean {
			if (Capabilities.playerType == "External" || Capabilities.playerType == "StandAlone") {
				return false;
			} else {
				return true;
			}
		}
	}
}
