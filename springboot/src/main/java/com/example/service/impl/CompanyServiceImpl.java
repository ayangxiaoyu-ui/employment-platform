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
        // 推荐 lambdaQuery（字段安全，IDE 提示好）
        return lambdaQuery()
                .eq(Company::getUserId, userId)
                .one();

        // 如果你想保留原来的写法也可以
        // return baseMapper.selectOne(new QueryWrapper<Company>().eq("user_id", userId));
    }

    // getById 可以直接调用父类方法（省略重写）
    // @Override
    // public Company getById(Long id) {
    //     return super.getById(id);
    // }

    // saveOrUpdate 也可以直接调用父类（省略重写）
    // @Override
    // public boolean saveOrUpdate(Company company) {
    //     return super.saveOrUpdate(company);
    // }
}