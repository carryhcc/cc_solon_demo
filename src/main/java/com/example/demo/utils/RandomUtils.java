package com.example.demo.utils;

import java.util.concurrent.ThreadLocalRandom;

public class RandomUtils {
    public static Integer randomNumber() {
        //获取随机数861736 1702875
        return ThreadLocalRandom.current().nextInt(861736, 1702875);
    }

    public static Integer randomNumberList() {
        //获取随机数 1 14973
        return ThreadLocalRandom.current().nextInt(1, 14973);
    }
}
