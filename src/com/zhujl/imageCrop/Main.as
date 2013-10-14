/**
 * @file 图片裁剪工具主程序
 * @author zhujl
 */
package com.zhujl.imageCrop {

    import fl.controls.Button;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Graphics;
    import flash.display.MovieClip;
    import flash.display.Sprite;

    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFieldAutoSize;

    import flash.geom.Rectangle;
    import flash.geom.Matrix;
    import flash.geom.Point;

    import flash.system.Security;

    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.ProgressEvent;
    import flash.events.IOErrorEvent;
    import flash.events.HTTPStatusEvent;

    public class Main extends MovieClip {

        /**
         * 文件选择窗口
         */
        private var imageBrowser: ImageBrowser;

        /**
         * 最底层的画布背景，一般是产品 logo
         */
        private var canvas: Sprite;

        /**
         * 画布中心点坐标
         */
        private var canvasCenter: Point;

        /**
         * 选择的原始图片, 如 图片大小是原始的尺寸
         */
        private var rawImage: Image;

        /**
         * 经过缩放的图片
         */
        private var scaledImage: Image;

        /**
         * 裁剪器, 包括遮罩和修剪框
         */
        private var crop: Crop;

        /**
         * 右侧预览图
         */
        private var preview: Preview;

        /**
         * 提示信息条
         */
        private var infoBar: InfoBar;

        public function Main() {
            initStage();
            initExternal();
            initUI();
            status4Init();
        }

        /**
         * 初始化舞台, 包括跨域设置, 缩放对齐
         */
        public function initStage(): void {
            Security.allowDomain("*");
            Security.allowInsecureDomain("*");

            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
        }

        /**
         * 初始化配置对象, 设置通信接口
         */
        public function initExternal(): void {

            // 页面传入的参数
            var params: Object = stage.loaderInfo.parameters;

            // 根据参数初始化配置对象
            Config.init(params);

            if (params.movieName) {
                ExternalCall.init(params.movieName);
                // 通知页面加载完成
                ExternalCall.loaded();
            }
        }

        /**
         * 初始化界面
         */
        public function initUI(): void {

            addCanvas();
            addButton();
            addPreview();

            crop = new Crop();
            imageBrowser = new ImageBrowser();

            addInfoBar();

            selectButton.addEventListener(MouseEvent.CLICK, clickSelectButton);
            uploadButton.addEventListener(MouseEvent.CLICK, uploadImage);
            saveButton.addEventListener(MouseEvent.CLICK, saveImage);
            rotateLeftButton.addEventListener(MouseEvent.CLICK, rotateLeft);
            rotateRightButton.addEventListener(MouseEvent.CLICK, rotateRight);

            crop.addEventListener(Event.CHANGE, onchange);

            imageBrowser.addEventListener(ImageEvent.ACCEPT_INVALID, acceptInvalid);
            imageBrowser.addEventListener(ImageEvent.SIZE_INVALID, sizeInvalid);
            imageBrowser.addEventListener(ImageEvent.LOAD_COMPLETE, selectImage);
        }

        /**
         * 添加画布
         */
        private function addCanvas(): void {

            canvas = new Sprite();

            var canvasConfig: Object = Config.canvas;
            var gutterConfig: Object = Config.gutter;

            var width: Number = canvasConfig.width;
            var height: Number = canvasConfig.height;
            var outerWidth: Number = width + canvasConfig.borderWidth * 2;
            var outerHeight: Number = height + canvasConfig.borderWidth * 2;

            Util.drawRect(
                        canvas,
                        new Rectangle(0, 0, outerWidth, outerHeight),
                        canvasConfig.bgColor,
                        canvasConfig.borderWidth,
                        canvasConfig.borderColor
                    );

            canvas.x = canvasConfig.x;
            canvas.y = canvasConfig.y;
            this.addChild(canvas);

            // 获取画布中心的坐标, 便于进行旋转
            canvasCenter = new Point(canvas.x + outerWidth / 2, canvas.y + outerHeight / 2);

            // 在画布右下角加个 logo
            logo.x = canvas.width - logo.width - gutterConfig.logo2Canvas;
            logo.y = canvas.height - logo.height - gutterConfig.logo2Canvas;
            canvas.addChild(logo);
        }

        /**
         * 添加按钮
         */
        private function addButton(): void {

            var buttonConfig: Object = Config.button;
            var gutterConfig: Object = Config.gutter;

            // 初始化文本按钮
            initTextButton(selectButton, buttonConfig.selectButtonText);
            initTextButton(uploadButton, buttonConfig.uploadButtonText);
            initTextButton(saveButton, buttonConfig.saveButtonText);

            // 初始化图标按钮
            var rotateLeftIcon: Image = new Image(new Bitmap(new RotateLeftIcon()));
            var rotateRightIcon: Image = rotateLeftIcon.clone();
            rotateRightIcon.flipX();

            initIconButton(rotateLeftButton, rotateLeftIcon);
            initIconButton(rotateRightButton, rotateRightIcon);

            // 设置按钮位置

            selectButton.y =
            uploadButton.y =
            saveButton.y =
            rotateLeftButton.y =
            rotateRightButton.y = buttonConfig.y;

            // 文本按钮居左
            selectButton.x = 0;
            uploadButton.x = selectButton.x + selectButton.width + gutterConfig.button;
            saveButton.x = uploadButton.x + uploadButton.width + gutterConfig.button;

            // 图标按钮居右
            rotateRightButton.x = canvas.x + canvas.width - rotateRightButton.width;
            rotateLeftButton.x = rotateRightButton.x - gutterConfig.button - rotateLeftButton.width;
        }

        /**
         * 因为已经在 .fla 文件里加上了 5 个 button, 所以就不叫 addButton 了
         */
        private function initTextButton(button: Button, text: String): void {
            var buttonConfig: Object = Config.button;
            var tf: TextFormat = new TextFormat(buttonConfig.fontFamily,
                                                buttonConfig.fontSize,
                                                buttonConfig.fontColor);

            button.label = text;
            button.setStyle('textFormat', tf);
            button.useHandCursor = true;
        }
        private function initIconButton(button: Button, icon: Image): void {
            button.label = '';
            //button.width = 35;
            button.setStyle('icon', icon);
            button.useHandCursor = true;
        }

        /**
         * 初始化图片预览
         */
        private function addPreview(): void {
            var previewConfig: Object = Config.preview;
            var gutterConfig: Object = Config.gutter;

            preview = new Preview();
            preview.x = canvas.x + canvas.width + gutterConfig.canvas2Preview;
            preview.y = canvasCenter.y - preview.image.height / 2;

            if (previewConfig.enabled) {
                this.addChild(preview);
            }
        }

        private function addInfoBar(): void {
            var infoBarConfig: Object = Config.infoBar;
            var canvasConfig: Object = Config.canvas;

            infoBar = new InfoBar();

            infoBar.x = canvas.x + canvasConfig.borderWidth;
            infoBar.y = canvasCenter.y - infoBarConfig.height / 2;
        }

        /**
         * 初始化状态
         */
        private function status4Init() {
            if (this.contains(crop)) {
                this.removeChild(crop);
            }
            showText(Config.text.textMessage);

            preview.reset();

            uploadButton.enabled =
            saveButton.enabled =
            rotateLeftButton.enabled =
            rotateRightButton.enabled = false;
        }

        /**
         * 显示提示信息状态
         */
        private function status4Text() {
            if (this.contains(crop)) {
                this.removeChild(crop);
            }
            this.addChild(infoBar);
            preview.reset();

            uploadButton.enabled =
            saveButton.enabled =
            rotateLeftButton.enabled =
            rotateRightButton.enabled = false;
        }

        /**
         * 显示图片状态
         */
        private function status4Crop() {
            if (this.contains(infoBar)) {
                this.removeChild(infoBar);
            }
            this.addChild(crop);

            uploadButton.enabled =
            saveButton.enabled = true;

            if (isRotatable()) {
                rotateLeftButton.enabled =
                rotateRightButton.enabled = true;
            }
        }

        public function updateScaledImage(): void {

            var canvasConfig: Object = Config.canvas;

            var scale: Number = Util.getScale(rawImage, {
                width: canvasConfig.width,
                height: canvasConfig.height
            });

            scaledImage = rawImage.clone();
            scaledImage.scale(scale, scale);

            canvasConfig.scale = scale;
        }

        public function updateCrop(): void {
            crop.x = canvasCenter.x - scaledImage.width / 2;
            crop.y = canvasCenter.y - scaledImage.height / 2;

            crop.setImage(scaledImage);
        }

        private function showText(text: String): void {
            status4Text();
            infoBar.showText(text);
        }
        private function showSuccess(success: String): void {
            status4Text();
            infoBar.showSuccess(success);
        }
        private function showError(error: String): void {
            status4Text();
            infoBar.showError(error);
        }

        /**
         * 图片是否可以旋转
         *
         * @return {Boolean}
         */
        private function isRotatable() {
            var imageConfig: Object = Config.image;
            return rawImage.width >= imageConfig.height && rawImage.height >= imageConfig.width;
        }


        // ====================== event handler ========================================

        private function clickSelectButton(e: MouseEvent): void {
            imageBrowser.selectFile();
        }

        private function acceptInvalid(e: ImageEvent): void {
            this.showError(Config.getAcceptErrorMessage());
        }

        private function sizeInvalid(e: ImageEvent): void {
            this.showError(Config.getSizeErrorMessage());
        }

        private function selectImage(e: ImageEvent): void {

            var image: Bitmap = e.image;
            rawImage = new Image(image);

            status4Crop();

            updateScaledImage();
            updateCrop();
        }

        private function onchange(e: Event): void {

            var rect: Rectangle = crop.getCropRectangle();
            var scale: Number = 1 / Config.canvas.scale;

            var rawRect: Rectangle = new Rectangle(
                rect.x * scale,
                rect.y * scale,
                rect.width * scale,
                rect.height * scale
            );

            preview.image.draw(rawImage.pick(rawRect));
        }

        private function rotateLeft(e: MouseEvent): void {
            rawImage.rotate(-90);
            updateScaledImage();
            updateCrop();
        }

        private function rotateRight(e: MouseEvent): void {
            rawImage.rotate(90);
            updateScaledImage();
            updateCrop();
        }

        private function uploadImage(e: MouseEvent): void {
            var image: Image = getFinalImage();

            image.addEventListener(Event.OPEN, uploadStartHandler);
            image.addEventListener(ProgressEvent.PROGRESS, uploadingHandler);
            image.addEventListener(IOErrorEvent.IO_ERROR, uploadErrorHandler);
            image.addEventListener(HTTPStatusEvent.HTTP_STATUS, uploadStatusHandler);
            image.addEventListener(ImageEvent.UPLOAD_COMPLETE, uploadCompleteHandler);

            image.upload(Config.image.url);
        }

        private function saveImage(e: MouseEvent): void {
            var image: Image = getFinalImage();
            image.download();
        }

        private function getFinalImage(): Image {
            if (Config.preview.enabled) {
                return preview.image;
            }
            else {
                return new Image(new Bitmap(crop.getCropImage()));
            }
        }

        private function uploadStartHandler(e: Event): void {
            showText(Config.text.uploadProgressMessage);
            ExternalCall.uploadStart();
        }
        private function uploadingHandler(e: ProgressEvent): void {
            showText(Config.text.uploadProgressMessage);
            ExternalCall.uploadProgress(e.bytesLoaded, e.bytesTotal);
        }
        private function uploadErrorHandler(e: IOErrorEvent): void {
            showError(Config.text.uploadFailMessage);
            ExternalCall.uploadError(e.text);
        }
        private function uploadStatusHandler(e: HTTPStatusEvent): void {
            ExternalCall.uploadStatus(e.status);
        }
        private function uploadCompleteHandler(e: ImageEvent): void {

            var target: Image = e.target as Image;
            target.removeEventListener(Event.OPEN, uploadStartHandler);
            target.removeEventListener(ProgressEvent.PROGRESS, uploadingHandler);
            target.removeEventListener(IOErrorEvent.IO_ERROR, uploadErrorHandler);
            target.removeEventListener(ImageEvent.UPLOAD_COMPLETE, uploadCompleteHandler);

            showSuccess(Config.text.uploadSuccessMessage);

            ExternalCall.uploadComplte(e.data);
        }


    }

}
