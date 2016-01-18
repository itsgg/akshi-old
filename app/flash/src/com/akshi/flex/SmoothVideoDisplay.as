package com.akshi.flex {
	import mx.controls.VideoDisplay;
	import mx.core.mx_internal;
	
	public class SmoothVideoDisplay extends VideoDisplay {
		private var _smoothing:Boolean = false;
		
		public function SmoothVideoDisplay() {
			super();
		}
		
		[Bindable]
		public function set smoothing(value:Boolean):void {
			if(value == _smoothing) {
				return;
			}
			_smoothing = value;
			this.smoothing = _smoothing;
		}
		
		public function get smoothing():Boolean {
			return _smoothing;
		}
	}
}