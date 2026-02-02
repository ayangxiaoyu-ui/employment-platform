package com.example.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import lombok.Data;

@Data
public class Company {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private String name;
    private String description;
    private String logo;
    private String address;
    private String industry;
    private String scale;
    private String contactPerson;
    private String contactPhone;
    private Integer status; // 0-待审核, 1-通过, 2-拒绝
}