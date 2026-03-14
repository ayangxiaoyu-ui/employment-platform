package com.example.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import lombok.Data;
import java.util.Date;

@Data
public class Job {

    private Long id;
    private Long companyId;
    private String title;
    private Long categoryId;
    private String description;
    private String requirements;
    private Integer salaryMin;
    private Integer salaryMax;
    private String location;
    private Integer status;
    private Date createTime;
    private Date updateTime;
    // ⭐ 新增字段：公司 Logo（来自联表）
    @TableField(exist = false)
    private String companyLogo;

    // ⭐ 新增字段：公司名称（来自联表）
    @TableField(exist = false)
    private String companyName;
}
