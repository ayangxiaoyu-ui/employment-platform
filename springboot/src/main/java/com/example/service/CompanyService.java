package com.example.service;

import com.example.entity.Company;

public interface CompanyService {
    /**
     * 根据用户ID获取企业信息
     */
    Company getByUserId(Long userId);

    /**
     * 根据ID获取企业信息
     */
    Company getById(Long id);

    /**
     * 保存或更新企业信息
     */
    boolean saveOrUpdate(Company company);
}
