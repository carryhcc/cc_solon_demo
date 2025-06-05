package com.example.demo.utils;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;

public class StrUtils {
    public static String extractPicUrls(String jsonStr) {
        try {
            JSONArray jsonArray = JSONArray.parseArray(jsonStr);
            StringBuilder result = new StringBuilder("[");

            for (int i = 0; i < jsonArray.size(); i++) {
                JSONObject obj = jsonArray.getJSONObject(i);
                String url = obj.getString("pic_url");
                if (url != null) {
                    result.append(url);
                    if (i < jsonArray.size() - 1) {
                        result.append(",");
                    }
                }
            }

            result.append("]");
            return result.toString();
        } catch (Exception e) {
            System.err.println("处理JSON时出错: " + e.getMessage());
            return "[]";
        }
    }

    public static boolean isEmpty(String s) {
        return s == null || s.isEmpty();
    }
}
