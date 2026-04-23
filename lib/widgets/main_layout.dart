import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

// construção do layout principal

class MainLayout extends StatefulWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;

  const MainLayout({
    super.key,
    required this.child,
    required this.title,
    this.actions,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 900;

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            actions: [
              ...?widget.actions,
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  if (Platform.isAndroid) {
                    SystemNavigator.pop();
                  } else if (Platform.isIOS) {
                    exit(0);
                  } else {
                    ServicesBinding.instance.exitApplication(
                      ui.AppExitType.required,
                    );
                  }
                },
                icon: const Icon(Icons.logout),
                tooltip: 'Sair',
              ),
              const SizedBox(width: 16),
            ],
          ),
          drawer: isDesktop ? null : _buildDrawer(),
          body: Row(
            children: [
              if (isDesktop) _buildSidebar(),
              Expanded(
                child: Container(color: Colors.grey[50], child: widget.child),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: AppTheme.navyBlue,
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildLogo(),
          const SizedBox(height: 40),
          _buildNavItems(),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: AppTheme.navyBlue,
        child: Column(
          children: [
            const SizedBox(height: 60),
            _buildLogo(),
            const SizedBox(height: 40),
            _buildNavItems(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.accentBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.description, color: AppTheme.navyBlue),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Synapse Quote',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItems() {
    return Column(
      children: [
        _buildNavItem(Icons.list, 'Meus Documentos', '/'),
        _buildNavItem(Icons.add, 'Novo Documento', '/create'),
        _buildNavItem(Icons.settings, 'Configurações', '/settings'),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String label, String route) {
    bool isSelected = ModalRoute.of(context)?.settings.name == route;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.accentBlue : Colors.white70,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        if (ModalRoute.of(context)?.settings.name != route) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      selected: isSelected,
    );
  }
}
