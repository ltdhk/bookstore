/**
 * 角色权限配置
 * 定义各角色拥有的权限列表
 */
export const ROLE_PERMISSIONS: Record<string, string[]> = {
  admin: ['*'], // 管理员拥有所有权限
  distributor: [
    'dashboard:view',
    'book:view',
    'book:edit',
    'book:import',
    'book:cover',
    'subscription:view',
    'subscription:distributor-revenue',
    // 注意: 没有 subscription:products 权限
  ],
};

/**
 * 菜单权限配置
 * 定义访问各菜单路径所需的权限
 */
export const MENU_PERMISSIONS: Record<string, string[]> = {
  '/': ['dashboard:view'],
  '/book': ['book:view'],
  '/book/import': ['book:import'],
  '/book/cover-management': ['book:cover'],
  '/subscription': ['subscription:view'],
  '/subscription/products': ['subscription:products'], // 分销商无此权限，菜单不可见
  '/subscription/distributor-revenue': ['subscription:distributor-revenue'],
  // 以下菜单分销商不可见
  '/user': ['user:view'],
  '/distributor': ['distributor:view'],
  '/advertisement': ['advertisement:view'],
  '/passcode': ['passcode:view'],
  '/system': ['system:view'],
};

/**
 * 检查用户是否有权限访问指定路径
 */
export const hasPathPermission = (
  path: string,
  permissions: string[]
): boolean => {
  // 管理员拥有所有权限
  if (permissions.includes('*')) {
    return true;
  }

  const requiredPerms = MENU_PERMISSIONS[path];
  if (!requiredPerms) {
    return true; // 未定义权限要求的路径默认允许访问
  }

  return requiredPerms.some((perm) => permissions.includes(perm));
};
