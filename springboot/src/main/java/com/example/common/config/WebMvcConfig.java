package com.example.common.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new JwtInterceptor())
                .addPathPatterns("/api/**")
                .excludePathPatterns("/auth/**");
    }
    @Value("${file.upload.base-path}")
    private String basePath;

    @Value("${file.upload.avatar-sub-path}")
    private String avatarSubPath;

    @Value("${file.upload.logo-sub-path}")
    private String logoSubPath;

    @Value("${file.upload.avatar-url-prefix}")
    private String avatarUrlPrefix;

    @Value("${file.upload.logo-url-prefix}")
    private String logoUrlPrefix;

    @Value("${file.upload.resume-url-prefix}")
    private String resumeUrlPrefix;

    @Value("${file.upload.resume-sub-path}")
    private String resumeSubPath;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // 头像静态资源映射
        registry.addResourceHandler(avatarUrlPrefix + "**")
                .addResourceLocations("file:" + basePath + avatarSubPath);

        // Logo 静态资源映射
        registry.addResourceHandler(logoUrlPrefix + "**")
                .addResourceLocations("file:" + basePath + logoSubPath);

        System.out.println("静态资源映射已注册：");
        System.out.println("头像: " + avatarUrlPrefix + "** → " + basePath + avatarSubPath);
        System.out.println("Logo:  " + logoUrlPrefix + "** → " + basePath + logoSubPath);
        System.out.println("简历: " + resumeUrlPrefix + "** → " + basePath + resumeSubPath);
    }
}
