package com.example.entity;

import cn.hutool.crypto.digest.BCrypt;

public class GenPwd {
    public static void main(String[] args) {
        String raw = "admin123"; // 你想要的密码
        String hash = BCrypt.hashpw(raw);
        System.out.println(hash);
    }
}