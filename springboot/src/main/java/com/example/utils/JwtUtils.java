package com.example.utils;

import cn.hutool.jwt.JWT;
import cn.hutool.jwt.JWTUtil;
import cn.hutool.jwt.signers.JWTSignerUtil;

import java.util.HashMap;
import java.util.Map;

public class JwtUtils {

    // 密钥，实际开发中应该放在配置文件中
    private static final byte[] KEY = "my-secret-key-123456".getBytes();

    public static String createToken(Long userId, String username, String role) {
        Map<String, Object> payload = new HashMap<>();
        payload.put("userId", userId);
        payload.put("username", username);
        payload.put("role", role);
        payload.put("expire_time", System.currentTimeMillis() + 1000 * 60 * 60 * 24); // 24小时过期

        return JWTUtil.createToken(payload, JWTSignerUtil.hs256(KEY));
    }

    public static boolean verify(String token) {
        try {
            return JWTUtil.verify(token, JWTSignerUtil.hs256(KEY));
        } catch (Exception e) {
            return false;
        }
    }

    public static JWT parse(String token) {
        return JWTUtil.parseToken(token);
    }
}