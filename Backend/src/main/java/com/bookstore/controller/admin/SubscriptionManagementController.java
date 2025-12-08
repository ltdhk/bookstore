package com.bookstore.controller.admin;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.bookstore.common.Result;
import com.bookstore.dto.SubscriptionOrderDetailDTO;
import com.bookstore.dto.SubscriptionOrderListDTO;
import com.bookstore.dto.SubscriptionProductDTO;
import com.bookstore.entity.Distributor;
import com.bookstore.entity.Order;
import com.bookstore.entity.SubscriptionProduct;
import com.bookstore.entity.User;
import com.bookstore.repository.DistributorRepository;
import com.bookstore.repository.OrderRepository;
import com.bookstore.repository.SubscriptionProductRepository;
import com.bookstore.repository.UserMapper;
import com.bookstore.service.SubscriptionService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/admin/subscriptions")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class SubscriptionManagementController {

    private final SubscriptionService subscriptionService;
    private final OrderRepository orderRepository;
    private final SubscriptionProductRepository subscriptionProductRepository;
    private final UserMapper userMapper;
    private final DistributorRepository distributorRepository;

    /**
     * Get subscription orders list with pagination and filters (使用 JOIN 查询关联用户名和分销商名称)
     */
    @GetMapping
    public Result<Map<String, Object>> getSubscriptionOrders(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "20") Integer size,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String platform,
            @RequestParam(required = false) String subscriptionPeriod,
            @RequestParam(required = false) String username,
            @RequestParam(required = false) Long distributorId,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate) {
        try {
            int offset = (page - 1) * size;

            // 使用 JOIN 查询获取列表数据（包含用户名和分销商名称）
            List<SubscriptionOrderListDTO> records = orderRepository.selectSubscriptionOrderList(
                    status, platform, subscriptionPeriod, username, distributorId,
                    startDate, endDate, size, offset);

            // 获取总数
            long total = orderRepository.countSubscriptionOrders(
                    status, platform, subscriptionPeriod, username, distributorId,
                    startDate, endDate);

            // 构建分页结果
            Map<String, Object> result = new HashMap<>();
            result.put("records", records);
            result.put("total", total);
            result.put("size", size);
            result.put("current", page);
            result.put("pages", (total + size - 1) / size);

            return Result.success(result);
        } catch (Exception e) {
            return Result.error("Failed to get subscription orders: " + e.getMessage());
        }
    }

    /**
     * Get subscription order details (使用 JOIN 查询减少数据库查询次数)
     */
    @GetMapping("/{id}")
    public Result<SubscriptionOrderDetailDTO> getSubscriptionDetail(@PathVariable Long id) {
        try {
            // 使用单次 JOIN 查询获取订单详情及关联的分销商、通行证、书籍名称
            SubscriptionOrderDetailDTO detail = orderRepository.selectSubscriptionOrderDetail(id);

            if (detail == null || !"subscription".equals(detail.getOrderType())) {
                return Result.error("Subscription order not found");
            }

            return Result.success(detail);
        } catch (Exception e) {
            return Result.error("Failed to get subscription details: " + e.getMessage());
        }
    }

    /**
     * Force cancel subscription (admin operation)
     */
    @PutMapping("/{id}/cancel")
    public Result<String> forceCancelSubscription(
            @PathVariable Long id,
            @RequestParam(required = false) String reason) {
        try {
            Order order = orderRepository.selectById(id);
            if (order == null || !"subscription".equals(order.getOrderType())) {
                return Result.error("Subscription order not found");
            }

            if ("Paid".equals(order.getStatus()) && order.getSubscriptionEndDate().isAfter(LocalDateTime.now())) {
                // Update order
                order.setIsAutoRenew(false);
                order.setCancelDate(LocalDateTime.now());
                order.setCancelReason(reason != null ? reason : "Admin cancelled");
                order.setUpdateTime(LocalDateTime.now());
                orderRepository.updateById(order);

                // Update user status
                User user = userMapper.selectById(order.getUserId());
                if (user != null) {
                    user.setSubscriptionStatus("cancelled");
                    userMapper.updateById(user);
                }

                return Result.success("Subscription cancelled successfully");
            } else {
                return Result.error("Subscription is not active or already cancelled");
            }
        } catch (Exception e) {
            return Result.error("Failed to cancel subscription: " + e.getMessage());
        }
    }

    /**
     * Get subscription statistics
     */
    @GetMapping("/stats")
    public Result<Map<String, Object>> getSubscriptionStats(
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate) {
        try {
            QueryWrapper<Order> queryWrapper = new QueryWrapper<>();
            queryWrapper.eq("order_type", "subscription");

            if (startDate != null && !startDate.isEmpty()) {
                queryWrapper.ge("create_time", startDate);
            }

            if (endDate != null && !endDate.isEmpty()) {
                queryWrapper.le("create_time", endDate);
            }

            List<Order> allOrders = orderRepository.selectList(queryWrapper);

            Map<String, Object> stats = new HashMap<>();

            // Total subscriptions
            stats.put("totalSubscriptions", allOrders.size());

            // Active subscriptions
            long activeCount = allOrders.stream()
                    .filter(o -> "Paid".equals(o.getStatus())
                            && o.getSubscriptionEndDate() != null
                            && o.getSubscriptionEndDate().isAfter(LocalDateTime.now()))
                    .count();
            stats.put("activeSubscriptions", activeCount);

            // Cancelled subscriptions
            long cancelledCount = allOrders.stream()
                    .filter(o -> o.getCancelDate() != null)
                    .count();
            stats.put("cancelledSubscriptions", cancelledCount);

            // Expired subscriptions
            long expiredCount = allOrders.stream()
                    .filter(o -> "Paid".equals(o.getStatus())
                            && o.getSubscriptionEndDate() != null
                            && o.getSubscriptionEndDate().isBefore(LocalDateTime.now()))
                    .count();
            stats.put("expiredSubscriptions", expiredCount);

            // Total revenue
            BigDecimal totalRevenue = allOrders.stream()
                    .filter(o -> "Paid".equals(o.getStatus()))
                    .map(Order::getAmount)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
            stats.put("totalRevenue", totalRevenue);

            // Revenue by platform
            Map<String, BigDecimal> revenueByPlatform = allOrders.stream()
                    .filter(o -> "Paid".equals(o.getStatus()))
                    .collect(Collectors.groupingBy(
                            Order::getPlatform,
                            Collectors.reducing(BigDecimal.ZERO, Order::getAmount, BigDecimal::add)
                    ));
            stats.put("revenueByPlatform", revenueByPlatform);

            // Revenue by period
            Map<String, BigDecimal> revenueByPeriod = allOrders.stream()
                    .filter(o -> "Paid".equals(o.getStatus()) && o.getSubscriptionPeriod() != null)
                    .collect(Collectors.groupingBy(
                            Order::getSubscriptionPeriod,
                            Collectors.reducing(BigDecimal.ZERO, Order::getAmount, BigDecimal::add)
                    ));
            stats.put("revenueByPeriod", revenueByPeriod);

            // Subscriptions by plan type
            Map<String, Long> subscriptionsByPlan = allOrders.stream()
                    .filter(o -> o.getSubscriptionPeriod() != null)
                    .collect(Collectors.groupingBy(
                            Order::getSubscriptionPeriod,
                            Collectors.counting()
                    ));
            stats.put("subscriptionsByPlan", subscriptionsByPlan);

            // Subscriptions by source entry
            Map<String, Long> subscriptionsBySource = allOrders.stream()
                    .filter(o -> o.getSourceEntry() != null)
                    .collect(Collectors.groupingBy(
                            Order::getSourceEntry,
                            Collectors.counting()
                    ));
            stats.put("subscriptionsBySource", subscriptionsBySource);

            return Result.success(stats);
        } catch (Exception e) {
            return Result.error("Failed to get statistics: " + e.getMessage());
        }
    }

    /**
     * Get all subscription products
     */
    @GetMapping("/products")
    public Result<List<SubscriptionProductDTO>> getProducts(
            @RequestParam(required = false) String platform,
            @RequestParam(required = false) Boolean isActive) {
        try {
            QueryWrapper<SubscriptionProduct> queryWrapper = new QueryWrapper<>();

            if (platform != null && !platform.isEmpty()) {
                queryWrapper.eq("platform", platform);
            }

            if (isActive != null) {
                queryWrapper.eq("is_active", isActive);
            }

            queryWrapper.orderByAsc("sort_order");

            List<SubscriptionProduct> products = subscriptionProductRepository.selectList(queryWrapper);
            List<SubscriptionProductDTO> dtos = products.stream().map(product -> {
                SubscriptionProductDTO dto = new SubscriptionProductDTO();
                BeanUtils.copyProperties(product, dto);
                return dto;
            }).collect(Collectors.toList());

            return Result.success(dtos);
        } catch (Exception e) {
            return Result.error("Failed to get products: " + e.getMessage());
        }
    }

    /**
     * Create subscription product
     */
    @PostMapping("/products")
    public Result<SubscriptionProduct> createProduct(@RequestBody SubscriptionProduct product) {
        try {
            product.setCreatedAt(LocalDateTime.now());
            product.setUpdatedAt(LocalDateTime.now());
            subscriptionProductRepository.insert(product);
            return Result.success(product);
        } catch (Exception e) {
            return Result.error("Failed to create product: " + e.getMessage());
        }
    }

    /**
     * Update subscription product
     */
    @PutMapping("/products/{id}")
    public Result<SubscriptionProduct> updateProduct(
            @PathVariable Long id,
            @RequestBody SubscriptionProduct product) {
        try {
            SubscriptionProduct existing = subscriptionProductRepository.selectById(id);
            if (existing == null) {
                return Result.error("Product not found");
            }

            product.setId(id);
            product.setUpdatedAt(LocalDateTime.now());
            subscriptionProductRepository.updateById(product);
            return Result.success(product);
        } catch (Exception e) {
            return Result.error("Failed to update product: " + e.getMessage());
        }
    }

    /**
     * Delete subscription product
     */
    @DeleteMapping("/products/{id}")
    public Result<String> deleteProduct(@PathVariable Long id) {
        try {
            SubscriptionProduct product = subscriptionProductRepository.selectById(id);
            if (product == null) {
                return Result.error("Product not found");
            }

            subscriptionProductRepository.deleteById(id);
            return Result.success("Product deleted successfully");
        } catch (Exception e) {
            return Result.error("Failed to delete product: " + e.getMessage());
        }
    }

    /**
     * Toggle product active status
     */
    @PutMapping("/products/{id}/toggle")
    public Result<String> toggleProductStatus(@PathVariable Long id) {
        try {
            SubscriptionProduct product = subscriptionProductRepository.selectById(id);
            if (product == null) {
                return Result.error("Product not found");
            }

            product.setIsActive(!product.getIsActive());
            product.setUpdatedAt(LocalDateTime.now());
            subscriptionProductRepository.updateById(product);

            return Result.success("Product status updated successfully");
        } catch (Exception e) {
            return Result.error("Failed to update product status: " + e.getMessage());
        }
    }

    /**
     * Get subscriptions by distributor
     */
    @GetMapping("/by-distributor/{distributorId}")
    public Result<Map<String, Object>> getSubscriptionsByDistributor(
            @PathVariable Long distributorId,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "20") Integer size) {
        try {
            Page<Order> pageParam = new Page<>(page, size);
            QueryWrapper<Order> queryWrapper = new QueryWrapper<>();

            queryWrapper.eq("order_type", "subscription");
            queryWrapper.eq("distributor_id", distributorId);
            queryWrapper.eq("status", "Paid");
            queryWrapper.orderByDesc("create_time");

            IPage<Order> orders = orderRepository.selectPage(pageParam, queryWrapper);

            // Calculate total revenue for this distributor
            QueryWrapper<Order> revenueWrapper = new QueryWrapper<>();
            revenueWrapper.eq("order_type", "subscription");
            revenueWrapper.eq("distributor_id", distributorId);
            revenueWrapper.eq("status", "Paid");

            List<Order> allOrders = orderRepository.selectList(revenueWrapper);
            BigDecimal totalRevenue = allOrders.stream()
                    .map(Order::getAmount)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            // Get distributor commission rate
            Distributor distributor = distributorRepository.selectById(distributorId);
            BigDecimal commissionRate = distributor != null && distributor.getCommissionRate() != null
                    ? distributor.getCommissionRate()
                    : new BigDecimal("30.00");

            // Calculate actual commission
            BigDecimal distributorCommission = totalRevenue
                    .multiply(commissionRate)
                    .divide(new BigDecimal("100"), 2, BigDecimal.ROUND_HALF_UP);

            Map<String, Object> result = new HashMap<>();
            result.put("orders", orders);
            result.put("totalRevenue", totalRevenue);
            result.put("commissionRate", commissionRate);
            result.put("distributorCommission", distributorCommission);
            result.put("totalCount", allOrders.size());

            return Result.success(result);
        } catch (Exception e) {
            return Result.error("Failed to get distributor subscriptions: " + e.getMessage());
        }
    }

    /**
     * Get distributor revenue report (all distributors)
     */
    @GetMapping("/distributors/revenue-report")
    public Result<List<Map<String, Object>>> getDistributorsRevenueReport(
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate) {
        try {
            // Get all distributors
            QueryWrapper<Distributor> distributorWrapper = new QueryWrapper<>();
            distributorWrapper.eq("status", 1); // Only active distributors
            List<Distributor> distributors = distributorRepository.selectList(distributorWrapper);

            List<Map<String, Object>> reportList = new java.util.ArrayList<>();

            for (Distributor distributor : distributors) {
                // Get orders for this distributor
                QueryWrapper<Order> orderWrapper = new QueryWrapper<>();
                orderWrapper.eq("order_type", "subscription");
                orderWrapper.eq("distributor_id", distributor.getId());
                orderWrapper.eq("status", "Paid");

                if (startDate != null && !startDate.isEmpty()) {
                    orderWrapper.ge("create_time", startDate);
                }
                if (endDate != null && !endDate.isEmpty()) {
                    orderWrapper.le("create_time", endDate);
                }

                List<Order> orders = orderRepository.selectList(orderWrapper);

                // Calculate total revenue
                BigDecimal totalRevenue = orders.stream()
                        .map(Order::getAmount)
                        .reduce(BigDecimal.ZERO, BigDecimal::add);

                // Get commission rate
                BigDecimal commissionRate = distributor.getCommissionRate() != null
                        ? distributor.getCommissionRate()
                        : new BigDecimal("30.00");

                // Calculate distributor commission
                BigDecimal distributorCommission = totalRevenue
                        .multiply(commissionRate)
                        .divide(new BigDecimal("100"), 2, BigDecimal.ROUND_HALF_UP);

                // Build report item
                Map<String, Object> reportItem = new HashMap<>();
                reportItem.put("distributorId", distributor.getId());
                reportItem.put("distributorName", distributor.getName());
                reportItem.put("distributorCode", distributor.getCode());
                reportItem.put("commissionRate", commissionRate);
                reportItem.put("orderCount", orders.size());
                reportItem.put("totalRevenue", totalRevenue);
                reportItem.put("distributorCommission", distributorCommission);

                reportList.add(reportItem);
            }

            return Result.success(reportList);
        } catch (Exception e) {
            return Result.error("Failed to get distributors revenue report: " + e.getMessage());
        }
    }
}
