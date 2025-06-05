package com.example.demo.utils;

import com.example.demo.server.CacheService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.SQLException;
import java.util.Timer;
import java.util.TimerTask;


public class ResettableTimer {

    private static final Logger log = LoggerFactory.getLogger(ResettableTimer.class);

    private final CacheService cacheService;
    private final long delayMillis;
    private Timer timer;
    private final String targetEnv;

    public ResettableTimer(CacheService cacheService, long delayMinutes, String targetEnv) {
        this.cacheService = cacheService;
        // x 分钟后切换
        this.delayMillis = delayMinutes * 60 * 100;
        // x 秒后切换
//        this.delayMillis = delayMinutes * 1000;
        this.targetEnv = targetEnv;
        this.timer = new Timer();
        scheduleTask();
    }

    private void scheduleTask() {
        timer.schedule(new TimerTask() {
            @Override
            public void run() {
                try {
                    // 如果是dev环境，直接返回不执行切换
                    if (cacheService.getDefaultEnv().equalsIgnoreCase(targetEnv)) {
                        log.info("当前为开发环境{}，跳过环境切换任务",targetEnv);
                        return;
                    }

                    cacheService.switchSqlName(targetEnv);
                    log.info("定时器触发：已切换到{}环境", targetEnv);
                } catch (SQLException e) {
                    // 使用 error 级别记录异常，包含完整堆栈
                    log.error("定时器切换环境失败，目标环境: {}", targetEnv, e);
                }
            }
        }, delayMillis);
    }

    public void reset() {
        try {
            timer.cancel();
            timer = new Timer();
            scheduleTask();

            // 使用工具方法生成时间描述并记录日志
            log.info("定时器已重置，{}后切换到{}环境", formatDelayTime(delayMillis), targetEnv);
        } catch (Exception e) {
            log.error("重置定时器失败", e);
            timer = new Timer();
        }
    }

    /**
     * 将毫秒级延迟时间格式化为人类可读的时间描述
     * @param delayMillis 延迟毫秒数
     * @return 格式化后的时间描述，如"3分钟20秒"、"1分钟"或"45秒"
     */
    private String formatDelayTime(long delayMillis) {
        long minutes = delayMillis / 60000;
        long seconds = (delayMillis % 60000) / 1000;

        if (minutes > 0 && seconds > 0) {
            return String.format("%d分钟%d秒", minutes, seconds);
        } else if (minutes > 0) {
            return String.format("%d分钟", minutes);
        } else {
            return String.format("%d秒", seconds);
        }
    }
}