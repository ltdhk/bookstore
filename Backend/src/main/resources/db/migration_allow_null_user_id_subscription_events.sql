-- 迁移: 允许 subscription_events 表的 user_id 为空
-- 日期: 2025-12-06
-- 说明: 某些 webhook 事件（如处理失败、无法匹配用户的通知）可能没有 user_id

ALTER TABLE `subscription_events`
MODIFY COLUMN `user_id` bigint(20) DEFAULT NULL COMMENT '用户ID (可为空)';
