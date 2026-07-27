<%@ Page Title="Manage Modules" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ManageModules.aspx.cs" Inherits="Atelier.Admin.ManageModules" ValidateRequest="false" %>
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
        .form-panel {
            background: #FFFFFF;
            border: 0.5px solid #E8E0E2;
            border-radius: 16px;
            padding: 24px;
            margin-bottom: 24px;
            display: none;
        }
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }
        .table-panel {
            background: #FFFFFF;
            border: 0.5px solid #E8E0E2;
            border-radius: 16px;
            padding: 24px;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="admin-wrapper">

        <div class="admin-sidebar">
            <h3>Admin Panel</h3>
            <a href="~/Admin/Dashboard.aspx" runat="server">Dashboard</a>
            <a href="~/Admin/ManageCourses.aspx" runat="server">Manage Courses</a>
            <a href="~/Admin/ManageModules.aspx" runat="server" class="active">Manage Modules</a>
            <a href="~/Admin/ManageUsers.aspx" runat="server">Manage Users</a>
            <a href="~/Admin/ManageAssessments.aspx" runat="server">Assessments</a>
            <a href="~/Admin/ManageForum.aspx" runat="server">Forum</a>
            <a href="~/Admin/Announcements.aspx" runat="server">Announcements</a>
            <a href="~/Admin/ViewEnrolments.aspx" runat="server">Enrollments</a>
            <a href="~/Admin/GuestInquiries.aspx" runat="server">Guest Inquiries</a>
            <a href="~/Admin/Analytics.aspx" runat="server">Analytics</a>
            <a href="~/Logout.aspx" runat="server">Sign Out</a>
        </div>

        <div class="admin-main">

            <div class="page-header">
                <h2>Manage Modules</h2>
                <asp:Button ID="btnShowAdd" 
                    runat="server" 
                    Text="+ Add New Module"
                    CssClass="btn btn-primary"
                    OnClick="btnShowAdd_Click"
                    CausesValidation="false"/>
            </div>

            <asp:Label ID="lblMessage" 
                runat="server" 
                Visible="false"
                style="display:block;margin-bottom:16px"/>
           

            <div style="background:#FFFFFF;
                        border:0.5px solid #E8E0E2;
                        border-radius:16px;
                        padding:16px 24px;
                        margin-bottom:16px;
                        display:flex;
                        align-items:center;
                        gap:12px">
                <label style="font-weight:500;
                              font-size:14px">
                    Filter by Course:
                </label>
                <asp:DropDownList 
                    ID="ddlFilterCourse" 
                    runat="server"
                    AutoPostBack="true"
                    OnSelectedIndexChanged="ddlFilterCourse_Changed"
                    style="padding:6px 12px;
                           border:0.5px solid #E8E0E2;
                           border-radius:8px;
                           font-size:14px"/>
            </div>

                <div class="form-panel" 
                     id="formPanel" runat="server">
                    <h3 style="margin-bottom:16px">
                        <asp:Label ID="lblFormTitle" 
                            runat="server" 
                            Text="Add New Module"/>
                    </h3>

                    <asp:HiddenField ID="hdnModuleID" 
                        runat="server" Value="0"/>

                    <div class="form-row">
                        <div class="form-group">
                            <label>Course</label>
                            <asp:DropDownList 
                                ID="ddlCourse" 
                                runat="server"/>
                            <asp:RequiredFieldValidator
                                runat="server"
                                ControlToValidate="ddlCourse"
                                InitialValue="0"
                                ErrorMessage="Please select a course"
                                CssClass="field-error"
                                Display="Dynamic"
                                ValidationGroup="ModuleForm"/>
                        </div>
                    <div class="form-group">
                        <label>Module Title</label>
                        <asp:TextBox ID="txtTitle" 
                            runat="server"/>
                        <asp:RequiredFieldValidator
                            runat="server"
                            ControlToValidate="txtTitle"
                            ErrorMessage="Title is required"
                            CssClass="field-error"
                            Display="Dynamic"
                            ValidationGroup="ModuleForm"/>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label>Content Type</label>
                        <asp:DropDownList 
                            ID="ddlContentType" 
                            runat="server">
                            <asp:ListItem Value="video">Video</asp:ListItem>
                            <asp:ListItem Value="text">Text</asp:ListItem>
                            <asp:ListItem Value="pdf">PDF</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="form-group">
                        <label>Content URL</label>
                        <asp:TextBox ID="txtContentURL" 
                            runat="server"
                            placeholder="https://www.youtube.com/embed/..."/>
                    </div>
                </div>

                <div class="form-group">
                    <label>Description</label>
                    <asp:TextBox ID="txtDescription" 
                        runat="server" 
                        TextMode="MultiLine" 
                        Rows="4"/>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label>Order Index</label>
                        <asp:TextBox ID="txtOrderIndex" 
                            runat="server" 
                            Text="1"/>
                        <asp:RequiredFieldValidator
                            runat="server"
                            ControlToValidate="txtOrderIndex"
                            ErrorMessage="Order is required"
                            CssClass="field-error"
                            Display="Dynamic"
                            ValidationGroup="ModuleForm"/>
                        <asp:RangeValidator
                            runat="server"
                            ControlToValidate="txtOrderIndex"
                            MinimumValue="1"
                            MaximumValue="100"
                            Type="Integer"
                            ErrorMessage="Order must be between 1 and 100"
                            CssClass="field-error"
                            Display="Dynamic"
                            ValidationGroup="ModuleForm"/>
                    </div>
                    <div class="form-group">
                        <label>Duration (minutes)</label>
                        <asp:TextBox ID="txtDuration" 
                            runat="server" 
                            Text="0"/>
                        <asp:RangeValidator
                            runat="server"
                            ControlToValidate="txtDuration"
                            MinimumValue="0"
                            MaximumValue="999"
                            Type="Integer"
                            ErrorMessage="Duration must be between 0 and 999"
                            CssClass="field-error"
                            Display="Dynamic"
                            ValidationGroup="ModuleForm"/>
                    </div>
                </div>

                <div class="form-group">
                    <asp:CheckBox ID="chkIsPreview" 
                        runat="server" 
                        Text=" Allow guest preview"/>
                </div>

                <div style="display:flex;
                            gap:12px;margin-top:8px">
                    <asp:Button ID="btnSave" 
                        runat="server" 
                        Text="Save Module"
                        CssClass="btn btn-primary"
                        OnClick="btnSave_Click"
                        ValidationGroup="ModuleForm"/>
                    <asp:Button ID="btnCancel" 
                        runat="server" 
                        Text="Cancel"
                        CssClass="btn btn-secondary"
                        OnClick="btnCancel_Click"
                        CausesValidation="false"/>
                </div>
            </div>

            <div class="table-panel">
                <h3 style="margin-bottom:16px">
                    All Modules
                    <span class="badge badge-info" 
                          style="margin-left:8px">
                        <asp:Label ID="lblModuleCount" 
                            runat="server" Text="0"/>
                    </span>
                </h3>

                <asp:GridView ID="gvModules" 
                    runat="server"
                    AutoGenerateColumns="false"
                    OnRowCommand="gvModules_RowCommand"
                    EmptyDataText="No modules found."
                    CssClass="table">
                    <Columns>
                        <asp:BoundField DataField="ModuleID" 
                            HeaderText="ID"/>
                        <asp:BoundField DataField="CourseTitle" 
                            HeaderText="Course"/>
                        <asp:BoundField DataField="Title" 
                            HeaderText="Title"/>
                        <asp:BoundField DataField="ContentType" 
                            HeaderText="Type"/>
                        <asp:BoundField DataField="OrderIndex" 
                            HeaderText="Order"/>
                        <asp:BoundField DataField="DurationMins" 
                            HeaderText="Duration (mins)"/>
                        <asp:TemplateField HeaderText="Preview">
                            <ItemTemplate>
                                <span class='<%# Convert.ToBoolean(Eval("IsPreview")) ? "badge badge-success" : "badge badge-info" %>'>
                                    <%# Convert.ToBoolean(Eval("IsPreview")) ? "Yes" : "No" %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <asp:LinkButton 
                                    runat="server"
                                    CommandName="EditModule"
                                    CommandArgument='<%# Eval("ModuleID") %>'
                                    CssClass="btn btn-secondary btn-sm"
                                    CausesValidation="false">
                                    Edit
                                </asp:LinkButton>
                                <asp:LinkButton 
                                    runat="server"
                                    CommandName="DeleteModule"
                                    CommandArgument='<%# Eval("ModuleID") %>'
                                    CssClass="btn btn-danger btn-sm"
                                    CausesValidation="false"
                                    OnClientClick="if(!confirm('Delete this module?')) return false;">
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
