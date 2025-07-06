# Solar Schedule UI Integration Plan

## 🎨 **Modern Calendar UI Integration for Solar Project Management**

### **Overview**
The provided calendar and schedule UI design is beautifully crafted and would significantly enhance the user experience of your solar project management app. Here's how we can integrate this modern design with your existing work calendar system.

---

## **🔄 Integration Strategy**

### **1. Enhanced Calendar Screen Design**
Replace the current `calendar_screen.dart` with the modern design while maintaining existing functionality:

```dart
// Enhanced Solar Calendar Screen with Modern UI
class ModernSolarCalendarScreen extends StatefulWidget {
  const ModernSolarCalendarScreen({super.key});

  @override
  State<ModernSolarCalendarScreen> createState() => _ModernSolarCalendarScreenState();
}

class _ModernSolarCalendarScreenState extends State<ModernSolarCalendarScreen> {
  int _selectedIndex = 1; // Calendar tab selected
  DateTime _selectedDate = DateTime.now();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: _buildModernAppBar(),
      body: _buildCalendarContent(),
      bottomNavigationBar: _buildSolarBottomNav(),
    );
  }
  
  AppBar _buildModernAppBar() {
    return AppBar(
      backgroundColor: context.colorScheme.surface,
      elevation: 0,
      leadingWidth: 150,
      leading: Padding(
        padding: EdgeInsets.only(left: SolarSpacing.md),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            _getMonthName(_selectedDate),
            style: context.textTheme.displayHeading.copyWith(
              fontSize: 34,
              color: context.colorScheme.onSurface,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: context.colorScheme.onSurface, size: 28),
          onPressed: () => _showSearchDialog(),
        ),
        IconButton(
          icon: Icon(Icons.settings_outlined, color: context.colorScheme.onSurface, size: 28),
          onPressed: () => _showSettings(),
        ),
      ],
    );
  }
}
```

### **2. Modern Calendar Widget**
Create a new calendar widget that matches the design:

```dart
class SolarCalendarView extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final List<WorkEvent> events;
  final List<ConstructionTask> tasks;

  const SolarCalendarView({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.events,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SolarSpacing.md,
        vertical: SolarSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _buildWeekDays(),
      ),
    );
  }

  List<Widget> _buildWeekDays() {
    // Implementation similar to the provided design
    // but adapted for solar project events and tasks
  }

  Widget _buildCalendarDay(String day, String date, {
    required bool isActive,
    bool hasDots = false,
    List<Color> dotColors = const [],
  }) {
    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            color: isActive 
              ? context.colorScheme.onSurface 
              : context.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: SolarSpacing.sm),
        Container(
          padding: EdgeInsets.all(SolarSpacing.sm),
          decoration: BoxDecoration(
            color: isActive 
              ? context.colorScheme.solarBlue 
              : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Text(
            date,
            style: TextStyle(
              color: isActive 
                ? Colors.white 
                : context.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(height: SolarSpacing.xs),
        if (hasDots)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: dotColors.map((color) => Container(
              width: 3,
              height: 3,
              margin: EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            )).toList(),
          )
        else
          SizedBox(height: 10),
      ],
    );
  }
}
```

### **3. Modern Schedule List**
Adapt the schedule items for solar project management:

```dart
class SolarScheduleList extends StatelessWidget {
  final List<WorkEvent> events;
  final List<ConstructionTask> tasks;
  final DateTime selectedDate;

  const SolarScheduleList({
    super.key,
    required this.events,
    required this.tasks,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: SolarSpacing.lg),
          _buildSectionHeader(
            "Today • ${_formatDate(selectedDate)}",
          ),
          
          // Construction Tasks for Today
          ...tasks.where(_isToday).map((task) => 
            _buildConstructionTaskItem(task)
          ),
          
          // Work Events for Today  
          ...events.where(_isToday).map((event) =>
            _buildWorkEventItem(event)
          ),
          
          // Due Today Items
          _buildDueTodayItem(),
          
          Divider(height: 30, indent: 20, endIndent: 20),
          
          _buildSectionHeader(
            "Tomorrow • ${_formatDate(selectedDate.add(Duration(days: 1)))}",
          ),
          
          // Tomorrow's items...
        ],
      ),
    );
  }
  
  Widget _buildConstructionTaskItem(ConstructionTask task) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: SolarSpacing.xs),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Color bar based on task status/priority
            Container(
              width: 6,
              color: _getTaskColor(task),
            ),
            SizedBox(width: SolarSpacing.sm),
            
            // Time section
            SizedBox(
              width: 70,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: SolarSpacing.xs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatTime(task.startDate),
                      style: context.textTheme.body.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      _formatTime(task.endDate),
                      style: context.textTheme.caption.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Content section
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: SolarSpacing.xs,
                  horizontal: SolarSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.construction_outlined,
                          color: context.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        SizedBox(width: SolarSpacing.sm),
                        Text(
                          task.title,
                          style: context.textTheme.cardTitle.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    
                    if (task.assignedTeam != null) ...[
                      SizedBox(height: SolarSpacing.xs),
                      Padding(
                        padding: EdgeInsets.only(left: 28.0),
                        child: Text(
                          task.assignedTeam!,
                          style: context.textTheme.body.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                    
                    SizedBox(height: SolarSpacing.sm),
                    Padding(
                      padding: EdgeInsets.only(left: 28.0),
                      child: Text(
                        "Progress: ${(task.progress * 100).toInt()}%",
                        style: context.textTheme.body,
                      ),
                    ),
                    
                    // Progress indicator
                    SizedBox(height: SolarSpacing.xs),
                    Padding(
                      padding: EdgeInsets.only(left: 28.0, right: SolarSpacing.md),
                      child: LinearProgressIndicator(
                        value: task.progress,
                        backgroundColor: context.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getTaskColor(task),
                        ),
                      ),
                    ),
                    
                    // Status indicator
                    if (task.status != TaskStatus.inProgress) ...[
                      SizedBox(height: SolarSpacing.sm),
                      Padding(
                        padding: EdgeInsets.only(left: 28.0),
                        child: Row(
                          children: [
                            Icon(
                              _getStatusIcon(task.status),
                              color: _getStatusColor(task.status),
                              size: 20,
                            ),
                            SizedBox(width: SolarSpacing.sm),
                            Text(
                              "Status: ${task.status.displayName}",
                              style: context.textTheme.body.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    SizedBox(height: SolarSpacing.sm),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getTaskColor(ConstructionTask task) {
    switch (task.status) {
      case TaskStatus.completed:
        return context.colorScheme.energyHigh; // Green
      case TaskStatus.inProgress:
        return context.colorScheme.solarBlue; // Blue
      case TaskStatus.notStarted:
        return context.colorScheme.energyMedium; // Orange
      case TaskStatus.onHold:
        return context.colorScheme.energyLow; // Red
      default:
        return context.colorScheme.outline;
    }
  }
}
```

---

## **🎯 Key Features to Implement**

### **1. Solar-Specific Adaptations**
- **Energy Status Colors**: Use the solar color scheme (energyHigh, energyMedium, etc.)
- **Project Types**: Distinguish between installation, maintenance, inspection tasks
- **Team Assignments**: Show solar installation teams, electrical teams, inspection teams
- **Progress Tracking**: Visual progress bars for construction phases
- **Weather Integration**: Show weather conditions affecting outdoor work

### **2. Enhanced Functionality**
```dart
// Solar-specific schedule items
Widget _buildSolarInstallationItem({
  required Color statusColor,
  required String startTime,
  required String endTime,
  required String customerName,
  required String projectDetails,
  required String address,
  required InstallationPhase phase,
  required double energyCapacity,
  IconData? weatherIcon,
  String? weatherCondition,
}) {
  return _buildScheduleItem(
    color: statusColor,
    time: startTime,
    duration: endTime,
    icon: Icons.solar_power,
    title: customerName,
    projectDetails: "$projectDetails • ${energyCapacity}kW System",
    address: address,
    additionalInfo: phase.displayName,
    weatherInfo: weatherCondition != null 
      ? Row(
          children: [
            Icon(weatherIcon, size: 16, color: context.colorScheme.onSurfaceVariant),
            SizedBox(width: 4),
            Text(weatherCondition, style: context.textTheme.caption),
          ],
        )
      : null,
  );
}
```

### **3. Integration Points**
- **BLoC Integration**: Connect with existing `WorkCalendarBloc` and `CalendarManagementBloc`
- **Navigation**: Use your existing `AppRouter` system
- **Theme Integration**: Use the new `SolarAppTheme` throughout
- **Data Models**: Leverage existing `WorkEvent`, `ConstructionTask`, and `CalendarEvent` entities

---

## **📱 Bottom Navigation Enhancement**

```dart
Widget _buildSolarBottomNav() {
  return BottomNavigationBar(
    items: [
      BottomNavigationBarItem(
        icon: Icon(Icons.dashboard_outlined),
        activeIcon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.calendar_today_outlined),
        activeIcon: Icon(Icons.calendar_today),
        label: 'Schedule',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.engineering_outlined),
        activeIcon: Icon(Icons.engineering),
        label: 'Projects',
      ),
    ],
    currentIndex: _selectedIndex,
    selectedItemColor: context.colorScheme.solarBlue,
    unselectedItemColor: context.colorScheme.onSurfaceVariant,
    type: BottomNavigationBarType.fixed,
    backgroundColor: context.colorScheme.surface,
    elevation: 8.0,
    onTap: _onBottomNavTapped,
  );
}
```

---

## **🚀 Implementation Steps**

### **Phase 1: Core UI Implementation**
1. Create `ModernSolarCalendarScreen` widget
2. Implement `SolarCalendarView` with week view
3. Build `SolarScheduleList` with task/event items
4. Integrate with existing BLoCs

### **Phase 2: Solar-Specific Features**
1. Add weather integration for outdoor tasks
2. Implement energy capacity and progress tracking
3. Create specialized schedule item types
4. Add team assignment visualizations

### **Phase 3: Enhanced UX**
1. Add smooth animations between dates
2. Implement pull-to-refresh functionality
3. Add search and filter capabilities
4. Optimize for different screen sizes

### **Phase 4: Integration & Testing**
1. Connect with existing calendar management system
2. Ensure data consistency across views
3. Add comprehensive testing
4. Performance optimization

---

## **💡 Benefits of This Integration**

### **For Users**
- **Modern Interface**: Clean, professional calendar design
- **Solar Focus**: Specialized for solar installation workflows
- **Better Visibility**: Clear status indicators and progress tracking
- **Intuitive Navigation**: Easy-to-use bottom navigation

### **For Development**
- **Consistent Theme**: Uses your new SolarAppTheme system
- **Maintainable Code**: Follows existing architecture patterns
- **Extensible Design**: Easy to add new schedule item types
- **Performance Optimized**: Efficient list rendering and state management

---

## **🎨 Visual Enhancements**

- **Solar Color Coding**: Blue for active, orange for pending, green for completed
- **Progress Indicators**: Visual progress bars for installation phases
- **Weather Icons**: Weather conditions affecting outdoor work
- **Team Avatars**: Visual representation of assigned teams
- **Energy Metrics**: kW capacity and estimated generation

This integration would transform your calendar from a functional tool into a beautiful, solar-focused scheduling interface that delights users while maintaining all existing functionality!

Would you like me to start implementing any specific part of this integration plan?
