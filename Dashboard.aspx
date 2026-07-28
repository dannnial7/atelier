<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="Atelier.Dashboard" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server"></asp:Content>
<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="container" style="margin-top:40px">

        <h1>Welcome back, <asp:Literal ID="litName" runat="server" />!</h1>
        <p style="color:var(--muted-colour)">Here is your learning progress so far.</p>

        <%-- Stats row --%>
        <div class="grid-stats" style="margin:32px 0">
            <div class="stat-card">
                <asp:Label ID="lblXP" runat="server" CssClass="stat-number" Text="0" />
                <div class="stat-label">Experience Points</div>
            </div>
            <div class="stat-card">
                <asp:Label ID="lblCourses" runat="server" CssClass="stat-number" Text="0" />
                <div class="stat-label">Courses Enrolled</div>
            </div>
            <div class="stat-card">
                <asp:Label ID="lblBadges" runat="server" CssClass="stat-number" Text="0" />
                <div class="stat-label">Badges Earned</div>
            </div>
        </div>

        <%-- Enrolled courses --%>
        <h2 class="section-title">My Courses</h2>

        <asp:Panel ID="pnlNoCourses" runat="server" Visible="false">
            <div class="alert alert-info">
                You have not enrolled in any courses yet.
                <a href="~/Courses.aspx" runat="server">Browse the catalogue</a> to get started.
            </div>
        </asp:Panel>

        <div class="grid-courses">
            <asp:Repeater ID="rptEnrollments" runat="server">
                <ItemTemplate>
                    <div class="course-card">
                        <asp:Image runat="server" CssClass="course-thumbnail"
                            ImageUrl='<%# Eval("Thumbnail") %>'
                            AlternateText='<%# Eval("Title") %>' />
                        <div class="course-body">
                            <p class="course-title"><%# Eval("Title") %></p>
                            <p class="course-meta">
                                <%# Eval("CategoryName") %> &nbsp;&middot;&nbsp; <%# Eval("Difficulty") %>
                            </p>

                            <div class="progress" style="margin:10px 0">
                                <div class="progress-fill" style='<%# "width:" + Eval("Progress") + "%" %>'></div>
                            </div>
                            <p class="course-meta"><%# Eval("Progress") %>% complete</p>

                            <a href='<%# "CourseDetail.aspx?id=" + Eval("CourseID") %>'
                               class="btn btn-primary btn-sm"
                               style="margin-top:8px;display:block;text-align:center;color:#BFCFE8 !important;background-color:#6B1A2A !important;">
                                Continue Learning
                            </a>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <%-- Badges --%>
        <h2 class="section-title" style="margin-top:40px">My Badges</h2>

        <asp:Panel ID="pnlNoBadges" runat="server" Visible="false">
            <div class="alert alert-info">
                No badges yet. Complete a module to earn your first one.
            </div>
        </asp:Panel>

        <div style="display:flex;flex-wrap:wrap;gap:12px">
            <asp:Repeater ID="rptBadges" runat="server">
                <ItemTemplate>
                    <div class="card-sm" style="min-width:240px;display:flex;align-items:center;gap:12px">
                        <img src='<%# ResolveUrl(Eval("IconURL") != DBNull.Value && !string.IsNullOrEmpty(Eval("IconURL").ToString()) ? Eval("IconURL").ToString() : "~/Images/Badges/first-steps.png") %>' alt="Badge Icon" style="width:48px;height:48px;object-fit:contain;border-radius:50%;background:rgba(255,255,255,0.05);padding:4px;" />
                        <div>
                            <strong style="color:var(--heading-colour);"><%# Eval("BadgeName") %></strong>
                            <p class="course-meta" style="margin-top:4px;font-size:13px"><%# Eval("Description") %></p>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <%-- Notifications --%>
        <h2 class="section-title" style="margin-top:40px">Recent Notifications</h2>

        <asp:Panel ID="pnlNoNotifications" runat="server" Visible="false">
            <div class="alert alert-info">No new notifications.</div>
        </asp:Panel>

        <asp:Repeater ID="rptNotifications" runat="server">
            <ItemTemplate>
                <div class="card-sm" style="margin-bottom:10px">
                    <strong><%# Eval("Title") %></strong>
                    <p class="course-meta"><%# Eval("Body") %></p>
                    <p class="course-meta" style="font-size:12px">
                        <%# Eval("CreatedAt", "{0:dd MMM yyyy, h:mm tt}") %>
                    </p>
                </div>
            </ItemTemplate>
        </asp:Repeater>

        <%-- Community Forum & Discussions --%>
        <div style="display:flex;justify-content:space-between;align-items:center;margin-top:40px;">
            <h2 class="section-title" style="margin:0;">Community Forum & Discussions</h2>
            <a href="~/Forum.aspx" runat="server" class="btn btn-secondary btn-sm" style="font-weight:600;">
                Visit Forum &raquo;
            </a>
        </div>

        <asp:Panel ID="pnlNoForumThreads" runat="server" Visible="false" style="margin-top:12px;">
            <div class="alert alert-info">
                No active discussions yet. <a href="~/Forum.aspx" runat="server">Start the first thread!</a>
            </div>
        </asp:Panel>

        <div style="margin-top:16px;">
            <asp:Repeater ID="rptForumThreads" runat="server">
                <ItemTemplate>
                    <div class="card-sm" style="margin-bottom:12px;padding:16px 20px;background:#ffffff;border:1px solid #e2e8f0;border-radius:12px;display:flex;justify-content:space-between;align-items:center;gap:16px;">
                        <div>
                            <strong style="font-size:16px;">
                                <a href='<%# "ForumThread.aspx?id=" + Eval("ForumID") %>' style="text-decoration:none;color:var(--heading-colour, #0f172a);">
                                    <%# Convert.ToBoolean(Eval("Pinned")) ? "<span class='badge badge-primary' style='font-size:11px;margin-right:6px;'>Pinned</span>" : "" %><%# Eval("Title") %>
                                </a>
                            </strong>
                            <p class="course-meta" style="margin-top:4px;font-size:13px;">
                                Posted by <strong><%# Eval("FullName") %></strong> &nbsp;&middot;&nbsp; 
                                <%# Eval("CourseTitle") != DBNull.Value ? Eval("CourseTitle") : "General Discussion" %> &nbsp;&middot;&nbsp; 
                                <%# Eval("CreatedAt", "{0:dd MMM yyyy}") %>
                            </p>
                        </div>
                        <div style="text-align:right;white-space:nowrap;font-size:13px;color:#64748b;display:flex;align-items:center;gap:12px;">
                            <span>
                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:-2px;margin-right:3px;"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path></svg><%# Eval("ReplyCount") %> replies
                            </span>
                            &middot;
                            <span>
                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:-2px;margin-right:3px;"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg><%# Eval("ViewCount") %> views
                            </span>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

    </div>

<div style="margin-top:40px;text-align:center">
    <h2 class="section-title">My Portfolio</h2>
    <a href="~/Portfolio.aspx" 
       runat="server"
       class="btn btn-primary">
        View My Portfolio
    </a>
</div>

</asp:Content>