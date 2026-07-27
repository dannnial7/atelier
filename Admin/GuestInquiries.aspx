<%@ Page Title="Guest Inquiries" Language="C#" MasterPageFile="~/Site.Master"  AutoEventWireup="true" CodeBehind="GuestInquiries.aspx.cs" Inherits="Atelier.Admin.GuestInquiries" %>
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
        .table-panel { background:#FFFFFF; border:0.5px solid #E8E0E2; border-radius:16px; padding:24px; margin-bottom:24px; }
        .reply-panel { background:#FFFFFF; border:0.5px solid #E8E0E2; border-radius:16px; padding:24px; display:none; }
        .inquiry-detail { background:#F0F4F9; border-radius:10px; padding:16px; margin-bottom:16px; }
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
            <a href="~/Admin/GuestInquiries.aspx" runat="server" class="active">Guest Inquiries</a>
            <a href="~/Admin/Analytics.aspx" runat="server">Analytics</a>
            <a href="~/Logout.aspx" runat="server">Sign Out</a>
        </div>

        <div class="admin-main">
            <div class="page-header">
                <h2>Guest Inquiries</h2>
            </div>

            <asp:Label ID="lblMessage"
                runat="server"
                Visible="false"
                style="display:block;margin-bottom:16px"/>

            <div style="display:flex;gap:8px;margin-bottom:16px">
                <asp:Button ID="btnPending"
                    runat="server"
                    Text="Pending"
                    CssClass="btn btn-primary"
                    OnClick="btnPending_Click"
                    CausesValidation="false"/>
                <asp:Button ID="btnResolved"
                    runat="server"
                    Text="Resolved"
                    CssClass="btn btn-secondary"
                    OnClick="btnResolved_Click"
                    CausesValidation="false"/>
                <asp:Button ID="btnAll"
                    runat="server"
                    Text="All"
                    CssClass="btn btn-secondary"
                    OnClick="btnAll_Click"
                    CausesValidation="false"/>
            </div>

            <div class="table-panel">
                <h3 style="margin-bottom:16px">
                    Inquiries
                    <span class="badge badge-info" style="margin-left:8px">
                        <asp:Label ID="lblCount" runat="server" Text="0"/>
                    </span>
                </h3>

                <asp:GridView ID="gvInquiries"
                    runat="server"
                    AutoGenerateColumns="false"
                    OnRowCommand="gvInquiries_RowCommand"
                    EmptyDataText="No inquiries found."
                    CssClass="table">
                    <Columns>
                        <asp:BoundField DataField="InquiryID" HeaderText="ID"/>
                        <asp:BoundField DataField="FullName" HeaderText="Name"/>
                        <asp:BoundField DataField="Email" HeaderText="Email"/>
                        <asp:BoundField DataField="Subject" HeaderText="Subject"/>
                        <asp:BoundField DataField="SubmittedAt" HeaderText="Date" DataFormatString="{0:dd MMM yyyy}"/>
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <span class='<%# Eval("Status").ToString() == "Pending" ? "badge badge-warning" : "badge badge-success" %>'>
                                    <%# Eval("Status") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <asp:LinkButton
                                    runat="server"
                                    CommandName="ViewInquiry"
                                    CommandArgument='<%# Eval("InquiryID") %>'
                                    CssClass="btn btn-secondary btn-sm"
                                    CausesValidation="false">
                                    View & Reply
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

            <div class="reply-panel" id="replyPanel" runat="server">
                <asp:HiddenField ID="hdnInquiryID" runat="server" Value="0"/>

                <h3 style="margin-bottom:16px">Inquiry Details</h3>

                <div class="inquiry-detail">
                    <p><strong>From:</strong>
                        <asp:Label ID="lblGuestName" runat="server"/>
                        (<asp:Label ID="lblGuestEmail" runat="server"/>)
                    </p>
                    <p style="margin-top:8px"><strong>Subject:</strong>
                        <asp:Label ID="lblSubject" runat="server"/>
                    </p>
                    <p style="margin-top:8px"><strong>Message:</strong></p>
                    <p style="margin-top:4px;color:#3D2030">
                        <asp:Label ID="lblMessage2" runat="server"/>
                    </p>
                </div>

                <div class="form-group">
                    <label>Admin Response</label>
                    <asp:TextBox ID="txtResponse"
                        runat="server"
                        TextMode="MultiLine"
                        Rows="4"
                        placeholder="Type your response here..."/>
                    <asp:RequiredFieldValidator
                        runat="server"
                        ControlToValidate="txtResponse"
                        ErrorMessage="Response is required"
                        CssClass="field-error"
                        Display="Dynamic"
                        ValidationGroup="ReplyForm"/>
                </div>

                <div style="display:flex;gap:12px;margin-top:8px">
                    <asp:Button ID="btnSendReply"
                        runat="server"
                        Text="Send Reply"
                        CssClass="btn btn-primary"
                        OnClick="btnSendReply_Click"
                        ValidationGroup="ReplyForm"/>
                    <asp:Button ID="btnCloseReply"
                        runat="server"
                        Text="Close"
                        CssClass="btn btn-secondary"
                        OnClick="btnCloseReply_Click"
                        CausesValidation="false"/>
                </div>
            </div>

        </div>
    </div>

</asp:Content>
