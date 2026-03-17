// 时间格式化函数
export const formatDateTime = (timeStr) => {
    if (!timeStr) return "暂无时间";
    const date = new Date(timeStr);
    // 格式化为: 2023-10-24 14:30
    return date.getFullYear() + '-' +
        String(date.getMonth() + 1).padStart(2, '0') + '-' +
        String(date.getDate()).padStart(2, '0') + ' ' +
        String(date.getHours()).padStart(2, '0') + ':' +
        String(date.getMinutes()).padStart(2, '0');
};