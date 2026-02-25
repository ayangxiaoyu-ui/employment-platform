package com.example.common.exception;

import com.example.common.Result;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    // 专门处理你的自定义业务异常
    @ExceptionHandler(CustomException.class)
    public Result<?> handleCustomException(CustomException e) {
        log.warn("业务异常：{}", e.getMessage());  // warn 级别，不算严重错误
        return Result.error("400", e.getMessage());  // 400 Bad Request 或自定义 code
    }

    // 兜底：捕获其他所有未处理的异常（系统级错误）
    @ExceptionHandler(Exception.class)
    public Result<?> handleAllException(Exception e) {
        log.error("系统异常", e);  // error 级别 + 完整堆栈
        return Result.error("500", "系统繁忙，请稍后重试");  // 隐藏细节，保护安全
    }
}