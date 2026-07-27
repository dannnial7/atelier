<%@ Page Title="Announcements" Language="C#" 
    MasterPageFile="~/Site.Master" 
    AutoEventWireup="true" 
    CodeBehind="Announcements.aspx.cs" 
    Inherits="Atelier.Admin.Announcements" %>

<asp:Content ID="HeadContent" 
    ContentPlaceHolderID="HeadContent" 
    runat="server">
    <style>
        .admin-wrapper { display:flex; min-height:calc(100vh - 120px); }
        .admin-sidebar { width:220px; background-color:#4A1020; padding:24px 0; flex-shrink:0; }
        .admin-sidebar h3 { color:#BFCFE8; font-size:13px; text-transform:uppercase; letter-spacing:0.08em; padding:0 20px; margin-bottom:12px; }
        .admin-sidebar a { display:block; padding:10px 20px; color:rgba(191,207,232,0.75); font-size:14px; text-decoration:none; }
        .admin-sidebar a:hover, .admin-sidebar a.active { background-color:#6B1A2A; color:#BFCFE8; text-decoration:none; }
        .admin-main { flex:1; padding:32px 40px; background-color:#F0F4F9; }
        .page-header { display:flex; align-items:center; justify-content:space-between; margin-bottom:24px; }
        .form-panel { background:#FFFFFF; border:0.5px solid #E8E0E2; border-radius:16px; padding:24px; margin-bottom:24px; }
        .announcement-card { background:#FFFFFF; border:0.5px solid #E8E0E2; border-radius:12px; padding:20px; margin-bottom:12px; }
        .announcement-header { display:flex; align-items:center; justify-content:space-between; margin-bottom:8px; }
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
            <a href="~/Admin/ManageForum.aspx" runat="server">Forum</a>
            <a href="~/Admin/Announcements.aspx" runat="server" class="active">Announcements</a>
            <a href="~/Admin/ViewEnrollments.aspx" runat="server">Enrollments</a>
            <a href="~/Admin/GuestInquiries.aspx" runat="server">Guest Inquiries</a>
            <a href="~/Admin/Analytics.aspx" runat="server">Analytics</a>
            <a href="~/Logout.aspx" runat="server">Sign Out</a>
        </div>

        <div class="admin-main">
            <div class="page-header">
                <h2>Announcements</h2>
            </div>

            <asp:Label ID="lblMessage"
                runat="server"
                Visible="false"
                style="display:block;margin-bottom:16px"/>

            <div class="form-panel">
                <h3 style="margin-bottom:16px">
                    Post New Announcement
                </h3>
                <div class="form-group">
                    <label>Title</label>
                    <asp:TextBox ID="txtTitle"
                        runat="server"
                        placeholder="Announcement title"/>
                    <asp:RequiredFieldValidator
                        runat="server"
                        ControlToValidate="txtTitle"
                        ErrorMessage="Title is required"
                        CssClass="field-error"
                        Display="Dynamic"
                        ValidationGroup="AnnouncementForm"/>
                </div>
                <div class="form-group">
                    <label>Message</label>
                    <asp:TextBox ID="txtMessage"
                        runat="server"
                        TextMode="MultiLine"
                        Rows="4"
                        placeholder="Write your announcement here..."/>
                    <asp:RequiredFieldValidator
                        runat="server"
                        ControlToValidate="txtMessage"
                        ErrorMessage="Message is required"
                        CssClass="field-error"
                        Display="Dynamic"
                        ValidationGroup="AnnouncementForm"/>
                </div>
                <asp:Button ID="btnPost"
                    runat="server"
                    Text="Post Announcement"
                    CssClass="btn btn-primary"
                    OnClick="btnPost_Click"
                    ValidationGroup="AnnouncementForm"/>
            </div>

            <h3 style="margin-bottom:16px">
                Previous Announcements
                <span class="badge badge-info" 
                      style="margin-left:8px">
                    <asp:Label ID="lblCount" 
                        runat="server" Text="0"/>
                </span>
            </h3>

            <asp:Label ID="lblNoAnnouncements"
                runat="server"
                Text="No announcements posted yet."
                Visible="false"
                style="color:#5A3A42;font-size:14px"/>

            <asp:Repeater ID="rptAnnouncements" 
                runat="server"
                OnItemCommand="rptAnnouncements_ItemCommand">
                <ItemTemplate>
                    <div class="announcement-card">
                        <div class="announcement-header">
                            <div>
                                <h4 style="color:#6B1A2A">
                                    <%# Eval("Title") %>
                                </h4>
                                <p style="font-size:12px;
                                          color:#5A3A42;
                                          margin-top:2px">
                                    Posted by 
                                    <%# Eval("PostedBy") %> 
                                    on 
                                    <%# Eval("CreatedAt", 
                                        "{0:dd MMM yyyy}") %>
                                </p>
                            
                            <asp:LinkButton
                                runat="server"
                                CommandName="DeleteAnnouncement"
                                CommandArgument='<%# Eval("NotificationID") %>'
                                CssClass="btn btn-danger btn-sm"
                                CausesValidation="false"
                                OnClientClick="if(!confirm('Delete this announcement?')) return false;">
                                Delete
                            </asp:LinkButton>
                        </div>
                            </div>
                        <p style="font-size:14px;
                                  color:#3D2030;
                                  margin-top:8px">
                            <%# Eval("Message") %>
                        </p>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

        </div>
    </div>

</asp:Content>