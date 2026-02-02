package com.example.utils;

import cn.hutool.jwt.JWT;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

class JwtUtilsTest {

    @Test
    void createToken_shouldVerifyAndParse() {
        String token = JwtUtils.createToken(1L, "u1", "STUDENT");
        assertTrue(JwtUtils.verify(token));
        JWT jwt = JwtUtils.parse(token);
        assertNotNull(jwt);
    }
}

