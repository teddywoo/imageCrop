/**
 * @file 配置文件
 * @author zhujl
 */
package com.zhujl.imageCrop {

    public class Config {

        /**
         * 图片的配置
         */
        public static var image: Object = {
            // 可接受的图片格式
            accepts: [ 'jpg', 'jpeg', 'png', 'gif' ],
            // 可接受的图片尺寸
            size: {
                minWidth: 0,
                minHeight: 0,
                maxWidth: 10000,
                maxHeight: 10000
            },
            // 最理想的宽度
            width: 380,
            // 最理想的高度
            height: 250,
            // 图片宽高比
            ratio: 1,
            // 上传地址
            url: ''
        };

        /**
         * 画布的配置
         */
        public static var canvas: Object = {
            x: 0,
            y: 35,
            width: 400,
            height: 300,
            // 图片缩放比例
            // scale 会动态算，这里只是随便赋个值
            scale: 1,
            bgColor: 0xFFF2F2F2,
            borderWidth: 1,
            borderColor: 0xDDDDDD
        };

        /**
         * 按钮的配置
         */
        public static var button: Object = {
            y: 0,
            fontFamily: '宋体',
            fontSize: 13,
            fontColor: 0x555555,
            selectButtonText: '选择图片',
            uploadButtonText: '保存',
            saveButtonText: '下载'
        };

        public static var cropAlphaMask: Object = {
            alpha: 0.3,
            bgColor: 0x000000
        };

        /**
         * 裁剪窗口的配置
         */
        public static var cropImageMask: Object = {
        	width: 0,
        	height: 0,
            minWidth: 10,
            minHeight: 10
        };

        /**
         * 拖拽改变裁剪窗口大小的配置
         */
        public static var cropResizer: Object = {
            width: 8,
            height: 8,
            alpha: 0.3,
            bgColor: 0x000000,
            borderWidth: 1,
            borderColor: 0xFFFFFF
        };

        public static var preview: Object = {
            // 是否开启图片预览
            enabled: true,
            width: 0,
            height: 0,
            fontFamily: '宋体',
            fontSize: 13,
            fontColor: 0x666666,
            bgColor: 0xFFF2F2F2,
            borderWidth: 1,
            borderColor: 0xDDDDDD
        };

        public static var infoBar: Object = {
            width: 0,
            height: 60,
            fontFamily: '宋体',
            fontSize: 13,
            color: {
                text: {
                    bgColor: 0xD5E7E9,
                    fontColor: 0x666666
                },
                success: {
                    bgColor: 0xCCE7CB,
                    fontColor: 0x7BAA31
                },
                error: {
                    bgColor: 0xE9D5D5,
                    fontColor: 0xC75353
                },
                loading: {
                    bgColor: 0xCADDE3,
                    fontColor: 0x408EA6
                }
            }
        };

        /**
         * 文本配置
         */
        public static var text: Object = {
            // 默认显示的信息
            textMessage: '请选择需要上传的图片',
            // 上传成功的信息
            uploadSuccessMessage: '上传成功',
            // 图片尺寸错误的信息
            sizeErrorMessage: '',

            uploadStartMessage: '开始上传',
            uploadProgressMessage: '正在上传...',
            uploadFailMessage: '上传失败',
            uploadSuccessMessage: '上传成功'
        };


        /**
         * 间距配置
         */
        public static var gutter: Object = {
            button: 10,
            button2Canvas: 10,
            canvas2Preview: 20,
            preview2resolution: 5,
            logo2Canvas: 10
        };

        /**
         * 初始化配置
         *
         * @param {Object} options 外部传入的配置
         * @param {String} options.movieName 当前影片对象的名称, 相当于 ID
         * @param {String} options.uploadURL 上传地址
         * @param {String} options.accepts 可接受的图片格式, 以 , 分隔
         * @param {Number} options.canvasWidth 画布宽度
         * @param {Number} options.canvasHeight 画布高度
         * @param {Number} options.desiredWidth 期待裁剪出的宽度
         * @param {Number} options.desiredHeight 期待裁剪出的高度
         * @param {String} options.supportPreview 是否支持预览
         * @param {String} options.selectButtonText 选择按钮的文本
         * @param {String} options.uploadButtonText 上传按钮的文本
         * @param {String} options.saveButtonText 保存按钮的文本
         */
        public static function init(options: Object): void {

            // 有 movieName 表示参数完备
            if (options.movieName) {

                // 配置 image
                Config.setValue('image.url', options.uploadURL);
                Config.setValue('image.width', options.desiredWidth);
                Config.setValue('image.height', options.desiredHeight);

                if (options.accepts) {

                    var accepts: Array = options.accepts.split(',');
                    accepts.forEach(function (value: String, index: int, array: Array) {
                        array[index] = value;
                    });

                    if (accepts.length > 0) {
                        Config.setValue('image.accepts', accepts);
                    }
                }

                // 配置 canvas
                Config.setValue('canvas.width', options.canvasWidth);
                Config.setValue('canvas.height', options.canvasHeight);

                // 配置 preview
                Config.setValue('preview.enabled', options.supportPreview === 'true' ? true : false);
                Config.setValue('preview.width', options.desiredWidth);
                Config.setValue('preview.height', options.desiredHeight);

                // 配置 button
                Config.setValue('button.selectButtonText', options.selectButtonText);
                Config.setValue('button.uploadButtonText', options.uploadButtonText);
                Config.setValue('button.saveButtonText', options.saveButtonText);
            }

            Config.setValue('image.ratio', Config.image.width / Config.image.height);
            Config.setValue('image.size.minWidth', Config.image.width);
            Config.setValue('image.size.minHeight', Config.image.height);
            Config.setValue('preview.width', Config.image.width);
            Config.setValue('preview.height', Config.image.height);
            Config.setValue('cropImageMask.width', Config.image.width);
            Config.setValue('cropImageMask.height', Config.image.height);
            Config.setValue('infoBar.width', Config.canvas.width);
        }

        /**
         * 获得图片尺寸错误信息
         *
         * @return {String}
         */
        public static function getSizeErrorMessage(): String {
            var imageSize: Object = Config.image.size;
            return '图片尺寸不能小于 ' + imageSize.minWidth + ' x ' + imageSize.minHeight + ', 请重新选择';
        }

        /**
         * 获得图片格式错误信息
         *
         * @return {String}
         */
        public static function getAcceptErrorMessage(): String {
            return '图片格式错误';
        }

        /**
         * 为配置对象赋值
         *
         * @param {String} name 属性名, 可包含 . , 如 image.size.minWidth
         * @param {*} value 属性值
         */
        private static function setValue(name: String, value: *): void {
            if (value) {
                var chains: Array = name.split('.');
                var scope: * = Config;

                // chains 最后一项是赋值的属性名
                var prop: String = chains.pop();

                chains.forEach(function (name: String, index: int, array: Array) {
                    scope = scope[name];
                });

                scope[prop] = value;
            }
        }
    }
}
