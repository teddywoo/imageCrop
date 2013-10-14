/**
 * @file 图片裁剪器. 盖住图片的遮罩 + 裁剪窗口
 * @author zhujl
 */
package com.zhujl.imageCrop {

    import flash.display.Sprite;
    import flash.display.Graphics;
    import flash.display.Bitmap;
    import flash.display.BitmapData;

    import flash.geom.Rectangle;

    import flash.events.Event;
    import flash.events.MouseEvent;

    /**
     * 裁剪器分 5 层, 从底层到顶层依次如下:
     *
     * 图片
     * 半透明遮罩
     * 图片的副本
     * 图片遮罩(取景窗口)
     * resizer
     *
     * 拖动顶层的图片遮罩即可改变取景
     */
    public class Crop extends Sprite {

        /**
         * 需要裁剪的图片
         */
        public var image: Image;
        public var imageCopy: Image;

        /**
         * 半透明遮罩
         */
        public var alphaMask: Sprite;

        /**
         * 图片遮罩
         */
        public var imageMask: Sprite;

        /**
         * 拖动改变 imageMask 大小的 handler
         */
        private var resizer: Sprite;

        /**
         * 这两个属性用来辅助计算
         */
        private var offsetX: Number;
        private var offsetY: Number;

        private var resizeBounds: Rectangle = new Rectangle();

        public function Crop() {
            addAlphaMask();
            addImageMask();
            addResizer();
        }

        /**
         * 添加半透明遮罩
         */
        private function addAlphaMask(): void {
            alphaMask = new Sprite();
            this.addChild(alphaMask);
        }

        /**
         * 添加图片遮罩
         */
        private function addImageMask(): void {
            imageMask = new Sprite();
            this.addChild(imageMask);

            // 遮罩无法响应事件, 所以改下机制
            // 用坐标判断是否点在遮罩内
            this.addEventListener(MouseEvent.MOUSE_DOWN, startDragImageMask);
        }

        /**
         * 添加裁剪窗口右下角的可拖动对象
         */
        private function addResizer(): void {
            resizer = new Sprite();

            var resizerConfig: Object = Config.cropResizer;

            var width: Number = resizerConfig.width;
            var height: Number = resizerConfig.height;
            var borderWidth: int = resizerConfig.borderWidth;

            var graphics: Graphics = resizer.graphics;
            graphics.beginFill(resizerConfig.bgColor, resizerConfig.alpha);
            graphics.lineStyle(borderWidth, resizerConfig.borderColor);
            graphics.drawRect(
                -1 * width / 2 + borderWidth,
                -1 * height / 2 + borderWidth,
                width - 2 * borderWidth,
                height - 2 * borderWidth
            );
            graphics.endFill();

            this.addChild(resizer);
            resizer.addEventListener(MouseEvent.MOUSE_DOWN, startDragResizer);
        }

        /**
         * 设置裁剪的图片
         *
         * @param {Image} image
         */
        public function setImage(image: Image): void {

            if (this.image && this.contains(this.image)) {
                this.removeChild(this.image);
            }
            if (this.imageCopy && this.contains(this.imageCopy)) {
                this.removeChild(this.imageCopy);
            }

            image.x = 0;
            image.y = 0;

            this.image = image;
            this.imageCopy = image.clone();

            this.imageCopy.mask = imageMask;

            this.addChildAt(image, 0);
            this.addChildAt(imageCopy, 2);

            // 更新半透明遮罩
            resizeAlphaMask(image.width, image.height);

            // 更新图片遮罩
            var width: Number = Config.image.width;
            var height: Number = Config.image.height;


            var scale: Number = getImageMaskScale();
            resizeImageMask(width * scale, height * scale);

            // 居中
            centerImageMask();
        }

        /**
         * 图片显示在 canvas 里需要缩放一次
         * imageMask 显示在 image 里需要再缩放一次
         *
         * @return {Number}
         */
        private function getImageMaskScale(): Number {

            var scale: Number = 1;

            var config: Object = Config.cropImageMask;

            if (config.width > image.width || config.height > image.height) {
                scale = Util.getScale(config, image);
            }

            return scale;
        }

        /**
         * 调整半透明遮罩的大小
         *
         * @param {Number} width
         * @param {Number} height
         */
        private function resizeAlphaMask(width: Number, height: Number): void {

            var maskConfig: Object = Config.cropAlphaMask;

            var graphics: Graphics = alphaMask.graphics;
            graphics.clear();
            graphics.beginFill(maskConfig.bgColor, maskConfig.alpha);
            graphics.drawRect(0, 0, width, height);
            graphics.endFill();
        }

        /**
         * 调整图片遮罩的大小
         *
         * @param {Number} width
         * @param {Number} height
         */
        private function resizeImageMask(width: Number, height: Number): void {

            var graphics: Graphics = imageMask.graphics;
            graphics.clear();
            // 这里的颜色不重要, 只要有颜色就行...
            graphics.beginFill(0xFF0000, 1);
            graphics.drawRect(0, 0, width, height);
            graphics.endFill();

            this.dispatchEvent(new Event(Event.CHANGE));
        }

        /**
         * 居中定位图片遮罩
         */
        private function centerImageMask(): void {

            var x: Number = (image.width - imageMask.width) / 2;
            var y: Number = (image.height - imageMask.height) / 2;

            moveImageMask(x, y);
        }

        /**
         * 移动图片遮罩
         *
         * @param {Number} x
         * @param {Number} y
         */
        private function moveImageMask(x: Number, y: Number): void {
            imageMask.x = x;
            imageMask.y = y;

            resizer.x = x + imageMask.width;
            resizer.y = y + imageMask.height;

            this.dispatchEvent(new Event(Event.CHANGE));
        }

        /**
         * 获得裁剪后的图片
         *
         * @return {BitmapData}
         */
        public function getCropImage(): BitmapData {
            var rect: Rectangle = getCropRectangle();
            return image.pick(rect);
        }

        /**
         * 获得裁剪区域
         *
         * @return {Rectangle}
         */
        public function getCropRectangle(): Rectangle {
            return new Rectangle(
                imageMask.x,
                imageMask.y,
                imageMask.width,
                imageMask.height
            );
        }

        // ====================== event handler ====================================

        private function startDragImageMask(e: MouseEvent): void {

            var imageMaskBound: Object = {
                top: imageMask.y,
                right: imageMask.x + imageMask.width,
                bottom: imageMask.y + imageMask.height,
                left: image.x
            };

            if (e.localX >= imageMaskBound.left
                && e.localY >= imageMaskBound.top
                && e.localX <= imageMaskBound.right
                && e.localY <= imageMaskBound.bottom) {

                // 不能点在 resizer 上
                if (e.localX < resizer.x || e.localY < resizer.y) {
                    offsetX = imageMask.mouseX;
                    offsetY = imageMask.mouseY;

                    stage.addEventListener(MouseEvent.MOUSE_MOVE, draggingImageMask);
                    stage.addEventListener(MouseEvent.MOUSE_UP, stopDragImageMask);
                }
            }

        }

        private function draggingImageMask(e: MouseEvent): void {

            var x: Number = Util.bound(
                                this.mouseX - offsetX,
                                0,
                                image.width - imageMask.width
                            );

            var y: Number = Util.bound(
                                this.mouseY - offsetY,
                                0,
                                image.height - imageMask.height
                            );

            moveImageMask(x, y);
        }

        private function stopDragImageMask(e: MouseEvent): void {
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, draggingImageMask);
            stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragImageMask);
        }

        private function startDragResizer(e: MouseEvent): void {
            offsetX = resizer.mouseX;
            offsetY = resizer.mouseY;

            stage.addEventListener(MouseEvent.MOUSE_MOVE, draggingResizer);
            stage.addEventListener(MouseEvent.MOUSE_UP, stopDragResizer);
        }

        private function draggingResizer(e: MouseEvent): void {

            var size: Object = {
                width: this.mouseX - imageMask.x,
                height: this.mouseY - imageMask.y
            };

            var minSize: Object = {
                width: Config.cropImageMask.minWidth,
                height: Config.cropImageMask.minHeight
            };

            if (size.width <= minSize.width || size.height <= minSize.height) {
                return;
            }

            size = Util.getSize(
                Config.image.ratio,
                size,
                minSize,
                {
                    width: image.width - imageMask.x,
                    height: image.height - imageMask.y
                }
            );

            resizeImageMask(size.width, size.height);
            moveImageMask(imageMask.x, imageMask.y);
        }

        private function stopDragResizer(e: MouseEvent): void {
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, draggingResizer);
            stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragResizer);
        }

    }
}
