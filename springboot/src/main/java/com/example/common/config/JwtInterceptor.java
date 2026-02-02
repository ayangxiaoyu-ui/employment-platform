package com.example.common.config;

import com.example.utils.JwtUtils;
import org.springframework.web.servlet.HandlerInterceptor;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import cn.hutool.jwt.JWT;

public class JwtInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
            throws Exception {
        String token = extractToken(request);
        
        if (token != null && JwtUtils.verify(token)) {
            JWT jwt = JwtUtils.parse(token);
            Long userId = ((Number) jwt.getPayload("userId")).longValue();
            String username = (String) jwt.getPayload("username");
            String role = (String) jwt.getPayload("role");
            
            request.setAttribute("userId", userId);
            request.setAttribute("username", username);
            request.setAttribute("role", role);
        }
        
        return true;
    }

    private String extractToken(HttpServletRequest request) {
        String header = request.getHeader("Authorization");
        if (header != null && header.startsWith("Bearer ")) {
            return header.substring(7);
        }
        return null;
    }
}
