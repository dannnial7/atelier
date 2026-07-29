<%@ Page Title="User Profile & Dashboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="UserProfile.aspx.cs" Inherits="Atelier.UserProfile" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server"></asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="container" style="margin-top:40px;margin-bottom:60px;">

        <p><a href="javascript:history.back()" style="display:inline-flex;align-items:center;gap:6px;font-weight:600;">&larr; Back</a></p>

        <asp:Panel ID="pnlNotFound" runat="server" Visible="false">
            <div class="alert alert-danger" style="margin-top:20px;">
                Learner profile not found. <a href="Leaderboard.aspx">Return to Leaderboard</a>
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlProfile" runat="server">

            <%-- Profile Hero Card --%>
            <div class="card" style="margin-top:20px;padding:36px;text-align:center;border-radius:20px;box-shadow:0 12px 36px rgba(0,0,0,0.08);">
                <asp:Image ID="imgAvatar" runat="server" CssClass="profile-pic" style="width:120px;height:120px;border-radius:50%;object-fit:cover;border:3.5px solid #6B1A2A;margin-bottom:16px;box-shadow:0 8px 24px rgba(107,26,42,0.18);" />
                <h1 style="font-size:30px;font-weight:700;margin:0 0 8px 0;display:flex;align-items:center;justify-content:center;gap:10px;">
                    <asp:Literal ID="litFullName" runat="server" />
                    <span class="badge badge-primary" style="font-size:12px;font-weight:600;"><asp:Literal ID="litRole" runat="server" /></span>
                </h1>
                <p style="font-size:15px;color:var(--muted-colour);max-width:550px;margin:0 auto 24px auto;line-height:1.6;">
                    <asp:Literal ID="litBio" runat="server" />
                </p>

                <%-- Public Stats Grid --%>
                <div class="grid-stats" style="max-width:650px;margin:0 auto;">
                    <div class="stat-card" style="padding:18px;border-radius:14px;text-align:center;">
                        <asp:Label ID="lblXP" runat="server" CssClass="stat-number" style="font-size:28px;font-weight:700;color:#6B1A2A;" />
                        <div style="font-size:13px;color:var(--muted-colour);margin-top:4px;">Total Experience Points</div>
                    </div>
                    <div class="stat-card" style="padding:18px;border-radius:14px;text-align:center;">
                        <asp:Label ID="lblBadges" runat="server" CssClass="stat-number" style="font-size:28px;font-weight:700;color:#059669;" />
                        <div style="font-size:13px;color:var(--muted-colour);margin-top:4px;">Badges Earned</div>
                    </div>
                    <div class="stat-card" style="padding:18px;border-radius:14px;text-align:center;">
                        <asp:Label ID="lblCourses" runat="server" CssClass="stat-number" style="font-size:28px;font-weight:700;color:#0284c7;" />
                        <div style="font-size:13px;color:var(--muted-colour);margin-top:4px;">Courses Enrolled</div>
                    </div>
                </div>
            </div>

            <%-- Badges Showcase --%>
            <h2 class="section-title" style="margin-top:40px;">Badges Showcase</h2>
            <asp:Panel ID="pnlNoBadges" runat="server" Visible="false">
                <div class="alert alert-info">This learner has not earned any badges yet.</div>
            </asp:Panel>
            <div style="display:flex;flex-wrap:wrap;gap:16px;">
                <asp:Repeater ID="rptBadges" runat="server">
                    <ItemTemplate>
                        <div class="card-sm" style="min-width:260px;flex:1;max-width:340px;display:flex;flex-direction:column;gap:12px;padding:16px;background:#ffffff;border:1px solid #e2e8f0;border-radius:12px;">
                            <div style="display:flex;align-items:center;gap:12px;">
                                <img src='<%# ResolveUrl(Eval("IconURL") != DBNull.Value && !string.IsNullOrEmpty(Eval("IconURL").ToString()) ? Eval("IconURL").ToString() : "~/Images/Badges/first-steps.png") %>' alt="Badge Icon" style="width:48px;height:48px;object-fit:contain;border-radius:50%;background:#f8fafc;padding:4px;border:1px solid #e2e8f0;" />
                                <div>
                                    <h4 style="margin:0;font-size:15px;font-weight:600;"><%# Eval("BadgeName") %></h4>
                                    <span style="font-size:12px;color:var(--muted-colour);"><%# Convert.ToDateTime(Eval("EarnedAt")).ToString("dd MMM yyyy") %></span>
                                </div>
                            </div>
                            <p style="margin:0;font-size:13px;color:var(--muted-colour);line-height:1.4;"><%# Eval("Description") %></p>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <%-- Enrolled Courses Showcase --%>
            <h2 class="section-title" style="margin-top:40px;">Enrolled Courses</h2>
            <asp:Panel ID="pnlNoCourses" runat="server" Visible="false">
                <div class="alert alert-info">This learner has not enrolled in any public courses yet.</div>
            </asp:Panel>
            <div class="grid-courses">
                <asp:Repeater ID="rptCourses" runat="server">
                    <ItemTemplate>
                        <div class="course-card">
                            <img src='<%# Eval("Thumbnail") %>' class="course-thumbnail" alt='<%# Eval("Title") %>' />
                            <div class="course-body">
                                <p class="course-title"><%# Eval("Title") %></p>
                                <p class="course-meta"><%# Eval("CategoryName") %></p>
                                <a href='<%# "CourseDetail.aspx?id=" + Eval("CourseID") %>' class="btn btn-primary btn-sm" style="margin-top:8px;display:block;text-align:center;color:#BFCFE8 !important;background-color:#6B1A2A !important;">
                                    View Course
                                </a>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

        </asp:Panel>

    </div>

</asp:Content>
