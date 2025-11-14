import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../config/responsive_helper.dart';

/// Sidebar Navigation Widget
/// Sidebar dengan navigation menu yang responsive
/// - Desktop: Permanent sidebar
/// - Tablet: Collapsible sidebar
/// - Mobile: Drawer
/// 
/// Inspired by octax-app/flutter-dashboard sidebar design

class SidebarWidget extends StatefulWidget {
  final String currentRoute;
  final Function(String route) onNavigate;
  final bool isCollapsed;
  final Function(bool collapsed)? onCollapsedChanged;
  
  const SidebarWidget({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
    this.isCollapsed = false,
    this.onCollapsedChanged,
  });

  @override
  State<SidebarWidget> createState() => _SidebarWidgetState();
}

class _SidebarWidgetState extends State<SidebarWidget> {
  late bool _isCollapsed;
  
  @override
  void initState() {
    super.initState();
    _isCollapsed = widget.isCollapsed;
  }
  
  void _toggleCollapse() {
    setState(() {
      _isCollapsed = !_isCollapsed;
    });
    widget.onCollapsedChanged?.call(_isCollapsed);
  }

  @override
  Widget build(BuildContext context) {
    final sidebarWidth = _isCollapsed ? 80.0 : ResponsiveHelper.getSidebarWidth(context);
    
    return Container(
      width: sidebarWidth,
      decoration: BoxDecoration(
        color: AppTheme.sidebarBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header / Logo
          _buildHeader(),
          
          // Navigation Menu
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.dashboard,
                    title: 'Dashboard',
                    route: '/home',
                  ),
                  _buildMenuItem(
                    icon: Icons.business_center,
                    title: 'Dashboard Eksekutif',
                    route: '/dashboard-eksekutif',
                  ),
                  _buildMenuItem(
                    icon: Icons.agriculture,
                    title: 'Dashboard Operasional',
                    route: '/dashboard-operasional',
                  ),
                  _buildMenuItem(
                    icon: Icons.engineering,
                    title: 'Dashboard Teknis',
                    route: '/dashboard-teknis',
                  ),
                  _buildMenuItem(
                    icon: Icons.supervisor_account,
                    title: 'Dashboard Mandor',
                    route: '/mandor-dashboard',
                  ),
                  
                  const SizedBox(height: 16),
                  if (!_isCollapsed)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(color: AppTheme.sidebarTextInactive.withOpacity(0.3)),
                    ),
                  const SizedBox(height: 16),
                  
                  _buildMenuItem(
                    icon: Icons.eco,
                    title: 'Lifecycle',
                    route: '/lifecycle',
                  ),
                  _buildMenuItem(
                    icon: Icons.flight,
                    title: 'Drone NDRE Prediction',
                    route: '/drone-ndre-analysis',
                  ),
                  _buildMenuItem(
                    icon: Icons.assignment,
                    title: 'SPK',
                    route: '/spk',
                  ),
                  _buildMenuItem(
                    icon: Icons.analytics,
                    title: 'Reports',
                    route: '/reports',
                  ),
                  
                  const SizedBox(height: 16),
                  if (!_isCollapsed)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(color: AppTheme.sidebarTextInactive.withOpacity(0.3)),
                    ),
                  const SizedBox(height: 16),
                  
                  _buildMenuItem(
                    icon: Icons.settings,
                    title: 'Settings',
                    route: '/settings',
                  ),
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'Help',
                    route: '/help',
                  ),
                ],
              ),
            ),
          ),
          
          // Footer / User Info
          _buildFooter(),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.sidebarBackground,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.sidebarTextInactive.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Logo Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.eco,
              color: Colors.white,
              size: 24,
            ),
          ),
          
          // Title (hidden when collapsed)
          if (!_isCollapsed) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'KEBOEN',
                    style: TextStyle(
                      color: AppTheme.sidebarText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'POAC Dashboard',
                    style: TextStyle(
                      color: AppTheme.sidebarTextInactive,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Collapse button (desktop only)
          if (!context.isMobile) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                _isCollapsed ? Icons.keyboard_arrow_right : Icons.keyboard_arrow_left,
                color: AppTheme.sidebarTextInactive,
              ),
              onPressed: _toggleCollapse,
              tooltip: _isCollapsed ? 'Expand' : 'Collapse',
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String route,
    int? badgeCount,
  }) {
    final isActive = widget.currentRoute == route;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onNavigate(route),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: isActive 
                ? AppTheme.sidebarItemActive.withOpacity(0.2)
                : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isActive
                ? Border.all(color: AppTheme.sidebarItemActive, width: 1)
                : null,
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 56,
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    color: isActive 
                      ? AppTheme.primaryGreenLight 
                      : AppTheme.sidebarTextInactive,
                    size: 24,
                  ),
                ),
                
                // Title (hidden when collapsed)
                if (!_isCollapsed)
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: isActive 
                          ? AppTheme.sidebarText 
                          : AppTheme.sidebarTextInactive,
                        fontSize: 14,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                
                // Badge (if any)
                if (!_isCollapsed && badgeCount != null && badgeCount > 0)
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badgeCount > 99 ? '99+' : badgeCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.sidebarBackground,
        border: Border(
          top: BorderSide(
            color: AppTheme.sidebarTextInactive.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.primaryGreen,
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 20,
            ),
          ),
          
          // User info (hidden when collapsed)
          if (!_isCollapsed) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'User Name',
                    style: TextStyle(
                      color: AppTheme.sidebarText,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'ASISTEN',
                    style: TextStyle(
                      color: AppTheme.sidebarTextInactive,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.logout,
                color: AppTheme.sidebarTextInactive,
                size: 20,
              ),
              onPressed: () {
                // TODO: Implement logout
                widget.onNavigate('/');
              },
              tooltip: 'Logout',
            ),
          ],
        ],
      ),
    );
  }
}
