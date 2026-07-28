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
                    <div class="card-sm" style="min-width:200px">
                        <span class="badge badge-primary"><%# Eval("BadgeName") %></span>
                        <p class="course-meta" style="margin-top:8px"><%# Eval("Description") %></p>
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

    </div>

</asp:Content>