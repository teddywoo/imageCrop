/**
 * @file 图片事件
 * @author zhujl
 */
package com.zhujl.imageCrop {

    import flash.display.Bitmap;
    import flash.events.Event;

    public class ImageEvent extends Event  {

        /**
         * 图片格式错误
         */
        public static const ACCEPT_INVALID: String = 'acceptInvalid';

        /**
         * 图片尺寸错误
         */
        public static const SIZE_INVALID: String = 'sizeInvalid';

        /**
         * 图片加载完成
         */
        public static const LOAD_COMPLETE: String = 'loadComplete';

        /**
         * 图片上传完成
         */
        public static const UPLOAD_COMPLETE: String = 'uploadComplete';

        /**
         * 图片对象
         */
        public var image: Bitmap;

        /**
         * 额外的数据
         */
        public var data: *;

        public function ImageEvent(type: String, bubbles: Boolean = false, cancelable: Boolean = false) {
            super(type, bubbles, cancelable);
        }

        public override function clone(): Event {
            return new ImageEvent(type, bubbles, cancelable);
        }
    }
}
