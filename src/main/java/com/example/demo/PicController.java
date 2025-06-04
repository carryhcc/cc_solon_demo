package com.example.demo;

import com.example.demo.utils.RandomUtils;
import org.noear.solon.annotation.Controller;
import org.noear.solon.annotation.Inject;
import org.noear.solon.annotation.Mapping;
import org.noear.solon.core.handle.ModelAndView;
import org.noear.solon.data.sql.SqlUtils;

import java.sql.SQLException;
import java.util.List;

@Controller
public class PicController {


    @Inject
    SqlUtils sqlUtils;

    /**
     * 跳转网页
     *
     * @return
     * @throws SQLException
     */
    @Mapping("/picTo")
    public ModelAndView picTo() throws SQLException {
        String url = sqlUtils.sql("SELECT pic_url FROM cc_pic_all_dev WHERE is_delete = 0 and id = " + RandomUtils.randomNumber()).queryValue();
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
        String val = sqlUtils.sql("SELECT pic_url FROM cc_pic_all_dev WHERE is_delete = 0 and id = " + RandomUtils.randomNumber()).queryValue();
        return String.format(val);
    }

    /**
     * 获取随机套图
     *
     * @return
     * @throws SQLException
     */
    @Mapping("/pic/list")
    public String picList() throws SQLException {
        List<String> valList = sqlUtils.sql("SELECT pic_url FROM cc_pic_all_dev WHERE is_delete = 0 and group_id = " + RandomUtils.randomNumberList()).queryRowList(String.class);
        return String.format(String.valueOf(valList));
    }


}
