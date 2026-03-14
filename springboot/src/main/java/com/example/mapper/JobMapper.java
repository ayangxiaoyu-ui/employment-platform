package com.example.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.entity.Job;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

@Mapper
public interface JobMapper extends BaseMapper<Job> {

    /** 查询所有岗位（含公司信息） */
    @Select("""
        SELECT 
            j.*, 
            c.name AS company_name,
            c.logo AS company_logo
        FROM job j
        LEFT JOIN company c ON j.company_id = c.id
        WHERE j.status = 1
        ORDER BY j.create_time DESC
    """)
    List<Job> selectAllWithCompany();


    /** 查询岗位详情（含公司信息） */
    @Select("""
        SELECT 
            j.*, 
            c.name AS company_name,
            c.logo AS company_logo
        FROM job j
        LEFT JOIN company c ON j.company_id = c.id
        WHERE j.id = #{id}
    """)
    Job selectDetail(Long id);


    /** 热门岗位（按浏览量排序） */
    @Select("""
        SELECT job_id, SUM(count) AS total
        FROM browsing_history
        GROUP BY job_id
        ORDER BY total DESC
        LIMIT 10
    """)
    List<Map<String, Object>> selectHotJobIds();
}
