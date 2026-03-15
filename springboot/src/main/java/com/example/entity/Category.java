package com.example.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.List;

@Data
@TableName("category")
public class Category {

    private Long id;

    private String name;

    // 1 = 职位分类, 2 = 行业分类
    private Integer type;

    // 父级分类 ID
    private Long parentId;

    // 前端 Cascader 需要的字段（不在数据库中）
    @TableField(exist = false)
    private String label;

    @TableField(exist = false)
    private Long value;

    @TableField(exist = false)
    private List<Category> children;
}
