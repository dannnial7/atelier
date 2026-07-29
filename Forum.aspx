<%@ Page Title="Forum" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Forum.aspx.cs" Inherits="Atelier.Forum" EnableEventValidation="false" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .forum-toolbar { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; margin-bottom:20px; }
        .forum-toolbar .filter-group { display:flex; align-items:center; gap:8px; }
        .thread-row { display:block; text-decoration:none; color:inherit; }
        .thread-meta { font-size:.85rem; opacity:.75; margin-top:4px; }
        .thread-stats { display:flex; gap:16px; font-size:.85rem; opacity:.85; white-space:nowrap; }
        .thread-flex { display:flex; justify-content:space-between; align-items:flex-start; gap:16px; }
        .form-row { margin-bottom:12px; }
        .form-row label { display:block; margin-bottom:4px; font-weight:600; }
        .form-row input[type=text], .form-row textarea, .form-row select { width:100%; padding:8px; box-sizing:border-box; }
        .form-row textarea { min-height:120px; resize:vertical; }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <h2>Community Forum</h2>

    <asp:Label ID="lblMessage" runat="server" CssClass="alert" Visible="false" />

    <div class="forum-toolbar">
        <div class="filter-group">
            <label>Course:</label>
            <asp:DropDownList ID="ddlFilterCourse" runat="server" AutoPostBack="true"
                OnSelectedIndexChanged="ddlFilterCourse_SelectedIndexChanged" />
        </div>
        <asp:Button ID="btnShowNew" runat="server" Text="New Thread"
            CssClass="btn btn-primary"
            OnClientClick="document.getElementById('newThreadPanel').style.display='block'; return false;" />
    </div>

    <div id="newThreadPanel" class="card" style="display:none;">
        <h3>Start a New Thread</h3>
        <div class="form-row">
            <label>Course</label>
            <asp:DropDownList ID="ddlNewCourse" runat="server" />
            <asp:RequiredFieldValidator runat="server" ControlToValidate="ddlNewCourse"
                InitialValue="" ErrorMessage="Please select a course." CssClass="alert"
                Display="Dynamic" ValidationGroup="NewThread" />
        </div>
        <div class="form-row">
            <label>Title</label>
            <asp:TextBox ID="txtTitle" runat="server" MaxLength="200" />
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtTitle"
                ErrorMessage="Title is required." CssClass="alert"
                Display="Dynamic" ValidationGroup="NewThread" />
        </div>
        <div class="form-row">
            <label>Message</label>
            <asp:TextBox ID="txtBody" runat="server" TextMode="MultiLine" />
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtBody"
                ErrorMessage="Message is required." CssClass="alert"
                Display="Dynamic" ValidationGroup="NewThread" />
        </div>
        <asp:Button ID="btnCreate" runat="server" Text="Post Thread"
            CssClass="btn btn-primary" OnClick="btnCreate_Click" ValidationGroup="NewThread" />
        <asp:Button ID="btnCancel" runat="server" Text="Cancel" CausesValidation="false"
            OnClientClick="document.getElementById('newThreadPanel').style.display='none'; return false;" />
    </div>

    <asp:Repeater ID="rptThreads" runat="server" OnItemCommand="rptThreads_ItemCommand">
        <ItemTemplate>
            <div class="card card-sm">
                <div class="thread-flex">
                    <div style="flex:1;">
                        <a class="thread-row" href='ForumThread.aspx?id=<%# Eval("ForumID") %>'>
                            <strong>
                                <%# (bool)Eval("Pinned") ? "<span class='badge'>Pinned</span> " : "" %>
                                <%# (bool)Eval("Locked") ? "<span class='badge'>Locked</span> " : "" %>
                                <%# Server.HtmlEncode(Eval("Title").ToString()) %>
                            </strong>
                            <div class="thread-meta">
                                by <a href='<%# "Profile.aspx?id=" + Eval("UserID") %>' style="color:inherit;font-weight:600;text-decoration:underline;"><%# Server.HtmlEncode(Eval("FullName").ToString()) %></a>
                                in <%# Server.HtmlEncode(Eval("CourseTitle").ToString()) %>
                                &middot; <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy, HH:mm") %>
                            </div>
                        </a>
                    </div>
                    <div style="text-align:right;">
                        <div class="thread-stats" style="display:flex;align-items:center;justify-content:flex-end;gap:14px;margin-bottom:6px;">
                            <span style="display:inline-flex;align-items:center;gap:4px;font-size:13px;opacity:0.85;">
                                <svg width="15" height="15" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" style="vertical-align:-2px;"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path></svg>
                                <%# Eval("ReplyCount") %> replies
                            </span>
                            <span style="display:inline-flex;align-items:center;gap:4px;font-size:13px;opacity:0.85;">
                                <svg width="15" height="15" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" style="vertical-align:-2px;"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                                <%# Eval("ViewCount") %> views
                            </span>
                        </div>
                        <asp:Button runat="server" Text="Delete" CommandName="DeleteThread"
                            CommandArgument='<%# Eval("ForumID") %>'
                            CssClass="btn btn-sm"
                            Visible='<%# CanUserDelete(Eval("UserID")) %>'
                            OnClientClick="return confirm('Delete this thread and all its replies?');"
                            CausesValidation="false" />
                    </div>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="alert">
        No threads yet. Be the first to start a discussion!
    </asp:Panel>
</asp:Content>