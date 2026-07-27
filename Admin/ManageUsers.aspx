<%@ Page Title="Manage Users" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ManageUsers.aspx.cs" Inherits="Atelier.Admin.ManageUsers" %>
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
        }
        .search-bar {
            display: flex;
            gap: 12px;
            margin-bottom: 16px;
        }
        .search-bar input {
            flex: 1;
            padding: 9px 12px;
            border: 0.5px solid #E8E0E2;
            border-radius: 10px;
            font-size: 14px;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="admin-wrapper">

        <div class="admin-sidebar">
            <h3>Admin Panel</h3>
            <a href="~/Admin/Dashboard.aspx" runat="server">Dashboard</a>
            <a href="~/Admin/ManageCourses.aspx" runat="server">Manage Courses</a>
            <a href="~/Admin/ManageModules.aspx" runat="server">Manage Modules</a>
            <a href="~/Admin/ManageUsers.aspx" runat="server" class="active">Manage Users</a>
            <a href="~/Admin/ManageAssessments.aspx" runat="server">Assessments</a>
            <a href="~/Admin/ManageForum.aspx" runat="server">Forum</a>
            <a href="~/Admin/Announcements.aspx" runat="server">Announcements</a>
            <a href="~/Admin/ViewEnrollments.aspx" runat="server">Enrolments</a>
            <a href="~/Admin/GuestInquiries.aspx" runat="server">Guest Inquiries</a>
            <a href="~/Admin/Analytics.aspx" runat="server">Analytics</a>
            <a href="~/Logout.aspx" runat="server">Sign Out</a>
        </div>

        <div class="admin-main">

            <div class="page-header">
                <h2>Manage Users</h2>
                <asp:Button ID="btnShowAdd" runat="server" 
                    Text="+ Add New User"
                    CssClass="btn btn-primary"
                    OnClick="btnShowAdd_Click"
                    CausesValidation="false"/>
            </div>

                <asp:Label ID="lblMessage" 
                    runat="server" 
                    Visible="false"
                    style="display:block;margin-bottom:16px"/>

            <div id="addPanel" runat="server" 
                     style="display:none;
                            background:#FFFFFF;
                            border:0.5px solid #E8E0E2;
                            border-radius:16px;
                            padding:24px;
                            margin-bottom:24px">

                    <h3 style="margin-bottom:16px">Add New User</h3>

                    <div style="display:grid;
                                grid-template-columns:1fr 1fr;
                                gap:16px">
                        <div class="form-group">
                            <label>Full Name</label>
                            <asp:TextBox ID="txtFullName" 
                                runat="server"/>
                            <asp:RequiredFieldValidator
                                runat="server"
                                ControlToValidate="txtFullName"
                                ErrorMessage="Full name is required"
                                CssClass="field-error"
                                Display="Dynamic"
                                ValidationGroup="AddUser"/>
                        </div>
                        <div class="form-group">
                            <label>Email</label>
                            <asp:TextBox ID="txtEmail" 
                                runat="server"
                                TextMode="Email"/>
                            <asp:RequiredFieldValidator
                                runat="server"
                                ControlToValidate="txtEmail"
                                ErrorMessage="Email is required"
                                CssClass="field-error"
                                Display="Dynamic"
                                ValidationGroup="AddUser"/>
                        </div>
                    </div>

                    <div style="display:grid;
                                grid-template-columns:1fr 1fr;
                                gap:16px">
                        <div class="form-group">
                            <label>Password</label>
                            <asp:TextBox ID="txtPassword" 
                                runat="server"
                                TextMode="Password"/>
                            <asp:RequiredFieldValidator
                                runat="server"
                                ControlToValidate="txtPassword"
                                ErrorMessage="Password is required"
                                CssClass="field-error"
                                Display="Dynamic"
                                ValidationGroup="AddUser"/>
                        </div>
                        <div class="form-group">
                            <label>Role</label>
                            <asp:DropDownList ID="ddlRole" 
                                runat="server">
                                <asp:ListItem Value="Learner">Learner</asp:ListItem>
                                <asp:ListItem Value="Admin">Admin</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>

                    <div style="display:flex;gap:12px;margin-top:8px">
                        <asp:Button ID="btnAddUser" 
                            runat="server" 
                            Text="Add User"
                            CssClass="btn btn-primary"
                            OnClick="btnAddUser_Click"
                            ValidationGroup="AddUser"/>
                        <asp:Button ID="btnCancelAdd" 
                            runat="server" 
                            Text="Cancel"
                            CssClass="btn btn-secondary"
                            OnClick="btnCancelAdd_Click"
                            CausesValidation="false"/>
                    </div>
                    </div>

                <div class="table-panel">

                    <div class="search-bar">
                        <asp:TextBox ID="txtSearch" 
                            runat="server" 
                            placeholder="Search by name or email..."/>
                        <asp:Button ID="btnSearch" 
                            runat="server" 
                            Text="Search"
                            CssClass="btn btn-primary"
                            OnClick="btnSearch_Click"
                            CausesValidation="false"/>
                        <asp:DropDownList ID="ddlRoleFilter" 
                            runat="server"
                            AutoPostBack="true"
                            OnSelectedIndexChanged="ddlRoleFilter_Changed">
                            <asp:ListItem Value="All">All Roles</asp:ListItem>
                            <asp:ListItem Value="Admin">Admin</asp:ListItem>
                            <asp:ListItem Value="Learner">Learner</asp:ListItem>
                        </asp:DropDownList>
                        <asp:Button ID="btnReset" 
                            runat="server" 
                            Text="Reset"
                            CssClass="btn btn-secondary"
                            OnClick="btnReset_Click"
                            CausesValidation="false"/>
                    </div>

                <h3 style="margin-bottom:16px">
                    All Users
                    <span class="badge badge-info" 
                          style="margin-left:8px">
                        <asp:Label ID="lblUserCount" 
                            runat="server" Text="0"/>
                    </span>
                </h3>

                <asp:GridView ID="gvUsers" 
                    runat="server"
                    AutoGenerateColumns="false"
                    OnRowCommand="gvUsers_RowCommand"
                    EmptyDataText="No users found."
                    CssClass="table">
                    <Columns>
                        <asp:BoundField DataField="UserID" 
                            HeaderText="ID"/>
                        <asp:BoundField DataField="FullName" 
                            HeaderText="Full Name"/>
                        <asp:BoundField DataField="Email" 
                            HeaderText="Email"/>
                        <asp:BoundField DataField="Role" 
                            HeaderText="Role"/>
                            <asp:TemplateField HeaderText="Status">
                                <ItemTemplate>
                                    <span class='<%# Convert.ToBoolean(Eval("IsActive")) ? "badge badge-success" : "badge badge-danger" %>'>
                                        <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Suspended" %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="RegisteredAt" 
                                HeaderText="Joined"
                                DataFormatString="{0:dd MMM yyyy}"/>
                            <asp:TemplateField HeaderText="Actions">
                                <ItemTemplate>
                                    <asp:LinkButton runat="server" CommandName="ToggleStatus" CommandArgument='<%# Eval("UserID") + "," + Eval("IsActive") %>'
                                    CssClass="btn btn-secondary btn-sm"
                                    CausesValidation="false">
                                    <%# Convert.ToBoolean(Eval("IsActive")) ? "Suspend" : "Activate" %>
                                </asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="DeleteUser" CommandArgument='<%# Eval("UserID") %>'
                                    CssClass="btn btn-danger btn-sm"
                                    CausesValidation="false"
                                    OnClientClick="if(!confirm('Are you sure you want to delete this user? This cannot be undone.')) return false;"> Delete
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

        </div>
    </div>

</asp:Content>
