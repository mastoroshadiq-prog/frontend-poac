import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../config/responsive_helper.dart';
import '../widgets/sidebar_widget.dart';

/// Dashboard Layout
/// Main layout wrapper untuk semua dashboard pages
/// Features:
/// - Responsive sidebar (drawer on mobile, permanent on desktop)
/// - Top app bar with title and actions
/// - Breadcrumb navigation
/// - Content area with consistent padding
/// 
/// Inspired by octax-app/flutter-dashboard layout

class DashboardLayout extends StatefulWidget {
  final Widget child;
  final String title;
  final String currentRoute;
  final List<BreadcrumbItem>? breadcrumbs;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Function(String route)? onNavigate;
  
  const DashboardLayout({
    super.key,
    required this.child,
    required this.title,
    required this.currentRoute,
    this.breadcrumbs,
    this.actions,
    this.floatingActionButton,
    this.onNavigate,
  });

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSidebarCollapsed = false;

  @override
  void initState() {
    super.initState();
    // Collapse sidebar by default on tablet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.isTablet) {
        setState(() {
          _isSidebarCollapsed = true;
        });
      }
    });
  }

  void _handleNavigation(String route) {
    // Close drawer if on mobile
    if (context.isMobile && _scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.of(context).pop();
    }
    
    // Call navigation callback
    widget.onNavigate?.call(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.backgroundLight,
      
      // Drawer (Mobile only)
      drawer: context.isMobile
        ? Drawer(
            child: SidebarWidget(
              currentRoute: widget.currentRoute,
              onNavigate: _handleNavigation,
              isCollapsed: false, // Never collapse in drawer
            ),
          )
        : null,
      
      body: Row(
        children: [
          // Sidebar (Desktop & Tablet only)
          if (!context.isMobile)
            SidebarWidget(
              currentRoute: widget.currentRoute,
              onNavigate: _handleNavigation,
              isCollapsed: _isSidebarCollapsed,
              onCollapsedChanged: (collapsed) {
                setState(() {
                  _isSidebarCollapsed = collapsed;
                });
              },
            ),
          
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top App Bar
                _buildTopBar(),
                
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: ResponsiveHelper.getDashboardContentPadding(context),
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      
      floatingActionButton: widget.floatingActionButton,
    );
  }
  
  Widget _buildTopBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.isMobile ? 12 : 24,
        ),
        child: Row(
          children: [
            // Menu button (Mobile only)
            if (context.isMobile)
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                tooltip: 'Open menu',
              ),
            
            // Title & Breadcrumbs
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // Breadcrumbs (Desktop only)
                  if (!context.isMobile && widget.breadcrumbs != null && widget.breadcrumbs!.isNotEmpty)
                    _buildBreadcrumbs(),
                ],
              ),
            ),
            
            // Actions
            if (widget.actions != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: widget.actions!,
              ),
            
            // Notification Icon
            IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_outlined),
                  // Badge
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.errorRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () {
                // TODO: Show notifications
              },
              tooltip: 'Notifications',
            ),
            
            const SizedBox(width: 8),
            
            // User Avatar (Desktop only)
            if (!context.isMobile)
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryGreen,
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBreadcrumbs() {
    return Row(
      children: [
        for (int i = 0; i < widget.breadcrumbs!.length; i++) ...[
          if (i > 0) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: 8),
          ],
          InkWell(
            onTap: widget.breadcrumbs![i].onTap,
            child: Text(
              widget.breadcrumbs![i].label,
              style: TextStyle(
                fontSize: 12,
                color: i == widget.breadcrumbs!.length - 1
                    ? AppTheme.primaryGreen
                    : AppTheme.textSecondary,
                fontWeight: i == widget.breadcrumbs!.length - 1
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Breadcrumb Item Model
class BreadcrumbItem {
  final String label;
  final VoidCallback? onTap;
  
  const BreadcrumbItem({
    required this.label,
    this.onTap,
  });
}
