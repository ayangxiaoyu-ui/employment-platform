package com.example.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.entity.Company;

public interface CompanyService extends IService<Company> {

    /**
     * 根据用户ID获取企业信息
     */
    Company getByUserId(Long userId);

    // getById 和 saveOrUpdate 可以省略，因为 IService 已经提供了
    // 但如果你想保留自定义签名，可以保留
}