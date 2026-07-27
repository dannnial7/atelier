<%@ Page Title="View Enrollments" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ViewEnrollments.aspx.cs" Inherits="Atelier.Admin.ViewEnrollments" %>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .admin-wrapper { display:flex; min-height:calc(100vh - 120px); }
        .admin-sidebar { width:220px; background-color:#4A1020; padding:24px 0; flex-shrink:0; }
        .admin-sidebar h3 { color:#BFCFE8; font-size:13px; text-transform:uppercase; letter-spacing:0.08em; padding:0 20px; margin-bottom:12px; }
        .admin-sidebar a { display:block; padding:10px 20px; color:rgba(191,207,232,0.75); font-size:14px; text-decoration:none; }
        .admin-sidebar a:hover, .admin-sidebar a.active { background-color:#6B1A2A; color:#BFCFE8; text-decoration:none; }
        .admin-main { flex:1; padding:32px 40px; background-color:#F0F4F9; }
        .page-header { display:flex; align-items:center; justify-content:space-between; margin-bottom:24px; }
        .table-panel { background:#FFFFFF; border:0.5px solid #E8E0E2; border-radius:16px; padding:24px; }
        .filter-bar { display:flex; gap:12px; margin-bottom:16px; flex-wrap:wrap; }
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
            <a href="~/Admin/ViewEnrollments.aspx" runat="server" class="active">Enrollments</a>
            <a href="~/Admin/GuestInquiries.aspx" runat="server">Guest Inquiries</a>
            <a href="~/Admin/Analytics.aspx" runat="server">Analytics</a>
            <a href="~/Logout.aspx" runat="server">Sign Out</a>
        </div>

        <div class="admin-main">
            <div class="page-header">
                <h2>View Enrollments</h2>
                <asp:Button ID="btnExportCSV"
                    runat="server"
                    Text="Export to CSV"
                    CssClass="btn btn-secondary"
                    OnClick="btnExportCSV_Click"
                    CausesValidation="false"/>
            </div>

            <asp:Label ID="lblMessage"
                runat="server"
                Visible="false"
                style="display:block;margin-bottom:16px"/>

            <div class="table-panel">
                <div class="filter-bar">
                    <asp:DropDownList ID="ddlCourseFilter"
                        runat="server"
                        AutoPostBack="true"
                        OnSelectedIndexChanged="ddlCourseFilter_Changed"
                        style="padding:6px 12px;border:0.5px solid #E8E0E2;border-radius:8px;font-size:14px"/>
                    <asp:DropDownList ID="ddlProgressFilter"
                        runat="server"
                        AutoPostBack="true"
                        OnSelectedIndexChanged="ddlProgressFilter_Changed"
                        style="padding:6px 12px;border:0.5px solid #E8E0E2;border-radius:8px;font-size:14px">
                        <asp:ListItem Value="All">All Progress</asp:ListItem>
                        <asp:ListItem Value="NotStarted">Not Started (0%)</asp:ListItem>
                        <asp:ListItem Value="InProgress">In Progress</asp:ListItem>
                        <asp:ListItem Value="Completed">Completed (100%)</asp:ListItem>
                    </asp:DropDownList>
                    <asp:Button ID="btnReset"
                        runat="server"
                        Text="Reset"
                        CssClass="btn btn-secondary"
                        OnClick="btnReset_Click"
                        CausesValidation="false"/>
                </div>

                <h3 style="margin-bottom:16px">
                    All Enrollments
                    <span class="badge badge-info" style="margin-left:8px">
                        <asp:Label ID="lblCount" runat="server" Text="0"/>
                    </span>
                </h3>

                <asp:GridView ID="gvEnrollments"
                    runat="server"
                    AutoGenerateColumns="false"
                    EmptyDataText="No enrollments found."
                    CssClass="table">
                    <Columns>
                        <asp:BoundField DataField="EnrollmentID" HeaderText="ID"/>
                        <asp:BoundField DataField="FullName" HeaderText="Learner"/>
                        <asp:BoundField DataField="Email" HeaderText="Email"/>
                        <asp:BoundField DataField="CourseTitle" HeaderText="Course"/>
                        <asp:BoundField DataField="EnrolledAt" HeaderText="Enrolled" DataFormatString="{0:dd MMM yyyy}"/>
                        <asp:TemplateField HeaderText="Progress">
                            <ItemTemplate>
                                <div class="progress">
                                    <div class="progress-fill" 
                                         style='<%# string.Format("width:{0}%", Eval("Progress")) %>'>
                                    </div>
                                </div>
                                <span style="font-size:12px;color:#5A3A42">
                                    <%# Eval("Progress") %>%
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <span class='<%# Convert.ToInt32(Eval("Progress")) == 100 ? "badge badge-success" : Convert.ToInt32(Eval("Progress")) == 0 ? "badge badge-warning" : "badge badge-info" %>'>
                                    <%# Convert.ToInt32(Eval("Progress")) == 100 ? "Completed" : Convert.ToInt32(Eval("Progress")) == 0 ? "Not Started" : "In Progress" %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>

</asp:Content>
