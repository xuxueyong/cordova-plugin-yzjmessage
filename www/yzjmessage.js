
var exec = require('cordova/exec');

// 获取token
exports.getToken = function(success, error,codes) {
    exec(success, error, "CDVYZJMessage", "getToken",codes);
};
   
// 打开消息列表
exports.openMessageListView = function(success, error,codes) {
    exec(success, error, "CDVYZJMessage", "openMessageListView",codes);
};
    
// 打开通讯录聊天
exports.openPersonMessageView = function(success, error,codes) {
    exec(success, error, "CDVYZJMessage", "openPersonMessageView",codes);
};
    
// 分享
exports.shareMessageToSDK = function(success, error, userName) {
    exec(success, error, "CDVYZJMessage", "shareMessageToSDK" , userName);
};
               
// 消息未读数
exports.getUnreadCount = function(success, error, userName) {
    exec(success, error, "CDVYZJMessage", "getUnreadCount" , userName);
};
               
// 打开推送消息
exports.openMessageByGroupID = function(success, error, userName) {
    exec(success, error, "CDVYZJMessage", "openMessageByGroupID" , userName);
};
               
// 退出登录
exports.messageLogout = function(success, error, userName) {
    exec(success, error, "CDVYZJMessage", "messageLogout" , userName);
};

exports.allowPermission = function(success, error,codes) {
    exec(success, error, "CDVYZJMessage", "allowPermission",codes);
};

