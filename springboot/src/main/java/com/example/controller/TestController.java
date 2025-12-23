package com.example.controller;

import com.example.entity.Test;
import com.example.mapper.TestMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@CrossOrigin
public class TestController {

    @Autowired
    private TestMapper testMapper;  // 直接注入 Mapper，新手这样最直观

    // 插入接口：最简单的一行代码版本
    @RequestMapping("/insert")
    public String insert(@RequestParam Integer id,
                         @RequestParam String name,
                         @RequestParam Integer age) {
        // 一行完成插入：成功返回 success，失败返回 fail
        return testMapper.insert(new Test(id, name, age)) > 0 ? "success" : "fail";
    }
    @RequestMapping("/select")
    public List<Test> select() {
        return testMapper.selectList(null);
    }
    @RequestMapping("/select1")
    public Test select1() {
        return testMapper.select1();
    }
}