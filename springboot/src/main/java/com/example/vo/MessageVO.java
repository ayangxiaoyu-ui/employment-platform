package com.example.vo;

import com.example.entity.Message;   // ⭐ 正确的 Message
import lombok.Data;

@Data
public class MessageVO extends Message {
    private UserInfo target;  // ⭐ 正确的 UserInfo（你自己写的）
}
