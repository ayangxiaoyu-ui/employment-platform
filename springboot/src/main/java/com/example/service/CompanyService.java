package com.example.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.entity.Company;

public interface CompanyService extends IService<Company> {

    /**
     * 根据用户ID获取企业信息
     */
    Company getByUserId(Long userId);

}