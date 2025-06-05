package com.example.demo;

import org.noear.solon.core.handle.Context;
import org.noear.solon.core.handle.Filter;
import org.noear.solon.core.handle.FilterChain;

// 实现 Filter 接口而非 Handler
public class CorsInterceptor implements Filter {
    @Override
    public void doFilter(Context ctx, FilterChain chain) throws Throwable {

        // 设置 CORS 头
        ctx.headerSet("Access-Control-Allow-Origin", "*");
        ctx.headerSet("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
        ctx.headerSet("Access-Control-Allow-Headers", "Content-Type, Authorization");
        ctx.headerSet("Access-Control-Max-Age", "3600");

        // 处理预检请求
        if ("OPTIONS".equals(ctx.method())) {
            ctx.status(204);
            return;
        }

        // 继续执行后续过滤器和处理链
        chain.doFilter(ctx);
    }
}