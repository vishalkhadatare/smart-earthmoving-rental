// Data models for Equipment Management App

class Equipment {
  final String id;
  final String name;
  final String type; // JCB, Excavator, Loader, etc
  final String imageUrl;
  final String status; // Available, Busy, Maintenance
  final String location;
  final double rentPerHour;
  final double rentPerDay;
  final String operatorName;
  final String operatorPhone;
  final List<String> specifications;
  final List<String> documents;
  final DateTime lastServiceDate;
  final String currentBookingId;

  Equipment({
    required this.id,
    required this.name,
    required this.type,
    required this.imageUrl,
    required this.status,
    required this.location,
    required this.rentPerHour,
    required this.rentPerDay,
    required this.operatorName,
    required this.operatorPhone,
    required this.specifications,
    required this.documents,
    required this.lastServiceDate,
    required this.currentBookingId,
  });
}

class Booking {
  final String id;
  final String machineId;
  final String machineName;
  final String clientName;
  final String clientPhone;
  final String clientEmail;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String status; // Upcoming, Active, Completed, Cancelled
  final double totalCost;
  final String workDescription;
  final bool isTimeTracked;

  Booking({
    required this.id,
    required this.machineId,
    required this.machineName,
    required this.clientName,
    required this.clientPhone,
    required this.clientEmail,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.status,
    required this.totalCost,
    required this.workDescription,
    required this.isTimeTracked,
  });
}

class Payment {
  final String id;
  final String clientName;
  final double amount;
  final DateTime date;
  final String status; // Paid, Pending
  final String description;
  final String bookingId;

  Payment({
    required this.id,
    required this.clientName,
    required this.amount,
    required this.date,
    required this.status,
    required this.description,
    required this.bookingId,
  });
}

class MaintenanceLog {
  final String id;
  final String equipmentId;
  final DateTime date;
  final String description;
  final double cost;
  final String status; // Completed, Pending

  MaintenanceLog({
    required this.id,
    required this.equipmentId,
    required this.date,
    required this.description,
    required this.cost,
    required this.status,
  });
}

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String companyName;
  final String role; // owner, contractor, operator
  final String profileImage;
  final String subscriptionPlan;
  final List<String> operatorIds;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.companyName,
    required this.role,
    required this.profileImage,
    required this.subscriptionPlan,
    required this.operatorIds,
  });
}

class DashboardMetrics {
  final int totalMachines;
  final int activeMachines;
  final int availableMachines;
  final int activeJobs;
  final double earningsToday;
  final double earningsWeekly;
  final double earningsMonthly;
  final double pendingPayments;

  DashboardMetrics({
    required this.totalMachines,
    required this.activeMachines,
    required this.availableMachines,
    required this.activeJobs,
    required this.earningsToday,
    required this.earningsWeekly,
    required this.earningsMonthly,
    required this.pendingPayments,
  });
}
