package com.example.demo.utils;

import java.util.Arrays;
import java.util.List;
import java.util.Random;
import java.util.concurrent.ThreadLocalRandom;

public class RandomUtils {
    public static Integer randomNumber() {
        //获取随机数861736 1702875
//        return ThreadLocalRandom.current().nextInt(861736, 1702875);
        // 随机861736 862735
        return ThreadLocalRandom.current().nextInt(861736, 862735);
    }

    public static Integer randomNumberList() {
        //获取随机数 1 14973
        return ThreadLocalRandom.current().nextInt(1, 14973);
    }

    public static int getRandomValue() {
        List<Integer> values = Arrays.asList(2290, 2514, 2671, 2683, 3145, 3263, 3346, 3350, 3606, 3673, 3712, 4590, 4594, 4758, 5523, 5919, 6084, 6414, 7375, 7517, 7524);
        Random random = new Random();
        return values.get(random.nextInt(values.size()));
    }
}
