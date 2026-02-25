package com.example.common.exception;
//创建全局异常处理器
import com.example.common.Result;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {
    private final String test = "hello";
    public void testLombok() {
        log.info("测试 Lombok 是否生效");
        System.out.println(test);
    }
    @ExceptionHandler(Exception.class)
    public Result<?> handleException(Exception e) {
        log.error("系统异常", e);
        return Result.error(e.getMessage());
    }

    // 这里以后可以扩展更多具体的异常处理，比如自定义业务异常
}