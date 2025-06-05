package com.example.demo.server;

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
    public Integer maxId;

    @Getter
    public Integer minId;

    @Getter
    public Integer maxGroupId;

    @Getter
    public Integer minGroupId;

    @Inject
    SqlUtils sqlUtils;

    // 默认测试库
    public static String sqlName = "cc_pic_all_dev";

    public static final List<String> defaultList = Arrays.asList("cc_pic_all_dev", "cc_pic_all_test", "cc_pic_all_prod");

    @Init
    public void cachePicId() throws SQLException {
        // 缓存图片ID
        String maxSql = "SELECT id FROM " + sqlName + " WHERE is_delete = 0 ORDER BY id DESC LIMIT 1";
        maxId = sqlUtils.sql(maxSql).queryValue();
        String minSql = "SELECT id FROM " + sqlName + " WHERE is_delete = 0 ORDER BY id LIMIT 1";
        minId = sqlUtils.sql(minSql).queryValue();

        System.out.println("cache_minId:" + minId + "cache_maxId:" + maxId);
        // 缓存分组ID
        String maxGroupSql = "SELECT group_id FROM " + sqlName + " WHERE is_delete = 0 ORDER BY group_id DESC LIMIT 1";
        maxGroupId = sqlUtils.sql(maxGroupSql).queryValue();
        String minGroupSql = "SELECT group_id FROM " + sqlName + " WHERE is_delete = 0 ORDER BY group_id LIMIT 1";
        minGroupId = sqlUtils.sql(minGroupSql).queryValue();

        System.out.println("cache_minGroupId:" + minGroupId + "cache_maxGroupId:" + maxGroupId);
    }

    public Integer getRandomId() {
        return ThreadLocalRandom.current().nextInt(minId, maxId);
    }

    public Integer getRandomGroupId() {
        return ThreadLocalRandom.current().nextInt(minGroupId, maxGroupId);
    }

    public String getSqlName() {
        return sqlName;
    }

    public void switchSqlName(String env) throws SQLException {
        // 切换库
        String newSqlName = "cc_pic_all_" + env;
        // 判断是否正常
        if (!defaultList.contains(sqlName)) {
            log.error("切换异常:{}", sqlName);
        }
        sqlName = newSqlName;
        log.warn("切换成功:{}", sqlName);
        // 刷新缓存
        this.cachePicId();
    }
    // 10分钟恢复默认库
}
