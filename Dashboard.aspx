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

        <div style="display:flex;flex-wrap:wrap;gap:16px">
            <asp:Repeater ID="rptBadges" runat="server">
                <ItemTemplate>
                    <div class="card-sm" style="min-width:260px;flex:1;max-width:340px;display:flex;flex-direction:column;gap:12px;padding:16px;background:#ffffff;border:1px solid #e2e8f0;border-radius:12px;">
                        <div style="display:flex;align-items:center;gap:12px;">
                            <img src='<%# ResolveUrl(Eval("IconURL") != DBNull.Value && !string.IsNullOrEmpty(Eval("IconURL").ToString()) ? Eval("IconURL").ToString() : "~/Images/Badges/first-steps.png") %>' alt="Badge Icon" style="width:52px;height:52px;object-fit:contain;border-radius:50%;background:#f8fafc;padding:4px;border:1px solid #e2e8f0;" />
                            <div>
                                <strong style="color:var(--heading-colour);font-size:15px;"><%# Eval("BadgeName") %></strong>
                                <p class="course-meta" style="margin-top:4px;font-size:13px"><%# Eval("Description") %></p>
                            </div>
                        </div>
                        <div style="display:flex;gap:8px;margin-top:auto;padding-top:8px;border-top:1px solid #f1f5f9;">
                            <a href='<%# ResolveUrl(Eval("IconURL") != DBNull.Value && !string.IsNullOrEmpty(Eval("IconURL").ToString()) ? Eval("IconURL").ToString() : "~/Images/Badges/first-steps.png") %>' download='<%# Eval("BadgeName") + "-Badge.png" %>' class="btn btn-secondary btn-sm" style="font-size:12px;padding:4px 10px;display:inline-flex;align-items:center;gap:4px;">
                                <svg width="12" height="12" fill="currentColor" viewBox="0 0 24 24"><path d="M19 9h-4V3H9v6H5l7 7 7-7zM5 18v2h14v-2H5z"/></svg> Download
                            </a>
                            <a href='<%# "https://www.linkedin.com/sharing/share-offsite/?url=" + Server.UrlEncode("https://atelier.edu/Badges/" + Eval("BadgeName")) %>' target="_blank" class="btn btn-secondary btn-sm" style="font-size:12px;padding:4px 10px;display:inline-flex;align-items:center;gap:4px;color:#0a66c2 !important;border-color:#0a66c2 !important;">
                                <svg width="12" height="12" fill="currentColor" viewBox="0 0 24 24"><path d="M19 3a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h14m-.5 15.5v-5.3a3.26 3.26 0 0 0-3.26-3.26c-.85 0-1.84.52-2.28 1.3v-1.11h-2.79v8.37h2.79v-4.93c0-.77.62-1.4 1.39-1.4a1.4 1.4 0 0 1 1.4 1.4v4.93h2.75M6.46 10.9v8.37H9.25V10.9H6.46M7.86 6.74a1.62 1.62 0 1 0 0 3.24 1.62 1.62 0 0 0 0-3.24z"/></svg> Share
                            </a>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <%-- Certificates Section --%>
        <h2 class="section-title" style="margin-top:40px">My Certificates</h2>

        <asp:Panel ID="pnlNoCertificates" runat="server" Visible="false">
            <div class="alert alert-info" style="display:flex;align-items:center;gap:10px;">
                <svg width="20" height="20" fill="currentColor" viewBox="0 0 24 24"><path d="M12 2L1 21h22L12 2zm0 3.47L20.47 19H3.53L12 5.47zM11 10h2v4h-2zm0 5h2v2h-2z"/></svg>
                <span>No certificates earned yet. Complete 100% of all course modules and pass the final quiz to unlock your official Certificate of Completion!</span>
            </div>
        </asp:Panel>

        <div style="display:grid;grid-template-columns:repeat(auto-fill, minmax(280px, 1fr));gap:16px;">
            <asp:Repeater ID="rptCertificates" runat="server">
                <ItemTemplate>
                    <div style="background:#ffffff;border:1.5px solid #E2E8F0;border-radius:14px;padding:18px;box-shadow:0 4px 12px rgba(0,0,0,0.04);display:flex;flex-direction:column;gap:12px;">
                        <div style="display:flex;align-items:center;gap:12px;">
                            <img src='<%# ResolveUrl(Eval("Thumbnail") != DBNull.Value ? Eval("Thumbnail").ToString() : "~/Images/Courses/Visual-Arts.jpg") %>' alt="Course Thumbnail" style="width:56px;height:56px;object-fit:cover;border-radius:10px;" />
                            <div>
                                <h4 style="margin:0;font-size:15px;color:#0F172A;"><%# Eval("CourseTitle") %></h4>
                                <span style="font-size:12px;color:#64748B;font-family:monospace;">ID: <%# Eval("CertificateID") %></span>
                            </div>
                        </div>
                        <div style="font-size:12px;color:#475569;display:flex;align-items:center;gap:6px;background:#F8FAFC;padding:6px 10px;border-radius:6px;">
                            <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                            Earned on <%# Eval("CompletedAt", "{0:dd MMM yyyy}") %>
                        </div>
                        <div style="display:flex;gap:8px;margin-top:auto;">
                            <a href='<%# "Certificate.aspx?id=" + Eval("CourseID") %>' class="btn btn-primary btn-sm" style="flex:1;text-align:center;color:#ffffff !important;background:#6B1A2A !important;border:none;font-weight:600;">
                                View Certificate
                            </a>
                            <a href='<%# "https://www.linkedin.com/sharing/share-offsite/?url=" + Server.UrlEncode("https://atelier.edu/Certificate.aspx?id=" + Eval("CourseID")) %>' target="_blank" class="btn btn-secondary btn-sm" style="color:#0a66c2 !important;border-color:#0a66c2 !important;display:inline-flex;align-items:center;gap:4px;">
                                <svg width="12" height="12" fill="currentColor" viewBox="0 0 24 24"><path d="M19 3a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h14m-.5 15.5v-5.3a3.26 3.26 0 0 0-3.26-3.26c-.85 0-1.84.52-2.28 1.3v-1.11h-2.79v8.37h2.79v-4.93c0-.77.62-1.4 1.39-1.4a1.4 1.4 0 0 1 1.4 1.4v4.93h2.75M6.46 10.9v8.37H9.25V10.9H6.46M7.86 6.74a1.62 1.62 0 1 0 0 3.24 1.62 1.62 0 0 0 0-3.24z"/></svg> LinkedIn
                            </a>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <%-- Recent Notifications Card --%>
        <h2 class="section-title" style="margin-top:40px">Recent Notifications</h2>

        <div style="background:#ffffff;border:1px solid #E2E8F0;border-radius:16px;padding:24px;box-shadow:0 8px 24px rgba(0,0,0,0.04);">
            <asp:Panel ID="pnlNoNotifications" runat="server" Visible="false">
                <div class="alert alert-info" style="margin:0;">No new notifications.</div>
            </asp:Panel>

            <div style="display:flex;flex-direction:column;gap:12px;">
                <asp:Repeater ID="rptNotifications" runat="server">
                    <ItemTemplate>
                        <div style="padding:14px 16px;background:#F8FAFC;border:1px solid #F1F5F9;border-radius:10px;display:flex;justify-content:space-between;align-items:flex-start;gap:12px;">
                            <div style="display:flex;gap:12px;align-items:flex-start;">
                                <div style="width:36px;height:36px;border-radius:8px;background:rgba(107,26,42,0.08);color:#6B1A2A;display:flex;align-items:center;justify-content:center;flex-shrink:0;margin-top:2px;">
                                    <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path><path d="M13.73 21a2 2 0 0 1-3.46 0"></path></svg>
                                </div>
                                <div>
                                    <strong style="color:#0F172A;font-size:15px;display:block;"><%# Eval("Title") %></strong>
                                    <p style="margin:4px 0 0;font-size:13.5px;color:#475569;"><%# Eval("Body") %></p>
                                </div>
                            </div>
                            <span style="font-size:12px;color:#94A3B8;white-space:nowrap;flex-shrink:0;">
                                <%# Eval("CreatedAt", "{0:dd MMM yyyy, h:mm tt}") %>
                            </span>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <div style="margin-top:16px;text-align:center;">
                <asp:Button ID="btnViewMoreNotifications" runat="server" Text="View More Notifications" OnClick="btnViewMoreNotifications_Click" CssClass="btn btn-secondary btn-sm" style="font-weight:600;padding:8px 20px;color:#6B1A2A !important;border-color:#6B1A2A !important;background:transparent !important;" />
            </div>
        </div>

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