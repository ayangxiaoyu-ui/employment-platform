package com.example.entity;

import com.baomidou.mybatisplus.annotation.TableId;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Test {
    @TableId
    private Integer id;     // 新手阶段用 Integer 就行
    private String name;
    private Integer age;
}