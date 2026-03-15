package com.example.service;

import com.example.entity.Category;   // ⭐ 必须加
import java.util.List;

public interface CategoryService {
    List<Category> getJobCategories();
}
