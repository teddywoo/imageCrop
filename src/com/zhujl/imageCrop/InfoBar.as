/**
 * @file 提示信息
 * @author zhujl
 */
package com.zhujl.imageCrop {

    import flash.display.Graphics;
    import flash.display.Sprite;

    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;

    import flash.filters.DropShadowFilter;

    import flash.events.Event;

    public class InfoBar extends Sprite {

        private var textField: TextField;

        public function InfoBar() {

            var infoBarConfig: Object = Config.infoBar;

            var tf: TextFormat = new TextFormat();
            tf.font = infoBarConfig.fontFamily;
            tf.size = infoBarConfig.fontSize;
            tf.color = infoBarConfig.color.text.fontColor;
            tf.align = TextFormatAlign.CENTER;

            textField = Util.createTextField(tf);
            textField.width = infoBarConfig.width;

            textField.y = (infoBarConfig.height - infoBarConfig.fontSize) / 2;

            this.addChild(textField);

            applyStyle();
        }

        private function setColor(color: uint): void {
            var textFormat: TextFormat = textField.defaultTextFormat;
            textFormat.color = color;

            textField.defaultTextFormat = textFormat;
        }

        private function setBackgroundColor(color: uint): void {
            var infoBarConfig: Object = Config.infoBar;

            var graphics: Graphics = this.graphics;
            graphics.clear();
            graphics.beginFill(color, 1);
            graphics.drawRect(0, 0, infoBarConfig.width, infoBarConfig.height);
            graphics.endFill();
        }

        private function applyStyle() {
            var innerShadow = new DropShadowFilter(2, 90, 0x000000, 0.2, 0, 6, 1, 1, true);
            var shadow = new DropShadowFilter(1, 90, 0xFFFFFF, 1, 0, 1, 1, 1, false)

            this.filters = [ innerShadow, shadow ];
        }

        /**
         * 显示普通的提示
         *
         * @param {String} text
         */
        public function showText(text: String): void {
            var color: Object = Config.infoBar.color.text;

            textField.text = text;
            setBackgroundColor(color.bgColor);
            setColor(color.fontColor);
        }

        /**
         * 显示成功提示
         *
         * @param {String} success
         */
        public function showSuccess(success: String): void {
            var color: Object = Config.infoBar.color.success;

            textField.text = success;
            setBackgroundColor(color.bgColor);
            setColor(color.fontColor);
        }

        /**
         * 显示错误提示
         *
         * @param {String} error
         */
        public function showError(error: String): void {
            var color: Object = Config.infoBar.color.error;

            textField.text = error;
            setBackgroundColor(color.bgColor);
            setColor(color.fontColor);
        }

        /**
         * 显示进度信息
         *
         * @param {String} loading
         */
        public function showLoading(loading: String): void {
            var color: Object = Config.infoBar.color.loading;

            textField.text = loading;
            setBackgroundColor(color.bgColor);
            setColor(color.fontColor);
        }

    }
}
