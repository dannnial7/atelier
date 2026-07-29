<%@ Page Title="Thread" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ForumThread.aspx.cs" Inherits="Atelier.ForumThread" EnableEventValidation="false" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .thread-header { margin-bottom:8px; }
        .thread-header .meta { font-size:.85rem; opacity:.75; }
        .reply-item { margin-bottom:12px; }
        .reply-item .meta { font-size:.85rem; opacity:.75; margin-bottom:4px; }
        .reply-body { white-space:pre-wrap; }
        .form-row { margin-bottom:12px; }
        .form-row label { display:block; margin-bottom:4px; font-weight:600; }
        .form-row input[type=text], .form-row textarea { width:100%; padding:8px; box-sizing:border-box; }
        .form-row textarea { min-height:100px; resize:vertical; }
        .locked-note { font-weight:600; }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <p><a href="Forum.aspx">&larr; Back to Forum</a></p>

    <asp:Label ID="lblMessage" runat="server" CssClass="alert" Visible="false" />

    <asp:Panel ID="pnlThread" runat="server">
        <div class="card">
            <div class="thread-header">
                <h2>
                    <asp:Literal ID="litPinned" runat="server" />
                    <asp:Literal ID="litLocked" runat="server" />
                    <asp:Literal ID="litTitle" runat="server" />
                </h2>
                <div class="meta" style="display:flex;align-items:center;gap:6px;flex-wrap:wrap;">
                    <span>by <asp:Literal ID="litAuthor" runat="server" /></span>
                    <span>in <asp:Literal ID="litCourse" runat="server" /></span>
                    <span>&middot; <asp:Literal ID="litDate" runat="server" /></span>
                    <span style="display:inline-flex;align-items:center;gap:4px;">
                        &middot;
                        <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" style="vertical-align:-1px;"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                        <asp:Literal ID="litViews" runat="server" /> views
                    </span>
                </div>
            </div>
            <div class="reply-body"><asp:Literal ID="litBody" runat="server" /></div>

            <asp:Panel ID="pnlOwnerActions" runat="server" Visible="false" CssClass="card-sm">
                <asp:Button ID="btnShowEdit" runat="server" Text="Edit" CssClass="btn"
                    CausesValidation="false" OnClick="btnShowEdit_Click" />
                <asp:Button ID="btnDeleteThread" runat="server" Text="Delete Thread" CssClass="btn"
                    CausesValidation="false" OnClick="btnDeleteThread_Click"
                    OnClientClick="return confirm('Delete this thread and all its replies?');" />
            </asp:Panel>
        </div>

        <asp:Panel ID="pnlEdit" runat="server" Visible="false" CssClass="card">
            <h3>Edit Thread</h3>
            <div class="form-row">
                <label>Title</label>
                <asp:TextBox ID="txtEditTitle" runat="server" MaxLength="200" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEditTitle"
                    ErrorMessage="Title is required." CssClass="alert"
                    Display="Dynamic" ValidationGroup="EditThread" />
            </div>
            <div class="form-row">
                <label>Message</label>
                <asp:TextBox ID="txtEditBody" runat="server" TextMode="MultiLine" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEditBody"
                    ErrorMessage="Message is required." CssClass="alert"
                    Display="Dynamic" ValidationGroup="EditThread" />
            </div>
            <asp:Button ID="btnSaveEdit" runat="server" Text="Save Changes"
                CssClass="btn btn-primary" OnClick="btnSaveEdit_Click" ValidationGroup="EditThread" />
            <asp:Button ID="btnCancelEdit" runat="server" Text="Cancel" CausesValidation="false"
                OnClick="btnCancelEdit_Click" />
        </asp:Panel>

        <h3 style="display:flex;align-items:center;gap:8px;">
            <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" style="vertical-align:-2px;"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path></svg>
            Replies
        </h3>

        <asp:Repeater ID="rptReplies" runat="server" OnItemCommand="rptReplies_ItemCommand">
            <ItemTemplate>
                <div class="card card-sm reply-item">
                    <div class="meta">
                        <a href='<%# "UserProfile.aspx?id=" + Eval("UserID") %>' onclick='<%# string.Format("openUserPreview(\"{0}\", \"{1}\", \"{2}\", \"{3}\", \"{4}\"); return false;", Server.HtmlEncode(Eval("FullName").ToString()), Server.HtmlEncode(Eval("Bio").ToString().Replace("\r", "").Replace("\n", " ")), Eval("TotalXP"), Eval("BadgeCount"), Eval("ProfilePic")) %>' style="color:inherit;font-weight:600;text-decoration:underline;"><%# Server.HtmlEncode(Eval("FullName").ToString()) %></a>
                        &middot; <%# Convert.ToDateTime(Eval("PostedAt")).ToString("dd MMM yyyy, HH:mm") %>
                    </div>
                    <div class="reply-body"><%# Server.HtmlEncode(Eval("Body").ToString()) %></div>
                    <asp:Button runat="server" Text="Delete" CommandName="DeleteReply"
                        CommandArgument='<%# Eval("ReplyID") %>'
                        CssClass="btn btn-sm"
                        Visible='<%# CanUserDelete(Eval("UserID")) %>'
                        OnClientClick="return confirm('Delete this reply?');"
                        CausesValidation="false" />
                </div>
            </ItemTemplate>
        </asp:Repeater>

        <asp:Panel ID="pnlNoReplies" runat="server" Visible="false" CssClass="alert">
            No replies yet.
        </asp:Panel>

        <asp:Panel ID="pnlReplyForm" runat="server" CssClass="card">
            <h3>Post a Reply</h3>
            <div class="form-row">
                <asp:TextBox ID="txtReply" runat="server" TextMode="MultiLine" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtReply"
                    ErrorMessage="Reply cannot be empty." CssClass="alert"
                    Display="Dynamic" ValidationGroup="PostReply" />
            </div>
            <asp:Button ID="btnPostReply" runat="server" Text="Post Reply"
                CssClass="btn btn-primary" OnClick="btnPostReply_Click" ValidationGroup="PostReply" />
        </asp:Panel>

        <asp:Panel ID="pnlLocked" runat="server" Visible="false" CssClass="alert">
            <span class="locked-note">This thread is locked. No new replies can be posted.</span>
        </asp:Panel>
    </asp:Panel>

    <asp:Panel ID="pnlNotFound" runat="server" Visible="false" CssClass="alert">
        Thread not found. <a href="Forum.aspx">Return to Forum</a>.
    </asp:Panel>
</asp:Content>