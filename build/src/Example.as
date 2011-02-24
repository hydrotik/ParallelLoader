package {
	import flash.display.Graphics;

	import com.hydrotik.parallelloader.ParallelLoaderEvent;
	import com.hydrotik.parallelloader.ParallelLoader;

	import flash.display.Sprite;

	/**
	 * @author Donovan Adams | Macys.com | donovan.adams@macys.com
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
			
			_items.push({src:"../flashassets/images/thumbnail1.jpg", title:"image 1"});
			_items.push({src:"../flashassets/images/thumbnail2.jpg", title:"image 2"});
			_items.push({src:"../flashassets/images/thumbnail3.jpg", title:"image 3"});
			_items.push({src:"../flashassets/images/thumbnail4.jpg", title:"image 4"});
			_items.push({src:"../flashassets/images/thumbnail5.jpg", title:"image 5"});
			_items.push({src:"../flashassets/images/thumbnail6.jpg", title:"image 6"});
			_items.push({src:"../flashassets/images/thumbnail7.jpg", title:"image 7"});
			
			_pl = new ParallelLoader();
			
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
			trace("\tItem Start");
		}

		private function onItemCompleteHandler(event : ParallelLoaderEvent) : void {
			trace("\t" + event.currItem.index+ ": Item Complete");
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
	}
}
