/**
 * @file 外部接口文件, 方便查看对外暴露的接口
 * @author zhujl
 */
package  com.zhujl.imageCrop {

    import flash.external.ExternalInterface;

    public class ExternalCall {

        private static var externalHandler: Object = { };

        public static function init(movieName: String): void {
            var externalHandler: Object = ExternalCall.externalHandler;
            var prefix: String = 'ImageCrop.instances["' + movieName + '"].';

            externalHandler.loaded = prefix + 'loaded_handler';
            externalHandler.upload_start = prefix + 'upload_start_handler';
            externalHandler.upload_progress = prefix + 'upload_progress_handler';
            externalHandler.upload_success = prefix + 'upload_success_handler';
            externalHandler.upload_error = prefix + 'upload_error_handler';
            externalHandler.upload_status = prefix + 'upload_status_handler';
            externalHandler.upload_complete = prefix + 'upload_complete_handler';
        }

        /**
         * swf 加载完成后调用
         */
        public static function loaded(): void {
            var callback: String = ExternalCall.externalHandler.loaded;
            if (callback) {
                ExternalInterface.call(callback);
            }
        }

        /**
         * 图片开始上传时调用
         */
        public static function uploadStart(): void {
            var callback: String = ExternalCall.externalHandler.upload_start;
            if (callback) {
                ExternalInterface.call(callback);
            }
        }

        /**
         * 图片上传过程中调用
         *
         * @param {uint} bytesLoaded
         * @param {uint} bytesTotal
         */
        public static function uploadProgress(bytesLoaded: uint, bytesTotal: uint): void {
            var callback: String = ExternalCall.externalHandler.upload_progress;
            if (callback) {
                ExternalInterface.call(callback, bytesLoaded, bytesTotal);
            }
        }

        /**
         * 图片成功上传后调用
         *
         * @param {string} data
         */
        public static function uploadSuccess(data: String): void {
            var callback: String = ExternalCall.externalHandler.upload_success;
            if (callback) {
                ExternalInterface.call(callback, data);
            }
        }

        /**
         * 图片上传失败后调用
         *
         * @param {String} error 错误信息
         */
        public static function uploadError(error: String): void {
            var callback: String = ExternalCall.externalHandler.upload_error;
            if (callback) {
                ExternalInterface.call(callback, error);
            }
        }

        /**
         * 图片上传过程中调用
         *
         * @param {int} statusCode 状态码
         */
        public static function uploadStatus(statusCode: int): void {
            var callback: String = ExternalCall.externalHandler.upload_status;
            if (callback) {
                ExternalInterface.call(callback, statusCode);
            }
        }

        /**
         * 图片上传完成后调用, 不论成功或失败
         *
         * @param {String} data 返回的数据
         */
        public static function uploadComplte(data: String): void {
            var callback: String = ExternalCall.externalHandler.upload_complete;
            if (callback) {
                ExternalInterface.call(callback, data);
            }
        }
    }
}
