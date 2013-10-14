/**
 * @file 预览图
 * @author zhujl
 */
package com.zhujl.imageCrop {

    import flash.display.Sprite;
    import flash.display.Bitmap;
    import flash.display.BitmapData;

    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;

    import flash.geom.Rectangle;

    public class Preview extends Sprite {

        /**
         * 预览图
         *
         * @type Image
         */
        public var image: Image;

        /**
         * 图片分辨率
         *
         * @type TextField
         */
        public var resolution: TextField;

        /**
         * 创建预览图
         */
        public function Preview() {
            addImage();
            addResolution();
        }

        public function reset() {
            var previewConfig: Object = Config.preview;
            image.fill(previewConfig.bgColor);
        }

        /**
         * 添加预览图
         */
        private function addImage(): void {
            var previewConfig: Object = Config.preview;

            var width: Number = previewConfig.width;
            var height: Number = previewConfig.height;

            var outer: Number = (previewConfig.borderWidth + 1) * 2;

            var outerWidth: Number = width + outer;
            var outerHeight: Number = height + outer;

            Util.drawRect(
                this,
                new Rectangle(0, 0, outerWidth, outerHeight),
                previewConfig.bgColor,
                previewConfig.borderWidth,
                previewConfig.borderColor
            );

            image = new Image(new Bitmap(new BitmapData(
                                            width,
                                            height,
                                            true,
                                            previewConfig.bgColor
                                        )
                                    )
                                );

            image.x = outer / 2;
            image.y = outer / 2;

            this.addChild(image);
        }

        /**
         * 添加图片分辨率的说明文字
         */
        private function addResolution(): void {
            var previewConfig: Object = Config.preview;

            var tf: TextFormat = new TextFormat();
            tf.font = previewConfig.fontFamily;
            tf.size = previewConfig.fontSize;
            tf.color = previewConfig.fontColor;
            tf.align = TextFormatAlign.CENTER;

            resolution = Util.createTextField(tf, image.width + ' x ' + image.height);
            resolution.width = this.width;

            resolution.x = 0;
            resolution.y = image.x + image.height + Config.gutter.preview2resolution;

            this.addChild(resolution);
        }
    }
}