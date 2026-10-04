# AlienHR — Status & Completion Report

---

## 1. Quick Summary by Role

| Feature Area | 👤 Employee Role | 👔 Manager Role | 👑 Admin Role |
| :--- | :---: | :---: | :---: |
| **Authentication & Auto-Routing** | ✅ **100% Live** | ✅ **100% Live** | ✅ **100% Live** |
| **GPS Check-In / Check-Out** | ✅ **100% Live** | ❌ Missing UI | ❌ Missing UI |
| **Today's Attendance Status & Times** | ✅ **100% Live** | ❌ Missing UI | ❌ Missing UI |
| **Attendance History & Date Filter** | ✅ **100% Live** | ❌ Missing Team View | ❌ Missing Org View |
| **Leave Application (Live Types from DB)**| ✅ **100% Live** | ❌ Missing Self Leave | ❌ Missing Self Leave |
| **Leave History & Cancel Action** | ✅ **100% Live** | ❌ Missing Self View | ❌ Missing Self View |
| **Leave Approvals & Rejections** | N/A | ✅ **100% Live** | ✅ **100% Live** |
| **Employee Directory (View/Search)** | N/A | ❌ Missing | ✅ **100% Live** |
| **Employee Creation & Auto-Login** | N/A | N/A | ⚠️ **Partial** (Fixed IDs) |
| **Employee Delete (Soft Delete)** | N/A | N/A | ✅ **100% Live** |
| **Dashboard Metrics & Graphs** | ⚠️ Holiday is Mock | ❌ **100% Mock Data** | ❌ **100% Mock Data** |
| **Holidays Screen** | ❌ Missing | ❌ Missing | ❌ Missing |
| **Branch Management** | N/A | N/A | ❌ Missing |
| **Profile View** | ❌ Missing | ❌ Missing | ❌ Missing |

---

## 2. Employee Login

### ✅ What is Fully Completed
1. **Secure Login & Storage**:
   * Logs in against `POST /api/Authentication/login`.
   * Saves JWT token and user profile securely in [secure_storage.dart](lib/core/storage/secure_storage.dart).
   * Directs automatically to Employee Dashboard upon app launch.
2. **Live Attendance & GPS Geofencing**:
   * Captures high-accuracy GPS coordinates via device sensors.
   * Prompts confirmation dialog showing device Latitude and Longitude.
   * Calls `POST /api/Attendance/check-in` & `POST /api/Attendance/check-out` with employee ID and coordinates.
   * Backend validates that employee is within the branch's `GeofenceRadiusMeters`.
3. **Real-Time Attendance State Synchronization**:
   * Auto-fetches current day's record via `GET /api/Attendance/today`.
   * Automatically switches between **CHECK IN** (Violet), **CHECK OUT** (Crimson), and **COMPLETED** (Teal).
   * Displays live Check-in time, Check-out time, Worked hours (`Xh Ym`), and Overtime (`Xh Ym`).
4. **Attendance History**:
   * Fetches real records from `GET /api/Attendance/history`.
   * Filterable by Custom Date Range (`From Date` → `To Date`).
   * Displays daily breakdown: Date, Check-in/out times, Distance in meters from branch, Status badge (`Present`, `Late`, `Early Departure`, `OT`).
5. **Leave Management**:
   * **My Leave**: Fetches real leave history from `GET /api/Leave/employee/{id}` with live counts for *Pending*, *Approved*, and *Rejected*.
   * **Apply Leave**: Dynamically loads active leave types (Annual, Casual, Medical) from `GET /api/LeaveType`. Validates date ranges (skips Sundays, prevents past dates, checks overlaps).
   * **Cancel Leave**: Employees can cancel any of their own *Pending* leaves with one tap.

### ❌ What is Still Missing for Employee
* **Upcoming Holiday Card**: Shows hardcoded `'Sample Public Holiday - August 10, 2026'`.
* **Holidays Quick Action**: Tapping "Holidays" only shows a snackbar message.
* **My Profile Quick Action**: Tapping "My Profile" only shows a snackbar message.
* **Branch Name**: Hardcoded text `'Colombo Branch'`.

---

## 3. Manager Login

### ✅ What is Fully Completed
1. **Manager Authentication**:
   * Login correctly resolves Manager role (`RoleId == 2` or `"Manager"`).
   * Routes to [manager_dashboard.dart](lib/ui/home/manager/manager_dashboard.dart).
2. **Leave Approvals Module**:
   * Tapping **"Leave Approvals"** opens [manager_leave_page.dart](lib/ui/leave/manager/manager_leave_page.dart), which fetches real pending requests from `GET /api/Leave/pending`.
   * **Approve Leave**: Calls `PUT /api/Leave/{id}/approve` with manager's ID.
   * **Reject Leave**: Prompts dialog requiring a mandatory comment and calls `PUT /api/Leave/{id}/reject`.

### ❌ What is Still Missing / Mock for Manager
* **All Dashboard Cards are 100% Mock Data**:
  * Team count: `teamTotal = 25` (hardcoded).
  * Present today: `presentToday = 20` (hardcoded).
  * On Leave: `onLeaveToday = 3`, Absent: `2`, Pending: `5` (hardcoded).
  * "Who is on Leave Today": hardcoded names (*Kasun Perera*, *Amal Silva*, *Nimal Fernando*).
  * Weekly Attendance graph: hardcoded percentages (*Mon 92%, Tue 88%, Wed 94%, etc.*).
* **Missing Screens**:
  * "Team Attendance" button shows a snackbar.
  * "My Attendance" button shows a snackbar.
  * "Calendar" button shows a snackbar.

---

## 4. Admin Login & Admin Panel

### ✅ What is Fully Completed
1. **Admin Authentication**:
   * Login correctly resolves Admin role (`RoleId == 1` or `"Admin"`) and opens [admin_dashboard.dart](lib/ui/home/admin/admin_dashboard.dart).
2. **Employee Directory**:
   * Tapping **"Employees"** opens [employee_list_page.dart](lib/ui/employee/employee_list_page.dart).
   * Fetches real employees from `GET /api/Employee`.
   * Real-time search filter by Name or Employee Code.
   * Pull-to-refresh to reload from backend.
3. **Employee Details**:
   * Opens [employee_details_page.dart](lib/ui/employee/employee_details_page.dart) showing personal details, contact info, joined date, department, designation, branch, and active status.
4. **Soft Delete Employee**:
   * Calls `DELETE /api/Employee/{id}?deletedBy={adminId}` to soft-delete an employee with confirmation dialog.
5. **Leave Approvals for Admin**:
   * Admin can also view and approve/reject pending leaves through the linked approval screen.

---

### ⚠️ What is Still Missing or Using Mock Data in Admin Panel

#### A. 100% Hardcoded Dashboard Metrics
In [admin_dashboard.dart](lib/ui/home/admin/admin_dashboard.dart):
* **Organization Summary**:
  ```dart
  totalEmployees = 245;  // ❌ Hardcoded
  present = 218;         // ❌ Hardcoded
  onLeave = 12;          // ❌ Hardcoded
  absent = 15;           // ❌ Hardcoded
  ```
* **Needs Attention**:
  ```dart
  pendingLeave = 14;     // ❌ Hardcoded
  lateEmployees = 8;     // ❌ Hardcoded
  missingCheckOut = 5;   // ❌ Hardcoded
  ```
* **Today's Attendance Overview**:
  * Shows fixed 89% progress bar with hardcoded on-time / late statistics.

#### B. Employee Form Limitations ([employee_form_page.dart](lib/ui/employee/employee_form_page.dart))
* **Hardcoded Payload IDs**:
  ```dart
  companyId: 1,
  branchId: 1,
  designationId: 1,
  roleId: 4,
  ```
* **Empty Dropdown**: Department dropdown has `items: const []` because backend has no department endpoint.
* **Fixed Display Text**: Branch is fixed to `"Bandarawela"`, Designation is fixed to `"Sales Assistant"`, Role is fixed to `"Employee"`.

#### C. Unimplemented Admin Quick Actions
* **Attendance**: Tapping "Attendance" shows snackbar: *"Attendance screen will be added next."* (No company-wide attendance tracking screen).
* **Branches**: Tapping "Branches" shows snackbar: *"Branches screen will be added next."* (Backend has full `/api/Branch` CRUD, but mobile has no screen).

---

## 5. Master To-Do Checklist to 100% Complete the HRMS Mobile App

### Phase 2: Master Lookups & Employee Form Fix
* [ ] **Backend**: Expose `GET /api/Lookup/departments`, `GET /api/Lookup/designations`, and `GET /api/Lookup/employment-types`.
* [ ] **Flutter**: Create `LookupService` to dynamically populate Department, Designation, Branch, and Role dropdowns in [employee_form_page.dart](lib/ui/employee/employee_form_page.dart).

### Phase 3: Live Dashboard Metrics (Replace Mock Data)
* [ ] **Backend**: Add `GET /api/Dashboard/admin-summary` and `GET /api/Dashboard/manager-summary`.
* [ ] **Flutter**: Replace the hardcoded numbers in [admin_dashboard.dart](lib/ui/home/admin/admin_dashboard.dart) with live API metrics.
* [ ] **Flutter**: Replace team stats, who is on leave, and weekly graph in [manager_dashboard.dart](lib/ui/home/manager/manager_dashboard.dart) with live API data.

### Phase 4: Missing Feature Screens
* [ ] **Holidays Screen**:
  * Connect to existing `GET /api/Holiday` backend API.
  * Show upcoming holidays calendar screen.
  * Replace `'Sample Public Holiday'` on the Employee Dashboard with the real next holiday.
* [ ] **Employee Profile Screen**:
  * Build a clean self-profile screen for employees (view personal details, contact info, job role, and change password).
* [ ] **Branch Management Screen (Admin)**:
  * Connect to existing `GET /api/Branch` and allow admins to view branches and GPS geofence radius settings.
* [ ] **Company Attendance Monitor (Admin / Manager)**:
  * Screen allowing Admin/Manager to see today's present, late, and absent employees with real-time timestamps.
