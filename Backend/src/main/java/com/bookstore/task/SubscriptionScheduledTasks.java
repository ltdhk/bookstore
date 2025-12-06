package com.bookstore.task;

import com.bookstore.service.SubscriptionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * Scheduled tasks for subscription management
 * Handles automatic expiration checking and status updates
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class SubscriptionScheduledTasks {

    private final SubscriptionService subscriptionService;

    /**
     * Check and process expired subscriptions every hour
     * Cron expression: 0 0 * * * ? (At minute 0 of every hour)
     *
     * This task will:
     * 1. Find all users with subscription_status = 'active' but subscription_end_date < now
     * 2. Update their status to 'expired'
     * 3. Set is_svip = false
     */
    @Scheduled(cron = "0 0 * * * ?")
    public void checkExpiredSubscriptions() {
        log.info("========== 开始执行订阅过期检查定时任务 ==========");

        try {
            long startTime = System.currentTimeMillis();

            subscriptionService.processExpiredSubscriptions();

            long duration = System.currentTimeMillis() - startTime;
            log.info("订阅过期检查任务执行完成，耗时: {} ms", duration);

        } catch (Exception e) {
            log.error("订阅过期检查任务执行失败", e);
        }

        log.info("========== 订阅过期检查定时任务结束 ==========");
    }

    /**
     * Health check task - runs every 5 minutes to confirm scheduler is working
     * Can be disabled in production if not needed
     */
    @Scheduled(cron = "0 */5 * * * ?")
    public void healthCheck() {
        log.debug("定时任务调度器运行正常 - {}", java.time.LocalDateTime.now());
    }
}
