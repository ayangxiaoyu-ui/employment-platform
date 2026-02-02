/*
 Navicat Premium Data Transfer

 Source Server         : Localhost
 Source Server Type    : MySQL
 Source Server Version : 8.0.0
 Source Schema         : employment_platform

 Target Server Type    : MySQL
 Target Server Version : 8.0.0
 File Encoding         : 65001

 Date: 23/12/2025
 Description: 大学生就业服务平台数据库脚本 (含浏览记录与推荐支持)
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- 1. 用户表 (所有角色的登录信息)
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `username` varchar(50) NOT NULL COMMENT '用户名',
  `password` varchar(100) NOT NULL COMMENT '密码',
  `role` varchar(20) NOT NULL COMMENT '角色: ADMIN, COMPANY, STUDENT',
  `status` int(1) DEFAULT 1 COMMENT '状态: 1-正常, 0-禁用',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统用户表';

-- ----------------------------
-- 2. 学生信息表
-- ----------------------------
DROP TABLE IF EXISTS `student`;
CREATE TABLE `student` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL COMMENT '关联用户ID',
  `name` varchar(50) DEFAULT NULL COMMENT '姓名',
  `gender` varchar(10) DEFAULT NULL COMMENT '性别',
  `phone` varchar(20) DEFAULT NULL COMMENT '联系电话',
  `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
  `university` varchar(100) DEFAULT NULL COMMENT '毕业院校',
  `major` varchar(100) DEFAULT NULL COMMENT '专业',
  `graduation_year` int(4) DEFAULT NULL COMMENT '毕业年份',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像URL',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学生表';

-- ----------------------------
-- 3. 企业信息表
-- ----------------------------
DROP TABLE IF EXISTS `company`;
CREATE TABLE `company` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL COMMENT '关联用户ID',
  `name` varchar(100) NOT NULL COMMENT '企业名称',
  `description` text COMMENT '企业简介',
  `logo` varchar(255) DEFAULT NULL COMMENT '企业Logo',
  `address` varchar(200) DEFAULT NULL COMMENT '详细地址',
  `industry` varchar(50) DEFAULT NULL COMMENT '所属行业',
  `scale` varchar(50) DEFAULT NULL COMMENT '人员规模',
  `contact_person` varchar(50) DEFAULT NULL COMMENT '联系人',
  `contact_phone` varchar(20) DEFAULT NULL COMMENT '联系电话',
  `status` int(1) DEFAULT 0 COMMENT '审核状态: 0-待审核, 1-通过, 2-拒绝',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='企业表';

-- ----------------------------
-- 4. 职位分类表 (字典表)
-- ----------------------------
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL COMMENT '分类名称',
  `type` int(1) DEFAULT 1 COMMENT '类型: 1-职位分类, 2-行业分类',
  `parent_id` bigint(20) DEFAULT 0 COMMENT '父级ID',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='分类字典表';

-- ----------------------------
-- 5. 职位信息表
-- ----------------------------
DROP TABLE IF EXISTS `job`;
CREATE TABLE `job` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` bigint(20) NOT NULL COMMENT '发布企业ID',
  `title` varchar(100) NOT NULL COMMENT '职位名称',
  `category_id` bigint(20) DEFAULT NULL COMMENT '职位分类ID',
  `description` text COMMENT '职位描述',
  `requirements` text COMMENT '任职要求',
  `salary_min` int(11) DEFAULT NULL COMMENT '最低薪资',
  `salary_max` int(11) DEFAULT NULL COMMENT '最高薪资',
  `location` varchar(100) DEFAULT NULL COMMENT '工作地点',
  `status` int(1) DEFAULT 1 COMMENT '状态: 1-招聘中, 0-已下架',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='职位表';

-- ----------------------------
-- 6. 简历表
-- ----------------------------
DROP TABLE IF EXISTS `resume`;
CREATE TABLE `resume` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `student_id` bigint(20) NOT NULL COMMENT '关联学生ID',
  `title` varchar(100) DEFAULT '我的简历' COMMENT '简历名称',
  `content` text COMMENT '简历详情(JSON格式存储教育/实习经历)',
  `file_url` varchar(255) DEFAULT NULL COMMENT '附件简历URL',
  `is_public` int(1) DEFAULT 1 COMMENT '是否公开: 1-公开, 0-保密',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_student_id` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='简历表';

-- ----------------------------
-- 7. 职位申请记录表
-- ----------------------------
DROP TABLE IF EXISTS `application`;
CREATE TABLE `application` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `job_id` bigint(20) NOT NULL COMMENT '职位ID',
  `student_id` bigint(20) NOT NULL COMMENT '学生ID',
  `resume_id` bigint(20) NOT NULL COMMENT '使用的简历ID',
  `status` int(1) DEFAULT 0 COMMENT '状态: 0-待查看, 1-已查看, 2-面试邀请, 3-不合适, 4-已录用',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '投递时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_job_student` (`job_id`, `student_id`) COMMENT '同一职位只能投递一次'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='职位申请表';

-- ----------------------------
-- 8. 消息表 (新增：支持企业主动联系)
-- ----------------------------
DROP TABLE IF EXISTS `message`;
CREATE TABLE `message` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `sender_id` bigint(20) NOT NULL COMMENT '发送者用户ID',
  `receiver_id` bigint(20) NOT NULL COMMENT '接收者用户ID',
  `content` text NOT NULL COMMENT '消息内容',
  `type` int(1) DEFAULT 1 COMMENT '类型: 1-普通消息, 2-面试通知, 3-系统通知',
  `is_read` int(1) DEFAULT 0 COMMENT '状态: 0-未读, 1-已读',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '发送时间',
  PRIMARY KEY (`id`),
  KEY `idx_receiver` (`receiver_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='站内消息表';

-- ----------------------------
-- 9. 新闻/公告表
-- ----------------------------
DROP TABLE IF EXISTS `news`;
CREATE TABLE `news` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `title` varchar(200) NOT NULL COMMENT '标题',
  `content` longtext COMMENT '内容',
  `author_id` bigint(20) DEFAULT NULL COMMENT '发布人ID',
  `view_count` int(11) DEFAULT 0 COMMENT '浏览量',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='新闻公告表';

-- ----------------------------
-- 10. 浏览历史表 (新增：记录用户查看过的职位)
-- ----------------------------
DROP TABLE IF EXISTS `browsing_history`;
CREATE TABLE `browsing_history` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `student_id` bigint(20) NOT NULL COMMENT '学生ID',
  `job_id` bigint(20) NOT NULL COMMENT '职位ID',
  `count` int(11) DEFAULT 1 COMMENT '浏览次数',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后浏览时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_student_job` (`student_id`, `job_id`) COMMENT '同一个学生对同一个职位只存一条记录'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='浏览历史表';

SET FOREIGN_KEY_CHECKS = 1;
-- ----------------------------
-- 11. 初始化管理员账号
-- ----------------------------
-- 默认管理员账号：
-- 用户名: admin
-- 密码: admin123
-- 角色: ADMIN
-- 
-- 如需修改密码，请使用以下方法生成BCrypt哈希：
-- 1. 在Java代码中运行: BCrypt.hashpw("你的密码")
-- 2. 或使用在线BCrypt工具生成
-- 3. 替换下面的password字段值
INSERT IGNORE INTO `sys_user` (`username`, `password`, `role`, `status`) 
VALUES ('admin', '$2a$10$ipNCTTJXqmhCif31hcybWOaPaqc4UGhPKT4gyP3aObt7jqNPLVLuS', 'ADMIN', 1);