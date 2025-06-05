package com.example.demo.utils;

import com.example.demo.server.CacheService;
import org.noear.solon.annotation.Inject;
import org.noear.solon.scheduling.annotation.Scheduled;

import java.sql.SQLException;

public class JobUtils {

    @Inject
    CacheService cacheService;

    // 基于 Runnable 接口的模式
    @Scheduled(fixedRate = 10 * 60 * 1000)
    public class defaultEnv implements Runnable {
        @Override
        public void run() {
            try {
                cacheService.switchSqlName("dev");
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
            System.out.println("定时任务：已切换到dev环境");
        }
    }
}
