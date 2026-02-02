package com.example.controller;

import com.example.common.exception.CustomException;
import com.example.entity.SysUser;
import com.example.service.SysUserService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class AuthControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private SysUserService sysUserService;

    @Test
    void login_shouldReturnToken() throws Exception {
        // 补上第三个参数（role）
        when(sysUserService.login(eq("u1"), eq("p1"), anyString()))
                .thenReturn("token-123");

        SysUser req = new SysUser();
        req.setUsername("u1");
        req.setPassword("p1");
        // 可选：req.setRole("STUDENT");  // 如果想更真实

        mockMvc.perform(post("/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("200"))
                .andExpect(jsonPath("$.data").value("token-123"));
    }

    @Test
    void register_shouldReturnUser() throws Exception {
        SysUser saved = new SysUser();
        saved.setId(1L);
        saved.setUsername("u2");
        saved.setRole("STUDENT");

        when(sysUserService.register(any(SysUser.class))).thenReturn(saved);

        SysUser req = new SysUser();
        req.setUsername("u2");
        req.setPassword("p2");
        req.setRole("STUDENT");

        mockMvc.perform(post("/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("200"))
                .andExpect(jsonPath("$.data.id").value(1))
                .andExpect(jsonPath("$.data.username").value("u2"))
                .andExpect(jsonPath("$.data.role").value("STUDENT"));
    }

    @Test
    void login_whenServiceThrows_shouldReturnResultError() throws Exception {
        // 补上第三个参数（role）
        when(sysUserService.login(eq("u3"), eq("bad"), anyString()))
                .thenThrow(new CustomException("密码错误"));

        SysUser req = new SysUser();
        req.setUsername("u3");
        req.setPassword("bad");
        // 可选：req.setRole("STUDENT");

        mockMvc.perform(post("/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("500"))
                .andExpect(jsonPath("$.msg").value("密码错误"));
    }
}