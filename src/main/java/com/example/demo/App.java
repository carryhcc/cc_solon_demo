package com.example.demo;

import org.noear.solon.Solon;
import org.noear.solon.annotation.SolonMain;
import org.noear.solon.scheduling.annotation.EnableScheduling;

@SolonMain
@EnableScheduling
public class App {
    public static void main(String[] args) {
        Solon.start(App.class, args);

        // 注册全局过滤器
        Solon.app().filter(new CorsInterceptor());
    }
}