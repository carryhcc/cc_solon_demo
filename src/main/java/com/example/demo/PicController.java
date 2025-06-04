package com.example.demo;

import com.example.demo.server.CacheService;
import com.example.demo.utils.StrUtils;
import org.noear.solon.annotation.Controller;
import org.noear.solon.annotation.Inject;
import org.noear.solon.annotation.Mapping;
import org.noear.solon.core.handle.ModelAndView;
import org.noear.solon.data.sql.SqlUtils;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

@Controller
public class PicController {


    @Inject
    SqlUtils sqlUtils;

    @Inject("${config.sqlName}")
    public static String sqlName;

    @Inject
    CacheService cacheService;

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
        Integer randomGroupId = cacheService.getRandomGroupId();
        String sql = "SELECT pic_name, GROUP_CONCAT(pic_url) as pic_urls " + "FROM " + sqlName + " " + "WHERE is_delete = 0 AND group_id = ? " + "GROUP BY pic_name";

        return sqlUtils.sql(sql)
                .params(randomGroupId)
                .queryRow(resultSet -> {
                    // 直接访问当前行，不需要调用 next()
                    Map<String, String> map = new HashMap<>();
                    map.put(resultSet.getString("pic_name"), "[" + resultSet.getString("pic_urls") + "]");
                    return map;
                });
    }

    @Mapping("/showPicList") // 定义访问此页面的路径
    public ModelAndView showPicListPage() {
        return new ModelAndView("picList.ftl");
    }

}
