# ALIENHR — MASTER DEVELOPMENT PLAN AND IMPLEMENTATION BACKLOG

**Project:** AlienHR — Complete Human Resource Management System  
**Development approach:** Backend-first, database-aware, incremental implementation  
**Backend:** ASP.NET Core Web API  
**Database:** PostgreSQL + Entity Framework Core  
**Mobile:** Flutter  
**Web:** Existing web application and frontend framework

---

# 1. PRIMARY OBJECTIVE

Complete the existing AlienHR system into a production-ready HRMS.

The system must support:

1. Company, branch and employee management.
2. Multiple managers per branch and managers assigned to multiple branches.
3. GPS-based employee check-in and check-out.
4. Missing attendance and manual correction approval workflows.
5. Automated daily attendance finalization.
6. Leave applications, balances and approvals.
7. Public holidays, company holidays and branch calendars.
8. Employee profiles and self-service.
9. Salary structures, payroll calculations and deductions.
10. Payroll approval, publication and payslips.
11. Manager and HR dashboards.
12. Attendance, leave, payroll and employee reports.
13. Notifications, audit logging and access control.
14. Automated testing, database migrations and deployment.

The final product must provide complete end-to-end functionality, not just frontend screens or API placeholders.

# 2. MANDATORY DEVELOPMENT RULES

Follow these rules throughout the project.

- Inspect the existing repository and database before modifying anything.
- Preserve working functionality and existing UI styles.
- Do not recreate existing tables, controllers, services or APIs unnecessarily.
- Do not invent database fields or relationships without inspecting the current schema.
- Use the existing architecture, naming conventions, authentication and dependency injection patterns.
- Use authenticated server-side identity to determine employee ownership.
- Enforce manager access by assigned branch on every applicable endpoint.
- Do not trust client-supplied employee IDs for authorization.
- Implement business rules in backend services, not only in frontend code.
- Use DTOs, validation, error handling and transactions consistently.
- Generate EF Core migrations only for verified schema changes.
- Never reset, drop or truncate production data to fix migration errors.
- Do not automatically run unreviewed migrations against production.
- Preserve existing attendance, leave and holiday records.
- Do not hardcode IDs, salary rules, branch IDs or role IDs when configuration or database relationships should be used.
- Never claim a build, migration or test succeeded unless the command actually succeeded.
- Do not implement multiple large phases simultaneously without validating each phase.
- Do not leave incomplete buttons, placeholder endpoints, hardcoded dashboards or mock production data.

# 3. PHASE 1 — COMPLETE PROJECT AUDIT

Before development, inspect the entire solution.

## Tasks

1. Identify every backend project, frontend project and mobile project.
2. Inspect the solution structure and project references.
3. Inspect PostgreSQL tables, columns, constraints, indexes and relationships.
4. Inspect EF Core entities, DbContext, mappings, repositories and migrations.
5. Inspect all controllers, services, DTOs and authorization policies.
6. Inspect Flutter screens, models, API clients and service classes.
7. Inspect web components, routing, guards, API services and UI conventions.
8. Identify all existing features and classify them as:
   - Complete and verified
   - Implemented but incomplete
   - Implemented but defective
   - Missing
9. Identify duplicate implementations, dead code and unsafe authorization.
10. Identify missing indexes, validations, tests and database constraints.
11. Document existing API routes and current request/response contracts.
12. Identify background workers and scheduled jobs already implemented.
13. Identify the current authentication mechanism and role claims.
14. Identify current employee-to-user and employee-to-branch relationships.
15. Produce a dependency-ordered development backlog.

## Required deliverables

- Architecture inventory.
- Database relationship map.
- Existing-feature versus missing-feature report.
- API inventory.
- Frontend screen inventory.
- Security gap report.
- Migration plan.
- Phase-by-phase implementation checklist.

Do not start speculative database changes until this audit is complete.

# 4. PHASE 2 — IDENTITY, COMPANY, BRANCH AND EMPLOYEE MANAGEMENT

## 4.1 Authentication and permissions

Verify and complete:

- Login and logout.
- Access-token validation.
- Refresh-token handling if supported.
- Password reset and change password.
- Authenticated user profile.
- Role and permission checks.
- Account activation and deactivation.
- Secure token storage in Flutter.
- Appropriate authentication error handling.

Preserve the current authentication implementation unless a specific defect requires a justified change.

## 4.2 Company management

Implement or complete:

- Company details.
- Company settings.
- Timezone and working-calendar settings.
- Payroll configuration defaults.
- Attendance cutoff settings.
- Company-wide policies where appropriate.

## 4.3 Branch management

Implement or complete:

- Create, edit, view and deactivate branches.
- Branch name, code, address and contact details.
- Latitude and longitude.
- Geofence radius in metres.
- Branch working days and holidays when applicable.
- Branch status and effective dates.
- Validation of GPS coordinates and radius.
- Branch assignment history.

Do not assume all branches share identical working hours or attendance rules.

## 4.4 Employee management

Provide a complete employee administration module.

Employee data should include the applicable existing fields for:

- Employee number.
- Personal information.
- Contact information.
- Employment status.
- Joining date and termination date.
- Department and designation.
- Employment type.
- Assigned branch.
- Manager or reporting relationship.
- Login account and role.
- Emergency contact and other permitted HR fields.

Tasks:

- Complete employee create, view, update and deactivate operations.
- Fix employee form lookup lists.
- Replace hardcoded department, designation, branch and employment-type IDs.
- Validate required fields and unique employee numbers.
- Provide employee search, filters and pagination.
- Support employee transfers between branches.
- Preserve historical attendance and payroll when an employee changes branches.
- Separate account deactivation from deleting employment history.

## 4.5 Manager-to-branch assignments

Requirements:

- A branch may have multiple managers.
- A manager may manage multiple branches.
- Managers can only view and operate within assigned branches.
- Assignments must support active/inactive status.
- Effective dates should be supported where historical authorization and reporting require them.
- Removing an assignment must not delete historical attendance or approvals.

If the current schema cannot represent these relationships, design a migration only after verifying the existing model.

# 5. PHASE 3 — GPS ATTENDANCE ENGINE

This is a critical module and must be fully verified before payroll development.

## 5.1 Employee check-in

When the employee selects Check In:

1. Identify the authenticated employee.
2. Retrieve the applicable branch assignment.
3. Confirm that the branch is active and eligible for attendance.
4. Obtain device GPS coordinates and reported accuracy.
5. Validate latitude and longitude.
6. Calculate the distance from the permitted branch location.
7. Compare the distance with the configured geofence radius and any documented accuracy policy.
8. Use the server to determine the official event timestamp.
9. Verify that the employee does not already have an active check-in.
10. Record the event, branch, coordinates, timestamp and validation details.
11. Return a clear success or failure response.

Do not rely on client-side distance calculations alone.

## 5.2 Employee check-out

Implement the equivalent server-side validations for Check Out.

- Require a valid attendance session.
- Prevent duplicate check-outs.
- Validate location according to the approved attendance policy.
- Calculate worked duration using server timestamps.
- Handle overnight shifts according to configured work schedules.
- Record the original check-out event.
- Return the recorded time and attendance status.

## 5.3 Attendance history

Employees must be able to view:

- Today's attendance.
- Check-in time.
- Check-out time.
- Total worked duration.
- Attendance status.
- Missing or incomplete attendance.
- Monthly calendar.
- Past attendance by date range.
- Holidays and leave.
- Manual correction requests and their status.

Managers need daily and monthly attendance views for their assigned branches.

## 5.4 Manual attendance correction

An employee who forgets to check out must be able to submit a correction request after the configured deadline.

The request should contain:

- Attendance date.
- Requested check-out time.
- Reason.
- Optional supporting evidence.
- Submission timestamp.
- Approval status.

Workflow:

1. Employee submits a request.
2. The system validates the attendance record and deadline.
3. The request enters a pending approval queue.
4. An authorized manager or HR user reviews it.
5. The reviewer approves or rejects it with a reason.
6. An approved correction updates the effective attendance result through a controlled transaction.
7. Original attendance events remain preserved.
8. The correction and approval are recorded in the audit trail.
9. Affected attendance summaries and draft payroll calculations are recalculated.

Configure the deadline explicitly. The business requirement is after 12:00 PM, but confirm whether that means the following day at noon or another company-defined cutoff. Do not hardcode an ambiguous interpretation.

## 5.5 Attendance finalization

Complete or enhance the existing background worker.

It must:

- Identify eligible attendance dates.
- Read the applicable work calendar.
- Process check-in/out records.
- Identify incomplete attendance.
- Calculate attendance status.
- Account for approved leave and holidays.
- Avoid duplicate daily summaries.
- Support safe retries.
- Record failures and provide operational logging.
- Recalculate affected dates when approved corrections or leave changes occur.

Do not automatically classify a holiday as absent or no-pay.

## 5.6 Attendance exception handling

Test and implement handling for:

- GPS disabled.
- Location permission denied.
- Poor GPS accuracy.
- Outside-geofence attempts.
- Duplicate requests.
- Network timeouts.
- Device retry after a successful request.
- Employee branch transfer.
- Missing check-out.
- Overnight shifts.
- Holiday and weekend attendance.
- Approved attendance correction.
- Unauthorized employee or branch access.

# 6. PHASE 4 — LEAVE MANAGEMENT

## 6.1 Leave configuration

Implement or complete:

- Leave types.
- Paid and unpaid classification.
- Annual entitlement.
- Balance calculation.
- Accrual and carry-forward where required.
- Partial-day leave if company policy supports it.
- Eligibility and approval configuration.
- Active/inactive leave types.

## 6.2 Employee leave centre

Employees must be able to:

- View leave balances.
- Submit a leave request.
- Apply for a single day or date range.
- Apply for same-day leave.
- Provide a reason and optional attachment.
- View pending, approved and rejected requests.
- Cancel a request according to policy.
- View approval comments and history.

## 6.3 Manager leave approval

Managers must be able to:

- View pending requests for assigned branches.
- Inspect employee and leave details.
- Check overlapping requests.
- Review leave balance and relevant attendance.
- Approve or reject with a reason.
- View historical decisions.

Prevent unauthorized approvals and duplicate balance deductions.

## 6.4 Leave integration

When leave is approved, rejected or cancelled:

- Recalculate the relevant leave balance.
- Recalculate affected attendance dates.
- Update draft payroll inputs.
- Preserve approval history.
- Notify relevant users.
- Ensure repeated processing does not duplicate leave transactions.

Employees may apply for leave after an absence. The final attendance and payroll treatment must follow the leave decision and company policy.

# 7. PHASE 5 — HOLIDAYS AND WORK CALENDARS

Implement or complete:

- Company-wide holidays.
- Public holidays.
- Branch-specific holidays.
- Weekly rest days.
- Special working days.
- Holiday overrides.
- Effective dates and active status.
- Calendar views and filters.
- Holiday creation, editing and deactivation.
- Audit history for holiday changes.

Integrate the work calendar with attendance finalization, leave calculation and payroll.

Rules:

- A holiday must not automatically create an absence deduction.
- A scheduled non-working day must be distinguished from a scheduled working day.
- Working on a holiday must be recorded and treated according to configured policy.
- Retroactive calendar changes must trigger controlled recalculation where necessary.

Do not hardcode the same calendar rules for every branch.

# 8. PHASE 6 — EMPLOYEE SELF-SERVICE FLUTTER APP

Preserve the current Flutter application architecture and styling.

## Required screens

1. Login.
2. Employee dashboard.
3. GPS check-in/check-out.
4. Today's attendance details.
5. Monthly attendance calendar.
6. Attendance history.
7. Manual attendance correction request.
8. Leave balance.
9. Apply leave.
10. Leave history and request status.
11. Employee profile.
12. Employment details.
13. Notification centre.
14. Salary history.
15. Monthly payslip.
16. Account settings.

## Dashboard

Display:

- Employee identity and branch.
- Today's attendance status.
- Check-in and check-out times.
- Worked duration.
- Leave balance.
- Pending leave requests.
- Attendance correction status.
- Latest published payslip.

## Mobile requirements

- Use real API responses instead of sample data.
- Use the existing authenticated API client.
- Use secure token storage.
- Handle expired tokens and unauthorized responses.
- Request location permission appropriately.
- Handle disabled GPS and poor connectivity.
- Prevent duplicate submissions.
- Display loading, empty, success and error states.
- Avoid exposing other employees' data.
- Keep existing working styles and navigation intact.

Connect the salary screens after the payroll APIs are implemented and verified.

# 9. PHASE 7 — SALARY STRUCTURE AND PAYROLL ENGINE

Payroll must be implemented as a dedicated backend module.

## 9.1 Salary structure management

Authorized HR or management users must be able to configure:

- Basic salary.
- Fixed allowances.
- Variable allowances.
- Overtime.
- Bonuses.
- Commissions.
- Other earnings.
- Fixed deductions.
- Percentage deductions.
- No-pay deductions.
- Applicable statutory deductions and contributions.
- Effective start and end dates.
- Payroll calculation policies.

Store salary changes with effective dates and audit information. Historical payslips must not change merely because the current salary structure changes.

## 9.2 Monthly attendance summary

For each employee and payroll period, calculate or retrieve:

- Calendar days.
- Scheduled working days.
- Actual worked days.
- Paid leave days.
- Unpaid leave days.
- Holidays.
- Weekly rest days.
- Unauthorized absences.
- Incomplete attendance requiring resolution.
- Approved overtime or additional work.
- Other payroll-relevant attendance values.

Avoid double counting days that overlap with leave, holidays or non-working days.

## 9.3 Payroll calculation

Create a deterministic, testable payroll calculation service.

It must:

1. Validate the payroll period.
2. Resolve eligible employees.
3. Resolve salary structures effective for that period.
4. Validate finalized attendance and approved leave.
5. Identify missing or conflicting data.
6. Calculate payable days.
7. Calculate basic salary payable.
8. Calculate allowances and variable earnings.
9. Calculate overtime and bonuses where applicable.
10. Calculate no-pay deductions according to the configured divisor and policy.
11. Calculate other authorized deductions.
12. Calculate applicable statutory items using verified, configurable rules.
13. Apply currency precision and rounding.
14. Calculate gross earnings, total deductions and net salary.
15. Store itemized payroll lines and calculation inputs.
16. Provide a preview and exception report.
17. Permit authorized draft recalculation.
18. Prevent duplicate payroll processing for the same employee and period.

Do not assume every organization uses a 30-day divisor. Support the approved policy explicitly.

## 9.4 Payroll example

Use the following only as a calculation test fixture:

- Basic salary: LKR 80,000.
- Allowances: LKR 12,000.
- Gross earnings: LKR 92,000.
- No-pay deduction: LKR 3,000.
- Other deductions: LKR 2,000.
- Net salary: LKR 87,000.

Verify that the calculation engine produces the expected results when given these inputs.

## 9.5 No-pay and holiday rules

- Holidays must not create automatic no-pay deductions solely because the employee did not check in.
- Paid leave must not be treated as unpaid leave.
- Unpaid leave must follow the applicable company-approved deduction formula.
- Weekends and rest days must follow the configured calendar.
- Approved attendance corrections must update draft payroll inputs.
- Payroll calculation must flag unresolved attendance exceptions.
- Changes after publication must use controlled adjustments rather than silently overwriting historical payroll.

## 9.6 Sri Lankan payroll support

Provide configurable support for applicable:

- EPF.
- ETF.
- APIT and other relevant tax requirements.
- Other company-authorized statutory or contractual deductions.

Verify current legal rates, eligibility, calculation bases and employer/employee responsibilities with the authorized payroll professional before production deployment.

# 10. PHASE 8 — PAYROLL APPROVAL AND PAYSLIPS

Implement the full payroll lifecycle.

1. Draft.
2. Calculated.
3. Under Review.
4. Approved.
5. Published.
6. Cancelled, where permitted.

## Payroll management screens

- Payroll period selection.
- Employee payroll register.
- Working-day summary.
- Attendance exception list.
- Earnings and deductions editor.
- Calculation preview.
- Payroll totals and reconciliation.
- Submit for approval.
- Approve or reject.
- Publish payslips.
- Payroll history.
- Controlled adjustments.
- Audit trail.

A manager may prepare payroll for authorized branches if granted permission. Separate preparation and approval permissions where required.

## Employee payslip

Display:

- Employee information.
- Payroll month.
- Basic salary.
- Earnings and allowances.
- Working days.
- Worked days.
- Paid leave.
- Unpaid leave.
- Holidays.
- Absences.
- Overtime.
- Bonuses.
- Deductions.
- Gross earnings.
- Total deductions.
- Net salary.
- Approval and publication details.

Employees can only access their own published payslips.

# 11. PHASE 9 — MANAGER PORTAL

Complete or add the following screens using the existing web architecture.

## Manager dashboard

- Assigned branch selector.
- Total assigned employees.
- Present employees.
- Absent employees.
- Employees on leave.
- Late arrivals.
- Missing check-outs.
- Pending leave approvals.
- Pending attendance corrections.
- Payroll preparation status.

## Employee operations

- Employee directory.
- Employee detail page.
- Daily attendance register.
- Monthly attendance history.
- Attendance exception management.
- Leave request review.
- Approval history.
- Branch calendar.
- Permitted salary and payroll views.

## Payroll workspace

- Select payroll period.
- Select authorized branch.
- Review eligible employees.
- Review attendance and leave day counts.
- Review salary components.
- Add permitted variable earnings or deductions.
- Enter reasons for adjustments.
- Recalculate drafts.
- Review exceptions.
- Submit payroll for approval.
- View approval status.

Do not allow branch managers to see unassigned branch data or sensitive salary information without explicit permission.

# 12. PHASE 10 — ADMIN / HR PORTAL

Complete the following modules.

## Organization

- Company settings.
- Branch administration.
- Geofence configuration.
- Department and designation lookups.
- Employment types.
- Employee lifecycle.
- Manager assignments.
- Roles and permissions.

## HR operations

- Employee directory.
- Employee profiles.
- Branch transfers.
- Attendance exception management.
- Leave configuration and approval oversight.
- Holiday management.
- Work calendars and attendance cutoff policies.
- Employee document handling if required by the existing design.

## Payroll administration

- Salary structures.
- Salary component definitions.
- Effective-dated salary changes.
- Payroll period configuration.
- Payroll review and approval.
- Payroll publication.
- Historical payroll.
- Controlled payroll corrections.
- Payroll reconciliation.

## System administration

- Audit log.
- Notification delivery status.
- Failed background-job monitoring.
- User access review.
- Configuration validation.
- Operational health status.

# 13. PHASE 11 — REPORTS AND DASHBOARDS

Implement reports with server-side filtering and pagination.

## Attendance reports

- Daily attendance.
- Monthly attendance.
- Employee attendance history.
- Branch attendance summary.
- Absentee report.
- Late arrivals.
- Early departures if applicable.
- Missing check-outs.
- Manual correction requests.
- Attendance exceptions.

## Leave reports

- Leave requests by status.
- Leave balance report.
- Leave taken by employee.
- Leave taken by branch.
- Paid and unpaid leave totals.
- Leave approval history.
- Leave trends.

## Payroll reports

- Monthly payroll register.
- Employee payslip summary.
- Branch payroll summary.
- Gross earnings.
- Allowances and bonuses.
- Deduction totals.
- No-pay deductions.
- Statutory totals.
- Net salary payable.
- Payroll run reconciliation.
- Payroll adjustments.

## Employee reports

- Active and inactive employees.
- Employee headcount by branch.
- Department and designation distribution.
- Employment type distribution.
- Employee transfers and status history.

Reports must reconcile with the underlying records. Provide CSV or Excel exports where useful and ensure exports follow the same authorization rules as the screens.

# 14. PHASE 12 — NOTIFICATIONS AND BACKGROUND JOBS

Use the existing background-worker architecture where suitable.

Implement or complete:

- Daily attendance finalization.
- Missing-checkout detection.
- Pending approval reminders.
- Leave decision notifications.
- Attendance correction decision notifications.
- Payroll preparation reminders.
- Payroll publication notifications.
- Failed notification retry.
- Leave accrual processing if required.
- Payroll period validation.

Requirements:

- All jobs must be safe to retry.
- Avoid duplicate attendance summaries and notifications.
- Log errors with sufficient operational context.
- Provide monitoring for failed jobs.
- Respect the company timezone.
- Do not publish payroll automatically without the required approval.
- Do not make business-critical decisions based solely on a scheduled job when approval is required.

# 15. PHASE 13 — API CONTRACT AND SECURITY

Inspect existing endpoints before adding new routes.

Complete APIs for:

- Authentication.
- Employees.
- Branches.
- Manager and employee assignments.
- Attendance.
- Attendance correction requests.
- Leave requests and approvals.
- Holidays and work calendars.
- Salary structures.
- Payroll runs and calculations.
- Payroll approval and publication.
- Payslips.
- Reports.
- Notifications.
- Audit history.

For every API:

1. Define request and response DTOs.
2. Validate inputs.
3. Enforce authentication and permissions.
4. Enforce employee ownership and branch scope.
5. Apply transactions where multiple records change.
6. Return consistent status codes and error responses.
7. Add structured logging.
8. Add integration tests.
9. Update API documentation.
10. Avoid exposing confidential database fields.

Test attempts to access other employees, other branches and unauthorized salary records by manipulating request identifiers.

# 16. PHASE 14 — DATABASE MIGRATIONS

For each required schema change:

1. Inspect the current entity and database schema.
2. Identify the exact change required.
3. Update the entity, mapping and related service.
4. Generate a named EF Core migration.
5. Review the generated migration.
6. Generate SQL for inspection.
7. Back up the development database.
8. Apply the migration to a development database.
9. Verify the existing data.
10. Run application and integration tests.
11. Document the migration and recovery plan.
12. Apply to staging after approval.
13. Apply to production only through the approved deployment process.

Use the actual solution paths discovered during Phase 1.

Example commands, adjusting paths to the real repository:

    dotnet restore
    dotnet build
    dotnet ef migrations list --project HRMS.API --startup-project HRMS.API
    dotnet ef migrations add AddVerifiedFeature --project HRMS.API --startup-project HRMS.API
    dotnet ef migrations script --project HRMS.API --startup-project HRMS.API --output migration.sql

Do not run a speculative migration simply because the example command is provided.

# 17. PHASE 15 — AUTOMATED TESTING

Create or extend unit tests and integration tests.

## Backend tests

- Employee CRUD.
- Role and branch authorization.
- GPS distance calculation.
- Valid and invalid check-in.
- Valid and invalid check-out.
- Duplicate attendance requests.
- Manual correction approval.
- Daily attendance finalization.
- Leave balances.
- Leave approval and cancellation.
- Holiday and weekend handling.
- Salary calculation.
- No-pay deductions.
- Overtime and allowances.
- Payroll approval and publication.
- Historical payslip integrity.
- Transaction rollback.
- Concurrent requests.
- Migration upgrades.

## Flutter tests

- Login and session handling.
- GPS permissions.
- Location errors.
- Check-in/out API integration.
- Attendance history.
- Leave request submission.
- Approval status.
- Profile and payslip screens.
- Loading, empty and error states.

## Web tests

- Role-based navigation.
- Employee forms.
- Branch assignments.
- Attendance tables.
- Leave approvals.
- Payroll preview and editing.
- Approval workflows.
- Report filters and exports.

## End-to-end scenarios

Test the complete journey:

1. Admin creates an employee.
2. Admin assigns a branch.
3. Employee logs in.
4. Employee checks in and checks out.
5. Attendance is finalized.
6. Employee submits leave.
7. Manager approves leave.
8. Attendance reflects the approved leave.
9. HR prepares payroll.
10. The payroll engine calculates the monthly salary.
11. Authorized management approves and publishes payroll.
12. Employee views the payslip.
13. HR verifies that reports reconcile.

# 18. PHASE 16 — DEPLOYMENT AND PRODUCTION READINESS

Prepare:

- Development, staging and production configurations.
- Secure secrets and database credentials.
- Production database backups.
- Verified restore procedures.
- Reviewed database migration scripts.
- HTTPS and secure token handling.
- API health checks.
- Structured logs and error monitoring.
- Background-job monitoring.
- Flutter release configuration.
- Database access restrictions.
- Data retention and audit policies.
- Payroll reconciliation and sign-off.
- Pilot deployment to one branch.
- Rollback and incident-response procedures.
- Deployment and maintenance documentation.

Never use development credentials or sample payroll data in production.

# 19. DEFINITION OF DONE

A feature is complete only when:

- The backend implementation is finished.
- Required database changes are migrated and verified.
- The frontend uses the real API.
- Role and branch permissions are enforced.
- Validation and error handling are implemented.
- Automated tests have run and their results are recorded.
- Existing working functionality has passed regression checks.
- The UI supports loading, empty, success and error states.
- Audit records exist for important actions.
- Documentation is updated.
- No placeholder implementation remains in the completed scope.

# 20. ANTIGRAVITY EXECUTION INSTRUCTIONS

Work autonomously within the reviewed scope, but do not make destructive or high-impact changes without review.

For every phase:

1. Read the relevant files before editing.
2. Prepare a short implementation plan.
3. Identify the exact files and database objects affected.
4. Implement the phase in small logical changes.
5. Run backend builds and relevant tests.
6. Run Flutter or web builds for affected applications.
7. Verify migrations against the development database.
8. Review source changes for unintended modifications.
9. Fix failures before proceeding.
10. Update the project backlog with actual status.
11. Report completed work, changed files, migration names, test results and remaining blockers.

Maintain a project implementation document and update it after each verified phase. Keep a separate list of unimplemented requirements and known defects.

Do not mark a feature complete because its code was generated. Mark it complete only after the acceptance criteria have been verified.

## START NOW

Begin Phase 1.

Inspect the complete AlienHR repository, existing PostgreSQL schema, migrations, authentication, attendance, leave, holiday, Flutter application and web frontend.

Produce the initial audit report and ordered implementation backlog.

After the audit, proceed to Phase 2 and continue through the remaining phases in dependency order. Preserve existing working code and stop when a blocker requires a decision.

Do not claim the complete HRMS is finished until every applicable definition-of-done criterion and end-to-end acceptance scenario has passed.