         //export const HOST = 'http://localhost:6002' // 本地代理请求路径
        // export const HOST = 'http://localhost:8080' // 公司服务器
         //export const HOST = 'http://183.3.139.134:8383' //外部服务器
        //export const HOST = '/mylocal' //前端代理服务器


         let HOST = 'mylocal';
         if (process.env.NODE_ENV === 'production') {
           HOST = 'mylocal';
         }
         export {
           HOST
         }
