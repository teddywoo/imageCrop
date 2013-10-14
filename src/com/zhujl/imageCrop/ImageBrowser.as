/**
 * @file 图片选择窗
 * @author zhujl
 */
package com.zhujl.imageCrop {

    import flash.display.Loader;
    import flash.display.LoaderInfo;

    import flash.display.Bitmap;

    import flash.net.FileReference;
    import flash.net.FileFilter;

    import flash.events.Event;
    import flash.events.EventDispatcher;


    public class ImageBrowser extends EventDispatcher  {

        public var file: FileReference;

        /**
         * 打开图片选择窗
         */
        public function selectFile(): void {
            file = new FileReference();
            file.addEventListener(Event.SELECT, selectHandler);

            var temp: Array = Config.image.accepts;
            var accepts: Array = new Array(temp.length);
            temp.forEach(function (value: String, index: int, array: Array) {
                accepts[index] = '*.' + value;
            });

            var fileFilter:FileFilter = new FileFilter('Images: (' + accepts.join(', ') + ')', accepts.join('; '));
            file.browse([fileFilter]);
        }

        /**
         * 验证图片格式
         *
         * @return {Boolean}
         */
        private function validateAccept(): Boolean {
            var type: String = file.type.toLowerCase().substr(1);
            return Config.image.accepts.indexOf(type) !== -1;
        }

        /**
         * 验证图片尺寸
         *
         * @param {Bitmap} image
         * @return {Boolean}
         */
        private function validateSize(image: Bitmap): Boolean {
            var imageSize: Object = Config.image.size;
            return image && image.width >= imageSize.minWidth && image.height >= imageSize.minHeight;
        }

        // ================================== event handler ======================================
        private function selectHandler(e: Event): void {
            file.removeEventListener(Event.SELECT, selectHandler);

            if (validateAccept()) {
                file.addEventListener(Event.COMPLETE, loadCompleteHandler);
                file.load();
            }
            else {
                var event: ImageEvent = new ImageEvent(ImageEvent.ACCEPT_INVALID);
                this.dispatchEvent(event);
            }

        }

        private function loadCompleteHandler(e: Event): void {
            file.removeEventListener(Event.COMPLETE, loadCompleteHandler);

            var loader: Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadBytesHandler);
            loader.loadBytes(file.data);
        }

        private function loadBytesHandler(e: Event): void {

            var loaderInfo: LoaderInfo = (e.target as LoaderInfo);
            loaderInfo.removeEventListener(Event.COMPLETE, loadBytesHandler);

            var bitmap: Bitmap = loaderInfo.content as Bitmap;
            var event: ImageEvent;

            if (validateSize(bitmap)) {
                event = new ImageEvent(ImageEvent.LOAD_COMPLETE);
            }
            else {
                event = new ImageEvent(ImageEvent.SIZE_INVALID);
            }

            event.image = bitmap;
            this.dispatchEvent(event);
        }
    }
}
