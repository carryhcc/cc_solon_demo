package com.example.demo.server;

import com.example.demo.utils.ResettableTimer;
import lombok.Getter;
import org.noear.solon.annotation.Component;
import org.noear.solon.annotation.Init;
import org.noear.solon.annotation.Inject;
import org.noear.solon.data.sql.SqlUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.SQLException;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.ThreadLocalRandom;

@Component
public class CacheService {

    private static final Logger log = LoggerFactory.getLogger(CacheService.class);

    @Getter
    private Integer maxId;

    @Getter
    private Integer minId;

    @Getter
    private Integer maxGroupId;

    @Getter
    private Integer minGroupId;

    @Inject
    private SqlUtils sqlUtils;

    private ResettableTimer resettableTimer;

    public static String sqlName = "cc_pic_all_dev";


    @Getter
    @Inject("${config.env}")
    public static String defaultEnv;

    public static final List<String> defaultList = Arrays.asList(
            "cc_pic_all_dev", "cc_pic_all_test", "cc_pic_all_prod"
    );

    public CacheService() {
        initTimer();
    }

    private void initTimer() {
        this.resettableTimer = new ResettableTimer(this, 5, "dev");
    }

    @Init
    public void cachePicId() throws SQLException {
        // 缓存图片ID
        String maxSql = "SELECT id FROM " + sqlName + " WHERE is_delete = 0 ORDER BY id DESC LIMIT 1";
        maxId = sqlUtils.sql(maxSql).queryValue();

        String minSql = "SELECT id FROM " + sqlName + " WHERE is_delete = 0 ORDER BY id LIMIT 1";
        minId = sqlUtils.sql(minSql).queryValue();

        log.info("cache_minId:{} cache_maxId:{}", minId, maxId);

        // 缓存分组ID
        String maxGroupSql = "SELECT group_id FROM " + sqlName + " WHERE is_delete = 0 ORDER BY group_id DESC LIMIT 1";
        maxGroupId = sqlUtils.sql(maxGroupSql).queryValue();

        String minGroupSql = "SELECT group_id FROM " + sqlName + " WHERE is_delete = 0 ORDER BY group_id LIMIT 1";
        minGroupId = sqlUtils.sql(minGroupSql).queryValue();

        log.info("cache_minGroupId:{} cache_maxGroupId:{}", minGroupId, maxGroupId);
    }

    public Integer getRandomId() {
        return ThreadLocalRandom.current().nextInt(minId, maxId);
    }

    public Integer getRandomGroupId() {
        return ThreadLocalRandom.current().nextInt(minGroupId, maxGroupId);
    }

    public void switchSqlName(String env) throws SQLException {
        // 切换库
        String newSqlName = "cc_pic_all_" + env;

        // 验证环境名
        if (!defaultList.contains(newSqlName)) {
            log.error("无效的环境名:{}", env);
            return;
        }

        sqlName = newSqlName;

        defaultEnv = env;

        log.info("切换成功:{}", sqlName);

        // 刷新缓存
        this.cachePicId();

        // 刷新定时器
        this.resetTimer();
    }

    public void resetTimer() {
        resettableTimer.reset();
    }
}