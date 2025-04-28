package com.example.demo;

import org.noear.solon.annotation.Controller;
import org.noear.solon.annotation.Inject;
import org.noear.solon.annotation.Mapping;
import org.noear.solon.annotation.Param;
import org.noear.solon.core.handle.ModelAndView;
import org.noear.solon.data.sql.SqlUtils;

import java.sql.SQLException;
import java.util.List;
import java.util.concurrent.ThreadLocalRandom;

@Controller
public class DemoController {

    @Inject
    SqlUtils sqlUtils;


    @Mapping("/hello")
    public String hello(@Param(defaultValue = "world") String name) {
        return String.format("Hello %s!", name);
    }

    @Mapping("/index")
    public ModelAndView index(@Param(defaultValue = "world") String name) {
        return new ModelAndView("hello.ftl").put("name", name);
    }


}