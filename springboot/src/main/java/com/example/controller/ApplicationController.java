package com.example.controller;

import com.example.common.Result;
import com.example.entity.Application;
import com.example.service.ApplicationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/application")
public class ApplicationController {

    @Autowired
    private ApplicationService applicationService;

    @PostMapping("/apply")
    public Result<Void> apply(@RequestBody Application application) {

        // 默认状态：0-待查看
        application.setStatus(0);

        try {
            applicationService.save(application);
            return Result.success();
        } catch (DuplicateKeyException e) {
            return Result.error("你已经投递过该职位了");
        }
    }
}
