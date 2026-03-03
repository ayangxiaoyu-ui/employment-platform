package com.example.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.entity.Company;
import com.example.mapper.CompanyMapper;
import com.example.service.CompanyService;
import org.springframework.stereotype.Service;

@Service
public class CompanyServiceImpl
        extends ServiceImpl<CompanyMapper, Company>
        implements CompanyService {

    @Override
    public Company getByUserId(Long userId) {
        return lambdaQuery()
                .eq(Company::getUserId, userId)
                .one();
    }
}
