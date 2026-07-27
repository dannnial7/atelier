<%@ Page Title="Manage Forum" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ManageForum.aspx.cs" Inherits="Atelier.Admin.ManageForum" %>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .admin-wrapper {
            display: flex;
            min-height: calc(100vh - 120px);
        }
        .admin-sidebar {
            width: 220px;
            background-color: #4A1020;
            padding: 24px 0;
            flex-shrink: 0;
        }
        .admin-sidebar h3 {
            color: #BFCFE8;
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
        .page-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 24px;
        }
        .table-panel {
            background: #FFFFFF;
            border: 0.5px solid #E8E0E2;
            border-radius: 16px;
            padding: 24px;
            margin-bottom: 24px;
        }
        .tab-buttons {
            display: flex;
            gap: 8px;
            margin-bottom: 24px;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" 
    ContentPlaceHolderID="MainContent" 
    runat="server">

    <div class="admin-wrapper">
        <div class="admin-sidebar">
            <h3>Admin Panel</h3>
            <a href="~/Admin/Dashboard.aspx" runat="server">Dashboard</a>
            <a href="~/Admin/ManageCourses.aspx" runat="server">Manage Courses</a>
            <a href="~/Admin/ManageModules.aspx" runat="server">Manage Modules</a>
            <a href="~/Admin/ManageUsers.aspx" runat="server">Manage Users</a>
            <a href="~/Admin/ManageAssessments.aspx" runat="server">Assessments</a>
            <a href="~/Admin/ManageForum.aspx" runat="server" class="active">Forum</a>
            <a href="~/Admin/Announcements.aspx" runat="server">Announcements</a>
            <a href="~/Admin/ViewEnrolments.aspx" runat="server">Enrollments</a>
            <a href="~/Admin/GuestInquiries.aspx" runat="server">Guest Inquiries</a>
            <a href="~/Admin/Analytics.aspx" runat="server">Analytics</a>
            <a href="~/Logout.aspx" runat="server">Sign Out</a>
        </div>

        <div class="admin-main">

            <div class="page-header">
                <h2>Manage Forum</h2>
            </div>

            <asp:Label ID="lblMessage" 
                runat="server" 
                Visible="false"
                style="display:block;margin-bottom:16px"/>

            <div class="tab-buttons">
                <asp:Button ID="btnShowThreads" 
                    runat="server" 
                    Text="All Threads"
                    CssClass="btn btn-primary"
                    OnClick="btnShowThreads_Click"
                    CausesValidation="false"/>
                <asp:Button ID="btnShowReported" 
                    runat="server" 
                    Text="Reported Posts"
                    CssClass="btn btn-secondary"
                    OnClick="btnShowReported_Click"
                    CausesValidation="false"/>
            </div>

            <div class="table-panel" 
                 id="threadsPanel" runat="server">
                <h3 style="margin-bottom:16px">
                    Forum Threads
                    <span class="badge badge-info" 
                          style="margin-left:8px">
                        <asp:Label ID="lblThreadCount" 
                            runat="server" Text="0"/>
                    </span>
                </h3>

                <asp:GridView ID="gvThreads" 
                    runat="server"
                    AutoGenerateColumns="false"
                    OnRowCommand="gvThreads_RowCommand"
                    EmptyDataText="No threads found."
                    CssClass="table">
                    <Columns>
                        <asp:BoundField DataField="ForumID" 
                            HeaderText="ID"/>
                        <asp:BoundField DataField="Title" 
                            HeaderText="Title"/>
                        <asp:BoundField DataField="FullName" 
                            HeaderText="Posted By"/>
                        <asp:BoundField DataField="CourseTitle" 
                            HeaderText="Course"/>
                        <asp:BoundField DataField="CreatedAt" 
                            HeaderText="Date"
                            DataFormatString="{0:dd MMM yyyy}"/>
                        <asp:BoundField DataField="ReplyCount" 
                            HeaderText="Replies"/>
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <asp:LinkButton 
                                    runat="server"
                                    CommandName="DeleteThread"
                                    CommandArgument='<%# Eval("ForumID") %>'
                                    CssClass="btn btn-danger btn-sm"
                                    CausesValidation="false"
                                    OnClientClick="if(!confirm('Delete this thread and all its replies?')) return false;">
                                    Delete
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

            <div class="table-panel" 
                 id="reportedPanel" runat="server"
                 style="display:none">
                <h3 style="margin-bottom:16px">
                    Reported Posts
                    <span class="badge badge-danger" 
                          style="margin-left:8px">
                        <asp:Label ID="lblReportedCount" 
                            runat="server" Text="0"/>
                    </span>
                </h3>

                <asp:GridView ID="gvReported" 
                    runat="server"
                    AutoGenerateColumns="false"
                    OnRowCommand="gvReported_RowCommand"
                    EmptyDataText="No reported posts."
                    CssClass="table">
                    <Columns>
                        <asp:BoundField DataField="ReplyID" 
                            HeaderText="ID"/>
                        <asp:BoundField DataField="Body" 
                            HeaderText="Content"/>
                        <asp:BoundField DataField="FullName" 
                            HeaderText="Posted By"/>
                        <asp:BoundField DataField="ReportReason" 
                            HeaderText="Reason"/>
                        <asp:BoundField DataField="PostedAt" 
                            HeaderText="Date"
                            DataFormatString="{0:dd MMM yyyy}"/>
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <asp:LinkButton 
                                    runat="server"
                                    CommandName="DismissReport"
                                    CommandArgument='<%# Eval("ReplyID") %>'
                                    CssClass="btn btn-secondary btn-sm"
                                    CausesValidation="false">
                                    Dismiss
                                </asp:LinkButton>
                                <asp:LinkButton 
                                    runat="server"
                                    CommandName="DeleteReply"
                                    CommandArgument='<%# Eval("ReplyID") %>'
                                    CssClass="btn btn-danger btn-sm"
                                    CausesValidation="false"
                                    OnClientClick="if(!confirm('Delete this post?')) return false;">
                                    Delete
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

        </div>
    </div>

</asp:Content>
