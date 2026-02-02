package com.example.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.example.entity.Company;
import com.example.mapper.CompanyMapper;
import com.example.service.CompanyService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class CompanyServiceImpl implements CompanyService {

    @Autowired
    private CompanyMapper companyMapper;

    @Override
    public Company getByUserId(Long userId) {
        QueryWrapper<Company> wrapper = new QueryWrapper<>();
        wrapper.eq("user_id", userId);
        return companyMapper.selectOne(wrapper);
    }

    @Override
    public Company getById(Long id) {
        return companyMapper.selectById(id);
    }

    @Override
    public boolean saveOrUpdate(Company company) {
        if (company.getId() != null) {
            return companyMapper.updateById(company) > 0;
        } else {
            return companyMapper.insert(company) > 0;
        }
    }
}
