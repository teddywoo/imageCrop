/**
 * @file 封装图片常用功能
 * @author zhujl
 */
package com.zhujl.imageCrop {

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.IBitmapDrawable;
    import flash.display.Sprite;

    import flash.net.FileReference;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;
    import flash.net.URLVariables;

    import flash.utils.ByteArray;

    import flash.geom.Rectangle;
    import flash.geom.Matrix;
    import flash.geom.Point;

    import flash.events.Event;
    import flash.events.DataEvent;
    import flash.events.ProgressEvent;
    import flash.events.IOErrorEvent;
    import flash.events.HTTPStatusEvent;

    import com.adobe.images.JPGEncoder;

    public class Image extends Sprite {

        private var bitmap: Bitmap;

        public function Image(bitmap: Bitmap) {
            this.bitmap = bitmap;
            this.addChild(bitmap);
        }

        public override function get width(): Number {
            return bitmap.width;
        }
        public override function set width(width: Number): void {
            bitmap.width = width;
        }
        public override function get height(): Number {
            return bitmap.height;
        }
        public override function set height(height: Number): void {
            bitmap.height = height;
        }

        /**
         * 上传图片
         *
         * @param {String} url 上传地址
         */
        public function upload(url: String): void {
            var jpg: JPGEncoder = new JPGEncoder(100);
            var bytes: ByteArray = jpg.encode(this.bitmap.bitmapData);

            var req: URLRequest = new URLRequest(url);
            req.data = bytes;
            req.method = URLRequestMethod.POST;
            req.contentType = "application/octet-stream";

            var loader: URLLoader = new URLLoader();
            loader.load(req);

            loader.addEventListener(Event.OPEN, uploadStart);
            loader.addEventListener(ProgressEvent.PROGRESS, uploading);
            loader.addEventListener(IOErrorEvent.IO_ERROR, uploadError);
            loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, uploadStatus);
            loader.addEventListener(Event.COMPLETE, uploadComplete);
        }

        /**
         * 下载图片
         */
        public function download(): void {
            var jpg: JPGEncoder = new JPGEncoder(100);
            var bytes: ByteArray = jpg.encode(this.bitmap.bitmapData);

            var file:FileReference = new FileReference();
            file.save(bytes, 'Image[' + getTimestamp() + '].jpg');
        }

        /**
         * 旋转图片
         * 图片始终以 (0,0) 作为左上角, 展现在第四象限区域
         *
         * @param {Number} rotation
         */
        public function rotate(rotation: Number): void {

            var old: Bitmap = this.bitmap;

            var matrix: Matrix = old.transform.matrix;
            // 调整旋转中心
            matrix.translate(- old.width / 2, - old.height / 2);
            // 角度转弧度
            matrix.rotate(rotation * Math.PI / 180);
            old.transform.matrix = matrix;
            // 再偏移回第四象限
            matrix.translate(old.width / 2, old.height / 2);
            old.transform.matrix = matrix;


            // 旋转完之后，x 和 y 值不一定是 (0, 0)
            // 所以用 sprite 调整一下
            var sprite: Sprite = new Sprite();
            sprite.addChild(old);

            var copy: BitmapData = new BitmapData(sprite.width, sprite.height, true, 0x00FFFFFF);
            copy.draw(sprite);

            this.bitmap = new Bitmap(copy);
            this.addChild(this.bitmap);
        }

        /**
         * 水平翻转
         */
        public function flipX(): void {
            flip('x');
        }

        /**
         * 垂直翻转
         */
        public function flipY(): void {
            flip('y');
        }

        private function flip(direction: String): void {
            var oldImage: Bitmap = this.bitmap;
            oldImage['scale' + direction.toUpperCase()] *= -1;

            // 因为是以 (0, 0) 为中心翻转的
            var sprite: Sprite = new Sprite();
            sprite.addChild(oldImage);

            if (direction === 'x') {
                oldImage.x = oldImage.width;
            }
            else if (direction === 'y') {
                oldImage.y = oldImage.height;
            }


            var newImage: BitmapData = new BitmapData(oldImage.width, oldImage.height, true, 0x00FFFFFF);
            newImage.draw(sprite);

            this.bitmap = new Bitmap(newImage);
            this.addChild(this.bitmap);
        }

        /**
         * 缩放图片
         *
         * @param {Number} scaleX 取值区间 0-1
         * @param {Number} scaleY 取值区间 0-1
         */
        public function scale(scaleX, scaleY): void {
            var bitmapData: BitmapData = this.bitmap.bitmapData;
            var matrix: Matrix = new Matrix();
            matrix.scale(scaleX, scaleY);

            var copy: BitmapData = new BitmapData(bitmapData.width * scaleX, bitmapData.height * scaleY, true, 0x00FFFFFF);
            copy.draw(bitmapData, matrix);

            this.removeChild(this.bitmap);

            this.bitmap = new Bitmap(copy);
            this.addChild(this.bitmap);
        }

        /**
         * 截取一个矩形区域的像素
         *
         * @param {Rectangle} rect
         */
        public function pick(rect: Rectangle): BitmapData {
            var bitmapData: BitmapData = new BitmapData(rect.width, rect.height, true, 0x00FFFFFF);
            bitmapData.copyPixels(this.bitmap.bitmapData, rect, new Point(0, 0));
            return bitmapData;
        }

        /**
         * 画入一个显示对象
         *
         * @param {DisplayObject|BitmapData} drawable
         * @param {Boolean} scaleable 是否自动缩放
         */
        public function draw(drawable: *, scaleable: Boolean = true): void {

            var matrix: Matrix = null;

            if (scaleable) {
                var scaleX: Number = this.bitmap.width / drawable.width;
                var scaleY: Number = this.bitmap.height / drawable.height;

                if (scaleX != 1 || scaleY != 1) {
                    matrix = new Matrix();
                    matrix.scale(scaleX, scaleY);
                }
            }

            // 先把画布清空, 这样在绘制半透明图片时, 不会出现上次的遗留像素
            var bitmapData: BitmapData = this.bitmap.bitmapData;
            bitmapData.fillRect(bitmapData.rect, 0xFFFFFFFF);
            bitmapData.draw(drawable, matrix);
        }

        /**
         * 填充颜色
         *
         * @param {uint} color
         */
        public function fill(color: uint): void {
            var bitmapData: BitmapData = this.bitmap.bitmapData;
            bitmapData.fillRect(bitmapData.rect, color);
        }

        /**
         * 克隆一个新的 Image
         *
         * @return {Image}
         */
        public function clone(): Image {
            // 不减掉 1, 右边会出现白边...
            var bitmapData: BitmapData = new BitmapData(this.bitmap.width - 1, this.bitmap.height - 1, true, 0x00FFFFFF);
            bitmapData.copyPixels(bitmap.bitmapData, bitmap.bitmapData.rect, new Point(0, 0));
            return new Image(new Bitmap(bitmapData));
        }

        private function getTimestamp(): String {
            var date: Date = new Date();
            var month: int = date.month + 1;
            return date.fullYear + '-' + (month < 10 ? ('0' + month) : month) + '-' + date.date;
        }

        private function uploadStart(e: Event): void {
            this.dispatchEvent(e);
        }
        private function uploading(e: ProgressEvent): void {
            this.dispatchEvent(e);
        }
        private function uploadError(e: IOErrorEvent): void {
            this.dispatchEvent(e);
        }
        private function uploadStatus(e: HTTPStatusEvent): void {
            this.dispatchEvent(e);
        }
        private function uploadComplete(e: Event): void {

            var loader: URLLoader = e.target as URLLoader;

            var event: ImageEvent = new ImageEvent(ImageEvent.UPLOAD_COMPLETE);
            event.image = this.bitmap;
            event.data = loader.data;

            this.dispatchEvent(event);
        }

    }
}
