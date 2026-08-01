<%@ Page Title="Admin Dashboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="Atelier.Admin.Dashboard" %>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>.admin-wrapper {display: flex; min-height: calc(100vh - 120px);
        }
        .admin-sidebar {
            width: 220px;
            background-color: #4A1020;
            padding: 24px 0;
            flex-shrink: 0;
        }
        .admin-sidebar h3 {
            color: #FFFFFF;
            font-size: 13px;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            padding: 0 20px;
            margin-bottom: 12px;
        }
        .admin-sidebar a {
            display: block;
            padding: 10px 20px;
            color: rgba(191,207,232,0.75);
            font-size: 14px;
            text-decoration: none;
        }
        .admin-sidebar a:hover,
        .admin-sidebar a.active {
            background-color: #6B1A2A;
            color: #BFCFE8;
            text-decoration: none;
        }
        .admin-main {
            flex: 1;
            padding: 32px 40px;
            background-color: #F0F4F9;
        }
        .admin-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 32px;
        }
        .chart-container {
            background-color: #FFFFFF;
            border: 0.5px solid #E8E0E2;
            border-radius: 16px;
            padding: 24px;
            margin-top: 24px;
        }
        .chart-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 24px;
            margin-top: 24px;
        } 

    </style>
</asp:Content>
<asp:Content ID="MainContent" 
    ContentPlaceHolderID="MainContent" 
    runat="server">

    <div class="admin-wrapper">

        <%-- SIDEBAR --%>
        <div class="admin-sidebar">
            <h3>Admin Panel</h3>
            <a href="~/Admin/Dashboard.aspx" runat="server" class="active">Dashboard</a>
            <a href="~/Admin/ManageCourses.aspx" runat="server">Manage Courses</a>
            <a href="~/Admin/ManageModules.aspx" runat="server">Manage Modules</a>
            <a href="~/Admin/ManageUsers.aspx" runat="server">Manage Users</a>
            <a href="~/Admin/ManageAssessments.aspx" runat="server">Assessments</a>
            <a href="~/Admin/ManageForum.aspx" runat="server">Forum</a>
            <a href="~/Admin/Announcements.aspx" runat="server">Announcements</a>
            <a href="~/Admin/ViewEnrollments.aspx" runat="server">Enrollments</a>
            <a href="~/Admin/GuestInquiries.aspx" runat="server">Guest Inquiries</a>
            <a href="~/Admin/Analytics.aspx" runat="server">Analytics</a>
            <a href="~/Logout.aspx" runat="server">Sign Out</a>
        </div>

        <div class="admin-main">

            <div class="admin-header">
                <div>
                    <h2>Dashboard</h2>
                    <p class="text-muted">
                        Welcome back,
                        <asp:Label ID="lblAdminName" 
                            runat="server"/>
                    </p>
                </div>
                <p class="text-muted text-sm">
                    <%= DateTime.Now.ToString(
                        "dddd, dd MMMM yyyy") %>
                </p>
            </div>

            <div class="grid-stats" 
                 style="margin-bottom:24px;display:grid;grid-template-columns:repeat(auto-fit, minmax(210px, 1fr));gap:20px;">
                <div class="stat-card" style="max-width:280px;margin:0 auto;width:100%;display:flex;flex-direction:column;align-items:center;padding:20px;">
                    <div style="width:44px;height:44px;border-radius:12px;background:rgba(107,26,42,0.08);color:#6B1A2A;display:flex;align-items:center;justify-content:center;margin-bottom:10px;">
                        <svg width="22" height="22" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                    </div>
                    <div class="stat-number">
                        <asp:Label ID="lblTotalUsers" runat="server" Text="0"/>
                    </div>
                    <div class="stat-label">Total Registered Users</div>
                </div>
                <div class="stat-card" style="max-width:280px;margin:0 auto;width:100%;display:flex;flex-direction:column;align-items:center;padding:20px;">
                    <div style="width:44px;height:44px;border-radius:12px;background:rgba(107,26,42,0.08);color:#6B1A2A;display:flex;align-items:center;justify-content:center;margin-bottom:10px;">
                        <svg width="22" height="22" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
                    </div>
                    <div class="stat-number">
                        <asp:Label ID="lblTotalCourses" runat="server" Text="0"/>
                    </div>
                    <div class="stat-label">Active Courses</div>
                </div>
                <div class="stat-card" style="max-width:280px;margin:0 auto;width:100%;display:flex;flex-direction:column;align-items:center;padding:20px;">
                    <div style="width:44px;height:44px;border-radius:12px;background:rgba(45,106,79,0.08);color:#2D6A4F;display:flex;align-items:center;justify-content:center;margin-bottom:10px;">
                        <svg width="22" height="22" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                    </div>
                    <div class="stat-number">
                        <asp:Label ID="lblTotalEnrollments" runat="server" Text="0"/>
                    </div>
                    <div class="stat-label">Total Enrollments</div>
                    <div style="font-size:12px;color:#2D6A4F;margin-top:4px">
                        <asp:Label ID="lblMonthlyTrend" runat="server"/>
                    </div>
                </div>
                <div class="stat-card" style="max-width:280px;margin:0 auto;width:100%;display:flex;flex-direction:column;align-items:center;padding:20px;">
                    <div style="width:44px;height:44px;border-radius:12px;background:rgba(180,83,9,0.08);color:#B45309;display:flex;align-items:center;justify-content:center;margin-bottom:10px;">
                        <svg width="22" height="22" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg>
                    </div>
                    <div class="stat-number">
                        <asp:Label ID="lblTotalRevenue" runat="server" Text="RM0"/>
                    </div>
                    <div class="stat-label">Total Revenue</div>
                </div>
            </div>
                <div style="background:#FFFFFF;
                            border:0.5px solid #E8E0E2;
                            border-radius:16px;
                            padding:24px;
                            margin-bottom:24px">
                    <h3 style="margin-bottom:16px;
                               color:#6B1A2A">
                        Needs Attention
                    </h3>
                    <asp:Label ID="lblNoAlerts" 
                        runat="server"
                        Text="No alerts — everything is up to date!"
                        Visible="false"
                        style="color:#2D6A4F;font-size:14px"/>
                    <asp:Repeater ID="rptAlerts" 
                        runat="server">
                        <ItemTemplate>
                            <div style="display:flex;
                                        align-items:center;
                                        gap:12px;
                                        padding:10px 0;
                                        border-bottom:
                                        0.5px solid #E8E0E2">
                                <span class='<%# Eval("CssClass") %>'>
                                    <%# Eval("Count") %>
                                </span>
                                <span style="font-size:14px">
                                    <%# Eval("Message") %>
                                </span>
                                <a href='<%# ResolveUrl(Eval("Link").ToString()) %>'
                                   style="margin-left:auto;
                                          font-size:13px;
                                          color:#6B1A2A;
                                          text-decoration:none">
                                    View →
                                </a>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

            <div class="chart-row">
                <div class="chart-container">
                    <h3 style="margin-bottom:16px">
                        Enrollments by Course
                    </h3>
                    <canvas id="enrolmentChart">
                    </canvas>
                </div>
                <div class="chart-container">
                    <h3 style="margin-bottom:16px">
                        Users by Role
                    </h3>
                    <canvas id="userChart">
                    </canvas>
                </div>
            </div>

            <div class="chart-container" 
                 style="margin-top:24px">
                <h3 style="margin-bottom:16px">
                    Recent Enrollments
                </h3>
                <table>
                    <tr>
                        <th>Learner</th>
                        <th>Course</th>
                        <th>Date</th>
                        <th>Progress</th>
                    </tr>
                    <asp:Repeater ID="rptEnrollments" 
                        runat="server">
                        <ItemTemplate>
                            <tr>
                                <td><%# Eval("FullName") %></td>
                                <td><%# Eval("Title") %></td>
                                <td><%# Eval("EnrolledAt", "{0:dd MMM yyyy}") %></td>
                                <td><%# Eval("Progress") %>%</td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </table>
            </div>

        </div>
    </div>

    <script type="text/javascript">
        var enrolmentData = <%= EnrolmentChartData %>;
        var userData = <%= UserChartData %>;

        new Chart(
            document.getElementById('enrolmentChart'), {
            type: 'bar',
            data: {
                labels: enrolmentData.labels,
                datasets: [{
                    label: 'Enrollments',
                    data: enrolmentData.data,
                    backgroundColor: '#6B1A2A',
                    borderRadius: 6
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: { display: false }
                }
            }
        });

        new Chart(
            document.getElementById('userChart'), {
            type: 'doughnut',
            data: {
                labels: userData.labels,
                datasets: [{
                    data: userData.data,
                    backgroundColor: [
                        '#6B1A2A', '#BFCFE8']
                }]
            },
            options: { responsive: true }
        });
    </script>

</asp:Content>

