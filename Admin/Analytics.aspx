<%@ Page Title="Analytics" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Analytics.aspx.cs" Inherits="Atelier.Admin.Analytics" %>
<asp:Content ID="HeadContent" 
    ContentPlaceHolderID="HeadContent" 
    runat="server">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .admin-wrapper { display:flex; min-height:calc(100vh - 120px); }
        .admin-sidebar { width:220px; background-color:#4A1020; padding:24px 0; flex-shrink:0; }
        .admin-sidebar h3 { color:#BFCFE8; font-size:13px; text-transform:uppercase; letter-spacing:0.08em; padding:0 20px; margin-bottom:12px; }
        .admin-sidebar a { display:block; padding:10px 20px; color:rgba(191,207,232,0.75); font-size:14px; text-decoration:none; }
        .admin-sidebar a:hover, .admin-sidebar a.active { background-color:#6B1A2A; color:#BFCFE8; text-decoration:none; }
        .admin-main { flex:1; padding:32px 40px; background-color:#F0F4F9; }
        .page-header { display:flex; align-items:center; justify-content:space-between; margin-bottom:24px; }
        .chart-card { background:#FFFFFF; border:0.5px solid #E8E0E2; border-radius:16px; padding:24px; margin-bottom:24px; }
        .chart-grid { display:grid; grid-template-columns:1fr 1fr; gap:24px; margin-bottom:24px; }
        .stat-row { display:grid; grid-template-columns:repeat(4,1fr); gap:16px; margin-bottom:24px; }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
        <div class="admin-wrapper">
        <div class="admin-sidebar">
            <h3>Admin Panel</h3>
            <a href="~/Admin/Dashboard.aspx" runat="server">Dashboard</a>
            <a href="~/Admin/ManageCourses.aspx" runat="server">Manage Courses</a>
            <a href="~/Admin/ManageModules.aspx" runat="server">Manage Modules</a>
            <a href="~/Admin/ManageUsers.aspx" runat="server">Manage Users</a>
            <a href="~/Admin/ManageAssessments.aspx" runat="server">Assessments</a>
            <a href="~/Admin/ManageForum.aspx" runat="server">Forum</a>
            <a href="~/Admin/Announcements.aspx" runat="server">Announcements</a>
            <a href="~/Admin/ViewEnrolments.aspx" runat="server">Enrollments</a>
            <a href="~/Admin/GuestInquiries.aspx" runat="server">Guest Inquiries</a>
            <a href="~/Admin/Analytics.aspx" runat="server" class="active">Analytics</a>
            <a href="~/Logout.aspx" runat="server">Sign Out</a>
        </div>

        <div class="admin-main">
            <div class="page-header">
                <h2>Analytics</h2>
                <asp:Button ID="btnExport"
                    runat="server"
                    Text="Export Report CSV"
                    CssClass="btn btn-secondary"
                    OnClick="btnExport_Click"
                    CausesValidation="false"/>
            </div>

                    <div class="stat-row">
                        <div class="stat-card">
                            <div class="stat-number">
                                <asp:Label ID="lblTotalUsers" runat="server" Text="0"/>
                            </div>
                            <div class="stat-label">Total Users</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-number">
                                <asp:Label ID="lblTotalEnrollments" runat="server" Text="0"/>
                            </div>
                            <div class="stat-label">Total Enrollments</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-number">
                                <asp:Label ID="lblCompletionRate" runat="server" Text="0%"/>
                            </div>
                            <div class="stat-label">Completion Rate</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-number">
                                <asp:Label ID="lblTotalRevenue" runat="server" Text="RM0"/>
                            </div>
                            <div class="stat-label">Total Revenue</div>
                        </div>
                    </div>
            <div class="chart-grid">
                <div class="chart-card">
                    <h3 style="margin-bottom:16px">
                        Enrollments by Course
                    </h3>
                    <canvas id="courseChart"></canvas>
                </div>
                <div class="chart-card">
                    <h3 style="margin-bottom:16px">
                        Users by Role
                    </h3>
                    <canvas id="roleChart"></canvas>
                </div>
            </div>

            <div class="chart-card">
                <h3 style="margin-bottom:16px">
                    Average Progress by Course
                </h3>
                <canvas id="progressChart"></canvas>
            </div>

            <div class="chart-card">
                <h3 style="margin-bottom:16px">
                    Top Performing Learners
                </h3>
                <asp:GridView ID="gvTopLearners"
                    runat="server"
                    AutoGenerateColumns="false"
                    EmptyDataText="No data yet."
                    CssClass="table">
                    <Columns>
                        <asp:BoundField DataField="FullName" HeaderText="Learner"/>
                        <asp:BoundField DataField="Email" HeaderText="Email"/>
                        <asp:BoundField DataField="CoursesEnrolled" HeaderText="Courses Enrolled"/>
                        <asp:BoundField DataField="CoursesCompleted" HeaderText="Completed"/>
                        <asp:BoundField DataField="AvgProgress" HeaderText="Avg Progress"/>
                    </Columns>
                </asp:GridView>
            </div>

        </div>
    </div>

    <script type="text/javascript">
        var courseData = <%= CourseChartData %>;
        var roleData = <%= RoleChartData %>;
var progressData = <%= ProgressChartData %>;

new Chart(document.getElementById('courseChart'), {
    type: 'bar',
    data: {
        labels: courseData.labels,
        datasets: [{
            label: 'Enrollments',
            data: courseData.data,
            backgroundColor: '#6B1A2A',
            borderRadius: 6
        }]
    },
    options: {
        responsive: true,
        plugins: { legend: { display: false } }
    }
});

new Chart(document.getElementById('roleChart'), {
    type: 'doughnut',
    data: {
        labels: roleData.labels,
        datasets: [{
            data: roleData.data,
            backgroundColor: ['#6B1A2A', '#BFCFE8']
        }]
    },
    options: { responsive: true }
});

new Chart(document.getElementById('progressChart'), {
    type: 'bar',
    data: {
        labels: progressData.labels,
        datasets: [{
            label: 'Avg Progress (%)',
            data: progressData.data,
            backgroundColor: '#BFCFE8',
            borderRadius: 6
        }]
    },
    options: {
        responsive: true,
        scales: {
            y: { max: 100, min: 0 }
        },
        plugins: { legend: { display: false } }
    }
        });
    </script>

</asp:Content>
