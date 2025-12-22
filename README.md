# 🎓 University Database Management System

A robust and aesthetically designed web-based system for managing university HR operations, academic workflows, and administrative tasks. This project digitizes the core functionalities of a university, including employee attendance, leave management, payroll processing, and student/staff administration.

**Course:** Databases I (CSEN501) - German University in Cairo  
---

## 🚀 Features

The system is divided into three role-based portals, each with specialized workflows:

### 1. 👔 HR Employee Portal
- **Leave Management:** Automated approval engine for Annual, Accidental, Unpaid, and Compensation leaves.
- **Payroll System:** Generate monthly payroll with automatic calculation of bonuses and deductions.
- **Attendance & Deductions:** Apply penalties for missing hours or days with a single click.
- **Dashboard:** Real-time analytics on active employees and pending requests.

### 2. 📚 Academic Employee Portal
- **Leave Requests:** Apply for various leave types (Medical, Annual, etc.) with validation.
- **Profile Management:** View personal data, schedule, and payroll history.
- **Performance:** Track academic performance and ratings.

### 3. 🛡️ Admin Portal
- **System Config:** Manage departments, roles, and official holidays.
- **User Management:** Add/Remove employees and manage access.

---

## 🛠️ Tech Stack

- **Frontend:** ASP.NET Core Razor Pages (HTML5, CSS3, Bootstrap 5)  
- **Backend:** C# (.NET 6/7/8)  
- **Database:** Microsoft SQL Server (T-SQL)  
- **Tools:** Visual Studio 2022, SQL Server Management Studio (SSMS)

---

🖼️ Sample Preview Images
<p align="center"> <img src="Sample Preview Images/1.png" width="700" /> <img src="Sample Preview Images/2.png" width="700" /> <img src="Sample Preview Images/3.png" width="700" /> <img src="Sample Preview Images/4.png" width="700" /> <img src="Sample Preview Images/5.png" width="700" /> <img src="Sample Preview Images/6.png" width="700" /> </p>

---

## 💻 Local Setup Guide

Follow these steps to get the project running on your machine.

### Prerequisites
- Visual Studio 2022 (with "ASP.NET and web development" workload installed)  
- SQL Server (Developer or Express edition)  
- SQL Server Management Studio (SSMS)  

### Step 1: Database Setup
1. Open SSMS and connect to your local server.  
2. Open the file `final_implementation.sql` located in the SQL folder (or root).  
3. Execute the script to create the database (`University_HR_ManagementSystem`) and all tables/procedures.  
4. Open `comprehensive_test_data.sql` and execute it to populate the database with test users and scenarios.

### Step 2: Configure Connection String
1. Open the project in Visual Studio.  
2. Open `appsettings.json`.  
3. Update the `DefaultConnection` string with your local server name:

```json
"ConnectionStrings": {
  "DefaultConnection": "Server=YOUR_SERVER_NAME;Database=University_HR_ManagementSystem;Trusted_Connection=True;TrustServerCertificate=True;"
}
