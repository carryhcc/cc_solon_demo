package com.example.demo.server;

import lombok.Getter;
import org.noear.solon.annotation.Component;
import org.noear.solon.annotation.Init;
import org.noear.solon.annotation.Inject;
import org.noear.solon.data.sql.SqlUtils;

import java.sql.SQLException;
import java.util.concurrent.ThreadLocalRandom;

@Component
public class CacheService {

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

    @Inject("${config.sqlName}")
    public static String sqlName;

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

        System.out.println("cache_minGroupId" + minGroupId + "cache_maxGroupId" + maxGroupId);
    }

    public Integer getRandomId() {
        return ThreadLocalRandom.current().nextInt(minId, maxId);
    }

    public Integer getRandomGroupId() {
        return ThreadLocalRandom.current().nextInt(minGroupId, maxGroupId);
    }


}
