package com.example.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.entity.Favorite;
import com.example.entity.Job;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 职位收藏表 Mapper 接口
 */
@Mapper
public interface FavoriteMapper extends BaseMapper<Favorite> {
    // 这里暂时不需要写任何 SQL 方法，BaseMapper 已经提供了：
    // insert, deleteById, selectOne, selectCount 等所有你需要的功能
    @Select("SELECT j.* FROM favorite f " +
            "LEFT JOIN job j ON f.job_id = j.id " +
            "WHERE f.student_id = #{studentId} " +
            "ORDER BY f.create_time DESC")
    List<Job> getFavoriteJobs(Long studentId);
}