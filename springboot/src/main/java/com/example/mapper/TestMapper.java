package com.example.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.entity.Test;
import org.apache.ibatis.annotations.Select;

public interface TestMapper extends BaseMapper<Test> {
    @Select("select * from test where name like 'a%';")
    Test select1();
}