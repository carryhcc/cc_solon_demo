package com.example.demo;

import com.example.demo.server.CacheService;
import org.noear.solon.annotation.*;
import org.noear.solon.core.handle.ModelAndView;
import org.noear.solon.data.sql.SqlUtils;

import java.sql.SQLException;
import java.util.*;

import static com.example.demo.server.CacheService.sqlName;

@Controller
public class PicController {


    @Inject
    CacheService cacheService;

    @Inject
    SqlUtils sqlUtils;

    /**
     * 跳转网页
     *
     * @return
     * @throws SQLException
     */
    @Mapping("/showPic")
    public ModelAndView picTo() throws SQLException {

        String url = sqlUtils.sql("SELECT pic_url FROM  " + sqlName + "  WHERE is_delete = 0 and id = " + cacheService.getRandomId()).queryValue();
        return new ModelAndView("pic.ftl").put("url", url);
    }

    /**
     * 获取随机图片
     *
     * @return
     * @throws SQLException
     */
    @Mapping("/pic")
    public String pic() throws SQLException {
        String val = sqlUtils.sql("SELECT pic_url FROM  " + sqlName + "  WHERE is_delete = 0 and id = " + cacheService.getRandomId()).queryValue();
        return String.format(val);
    }

    /**
     * 获取随机套图
     *
     * @return
     * @throws SQLException
     */
    @Mapping("/pic/list")
    public Map<String, String> picList() throws SQLException {
        cacheService.resetTimer();
        Integer randomGroupId = cacheService.getRandomGroupId();
        // 先设置会话变量
        sqlUtils.sql("SET SESSION group_concat_max_len = 1024000;").update();
        // 再执行查询语句
        String sql = "SELECT pic_name, GROUP_CONCAT(pic_url) as pic_urls " + "FROM " + sqlName + " " + "WHERE is_delete = 0 AND group_id = ? " + "GROUP BY pic_name";

        return sqlUtils.sql(sql)
                .params(randomGroupId)
                .queryRow(resultSet -> {
                    Map<String, String> map = new HashMap<>();
                    map.put(resultSet.getString("pic_name"), "[" + resultSet.getString("pic_urls") + "]");
                    return map;
                });
    }

    @Mapping("/showPicList")
    public ModelAndView showPicListPage() {
        return new ModelAndView("picList.ftl");
    }

}
