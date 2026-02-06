import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import 'package:udb_association/src/features/shop/providers/order_provider.dart';
import 'package:udb_association/src/features/shop/models/order_model.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  DateTime selectedMonth = DateTime.now();
  late int selectedWeek;
  String selectedPeriodType = 'Weekly'; // Weekly, Monthly, Yearly

  @override
  void initState() {
    super.initState();
    // Calculate current week number in the current month
    selectedWeek = _getCurrentWeekOfMonth();
  }

  // Calculate which week of the month today is
  int _getCurrentWeekOfMonth() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final weekNumber = ((now.day + firstDayOfMonth.weekday - 2) ~/ 7) + 1;
    return weekNumber;
  }

  // Calculate statistics from vendor orders
  Map<String, dynamic> _calculateStatistics(List<OrderModel> orders) {
    int totalOrders = orders.length;
    double totalRevenue = 0;
    Set<int> uniqueCustomers = {}; // Track unique customer IDs
    Map<String, int> orderStatusData = {
      'Pending': 0,
      'Processing': 0,
      'Shipped': 0,
      'Delivered': 0,
    };

    for (var order in orders) {
      // Calculate total revenue
      final amount = double.tryParse(order.totalAmount) ?? 0.0;
      totalRevenue += amount;

      // Track unique customers from user object
      if (order.user != null) {
        uniqueCustomers.add(order.user!.id);
      } else {
        // Fallback to userId if user object is not available
        uniqueCustomers.add(order.userId);
      }

      // Count order statuses (normalize to capitalize first letter)
      final status = order.status.toLowerCase();
      if (status.contains('pend')) {
        orderStatusData['Pending'] = (orderStatusData['Pending'] ?? 0) + 1;
      } else if (status.contains('process')) {
        orderStatusData['Processing'] =
            (orderStatusData['Processing'] ?? 0) + 1;
      } else if (status.contains('ship')) {
        orderStatusData['Shipped'] = (orderStatusData['Shipped'] ?? 0) + 1;
      } else if (status.contains('deliver')) {
        orderStatusData['Delivered'] = (orderStatusData['Delivered'] ?? 0) + 1;
      }
    }

    return {
      'totalOrders': totalOrders,
      'totalRevenue': totalRevenue,
      'totalCustomers': uniqueCustomers.length,
      'orderStatusData': orderStatusData,
    };
  }

  // Calculate weekly sales data from orders
  Map<String, List<double>> _calculateWeeklySales(List<OrderModel> orders) {
    Map<String, List<double>> weeklySalesData = {};

    // Group orders by month and week
    for (var order in orders) {
      try {
        final orderDate = DateTime.parse(order.createdAt);
        final monthKey = DateFormat('yyyy-MM').format(orderDate);

        // Calculate week number in month
        final firstDayOfMonth = DateTime(orderDate.year, orderDate.month, 1);
        final weekNumber =
            ((orderDate.day + firstDayOfMonth.weekday - 2) ~/ 7) + 1;

        final weekKey = '$monthKey-$weekNumber';

        // Get day of week (0 = Monday, 6 = Sunday)
        final dayOfWeek = orderDate.weekday - 1;

        // Initialize week data if not exists
        if (!weeklySalesData.containsKey(weekKey)) {
          weeklySalesData[weekKey] = [0, 0, 0, 0, 0, 0, 0];
        }

        // Add order amount to the day
        final amount = double.tryParse(order.totalAmount) ?? 0.0;
        weeklySalesData[weekKey]![dayOfWeek] += amount;
      } catch (e) {
        print('Error parsing order date: $e');
      }
    }

    return weeklySalesData;
  }

  // Calculate monthly sales data from orders (12 months)
  Map<String, List<double>> _calculateMonthlySales(List<OrderModel> orders) {
    Map<String, List<double>> monthlySalesData = {};

    for (var order in orders) {
      try {
        final orderDate = DateTime.parse(order.createdAt);
        final yearKey = orderDate.year.toString();

        // Initialize year data if not exists (12 months: Jan-Dec)
        if (!monthlySalesData.containsKey(yearKey)) {
          monthlySalesData[yearKey] = List.filled(12, 0.0);
        }

        // Get month index (0 = January, 11 = December)
        final monthIndex = orderDate.month - 1;

        // Add order amount to the month
        final amount = double.tryParse(order.totalAmount) ?? 0.0;
        monthlySalesData[yearKey]![monthIndex] += amount;
      } catch (e) {
        print('Error parsing order date: $e');
      }
    }

    return monthlySalesData;
  }

  // Calculate yearly sales data from orders
  Map<String, double> _calculateYearlySales(List<OrderModel> orders) {
    Map<String, double> yearlySalesData = {};

    for (var order in orders) {
      try {
        final orderDate = DateTime.parse(order.createdAt);
        final yearKey = orderDate.year.toString();

        // Initialize year data if not exists
        if (!yearlySalesData.containsKey(yearKey)) {
          yearlySalesData[yearKey] = 0.0;
        }

        // Add order amount to the year
        final amount = double.tryParse(order.totalAmount) ?? 0.0;
        yearlySalesData[yearKey] = yearlySalesData[yearKey]! + amount;
      } catch (e) {
        print('Error parsing order date: $e');
      }
    }

    return yearlySalesData;
  }

  List<String> get weekDays => [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  String get currentMonthKey => DateFormat('yyyy-MM').format(selectedMonth);

  String get currentWeekKey => '$currentMonthKey-$selectedWeek';

  // Calculate number of weeks in the selected month
  int get weeksInMonth {
    final lastDayOfMonth = DateTime(
      selectedMonth.year,
      selectedMonth.month + 1,
      0,
    );
    final firstDayOfMonth = DateTime(
      selectedMonth.year,
      selectedMonth.month,
      1,
    );
    final days = lastDayOfMonth.day;
    return ((days + firstDayOfMonth.weekday - 1) / 7).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vendorOrdersAsync = ref.watch(vendorOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('statistics_title')),
        backgroundColor: const Color(0xFF6B7C32),
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: vendorOrdersAsync.when(
        data: (ordersResponse) {
          final orders = ordersResponse.data;
          final stats = _calculateStatistics(orders);
          final weeklySalesData = _calculateWeeklySales(orders);
          final monthlySalesData = _calculateMonthlySales(orders);
          final yearlySalesData = _calculateYearlySales(orders);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statistics Cards
                _buildStatisticsCards(l10n, stats),
                const SizedBox(height: 24),

                // Sales Progress Chart
                _buildSalesProgressChart(
                  l10n,
                  weeklySalesData,
                  monthlySalesData,
                  yearlySalesData,
                ),
                const SizedBox(height: 24),

                // Order Status Chart
                _buildOrderStatusChart(l10n, stats, orders),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                l10n.translate('statistics_error_title'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(vendorOrdersProvider);
                },
                child: Text(l10n.translate('retry')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(
    AppLocalizations l10n,
    Map<String, dynamic> stats,
  ) {
    final totalOrders = stats['totalOrders'] as int;
    final totalRevenue = stats['totalRevenue'] as double;
    final totalCustomers = stats['totalCustomers'] as int;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('statistics_overview'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        // First Row - Total Orders and Total Revenue
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: l10n.translate('statistics_total_orders'),
                value: totalOrders.toString(),
                icon: Icons.shopping_cart,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: l10n.translate('statistics_total_revenue'),
                value: l10n.translate(
                  'statistics_currency_value',
                  params: {'value': totalRevenue.toStringAsFixed(2)},
                ),
                icon: Icons.attach_money,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Second Row - Total Customers and Avg Order Value
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: l10n.translate('statistics_total_customers'),
                value: totalCustomers.toString(),
                icon: Icons.people,
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: l10n.translate('statistics_avg_order_value'),
                value: totalOrders > 0
                    ? l10n.translate(
                        'statistics_currency_value',
                        params: {
                          'value': (totalRevenue / totalOrders).toStringAsFixed(
                            2,
                          ),
                        },
                      )
                    : l10n.translate(
                        'statistics_currency_value',
                        params: {'value': '0.00'},
                      ),
                icon: Icons.trending_up,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      height: 120, // Fixed height for all cards
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalesProgressChart(
    AppLocalizations l10n,
    Map<String, List<double>> weeklySalesData,
    Map<String, List<double>> monthlySalesData,
    Map<String, double> yearlySalesData,
  ) {
    List<double> chartData = [];
    List<String> labels = [];
    double maxValue = 100.0;

    // Determine data based on selected period type
    if (selectedPeriodType == 'Weekly') {
      chartData = weeklySalesData[currentWeekKey] ?? [0, 0, 0, 0, 0, 0, 0];
      labels = [
        l10n.translate('events_day_mon'),
        l10n.translate('events_day_tue'),
        l10n.translate('events_day_wed'),
        l10n.translate('events_day_thu'),
        l10n.translate('events_day_fri'),
        l10n.translate('events_day_sat'),
        l10n.translate('events_day_sun'),
      ];
    } else if (selectedPeriodType == 'Monthly') {
      final currentYear = DateTime.now().year.toString();
      chartData = monthlySalesData[currentYear] ?? List.filled(12, 0.0);
      labels = List.generate(
        12,
        (index) => DateFormat(
          'MMM',
          l10n.locale.toLanguageTag(),
        ).format(DateTime(2000, index + 1)),
      );
    } else if (selectedPeriodType == 'Yearly') {
      // Get last 5 years of data
      final currentYear = DateTime.now().year;
      for (int i = 4; i >= 0; i--) {
        final year = (currentYear - i).toString();
        labels.add(year);
        chartData.add(yearlySalesData[year] ?? 0.0);
      }
    }

    maxValue = chartData.isEmpty
        ? 100.0
        : chartData.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.translate(
                    'statistics_sales_progress_title',
                    params: {'period': _periodLabel(l10n, selectedPeriodType)},
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              // Period Type Dropdown
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B7C32).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF6B7C32).withOpacity(0.3),
                  ),
                ),
                child: DropdownButton<String>(
                  value: selectedPeriodType,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, size: 20),
                  style: const TextStyle(
                    color: Color(0xFF6B7C32),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  items: ['Weekly', 'Monthly', 'Yearly'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(_periodLabel(l10n, value)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedPeriodType = newValue;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (selectedPeriodType == 'Weekly')
            Row(
              children: [
                // Month Selector
                Expanded(
                  child: GestureDetector(
                    onTap: _selectMonth,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_month,
                            color: Colors.green[700],
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat(
                              'MMM yyyy',
                              l10n.locale.toLanguageTag(),
                            ).format(selectedMonth),
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Week Selector
                Expanded(
                  child: GestureDetector(
                    onTap: _selectWeek,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.date_range,
                            color: Colors.blue[700],
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.translate(
                              'statistics_week_label',
                              params: {'week': selectedWeek.toString()},
                            ),
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (chartData.length - 1).toDouble(),
                minY: 0,
                maxY: maxValue > 0 ? maxValue + (maxValue * 0.1) : 100,
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          labels[index],
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value);
                    }).toList(),
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.withOpacity(0.3),
                          Colors.green.withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusChart(
    AppLocalizations l10n,
    Map<String, dynamic> stats,
    List<OrderModel> orders,
  ) {
    final orderStatusData = stats['orderStatusData'] as Map<String, int>;
    final colors = {
      'Shipped': Colors.purple,
      'Delivered': Colors.green,
      'Pending': Colors.blue,
      'Processing': Colors.orange,
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate('statistics_order_status_title'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Pie Chart
              SizedBox(
                width: 150,
                height: 150,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: orderStatusData.entries.map((e) {
                      return PieChartSectionData(
                        color: colors[e.key] ?? Colors.grey,
                        value: e.value.toDouble(),
                        title: e.value.toString(),
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: orderStatusData.entries.map((e) {
                    final status = e.key;
                    final count = e.value;
                    final color = colors[status] ?? Colors.grey;
                    final totalSales = _getTotalSalesForStatus(status, orders);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _orderStatusLabel(l10n, status),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  l10n.translate(
                                    'statistics_orders_count',
                                    params: {'count': count.toString()},
                                  ),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  l10n.translate(
                                    'statistics_currency_value',
                                    params: {
                                      'value': totalSales.toStringAsFixed(0),
                                    },
                                  ),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _periodLabel(AppLocalizations l10n, String period) {
    switch (period) {
      case 'Monthly':
        return l10n.translate('statistics_period_monthly');
      case 'Yearly':
        return l10n.translate('statistics_period_yearly');
      case 'Weekly':
      default:
        return l10n.translate('statistics_period_weekly');
    }
  }

  String _orderStatusLabel(AppLocalizations l10n, String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('pend')) {
      return l10n.translate('statistics_status_pending');
    }
    if (normalized.contains('process')) {
      return l10n.translate('statistics_status_processing');
    }
    if (normalized.contains('ship')) {
      return l10n.translate('statistics_status_shipped');
    }
    if (normalized.contains('deliver')) {
      return l10n.translate('statistics_status_delivered');
    }
    return status;
  }

  double _getTotalSalesForStatus(String status, List<OrderModel> orders) {
    double total = 0.0;

    for (var order in orders) {
      final orderStatus = order.status.toLowerCase();
      bool matches = false;

      if (status == 'Pending' && orderStatus.contains('pend')) {
        matches = true;
      } else if (status == 'Processing' && orderStatus.contains('process')) {
        matches = true;
      } else if (status == 'Shipped' && orderStatus.contains('ship')) {
        matches = true;
      } else if (status == 'Delivered' && orderStatus.contains('deliver')) {
        matches = true;
      }

      if (matches) {
        final amount = double.tryParse(order.totalAmount) ?? 0.0;
        total += amount;
      }
    }

    return total;
  }

  Future<void> _selectMonth() async {
    final l10n = context.l10n;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        int selectedYear = selectedMonth.year;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.translate('statistics_select_month')),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    // Year Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () {
                            setDialogState(() {
                              selectedYear--;
                            });
                          },
                        ),
                        Text(
                          selectedYear.toString(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () {
                            if (selectedYear < DateTime.now().year) {
                              setDialogState(() {
                                selectedYear++;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    // Month Grid
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: 12,
                        itemBuilder: (context, index) {
                          final monthNum = index + 1;
                          final monthName = DateFormat(
                            'MMM',
                            l10n.locale.toLanguageTag(),
                          ).format(DateTime(selectedYear, monthNum));
                          final isSelected =
                              selectedYear == selectedMonth.year &&
                              monthNum == selectedMonth.month;
                          final isFuture = DateTime(
                            selectedYear,
                            monthNum,
                          ).isAfter(DateTime.now());

                          return InkWell(
                            onTap: isFuture
                                ? null
                                : () {
                                    setState(() {
                                      selectedMonth = DateTime(
                                        selectedYear,
                                        monthNum,
                                      );
                                      // If selecting current month, set to current week
                                      final now = DateTime.now();
                                      if (selectedYear == now.year &&
                                          monthNum == now.month) {
                                        selectedWeek = _getCurrentWeekOfMonth();
                                      } else {
                                        selectedWeek = 1;
                                      }
                                    });
                                    Navigator.of(context).pop();
                                  },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.green
                                    : isFuture
                                    ? Colors.grey.withOpacity(0.1)
                                    : Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.green
                                      : Colors.green.withOpacity(0.3),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  monthName,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : isFuture
                                        ? Colors.grey
                                        : Colors.green[700],
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.translate('common_cancel')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _selectWeek() async {
    final int totalWeeks = weeksInMonth;
    final l10n = context.l10n;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            l10n.translate(
              'statistics_select_week_title',
              params: {
                'month': DateFormat(
                  'MMM yyyy',
                  l10n.locale.toLanguageTag(),
                ).format(selectedMonth),
              },
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: totalWeeks,
              itemBuilder: (context, index) {
                final weekNumber = index + 1;
                final isSelected = weekNumber == selectedWeek;

                return ListTile(
                  leading: Icon(
                    Icons.date_range,
                    color: isSelected ? Colors.blue[700] : Colors.grey,
                  ),
                  title: Text(
                    l10n.translate(
                      'statistics_week_label',
                      params: {'week': weekNumber.toString()},
                    ),
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? Colors.blue[700] : Colors.black,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: Colors.blue[700])
                      : null,
                  tileColor: isSelected ? Colors.blue.withOpacity(0.1) : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onTap: () {
                    setState(() {
                      selectedWeek = weekNumber;
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.translate('common_cancel')),
            ),
          ],
        );
      },
    );
  }
}
